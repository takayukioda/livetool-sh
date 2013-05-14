##################################################
# @author: da0shi
# @version: 1.0.0
#
#
# about options:
# 	bufsize = maxrate x 2
#
##################################################
usage()
{
	echo "Usage:";
	echo "  $0 [-h] [-l] [-f fps] [-i insize] [-o outsize] [-g position] [-p file] <start | check>";
	echo "  -h"
	echo "    show usage"
	echo "  -l"
	echo "    Make report file"
	echo "  -r fps"
	echo "    fps: number 1 <=> 50"
	echo "  -i insize"
	echo "    insize: WIDTHxHEIGHT"
	echo "  -o outsize"
	echo "    outsize: WIDTHxHEIGHT"
	echo "  -g grab_position"
	echo "    position: WIDTH,HEIGHT"
	echo "  -p profile"
}

print_config()
{
	echo "  ffmpeg option settings:"
	echo "  -rtbufsize 10MB"
	echo "  -r ${fps} (input)"
	echo "  -f x11grab -show_region 1"
	echo "  -s ${insize} -i ${grab_position}"
	echo "  -f alsa -i default"
	echo "  -r ${fps} (output)"
	echo "  -s ${outsize}"
	echo "  -sws_flags lanczos"
	echo "  -pix_fmt yuv420p"
	echo "  -maxrate ${maxrate}"
	echo "  -bufsize ${bufsize}"
	echo "  -vcodec ${video_codec}"
	echo "  -vprofile high"
	echo "  -vf \"unsharp=3:3:0.3\""
	echo "  -preset slower"
	echo "  -x264opts ${x264opts}"
	echo "  -acodec ${audio_codec}"
	echo "  -ar ${audio_frequency}"
	echo "  -ab ${audio_bitrate}"
	echo "  -ac ${audio_channel}"
	echo "  -nr ${noise_reduction}"
	echo "  -threads 2"
	echo "  -vsync ${video_sync_method}"
	echo "  -async ${audio_sync_sample_rate}"
	echo "  -y"
	echo "  -metadata maxBitrate=${maxrate}"
	echo "  -f flv \"RTMP_URL ${flash_version}\""
	echo "  (-report)"
	if [ -n "${RTMP_URL}" ]; then
		echo "rtmp url has been set"
	else
		echo "Need to set rtmp url"
	fi
	if [ -n "${STREAM}" ]; then
		echo "stream id has been set"
	else
		echo "Need to set stream id"
	fi
	echo "Using ${RTMP_FILE}"
}

# Get file path of its own
SRC_DIR="${0%/*}"
# Make log directory under the script path
LOG_DIR="${SRC_DIR}/log"
if [ ! -d ${LOG_DIR} ]; then
	mkdir ${LOG_DIR}
fi
cd ${SRC_DIR}

# Default Properties #####
profile="default.profile"
source ${profile}
source ${RTMP_FILE}

# Initialize OPTIND to check options again
report=""
while getopts hlr:i:o:g:p: option
do
	case "${option}" in
		h) #help
			usage
			exit 0
			;;
		l) #log
			report="-report"
			;;
		r) #ffmpeg option -r
			if [ ${OPTARG} -gt 0 -a ${OPTARG} -le 50 ]; then
				fps=${OPTARG}
			fi
			;;
		i) #input size
			if [ `echo ${OPTARG} | grep "^[0-9]\+x[0-9]\+$"` ]; then
				insize=${OPTARG}
			fi
			;;
		o) #outpout size
			if [ `echo ${OPTARG} | grep "^[0-9]\+x[0-9]\+$"` ]; then
				outsize=${OPTARG}
			fi
			;;
		g) #grab position
			if [ `echo ${OPTARG} | grep "^[0-9]\+,[0-9]\+$"` ]; then
				grab_position=":0.0+${OPTARG}"
			fi
			;;
		p) #profile
			if [ -f "${OPTARG}" ]; then
				load_profile=${OPTARG}
				echo "include ${load_profile}"
			fi
			;;
		\?)
			usage 1>&2
			exit 1
			;;
	esac
done
# shift arguements to check remaining arguements
shift `expr "${OPTIND}" - 1`

if [ ! -z ${load_profile} ]; then
	source ${load_profile}
fi

if [ $# -eq 0 ]; then
	echo "Need Request 'start' or 'check'"
	usage 1>&2
	exit 1
fi

if [ "$1" = "start" ]; then
	if [ -z "${RTMP_URL}" -o -z "${STREAM}" ]; then
		echo "rtmp url is not set" 1>&2
		echo "  rtmp url: ${RTMP_URL}" 1>&2
		echo "  stream id: ${STREAM}" 1>&2
		exit 1
	fi
elif [ "$1" = "check" ]; then
	print_config
	exit 2
else
	echo "Bad Request: $1";
	usage
	exit 1
fi

#gnome-alsamixer &
gnome-system-monitor &
pavucontrol &
xeyes &
xclock -digital -strftime "%Y/%m/%d %H:%M" &

# ffmpeg options
# -rtbufsize :
# -r : fps
# -f : input file format
#   => x11grab : use x11grab for display capture
#   => -show_region 1 : show the captured area
#   => -s : input frame size
#   => -i : start point to grab
# -f : audio source
#   => -i : sound card
# -r ${fps} \
	# -s ${outsize} \
	# -sws_flags lanczos \
	# -pix_fmt yuv420p \
	# -maxrate ${maxrate} \
	# -bufsize ${bufsize} \
	# -vcodec ${video_codec} \
	# -vprofile high \
	# -vf "unsharp=3:3:0.3" \
	# -preset slower \
	# -x264opts ${x264opts} \
	# -acodec ${audio_codec} \
	# -ar ${audio_frequency} \
	# -ab ${audio_bitrate} \
	# -ac ${audio_channel} \
	# -threads 2 \
	# -vsync ${video_sync_method} \
	# -y \
	# -f flv "${RTMP_URL}/${STREAM} ${flash_version}" \
	# -report

/usr/local/bin/ffmpeg \
	-rtbufsize 10MB \
	-r ${fps} \
	-f x11grab -show_region 1 \
	-s ${insize} -i ${grab_position} \
	-f alsa -i default \
	-isync \
	-r ${fps} \
	-s ${outsize} \
	-sws_flags lanczos \
	-pix_fmt yuv420p \
	-maxrate ${maxrate} \
	-bufsize ${bufsize} \
	-vcodec ${video_codec} \
	-vprofile high \
	-vf "unsharp=3:3:0.3" \
	-preset ${preset} \
	-x264opts ${x264opts} \
	-acodec ${audio_codec} \
	-ar ${audio_frequency} \
	-ab ${audio_bitrate} \
	-ac ${audio_channel} \
	-nr ${noise_reduction} \
	-threads 2 \
	-vsync ${video_sync_method} \
	-async ${audio_sync_sample_rate} \
	-y \
	-metadata maxBitrate=${maxrate} \
	-f flv "${RTMP_URL}/${STREAM} ${flash_version}" \
	${report}

if [ -n "${report}" ]; then
	mv ffmpeg*.log ${LOG_DIR}/.
fi
