#!/bin/sh

libName="lame"
libVersion="3.100"
libId="${libName}-${libVersion}"
scriptId=${g_platform}_${g_arch}_${libId}

# 源码目录
libSourceDir=${g_inputRootDir}/${libId}
# 脚本目录
libScriptDir=${g_scriptRootDir}/${g_platform}/${g_arch}
# Build目录

buildLibDir=${g_buildArchDir}/${libId}
if [[ ! -e ${buildLibDir} ]]; then
    mkdir -p ${buildLibDir}
fi
# Output目录
outputLibDir=${g_outputArchDir}/${libId}
if [[ ! -e ${outputLibDir} ]]; then
    mkdir -p ${outputLibDir}
fi


# 是否需要configure # 是否需要make
libBuildType=$1
echo "libBuildType:${libBuildType}"
case $1 in
    $LIB_BUILD_TYPE_CONFIGURE)
    isConfigure="Y"
    isMake="N"
    ;;
    $LIB_BUILD_TYPE_MAKE)
    isConfigure="N"
    isMake="Y"
    ;;
    $LIB_BUILD_TYPE_CONFIGURE_MAKE)
    isConfigure="Y"
    isMake="Y"
    ;;
    $LIB_BUILD_TYPE_IGNORE)
    isConfigure="N"
    isMake="N"
    ;;
esac


doClean() {
    echo "+++ clean start +++"

    if [[ -e "${libSourceDir}/makefile" ]]; then 
        make -C ${libSourceDir} distclean
        echo "distclean"
    fi
    

    if [[ -e "makefile" ]]; then 
        make clean
        [[ $? != 0 ]] && echo "--- clean failed ---\n" && exit
    else 
        echo "No need to clean"
    fi
    echo "=== clean end ===\n"
}

doConfigure() {
    echo "\n+++ configure start +++"

	flags=""
	flags+=" --enable-shared=no"
	flags+=" --disable-frontend"
	if [[ "${g_configure}" = "debug" ]]; then
		flags+=" --enable-debug=alot"
	else
		flags+=" --enable-debug=no"
	fi
	flags+=" --enable-static=yes"
	flags+=" --host=${g_host}"
	flags+=" --enable-static=yes"
	flags+=" --prefix=${outputLibDir}"
	# flags+=" --srcdir=${libSourceDir}"
	 
    export CC="${g_cc}"
    # # export CFLAGS="-arch arm64 -fembed-bitcode -miphoneos-version-min=8.0"
    # # export LDFLAGS="-arch arm64 -fembed-bitcode -miphoneos-version-min=8.0"
	# # C预编译期
    # export CPP="${CC} -E"
    # export CPPFLAGS=${CFLAGS}
    # export CXX=${CC}
    # export CXXFLAGS=${CFLAGS}
    # export AS="xcrun -sdk iphoneos clang"
	# printCompileEnvironment

	echo "flags is: ${flags}"
    # echo ${flags} | xargs ${libSourceDir}/configure
	${libSourceDir}/configure ${flags}

	[[ $? != 0 ]] && echo "--- configure failed ---\n" && exit
    echo "=== configure end ===\n"
}


doCMake() {
    echo "\n+++ cmake start +++"
	[[ $? != 0 ]] && echo "--- cmake failed ---\n" && exit
    echo "=== cmake end ===\n"
}

doMake() {
    echo "\n+++ make start +++"
	cd ${buildLibDir}
    make -j4
    [[ $? != 0 ]] && echo "--- make failed ---\n" && exit
    echo "=== make end ===\n"
}

doInstall() {
    echo "\n+++ install start +++"
    make install
    [[ $? != 0 ]] && echo "--- install failed ---\n" && exit
    echo "=== install end ===\n"
}


# 完成阶段做一些操作
# 添加pc文件夹到PKG_CONFIG_PATH
doFinish() {
    echo "\n+++ finish start +++"
    if [[ ${PKG_CONFIG_PATH} == "" ]]; then
        PKG_CONFIG_PATH="${outputLibDir}/lib/pkgconfig"
    else 
        PKG_CONFIG_PATH="${outputLibDir}/lib/pkgconfig:${PKG_CONFIG_PATH}"
    fi
    
    # 取消CFLAGS.
    CFLAGS=""
    echo "=== finish end ===\n"
}



main () {
    echo "\n\n\n+++ Build ${libId} for ${g_platform} with ${g_arch} start  +++"
    
	cd ${buildLibDir}

    if [[ ${isConfigure} == "Y" ]]; then
        doClean
        doConfigure
		# doCMake    
        [[ $? != 0 ]] && echo "configure failed" && exit
    else  
        echo "set no configure"
    fi
    
    if [[ ${isMake} == "Y" ]]; then
        rm -rf ${outputLibDir}
        doMake
        doInstall
        [[ $? != 0 ]] && echo "make failed" && exit
    else 
        echo "set no make"
    fi

    doFinish
    echo "=== Build ${libId} for ${g_platform} with ${g_arch} finish ===\n\n\n"
}

main





