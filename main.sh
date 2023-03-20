### User Configure Start ###
# 用户需要配置的信息
export CONFIGURE_TYPE_DEBUG="debug"
export CONFIGURE_TYPE_RELEASE="release"
export g_configureType=$CONFIGURE_TYPE_RELEASE
# 判断哪些平台需要编译.
# 不编译
export BUILD_FLAG_NO="N"
# 编译
export BUILD_FLAG_YES="Y"
# 判断当前平台是不是该平台,是就编译否则不编译.
export BUILD_FLAG_AUTO="A"
platformArray=("ios" "android" "mac" "linux")
valueArray=($BUILD_FLAG_NO $BUILD_FLAG_YES $BUILD_FLAG_NO $BUILD_FLAG_NO)

### User Configure End ###

# +++ 脚本常量 Start  +++
export LIB_BUILD_TYPE_CONFIGURE="C"
export LIB_BUILD_TYPE_MAKE="M"
export LIB_BUILD_TYPE_IGNORE="I"
export LIB_BUILD_TYPE_CONFIGURE_MAKE="B"
# === 脚本常量 End  ===

# === Lib Build Flag===

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
export g_buildConfigureDir="${g_buildRootDir}/${g_configureType}"
export g_outputConfigureDir="${g_outputRootDir}/${g_configureType}"


function downloadLame3_100IfNeeded() {
    # 库下载地址
    libDownloadUrl="https://udomain.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz"
    # 库id,规则为${libName}-${libVersion}
    libId="lame-3.100"
    # lib压缩包文件路径
    libZipPath="${g_inputRootDir}/${libId}.tar.gz"
    sourceLibPath="${g_inputRootDir}/${libId}"
    downloadZipIfNeeded ${libDownloadUrl} ${libZipPath} ${sourceLibPath}
}

function cloneJsShellUtilityIfNeeded() {
    targetDir="${g_scriptRootDir}/utility/JsShellUtility"
    isDirNotEmpty ${targetDir}
    [[ "$?" = "1" ]] && return;
    mkdir -p `dirname ${targetDir}`
    cmd="git clone git@github.com:GikkiAres/JsShellUtility.git ${targetDir}";
    eval ${cmd}
}

# 判断文件夹是否存在且非空
function isDirNotEmpty() {
    dirPath=$1
    if [[ ! -e "${dirPath}" ]]; then
        echo "dir exists"
        return 0;
    fi
    info=`ls ${dirPath}`
    if [[ "${info}" = "" ]]; then
        echo "dir is empty"
        return 0;
    fi
    return 1;
}



	# 判断哪些平台需要编译.
	# Y,表示编译.
	# N,表示不编译.
	# A,表示自动判断当前系统,当前系统为指定系统就编译.
function buildIfNeeded() {
	declare -i length=${#platformArray[@]}
	for (( i = 0 ; i < ${length} ; i++))
	do
		platform=${platformArray[i]}
		buildFlag=${valueArray[i]}
		echo "platform: ${platform},build: ${buildFlag}"
		if [[ "${buildFlag}" == "Y" ]]; then
			. ${g_scriptRootDir}/${platform}/${platform}_manager.sh
			[[ $? != 0 ]] && echo "error" && exit
        elif [[ "${buildFlag}" == "A" ]]; then
            # 等于key == o
            currentPlatform=""
            if [[ $currentPlatform == $key ]]; then
                . ${g_scriptRootDir}/${platform}/${platform}_manager.sh
            fi
		fi      
	done
}

function main() {
    cloneJsShellUtilityIfNeeded
    . ${g_scriptRootDir}/utility/JsShellUtility/DownloadManager-0.0.0.sh
    . ${g_scriptRootDir}/utility/JsShellUtility/SystemManager-0.0.0.sh
    downloadLame3_100IfNeeded
    buildIfNeeded
}
main
