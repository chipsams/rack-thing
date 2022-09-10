@ECHO OFF
del /f .\rackthing.zip
"C:\Program Files\7-Zip\7z.exe" a .\rackthing.zip *
ren .\rackthing.zip rackthing.love