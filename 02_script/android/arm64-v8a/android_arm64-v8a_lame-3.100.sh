#!/bin/sh

# +++ Description Start +++
# 将Lame3.1编译为android上的so库,默认架构arm64-v8a.
# === Description End ===


# +++ 导入工具Shell Start +++
# . ${g_scriptArchDir}/util.sh
# === 导入工具Shell End ===


# +++ 用户指定变量 Start+++

# === 用户指定变量 End ===


# +++ 变量声明 Start+++
libId="lame-3.100"
scriptId=${g_platform}_${g_arch}_${libId}
# 源码目录
sourceLibDir=${g_inputRootDir}/${libId}
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


# 该库的编译时间
isConfigure="$1"
isMake="$2"

# === 变量声明 End ===


doClean() {
    echo "+++ clean start +++"

    if [[ -e "${sourceLibDir}/makefile" ]]; then 
        echo "distclean"
        make -C ${sourceLibDir} distclean
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
    echo "+++ configure start +++" 
    
	# host,cc,cxx是必须指定正确的.
	host="aarch64-linux-android"
    toolChainDir=${g_ndkDir}/toolchains/llvm/prebuilt/darwin-x86_64
	# arm64的在arch-arm64文件夹中. 该文件夹下,包含很多的系统库.
    # PLATFORM=${g_ndkDir}/platforms/android-${g_apiLevel}/arch-arm64
    # export PATH=$PATH:${ndkBinDir}:$PLATFORM/usr/include

	# C++编译器
    export CXX="${toolChainDir}/bin/${host}${g_apiLevel}-clang++"
	# C编译器
    export CC="${toolChainDir}/bin/${host}${g_apiLevel}-clang"

	# sysroot指不指定,没有作用呢?
	# --sysroot=${PLATFORM}
	# export CFLAGS="-isystem $g_ndkDir/sysroot/usr/include -isystem $g_ndkDir/sysroot/usr/include/aarch64-linux-android"
	
	# C编译器参数
	# export CFLAGS="--sysroot=${PLATFORM}"
	# C++编译器参数
    # export CXXFLAGS="$CFLAGS"
	# 预处理器参数
	# export CPPFLAGS="$CFLAGS"
	# 链接参数
    # export LDFLAGS="-L$PLATFORM/usr/lib -L$PREBUILT/${host}/lib -L${g_ndkDir}/sysroot/usr/lib/aarch64-linux-android"
    

    #不需要指定会自动判断.
 	export LD="${toolChainDir}/bin/aarch64-linux-android-ld"
	export AS="${toolChainDir}/bin/aarch64-linux-android-as"
    export LD="${toolChainDir}/bin/aarch64-linux-android-ld"
    export NM="${toolChainDir}/bin/aarch64-linux-android-nm"
    export STRIP="${toolChainDir}/bin/aarch64-linux-android-strip"
    export RANLIB="${toolChainDir}/bin/aarch64-linux-android-ranlib"
    export AR="${toolChainDir}/bin/aarch64-linux-android-ar"



    flag=""
	flag+=" --enable-shared"
	flag+=" --disable-frontend"
	if [[ "${g_configure}" = "debug" ]]; then
		flag+=" --enable-debug=alot"
	else
		flag+=" --enable-debug=no"
	fi
	flag+=" --enable-static=no"
	flag+=" --host=${host}"
	flag+=" --prefix=${outputLibDir}"

    
    ${sourceLibDir}/configure ${flag} 
    # echo ${flag} | xargs ${sourceLibDir}/configure
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

    if [[ ${isConfigure} == "Y" ]]; then
        doClean
        doConfigure
        [[ $? != 0 ]] && echo "configure failed" && exit
        # doCMake
    else 
        echo "No need to configure."
    fi

    if [[ ${isMake} == "Y" ]]; then
        rm -rf ${outputLibDir}
        doMake
        doInstall
        [[ $? != 0 ]] && echo "make failed" && exit
    else 
        echo "No need to make."
    fi
    # doFinish
    echo "=== Build ${libId} for ${g_platform} with ${g_arch} finish ===\n\n\n"
}

main
