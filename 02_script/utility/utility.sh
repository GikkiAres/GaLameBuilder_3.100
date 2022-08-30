#!/bin/bash

printCompileEnvironment() {
    echo "CC is: ${CC}"
    echo "CFLAGS is: ${CFLAGS}"
    echo "LDFLAGS is: ${LDFLAGS}"
    echo "PKG_CONFIG_PATH is: ${PKG_CONFIG_PATH}"
}

# 判断是否需要configure或者make
# 需要环境变量 libConfigureTsFilePath archConfigureTs
judgeIsNeedConfigureOrMake () {
	   # 判断是否需要Configure
    # 没有configureTs,则configue+make
    if [[ ! -e ${g_libConfigureTsFilePath} ]]; then 
        echo "No lib configure ts"
        isConfigure="Y"
    else 
		echo "libConfigureTsFilePath is: ${g_libConfigureTsFilePath}"
        libConfigureTs=$(cat ${g_libConfigureTsFilePath})
        echo "Lib configure ts: ${libConfigureTs}\nArch configure ts:${g_archConfigureTs}"
		# libConfig时间>=archConfig时间, 都不用再config
        if [[ "${libConfigureTs}" == "${g_archConfigureTs}" ]]; then
            isConfigure="N"
            echo "Ts time is the same,no need to configure."
		elif [[ "${libConfigureTs}" > "${g_archConfigureTs}"  ]]; then
			isConfigure="N"
            echo "Lib time is bigger,no need to configure."
        else
            isConfigure="Y"
        fi
    fi

    # 判断是否需要Make
    if [[ ${isConfigure} == "Y" ]]; then 
        isMake="Y"
        
    elif [[ ! -e ${g_libMakeTsFilePath} ]]; then
        isMake="Y"
    else 
        libMakeTs=$(cat ${g_libMakeTsFilePath})
        if [[ "${libMakeTs}" == "${g_archMakeTs}" ]]; then
            isMake="N"
			echo "No need to Make."
		elif [[ "${libMakeTs}" > "${g_archMakeTs}"  ]]; then
			isMake="N"
            echo "No need to Make."
        else
            isMake="Y"
        fi
    fi
}

# 导出该函数,子shell也能使用.
export -f judgeIsNeedConfigureOrMake
export -f printCompileEnvironment