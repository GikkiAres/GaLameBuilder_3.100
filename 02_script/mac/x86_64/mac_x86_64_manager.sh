#!/bin/sh
# +++ Description Start +++
# 编译sdl2+ffmpeg
# 整体编译时间
# === Description End ===

# +++ 用户指定变量 Start+++

# === 用户指定变量 End ===


# +++ 变量声明 Start+++
export g_arch="x86_64"

# 安装目录
archInstallDir=${g_projectDir}/04_Output/${g_platform}/${g_arch}
# 当前脚本的架构目录
g_scriptArchDir=${g_scriptPlatformDir}/${g_arch}
# 当前Build的架构目录
g_buildArchDir=${g_buildPlatformDir}/${g_arch}
g_outputArchDir=${g_outputPlatformDir}/${g_arch}

# 环境变量
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"

# 同一个arch下host是一样的.
vendor="apple"
# 必须小写值
osName="darwin"
#darwin
osVersion=`uname -r`
#20.0.6
# ${g_arch}-${vendor}-${osName}${osVersion}
export g_host="x86_64-apple-darwin"
export g_cc="xcrun -sdk macosx clang"
# build system type:x86_64-apple-darwin20.6.0

main () {
    echo "+++ Build for ${g_platform} with ${g_arch} Start +++"

    . ${g_scriptArchDir}/mac_x86_64_lame-3.100.sh Y Y
    
    echo "=== Build for ${g_platform} with ${g_arch} End ===\n\n\n"
}

main

