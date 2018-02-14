##########################################################################################
#
# Magisk Module Template Config Script
# by topjohnwu
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure the settings in this file (config.sh)
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Configs
##########################################################################################

# Set to true if you need to enable Magic Mount
# Most mods would like it to be enabled
AUTOMOUNT=true

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Installation Message
##########################################################################################

# Set what you want to show when installing your mod

print_modname() {
  ui_print "*******************************"
  ui_print "      Terminal Debloater       "
  ui_print "  by veez21 @ xda-developers   "
  ui_print "*******************************"
}

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info about how Magic Mount works, and why you need this

# This is an example
REPLACE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here, it will override the example above
# !DO NOT! remove this if you don't need to replace anything, leave it empty as it is now
REPLACE="
"

##########################################################################################
# Permissions
##########################################################################################

set_permissions() {
  # Only some special files require specific permissions
  # The default permissions should be good enough for most cases

  # Here are some examples for the set_perm functions:

  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm_recursive  $MODPATH/system/lib       0       0       0755            0644

  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm  $MODPATH/system/bin/app_process32   0       2000    0755         u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0       2000    0755         u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0       0       0644

  # The following is default permissions, DO NOT remove
  set_perm_recursive  $MODPATH  0  0  0755  0644
  cp -af $INSTALLER/common/aapt $MODPATH/aapt
  bin=bin
  if (grep -q samsung /system/build.prop); then
    bin=xbin
	mkdir $MODPATH/system/$bin
	mv $MODPATH/system/bin/systemize $MODPATH/system/$bin
	rm -rf $MODPATH/system/bin
  fi
  set_perm $MODPATH/system/$bin/systemize 0 0 0777
  set_perm $MODPATH/aapt 0 0 0777
}

##########################################################################################
# Custom Functions
##########################################################################################

# This file (config.sh) will be sourced by the main flash script after util_functions.sh
# If you need custom logic, please add them here as functions, and call these functions in
# update-binary. Refrain from adding code directly into update-binary, as it will make it
# difficult for you to migrate your modules to newer template versions.
# Make update-binary as clean as possible, try to only do function calls in it.

detect_installed() {
  no_app=0
  no_privapp=0
  no_xml=0
  all_apk_size=0
  mkdir -p $TMPDIR/$MODID/system
  mkdir -p $TMPDIR/$MODID/system/app
  mkdir -p $TMPDIR/$MODID/system/priv-app
  mkdir -p $TMPDIR/$MODID/system/etc/permissions
  if [ -d $MODPATH/system/app ]; then
    for i in $(find $MODPATH/system/app -name *.apk -type f); do
	  if [ "$1" != "size" ]; then
        cp -af ${i%/*} $TMPDIR/$MODID/system/app
	  fi
	  all_apk_size=$((all_apk_size+$(du $i | awk '{print $1}')))
    done
  else
    no_app=1
  fi
  if [ -d $MODPATH/system/priv-app ]; then
    for i in $(find $MODPATH/system/priv-app -name *.apk -type f); do
	  if [ "$1" != "size" ]; then
        cp -af ${i%/*} $TMPDIR/$MODID/system/priv-app
	  fi
	  all_apk_size=$((all_apk_size+$(du $i | awk '{print $1}')))
    done
  else
    no_privapp=1
  fi
  if [ -d $MODPATH/system/etc/permissions ]; then
    for i in $(find $MODPATH/system/etc/permissions -name *.xml -type f); do
	  if [ "$1" != "size" ]; then
	    cp -af ${i%/*} $TMPDIR/$MODID/system/etc/permissions
      fi
	done
  else
    no_xml=1
  fi
  #reqSizeM=$((reqSizeM+all_apk_size))
}

reinstall() {
  if [ $no_app == 0 ]; then
    for i in $(find $TMPDIR/$MODID/system/app -name *.apk -type f); do
	  app=${i%/*}
      mkdir -p $MODPATH/system/app/${app##*/}
      cp -af $app/. $MODPATH/system/app/${app##*/}
    done
  fi
  if [ $no_privapp == 0 ]; then
    for i in $(find $TMPDIR/$MODID/system/priv-app -name *.apk -type f); do
	  app=${i%/*}
      mkdir -p $MODPATH/system/priv-app/${app##*/}
      cp -af $app/. $MODPATH/system/priv-app/${app##*/}
    done
  fi
  if [ $no_xml == 0 ]; then
	mkdir -p $MODPATH/system/etc/permissions
	cp -af $TMPDIR/$MODID/system/etc/permissions/* $MODPATH/system/etc/permissions
  fi
}
