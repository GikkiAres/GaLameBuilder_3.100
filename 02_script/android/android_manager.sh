# platform级别的变量定义
export g_platform="android"
export g_inputPlatformDir="${g_inputRootDir}/${g_platform}"
export g_scriptPlatformDir="${g_scriptRootDir}/${g_platform}"
export g_buildPlatformDir="${g_buildConfigureDir}/${g_platform}"
export g_outputPlatformDir="${g_outputConfigureDir}/${g_platform}"


#不同的架构, 有不同的C编译器和Host值
 # 指定host和cc
 # arm64)
 # 安卓ndk中,不同版本的工具链放在不同的文件夹中.
export g_apiLevel="21"
# 设置安卓编译需要的ndkRoot
export g_ndkDir="/Users/gikkiares/Desktop/Lsh_LocalSoftwareHierachy/Sh01_Programming/06_Ndk/android-ndk-r21e"


function mergeThinToFat() {
    echo "Merge,begin"
    #创建胖子库/lib文件夹
    mkdir -p $fatDirPath/lib
    set - $archs
    cd $thinDirPath/$1/lib
    for libName in *.a
    do
        # 针对当前目录的每一个.a文件,从thinDir中,寻找同名的,进行合并
        # 放到变量之中后,变成一个字符串了,而不是数组.
        thinLibPath=`find $thinDirPath -name $libName`
        printVarOfName thinLibPath
        lipo -create `find $thinDirPath -name $libName` -output $fatDirPath/lib/$libName
    done

    # 复制头文件到fatDirPath/include下
    cp -rf $thinDirPath/$1/include $fatDirPath

    echo "Merge,compete"
}

#键值,两个数组.
archArray=("arm64-v8a" "armabi-v7a")
valueArray=("N" "Y")
# echo "${archMap[*]}"
declare -i length=${#archArray[@]}
for (( i = 0 ; i < ${length} ; i++))
do
	arch=${archArray[i]}
	value=${valueArray[i]}
	echo "arch: ${arch},build: ${value}"
	if [[ "${value}" == "Y" ]]; then
		. ${g_scriptPlatformDir}/${arch}/android_${arch}_manager.sh
		[[ $? != 0 ]] && echo "error" && exit
	fi
done
isMerge="N"
if [[ "${isMerge}" == "Y" ]]; then
	#Merge
	echo "merge."
fi



