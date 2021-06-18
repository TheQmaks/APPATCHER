@ECHO OFF
TITLE Android application patcher for Charles debugging
COLOR 02
ECHO     ___    ____  ____  ___  ______________  ________ ___
ECHO    /   ^|  / __ \/ __ \/   ^|/_  __/ ____/ / / / ____/ __ \
ECHO   / /^| ^| / /_/ / /_/ / /^| ^| / / / /   / /_/ / __/ / /_/ /
ECHO  / ___ ^|/ ____/ ____/ ___ ^|/ / / /___/ __  / /___/ _, _/
ECHO /_/  ^|_/_/   /_/   /_/  ^|_/_/  \____/_/ /_/_____/_/ ^|_^|
CD /d %~dp0
IF EXIST application RMDIR /S /Q application
START "Unpacking application" /WAIT java -jar resources/apktool_2.5.0.jar d -f %1 -o application
START /WAIT resources/xml edit --inplace --append "/manifest/application" --type attr -n "android:networkSecurityConfig" -v "@xml/network_security_config" application/AndroidManifest.xml
START /WAIT resources/xml edit --inplace --append "/manifest/application" --type attr -n "android:debuggable" -v "true" application/AndroidManifest.xml
COPY resources\network_security_config.xml application\res\xml >NUL
START "Packing application" /WAIT java -jar resources/apktool_2.5.0.jar b application
SET "RESULT=%~dpn1-PATCHED.apk"
START "Signing application" /WAIT java -jar resources/signapk.jar resources/certificate.pem resources/key.pk8 application/dist/app.apk %RESULT%
RMDIR /S /Q application