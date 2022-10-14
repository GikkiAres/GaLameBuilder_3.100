# platform级别的变量定义
export g_platform="ubuntu"
export g_inputPlatformDir="${g_inputRootDir}/${g_platform}"
export g_scriptPlatformDir="${g_scriptRootDir}/${g_platform}"
export g_buildPlatformDir="${g_buildConfigureDir}/${g_platform}"
export g_outputPlatformDir="${g_outputConfigureDir}/${g_platform}"

#不同的架构, 有不同的C编译器和Host值
 # 指定host和cc
 # arm64)
export g_host="x86_64-pc-linux-gnu"
export g_cc="gcc"
export g_cxx="g++"
export g_minSdkVersion="10.0"


# 判断哪些架构需要编译.
archArray=("x86_64")
valueArray=("Y")
# echo "${archMap[*]}"
declare -i length=${#archArray[@]}
for (( i = 0 ; i < ${length} ; i++))
do
	arch=${archArray[i]}
	value=${valueArray[i]}
	echo "arch: ${arch},build: ${value}"
	if [[ "${value}" == "Y" ]]; then
		. ${g_scriptPlatformDir}/${arch}/${g_platform}_${arch}_manager.sh
		[[ $? != 0 ]] && echo "error" && exit
	fi
done
isMerge="N"
if [[ "${isMerge}" == "Y" ]]; then
	#Merge
	echo "merge."
fi
