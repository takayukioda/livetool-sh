#!/bin/bash
##################################################
# @author: da0shi
# @version: 1.0.0
#
##################################################
readonly SRC_DIR=${0%/*}
CONF_DIR=${SRC_DIR}
LOG_DIRNAME=log
ffmpeg=`which ffmpeg`
profile="default.profile"
rtmpfile="rtmp.default"
exec_cmds="exec.list"
report=

usage()
{
	echo "Usage:";
	echo "  $0 [-c /path/to/config] [-h] [-l] [-f fps] [-i insize] [-o outsize] [-g position] [-p file] <start | check>";
	echo "  -c /path/to/config"
	echo "    set config directory"
	echo "    use ${SRC_DIR} by default"
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
	echo "Using ${rtmpfile}"
}

exec_cmd ()
{
	local cmd=`which $1`
	if [ -z ${cmd} ]; then
		return 1
	fi
	shift
	${cmd} "$*" &
}
exec_cmds ()
{
	while read line
	do
		case $line in
			\#*)
				continue ;;
			\\\\)
				continue ;;
			*)
				exec_cmd ${line} ;;
		esac
	done <${exec_cmds}
}

while getopts c:hlr:i:o:g:p: option
do
	case "${option}" in
		c) #config directory
			CONF_DIR=${OPTARG}
			LOG_DIR=${CONF_DIR}/log
			;;
		h) #help
			usage
			exit 0 ;;
		l) #log
			f_report="-report"
			;;
		r) #ffmpeg option -r
			if [ ${OPTARG} -gt 0 -a ${OPTARG} -le 50 ]; then
				f_fps=${OPTARG}
			fi
			;;
		i) #input size
			if [ `echo ${OPTARG} | grep "^[0-9]\+x[0-9]\+$"` ]; then
				f_insize=${OPTARG}
			fi
			;;
		o) #outpout size
			if [ `echo ${OPTARG} | grep "^[0-9]\+x[0-9]\+$"` ]; then
				f_outsize=${OPTARG}
			fi
			;;
		g) #grab position
			if [ `echo ${OPTARG} | grep "^[0-9]\+,[0-9]\+$"` ]; then
				f_grab_position=":0.0+${OPTARG}"
			fi
			;;
		p) #profile
			f_profile=${OPTARG}
			echo "include ${f_profile}"
			;;
		\?)
			usage 1>&2
			exit 1 ;;
	esac
done
# shift arguements to check remaining arguements
shift `expr ${OPTIND} - 1`

# Load Default #####
cd ${CONF_DIR}
. ${profile}
if [ ${f_profile} -a -f ${f_profile} ]; then
	. ${f_profile}
fi
. ${rtmpfile}

readonly RTMP_URL=${RTMP_URL}
readonly STREAM=${STREAM}

if [ ! ${ffmpeg} ]; then
	echo "Error: ffmpeg not found"
	exit 2
elif [ ! -f "${ffmpeg}" ]; then
	echo "Error: ffmpeg not found"
	exit 2
elif [ ! -x "${ffmpeg}" ]; then
	echo "Error: ffmpeg not executable"
	exit 2
fi

if [ ! -d ${LOG_DIRNAME} ]; then
	mkdir ${LOG_DIRNAME}
fi

if [ ${f_report} ]; then
	report=${f_report}
fi
if [ ${f_fps} ]; then
	fps=${f_fps}
fi
if [ ${f_insize} ]; then
	insize=${f_insize}
fi
if [ ${f_outsize} ]; then
	outsize=${f_outsize}
fi
if [ ${f_grab_position} ]; then
	grab_position=${f_grab_position}
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

exec_cmds

${ffmpeg} \
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
	-vprofile ${video_profile} \
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

if [ ${report} ]; then
	mv ffmpeg*.log ${LOG_DIRNAME}/
fi
