## App Systemizer (Terminal Emulator)
[More info and details in the XDA Thread](https://forum.xda-developers.com/apps/magisk/module-terminal-app-systemizer-ui-t3585851)

 Systemize your App systemlessly!
 Using terminal emulator.
 Enter this command and choose the app you want to systemize.

	systemize
	
 And you will be presented with a list of installed apps.
 And Reboot to apply changes.

## Error?
 Go to the menu and type `logs`, this will upload the log files of this module and will generate a link. Send that :)
 Alternatively, Send `/cache/terminal_debloater-verbose.log` in the XDA thread. I'll examine it for problems and will try to fix it.

## Changelog

### v13.1
* Add -l option to list systemized apps
* Apps doesn't get refreshed if you go back to menu
* Add "Refresh list" option in app list menu
* Misc improvements
### v13
* Add -a option to directly systemize a given package name
* Add -d option to directly systemize a given apk
* Automatically disable ANSI codes (the colors) when in ADB shell
* Add help message
* Misc
### v12.2
* Fixed quirks when listing app names
### v12.1
* Fixed stuff related to busybox alias
### v12
* Add Back to menu option
* Logs can now be uploaded by entering `logs`
* Other listed menus now have multiple option.
* Misc improvements XD

