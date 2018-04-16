@echo off

setlocal
set GLUE_TEMP_DIR=%~dp0
set GLUE_BUILD_DIR=%GLUE_TEMP_DIR:~0,-1%
pushd %GLUE_BUILD_DIR%

set GLUE_FAILURE=false
set SRC_D=..\deploy_Debug
set SRC_R=..\deploy_RelWithDebInfo
set DEST=..\packaging

rmdir /s /q %DEST%
mkdir %DEST%
mkdir %DEST%\doc
xcopy /E %SRC_R%\doc\html %DEST%\doc

mkdir %DEST%\etc
xcopy /E %SRC_R%\etc %DEST%\etc

mkdir %DEST%\include
xcopy /E %SRC_R%\include %DEST%\include

mkdir %DEST%\bin
mkdir %DEST%\bin\Debug
xcopy /E %SRC_D%\bin %DEST%\bin\Debug
xcopy /E %SRC_D%\x64\vc14\bin %DEST%\bin\Debug
mkdir %DEST%\bin\Release
xcopy /E %SRC_R%\bin %DEST%\bin\Release
xcopy /E %SRC_R%\x64\vc14\bin %DEST%\bin\Release

mkdir %DEST%\lib
mkdir %DEST%\lib\Debug
xcopy /E %SRC_D%\lib %DEST%\lib\Debug
xcopy /E %SRC_D%\x64\vc14\lib %DEST%\lib\Debug
xcopy /E %SRC_D%\x64\vc14\staticlib %DEST%\lib\Debug
mkdir %DEST%\lib\Release
xcopy /E %SRC_R%\lib %DEST%\lib\Release
xcopy /E %SRC_R%\x64\vc14\lib %DEST%\lib\Release
xcopy /E %SRC_R%\x64\vc14\staticlib %DEST%\lib\Release

move /Y %DEST%\lib\Debug\*.dll %DEST%\bin\Debug
move /Y %DEST%\lib\Release\*.dll %DEST%\bin\Release

goto resetEnvironment

:failure
set GLUE_FAILURE=true
goto resetEnvironment

:resetEnvironment
popd

if %GLUE_FAILURE% == false goto :eof

rem Do NOT remove the exit statement, the Bamboo build scripts rely on it!
exit /B 1
