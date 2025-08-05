#!/bin/bash
# IN DEVELOPMENT

mount_usb() {
    FS_TYPE=$(lsblk -no FSTYPE "$DEVNAME")
    MOUNT_POINT="/mnt/usb_$(basename "$DEVNAME")"
}


check_usb() {

}


main() {
    while true
    do
        if check_usb
        then
            mkdir -p "$MOUNT_POINT"
            sudo mount -o rw /dev/sda1 /mnt/usb
        fi
        sleep 3
    done
}
