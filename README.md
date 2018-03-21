## App Systemizer (Terminal Emulator)
[More info and details in the XDA Thread](https://forum.xda-developers.com/apps/magisk/module-terminal-app-systemizer-ui-t3585851)

 Systemize your App systemlessly!
 Using terminal emulator.
 Enter this command and choose the app you want to systemize.

	systemize
	
 And Reboot to apply changes.

## Error?
 Send `/cache/terminal_systemizer-verbose.log` in the XDA thread. I'll examine it for problems and will try to fix it.

## Changelog

### v11.2.1
* Fixed updating through TWRP
### v11.2
* Systemized apps now persist when updating in Magisk Manager
### v11.1
* Fix xbin not getting deleted
* Add Spinner when loading apps
### v11
* Sorted alphabetically (finally)
* More efficient app detection (by default)
* Fixed package name option
* Cleaned some stuff
### v10.7
* Faster App detection (create `/cache/fast_systemize` to use this)
### v10.6.1
* Samsung detection (bin/xbin)
### v10.6
* Fixed App listing function again
* Faster app detection