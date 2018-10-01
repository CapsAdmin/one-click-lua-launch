::_::BATCH_PROGRAM=[[
@echo off
IF %0 == "%~0" set RAN_FROM_EXPLORER=1
set APP_NAME=appexample
set ARG_LINE=%*
set SCRIPT_PATH=%~dpnx0
set STORAGE_PATH=%appdata%\myluapp

:Start
SetLocal EnableDelayedExpansion
call:Main
goto:eof

:Main
SetLocal
	set ARCH=unknown
	set OS=windows

	(set | find "ProgramFiles(x86)" > NUL) && (echo "!ProgramFiles(x86)!" | find "x86") > NUL && set ARCH=x64|| set ARCH=x86

	set url=https://gitlab.com/CapsAdmin/goluwa-binaries-!OS!_!ARCH!/raw/master/
	set dir=!STORAGE_PATH!\!OS!_!ARCH!

	if not exist "!dir!" ( mkdir "!dir!" )

	if not exist "!dir!\lua_downloaded_and_validated" (
		call:DownloadFile "!url!lua51.dll" "!dir!\lua51.dll"
		call:DownloadFile "!url!vcruntime140.dll" "!dir!\vcruntime140.dll"
	)

	call:DownloadLua "!url!luajit.exe" "!dir!" "luajit.exe"

	IF RAN_FROM_EXPLORER equ 1 (
		start "" "!dir!\luajit.exe" "!SCRIPT_PATH!"
	) else (
		"!dir!\luajit.exe" "!SCRIPT_PATH!"
	)

	if !errorlevel! neq 0 (
		pause
	)

EndLocal
goto:eof

:DownloadLua
SetLocal
	set url=%~1
	set directory=%~2
	set filename=%~3
	set abs_path=%~2\%~3

	if not exist "!directory!\lua_downloaded_and_validated" (
		call:DownloadFile "!url!" "!abs_path!"

		!abs_path! -e "os.exit(1)"

		if !errorlevel! neq 1 (
			echo "exit code 'os.exit(1)' does not match 1"
			echo "removing !abs_path! in 5 seconds to try again"
			timeout 5
			del !abs_path!
			EndLocal
			goto Start
		)

		echo. 2>!directory!\lua_downloaded_and_validated
	)
EndLocal
goto:eof

:DownloadFile
SetLocal
	set url=%~1
	set output_path=%~2

	where curl
	if !errorlevel! equ 0 (
		curl -L --url "!url!" --output "!output_path!"
		goto:eof
	) else (
		where powershell
		if !errorlevel! equ 0 (
			PowerShell -NoLogo -NoProfile -NonInteractive "(New-Object System.Net.WebClient).DownloadFile('!url!','%~dp0!filename!')"
			goto:eof
		)
	)
	echo "unable to find curl or powershell"
	exit /b
EndLocal
goto:eof


rem ]]

function AlertBox(msg)
	msg = msg:gsub("\\", "/"):gsub("\n", "\\n")
	os.execute([[mshta javascript:alert("]]..msg..[[");close();]])
end

function main(storage_path, script_path, arg_line)
	arg_line = arg_line or ""

    local msg = " hello from lua!\n" ..
	" storage path: " .. storage_path .. "\n" ..
    " script path: " ..script_path .. "\n" ..
    " arg line:" .. arg_line

	if os.getenv("RAN_FROM_EXPLORER") == "1" then
		print("some console text")
		print("some console text")
		print("some console text")
		AlertBox(msg)
	else
		io.write(msg)
	end
end

if os.getenv("RAN_FROM_EXPLORER") == "1" then
	os.execute("cls")
end

main(
	os.getenv("STORAGE_PATH"):gsub("\\", "/") .. "/",
	os.getenv("SCRIPT_PATH"):gsub("\\", "/"),
	os.getenv("ARG_LINE") or ""
)