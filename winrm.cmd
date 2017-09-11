@echo off
IF EXIST %SystemRoot%\system32\cscript.exe (
    @cscript //nologo "%~dpn0.vbs" %*
) ELSE (
    echo.
    echo WinRM command line is not available on this system.
    exit /B 1
)

