#!/bin/bash

# place to clone libraries to install ffmpeg
readonly SRC=/opt/vendor

# place to install
readonly BUILD=/opt/ffmpeg

clone_vendors ()
{
	mkdir_if_not_exists $SRC

	cd ${SRC}
	[ ! -d ./x264 ] && git clone git://git.videolan.org/x264.git
	[ ! -d ./fdk-aac ] && git clone git://github.com/mstorsjo/fdk-aac.git
	[ ! -d ./ffmpeg ] && git clone git://source.ffmpeg.org/ffmpeg.git
}


mkdir_if_not_exists() {
	local dir=$1
	[ ! -d $dir ] && echo "Running: mkdir $dir" && mkdir $dir
}

cd_and_git_pull() {
	local repo=$1
	[ ! -d $SRC/$repo ] && return 1
	cd $SRC/$repo
	make distclean
	git pull
}

install_prerequisites() {
	sudo apt-get update
	sudo apt-get install -y \
		autoconf \
		automake \
		build-essential \
		git \
		libass-dev \
		libfaac-dev \
		libgpac-dev \
		libmp3lame-dev \
		libopus-dev \
		libsdl1.2-dev \
		libtheora-dev \
		libtool \
		libva-dev \
		libvdpau-dev \
		libvorbis-dev \
		libvpx-dev \
		libx11-dev \
		libxfixes-dev \
		pkg-config \
		texi2html \
		yasm \
		zlib1g-dev
	sudo apt-get -y upgrade
}

install_x264 () {
	mkdir_if_not_exists $BUILD
	cd_and_git_pull x264

	local dir=${SRC}/x264
	cd ${dir}

	./configure \
		--prefix=${BUILD} \
		--bindir=${BUILD}/bin \
		--enable-static \
		--disable-cli \
		--disable-opencl \
		--disable-ffms \
		--disable-lavf \
		--disable-gpac \
		--disable-swscale \
		--disable-avs \
		&& \
		make && \
		make install && \
		make distclean
}

install_fdkaac ()
{
	mkdir_if_not_exists $BUILD
	cd_and_git_pull fdk-aac


	dir=${SRC}/fdk-aac
	cd ${dir}
	autoreconf -fiv && \
		./configure \
		--prefix=${BUILD} \
		--disable-shared && \
		make && \
		make install && \
		make distclean
}

install_ffmpeg ()
{
	mkdir_if_not_exists $BUILD
	cd_and_git_pull ffmpeg

	dir=${SRC}/ffmpeg
	cd ${dir}

	./configure \
		--prefix=${BUILD} \
		--extra-cflags="-I${BUILD}/include" \
		--extra-ldflags="-L${BUILD}/lib" \
		--bindir=${BUILD}/bin \
		--enable-librtmp \
		--enable-gpl \
		--enable-libass \
		--enable-libfaac \
		--enable-libfdk-aac \
		--enable-libmp3lame \
		--enable-libopus \
		--enable-libtheora \
		--enable-libvorbis \
		--enable-libvpx \
		--enable-libx264 \
		--enable-nonfree \
		--enable-x11grab &&\
		make && \
		make install && \
		make distclean && \
		hash -r && \
		. ~/.bash_profile
}

install_prerequisites
clone_vendors
install_x264
install_fdkaac
install_ffmpeg
