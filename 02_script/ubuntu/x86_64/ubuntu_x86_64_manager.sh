#!/bin/sh
export g_arch="x86_64"

# 当前脚本的架构目录
g_scriptArchDir=${g_scriptPlatformDir}/${g_arch}
# 当前Build的架构目录
g_buildArchDir=${g_buildPlatformDir}/${g_arch}
if [[ ! -e "${g_buildArchDir}" ]]; then 
	mkdir -p ${g_buildArchDir}
fi

g_outputArchDir=${g_outputPlatformDir}/${g_arch}
if [[ ! -e "${g_outputArchDir}" ]]; then 
	mkdir -p ${g_outputArchDir}
fi


main () {
    echo "+++ Build for ${g_platform} with ${g_arch} Start +++"
	
	#openssl
    export g_libId="lame-3.100"
	. ${g_scriptArchDir}/${g_platform}_${g_arch}_${g_libId}.sh Y Y
	export PKG_CONFIG_PATH+=":${g_outputArchDir}/${g_libId}/lib/pkgconfig" 

    
    echo "=== Build for ${g_platform} with ${g_arch} End ===\n\n\n"
}

main
