#!/bin/sh

# +++ Description Start +++
# 编译sdl2+ffmpeg
# 整体编译时间
# === Description End ===

# +++ 用户指定变量 Start+++

# === 用户指定变量 End ===


# +++ 变量声明 Start+++
export g_arch="arm64"

# archScript目录
export g_scriptArchDir="${g_scriptRootDir}/${g_platform}/${g_arch}"
export g_buildArchDir="${g_buildConfigureDir}/${g_platform}/${g_arch}"
if [[ ! -e "${g_buildArchDir}" ]]; then 
	mkdir -p ${g_buildArchDir}
fi

export g_outputArchDir="${g_outputConfigureDir}/${g_platform}/${g_arch}"
if [[ ! -e "${g_outputArchDir}" ]]; then 
	mkdir -p ${g_outputArchDir}
fi


# 编译环境变量
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"

# 同一个arch下host是一样的.
export g_host="aarch64-apple-darwin"
export g_cc="xcrun -sdk iphoneos clang -target ${g_arch}-${vendor}-ios${g_minSdkVersion}"
# export g_cc="xcrun -sdk iphoneos clang -target arm64-apple-ios${g_minSdkVersion}"

main () {
    echo "\n+++ Build ${g_platform} with ${g_arch} start +++"
    . ${g_scriptArchDir}/ios_arm64_lame-3.100.sh Y Y
    echo "=== Build iOS with ${g_arch} End ===\n"
}




main
