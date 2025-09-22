# qemu-vm (Nix QEMU variant; multi-arch aarch64/x86_64; vmnet + optional SPICE/VNC)
# Requires Nix packages: qemu (and optionally: spice-gtk for `spicy`)
#
# - Pick guest arch at create time:  --arch aarch64 | x86_64
# - Auto-picks QEMU binary per arch
# - Auto-locates firmware from Nix store (edk2 for aarch64 or OVMF/edk2 for x86_64)
# - Sensible defaults per arch:
#     aarch64: MACHINE=virt,gic-version=3  ACCEL=hvf   CPU=host
#     x86_64 : MACHINE=q35                 ACCEL=tcg*  CPU=qemu64
#   (*) On Apple Silicon, x86_64 cannot use HVF; we default to TCG.
#
# QEMU binaries (Nix-managed):
#   /run/current-system/sw/bin/qemu-system-aarch64
#   /run/current-system/sw/bin/qemu-system-x86_64
#
# Firmware is auto-detected under .../share/qemu/ in your Nix profiles/store.

# --- Paths (globals) -----------------------------------------------------
# These will be overridden per-VM at create time and stored in vm.conf.
set -gx _QEMU_BIN ""        # resolved per-VM from ARCH
set -gx _QEMU_EFI_CODE ""   # resolved per-VM by firmware locator
set -gx _QEMU_EFI_VARS_TPL ""

# --- Helpers -------------------------------------------------------------
function _qemu_require --argument-names path msg
    if not test -f "$path"
        echo "$msg: $path" >&2
        return 1
    end
end

function _qemu_vmroot --argument-names name
    echo "$HOME/vms/$name"
end

function _qemu_conf_path --argument-names name
    echo (_qemu_vmroot $name)/vm.conf
end

function _qemu_source_conf --argument-names name
    set -l CONF (_qemu_conf_path $name)
    if not test -f "$CONF"
        echo "Config not found: $CONF" >&2
        return 1
    end
    source "$CONF"
end

# Pick qemu-system-* per arch
function _qemu_pick_bin --argument-names arch
    switch "$arch"
        case aarch64
            echo "/run/current-system/sw/bin/qemu-system-aarch64"
        case x86_64
            echo "/run/current-system/sw/bin/qemu-system-x86_64"
        case '*'
            echo "" >&2
            return 1
    end
end

# Locate firmware for the given arch; sets globals _QEMU_EFI_CODE/_QEMU_EFI_VARS_TPL
function _qemu_locate_firmware --argument-names arch qemu_bin
    # Candidate directories to search
    set -l candidates \
        "/run/current-system/sw/share/qemu" \
        "/nix/var/nix/profiles/system/sw/share/qemu"

    # Also try next to the qemu binary in the store
    if test -n "$qemu_bin"
        set -l binreal (realpath $qemu_bin 2>/dev/null)
        if test -n "$binreal"
            set -l maybe (string replace -r '/bin/qemu-system-(aarch64|x86_64)$' '/share/qemu' $binreal)
            if test -d "$maybe"
                set candidates $candidates $maybe
            end
        end
    end

    # Arch-specific filename patterns (code,vars) in preference order
    set -l patterns
    switch "$arch"
        case aarch64
            # edk2 for AArch64
            set patterns \
                "edk2-aarch64-code.fd edk2-arm-vars.fd"
        case x86_64
            # Try OVMF first, then edk2-x86_64 variants found in some builds
            set patterns \
                "OVMF_CODE.fd OVMF_VARS.fd" \
                "edk2-x86_64-code.fd edk2-i386-vars.fd" \
                "edk2-x86_64-code.fd edk2-x86_64-vars.fd"
        case '*'
            echo "Unsupported arch for firmware lookup: $arch" >&2
            return 1
    end

    for d in $candidates
        if not test -d "$d"; continue; end
        for p in $patterns
            set -l code (string split ' ' -- $p)[1]
            set -l vars (string split ' ' -- $p)[2]
            if test -f "$d/$code" -a -f "$d/$vars"
                set -gx _QEMU_EFI_CODE     "$d/$code"
                set -gx _QEMU_EFI_VARS_TPL "$d/$vars"
                return 0
            end
        end
    end

    # Last resort: scan store for qemu outputs
    for d in /nix/store/*-qemu-*/share/qemu
        if not test -d "$d"; continue; end
        for p in $patterns
            set -l code (string split ' ' -- $p)[1]
            set -l vars (string split ' ' -- $p)[2]
            if test -f "$d/$code" -a -f "$d/$vars"
                set -gx _QEMU_EFI_CODE     "$d/$code"
                set -gx _QEMU_EFI_VARS_TPL "$d/$vars"
                return 0
            end
        end
    end

    echo "ERROR: Could not find UEFI firmware for $arch (looked for: $patterns)" >&2
    echo "Hint: ensure 'qemu' (and its firmware) is in your Nix profile." >&2
    return 1
end

# Build net args (vmnet-shared | vmnet-bridged | user)
function _qemu_net_args --argument-names net_mode bridge_if mac hostfwd_meye hostfwd_ssh
    switch "$net_mode"
        case vmnet-shared
            printf "%s\n" "-netdev" "vmnet-shared,id=net0" "-device" "virtio-net-pci,mac=$mac,netdev=net0"
        case vmnet-bridged
            printf "%s\n" "-netdev" "vmnet-bridged,id=net0,ifname=$bridge_if" "-device" "virtio-net-pci,mac=$mac,netdev=net0"
        case user
            set -l forwards ""
            if test -n "$hostfwd_meye"
                set forwards "hostfwd=tcp::"$hostfwd_meye"-:"$hostfwd_meye
            end
            if test -n "$hostfwd_ssh"
                if test -n "$forwards"; set forwards $forwards","; end
                set forwards $forwards"hostfwd=tcp::"$hostfwd_ssh"-:22"
            end
            if test -n "$forwards"
                printf "%s\n" "-netdev" "user,id=net0,$forwards" "-device" "virtio-net-pci,mac=$mac,netdev=net0"
            else
                printf "%s\n" "-netdev" "user,id=net0" "-device" "virtio-net-pci,mac=$mac,netdev=net0"
            end
        case '*'
            echo "Unsupported NET_MODE '$net_mode' (use vmnet-shared, vmnet-bridged, or user)" >&2
            return 1
    end
end

# Build display args (cocoa | spice-tcp | spice-uds | vnc-tcp | vnc-uds). Always add virtio-gpu-pci.
function _qemu_display_args --argument-names name
    _qemu_source_conf $name; or return 1
    set -l base "-vga" "none" "-device" "virtio-gpu-pci"

    switch "$DISPLAY_MODE"
        case cocoa
            printf "%s\n" $base "-display" "cocoa"
        case spice-tcp
            printf "%s\n" $base \
                "-spice" "addr=$SPICE_ADDR,port=$SPICE_PORT,disable-ticketing=$SPICE_DISABLE_TICKETING,image-compression=off,playback-compression=off,streaming-video=off" \
                "-device" "virtio-serial" \
                "-chardev" "spicevmc,id=vdagent,name=vdagent" \
                "-device" "virtserialport,chardev=vdagent,name=com.redhat.spice.0"
        case spice-uds
            printf "%s\n" $base \
                "-spice" "unix=on,addr=$SPICE_SOCK,disable-ticketing=$SPICE_DISABLE_TICKETING,image-compression=off,playback-compression=off,streaming-video=off" \
                "-device" "virtio-serial" \
                "-chardev" "spicevmc,id=vdagent,name=vdagent" \
                "-device" "virtserialport,chardev=vdagent,name=com.redhat.spice.0"
        case vnc-tcp
            printf "%s\n" $base "-vnc" "$VNC_HOST:$VNC_DISPLAY"
        case vnc-uds
            printf "%s\n" $base "-vnc" "unix:$VNC_SOCK"
        case '*'
            echo "Unsupported DISPLAY_MODE '$DISPLAY_MODE' (use cocoa | spice-tcp | spice-uds | vnc-tcp | vnc-uds)" >&2
            return 1
    end
end

function _qemu_write_conf \
  --argument-names name vm_root arch qemu_bin disk efi_code efi_vars cpu smp mem uuid mac accel machine net_mode bridge_if
    set -l CONF (_qemu_conf_path $name)
    set -l now (date -u "+%Y-%m-%d %H:%M:%SZ")
    mkdir -p "$vm_root"
    begin
        echo "# Generated $now"
        echo "set -gx NAME \"$name\""
        echo "set -gx VM_ROOT \"$vm_root\""
        echo "set -gx ARCH \"$arch\""
        echo "set -gx _QEMU_BIN \"$qemu_bin\""
        echo "set -gx DISK \"$disk\""
        echo "set -gx EFI_CODE \"$efi_code\""
        echo "set -gx EFI_VARS \"$efi_vars\""
        echo "set -gx CPU \"$cpu\""
        echo "set -gx SMP \"$smp\""
        echo "set -gx MEM \"$mem\""
        echo "set -gx UUID \"$uuid\""
        echo "set -gx MAC \"$mac\""
        echo "set -gx ACCEL \"$accel\""
        echo "set -gx MACHINE \"$machine\""
        echo "set -gx NET_MODE \"$net_mode\""
        echo "set -gx BRIDGE_IF \"$bridge_if\""
        echo "set -gx HOSTFWD_SSH \"2222\""
        echo "set -gx HOSTFWD_MEYE \"8765\""
        # --- Display defaults ---
        echo "set -gx DISPLAY_MODE \"cocoa\""
        echo "set -gx SPICE_ADDR \"127.0.0.1\""
        echo "set -gx SPICE_PORT \"5930\""
        echo "set -gx SPICE_DISABLE_TICKETING \"on\""
        echo "set -gx SPICE_SOCK \"$vm_root/spice.sock\""
        # --- VNC defaults ---
        echo "set -gx VNC_HOST \"127.0.0.1\""
        echo "set -gx VNC_DISPLAY \"1\""
        echo "set -gx VNC_SOCK \"$vm_root/vnc.sock\""
    end > "$CONF"
    echo "Wrote $CONF"
end

# --- Public commands -----------------------------------------------------

# qemu_create <name> [--arch aarch64|x86_64] [--disk PATH|--disk-size 32G] [--cpu ...] [--smp N] [--mem MB]
#                    [--net-mode vmnet-bridged|vmnet-shared|user] [--bridge-if en0] [--mac XX:...]
#                    [--accel hvf|tcg] (defaults based on arch)
#                    [--display-mode cocoa|spice-tcp|spice-uds|vnc-tcp|vnc-uds] [...]
function qemu_create --description 'Create VM folder + vm.conf (and optional disk)'
    if test (count $argv) -lt 1
        echo "Usage: qemu_create <name> [--arch aarch64|x86_64] [--disk PATH | --disk-size 32G] [--cpu CPU] [--smp N] [--mem MB] [--net-mode vmnet-bridged|vmnet-shared|user] [--bridge-if en0] [--mac XX:XX:XX:XX:XX:XX] [--accel hvf|tcg] [--display-mode cocoa|spice-tcp|spice-uds|vnc-tcp|vnc-uds] [display params...]" >&2
        return 1
    end
    set -l NAME $argv[1]; set -e argv[1]

    # defaults
    set -l ARCH aarch64
    set -l CPU host
    set -l SMP 4
    set -l MEM 4096
    set -l NET_MODE vmnet-shared
    set -l BRIDGE_IF en0
    set -l DISK ''
    set -l DISK_SIZE ''
    set -l MAC ''
    set -l ACCEL ''          # will be chosen based on ARCH if left blank
    set -l DISPLAY_MODE cocoa
    set -l SPICE_ADDR 127.0.0.1
    set -l SPICE_PORT 5930
    set -l SPICE_DISABLE_TICKETING on
    set -l SPICE_SOCK ''
    set -l VNC_HOST 127.0.0.1
    set -l VNC_DISPLAY 1
    set -l VNC_SOCK ''

    argparse --max-args=0 \
        'arch=' \
        'disk=' 'disk-size=' 'cpu=' 'smp=' 'mem=' \
        'net-mode=' 'bridge-if=' 'mac=' 'accel=' \
        'display-mode=' \
        'spice-addr=' 'spice-port=' 'spice-disable-ticketing=' 'spice-sock=' \
        'vnc-host=' 'vnc-display=' 'vnc-sock=' \
        -- $argv; or return 1

    if set -q _flag_arch;        set ARCH $_flag_arch; end
    if set -q _flag_disk;        set DISK $_flag_disk; end
    if set -q _flag_disk_size;   set DISK_SIZE $_flag_disk_size; end
    if set -q _flag_cpu;         set CPU $_flag_cpu; end
    if set -q _flag_smp;         set SMP $_flag_smp; end
    if set -q _flag_mem;         set MEM $_flag_mem; end
    if set -q _flag_net_mode;    set NET_MODE $_flag_net_mode; end
    if set -q _flag_bridge_if;   set BRIDGE_IF $_flag_bridge_if; end
    if set -q _flag_mac;         set MAC $_flag_mac; end
    if set -q _flag_accel;       set ACCEL $_flag_accel; end

    if set -q _flag_display_mode;        set DISPLAY_MODE $_flag_display_mode; end
    if set -q _flag_spice_addr;          set SPICE_ADDR $_flag_spice_addr; end
    if set -q _flag_spice_port;          set SPICE_PORT $_flag_spice_port; end
    if set -q _flag_spice_disable_ticketing; set SPICE_DISABLE_TICKETING $_flag_spice_disable_ticketing; end
    if set -q _flag_spice_sock;          set SPICE_SOCK $_flag_spice_sock; end
    if set -q _flag_vnc_host;            set VNC_HOST $_flag_vnc_host; end
    if set -q _flag_vnc_display;         set VNC_DISPLAY $_flag_vnc_display; end
    if set -q _flag_vnc_sock;            set VNC_SOCK $_flag_vnc_sock; end

    # Normalize ARCH
    switch "$ARCH"
        case aarch64 x86_64
        case '*'
            echo "Unsupported --arch '$ARCH' (use aarch64 | x86_64)" >&2
            return 1
    end

    # Choose defaults based on arch if not provided
    if test -z "$ACCEL"
        if test "$ARCH" = "aarch64"
            set ACCEL hvf
        else
            # On Apple Silicon, x86_64 cannot use HVF; default to TCG
            set ACCEL tcg
        end
    end
    if test "$ARCH" = "x86_64" -a "$CPU" = "host"
        # On Apple Silicon, "host" CPU model for x86_64 doesn't make sense; pick a generic one
        set CPU qemu64
    end

    # Resolve QEMU binary + firmware for this arch
    set -l QEMU_BIN (_qemu_pick_bin $ARCH); or begin
        echo "Failed to pick QEMU binary for arch=$ARCH" >&2; return 1
    end
    if not test -x "$QEMU_BIN"
        echo "QEMU binary not found/executable: $QEMU_BIN" >&2; return 1
    end

    _qemu_locate_firmware $ARCH $QEMU_BIN; or return 1
    _qemu_require $_QEMU_EFI_CODE "Missing firmware code image"; or return 1
    _qemu_require $_QEMU_EFI_VARS_TPL "Missing firmware vars image"; or return 1

    # VM dir & disk
    set -l VM_ROOT (_qemu_vmroot $NAME); mkdir -p "$VM_ROOT"
    set -l CONF (_qemu_conf_path $NAME)

    set -l EFI_VARS "$VM_ROOT/efi_vars.fd"
    if not test -f "$EFI_VARS"; cp "$_QEMU_EFI_VARS_TPL" "$EFI_VARS"; end

    if test -z "$DISK"; set DISK "$VM_ROOT/disk.qcow2"; end
    if test -n "$DISK_SIZE"
        qemu-img create -f qcow2 "$DISK" "$DISK_SIZE"
    else if not test -f "$DISK"
        echo "No disk at $DISK (use --disk-size to create one)" >&2
    end

    set -l UUID_FILE "$VM_ROOT/uuid"
    if not test -f "$UUID_FILE"; uuidgen > "$UUID_FILE"; end
    set -l UUID (string trim < "$UUID_FILE")

    if test -z "$MAC"
        set MAC (printf "52:54:%02x:%02x:%02x:%02x" (random 0 255) (random 0 255) (random 0 255) (random 0 255))
    end

    # Machine type default per arch
    set -l MACHINE ""
    if test "$ARCH" = "aarch64"
        set MACHINE "virt,gic-version=3"
    else
        set MACHINE "q35"
    end

    _qemu_write_conf $NAME "$VM_ROOT" "$ARCH" "$QEMU_BIN" "$DISK" "$_QEMU_EFI_CODE" "$EFI_VARS" "$CPU" "$SMP" "$MEM" "$UUID" "$MAC" "$ACCEL" "$MACHINE" "$NET_MODE" "$BRIDGE_IF"; or return 1

    # Display extras
    if test -z "$SPICE_SOCK"; set SPICE_SOCK "$VM_ROOT/spice.sock"; end
    if test -z "$VNC_SOCK";   set VNC_SOCK   "$VM_ROOT/vnc.sock";   end

    if test "$DISPLAY_MODE" != "cocoa"
        echo "set -gx DISPLAY_MODE \"$DISPLAY_MODE\"" >> "$CONF"
    end
    switch "$DISPLAY_MODE"
        case spice-tcp
            printf "set -gx SPICE_ADDR \"%s\"\nset -gx SPICE_PORT \"%s\"\nset -gx SPICE_DISABLE_TICKETING \"%s\"\n" "$SPICE_ADDR" "$SPICE_PORT" "$SPICE_DISABLE_TICKETING" >> "$CONF"
        case spice-uds
            printf "set -gx SPICE_SOCK \"%s\"\nset -gx SPICE_DISABLE_TICKETING \"%s\"\n" "$SPICE_SOCK" "$SPICE_DISABLE_TICKETING" >> "$CONF"
        case vnc-tcp
            printf "set -gx VNC_HOST \"%s\"\nset -gx VNC_DISPLAY \"%s\"\n" "$VNC_HOST" "$VNC_DISPLAY" >> "$CONF"
        case vnc-uds
            printf "set -gx VNC_SOCK \"%s\"\n" "$VNC_SOCK" >> "$CONF"
    end

    echo "Created VM '$NAME'"
    echo "  Arch: $ARCH  Bin: $QEMU_BIN"
    echo "  Disk: $DISK"
    echo "  vCPUs: $SMP  Mem: $MEM MB  CPU: $CPU  Accel: $ACCEL  Machine: $MACHINE"
    echo "  Net: $NET_MODE (bridge-if: $BRIDGE_IF)"
    echo "  Display: $DISPLAY_MODE"
end

# qemu_initiate <name> --iso /path/to/arm64-or-x86_64.iso [--console serial|gui]
function qemu_initiate --description 'First boot with display + ISO installer (runs as root for vmnet)'
    if test (count $argv) -lt 1
        echo "Usage: qemu_initiate <name> --iso /path/to/installer.iso [--console serial|gui]" >&2; return 1
    end
    set -l NAME $argv[1]; set -e argv[1]
    argparse --max-args=0 'iso=' 'console=' -- $argv; or return 1
    if not set -q _flag_iso; echo "ERROR: --iso required" >&2; return 1; end
    set -l ISO $_flag_iso
    set -l CONSOLE "gui"; if set -q _flag_console; set CONSOLE $_flag_console; end

    _qemu_source_conf $NAME; or return 1
    set -l NET_ARGS (_qemu_net_args $NET_MODE $BRIDGE_IF $MAC $HOSTFWD_MEYE $HOSTFWD_SSH); or return 1
    set -l DISP_ARGS (_qemu_display_args $NAME); or return 1

    set -l CONS_ARGS
    if test "$CONSOLE" = "serial"
        set CONS_ARGS "-nographic" "-serial" "mon:stdio"
        set -e DISP_ARGS
    end

    sudo $_QEMU_BIN \
        -accel "$ACCEL" \
        -machine "$MACHINE" \
        -cpu "$CPU" \
        -smp "cpus=$SMP,sockets=1,cores=$SMP,threads=1" \
        -m "$MEM" \
        -drive if=pflash,format=raw,unit=0,file="$EFI_CODE",readonly=on \
        -drive if=pflash,format=raw,unit=1,file="$EFI_VARS" \
        $DISP_ARGS \
        -device qemu-xhci,id=usb-bus \
        -device usb-kbd,bus=usb-bus.0 \
        -device usb-mouse,bus=usb-bus.0 \
        -device virtio-blk-pci,drive=sysdisk,serial="$UUID",bootindex=1 \
        -drive if=none,media=disk,id=sysdisk,file="$DISK",format=qcow2,discard=unmap,detect-zeroes=unmap \
        -drive if=none,media=cdrom,id=cd,file="$ISO",readonly=on \
        -device usb-storage,drive=cd,removable=true,bootindex=0,bus=usb-bus.0 \
        $NET_ARGS \
        $CONS_ARGS \
        -name "$NAME" \
        -uuid "$UUID"
end

# qemu_run <name>  (GUI; root for vmnet)
function qemu_run --description 'Normal boot with display (root for vmnet)'
    if test (count $argv) -ne 1
        echo "Usage: qemu_run <name>" >&2; return 1
    end
    set -l NAME $argv[1]
    _qemu_source_conf $NAME; or return 1
    set -l NET_ARGS (_qemu_net_args $NET_MODE $BRIDGE_IF $MAC $HOSTFWD_MEYE $HOSTFWD_SSH); or return 1
    set -l DISP_ARGS (_qemu_display_args $NAME); or return 1

    sudo $_QEMU_BIN \
        -accel "$ACCEL" \
        -machine "$MACHINE" \
        -cpu "$CPU" \
        -smp "cpus=$SMP,sockets=1,cores=$SMP,threads=1" \
        -m "$MEM" \
        -drive if=pflash,format=raw,unit=0,file="$EFI_CODE",readonly=on \
        -drive if=pflash,format=raw,unit=1,file="$EFI_VARS" \
        $DISP_ARGS \
        -device qemu-xhci,id=usb-bus \
        -device usb-kbd,bus=usb-bus.0 \
        -device usb-mouse,bus=usb-bus.0 \
        -device virtio-blk-pci,drive=sysdisk,serial="$UUID",bootindex=1 \
        -drive if=none,media=disk,id=sysdisk,file="$DISK",format=qcow2,discard=unmap,detect-zeroes=unmap \
        $NET_ARGS \
        -name "$NAME" \
        -uuid "$UUID"
end

# qemu_headless <name>  (daemonized; root for vmnet)
function qemu_headless --description 'Headless/daemonized boot (root for vmnet)'
    if test (count $argv) -ne 1
        echo "Usage: qemu_headless <name>" >&2; return 1
    end
    set -l NAME $argv[1]
    _qemu_source_conf $NAME; or return 1
    set -l NET_ARGS (_qemu_net_args $NET_MODE $BRIDGE_IF $MAC $HOSTFWD_MEYE $HOSTFWD_SSH); or return 1
    set -l DISP_ARGS (_qemu_display_args $NAME); or return 1

    set -l PIDFILE "$VM_ROOT/vm.pid"
    set -l LOGFILE "$VM_ROOT/qemu.log"
    set -l STDOUT "$VM_ROOT/stdout.log"
    set -l STDERR "$VM_ROOT/stderr.log"
    mkdir -p "$VM_ROOT"

    switch "$DISPLAY_MODE"
        case spice-tcp spice-uds vnc-tcp vnc-uds
            sudo $_QEMU_BIN \
                -accel "$ACCEL" \
                -machine "$MACHINE" \
                -cpu "$CPU" \
                -smp "cpus=$SMP,sockets=1,cores=$SMP,threads=1" \
                -m "$MEM" \
                -drive if=pflash,format=raw,unit=0,file="$EFI_CODE",readonly=on \
                -drive if=pflash,format=raw,unit=1,file="$EFI_VARS" \
                $DISP_ARGS \
                -device virtio-blk-pci,drive=sysdisk,serial="$UUID",bootindex=1 \
                -drive if=none,media=disk,id=sysdisk,file="$DISK",format=qcow2,discard=unmap,detect-zeroes=unmap \
                $NET_ARGS \
                -daemonize \
                -pidfile "$PIDFILE" \
                -D "$LOGFILE" \
                -name "$NAME" \
                -uuid "$UUID" \
                1>>"$STDOUT" 2>>"$STDERR"
        case '*'
            sudo $_QEMU_BIN \
                -accel "$ACCEL" \
                -machine "$MACHINE" \
                -cpu "$CPU" \
                -smp "cpus=$SMP,sockets=1,cores=$SMP,threads=1" \
                -m "$MEM" \
                -drive if=pflash,format=raw,unit=0,file="$EFI_CODE",readonly=on \
                -drive if=pflash,format=raw,unit=1,file="$EFI_VARS" \
                -device virtio-blk-pci,drive=sysdisk,serial="$UUID",bootindex=1 \
                -drive if=none,media=disk,id=sysdisk,file="$DISK",format=qcow2,discard=unmap,detect-zeroes=unmap \
                $NET_ARGS \
                -display none \
                -nographic \
                -daemonize \
                -pidfile "$PIDFILE" \
                -D "$LOGFILE" \
                -name "$NAME" \
                -uuid "$UUID" \
                1>>"$STDOUT" 2>>"$STDERR"
    end

    echo "Started headless. PID: "(cat "$PIDFILE")"  Logs: $LOGFILE"
end

# qemu_stop <name>  (stops headless VM)
function qemu_stop --description 'Stop headless VM'
    if test (count $argv) -ne 1
        echo "Usage: qemu_stop <name>" >&2; return 1
    end
    set -l NAME $argv[1]
    set -l VM_ROOT (_qemu_vmroot $NAME)
    set -l PIDFILE "$VM_ROOT/vm.pid"
    if test -f "$PIDFILE"
        set -l pid (string trim < "$PIDFILE")
        if test -n "$pid"
            sudo kill $pid 2>/dev/null
        end
        rm -f "$PIDFILE"
        echo "Stopped QEMU for $NAME"
    else
        echo "No pidfile at $PIDFILE"
    end
end

# qemu_set_display <name> <cocoa|spice-tcp|spice-uds|vnc-tcp|vnc-uds> [...]
function qemu_set_display --description 'Switch display mode + params in vm.conf'
    if test (count $argv) -lt 2
        echo "Usage: qemu_set_display <name> <cocoa|spice-tcp|spice-uds|vnc-tcp|vnc-uds> [--spice-addr 127.0.0.1] [--spice-port 5930] [--spice-disable-ticketing on|off] [--spice-sock /path.sock] [--vnc-host 127.0.0.1] [--vnc-display 1] [--vnc-sock /path.sock]" >&2
        return 1
    end
    set -l NAME $argv[1]
    set -l MODE $argv[2]
    set -e argv[1..2]

    argparse --max-args=0 \
        'spice-addr=' 'spice-port=' 'spice-disable-ticketing=' 'spice-sock=' \
        'vnc-host=' 'vnc-display=' 'vnc-sock=' \
        -- $argv; or return 1

    set -l CONF "$HOME/vms/$NAME/vm.conf"
    if not test -f "$CONF"
        echo "Config not found for '$NAME': $CONF" >&2
        return 1
    end

    function __conf_set --argument-names file var val
        if grep -q "^\s*set -gx $var " $file
            sed -i '' -E "s|^\s*set -gx $var \".*\"|set -gx $var \"$val\"|" $file
        else
            echo "set -gx $var \"$val\"" >> $file
        end
    end

    switch "$MODE"
        case cocoa spice-tcp spice-uds vnc-tcp vnc-uds
        case '*'
            echo "Unsupported display mode: $MODE (use cocoa | spice-tcp | spice-uds | vnc-tcp | vnc-uds)" >&2
            return 1
    end

    function _qemu_supports_spice
        set -l out ($_QEMU_BIN -help 2>&1)
        if string match -q '*-spice*' -- $out
            return 0
        end
        return 1
    end
    if string match -q 'spice-*' -- "$MODE"
        if not _qemu_supports_spice
            echo "Warning: Current QEMU ($_QEMU_BIN) lacks -spice support. Use vnc-tcp/vnc-uds or install a SPICE-enabled build." >&2
        end
    end

    __conf_set $CONF DISPLAY_MODE $MODE

    set -l VM_ROOT (dirname $CONF)
    set -l DEFAULT_SPICE_SOCK "$VM_ROOT/spice.sock"
    set -l DEFAULT_VNC_SOCK   "$VM_ROOT/vnc.sock"

    switch "$MODE"
        case spice-tcp
            set -l SA "127.0.0.1";  if set -q _flag_spice_addr; set SA $_flag_spice_addr; end
            set -l SP "5930";        if set -q _flag_spice_port; set SP $_flag_spice_port; end
            set -l SDT "on";         if set -q _flag_spice_disable_ticketing; set SDT $_flag_spice_disable_ticketing; end
            __conf_set $CONF SPICE_ADDR $SA
            __conf_set $CONF SPICE_PORT $SP
            __conf_set $CONF SPICE_DISABLE_TICKETING $SDT
        case spice-uds
            set -l SS $DEFAULT_SPICE_SOCK; if set -q _flag_spice_sock; set SS $_flag_spice_sock; end
            set -l SDT "on";               if set -q _flag_spice_disable_ticketing; set SDT $_flag_spice_disable_ticketing; end
            __conf_set $CONF SPICE_SOCK $SS
            __conf_set $CONF SPICE_DISABLE_TICKETING $SDT
        case vnc-tcp
            set -l VH "127.0.0.1"; if set -q _flag_vnc_host; set VH $_flag_vnc_host; end
            set -l VD "1";          if set -q _flag_vnc_display; set VD $_flag_vnc_display; end
            __conf_set $CONF VNC_HOST $VH
            __conf_set $CONF VNC_DISPLAY $VD
        case vnc-uds
            set -l VS $DEFAULT_VNC_SOCK; if set -q _flag_vnc_sock; set VS $_flag_vnc_sock; end
            __conf_set $CONF VNC_SOCK $VS
    end

    echo "Updated $CONF"
    echo "  Display: $MODE"
end
