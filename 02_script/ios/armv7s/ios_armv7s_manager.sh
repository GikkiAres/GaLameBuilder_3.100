#!/bin/sh

# +++ 变量声明 Start+++
export g_arch="armv7s"



# 中间目录
g_archConfigureTsFilePath=${g_buildArchDir}/configure.time
g_archMakeTsFilePath=${g_buildArchDir}/make.time

# 判断是否需要再次编译
export archConfigureTs="" 
export archMakeTs=""

# 编译环境变量
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"

# 同一个arch下host是一样的.
export g_host="armv7s-apple-darwin"
vendor="apple"
export g_cc="xcrun -sdk iphoneos clang -target ${g_arch}-${vendor}-ios${g_minSdkVersion}"
# export g_cc="xcrun -sdk iphoneos clang -target arm64-apple-ios${g_minSdkVersion}"

main () {
    echo "\n+++ Build ${g_platform} with ${g_arch} start +++"
	. ${g_scriptArchDir}/ios_armv7s_lame-3.100.sh
    echo "=== Build iOS with ${g_arch} End ===\n"
}




main





