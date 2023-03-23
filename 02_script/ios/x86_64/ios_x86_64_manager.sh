#!/bin/sh

#
# android_arm64-v8a_manaager 任务:
# 1 定义android的arm64-v8a有关的变量:
# host,arch,arm64-v8a的交叉编译工具位置.
# 2 如果有必要合并各个arch的库
#

# +++ Description Start +++
# 编译sdl2+ffmpeg
# 整体编译时间
# === Description End ===

# +++ 变量声明 Start+++
# 1 定义配置变量
export g_arch="x86_64"
export g_host="x86_64-apple-darwin"
vendor="apple"
# export CC="xcrun -sdk iphonesimulator clang -arch ${g_arch}"
export CC="xcrun -sdk iphonesimulator clang -target ${g_arch}-${vendor}-ios${g_minSdkVersion}"

# 2 定义目录
# 当前脚本的架构目录
export g_scriptArchDir=${g_scriptPlatformDir}/${g_arch}
# 当前Build的架构目录
export g_buildArchDir=${g_buildPlatformDir}/${g_arch}
# 输出目录
export g_outputArchDir=${g_outputPlatformDir}/${g_arch}

# 环境变量
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"


main () {
    echo "+++ Build for ${g_platform} with ${g_arch} Start +++"

    . ${g_scriptArchDir}/${g_platform}_${g_arch}_lame-3.100.sh $LIB_BUILD_TYPE_CONFIGURE_MAKE
    . ${g_scriptRootDir}/common/CommonBuildLib.sh 

    echo "=== Build for ${g_platform} with ${g_arch} End ===\n\n\n"
}

main





