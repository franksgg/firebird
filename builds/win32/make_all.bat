@echo off
set ERRLEV=0

:: Set env vars
@call setenvvar.bat %*

@if errorlevel 1 (call :ERROR Executing setenvvar.bat failed & goto :EOF)

:: verify that boot was run before

@if not exist %FB_BIN_DIR%\firebird.msg (echo %FB_BIN_DIR%\firebird.msg not found & goto :HELP_BOOT & goto :EOF)


::==========
:: MAIN

@echo Building %FB_OBJ_DIR%

@if "%FB_CLIENT_ONLY%"=="" (
	call compile.bat builds\win32\%VS_VER%\Firebird make_all_%FB_TARGET_PLATFORM%.log
) else (
	call compile.bat builds\win32\%VS_VER%\Firebird make_all_%FB_TARGET_PLATFORM%.log DLLs\yvalve DLLs\chacha
)
if errorlevel 1 call :ERROR build failed - see make_all_%FB_TARGET_PLATFORM%.log for details

@if "%ERRLEV%"=="1" (
  @goto :EOF
) else (
  @call :MOVE
)
@goto :EOF

::===========
:MOVE
@echo Cleaning output directory
@rmdir /S /Q "%FB_OUTPUT_DIR%" 2>nul

:: short delay to let OS complete actions by rmdir above
@timeout 1 >nul

@mkdir %FB_OUTPUT_DIR% 2>nul
@mkdir %FB_OUTPUT_DIR%\tzdata 2>nul
@mkdir %FB_OUTPUT_DIR%\include 2>nul
@mkdir %FB_OUTPUT_DIR%\include\firebird 2>nul
@mkdir %FB_OUTPUT_DIR%\include\firebird\impl 2>nul
@mkdir %FB_OUTPUT_DIR%\lib 2>nul
@mkdir %FB_OUTPUT_DIR%\system32 2>nul
@mkdir %FB_OUTPUT_DIR%\plugins 2>nul

@if "%FB_CLIENT_ONLY%"=="" (
	mkdir %FB_OUTPUT_DIR%\intl 2>nul
	mkdir %FB_OUTPUT_DIR%\doc 2>nul
	mkdir %FB_OUTPUT_DIR%\doc\sql.extensions 2>nul
	mkdir %FB_OUTPUT_DIR%\plugins\udr 2>nul
)

@copy %FB_ROOT_PATH%\temp\%FB_OBJ_DIR%\firebird\* %FB_OUTPUT_DIR% >nul
@copy %FB_ROOT_PATH%\temp\%FB_OBJ_DIR%\firebird\tzdata\* %FB_OUTPUT_DIR%\tzdata >nul
@copy %FB_ROOT_PATH%\temp\%FB_OBJ_DIR%\firebird\system32\* %FB_OUTPUT_DIR%\system32 >nul
@copy %FB_ROOT_PATH%\temp\%FB_OBJ_DIR%\firebird\plugins\*.dll %FB_OUTPUT_DIR%\plugins >nul
@copy %FB_ROOT_PATH%\temp\%FB_OBJ_DIR%\yvalve\fbclient.lib %FB_OUTPUT_DIR%\lib\fbclient_ms.lib >nul

@if "%FB_CLIENT_ONLY%"=="" (
	copy %FB_ROOT_PATH%\temp\%FB_OBJ_DIR%\firebird\intl\* %FB_OUTPUT_DIR%\intl >nul
	copy %FB_ROOT_PATH%\temp\%FB_OBJ_DIR%\firebird\plugins\udr\*.dll %FB_OUTPUT_DIR%\plugins\udr >nul
	copy %FB_ROOT_PATH%\temp\%FB_OBJ_DIR%\ib_util\ib_util.lib %FB_OUTPUT_DIR%\lib\ib_util_ms.lib >nul
)

for %%v in (gpre_boot build_msg common_test engine_test isql_test) do (
	@del %FB_OUTPUT_DIR%\%%v.* 2>nul
)

:: Firebird.conf, etc
@copy %FB_GEN_DIR%\firebird.msg %FB_OUTPUT_DIR%\ > nul
@copy %FB_ROOT_PATH%\builds\install\misc\firebird.conf %FB_OUTPUT_DIR%\firebird.conf >nul
@copy %FB_ROOT_PATH%\builds\install\misc\plugins.conf %FB_OUTPUT_DIR% >nul
@copy %FB_ROOT_PATH%\builds\install\misc\IPLicense.txt %FB_OUTPUT_DIR% >nul
@copy %FB_ROOT_PATH%\builds\install\misc\IDPLicense.txt %FB_OUTPUT_DIR% >nul

@if "%FB_CLIENT_ONLY%"=="" (
	copy %FB_ROOT_PATH%\builds\install\misc\databases.conf %FB_OUTPUT_DIR%\databases.conf >nul
	copy %FB_ROOT_PATH%\builds\install\misc\fbintl.conf %FB_OUTPUT_DIR%\intl\ >nul
	copy %FB_ROOT_PATH%\builds\install\misc\replication.conf %FB_OUTPUT_DIR% >nul
	copy %FB_ROOT_PATH%\src\utilities\ntrace\fbtrace.conf %FB_OUTPUT_DIR% >nul
	copy %FB_ROOT_PATH%\src\plugins\udr_engine\udr_engine.conf %FB_OUTPUT_DIR%\plugins\udr_engine.conf >nul

	:: DATABASES
	copy %FB_GEN_DIR%\dbs\security6.FDB %FB_OUTPUT_DIR%\security6.fdb >nul

	:: DOCS
	copy %FB_ROOT_PATH%\*.md %FB_OUTPUT_DIR%\doc\ >nul

	:: READMES
	copy %FB_ROOT_PATH%\doc\README.* %FB_OUTPUT_DIR%\doc >nul
	copy %FB_ROOT_PATH%\doc\sql.extensions\README.* %FB_OUTPUT_DIR%\doc\sql.extensions >nul
)

:: Headers
copy %FB_ROOT_PATH%\src\include\ibase.h %FB_OUTPUT_DIR%\include > nul
copy %FB_ROOT_PATH%\src\include\iberror.h %FB_OUTPUT_DIR%\include > nul
copy %FB_GEN_DIR%\iberror_c.h %FB_OUTPUT_DIR%\include\firebird\impl > nul

:: New API headers
xcopy /y %FB_ROOT_PATH%\src\include\firebird %FB_OUTPUT_DIR%\include\firebird /e > nul

@if "%FB_CLIENT_ONLY%"=="" (
	:: UDR
	copy %FB_ROOT_PATH%\src\extlib\*.sql %FB_OUTPUT_DIR%\plugins\udr > nul

	:: Installers
	copy %FB_INSTALL_SCRIPTS%\install_service.bat %FB_OUTPUT_DIR% >nul
	copy %FB_INSTALL_SCRIPTS%\uninstall_service.bat %FB_OUTPUT_DIR% >nul
)

:: MSVC runtime
copy "%VCToolsRedistDir%\%VSCMD_ARG_TGT_ARCH%\Microsoft.VC%MSVC_RUNTIME_LIBRARY_VERSION%.CRT\vcruntime140.dll" %FB_OUTPUT_DIR% > nul
if exist "%VCToolsRedistDir%\%VSCMD_ARG_TGT_ARCH%\Microsoft.VC%MSVC_RUNTIME_LIBRARY_VERSION%.CRT\vcruntime140_1.dll" (
	copy "%VCToolsRedistDir%\%VSCMD_ARG_TGT_ARCH%\Microsoft.VC%MSVC_RUNTIME_LIBRARY_VERSION%.CRT\vcruntime140_1.dll" %FB_OUTPUT_DIR% > nul
)
copy "%VCToolsRedistDir%\%VSCMD_ARG_TGT_ARCH%\Microsoft.VC%MSVC_RUNTIME_LIBRARY_VERSION%.CRT\msvcp140.dll" %FB_OUTPUT_DIR% > nul


@goto :EOF

::==============
:HELP_BOOT
@echo.
@echo    You must run make_boot.bat [Debug] before running this script
@echo.
@goto :EOF

:ERROR
::====
@echo.
@echo   An error occurred while running make_all.bat -
@echo     %*
@echo.
set ERRLEV=1
cancel_script > nul 2>&1
::End of ERROR
::------------
@goto :EOF
