# qemu-vm (root QEMU variant; vmnet + optional SPICE/VNC)
# Requires: brew install qemu
# Optional viewers:
#   SPICE: brew install spice-gtk     # use `spicy`
#   VNC:   use macOS Screen Sharing or any VNC client
# Firmware from Homebrew QEMU:
#   /opt/homebrew/share/qemu/edk2-aarch64-code.fd
#   /opt/homebrew/share/qemu/edk2-arm-vars.fd

# --- Paths ---------------------------------------------------------------
if test -x "/Applications/UTM.app/Contents/Resources/qemu-system-aarch64"
    # You can keep using Homebrew; UTM's QEMU also works. Both need sudo for vmnet here.
    set -gx _QEMU_BIN "/Applications/UTM.app/Contents/Resources/qemu-system-aarch64"
else
    set -gx _QEMU_BIN "/opt/homebrew/bin/qemu-system-aarch64"
end
set -gx _QEMU_EFI_CODE     /opt/homebrew/share/qemu/edk2-aarch64-code.fd
set -gx _QEMU_EFI_VARS_TPL /opt/homebrew/share/qemu/edk2-arm-vars.fd

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

    # Always disable legacy VGA and use virtio GPU
    set -l base "-vga" "none" "-device" "virtio-gpu-pci"

    switch "$DISPLAY_MODE"
        case cocoa
            printf "%s\n" $base "-display" "cocoa"

        case spice-tcp
            # Connect: spicy -h $SPICE_ADDR -p $SPICE_PORT
            printf "%s\n" $base \
                "-spice" "addr=$SPICE_ADDR,port=$SPICE_PORT,disable-ticketing=$SPICE_DISABLE_TICKETING,gl=off,image-compression=off,playback-compression=off,streaming-video=off" \
                "-device" "virtio-serial" \
                "-chardev" "spicevmc,id=vdagent,name=vdagent" \
                "-device" "virtserialport,chardev=vdagent,name=com.redhat.spice.0"

        case spice-uds
            # Connect: spicy -h unix -p $SPICE_SOCK
            printf "%s\n" $base \
                "-spice" "unix=on,addr=$SPICE_SOCK,disable-ticketing=$SPICE_DISABLE_TICKETING,gl=off,image-compression=off,playback-compression=off,streaming-video=off" \
                "-device" "virtio-serial" \
                "-chardev" "spicevmc,id=vdagent,name=vdagent" \
                "-device" "virtserialport,chardev=vdagent,name=com.redhat.spice.0"

        case vnc-tcp
            # QEMU wants host:display (port = 5900 + display). Keep host as 127.0.0.1 for safety.
            printf "%s\n" $base "-vnc" "$VNC_HOST:$VNC_DISPLAY"

        case vnc-uds
            # VNC via Unix socket. macOS viewers often prefer TCP; UDS here for completeness.
            printf "%s\n" $base "-vnc" "unix:$VNC_SOCK"

        case '*'
            echo "Unsupported DISPLAY_MODE '$DISPLAY_MODE' (use cocoa | spice-tcp | spice-uds | vnc-tcp | vnc-uds)" >&2
            return 1
    end
end

function _qemu_write_conf \
    --argument-names name vm_root disk efi_code efi_vars cpu smp mem uuid mac accel machine net_mode bridge_if
    set -l CONF (_qemu_conf_path $name)
    set -l now (date -u "+%Y-%m-%d %H:%M:%SZ")
    mkdir -p "$vm_root"
    begin
        echo "# Generated $now"
        echo "set -gx NAME \"$name\""
        echo "set -gx VM_ROOT \"$vm_root\""
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
        echo "set -gx NET_MODE \"$net_mode\""   # vmnet-shared | vmnet-bridged | user
        echo "set -gx BRIDGE_IF \"$bridge_if\""
        echo "set -gx HOSTFWD_SSH \"2222\""     # only used in user mode
        echo "set -gx HOSTFWD_MEYE \"8765\""
        # --- Display defaults ---
        echo "set -gx DISPLAY_MODE \"cocoa\""          # cocoa | spice-tcp | spice-uds | vnc-tcp | vnc-uds
        echo "set -gx SPICE_ADDR \"127.0.0.1\""        # for spice-tcp
        echo "set -gx SPICE_PORT \"5930\""             # for spice-tcp
        echo "set -gx SPICE_DISABLE_TICKETING \"on\""  # on|off
        echo "set -gx SPICE_SOCK \"$vm_root/spice.sock\""  # for spice-uds
        # --- VNC defaults ---
        echo "set -gx VNC_HOST \"127.0.0.1\""          # for vnc-tcp
        echo "set -gx VNC_DISPLAY \"1\""               # :1 => TCP 5901
        echo "set -gx VNC_SOCK \"$vm_root/vnc.sock\""  # for vnc-uds
    end > "$CONF"
    echo "Wrote $CONF"
end

# --- Public commands -----------------------------------------------------

# qemu_create <name> [--disk PATH|--disk-size 32G] [--cpu host|cortex-a72] [--smp N] [--mem MB]
#                    [--net-mode vmnet-bridged|vmnet-shared|user] [--bridge-if en0] [--mac XX:...]
#                    [--display-mode cocoa|spice-tcp|spice-uds|vnc-tcp|vnc-uds]
#                    [--spice-addr 127.0.0.1] [--spice-port 5930] [--spice-disable-ticketing on|off] [--spice-sock /path/to.sock]
#                    [--vnc-host 127.0.0.1] [--vnc-display 1] [--vnc-sock /path/to.sock]
function qemu_create --description 'Create VM folder + vm.conf (and optional disk)'
    if test (count $argv) -lt 1
        echo "Usage: qemu_create <name> [--disk PATH | --disk-size 32G] [--cpu host|cortex-a72] [--smp N] [--mem MB] [--net-mode vmnet-bridged|vmnet-shared|user] [--bridge-if en0] [--mac XX:XX:XX:XX:XX:XX] [--display-mode cocoa|spice-tcp|spice-uds|vnc-tcp|vnc-uds] [--spice-addr 127.0.0.1] [--spice-port 5930] [--spice-disable-ticketing on|off] [--spice-sock /path/to.sock] [--vnc-host 127.0.0.1] [--vnc-display 1] [--vnc-sock /path/to.sock]" >&2
        return 1
    end
    set -l NAME $argv[1]; set -e argv[1]

    # defaults
    set -l CPU host
    set -l SMP 4
    set -l MEM 4096
    set -l NET_MODE vmnet-shared
    set -l BRIDGE_IF en0
    set -l DISK ''
    set -l DISK_SIZE ''
    set -l MAC ''

    # display defaults (match _qemu_write_conf)
    set -l DISPLAY_MODE cocoa
    set -l SPICE_ADDR 127.0.0.1
    set -l SPICE_PORT 5930
    set -l SPICE_DISABLE_TICKETING on
    set -l SPICE_SOCK ''
    set -l VNC_HOST 127.0.0.1
    set -l VNC_DISPLAY 1
    set -l VNC_SOCK ''

    argparse --max-args=0 \
        'disk=' 'disk-size=' 'cpu=' 'smp=' 'mem=' 'net-mode=' 'bridge-if=' 'mac=' \
        'display-mode=' \
        'spice-addr=' 'spice-port=' 'spice-disable-ticketing=' 'spice-sock=' \
        'vnc-host=' 'vnc-display=' 'vnc-sock=' \
        -- $argv; or return 1

    if set -q _flag_disk;        set DISK $_flag_disk; end
    if set -q _flag_disk_size;   set DISK_SIZE $_flag_disk_size; end
    if set -q _flag_cpu;         set CPU $_flag_cpu; end
    if set -q _flag_smp;         set SMP $_flag_smp; end
    if set -q _flag_mem;         set MEM $_flag_mem; end
    if set -q _flag_net_mode;    set NET_MODE $_flag_net_mode; end
    if set -q _flag_bridge_if;   set BRIDGE_IF $_flag_bridge_if; end
    if set -q _flag_mac;         set MAC $_flag_mac; end

    if set -q _flag_display_mode;        set DISPLAY_MODE $_flag_display_mode; end
    if set -q _flag_spice_addr;          set SPICE_ADDR $_flag_spice_addr; end
    if set -q _flag_spice_port;          set SPICE_PORT $_flag_spice_port; end
    if set -q _flag_spice_disable_ticketing; set SPICE_DISABLE_TICKETING $_flag_spice_disable_ticketing; end
    if set -q _flag_spice_sock;          set SPICE_SOCK $_flag_spice_sock; end
    if set -q _flag_vnc_host;            set VNC_HOST $_flag_vnc_host; end
    if set -q _flag_vnc_display;         set VNC_DISPLAY $_flag_vnc_display; end
    if set -q _flag_vnc_sock;            set VNC_SOCK $_flag_vnc_sock; end

    _qemu_require $_QEMU_BIN "Missing qemu binary"; or return 1
    _qemu_require $_QEMU_EFI_CODE "Missing firmware"; or return 1
    _qemu_require $_QEMU_EFI_VARS_TPL "Missing firmware"; or return 1

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

    set -l MACHINE "virt,gic-version=3"

    _qemu_write_conf $NAME "$VM_ROOT" "$DISK" "$_QEMU_EFI_CODE" "$EFI_VARS" "$CPU" "$SMP" "$MEM" "$UUID" "$MAC" "hvf" "$MACHINE" "$NET_MODE" "$BRIDGE_IF"; or return 1

    # Build default sockets if unset
    if test -z "$SPICE_SOCK"; set SPICE_SOCK "$VM_ROOT/spice.sock"; end
    if test -z "$VNC_SOCK";   set VNC_SOCK   "$VM_ROOT/vnc.sock";   end

    # Append display overrides (last assignment wins when sourcing vm.conf)
    if test "$DISPLAY_MODE" != "cocoa"
        echo "set -gx DISPLAY_MODE \"$DISPLAY_MODE\"" >> "$CONF"
    end
    if test "$DISPLAY_MODE" = "spice-tcp"
        echo "set -gx SPICE_ADDR \"$SPICE_ADDR\"" >> "$CONF"
        echo "set -gx SPICE_PORT \"$SPICE_PORT\"" >> "$CONF"
        echo "set -gx SPICE_DISABLE_TICKETING \"$SPICE_DISABLE_TICKETING\"" >> "$CONF"
    else if test "$DISPLAY_MODE" = "spice-uds"
        echo "set -gx SPICE_SOCK \"$SPICE_SOCK\"" >> "$CONF"
        echo "set -gx SPICE_DISABLE_TICKETING \"$SPICE_DISABLE_TICKETING\"" >> "$CONF"
    else if test "$DISPLAY_MODE" = "vnc-tcp"
        echo "set -gx VNC_HOST \"$VNC_HOST\"" >> "$CONF"
        echo "set -gx VNC_DISPLAY \"$VNC_DISPLAY\"" >> "$CONF"
    else if test "$DISPLAY_MODE" = "vnc-uds"
        echo "set -gx VNC_SOCK \"$VNC_SOCK\"" >> "$CONF"
    end

    echo "Created VM '$NAME'"
    echo "  Disk: $DISK"
    echo "  vCPUs: $SMP  Mem: $MEM MB  CPU: $CPU"
    echo "  Net: $NET_MODE (bridge-if: $BRIDGE_IF)"
    echo "  Display: $DISPLAY_MODE"
    if test "$DISPLAY_MODE" = "spice-tcp"
        echo "    Connect with: spicy -h $SPICE_ADDR -p $SPICE_PORT"
    else if test "$DISPLAY_MODE" = "spice-uds"
        echo "    Connect with: spicy -h unix -p $SPICE_SOCK"
    else if test "$DISPLAY_MODE" = "vnc-tcp"
        set -l _vnc_port (math 5900 + $VNC_DISPLAY)
        echo "    Connect with: open vnc://$VNC_HOST:$_vnc_port"
    else if test "$DISPLAY_MODE" = "vnc-uds"
        echo "    VNC UDS at: $VNC_SOCK (most mac clients prefer vnc-tcp)"
    end
end

# qemu_initiate <name> --iso /path/to/arm64.iso
function qemu_initiate --description 'First boot with display + ISO installer (runs as root for vmnet)'
    if test (count $argv) -lt 1
        echo "Usage: qemu_initiate <name> --iso /path/to/arm64.iso" >&2; return 1
    end
    set -l NAME $argv[1]; set -e argv[1]
    argparse --max-args=0 'iso=' -- $argv; or return 1
    if not set -q _flag_iso; echo "ERROR: --iso required" >&2; return 1; end
    set -l ISO $_flag_iso

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
        -drive if=none,media=cdrom,id=cd,file="$ISO",readonly=on \
        -device usb-storage,drive=cd,removable=true,bootindex=0,bus=usb-bus.0 \
        $NET_ARGS \
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

    # If DISPLAY_MODE is SPICE or VNC, keep the server alive (no -display none/-nographic).
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

# qemu_set_display <name> <cocoa|spice-tcp|spice-uds|vnc-tcp|vnc-uds> [--spice-addr 127.0.0.1] [--spice-port 5930] [--spice-disable-ticketing on|off] [--spice-sock /path.sock] [--vnc-host 127.0.0.1] [--vnc-display 1] [--vnc-sock /path.sock]
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

    # Helper to set or append a var in vm.conf
    function __conf_set --argument-names file var val
        if grep -q "^\s*set -gx $var " $file
            # in-place replace
            sed -i '' -E "s|^\s*set -gx $var \".*\"|set -gx $var \"$val\"|" $file
        else
            echo "set -gx $var \"$val\"" >> $file
        end
    end

    # Validate mode
    switch "$MODE"
        case cocoa spice-tcp spice-uds vnc-tcp vnc-uds
            # ok
        case '*'
            echo "Unsupported display mode: $MODE (use cocoa | spice-tcp | spice-uds | vnc-tcp | vnc-uds)" >&2
            return 1
    end

    # If picking SPICE, optionally check capability of current QEMU
    function _qemu_supports_spice
        set -l out ($_QEMU_BIN -help 2>&1)
        if string match -q '*-spice*' -- $out
            return 0
        end
        return 1
    end
    if string match -q 'spice-*' -- "$MODE"
        if not _qemu_supports_spice
            echo "Warning: Current QEMU ($_QEMU_BIN) lacks -spice support. Use vnc-tcp/vnc-uds or point _QEMU_BIN to a SPICE-enabled build." >&2
        end
    end

    # Ensure defaults exist (they’ll be overwritten below if flags provided)
    __conf_set $CONF DISPLAY_MODE $MODE

    # Compute sensible defaults based on VM folder if unset
    set -l VM_ROOT (dirname $CONF)
    set -l DEFAULT_SPICE_SOCK "$VM_ROOT/spice.sock"
    set -l DEFAULT_VNC_SOCK   "$VM_ROOT/vnc.sock"

    # Apply per-mode params / overrides
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

    # Echo a friendly hint
    echo "Updated $CONF"
    echo "  Display: $MODE"
    switch "$MODE"
        case spice-tcp
            set -l SA (string match -r 'set -gx SPICE_ADDR "(.*)"' (grep 'SPICE_ADDR' $CONF) | string replace -r '.*"([^"]+)".*' '$1')
            set -l SP (string match -r 'set -gx SPICE_PORT "(.*)"' (grep 'SPICE_PORT' $CONF) | string replace -r '.*"([^"]+)".*' '$1')
            echo "  Connect: spicy -h $SA -p $SP"

        case spice-uds
            set -l SS (string match -r 'set -gx SPICE_SOCK "(.*)"' (grep 'SPICE_SOCK' $CONF) | string replace -r '.*"([^"]+)".*' '$1')
            echo "  Connect: spicy -h unix -p $SS"

        case vnc-tcp
            set -l VH (string match -r 'set -gx VNC_HOST "(.*)"' (grep 'VNC_HOST' $CONF) | string replace -r '.*"([^"]+)".*' '$1')
            set -l VD (string match -r 'set -gx VNC_DISPLAY "(.*)"' (grep 'VNC_DISPLAY' $CONF) | string replace -r '.*"([^"]+)".*' '$1')
            set -l PORT (math 5900 + $VD)
            echo "  Connect: open vnc://$VH:$PORT"

        case vnc-uds
            set -l VS (string match -r 'set -gx VNC_SOCK "(.*)"' (grep 'VNC_SOCK' $CONF) | string replace -r '.*"([^"]+)".*' '$1')
            echo "  VNC socket: $VS (most mac clients prefer vnc-tcp)"
        case cocoa
            echo "  Cocoa window will open when you run qemu_run."
    end
end
