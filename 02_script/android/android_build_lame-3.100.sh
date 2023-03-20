#!/bin/sh

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

# 判断是否要编译和make
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


doConfigure() {
    echo "+++ configure start +++" 




    ${sourceLibDir}/configure ${g_flag} 
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