# APPATCHER
Prepare your android application for network debugging many times faster than manually!

## USING
The use is actually very simple.
We need to drag the apk file of the target application to patch.bat and then the automatic processes of unpacking, changing values in configuration files, etc. will be started. The output file will be saved in the same directory as the original one with the PATCHED suffix (e.g. original.apk -> original_PATCHED.apk).

It is very important to mention the existence of the "certificate" directory, which will allow us to simplify the preparation process.
Usually, we change the application configurations, then set up a local proxy server, and the last step is to import the Charles or BurpSuite root certificate into the system. Unfortunately, sometimes there is no way to do this (e.g., AndroidTV or feature-limited emulators), so instead of importing the CA into the system - we can save it directly in the application resources. To do this, place the root certificate file (file extension .pem) in the "certificate" directory and follow the process described in the first paragraph.

In addition, these scripts contain a small amount of automatic fixes for possible bugs that I encountered during my researches. Sometimes it takes a lot of time, so I think it would be nice for everyone to have such a tool in his arsenal :)
## TOOLS
[xmlstarlet](http://xmlstar.sourceforge.net)

[apksigner](https://developer.android.com/studio/command-line/apksigner)

[zipalign](https://developer.android.com/studio/command-line/zipalign)

[apktool](https://ibotpeaches.github.io/Apktool)
