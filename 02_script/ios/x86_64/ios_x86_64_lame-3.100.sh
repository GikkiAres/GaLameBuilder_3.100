#!/bin/sh
# +++ 变量声明 Start+++
export g_libId="lame-3.100"
# 源码-库目录
export g_sourceLibDir=${g_inputRootDir}/${g_libId}
# 脚本-库目录
g_scriptLibDir=${g_scriptArchDir}/${g_libId}
# Build-库目录
export g_buildLibDir=${g_buildArchDir}/${g_libId}
if [[ ! -e ${g_buildLibDir} ]]; then
    mkdir -p ${g_buildLibDir}
fi

# Output-库目录
export g_outputLibDir=${g_outputArchDir}/${g_libId}
if [[ ! -e ${g_outputLibDir} ]]; then
    mkdir -p ${g_outputLibDir}
fi


# 判断是否要编译和make
export g_libBuildType=$1
echo "libBuildType:${g_libBuildType}"


# 定义configure flag.
export g_flag=""
g_flag+=" --enable-shared"
g_flag+=" --disable-frontend"
if [[ "${g_configure}" = "debug" ]]; then
    g_flag+=" --enable-debug=alot"
else
    g_flag+=" --enable-debug=no"
fi
g_flag+=" --enable-static=no"
g_flag+=" --host=${g_host}"
g_flag+=" --prefix=${g_outputLibDir}"