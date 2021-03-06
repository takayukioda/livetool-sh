#!/bin/bash
##################################################
# @author: da0shi
# @version: 1.0.0
#
# cavetubeの「配信を開始」ボタンを押さなくても配信を開始できるようにする
# require: live.sh
# require: curl
# Github Repository: https://github.com/trentm/json
##################################################
CAVETUBE_START_API='http://gae.cavelis.net/api/start'
curl=`which curl`
if [ -x "${curl}" ]; then
	echo "Error: curl not found."
	exit 1
fi

config='conf'
. ${config}

if [ -z "${devkey}" ]; then
	echo "Error: devkey not set"
	exit 2
fi
devkey="devkey=${devkey}"
if [ -z "${apikey}" ]; then
	echo "Error: apikey not set"
	exit 2
fi
apikey="apikey=${apikey}"
if [ -z "${title}" ]; then
	echo "Error: Need to set title"
	echo -n "Enter the title (leave empty to cancel): "; read title
	if [ -z "${title}" ]; then
		exit 2
	fi
fi
title="title=${title}"
if [ -f "${description}" ]; then
	description="description=`cat ${description}`"
fi
if [ -n "${tag}" ]; then
	tag="tag=${tag}"
fi
if [ -n "${id_visible}" ]; then
	id_visible="id_visible=${id_visible}"
fi
if [ -n "${anonymous_only}" ]; then
	anonymous_only="anonymous_only=${anonymous_only}"
fi
if [ -n "${login_user}" ]; then
	login_user="login_user=${login_user}"
fi
if [ -n "${thumbnail_slot}" ]; then
	thumbnail_slot="thumbnail_slot=${thumbnail_slot}"
fi
if [ -n "${test_mode}" ]; then
	test_mode="test_mode=${test_mode}"
fi
if [ -n "${socket_id}" ]; then
	socket_id="socket_id=${socket_id}"
fi

curl_log=curl.log
response=`curl -o ${curl_log} -w '%{http_code}' -d ${devkey} -d ${apikey} -d "${title}" -d "${description}" -d "${tag}" -d ${id_visible} -d ${anonymous_only} -d ${login_user} -d ${thumbnail_slot} -d ${test_mode} ${CAVETUBE_START_API} 2>>${curl_log}`

if [ ${response} -eq 200 ]; then
	./live.sh ${sh_option} check
	echo -n "Start? (y/n) [n]"; read yn
	case ${yn} in
		y*)
			rm ${curl_log}
			./live.sh ${sh_option} start
			;;
		*)
			rm ${curl_log}
			echo "Cancel Stream Live"
			exit 0
			;;
	esac
else
	echo "Error: something happend @ curl request"
	echo "       see ${curl_log} for error info"
	exit 1
fi
