@ECHO OFF
TITLE Android application patcher for Charles debugging
COLOR 02
ECHO     ___    ____  ____  ___  ______________  ________ ___
ECHO    /   ^|  / __ \/ __ \/   ^|/_  __/ ____/ / / / ____/ __ \
ECHO   / /^| ^| / /_/ / /_/ / /^| ^| / / / /   / /_/ / __/ / /_/ /
ECHO  / ___ ^|/ ____/ ____/ ___ ^|/ / / /___/ __  / /___/ _, _/
ECHO /_/  ^|_/_/   /_/   /_/  ^|_/_/  \____/_/ /_/_____/_/ ^|_^|
CD /d %~dp0

if "%~1"=="" GOTO MISSING_FILE

IF EXIST application RMDIR /S /Q application
START "Unpacking application" /WAIT java -jar resources/apktool_2.6.1.jar d -f %1 -o application
START /WAIT resources\xml edit --inplace --delete "/manifest/application/@android:networkSecurityConfig" application\AndroidManifest.xml
START /WAIT resources\xml edit --inplace --delete "/manifest/application/@android:debuggable" application\AndroidManifest.xml
START /WAIT resources\xml edit --inplace --append "/manifest/application" --type attr -n "android:networkSecurityConfig" -v "@xml/network_security_config" application\AndroidManifest.xml
START /WAIT resources\xml edit --inplace --append "/manifest/application" --type attr -n "android:debuggable" -v "true" application\AndroidManifest.xml
COPY /Y resources\network_security_config.xml application\res\xml >NUL
START "Compiling application" /WAIT cmd /c compile.bat
SET "FILE=application/dist/%~nx1"
SET "RESULT=%~dpn1-PATCHED.apk"
START "Signing application" /WAIT java -jar resources\apksigner.jar sign --ks resources\.keystore --ks-pass pass:p@ssw0rd --in %FILE% --out %RESULT%
RMDIR /S /Q application
GOTO EOF

:MISSING_FILE
echo.
echo Drag and drop apk to patch.bat
echo.
PAUSE

:EOF