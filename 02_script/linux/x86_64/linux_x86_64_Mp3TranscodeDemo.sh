#!/bin/sh

# +++ Description Start +++
# 将lame-3.100编译为ubuntu上的so库. 
# === Description End ===



# +++ 变量声明 Start+++
libId="${g_libId}"
scriptId=${g_platform}_${g_arch}_${libId}
# 源码目录
inputLibDir=${g_inputRootDir}/${libId}
# 脚本目录
scriptLibDir=${g_scriptArchDir}/${libId}
# 中间目录
buildLibDir=${g_buildArchDir}/${libId}
if [[ ! -e ${buildLibDir} ]]; then
    mkdir -p ${buildLibDir}
fi

# 安装目录
outputLibDir=${g_outputArchDir}/${libId}
if [[ ! -e ${outputLibDir} ]]; then
    mkdir -p ${outputLibDir}
fi


isConfigure="$1"
isMake="$2"

# === 变量声明 End ===


doClean() {
    echo "+++ clean start +++"

    if [[ -e "${inputLibDir}/makefile" ]]; then 
        echo "distclean"
        make -C ${inputLibDir} distclean
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


# configure做的事情:
# 1 设置makefile需要的一些环境变量,根据架构的不同,可能不同.
# 2 配置configure的flag,根据架构的不同,可能不同.
# 3 configure,得到makefile文件.
# 根据要编译出来的ffmpeg的功能,设置ffempg,这里希望能够代码播放flv.
doConfigure() {
    echo "\n+++ configure start +++"

	# export CFLAGS="-arch x86_64"
	# export LDFLAGS="-arch x86_64"
	export CC="${g_cc}"

	flag=""
    # 指定host
	flag+=" --host=${g_host}"
    # 指定安装目录
	flag+=" --prefix=${outputLibDir}"
    # 指定不编译可执行文件,默认编译
    flag+=" --disable-frontend"

	if [[ "${g_configure}" == "debug" ]]; then
		#debug,configure没有增加debug选项,自己增加-g参数.
		CFLAGS+=" -g"
	fi

	${inputLibDir}/configure ${flag}

	[[ $? != 0 ]] && echo "--- configure failed ---\n" && exit
    echo "=== configure end ===\n"
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

    echo "outputLibDir:${outputLibDir}"
    # ubuntu的math库为-lm  /usr/lib/x86_64-linux-gnu/libm.so

    if [[ ${isMake} == "Y" ]]; then
        rm -rf ${outputLibDir}
        gcc ${inputLibDir}/main.c -I${g_outputArchDir}/lame-3.100/include ${g_outputArchDir}/lame-3.100/lib/libmp3lame.a -lm
        cp a.out ${outputLibDir}/a.out
        [[ $? != 0 ]] && echo "make failed" && exit
    else 
        echo "No need to make."
    fi
    ${outputLibDir}/a.out ${g_inputRootDir}/timeless.pcm timeless.mp3
    # doFinish
    echo "=== Build ${libId} for ${g_platform} with ${g_arch} finish ===\n\n\n"
}

main
