This is a way of running Lua with one or two mouse clicks on Linux, macOS and 
Windows. It also supports running properly from the command line. It works 
by simply downloading the Lua executable with Batch or Shell from the internet.

By default, the scripts download files to `$HOME/.appexample` on Unix 
and `%appdata%\appexample` on Windows but you can also set it to write 
to the current directory if you want to make something like a portable folder. 

Both of the scripts use some syntax to allow writing Lua code at beginning of each script. 
Batch uses the following:
```lua
::_::BATCH_PROGRAM=[[
...
goto:eof
rem ]]
```

Which requires goto labels in Lua to be valid. This can be replaced with the following 
if Lua 5.1 is desired.
```lua
rem = nil BATCH_PROGRAM=[[
...
goto:eof
rem ]]
```

The Shell version uses the following:
```lua
#!/bin/sh
SHELL_PROGRAM=[=[
...
exit 0
]=]
```
Which looks a bit more natural.

These hacks are not strictly nesseceary as you could modify the script
to download an external Lua script and just execute that instead.

Both scripts have a helper function called DownloadFile.

```bash
# bash
# Uses wget or curl
DownloadFile "https://foobar.com/baz" "baz"
```

```batch
:: batch
:: Uses curl or powershell
call:DownloadFile "https://foobar.com/baz.exe" "baz.exe"
```

When downloading an executable it's good practice to run validation afterwards 
to make sure it works. For example, if `lua_downloaded_and_validated` 
doesn't exist download luajit.exe, check if the exit code is correct by running
`os.exit` and if successful write `lua_downloaded_and_validated` to the same 
directory indicating that it's been downloaded and validated. This is what
the example scripts do.

### Why not powershell or WSH on Windows?
I use Batch because it has a significant faster startup time than Powershell. 
Windows script host (.js or .vb) is fast but has some limitations when it comes 
to being executed from command line vs explorer. 


