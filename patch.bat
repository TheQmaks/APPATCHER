@ECHO OFF
TITLE Android application patcher for network debugging
COLOR 02
ECHO     ___    ____  ____  ___  ______________  ________ ___
ECHO    /   ^|  / __ \/ __ \/   ^|/_  __/ ____/ / / / ____/ __ \
ECHO   / /^| ^| / /_/ / /_/ / /^| ^| / / / /   / /_/ / __/ / /_/ /
ECHO  / ___ ^|/ ____/ ____/ ___ ^|/ / / /___/ __  / /___/ _, _/
ECHO /_/  ^|_/_/   /_/   /_/  ^|_/_/  \____/_/ /_/_____/_/ ^|_^|

REM Set the location of the script to the current directory.
CD /d %~dp0

REM When dragging a file to the script, the full path including its name is taken as the first argument.
REM This check allows you to make sure that it runs correctly, rather than double-clicking.
REM If it is empty - move to the logical block of no file.
IF "%~1"=="" GOTO MISSING_FILE

REM Checks the existence of the temporary directory of the unpacked application in case the script didn't work correctly, and deletes it if it does.
IF EXIST application RMDIR /S /Q application

REM Decoding the application into a temporary directory "application" for subsequent work with its resources using apktool.
START "Decoding application" /WAIT java -jar resources/apktool_2.6.1.jar d -f %1 -o application

REM Removes attributes in the manifest, if they exist, to avoid duplication exception during building.
START /WAIT resources\xml edit --inplace --delete "/manifest/application/@android:networkSecurityConfig" application\AndroidManifest.xml
START /WAIT resources\xml edit --inplace --delete "/manifest/application/@android:debuggable" application\AndroidManifest.xml

REM Adds attributes to the manifest for network debugging
START /WAIT resources\xml edit --inplace --append "/manifest/application" --type attr -n "android:networkSecurityConfig" -v "@xml/network_security_config" application\AndroidManifest.xml
START /WAIT resources\xml edit --inplace --append "/manifest/application" --type attr -n "android:debuggable" -v "true" application\AndroidManifest.xml

REM Moves the prepared network security config to application xml resources directory
COPY /Y resources\network_security_config.xml application\res\xml >NUL

REM If a certificate exists in the "certificate" directory, copies it to the application raw resources folder and modifies the network security configuration to add a custom CA.
FOR %%f IN (.\certificate\*.pem) DO (
    COPY /Y %%f .\application\res\raw\cert.pem >NUL
    START /WAIT resources\xml edit --inplace --subnode "//trust-anchors" --type elem -n "certificates src=\"@raw/cert\"" -v "" application\res\xml\network_security_config.xml
)

REM Builds the modified application and fixes known bugs that may occur during the build process
START "Building application" /WAIT cmd /c build.bat

REM Performing the zipalign process
SET "FILE=application/dist/%~n1_aligned.apk"
START "Aligning apk" /WAIT resources\zipalign -p -f -v 4 application/dist/%~nx1 %FILE%

REM Signing the application with self-generated certificate
SET "RESULT=%~dpn1-PATCHED.apk"
START "Signing application" /WAIT java -jar resources\apksigner.jar sign --ks resources\.keystore --ks-pass pass:p@ssw0rd --in %FILE% --out %RESULT%

REM Removing the directory of an decoded application after building
RMDIR /S /Q application
GOTO EOF

REM Logic block of a non-existent input file
:MISSING_FILE
echo.
echo Drag and drop apk to patch.bat
echo.
PAUSE

:EOF