#!/bin/sh
#定义配置变量
export g_arch="i386"
export g_host="i386-apple-darwin"
export g_cc="xcrun -sdk iphonesimulator clang -arch i386"


# archScript目录
export g_scriptArchDir="${g_scriptRootDir}/${g_platform}/${g_arch}"

# buildArch目录
export g_buildArchDir="${g_buildConfigureDir}/${g_platform}/${g_arch}"
if [[ ! -e "${g_buildArchDir}" ]]; then 
	mkdir -p ${g_buildArchDir}
fi
# outputArch目录
export g_outputArchDir="${g_outputConfigureDir}/${g_platform}/${g_arch}"
if [[ ! -e "${g_outputArchDir}" ]]; then 
	mkdir -p ${g_outputArchDir}
fi