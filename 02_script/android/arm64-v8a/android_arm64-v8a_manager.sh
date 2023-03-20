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


# echo "scriptArchDir is: ${g_scriptArchDir}"

main () {
    echo "+++ Build for ${g_platform} with ${g_arch} Start +++"

    . ${g_scriptArchDir}/android_arm64-v8a_lame-3.100.sh N Y
    
    echo "=== Build for ${g_platform} with ${g_arch} End ===\n\n\n"
}

main





