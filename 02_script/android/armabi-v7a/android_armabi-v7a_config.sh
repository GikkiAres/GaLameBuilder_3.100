#!/bin/sh

export g_arch="armabi-v7a"

# 当前脚本的架构目录
g_scriptArchDir=${g_scriptPlatformDir}/${g_arch}
# 当前Build的架构目录
g_buildArchDir=${g_buildPlatformDir}/${g_arch}
# 安装目录
g_outputArchDir=${g_outputPlatformDir}/${g_arch}

# 环境变量
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"

# host,cc,cxx是必须指定正确的.
host="armv7a-linux-androideabi"
toolChainDir=${g_ndkDir}/toolchains/llvm/prebuilt/darwin-x86_64

# C++编译器
export CXX="${toolChainDir}/bin/${host}${g_apiLevel}-clang++"
# C编译器
export CC="${toolChainDir}/bin/${host}${g_apiLevel}-clang"

export LD="${toolChainDir}/bin/arm-linux-androideabi-ld"
export AS="${toolChainDir}/bin/arm-linux-androideabi-as"
export LD="${toolChainDir}/bin/arm-linux-androideabi-ld"
export NM="${toolChainDir}/bin/arm-linux-androideabi-nm"
export STRIP="${toolChainDir}/bin/arm-linux-androideabi-strip"
export RANLIB="${toolChainDir}/bin/arm-linux-androideabi-ranlib"
export AR="${toolChainDir}/bin/arm-linux-androideabi-ar"

export g_flag=""
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
