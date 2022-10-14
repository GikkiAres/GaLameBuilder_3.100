### User Configure Start ###
# 用户需要配置的信息
# debug or release
# export g_configure="debug"
export g_configure="release"

### User Configure End ###

# +++ Variable Start +++
# 全局地址
export g_projectDir=$(pwd)/$(dirname $0)
export g_inputRootDir=${g_projectDir}/01_input
if [[ ! -e ${g_inputRootDir} ]]; then
    mkdir -p ${g_inputRootDir}
fi

export g_scriptRootDir=${g_projectDir}/02_script
export g_buildRootDir=${g_projectDir}/03_build
export g_outputRootDir=${g_projectDir}/04_output
export g_utilityDir="${g_scriptRootDir}/utility"
export g_buildConfigureDir="${g_buildRootDir}/${g_configure}"
export g_outputConfigureDir="${g_outputRootDir}/${g_configure}"

# 程序内部的变量
# 库下载地址
libDownloadUrl="https://udomain.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz"
# 库id,规则为${libName}-${libVersion}
libId="lame-3.100"
# lib压缩包文件路径
libZipPath="${g_inputRootDir}/${libId}.tar.gz"
sourceLibPath="${g_inputRootDir}/${libId}"
# === Variable End ===

function downloadIfNeeded() {
    if [[ ! -e "${g_inputRootDir}/${libId}" ]]; then
        if [[ ! -e "${libZipPath}" ]]; then
            echo "downloading ${libId}..."
            curl -o "${libZipPath}" "${libDownloadUrl}"
            [[ $? != 0 ]] && echo "download failed" && exit
        fi
        echo "uncompress ${libId}..."
        tar zxvf ${libZipPath}  -C "${g_inputRootDir}"
        [[ $? != 0 ]] && echo "uncompress failed" && exit
    else
        echo "lib ${libId} existed."
    fi

}

function isMac() {
    info=`uname`
    if [[ ${info} == "Darwin" ]]; then
        echo "Y";
    else 
        echo "N";
    fi
}

function isCentOs() {
    info=`cat /etc/redhat-release`
    result=`echo ${info} | grep CentOS`
    if [[ "${result}" != "" ]]; then
        echo "Y";
    else 
        echo "N";
    fi
}

function isUbuntuOs() {
    result=`cat /etc/issue | grep Ubuntu`
    if [[ "${result}" != "" ]]; then 
        echo "Y";
    else
        echo "N";
    fi
}


	# 判断哪些平台需要编译.
	# Y,表示编译.
	# N,表示不编译.
	# A,表示自动判断当前系统,当前系统为指定系统就编译.
function buildIfNeeded() {
	platformArray=("ios" "android" "mac" "centos" "ubuntu")
	isBuildMac=`isMac`
	isBuildCentOs=`isCentOs`
	isBuildUbuntu=`isUbuntuOs`
	valueArray=("N" "N" ${isBuildMac} ${isBuildCentOs} ${isBuildUbuntu})
	declare -i length=${#platformArray[@]}
	for (( i = 0 ; i < ${length} ; i++))
	do
		key=${platformArray[i]}
		value=${valueArray[i]}
		echo "platform: ${key},build: ${value}"
		if [[ "${value}" == "Y" ]]; then
			. ${g_scriptRootDir}/${key}/${key}_manager.sh
			[[ $? != 0 ]] && echo "error" && exit
		fi      
	done
}

function main() {
    downloadIfNeeded
    buildIfNeeded
}

main
