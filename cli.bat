@rem
@rem Copyright 2020 the original author jacky.eastmoon
@rem All commad module need 3 method :
@rem [command]        : Command script
@rem [command]-args   : Command script options setting function
@rem [command]-help   : Command description
@rem Basically, CLI will not use "--options" to execute function, "--help, -h" is an exception.
@rem But, if need exception, it will need to thinking is common or individual, and need to change BREADCRUMB variable in [command]-args function.
@rem NOTE, batch call [command]-args it could call correct one or call [command] and "-args" is parameter.
@rem

:: ------------------- batch setting -------------------
@rem setting batch file
@rem ref : https://www.tutorialspoint.com/batch_script/batch_script_if_else_statement.htm
@rem ref : https://poychang.github.io/note-batch/

@echo off
setlocal
setlocal enabledelayedexpansion

:: ------------------- declare CLI file variable -------------------
@rem retrieve project name
@rem Ref : https://www.robvanderwoude.com/ntfor.php
@rem Directory = %~dp0
@rem Object Name With Quotations=%0
@rem Object Name Without Quotes=%~0
@rem Bat File Drive = %~d0
@rem Full File Name = %~n0%~x0
@rem File Name Without Extension = %~n0
@rem File Extension = %~x0

set CLI_DIRECTORY=%~dp0
set CLI_FILE=%~n0%~x0
set CLI_FILENAME=%~n0
set CLI_FILEEXTENSION=%~x0

:: ------------------- declare CLI variable -------------------

set BREADCRUMB=cli
set COMMAND=
set COMMAND_BC_AGRS=
set COMMAND_AC_AGRS=

:: ------------------- declare variable -------------------

for %%a in ("%cd%") do (
    set PROJECT_NAME=%%~na
)
set PROJECT_ENV=dev
set PROJECT_SSH_USER=somesshuser
set PROJECT_SSH_PASS=somesshpass

:: ------------------- execute script -------------------

call :main %*
goto end

:: ------------------- declare function -------------------

:main (
    call :argv-parser %*
    call :%BREADCRUMB%-args %COMMAND_BC_AGRS%
    call :main-args %COMMAND_BC_AGRS%
    IF defined COMMAND (
        set BREADCRUMB=%BREADCRUMB%-%COMMAND%
        call :main %COMMAND_AC_AGRS%
    ) else (
        call :%BREADCRUMB%
    )
    goto end
)
:main-args (
    for %%p in (%*) do (
        if "%%p"=="-h" ( set BREADCRUMB=%BREADCRUMB%-help )
        if "%%p"=="--help" ( set BREADCRUMB=%BREADCRUMB%-help )
    )
    goto end
)
:argv-parser (
    set COMMAND=
    set COMMAND_BC_AGRS=
    set COMMAND_AC_AGRS=
    set is_find_cmd=
    for %%p in (%*) do (
        IF NOT defined is_find_cmd (
            echo %%p | findstr /r "\-" >nul 2>&1
            if errorlevel 1 (
                set COMMAND=%%p
                set is_find_cmd=TRUE
            ) else (
                set COMMAND_BC_AGRS=!COMMAND_BC_AGRS! %%p
            )
        ) else (
            set COMMAND_AC_AGRS=!COMMAND_AC_AGRS! %%p
        )
    )
    goto end
)

:: ------------------- Main mathod -------------------

:cli (
    goto cli-help
)

:cli-args (
    goto end
)

:cli-help (
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo If not input any command, at default will show HELP
    echo.
    echo Options:
    echo      --help, -h        Show more information with CLI.
    echo.
    echo Command:
    echo      init              Initial and download nginx service.
    echo      start             Start nginx service.
    echo      down              Stop nginx service.
    echo      status            Check nginx service status
    echo.
    echo Run 'cli [COMMAND] --help' for more information on a command.
    goto end
)

:: ------------------- Command "init" mathod -------------------

:cli-init (
    ( set /p NGINX_VERSION= ) < version.rc
    set NGINX_FILENAME=nginx-%NGINX_VERSION%.zip
    IF NOT EXIST %NGINX_FILENAME% (
        echo download %NGINX_FILENAME% and unzip
        curl -o %NGINX_FILENAME% http://nginx.org/download/%NGINX_FILENAME%
        tar -xf %NGINX_FILENAME%
        ren nginx-%NGINX_VERSION% nginx
    ) ELSE (
        echo %NGINX_FILENAME% has been download.
    )
    goto end
)

:cli-init-args (
    goto end
)

:cli-init-help (
    echo Initial and download nginx service.
    goto end
)

:: ------------------- Command "start" mathod -------------------

:cli-start (
    IF EXIST nginx (
        set NGINX_CONFIG_FILE=%CLI_DIRECTORY%conf\!NGINX_CONFIG: =!.conf
        IF EXIST !NGINX_CONFIG_FILE! (
            @ rem copy config file into nginx directory
            echo Nginx run by config file !NGINX_CONFIG_FILE!
            copy !NGINX_CONFIG_FILE! %CLI_DIRECTORY%\nginx\conf
            @rem close old nginx process
            call :cli-down
            @rem start nginx process
            cd %CLI_DIRECTORY%\nginx
            nginx -t -c conf\!NGINX_CONFIG: =!.conf
            start nginx -c conf\!NGINX_CONFIG: =!.conf
            tasklist /fi "imagename eq nginx.exe"
        ) else (
            echo Nginx !NGINX_CONFIG_FILE! config file not exist.
        )
    ) ELSE (
        echo Nginx hasn't download, please use command "init" to download.
    )

    goto end
)

:cli-start-args (
    set NGINX_CONFIG=nginx
    for %%p in (%*) do (
        echo %%p | findstr /r "\=" >nul 2>&1
        if errorlevel 1 (
            @rem not assign value.
            if "%%p"=="--dev" ( set NGINX_CONFIG=dev )
        ) else (
            @rem has assign value.
            for /F "tokens=1,2 delims==" %%G in (%%p) do (
               if "%%G"=="--dev" ( set NGINX_CONFIG=%%H )
            )
        )
    )


    goto end
)

:cli-start-help (
    echo Start nginx service.
    goto end
)

:: ------------------- Command "down" mathod -------------------

:cli-down (
    IF EXIST nginx (
        cd nginx
        tasklist /fi "imagename eq nginx.exe"
        nginx -s stop
        nginx -s quit
        taskkill /F /IM nginx.exe
    ) ELSE (
        echo Nginx hasn't download, please use command "init" to download.
    )
    goto end
)

:cli-down-args (
    goto end
)

:cli-down-help (
    echo Stop nginx service.
    goto end
)

:: ------------------- Command "status" mathod -------------------

:cli-status (
    IF EXIST nginx (
        cd nginx
        tasklist /fi "imagename eq nginx.exe"
    ) ELSE (
        echo Nginx hasn't download, please use command "init" to download.
    )
    goto end
)

:cli-status-args (
    goto end
)

:cli-status-help (
    echo Check nginx service status.
    goto end
)


:: ------------------- End method-------------------

:end (
    endlocal
)
