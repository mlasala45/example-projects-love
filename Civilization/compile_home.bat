@echo off
color a
cd src
"C:\Program Files\7-Zip\7z" a ..\tmp.zip *
cd ..
move tmp.zip main.love
pause
"C:\Program Files\LOVE\love.exe" --fused main.love