livetool-sh
===========

shellscripts for live streaming by ffmpeg

Prerequisites
-------------

### ffmpeg

ffmpeg, compiled with `--enable-libx264` option is required.
You may use other encoding libraries, but x264 is the most preferred library for streaming.

To check if your current ffmpeg has that option, run following command.

```shell
$ ffmpeg -version | grep "--enable-libx264"
```

### curl

To run `cavetube.bash`, curl is required to call some API endpoint.

Directory
---------

```
livetool-sh
  \_ .liverc
  \_ cavetube.bash
  \_ conf
  \_ default.desc
  \_ default.profile
  \_ exec.list
  \_ ffmpeg_setup.bash
  \_ live.sh
  \_ README.md
  \_ rtmp.default
```

ffmpeg_setup.sh
---------------

	Note: Recent ubuntu seems to have `x264` option enabled.
	Please try running without those manual installation; run `sudo apt install ffmpeg` instead.

Use this script to install ffmpeg with an option of `--enable-libx264`.
This script is made based on [UbuntuCompilationGuide](https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu).

It manually build and install `fdk-aac`, `x264`, and `ffmpeg`.  
ffmpeg will be installed into `/opt/ffmpeg`.


.liverc
-------

For configuration, use `.liverc` as configuration file.

### rtmp url and it's stream key

set rtmp url and it's id in rtmp.default.  

```sh
RTMP_URL="rtmp://rtmp.example.com/some/path"  
STREAM_KEY="xxxxxyyyyyzzzzz"  
```

CaveTube API Key
----------------

If you expect to start streaming in cavetube, you will need an API key to request prepare for streaming.

Get your api key from [here](http://gae.cavelis.net/developer).  
set "apikey" in file "conf" with the api key you've got from link above.  
fill the vars with comment "Required".  

```sh
devkey=xyzxyzXYZXYZ    #Required <- Do NOT Touch
apikey=******          #Required <- Fill with api key you've got
title="Live by ffmpeg" #Required <- Make any title you want
```

Write live description in "default.desc"
