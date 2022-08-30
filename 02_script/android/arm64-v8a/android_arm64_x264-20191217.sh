#!/bin/sh

# +++ 变量声明 Start+++
arch="arm64"
platform="android"
# 和源码的文件夹保持同名
libId="x264-20191217"
scriptId=${g_platform}_${g_arch}_${libId}

# 源码目录
libSourceDir=${g_projectDir}/01_Input/${libId}

# 脚本目录
libScriptDir=${g_projectDir}/02_Script/${g_platform}/${g_arch}

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
	# distclean必须cd到当前目录执行,为什么执行失败?
	
    if [[ -e "${libSourceDir}/makefile" ]]; then 
		echo "distclean"
		currentPwd=`pwd`
		cd ${buildLibDir}
        make distclean 
		cd ${currentPwd}
    fi
    
	echo "libSourceDir is: ${libSourceDir}"
	# exit
	# 为什么有的时候,直接cd到那个目录去clean是可以的.
	# 但是直接用-C参数却不行? make clean会产生config.h文件!
    # if [[ -e "${libSourceDir}/makefile" ]]; then 
    #     echo "clean"
    #     make clean -C ${libSourceDir}
    #     # [[ $? != 0 ]] && echo "--- clean failed ---\n\n\n" && exit
    # else 
    #     echo "No need to clean"
    # fi
    echo "=== clean end ===\n\n\n"
}

# configure做的事情:
# 1 设置makefile需要的一些环境变量,根据架构的不同,可能不同.
# 2 配置configure的flag,根据架构的不同,可能不同.
# 3 configure,得到makefile文件.
# 根据要编译出来的ffmpeg的功能,设置ffempg,这里希望能够代码播放flv.
doConfigure() {
    echo "+++ configure start +++"

    export CC=${commonCC}

    # 设置安装目录
    flag="--prefix=${outputLibDir}"
    # 不生成动态库
    flag="${flag} --enable-pic"

    # --cross-prefix指定了jni的目录 
    flag="${flag} --cross-prefix=${CROSS_COMPILE}"
    # 设置host,使用该代码的机器类型.
    flag="${flag} --host=${host}"
    flag="${flag} --enable-strip --disable-cli --enable-static"
    # 如果是x86需要禁用asm
    # flag="${flag} --disable-asm"
    echo "flag is: ${flag}"
	# 这样做提示Out of tree builds
    echo ${flag} | xargs ${libSourceDir}/configure
	# ${libSourceDir}/configure ${flag}
    [[ $? != 0 ]] && echo "--- configure failed ---\n\n\n" && exit
    echo "=== configure end ===\n\n\n"
}


doCMake() {
    echo "\n\n\n+++ cmake start +++"
    cmake ${g_projectDir}/02_Script/android/${g_arch}/CMakeLists.txt -B ${buildLibDir}
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
    echo "\n+++ install start +++"
    make install
    [[ $? != 0 ]] && echo "--- install failed ---\n\n\n" && exit
    echo "=== install end ===\n"
}


# 完成阶段做一些操作
# 添加pc文件夹到PKG_CONFIG_PATH
doFinish() {
    echo "+++ install start +++"
    if [[ ${PKG_CONFIG_PATH} == "" ]]; then
        PKG_CONFIG_PATH="${outputLibDir}/lib/pkgconfig"
    else 
        PKG_CONFIG_PATH="${outputLibDir}/lib/pkgconfig"
    fi
    
    CC=""
    CFLAGS=""
    # 写入编译时间戳.
    echo 
    echo "=== install end ===\n"
}

main () {
    echo "\n\n\n+++ Build ${libId} for ${g_platform} with ${g_arch} start  +++"
    cd ${buildLibDir}

    # 判断是否Configure
    # 没有configureTs,则configue+make
    if [[ ! -e ${g_libConfigureTsFilePath} ]]; then 
        echo "No lib configure ts"
        isConfigure="Y"
    else 
        libConfigureTs=$(cat ${g_libConfigureTsFilePath})
        echo "Lib configure ts: ${libConfigureTs}\nArch configure ts:${g_archConfigureTs}"
        if [[ "${g_archConfigureTs}" == "${libConfigureTs}" ]]; then
            isConfigure="N"
            echo "No need to configure."
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
        if [[ "${g_archMakeTs}" == "${libMakeTs}" ]]; then
            isMake="N"
        else
            isMake="Y"
        fi
    fi

    

    if [[ ${isConfigure} == "Y" ]]; then
        doClean
        doConfigure
        [[ $? != 0 ]] && echo "--- configure failed ---\n\n\n" && exit
        echo ${g_archConfigureTs} 1> ${g_libConfigureTsFilePath}
        # doCMake        
    fi
    
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





