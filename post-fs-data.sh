#!/system/bin/sh
MODDIR=${0%/*}

mount --bind "$MODDIRomc_root_path" "omc_root_path"
