@ECHO OFF
SET "ARGUMENTS=b application"

:RUN
java -jar resources\apktool_2.6.1.jar %ARGUMENTS% 2>>log.txt

FIND /c "invalid resource directory name" log.txt && (
	REM https://github.com/iBotPeaches/Apktool/issues/1978
	
	SET "ARGUMENTS=--use-aapt2 b application"
	
	DEL /F log.txt
	GOTO :RUN
)

FIND /c "attribute android:localeConfig not found" log.txt && (
	REM https://github.com/iBotPeaches/Apktool/issues/2756
	
	DEL /F application\res\xml\locales_config.xml
	START /WAIT resources\xml edit --inplace --delete "/resources/public[@name='locales_config']" application\res\values\public.xml
	START /WAIT resources\xml edit --inplace --delete "/manifest/application/@android:localeConfig" application\AndroidManifest.xml
	
	DEL /F log.txt
	GOTO :RUN
)

DEL /F log.txt