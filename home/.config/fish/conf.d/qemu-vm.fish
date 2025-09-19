# qemu-vm (root QEMU variant; simple vmnet)
# Requires: brew install qemu
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
    end > "$CONF"
    echo "Wrote $CONF"
end

# --- Public commands -----------------------------------------------------

# qemu_create <name> [--disk PATH|--disk-size 32G] [--cpu host|cortex-a72] [--smp N] [--mem MB]
#                    [--net-mode vmnet-bridged|vmnet-shared|user] [--bridge-if en0] [--mac XX:...]
function qemu_create --description 'Create VM folder + vm.conf (and optional disk)'
    if test (count $argv) -lt 1
        echo "Usage: qemu_create <name> [--disk PATH | --disk-size 32G] [--cpu host|cortex-a72] [--smp N] [--mem MB] [--net-mode vmnet-bridged|vmnet-shared|user] [--bridge-if en0] [--mac XX:XX:XX:XX:XX:XX]" >&2
        return 1
    end
    set -l NAME $argv[1]; set -e argv[1]

    set -l CPU host
    set -l SMP 4
    set -l MEM 4096
    set -l NET_MODE vmnet-shared
    set -l BRIDGE_IF en0
    set -l DISK ''
    set -l DISK_SIZE ''
    set -l MAC ''

    argparse --max-args=0 'disk=' 'disk-size=' 'cpu=' 'smp=' 'mem=' 'net-mode=' 'bridge-if=' 'mac=' -- $argv; or return 1
    if set -q _flag_disk;        set DISK $_flag_disk; end
    if set -q _flag_disk_size;   set DISK_SIZE $_flag_disk_size; end
    if set -q _flag_cpu;         set CPU $_flag_cpu; end
    if set -q _flag_smp;         set SMP $_flag_smp; end
    if set -q _flag_mem;         set MEM $_flag_mem; end
    if set -q _flag_net_mode;    set NET_MODE $_flag_net_mode; end
    if set -q _flag_bridge_if;   set BRIDGE_IF $_flag_bridge_if; end
    if set -q _flag_mac;         set MAC $_flag_mac; end

    _qemu_require $_QEMU_BIN "Missing qemu binary"; or return 1
    _qemu_require $_QEMU_EFI_CODE "Missing firmware"; or return 1
    _qemu_require $_QEMU_EFI_VARS_TPL "Missing firmware"; or return 1

    set -l VM_ROOT (_qemu_vmroot $NAME); mkdir -p "$VM_ROOT"

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

    echo "Created VM '$NAME'"
    echo "  Disk: $DISK"
    echo "  vCPUs: $SMP  Mem: $MEM MB  CPU: $CPU"
    echo "  Net: $NET_MODE (bridge-if: $BRIDGE_IF)"
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

    sudo $_QEMU_BIN \
        -accel "$ACCEL" \
        -machine "$MACHINE" \
        -cpu "$CPU" \
        -smp "cpus=$SMP,sockets=1,cores=$SMP,threads=1" \
        -m "$MEM" \
        -drive if=pflash,format=raw,unit=0,file="$EFI_CODE",readonly=on \
        -drive if=pflash,format=raw,unit=1,file="$EFI_VARS" \
        -vga none \
        -device virtio-gpu-pci \
        -display cocoa \
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

    sudo $_QEMU_BIN \
        -accel "$ACCEL" \
        -machine "$MACHINE" \
        -cpu "$CPU" \
        -smp "cpus=$SMP,sockets=1,cores=$SMP,threads=1" \
        -m "$MEM" \
        -drive if=pflash,format=raw,unit=0,file="$EFI_CODE",readonly=on \
        -drive if=pflash,format=raw,unit=1,file="$EFI_VARS" \
        -device virtio-gpu-pci \
        -display cocoa \
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

    set -l PIDFILE "$VM_ROOT/vm.pid"
    set -l LOGFILE "$VM_ROOT/qemu.log"
    set -l STDOUT "$VM_ROOT/stdout.log"
    set -l STDERR "$VM_ROOT/stderr.log"
    mkdir -p "$VM_ROOT"

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
            sudo kill $pid ^/dev/null
        end
        rm -f "$PIDFILE"
        echo "Stopped QEMU for $NAME"
    else
        echo "No pidfile at $PIDFILE"
    end
end
