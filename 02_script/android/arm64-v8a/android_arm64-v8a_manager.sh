#!/bin/sh

# +++ Description Start +++
# 编译sdl2+ffmpeg
# 整体编译时间
# === Description End ===

# +++ 用户指定变量 Start+++

# === 用户指定变量 End ===


# +++ 变量声明 Start+++
export g_arch="arm64-v8a"
# 安装目录
archInstallDir=${g_projectDir}/04_Output/${g_platform}/${g_arch}
# 当前脚本的架构目录
g_scriptArchDir=${g_scriptPlatformDir}/${g_arch}
# 当前Build的架构目录
g_buildArchDir=${g_buildPlatformDir}/${g_arch}
g_outputArchDir=${g_outputPlatformDir}/${g_arch}

# 环境变量
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"


# export ANDROID_API_LEVEL="23"
# export host="aarch64-linux-android"
# export ABI="arm64-v8a"
# export CROSS_COMPILE=${androidNdkBinDir}/${host}-
# export CXX=${androidNdkBinDir}/${host}${ANDROID_API_LEVEL}-clang++
# export commonCC=${androidNdkBinDir}/${host}${ANDROID_API_LEVEL}-clang

# echo "CC is: ${CC}"
# echo "androidNdkBinDir is: ${androidNdkBinDir}"
# echo "host is: ${host}"
# echo "ANDROID_API_LEVEL is: ${ANDROID_API_LEVEL}"
# echo "archInstallDir is: ${archInstallDir}"
# echo "buildArchDir is: ${g_buildArchDir}"
# echo "scriptArchDir is: ${g_scriptArchDir}"

main () {
    echo "+++ Build for ${g_platform} with ${g_arch} Start +++"

    . ${g_scriptArchDir}/android_arm64-v8a_lame-3.100.sh Y Y
    
    echo "=== Build for ${g_platform} with ${g_arch} End ===\n\n\n"
}

main





