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
  ui_print "   Terminal App Systemizer     "
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
  additional_size=0

  mkdir -p $TMPDIR/$MODID
  COPYPATH=$MODPATH
  $BOOTMODE && COPYPATH=/sbin/.core/img/$MODID

  if [ -d $COPYPATH/system/app ]; then
    cp -af $COPYPATH/system/app $TMPDIR/$MODID
	  additional_size=$((additional_size+$(du -ks $COPYPATH/system/app | awk '{print $1}')))
  else
    no_app=1
  fi

  if [ -d $COPYPATH/system/priv-app ]; then
    cp -af $COPYPATH/system/priv-app $TMPDIR/$MODID
	  additional_size=$((additional_size+$(du -ks $COPYPATH/system/priv-app | awk '{print $1}')))
  else
    no_privapp=1
  fi

  if [ -d $COPYPATH/system/etc/permissions ]; then
    cp -af $COPYPATH/system/etc/permissions $TMPDIR/$MODID
	  additional_size=$((additional_size+$(du -ks $COPYPATH/system/etc/permissions | awk '{print $1}')))
  else
    no_xml=1
  fi

  additional_size=$((additional_size / 1024 + 1))
  reqSizeM=$((reqSizeM+additional_size))
}

reinstall() {
  if [ $no_app == 0 ]; then
    cp -af $TMPDIR/$MODID/app $MODPATH/system
  fi
  if [ $no_privapp == 0 ]; then
    cp -af $TMPDIR/$MODID/priv-app $MODPATH/system
  fi
  if [ $no_xml == 0 ]; then
	  mkdir -p $MODPATH/system/etc
	  cp -af $TMPDIR/$MODID/permissions $MODPATH/system/etc
  fi
}
