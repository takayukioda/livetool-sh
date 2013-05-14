fps=15
#insize="960x720"
#outsize="720x540"
insize=640x480
outsize=640x480
grab_position=":0.0+1516,150"
maxrate="432k"
bufsize="864k"
flash_version="flashver=FME/3.0\20(compatible;20FMSc/1.0)"

## Video
video_codec="libx264"
x264opts="aq-mode=2:aq-strength=1.5:crf=16:deblock=-1=-1:psy-rd=0.7=0.5:keyint=200:rc-lookahead=40:qpmin=10:qpmax=51 "
video_sync_method=-1
#libx264 AVOption
preset="fast"

## Audio
audio_codec="libmp3lame"
audio_frequency="44100"
audio_bitrate="128k"
audio_channel="2"
audio_sync_sample_rate="2"
noise_reduction=100
## rtmp url
RTMP_FILE="rtmp.cave"
