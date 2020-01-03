## RsyncOSXsched

![](icon/menuapp.png)

This is the `menu app` (RsyncOSXsched.app) for executing scheduled tasks in RsyncOSX. Scheduled tasks are added in RsyncOSX. Quit RsyncOSX and let the menu app take care of executing the scheduled tasks. RsyncOSX does **not** execute scheduled tasks. Scheduled tasks are only added and deleted in RsyncOSX.

The `menu app` can be started from RsyncOSX. This require paths for both apps to be entered into userconfiguration.  The paths are used for activating the apps from either within RsyncOSX or RsyncOSXsched.

![](screenshots/userconfig.png).

The `menu app` submit a notification when a scheduled tasks is completed. A scheduled task is either of type `once`, `daily` or `weekly`.

![](screenshots/notifications.png)

If there are tasks waiting for executing the status light is green.

![](screenshots/menuapp1.png)

There is a minimal logging in the menu app. The menu app logs the major actions within the menu app.

![](screenshots/menuapp2.png)

Active scheduled tasks.

![](screenshots/menuapp3.png)

### Signing and notarizing

The app is signed with my Apple ID developer certificate and [notarized](https://support.apple.com/en-us/HT202491) by Apple. See [signing and notarizing](https://rsyncosx.github.io/Notarized) for info.

### SwiftLint and SwiftFormat

I am using [SwiftLint](https://github.com/realm/SwiftLint) as tool for writing more readable code. I am also using Paul Taykalo´s [swift-scripts](https://github.com/PaulTaykalo/swift-scripts) to find and delete not used code. Another tool is [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) for formatting swift code.

### Compile

To compile the code, install Xcode and open the RsyncOSXsched project file. Before compiling, open in Xcode the `RsyncOSXsched/General` preference page (after opening the RsyncOSXsched project file) and replace your own credentials in `Signing`, or disable Signing.

There are two ways to compile, either utilize `make` or compile by Xcode. `make release` will compile the `RsyncOSXsched.app` and `make dmg` will make a dmg file to be released.  The build of dmg files are by utilizing [andreyvit](https://github.com/andreyvit/create-dmg) script for creating dmg and [syncthing-macos](https://github.com/syncthing/syncthing-macos) setup.
