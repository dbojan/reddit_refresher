# reddit_refresher

2025-08-07-1

Get notifications of new posts on reddit

linux and windows version included

linux version uses grep, curl and sed, make sure you have them installed  
-add to crontab using: 
crontab -e  
to have it check every 2 minutes:  
` */2 * * * * /path_to_folder/reddit_refresher/refresh.sh `

if you lower time, you might get temporary blocked.
it will post links to new posts in ntfs.sh/yourchannel_name


windows version uses powershell  
you can start it by clicking on bat  
it runs in a loop.

### Installation

right click [here](https://raw.githubusercontent.com/dbojan/reddit_refresher/refs/heads/main/reddit_refresher.zip), select 'save link as' to download  
uncompres...
