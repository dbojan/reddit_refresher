

rem 2025-08-28-1
rem check reddit for new posts

@echo off
rem uses powershell

rem Define variables
set file_new=r_reddit_links_only_without_offer-new.txt
set file_old=r_reddit_links_only_without_offer-old.txt
set file_difference=r_difference-filenew-minus-fileold.txt
set chan=https://ntfy.sh/gamesr
set url=https://old.reddit.com/user/dbojan76/m/games/new/
set user-agent=reddit-refresher-github-win

rem Change to script directory
cd /d "%~dp0"

:retest
echo %date% - %time%


rem Remove downloaded file if it exists
rem if exist "%dl%" del "%dl%"

rem rem grep -oP 'data-permalink=".?\K[^"]*' "$dl" > "$file_new"
rem sed -i -e '/\/request/d' -e '/\/gog_thank/d' -e '/\/gog_a_big_thank_you/d' -e '/\/discussion/d' -e '/\/review/d'  "$file_new"

rem Download page
rem .\curl\curl.exe -A reddit_refresher_win "%url%" > "%dl%"
rem dl page: powershell.exe -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ; Invoke-WebRequest -Uri '%url%' -OutFile '%dl%' -UserAgent '%user-agent%'"
rem extract links: powershell -NoProfile -Command "Select-String -Path '%dl%' -Pattern 'data-permalink=\"(.+?)\"' -AllMatches |   ForEach-Object { $_.Matches } | ForEach-Object { $_.Value -replace 'data-permalink=\"', 'https://reddit.com' -replace '\"','' } | Out-File -FilePath '%file_new%' -Encoding utf8" 

rem remove unwanted tags: powershell.exe -NoProfile -Command "(Get-Content '%file_new%') -notmatch '/GiftofGames.*/request|/GiftofGames.*/gog.*thank|/GiftofGames.*/discussion|/GiftofGames.*/intro|/humblebundles.*/review' | Set-Content '%file_new%' -Encoding UTF8"
rem in pipe this gets changed to  Where-Object   {$_ -notmatch '/GiftofG ....' }  
rem save file ...

rem 1. download page, 2. extract links (replace data-permalink with https://..., 3. remove lines matching filter, and 4. finally save output to file:
powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ; Invoke-WebRequest -Uri '%url%' -UserAgent '%user-agent%'                       |            Select-String -Pattern 'data-permalink=\"(.+?)\"' -AllMatches |   ForEach-Object { $_.Matches } | ForEach-Object { $_.Value -replace 'data-permalink=\"', 'https://reddit.com' -replace '\"','' } |           Where-Object   {$_ -notmatch '/GiftofGames.*/request|/GiftofGames.*/gog.*thank|/GiftofGames.*/discussion|/GiftofGames.*/intro|/humblebundles.*_review'   }                           |Out-File -FilePath '%file_new%' -Encoding utf8" 


rem Check if file_old exists
if not exist "%file_old%" (
	echo No old file, sending new file with links
	call :fn_post "%file_new%"
) else (


	if exist "%file_difference%" del "%file_difference%"

	rem file_new=new, file_old=old 
	rem Compare file_new-new to file_old-old, and output difference to file_difference.txt
	REM WILL WRITE STRING AS UTF8-BOM!
	rem powershell.exe -NoProfile -Command "(Compare-Object (Get-Content '%file_new%' ) (Get-Content '%file_old%') -PassThru | Out-String).Trim()| Set-Content '%file_difference%' -Encoding UTF8"

	rem remove utf8-bom, write file if difference exists
	powershell.exe -NoProfile -Command "$utf8 = New-Object System.Text.UTF8Encoding($false)  ; $text_difference = (Compare-Object (Get-Content '%file_new%') (Get-Content '%file_old%') -PassThru | Out-String).Trim() ;    if ($text_difference){  [System.IO.File]::WriteAllText('%file_difference%', $text_difference, $utf8)  }  "	
	rem ; write-host $text_difference ")



    	rem Check if there's a difference.txt file
	if exist "%file_difference%" (
		echo New posts exist, sending difference list...
		call :fn_post "%file_difference%"
	) else (
		echo No changes...
	)
)

rem Move current page to old for future comparison
move /y "%file_new%" "%file_old%"


rem wait 2 minutes before rechecking. there is a limit after you get temporary blocked, so be careful with value

rem remove this two lines, if you run this using scheduler, or crontab
timeout /nobreak /t 120
goto retest


rem also remove line below, if using scheduler, or crontab
pause

exit /b


:fn_post
	rem first is file
	rem use set var=%~1 if needed
	echo sending file %~1
	powershell.exe -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;  $fileContent = [System.IO.File]::ReadAllBytes('%~1');    Invoke-WebRequest -Uri '%chan%' -Method 'POST' -Body $fileContent -ContentType 'application/octet-stream'"
	rem echo Hello %~1, welcome to %~2!
goto :eof





