##########################################################################################
#
# Magisk
# by topjohnwu
# 
# This is a template zip for developers
#
##########################################################################################
##########################################################################################
# 
# Instructions:
# 
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure the settings in this file (common/config.sh)
# 4. For advanced features, add shell commands into the script files under common:
#    post-fs-data.sh, service.sh
# 5. For changing props, add your additional/modified props into common/system.prop
# 
##########################################################################################

##########################################################################################
# Defines
##########################################################################################

# NOTE: This part has to be adjusted to fit your own needs

# This will be the folder name under /magisk
# This should also be the same as the id in your module.prop to prevent confusion
MODID=terminal_systemizer

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
  ui_print "******************************"
  ui_print "   Terminal App Systemizer    "
  ui_print "  by veez21 @ xda-developers  "
  ui_print "******************************"
}

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# By default Magisk will merge your files with the original system
# Directories listed here however, will be directly mounted to the correspond directory in the system

# You don't need to remove the example below, these values will be overwritten by your own list
# This is an example
REPLACE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here, it will overwrite the example
# !DO NOT! remove this if you don't need to replace anything, leave it empty as it is now
REPLACE="
"

##########################################################################################
# Permissions
##########################################################################################

# NOTE: This part has to be adjusted to fit your own needs

set_permissions() {
  # Default permissions, don't remove them
  set_perm_recursive  $MODPATH  0  0  0755  0644

  # Only some special files require specific permissions
  # The default permissions should be good enough for most cases

  # Some templates if you have no idea what to do:

  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm_recursive  $MODPATH/system/lib       0       0       0755            0644

  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm  $MODPATH/system/bin/app_process32   0       2000    0755         u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0       2000    0755         u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0       0       0644
  set_perm $MODPATH/system/bin/systemize_magisk 0 0 0777
  set_perm $MODPATH/system/xbin/aapt 0 0 0777
}

detect_installed() {
  no_app=0
  no_privapp=0
  mkdir -p $TMPDIR/$MODID/system
  mkdir -p $TMPDIR/$MODID/system/app
  mkdir -p $TMPDIR/$MODID/system/priv-app
  if [ -d /magisk/$MODID/system/app ]; then
    for i in $(find /magisk/$MODID/system/app -name *.apk -type f); do
      cp -af ${i%/*} $TMPDIR/$MODID/system/app
    done
  else
    no_app=1
  fi
  if [ -d /magisk/$MODID/system/priv-app ]; then
    for i in $(find /magisk/$MODID/system/priv-app -name *.apk -type f); do
      cp -af ${i%/*} $TMPDIR/$MODID/system/priv-app
    done
  else
    no_privapp=1
  fi
}

reinstall() {
  if [ $no_app == 0 ]; then
    for i in $(find $TMPDIR/$MODID/system/app -name *.apk -type f); do
	  app=${i%/*}
      mkdir -p /magisk/$MODID/system/app/${app##*/}
      cp -af $app/. /magisk/$MODID/system/app/${app##*/}
    done
  fi
  if [ $no_privapp == 0 ]; then
    for i in $(find $TMPDIR/$MODID/system/priv-app -name *.apk -type f); do
	  app=${i%/*}
      mkdir -p /magisk/$MODID/system/priv-app/${app##*/}
      cp -af $app/. /magisk/$MODID/system/priv-app/${app##*/}
    done
  fi
}
