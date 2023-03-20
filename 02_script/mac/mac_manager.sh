# 配置信息 Start #
archArray=("x86_64")
archBuildFlagArray=($BUILD_FLAG_YES)
# 配置信息 End #

export g_platform="mac"
export g_inputPlatformDir="${g_inputRootDir}/${g_platform}"
export g_scriptPlatformDir="${g_scriptRootDir}/${g_platform}"
export g_buildPlatformDir="${g_buildConfigureDir}/${g_platform}"
export g_outputPlatformDir="${g_outputConfigureDir}/${g_platform}"


export g_minSdkVersion="10.0"



declare -i length=${#archArray[@]}
for ((i = 0; i < ${length}; i++)); do
    arch=${archArray[i]}
    archBuildFlag=${archBuildFlagArray[i]}
    echo "arch:${arch},archBuildFlag:${archBuildFlag}"
    if [[ "${archBuildFlag}" == $BUILD_FLAG_YES ]]; then
         . "${g_projectDir}/02_Script/${g_platform}/${arch}/${g_platform}_${arch}_config.sh"
         . "${g_projectDir}/02_Script/${g_platform}/${g_platform}_build_lame-3.100.sh" $LIB_BUILD_TYPE_CONFIGURE_MAKE
    fi
done


function mergeThinToFat() {
    echo "Merge,begin"

    fatDir=${g_outputPlatformDir}/fat
    if [[ ! -e ${fatDir} ]]; then
        mkdir -p ${fatDir}
    fi
    mkdir -p $fatDir/lib
    # ls的结果是空格分开的,可以用for in迭代.
    archArray=`ls $g_outputPlatformDir | grep -v "fat"`
    # 分割字符串并设置位置参数,但是好像不加--也可以.
    set -- $archArray
    
    # 复制头文件到fatDir
    cp -rf $g_outputPlatformDir/$1/lame-3.100/include $fatDir

    cd $g_outputPlatformDir/$1/lame-3.100/lib
    for libName in *.a; do
        # 针对当前目录的每一个.a文件,从thinDir中,寻找同名的,进行合并
        # 放到变量之中后,变成一个字符串了,而不是数组.
        thinLibPath=$(find $g_outputPlatformDir -name $libName)
        echo "thinLibPath is: $thinLibPath"
        lipo -create $(find $g_outputPlatformDir -name $libName) -output $fatDir/lib/$libName
    done

    echo "Merge,compete"
}

isMerge=$BUILD_FLAG_YES

#合并Thin->Fat,.执行合并操作.
if [[ $isMerge == $BUILD_FLAG_YES ]]; then
    items=`ls ${g_outputPlatformDir}`
    # 去掉fat文件夹的文件夹的个数.
    itemCount=`ls -l ${g_outputPlatformDir} |grep "^d" | grep -v "fat" |wc -l`
    if [[ $itemCount -ge "2" ]]; then
        mergeThinToFat
    fi
fi
