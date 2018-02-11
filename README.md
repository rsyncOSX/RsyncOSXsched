## RsyncOSXsched

**Important:** There are some issues regarding how to enter `daily` and `weekly` schedules in version 5.0.0 of RsyncOSX. The scheduled part is redesigned in the release candidate. To activate a schedule select start date and time and type of schedule. The schedules are active until *deleted* or *stopped*. Schedule `once` only executes once, `daily` and `weekly` until stopped or deleted.

Initial listing v0.0.1 of the `menu app`. It compiles and executes but still need some more testing before released. This is the menu app (popover) for executing scheduled tasks RsyncOSX. The idea is to add scheduled tasks in RsyncOSX, quit RsyncOSX and let the menu app take care of executing the scheduled tasks.

Only scheduled tasks from the selected profile is active. In the release candidate there is an option (default on) to execute scheduled tasks within the menu app only. **Do not** run both RsyncOSX and the menu app at the same time **utilizing the same profile** if this option is switched **off**. Any scheduled tasks will be executed at the same time in both apps and it will most likely cause problems. Default is execute scheduled tasks only in menu app.

The menu app can be started from RsyncOSX and RsyncOSX can be activated from the menu app. This require paths for both apps to be entered into userconfiguration (**without** a trailing `/`).  The paths are used for activating the apps from either within RsyncOSX or RsyncOSXsched. Toggle on/off if scheduled tasks in menu app only. Default is in menu app only.
![](screenshots/sched0.png)
Adding scheduled for tasks (in profile `Snapshots`) in RsyncOSX. After adding tasks either keep RsyncOSX running or select main menu and select the button `Menuapp`.
![](screenshots/sched1.png)
Double click on row brings up details about schedules and logs for one task.
![](screenshots/sched3.png)
The green and yellow lights in column `Schedule` indicates two scheduled tasks within next hour (green lights) and one more than one hour (yellow light).
![](screenshots/sched2.png)
Selecting the `Menuapp` in main view quits RsyncOSX and starts the menu application. The default profile is selected when it starts. There are no active schedules in the `default` profile. Selecting profile `Snapshots` (the menu app reads any profile created within RsyncOSX) activates any scheduled tasks in profile. Only scheduled tasks in selected profile is activated.
![](screenshots/sched4.png)
![](screenshots/sched5.png)
The status light is green indicating there is an active task waiting for execution.
![](screenshots/sched6.png)

### Logging

There is a minimal logging in menu app. The log is not saved to disk, it lives only during lifetime of menu app. The menu app logs the major actions within the menu app.
![](screenshots/log1.png)
![](screenshots/log2.png)
