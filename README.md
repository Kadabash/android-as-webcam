# android-as-webcam

Connect your Android phone to a Linux computer with USB and use it as a webcam.<br>
Doesn't require root, or any software to be installed on the phone.
## Requirements

* Tested only on Debian 10 (x86_64), but should work on Ubuntu as well.

* Phone running Android 4.4 or higher.

## Installation

1. Install the virtual webcam driver, ADB, and ffmpeg: `sudo apt install v4l2loopback-dkms adb ffmpeg`<br>
   Reboot the system.
   
2. Clone this repo: `git clone https://github.com/Kadabash/android-as-webcam.git`

3. Adapt the video capture settings at the beginning `android-as-webcam.sh` to your needs.
   The defaults give a very low quality, but have been tested to be reliable.
   
## Running

1. Open the camera app on your phone, switch it to video mode, but don't record anything.
   We'll use the preview display as the source of our webcam feed.

2. Load the virtual webcam driver: `sudo modprobe v4l2loopback`. 
   This needs to be repeated after every reboot.
   Alternatively, you can add the module `v4l2loopback` to your `/etc/modules`.
   
3. On your phone, enable ADB in the Developer Settings and connect it to your PC using USB.
   
4. Connect via ADB: `adb devices` should show a device in the list.
  
5. Start the script: `bash android-as-webcam.sh`

6. Done! Test that the webcam works in your apps.

## Caveats

* The stream will be restarted automatically every 3 minutes. 
  This is a limitation of the built-in Android `screenrecord` command we're using.
  Check that your applications handle this restarting well by setting the `RECORD_TIME_SECS` 
  variable in the script to a low value.
  
* This has only been tested with a Galaxy S5 (G900F) until now.
  
* The phone screen must never turn off, or the connection will be lost.
  "Caffeine mode" in the quick settings on Android can be set to an infinite time, which keeps the screen on.
  
## Credits

This scriptlet was hacked together using lots of web resources, mainly on StackOverflow.
I came up with very little of it myself.
