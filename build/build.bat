@echo off

setlocal
set GLUE_TEMP_DIR=%~dp0
set GLUE_BUILD_DIR=%GLUE_TEMP_DIR:~0,-1%
pushd %GLUE_BUILD_DIR%

set GLUE_FAILURE=false

if "%2" == "" goto usage

if /i %1 == 2015 goto setvars2015
if /i %1 == 2017 goto setvars2017
goto usage

:setvars2015
call "%ProgramFiles(x86)%\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64
set GENERATOR="Visual Studio 14 2015 Win64"
set GLUE_COMPILER_VERSION=vc14
goto :setConfiguration

:setvars2017
call "%ProgramFiles(x86)%\Microsoft Visual Studio 15.0\VC\vcvarsall.bat" amd64
set GENERATOR="Visual Studio 15 2017 Win64"
set GLUE_COMPILER_VERSION=vc15
goto :setConfiguration

:setConfiguration
if /i %2 == all            goto configDebugRelease
if /i %2 == debug          goto configDebug
if /i %2 == release        goto configRelease
if /i %2 == relwithdebinfo goto configRelWithDebInfo
if /i %2 == minsizerel     goto configMinSizeRel
goto usage

:configDebug
set CONFIGURATION=Debug
goto setScope

:configRelease
set CONFIGURATION=Release
goto setScope

:configRelWithDebInfo
set CONFIGURATION=RelWithDebInfo
goto setScope

:configMinSizeRel
set CONFIGURATION=MinSizeRel
goto setScope

:configDebugRelease
call %0 %1 Debug %3
if ERRORLEVEL 1 goto failure
call %0 %1 RelWithDebInfo %3
if ERRORLEVEL 1 goto failure
goto resetEnvironment

:setScope
set BUILD_NOWIDE=false
set BUILD_EIGEN=false
set BUILD_CEREAL=false
set BUILD_OPENMVG=false

if "%3"  == ""        goto scopeFull
if /i %3 == full      goto scopeFull
if /i %3 == nowide    goto scopeNowide
if /i %3 == eigen     goto scopeEigen
if /i %3 == cereal    goto scopeCereal
if /i %3 == openmvg   goto scopeOpenmvg
goto usage

:scopeFull
set BUILD_NOWIDE=true
set BUILD_EIGEN=true
set BUILD_CEREAL=true
set BUILD_OPENMVG=true
goto startBuild

:scopeNowide
set BUILD_NOWIDE=true
goto startBuild

:scopeEigen
set BUILD_EIGEN=true
goto startBuild

:scopeCereal
set BUILD_CEREAL=true
goto startBuild

:scopeOpenmvg
set BUILD_OPENMVG=true
goto startBuild

:startBuild

if %BUILD_NOWIDE% == false goto noNowide

mkdir nowide_%CONFIGURATION%
cd nowide_%CONFIGURATION%
cmake -G %GENERATOR% -D GLUE_DEPLOY_DIR=deploy_%CONFIGURATION% -C ..\..\src\thirdparty\nowide_CMakeDefines.txt ..\..\src\thirdparty\nowide
if ERRORLEVEL 1 goto failure
cmake --build . --target install --config %CONFIGURATION%
if ERRORLEVEL 1 goto failure
cd ..

:noNowide

if %BUILD_EIGEN% == false goto noEigen

mkdir eigen_%CONFIGURATION%
cd eigen_%CONFIGURATION%
cmake -G %GENERATOR% -D GLUE_DEPLOY_DIR=deploy_%CONFIGURATION% -C ..\..\src\thirdparty\eigen_CMakeDefines.txt ..\..\src\thirdparty\eigen
if ERRORLEVEL 1 goto failure
cmake --build . --target install --config %CONFIGURATION%
if ERRORLEVEL 1 goto failure
cd ..

:noEigen

if %BUILD_CEREAL% == false goto noCereal

mkdir cereal_%CONFIGURATION%
cd cereal_%CONFIGURATION%
cmake -G %GENERATOR% -D GLUE_DEPLOY_DIR=deploy_%CONFIGURATION% ..\..\src\thirdparty\cereal
if ERRORLEVEL 1 goto failure
cmake --build . --target install --config %CONFIGURATION%
if ERRORLEVEL 1 goto failure
cd ..

:noCereal

if %BUILD_OPENMVG% == false goto noOpenmvg

mkdir openmvg_%CONFIGURATION%
cd openmvg_%CONFIGURATION%
cmake -G %GENERATOR% -D GLUE_DEPLOY_DIR=deploy_%CONFIGURATION% -C ..\..\src\thirdparty\openmvg_CMakeDefines.txt ..\..\src\thirdparty\openmvg\src
if ERRORLEVEL 1 goto failure
cmake --build . --target install --config %CONFIGURATION%
if ERRORLEVEL 1 goto failure
cd ..

:noOpenmvg

goto resetEnvironment

:usage
echo.
echo Usage: %0 VisualStudioVersion Configuration [Scope]
echo.
echo VisualStudioVersion can be one of
echo - 2015
echo - 2017
echo NOTE: The reference version is VS 2015.
echo NOTE: VS 2017 is experimental and currently untested.
echo NOTE: If the Visual Studio version changes, the files generated in the subdirectories of the build directory
echo       have to be removed.
echo.
echo Configuration can be one of
echo - All (corresponds to both Debug and RelWithDebInfo)
echo - Debug
echo - Release
echo - RelWithDebInfo
echo - MinSizeRel
echo NOTE: If Configuration changes between Release, RelWithDebInfo and MinSizeRel, the files generated in the deploy
echo subdirectory should be removed.
echo.
echo Scope is optional (default is 'full') and can be
echo - nowide    : configure and build only the nowide third party package
echo - eigen     : configure and build only the Eigen third party package
echo - cereal    : configure and build only the cereal third party package
echo - openmvg   : configure and build only the OpenMVG third party package
echo - full      : configure and build all packages
echo.
goto failure

:failure
set GLUE_FAILURE=true
goto resetEnvironment

:resetEnvironment

popd

if %GLUE_FAILURE% == false goto :eof

rem Do NOT remove the exit statement, the build scripts rely on it!
exit /B 1
