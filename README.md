# reddit_refresher

2025-11-27-1

Get notifications of new posts on reddit

linux and windows version included  
windows version is deprecated

it runs in a loop.

don't set update time to low, you might get temporary blocked.  
it will post links to new posts in ntfs.sh/yourchannel_name


windows version uses powershell  
you can start it by clicking on bat  


### Installation

download script, edit it and run

set your xmpp accounts, and password  
kuca-home account sender  
dbojan-reciever on android device  

you can also use xmpp-communicator (https://github.com/dbojan), which is conversations app with some added features.

### android

you can also run it from phone, using termux:  


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

#### copy script (refresh.sh or r) to $HOME in termux
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

run `termux-wake-lock` first, so the phone does not put script to sleep, and then run r:  
```
termux-wake-lock
./r
```  

to stop the script, use: 'ctrl' 'z'

#### Android, more info

- You shold allow termux to run in the background

- Accessing termux storage using file explorer (from https://wiki.termux.com/wiki/Internal_and_external_storage):
  - https://github.com/zhanghai/MaterialFiles
  - https://play.google.com/store/apps/details?id=nextapp.fx

- I also suggest installing and running 'battery charge limit' (requires root), since it is not good for li ion batter to be at 99% charge. Set it to (80/50)  

- getting to develeoper mode on nokia 5:  
settings/system/about phone/build number, tap repeatedly till get developer mode on  
default usb settings: enable ftp transfer

### Changes:  

2025-11-27-1  
-update linux version. win version is deprecated

2025-08-28-1  
-minor filter adjustment

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

