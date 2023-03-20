#!/bin/sh

export g_arch="arm64-v8a"

# 当前脚本的架构目录
g_scriptArchDir=${g_scriptPlatformDir}/${g_arch}
# 当前Build的架构目录
g_buildArchDir=${g_buildPlatformDir}/${g_arch}
# 安装目录
g_outputArchDir=${g_outputPlatformDir}/${g_arch}

# 环境变量
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"

# host,cc,cxx是必须指定正确的.
host="aarch64-linux-android"
toolChainDir=${g_ndkDir}/toolchains/llvm/prebuilt/darwin-x86_64

# C++编译器
export CXX="${toolChainDir}/bin/${host}${g_apiLevel}-clang++"
# C编译器
export CC="${toolChainDir}/bin/${host}${g_apiLevel}-clang"

export LD="${toolChainDir}/bin/aarch64-linux-android-ld"
export AS="${toolChainDir}/bin/aarch64-linux-android-as"
export LD="${toolChainDir}/bin/aarch64-linux-android-ld"
export NM="${toolChainDir}/bin/aarch64-linux-android-nm"
export STRIP="${toolChainDir}/bin/aarch64-linux-android-strip"
export RANLIB="${toolChainDir}/bin/aarch64-linux-android-ranlib"
export AR="${toolChainDir}/bin/aarch64-linux-android-ar"

export flag=""
g_flag+=" --enable-shared"
g_flag+=" --disable-frontend"
if [[ "${g_configure}" = "debug" ]]; then
    g_flag+=" --enable-debug=alot"
else
    g_flag+=" --enable-debug=no"
fi
g_flag+=" --enable-static=no"
g_flag+=" --host=${host}"
g_flag+=" --prefix=${outputLibDir}"
