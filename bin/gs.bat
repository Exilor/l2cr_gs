@echo off
title Game Server Console

chdir ..
:start
echo Starting l2_cr Game Server
echo.

./game_server

if ERRORLEVEL 2 goto restart
if ERRORLEVEL 1 goto error
goto end

:restart
echo.
echo Game Server restarted
echo.
goto start

:error
echo.
echo Game Server terminated abnormally
echo.

:end
echo.
echo Game Server terminated
echo.
pause
