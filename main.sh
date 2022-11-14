### User Configure Start ###
# 用户需要配置的信息
# debug or release
# export g_configure="debug"
export g_configure="release"
# 判断哪些平台需要编译.
platformArray=("ios" "android" "mac" "linux" "windows")
valueArray=("N" "Y" "N" "N" "N")
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


function downloadLame3_100IfNeeded() {
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
    # 存在且不为空,则继续.
    if [[ -e "${targetDir}" ]]; then
        info=$(ls ${targetDir})
        if [[ "${info}" != "" ]]; then
            return 0
        fi
    fi
    mkdir -p $(dirname ${targetDir})
    cmd="git clone git@github.com:GikkiAres/JsShellUtility.git ${targetDir}"
    eval ${cmd}
}

function main() {
    cloneJsShellUtilityIfNeeded
    . ${g_scriptRootDir}/utility/JsShellUtility/DownloadManager-0.0.0.sh
    . ${g_scriptRootDir}/utility/JsShellUtility/SystemManager-0.0.0.sh
    downloadLame3_100IfNeeded
    declare -i length=${#platformArray[@]}
    for ((i = 0; i < ${length}; i++)); do
        key=${platformArray[i]}
        value=${valueArray[i]}
        echo "platfrom: ${key},build: ${value}"
        if [[ "${value}" == "Y" ]]; then
            . ${g_scriptRootDir}/${key}/${key}_manager.sh
            [[ $? != 0 ]] && echo "error" && exit
        fi
    done
}

main
