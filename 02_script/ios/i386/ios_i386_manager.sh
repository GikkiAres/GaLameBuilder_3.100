#!/bin/sh

# +++ Description Start +++
# 编译sdl2+ffmpeg
# 整体编译时间
# === Description End ===

# +++ 用户指定变量 Start+++

# === 用户指定变量 End ===


# +++ 变量声明 Start+++
export g_arch="i386"

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

# 中间目录
g_archConfigureTsFilePath=${g_buildArchDir}/configure.time
g_archMakeTsFilePath=${g_buildArchDir}/make.time

# 判断是否需要再次编译
export g_archConfigureTs="" 
export g_archMakeTs=""

# 编译环境变量
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"

# 同一个arch下host是一样的.
export g_host="i386-apple-darwin"
export g_cc="xcrun -sdk iphonesimulator clang -arch i386"

main () {
    echo "\n\n\n+++ Build ${g_platform} with ${g_arch} start +++"

  	if [[ ! -e ${g_archConfigureTsFilePath} ]]; then 
        g_archConfigureTs=$(date "+%Y-%m-%d %H:%M:%S")
        echo ${g_archConfigureTs}  1> ${g_archConfigureTsFilePath}
        if [[ -e ${g_archMakeTsFilePath} ]]; then
            rm ${g_archMakeTsFilePath}
        fi
    else 
        g_archConfigureTs=$(cat ${g_archConfigureTsFilePath})
    fi

    if [[ ! -e ${g_archMakeTsFilePath} ]]; then 
        g_archMakeTs=$(date "+%Y-%m-%d %H:%M:%S")
        echo ${g_archMakeTs}  1> ${g_archMakeTsFilePath} 
    else 
        g_archMakeTs=$(cat ${g_archMakeTsFilePath})
    fi
	
    . ${g_scriptArchDir}/ios_i386_lame_3.100.sh
    echo "=== Build iOS with ${g_arch} End ===\n\n\n"
}




main





