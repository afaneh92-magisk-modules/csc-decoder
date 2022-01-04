SKIPUNZIP=1

# Extract files
ui_print "- Extracting module files"
unzip -o "$ZIPFILE" module.prop omc-decoder.jar service.sh -d $MODPATH >&2

# Functions
run_jar() {
    local dalvikvm file main 
    #Inspired in the osm0sis method
    if dalvikvm -showversion >/dev/null; then
       dalvikvm=dalvikvm
    elif /system/bin/dalvikvm -showversion >/dev/null; then 
       dalvikvm=/system/bin/dalvikvm
    else
       echo "CANT LOAD DALVIKVM " && return
    fi
    file="$1"
    unzip -o "$file" "META-INF/MANIFEST.MF" -p > "/data/main.tmp"
    main=$(cat /data/main.tmp | grep -m1 "^Main-Class:" | cut -f2 -d: | tr -d " " | dos2unix)
    rm -f /data/main.tmp
    if [ -z "$main" ]; then
       echo "Cant get main: $file " && return
    fi
    shift 1
    $dalvikvm -Djava.io.tmpdir=. -Xnodex2oat -Xnoimage-dex2oat -cp "$file" $main "$@" 2>/dev/null \ || $dalvikvm -Djava.io.tmpdir=. -Xnoimage-dex2oat -cp "$file" $main "$@"
}

# Paths
omc_root=`getprop persist.sys.omc_root`
omc_path=`getprop persist.sys.omc_path`
omc_root_basename="$(basename "$omc_root")"
omc_root_path="${omc_path%/$omc_root_basename*}/$omc_root_basename"
omc_parent_path="${omc_path%/$omc_root_basename*}"
original_files=`find $omc_root_path -type f -name '*.xml'`

# Your script starts here
ui_print "- copy omc files"
mkdir -p $MODPATH/$omc_parent_path
cp -aR $omc_root_path $MODPATH/$omc_parent_path
ui_print "- Start decodeing..."
for i in $original_files; do
  if `run_jar "$MODPATH/omc-decoder.jar" -i $MODPATH/$i -o $MODPATH/$i` ; then
    ui_print "- Not decoded $i!"
  else
    ui_print "- Successfully decoded $i!"
  fi
done

# Set executable permissions
set_perm_recursive "$MODPATH" 0 0 0755 0644

# Clean up files
rm -rf $MODPATH/omc-decoder.jar
