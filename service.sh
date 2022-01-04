#!/system/bin/sh
MODDIR=${0%/*}

omc_root=`getprop persist.sys.omc_root`
omc_path=`getprop persist.sys.omc_path`
omc_root_basename="$(basename "$omc_root")"
omc_root_path="${omc_path%/$omc_root_basename*}/$omc_root_basename"

mount --bind "$MODDIR/$omc_root_path" "$omc_root_path"
