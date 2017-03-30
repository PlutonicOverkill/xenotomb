Powershell -executionpolicy remotesigned -File .\appveyor_download.ps1

7z x "..\gdcc_dl.7z" -o..\GDCC

.\build.bat
