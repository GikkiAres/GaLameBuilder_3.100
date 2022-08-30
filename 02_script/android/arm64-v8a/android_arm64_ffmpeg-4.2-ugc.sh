#!/bin/sh

# +++ Description Start +++
# 将Lame3.1编译为android上的so库,默认架构arm64-v8a.
# === Description End ===


# +++ 导入工具Shell Start +++
. ${g_scriptArchDir}/util.sh
# === 导入工具Shell End ===


# +++ 用户指定变量 Start+++

# === 用户指定变量 End ===


# +++ 变量声明 Start+++
libId="ffmpeg-4.2-ugc"
scriptId=${g_platform}_${g_arch}_${libId}
# 源码目录
libSourceDir=${g_projectDir}/01_Input/${libId}

# 脚本目录
libScriptDir=${g_projectDir}/02_Script/${g_platform}/${libId}
# 中间目录
buildLibDir=${g_projectDir}/03_Build/${g_platform}/${g_arch}/${libId}
if [[ ! -e ${buildLibDir} ]]; then
    mkdir -p ${buildLibDir}
fi

# 安装目录
outputLibDir=${g_projectDir}/04_Output/${g_platform}/${g_arch}/${libId}
if [[ ! -e ${outputLibDir} ]]; then
    mkdir -p ${outputLibDir}
fi

libConfigureTsFilePath=${buildLibDir}/configure.time
libMakeTsFilePath=${buildLibDir}/make.time

# 该库的编译时间
libConfigureTs=""
libMakeTs=""
isConfigure=""
isMake=""

# === 变量声明 End ===


doClean() {
    echo "+++ clean start +++"

    if [[ -e "${libSourceDir}/makefile" ]]; then 
        echo "distclean"
        make -C ${libSourceDir} distclean
    fi
    

    if [[ -e "makefile" ]]; then 
        echo "clean"
        make clean
        [[ $? != 0 ]] && echo "--- clean failed ---\n\n\n" && exit
    else 
        echo "No need to clean"
    fi
    echo "=== clean end ===\n\n\n"
}

valifyPkgConfig() {
    echo "PKG-CONFIG-PATH is: ${PKG-CONFIG-PATH}"
    pkg-config sdl2 --libs
}

# configure做的事情:
# 1 设置makefile需要的一些环境变量,根据架构的不同,可能不同.
# 2 配置configure的flag,根据架构的不同,可能不同.
# 3 configure,得到makefile文件.
# 根据要编译出来的ffmpeg的功能,设置ffempg,这里希望能够代码播放flv.
doConfigure() {
    echo "+++ configure start +++"
    valifyPkgConfig    
    # exit;

    export CC=${commonCC}

    # 设置安装目录
    flag="--prefix=${outputLibDir}"
    # 交叉编译设置 --cross-prefix指定了jni的目录 
    flag="${flag} --target-os=android  --arch=${g_arch} --enable-cross-compile --enable-jni --cross-prefix=${CROSS_COMPILE}"
    flag="${flag} --pkg-config-flags=--static --pkg-config=pkg-config"
    flag="${flag} --enable-gpl --enable-nonfree --enable-version3 --enable-neon --enable-pthreads"
    # 库的类型
    flag="${flag} --disable-shared --enable-static"

    # 调式 
    flag="${flag}  --disable-stripping --disable-optimizations"
    # flag="${flag} --enable-optimizations --disable-debug"

    # 取消所有东西
    # 这个打开,有某些依赖无法满足不能编译出来.
    # flag="${flag} --disable-everything --disable-autodetect --disable-all --disable-doc"
    flag="${flag} --disable-doc"
    # 打开ffplay 和 ffmpeg,因为需要用到ffplay和ffmpeg中的函数.
    flag="${flag} --enable-ffplay --enable-ffmpeg --enable-sdl2 --disable-ffprobe "
    # 打开协议,能够打开文件
    flag="${flag} --disable-protocols --enable-protocol=file"
    # 打开parser
    flag="${flag} --disable-parsers --enable-parser=h263 --enable-parser=mpegvideo --enable-parser=mpegaudio --enable-parser=h264 --enable-parser=flac --enable-parser=h264"
   
    # decoder
    # 打开视频decoder
    flag="${flag} --disable-decoders --enable-decoder=flv --enable-decoder=h263 --enable-decoder=rawvideo --enable-decoder=aac --enable-decoder=h264 --enable-decoder=h264_mediacodec --enable-decoder=hevc --enable-decoder=hevc_mediacodec --enable-decoder=wrapped_avframe" 
    # 打开音频decoder
    flag="${flag} --enable-decoder=pcm_f16le  --enable-decoder=pcm_s16be --enable-decoder=pcm_f32le  --enable-decoder=pcm_s32be  --enable-decoder=mp3 --enable-decoder=mpeg4" 
    
    # 打开demuxer
    flag="${flag} --disable-demuxers --enable-demuxer=flv --enable-demuxer=image2 --enable-demuxer=mp3 --enable-demuxer=mpegvideo --enable-demuxer=m4v"
    # indev
    flag="${flag} --disable-indevs --enable-indev=ugc"
    # outdev
    flag="${flag} --enable-outdev=sdl2"
    # filter
	# 截图需要scale,tile
    flag="${flag} --disable-filters --enable-filter=null --enable-filter=ugc_movie --enable-filter=volume --enable-filter=atempo --enable-filter=setpts --enable-filter=gltransform --enable-filter=glfilter --enable-filter=settb --enable-filter=asettb --enable-filter=aresample --enable-filter=scale --enable-filter=tile"
    # bsf
    flag="${flag} --disable-bsfs --enable-bsf=null --enable-bsf=h264_metadata"
    # 加速
    flag="${flag} --disable-hwaccels"
    # muxer #singlejpeg用于截图.
    flag="${flag} --disable-muxers --enable-muxer=singlejpeg"
    # encoder
    flag="${flag} --disable-encoders --enable-encoder=mjpeg"
	# 安卓平台的支持
    flag="${flag} --enable-mediacodec"

    echo "configure flag is: ${flag} --cc=${CC}"
    ${libSourceDir}/configure ${flag} "--cc=${CC}"
    # ${libSourceDir}/configure ${flag} "--extra-cflags=${extraCFlags}" "--extra-ldflags=${extraLdFlags}" "--cc=${CC}"
    # echo ${flag} | xargs ${libSourceDir}/configure
    [[ $? != 0 ]] && echo "--- configure failed ---\n\n\n" && exit
    echo "=== configure end ===\n\n\n"
}

doCMake() {
    echo "\n\n\n+++ cmake start +++"
    cmake ${g_projectDir}/02_Script/android/${g_arch}/CMakeLists.txt -B ${buildDir}
    [[ $? != 0 ]] && echo "--- cmake failed ---\n\n\n" && exit
    echo "=== cmake end ===\n"
}

doMake() {
    echo "+++ make start +++"
    make -j4
    [[ $? != 0 ]] && echo "--- make failed ---\n\n\n" && exit
    echo "=== make end ===\n\n\n"
}
doInstall() {
    echo "+++ install start +++"
    make install
    [[ $? != 0 ]] && echo "--- install failed ---\n\n\n" && exit
    echo "=== install end ===\n\n\n"
}

main () {
    echo "\n\n\n+++ Build ${libId} for ${g_platform} with ${g_arch} start  +++"
    cd ${buildLibDir}

    # 判断是否Configure
    # 没有configureTs,则configue+make
    if [[ ! -e ${g_libConfigureTsFilePath} ]]; then 
        isConfigure="Y"
    else 
        libConfigureTs=$(cat ${g_libConfigureTsFilePath})
        if [[ ${g_archConfigureTs} == ${libConfigureTs} ]]; then
            isConfigure="N"
        else
            isConfigure="Y"
        fi
    fi

    # 判断是否Make
    if [[ ${isConfigure} == "Y" ]]; then 
        isMake="Y"
        
    elif [[ ! -e ${g_libMakeTsFilePath} ]]; then
        isMake="Y"
    else 
        libMakeTs=$(cat ${g_libMakeTsFilePath})
        if [[ ${g_archMakeTs} == ${libMakeTs} ]]; then
            isMake="N"
        else
            isMake="Y"
        fi
    fi

    

    if [[ ${isConfigure} == "Y" ]]; then
        doClean
        doConfigure
        [[ $? != 0 ]] && echo "configure failed" && exit
        echo ${g_archConfigureTs} 1> ${g_libConfigureTsFilePath}
        # doCMake
    else 
        echo "No need to configure."
    fi

    isMake="N"
    if [[ ${isMake} == "Y" ]]; then
        rm -rf ${outputLibDir}
        doMake
        doInstall
        [[ $? != 0 ]] && echo "make failed" && exit
        echo ${g_archMakeTs} 1> ${g_libMakeTsFilePath}
    else 
        echo "No need to make."
    fi

    doFinish

    echo "=== Build ${libId} for ${g_platform} with ${g_arch} finish ===\n\n\n"
}

main





