# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=PNY Kernel installer by Chanz22
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=evert
device.name2=Evert
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables block a
# block=/dev/block/bootdevice/by-name/boot_a;
# is_slot_device=0;
# ramdisk_compression=auto;

# shell variables
block=/dev/block/bootdevice/by-name/boot_b;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;


## AnyKernel install
dump_boot;

# begin ramdisk changes

# Set Android version for kernel
ver="$(file_getprop /system/build.prop ro.build.version.release)"
if [ ! -z "$ver" ]; then
  patch_cmdline "androidboot.version" "androidboot.version=$ver"
else
  patch_cmdline "androidboot.version" ""
fi

# end ramdisk changes

write_boot;
## end install

