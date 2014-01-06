#!/bin/bash
# place to clone git repository
src=/usr/local/git
# place to install
build=/usr/local/ffmpeg

init_git_repos ()
{
	if [ ! -d ${src} ]; then
		mkdir ${src}
	fi
	cd ${src}
	git clone git://git.videolan.org/x264.git
	git clone git://github.com/mstorsjo/fdk-aac.git
	git clone git://source.ffmpeg.org/ffmpeg.git
}
update_git_repos ()
{
	for repo in x264 fdk-aac ffmpeg
	do
		cd ${src}/${repo}
		make distclean
		git pull
	done
}

before_setup ()
{
	sudo apt-get install \
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
}
install_x264 ()
{
	if [ ! -d ${build} ]; then
		mkdir ${build}
	fi
	dir=${src}/x264
	cd ${dir}
	./configure \
		--prefix=${build} \
		--bindir=${build}/bin \
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
	if [ ! -d ${build} ]; then
		mkdir ${build}
	fi
	dir=${src}/fdk-aac
	cd ${dir}
	autoreconf -fiv && \
		./configure \
		--prefix=${build} \
		--disable-shared && \
		make && \
		make install && \
		make distclean
}

install_ffmpeg ()
{
	if [ ! -d ${build} ]; then
		mkdir ${build}
	fi
	dir=${src}/ffmpeg
	cd ${dir}
	./configure \
		--prefix=${build} \
		--extra-cflags="-I${build}/include" \
		--extra-ldflags="-L${build}/lib" \
		--bindir=${build}/bin \
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

#init_git_repos
#before_setup
#update_git_repos
#install_x264
#install_fdkaac
#install_ffmpeg
