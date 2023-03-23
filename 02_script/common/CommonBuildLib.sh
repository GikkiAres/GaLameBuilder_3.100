#!/bin/sh

# +++ Description Start +++
# CommonBuildLib.sh
# 按照给定的变量,执行编译操作.
# === Description End ===


doClean() {
    echo "\n+ clean start +"

    if [[ -e "${g_sourceLibDir}/makefile" ]]; then 
        echo "distclean"
        make -C ${g_sourceLibDir} distclean
    fi
    

    if [[ -e "makefile" ]]; then 
        echo "clean"
        make clean
        [[ $? != 0 ]] && echo "- clean failed -" && exit
    else 
        echo "No need to clean"
    fi
    echo "= clean end ="
}


# configure做的事情:
# 1 设置makefile需要的一些环境变量,根据架构的不同,可能不同.
# 2 配置configure的flag,根据架构的不同,可能不同.
# 3 configure,得到makefile文件.
# 根据要编译出来的ffmpeg的功能,设置ffempg,这里希望能够代码播放flv.
doConfigure() {
    echo "\n+ configure start +" 
    # 在build目录下执行源码目录中的configure命令,中间文件在build目录下.
    ${g_sourceLibDir}/configure ${g_flag} 
    # echo ${g_sourceLibDir} | xargs ${g_sourceLibDir}/configure

    [[ $? != 0 ]] && echo "- configure failed -\n\n\n" && exit
    echo "= configure end =\n\n\n"
}

doCMake() {
    echo "\n+ cmake start +"
    cmake ${g_projectDir}/02_Script/android/${g_arch}/CMakeLists.txt -B ${buildDir}
    [[ $? != 0 ]] && echo "--- cmake failed ---" && exit
    echo "= cmake end ="
}

doMake() {
    echo "\n+ make start +"
    make -j4
    [[ $? != 0 ]] && echo "--- make failed ---" && exit
    echo "= make end ="
}
doInstall() {
    echo "\n+ install start +"
    make install
    [[ $? != 0 ]] && echo "- install failed -" && exit
    echo "= install end ="
}


main () {
    echo "\n\n\n+++ Build ${libId} for ${g_platform} with ${g_arch} start  +++"
    # 切换到build临时目录
    cd ${g_buildLibDir}
    if [[ $g_libBuildType == $LIB_BUILD_TYPE_CONFIGURE_MAKE || $g_libBuildType == $LIB_BUILD_TYPE_CONFIGURE ]]; then
        doClean
        doConfigure
        [[ $? != 0 ]] && echo "configure failed" && exit
        # doCMake
    else 
        echo "No need to configure."
    fi

    if [[ $g_libBuildType == $LIB_BUILD_TYPE_CONFIGURE_MAKE || $g_libBuildType == $LIB_BUILD_TYPE_MAKE ]]; then
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
