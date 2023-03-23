# 配置变量 Start #
archArray=("arm64-v8a" "armabi-v7a")
archBuildFlagArray=($BUILD_FLAG_NO $BUILD_FLAG_YES)
# 配置变量 End #


#
# AndroidManager的任务:
# 1 负责导入各个arch的config文件,然后执行各个arch的manager文件
# 2 如果有必要合并各个arch的库
#

# platform级别的变量定义
export g_platform="android"
export g_inputPlatformDir="${g_inputRootDir}/${g_platform}"
export g_scriptPlatformDir="${g_scriptRootDir}/${g_platform}"
export g_buildPlatformDir="${g_buildConfigureDir}/${g_platform}"
export g_outputPlatformDir="${g_outputConfigureDir}/${g_platform}"


#不同的架构, 有不同的C编译器和Host值
# 安卓ndk中,不同api的工具链放在不同的文件夹中.
export g_apiLevel="21"
# 设置安卓编译需要的ndkRoot
export g_ndkDir="/Users/gikkiares/Desktop/Lsh_LocalSoftwareHierachy/Sh01_Programming/06_Ndk/android-ndk-r21e"


# echo "${archMap[*]}"
declare -i length=${#archArray[@]}
for ((i = 0; i < ${length}; i++)); do
    arch=${archArray[i]}
    archBuildFlag=${archBuildFlagArray[i]}
    echo "arch:${arch},archBuildFlag:${archBuildFlag}"
    if [[ "${archBuildFlag}" == $BUILD_FLAG_YES ]]; then
         . ${g_projectDir}/02_Script/${g_platform}/${arch}/${g_platform}_${arch}_manager.sh
    fi
done



