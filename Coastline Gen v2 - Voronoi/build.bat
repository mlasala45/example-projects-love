@echo off
color A
cd src
"C:\Program Files\7-Zip\7z" a ..\tmp.zip *
cd ..
move tmp.zip main.love
pause