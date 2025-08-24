# reddit_refresher

2025-08-24-2

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

#### make refresh.sh run in loop:  
open 'refresh.sh' in notepad++, or notepad  
remove # from lines: `#while true; do` and `#sleep 120; done`  
so it looks like this:

before:  
```
#remove to have it running in loop
#while true; do
...

#remove to have it running in loop
#sleep 120; done
```
after:  
```
#remove to have it running in loop
while true; do
...

#remove to have it running in loop
sleep 120; done
```

rename 'refresh.sh' to 'r'  

#### install termux, cx explorer using 'files' app  
update termux repository  
after installed, in termux type:  
`pkg update`  
`pkg install grep sed curl`  

#### allow termux to access phone file system
type:  
`termux-setup-storage`  
( allow )  
this fill allow to use folder '~/storage' which will point out to: 'dcim', 'downloads' etc ...  
(this is not actuual root of android folder, if you create file 1.txt above folder 'dcim' termux won't see it)  
using file manager like 'cx explorer', or 'files', copy file 'r' to folder 'dcim'  

#### copy 'r' to $HOME in termux
in termux type:
```
cd ~/storage
ls (you should see dcim folder)
cd dcim
ls (you should see 'r' here)
cp r $HOME
cd $HOME
ls (you should see 'r' here)
chmod 755 r
ls -al (you should see 'r' here, in green with rwx in front)
```
#### running the script
`./r`  

to stop the script, use: 'ctrl' 'z'

#### Android, more info

- I also suggest installing and running 'battery charge limit' (requires root), since it is not good for li ion batter to be at 99% charge. Set it to (80/50)  

- You shold probably disable battery optimization for termux  

- getting to develeoper mode on nokia 5:  
settings/system/about phone/build number, top repeatedly till get developer mode on  
usb settings: enable ftp transfer

- Accessing termux storage using file explorer (from https://wiki.termux.com/wiki/Internal_and_external_storage):
  - https://github.com/zhanghai/MaterialFiles
  - https://play.google.com/store/apps/details?id=nextapp.fx

### Changes:  

2025-08-24-2  
-minor modifications, should not sleep on android.

2025-08-24-1  
-more messages

2025-08-11-1  
-reworked filters  
-moved everything to one line

2025-08-16-1  
-added optional loop for refresh.sh

2025-08-18-1  
-added date at the start of the (optional) loop

