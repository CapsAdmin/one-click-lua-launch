::_::BATCH_PROGRAM=[[
@echo off
SetLocal EnableDelayedExpansion

(set | find "ProgramFiles(x86)" > NUL) && (echo "!ProgramFiles(x86)!" | find "x86") > NUL && set ARCH=x64|| set ARCH=x86
set OS=windows
set APP_NAME=appexample
set ARG_LINE=%*
set STORAGE_PATH=data
set BINARY_DIR=!STORAGE_PATH!\!OS!_!ARCH!
set BINARY_NAME=luajit.exe
set BASE_URL=https://gitlab.com/CapsAdmin/goluwa-binaries-!OS!_!ARCH!/raw/master/

set SCRIPT_PATH=%~dpnx0

IF %0 == "%~0" set RAN_FROM_FILEBROWSER=1

:Start
call:Main
goto:eof

:Main
SetLocal
	if not exist "!BINARY_DIR!" ( mkdir "!BINARY_DIR!" )

	if not exist "!BINARY_DIR!\lua_downloaded_and_validated" (
		call:DownloadFile "!BASE_URL!lua51.dll" "!BINARY_DIR!\lua51.dll"
		call:DownloadFile "!BASE_URL!vcruntime140.dll" "!BINARY_DIR!\vcruntime140.dll"
	)
	
	call:DownloadLua "!BASE_URL!!BINARY_NAME!" "!BINARY_DIR!" "!BINARY_NAME!"
	
	set cmd_line="!BINARY_DIR!\!BINARY_NAME!" "!SCRIPT_PATH!"
	
	IF RAN_FROM_FILEBROWSER equ 1 (
		start "" !cmd_line!
	) else (
		!cmd_line!
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
			echo "exit code from lua does not match 'os.exit(1)'"
			del !abs_path!
			echo "removing !abs_path!"

			pause

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

function AlertBox(msg, title)
	msg = msg:gsub("\\", "/"):gsub("\n", "\\n")
	os.execute([[mshta javascript:alert("]]..msg..[[");close();]])
end

function main(storage_path, script_path, arg_line)
	arg_line = arg_line or ""

    local msg = " hello from lua!\n" ..
	" storage path: " .. storage_path .. "\n" ..
    " script path: " ..script_path .. "\n" ..
    " arg line:" .. arg_line
	
	for i = 1, 10 do
		print("some console text " .. i)
	end

	if os.getenv("RAN_FROM_FILEBROWSER") == "1" then
		AlertBox(msg)
	else
		io.write(msg)
	end
end

main(
	os.getenv("STORAGE_PATH"):gsub("\\", "/") .. "/",
	os.getenv("SCRIPT_PATH"):gsub("\\", "/"),
	os.getenv("ARG_LINE") or ""
)