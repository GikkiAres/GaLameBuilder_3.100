
export g_platform="ios"
export g_inputPlatformDir="${g_inputRootDir}/${g_platform}"
export g_scriptPlatformDir="${g_scriptRootDir}/${g_platform}"
export g_buildPlatformDir="${buildRootDir}/${g_platform}"
export g_outputPlatformDir="${outputRootDir}/${g_platform}"

#不同的架构, 有不同的C编译器和Host值
 # 指定host和cc
 # arm64)
export g_minSdkVersion="10.0"

# armv7)
# export CC="xcrun -sdk iphoneos  clang -target armv7-apple-ios10.0"
# export host="arm-apple-darwin"
# # x86_64)
# export CC="xcrun -sdk iphonesimulator  clang -target x86_64-apple-ios10.0"
# export host="x86_64-apple-darwin"
# # x86)
# export CC="xcrun -sdk iphonesimulator  clang -target i386-apple-ios10.0"
# export host="i386-apple-darwin"


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

archs="arm64 armv7s x86_64 i386"
. ${g_projectDir}/02_Script/ios/arm64/ios_arm64_manager.sh
. ${g_projectDir}/02_Script/ios/armv7s/ios_armv7s_manager.sh
. ${g_projectDir}/02_Script/ios/x86_64/ios_x86_64_manager.sh
. ${g_projectDir}/02_Script/ios/i386/ios_i386_manager.sh
#合并Thin->Fat

outputPlatformFatDir=${g_outputArchDir}/fat
if [[ ! -e ${outputPlatformFatDir} ]]; then
	mkdir -p ${outputPlatformFatDir}
fi

# Todo.


