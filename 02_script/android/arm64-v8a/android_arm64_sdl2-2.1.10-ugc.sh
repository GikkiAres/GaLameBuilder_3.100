#!/bin/sh

# +++ Description Start +++
# 将Lame3.1编译为android上的so库,默认架构arm64-v8a.
# === Description End ===

# +++ 用户指定变量 Start+++

# === 用户指定变量 End ===



# +++ 变量声明 Start+++
arch="arm64"
libId="sdl2-2.0.10-ugc"
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


# configure做的事情:
# 1 设置makefile需要的一些环境变量,根据架构的不同,可能不同.
# 2 配置configure的flag,根据架构的不同,可能不同.
# 3 configure,得到makefile文件.
# 根据要编译出来的ffmpeg的功能,设置ffempg,这里希望能够代码播放flv.
doBuild() {
    echo "+++ build start +++"

    export CC=${commonCC}

    # 设置安装目录
    flag="NDK_PROJECT_PATH=null"
    # .o文件的目录,放到Build目录中.
    flag="${flag} NDK_OUT=${buildLibDir}/obj"
    # .so文件的目录,放到install目录中.
    flag="${flag} NDK_LIBS_OUT=${outputLibDir}/lib"
    # 1,0 是否debug
    flag="${flag} NDK_DEBUG=1"
    flag="${flag} APP_BUILD_SCRIPT=${libSourceDir}/Android.mk"
    flag="${flag} APP_ABI=${ABI}"
    flag="${flag} APP_PLATFORM=android-${ANDROID_API_LEVEL}"
    flag="${flag} APP_MODULES=SDL2"
    # 将源码中的头文件拷贝到NDK_LIBS_OUT/include中
    mkdir -p ${outputLibDir}/include/SDL2/
    cp -r ${libSourceDir}/include/* ${outputLibDir}/include/SDL2/
    [[ $? != 0 ]] && echo "--- copy header file failed ---\n\n\n" && exit
    # 执行configure
    echo ${flag} | xargs ${androidNdkDir}/ndk-build
    [[ $? != 0 ]] && echo "--- configure failed ---\n\n\n" && exit


    # 手动生成pc文件
    SDL_STATIC_LIBS="-lSDL2  -ldl -lGLESv1_CM -lGLESv2 -lOpenSLES -llog -landroid -lm -lstdc++"
    SDL_CFLAGS=-D_THREAD_SAFE
    SDL_RLD_FLAGS=
    SDL_LIBS=-lSDL2
    SDL_VERSION=2.0.10
    # 源码中的pc文件模板拷贝到lib目录下,并替换相关数据.
    pcFileDir="${outputLibDir}/lib/${ABI}"
    cp -rf ${libSourceDir}/sdl2.pc.in ${pcFileDir}/sdl2.pc
    cd ${pcFileDir}
        sed -i "" -e "s|@SDL_VERSION@|$SDL_VERSION|" sdl2.pc ||:
        # 必须指定so的目录,连接so也可以被ffmpeg使用.
        sed -i "" -e "s|@libdir@|${outputLibDir}/lib/${ABI}|" sdl2.pc ||: && \
        sed -i "" -e "s|@includedir@|${outputLibDir}/include|" sdl2.pc ||: && \
        sed -i "" -e "s|@SDL_STATIC_LIBS@|$SDL_STATIC_LIBS|" sdl2.pc ||: && \
        sed -i "" -e "s|@SDL_CFLAGS@|$SDL_CFLAGS|" sdl2.pc ||: && \
        sed -i "" -e "s|@SDL_RLD_FLAGS@|$SDL_RLD_FLAGS|" sdl2.pc ||: && \
        sed -i "" -e "s|@SDL_LIBS@|$SDL_LIBS|" sdl2.pc ||:
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
        PKG_CONFIG_PATH="${outputLibDir}/lib/${ABI}"
    else 
        PKG_CONFIG_PATH="${outputLibDir}/lib/${ABI}"
    fi
    
    CC=""
    CFLAGS=""
    # 写入编译时间戳.
    echo 
    echo "=== install end ===\n"
}

main () {
    echo "\n\n\n+++ xxx Build ${libId} for ${g_platform} with ${g_arch} start  +++"
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
        # doConfigure
        # doCMake        
    fi
    
    if [[ ${isMake} == "Y" ]]; then
        rm -rf ${outputLibDir}
        doBuild
        [[ $? != 0 ]] && echo "build failed" && exit
        echo ${g_archConfigureTs} 1> ${g_libConfigureTsFilePath}
        echo ${g_archMakeTs} 1> ${g_libMakeTsFilePath}
    else 
        echo "No need to make."
    fi

    doFinish
    echo "=== Build ${libId} for ${g_platform} with ${g_arch} finish ===\n\n\n"
}

main





