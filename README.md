## RsyncOSXsched

![](icon/menuapp.png)

The `menu app` is [released](https://github.com/rsyncOSX/RsyncOSX/releases) as release candidate together with RsyncOSX. This is probably the last release candidate before release in beginning of March.

This is the `menu app` (popover) for executing scheduled tasks in RsyncOSX. The idea is to add scheduled tasks in RsyncOSX, quit RsyncOSX and let the menu app take care of executing the scheduled tasks.

The `menu app` should be started from RsyncOSX. This require paths for both apps to be entered into userconfiguration.  The paths are used for activating the apps from either within RsyncOSX or RsyncOSXsched.
Adding paths for applications automatically enables, if both apps are found, executing scheduled apps in the `menu app`. To disable delete paths.

Only scheduled tasks from the selected profile is active. A flag in RsyncOSX indicates where the scheduled tasks is set to be executed. If both RsyncOSX and the menu app is active at the same time only one of them is allowed to executed scheduled tasks.
![](screenshots/sched0.png)
Both RsyncOSX and the `menu app` submit a notification when a scheduled tasks is completed. A scheduled task is either of type `once`, `daily` or `weekly`.

![](screenshots/notifications1.png)

Adding scheduled for tasks in RsyncOSX. After adding tasks either keep RsyncOSX running or select main menu and select the menuapp button. If you decide to let RsyncOSX execute the scheduled tasks remember to set the correct settings in user configuration.
![](screenshots/sched4.png)
Double click on row brings up details about schedules and logs for one task.
![](screenshots/sched1.png)
The green light in column `Schedule` indicates a scheduled tasks within next hour (green lights). Selecting the `Menuapp` in main view quits RsyncOSX and starts the menu application. The default profile is selected when it starts.
![](screenshots/sched2.png)
The status light is green indicates there are active tasks waiting for execution.
![](screenshots/sched5.png)

### Logging

There is a minimal logging in menu app. The log is not saved to disk, it lives only during lifetime of menu app. The menu app logs the major actions within the menu app.
![](screenshots/log1.png)
