livetool-sh
===========

shellscripts for live streaming by ffmpeg

#Directory
<pre>
livetool-sh
	|-ffmpeg_setup.sh
	|
	|-README.md
	|-live.sh
	|-default.profile
	|-exec.list
	|-rtmp.default
	|
	|-cavetube.sh
	|-conf
	|-default.desc
</pre>

#ffmpeg_setup.sh
"ffmpeg_setup.sh" is based on
[UbuntuCompilationGuide](https://ffmpeg.org/trac/ffmpeg/wiki/UbuntuCompilationGuide).  
Wrap each install operation as function.  
It will clone git repository to "/usr/local/git" where defined as src.  
And build files will be install at "/usr/local/ffmpeg".

#Requires
##live.sh  
ffmpeg with "--enable-libx264" option.  
It may possible to run with other than libx264, but I haven't tried :p.

#### How to check ffmpeg
Run ``ffmpeg -version``  
and search for if it includes "--enable-libx264" in configuration list.

##cavetube.sh
curl

#Before You Run
##live.sh
set rtmp url and it's id in rtmp.default.  
```sh
RTMP_URL="rtmp://rtmp.example.com/some/path"  
STREAM="xxxxxyyyyyzzzzz"  
```

##cavetube.sh
Get your api key from [here](http://gae.cavelis.net/developer).  
set "apikey" in file "conf" with the api key you've got from link above.  
fill the vars with comment "Required".  
```sh
devkey=xyzxyzXYZXYZ    #Required <- Do NOT Touch
apikey=******          #Required <- Fill with api key you've got
title="Live by ffmpeg" #Required <- Make any title you want
```
Write live description in "default.desc"
