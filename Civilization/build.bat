@echo off
color A
cd src
"C:\7-Zip\7z" a ..\tmp.zip *
cd ..
move tmp.zip main.love
pause