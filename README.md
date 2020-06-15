## RsyncOSXsched

![](icon/menuapp.png)

This is the `menu app` (RsyncOSXsched.app) for executing scheduled tasks in RsyncOSX. Scheduled tasks are added in RsyncOSX. Quit RsyncOSX and let the menu app take care of executing the scheduled tasks. RsyncOSX does **not** execute scheduled tasks. Scheduled tasks are only added and deleted in RsyncOSX.

The `menu app` is started from RsyncOSX.


### Localization

[RsyncOSX speaks new languages](https://rsyncosx.netlify.app/post/localization/). RsyncOSXsched is localized to:
- German - by [Andre](https://github.com/andre68723)
- French - translated by [crowdin](https://crowdin.com/project/rsyncosx)
- Norwegian - by me
- English - by me and the base language of RsyncOSXsched
- Italian - by [Stefano Steve Cutelle'](https://github.com/stefanocutelle)
  - Italian localization is released in version 6.2.5 release candidate

### Screenshots

The menu app is a simple app with a few screens. The one and only task for the menu app is to execute scheduled RsyncOSX tasks. Every time a task is executed a notification is submitted.

If there are tasks waiting for executing the status light is green.

![](screenshots/menuapp1.png)

There is a minimal logging in the menu app. The menu app logs the major actions within the menu app.

![](screenshots/menuapp2.png)

Active scheduled tasks.

![](screenshots/menuapp3.png)

### Signing and notarizing

The app is signed with my Apple ID developer certificate and [notarized](https://support.apple.com/en-us/HT202491) by Apple. See [signing and notarizing](https://rsyncosx.netlify.app/post/notarized/) for info.

### SwiftLint and SwiftFormat

I am using [SwiftLint](https://github.com/realm/SwiftLint) as tool for writing more readable code. Another tool is [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) for formatting swift code.
