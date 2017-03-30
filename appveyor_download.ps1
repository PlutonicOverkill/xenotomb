$source = "https://www.dropbox.com/sh/e4msp35vxp61ztg/AAA2Ti5pBthuMBfwPSb6Y_MCa/gdcc_master-latest_win64.txt?dl=1"
$destination = "./latest_gdcc_version.txt"
Invoke-WebRequest $source -OutFile $destination

$gdcc_url = Get-Content .\latest_gdcc_version.txt -Raw
$gdcc_url = $gdcc_url.Replace("dl=0", "dl=1")

$gdcc_destination = "..\gdcc_dl.7z"
Invoke-WebRequest $gdcc_url -OutFile $gdcc_destination
