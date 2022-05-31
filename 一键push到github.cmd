@echo off

:: 获取当前脚本的路径
cd /d %~dp0
:: 自动提交
git push origin master
@echo have completed,

SET daoTime=60
:dao
set /a daoTime=daoTime-1
ping -n 2 -w 500 127.1>nul
cls
echo Git upload complete, countdown exit %daoTime%second
if %daoTime%==0 (exit) else (goto dao)