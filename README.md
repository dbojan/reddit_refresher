# reddit_refresher

2025-08-16-1

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


### android

you can also run it from phone, using termux:  
pkg update  
pkg install grep sed curl  
remove # from below lines that say: remove this lines to have it running in loop.  

you cann connect phone to laptop usb (make sure it charges when laptop is in suspend mode), or to phone charger, and have it connected to wifi.  

root phone  
install cs explorer, in setting enable root  
and copy r.sh to to /data/data/com.termux/files/home/  

to make r.sh executable: chmod 755 ./r.sh  
start by runninx termux, and typing ./r.sh, or rename it to r. Press enter. Turn screen off.  

I also suggest installing and running 'battery charge limit' (requires root), since it is not good for li ion batter to be at 99% charge. Set it to (50/80)  


###

changes:  

2025-08-11-1  
-reworked filters  
-moved everything to one line

2025-08-16-1  
-added optional loop for refresh.sh

