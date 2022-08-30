#!/bin/sh

# +++ Description Start +++
# 奖ffmpeg打包为aar.
# === Description End ===


# +++ 导入工具Shell Start +++
. ${g_scriptArchDir}/util.sh
# === 导入工具Shell End ===


# +++ 用户指定变量 Start+++

# === 用户指定变量 End ===


# +++ 变量声明 Start+++
libId="wrapper"
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
aarBuildDir=${buildLibDir}/aar
aarInstallDir=${outputLibDir}/aar

# 将生成的aar直接复制到目标位置
userLibPath1="/Users/gikkiares/Desktop/CP_CompanyProject/CP03_Vgemv/CP0308_UgcSdk/01_UgcSdkDemo/04_Make/video_sdk/branches/AnHuiRiBao/android/VgemvUgcAh_android_dev/app/libs/"
userLibPath2="/Users/gikkiares/Desktop/CP_CompanyProject/CP03_Vgemv/CP0308_UgcSdk/01_UgcSdkDemo/04_Make/video_sdk/branches/AnHuiRiBao/android/VgemvUgcAh_android_dev/sdk/libs/"
userLibPath3="/Users/gikkiares/Desktop/CP_CompanyProject/CP03_Vgemv/CP0308_UgcSdk/01_UgcSdkDemo/04_Make/video_sdk/branches/AnHuiRiBao/android/VgemvUgcAh_android_dev/app/src/main/jniLibs/arm64-v8a"


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

copyAar() {
    # copy aar
    # set version release
    # RELEASE=`cat ${BUILD_ROOT_DIR}/RELEASE`
    # VERSION=`cat ${BUILD_ROOT_DIR}/VERSION`
    RELEASE="1.0.0"
    VERSION="1.0.0"
	# 创建文件夹
    mkdir -p ${aarInstallDir}/ffmpeg_cli_wrapper/
	# 从input拷贝到build
    cp -rf ${intputRootDir}/android/ffmpeg_cli_wrapper_jni/aar/* ${aarInstallDir}/ffmpeg_cli_wrapper/
	# 替换版本号
    sed -i "" -e "s/{{versionCode}}/${RELEASE}/" \
    ${aarInstallDir}/ffmpeg_cli_wrapper/AndroidManifest.xml
    sed -i "" -e "s/{{versionName}}/${VERSION}/" \
    ${aarInstallDir}/aar/ffmpeg_cli_wrapper/AndroidManifest.xml
}

# 根据wrapper的CMakeLists.txt文件->makefile文件.
# 这个的主要作用,就是编译了几个需要更改的ffmpeg中的c代码.
cmakeFfmpegCliWrapper() {
    echo "\n\n\n+++ cmakeFfmpegCliWrapper +++"
	wrapperDir=${g_buildArchDir}/ffmpeg_cli_wrapper
    # 创建ffmpeg_cli_wrapper文件夹
    mkdir -p ${wrapperDir}
    cd ${wrapperDir}
    # cmake,根据CMakeList创建makefile文件.
    # -DCMAKE_BUILD_TYPE=$([ $DEV_DEBUG = yes ] && echo Debug || echo Release) \
    flag="-DCMAKE_BUILD_TYPE=Debug"
    # 配置toolchain
    flag="${flag} -DCMAKE_TOOLCHAIN_FILE=${androidNdkDir}/build/cmake/android.toolchain.cmake"
    # 配置版本
    flag="${flag} -DANDROID_PLATFORM=${ANDROID_API_LEVEL}"
    # 配置ABI
    flag="${flag} -DANDROID_ABI=${ABI}"
    # 库的安装目录
    flag="${flag} -DCMAKE_INSTALL_PREFIX=${wrapperDir}"
	# ffmpeg的include头文件位置
    flag="${flag} -DFFMPEG_INCLUDE_DIR=${archInstallDir}/ffmpeg-4.2-ugc/include"

    cmake ${intputRootDir}/ffmpeg_cli_wrapper ${flag}

    echo "=== cmakeFfmpegCliWrapper ===\n\n\n"
}

# 根据wrapper_jni的CMakeLists.txt文件->makefile文件.
cmakeFfmpegCliWrapperJni() {
    echo "\n\n\n+++ cmakeFfmpegCliWrapperJni +++"
	wrapperJniDir=${g_buildArchDir}/ffmpeg_cli_wrapper_jni
    mkdir -p ${wrapperJniDir}
    cd ${wrapperJniDir}
    # 设置编译版本.
    flag="-DCMAKE_BUILD_TYPE=Debug"
    # flag="-DCMAKE_BUILD_TYPE=Release"
    # 配置toolchain
    flag="${flag} -DCMAKE_TOOLCHAIN_FILE=${androidNdkDir}/build/cmake/android.toolchain.cmake"
    # 配置版本
    flag="${flag} -DANDROID_PLATFORM=${ANDROID_API_LEVEL}"
	# 设置android-jar程序
	flag="${flag} -DANDROID_JAR=${intputRootDir}/android/android-${ANDROID_API_LEVEL}.jar"
    # 配置ABI
    flag="${flag} -DANDROID_ABI=${ABI}"
	# ffmpeg头文件的位置
    flag="${flag} -DFFMPEG_INCLUDE_DIR=${archInstallDir}/ffmpeg-4.2-ugc/include"

	# 设置库的安装目录
	flag="${flag} -DCMAKE_INSTALL_PREFIX=${archInstallDir}/ffmpeg_cli_wrapper_jni/"
    # 设置wrapper,ffmpeg,libx264,sdl的目录
	# ffmpeg_wrapper头文件位置.
	flag="${flag} -DWRAPPER_INCLUDE_DIR=${archInstallDir}/ffmpeg_cli_wrapper/include"
	# libffmpeg_cli_warpper.a的位置.
    flag="${flag} -DWRAPPER_LIB=${archInstallDir}/ffmpeg_cli_wrapper/lib/libffmpeg_cli_wrapper.a"
	# libffmpeg.a的位置.
    flag="${flag} -DFFMPEG_LIB=${archInstallDir}/ffmpeg-4.2-ugc/lib/libffmpeg.a"
	# libx264.a的位置.
    flag="${flag} -DLIBX264_LIB=${archInstallDir}/x264-20191217/lib/libx264.a"
	# libSDL.so的位置.
    flag="${flag} -DLIBSDL_LIB=${archInstallDir}/sdl2-2.0.10-ugc/lib/arm64-v8a/libSDL2.so"
    cmake ${intputRootDir}/android/ffmpeg_cli_wrapper_jni ${flag}
    echo "=== cmakeFfmpegCliWrapperJni ===\n\n\n"

}

generateMakeFile() {
    if [[ -e ${platformBuildDir}/Makefile ]]; then
        rm -rf ${platformBuildDir}/Makefile
    fi
    echo "\n\n\n+++ generateMakeFile +++"

	WRAPPER_AAR_DEPS="${WRAPPER_AAR_DEPS} wrapper_aar/${g_arch} "
# 输出制表符,不要空格.
cat << END > ${platformBuildDir}/Makefile
default_target: all
.PHONY : default_target
clean:
	rm -rf Makefile objs

END

# Step 0 : Make ffmpeg/arm64 使用ffmpeg本来的makefile,然后将所有的.o文件打包成ffmpeg.o文件.
# 每一行是一个subshell,所以要切换目录执行的命令,需要写成一行.
# 将ffmpeg-4.2-ugc目录下的所有.o文件打包生成libffmpeg.a文件.
# 最终结果输出到安装目录下.
cat << END >> ${platformBuildDir}/Makefile
ffmpeg/${g_arch}:
	@echo "make ffmpeg" && \\
	cd ${g_buildArchDir}/ffmpeg-4.2-ugc && \\
	\$(MAKE) -j4 && \\
	\$(MAKE) -j4 install-headers && \\
	find ./ -name "*.o"| xargs ${CROSS_COMPILE}ar rcs libffmpeg.a && \\
	cp -f libffmpeg.a ${archInstallDir}/ffmpeg-4.2-ugc/lib/

END

# Step 1 : Make ffmpeg_wrapper/arm64
# 切换到对应目录执行makefile文件.
cat << END >> ${platformBuildDir}/Makefile
wrapper/${g_arch}:
	@echo "make wrapper" && \\
	cd ${g_buildArchDir}/ffmpeg_cli_wrapper && \\
	\$(MAKE) -j4 install

END

# Step 2 : Make ffmpeg_wrapper_jni/arm64
# 切换到对应目录执行makefile文件.
cat << END >> ${platformBuildDir}/Makefile
wrapper_jni/${g_arch}:
	@echo "make wrapper_jni" && \\
	cd ${g_buildArchDir}/ffmpeg_cli_wrapper_jni && \\
	\$(MAKE) -j4 install

END


# Step 3 : 将ffmpeg/arm64 wrapper/arm64 wrapper_jni/arm64合并-->libffmpeg_cli_wrapper_jni.so,libSDL2.so移动过去.
# 切换到对应目录执行makefile文件.
# 将jni.jar文件移动过去
# 将合并得到的两个so移动过去.
cat << END >> ${platformBuildDir}/Makefile
wrapper_aar/${g_arch}: ffmpeg/${g_arch} wrapper/${g_arch} wrapper_jni/${g_arch}
	@echo "make wrapper_aar/arm64" && \\
	cp -rf ${g_buildArchDir}/ffmpeg_cli_wrapper_jni/jni.jar ${aarInstallDir}/ffmpeg_cli_wrapper/classes.jar && \\
	cp -rf ${archInstallDir}/ffmpeg_cli_wrapper_jni/aar/ffmpeg_cli_wrapper ${aarInstallDir}
	@echo "make wrapper_aar/arm64 end" 

END

# Step 4 : 将多个arch的文件合并
# 本质是jni目录中的arch的合并.
cat << END >> ${platformBuildDir}/Makefile
wrapper_aar:${WRAPPER_AAR_DEPS}
	@echo "packing wrapper_aar"	&& \\
	cd ${aarInstallDir}/ffmpeg_cli_wrapper  && \\
	zip -r ${platformInstallDir}/ffmpeg_cli_wrapper.aar *
	cp ${platformInstallDir}/ffmpeg_cli_wrapper.aar ${userLibPath1}
	cp ${platformInstallDir}/ffmpeg_cli_wrapper.aar ${userLibPath2}
	cp ${archInstallDir}/ffmpeg_cli_wrapper_jni/aar/ffmpeg_cli_wrapper/jni/arm64-v8a/libffmpeg_cli_wrapper_jni.so ${userLibPath3}
END

cat << END >> ${platformBuildDir}/Makefile
all: wrapper_aar
	@echo "ALL DONE. "
	@echo "     aar location: objs/ffmpeg_cli_wrapper.aar"
.PHONY : all

END


echo "=== generateMakeFile ===\n\n\n"
}

# configure做的事情:
# 1 设置makefile需要的一些环境变量,根据架构的不同,可能不同.
# 2 配置configure的flag,根据架构的不同,可能不同.
# 3 configure,得到makefile文件.
# 根据要编译出来的ffmpeg的功能,设置ffempg,这里希望能够代码播放flv.
doConfigure() {
    echo "+++ configure start +++"
    
    echo "=== configure end ===\n\n\n"
}

doCMake() {
    echo "\n\n\n+++ cmake start +++"

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
        generateMakeFile
        copyAar
        cmakeFfmpegCliWrapper
        cmakeFfmpegCliWrapperJni
        [[ $? != 0 ]] && echo "configure failed" && exit
        echo ${g_archConfigureTs} 1> ${g_libConfigureTsFilePath}
        # doCMake
    else 
        echo "No need to configure."
    fi

    if [[ ${isMake} == "Y" ]]; then
		echo "Prepare to make..."
		make -C ${platformBuildDir}
		[[ $? != 0 ]] && echo "make failed" && exit
		echo ${g_archMakeTs} 1> ${g_libMakeTsFilePath}
    else 
        echo "No need to make."
    fi

    doFinish

    echo "=== Build ${libId} for ${g_platform} with ${g_arch} finish ===\n\n\n"
}

main





