This is a way of running Lua with one or two mouse clicks on 
Linux, macOS and Windows. It also supports running from command line

It works by downloading Lua externally.

By default, this writes to `$HOME/.appexample` on Unix and `%appdata%\appexample` 
on Windows but you can also set it to write to the current directory to
make something like a portable folder. 

Both of the scripts use some silly syntax to allow writing Lua code at 
the end of each script. This has one side effect on Windows where it will
echo `rem =nil BATCH_PROGRAM=[[` before `@echo off` as I couldn't find a way
to make this work with Lua. It also sets rem to nil on the Lua side.

These hacks are not really nesseceary as you could modify it to download an 
external script and just execute that instead.

Both scripts have a helper function called DownloadFile which you can use 
to download files. 

### Bash
```bash
# Uses wget or curl
DownloadFile "https://foobar.com/test.exe" "test.exe"
```
### Batch
```batch
:: Uses curl or powershell
call:DownloadFile "https://foobar.com/test.exe" "test.exe"
```

If downloading an executable I recommend running a validation afterwards 
to make sure it works. In the scripts, unless `lua_downloaded_and_validated` 
doesn't exist, the function `DownloadLua` downloads luajit.exe, checks if the 
exit code is correct by running `os.exit` and if successful writes 
`lua_downloaded_and_validated` to the same directory indicating that it's 
been downloaded.

### Why not powershell or WSH on windows?
I use Batch because it has a significant faster startup time than Powershell. 
Windows script host (.js or .vb) is fast but has some limitations when it comes 
to being executed from command line vs explorer.
