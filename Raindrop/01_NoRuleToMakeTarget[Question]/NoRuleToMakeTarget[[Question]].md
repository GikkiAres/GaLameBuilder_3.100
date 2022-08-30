# 问题名称

NoRuleToMakeTargetCommon.C

# 问题现象

make时,提示:

```
make[2]: *** No rule to make target 

`/Users/gikkiares/Desktop/PP_PersonalProject/Mp02_MyGoalProject/Mp0202_AthenaProject/Mp020202_TinyWindWriter/01_Content/01_Av/01_LameBuilder编译/LameBuilder_3.100/./01_input/lame-3.100/mpglib/common.c', needed by `common.lo'.  Stop.
```

这个提示是说明,当前文件夹下面没有common.c文件.





# 问题分析:

1,Making all in mpglib,表示在make mpglib的all target.

```
all-am maked,

libmpgdecoder.la,

common.h dct64_i386.h decode_i386.h huffman.h interface.h l2tables.h layer1.h layer2.h layer3.h mpg123.h mpglib.h tabinit.h.
```



```
libmpgdecoder_la_OBJECTS:
common.lo dct64_i386.lo decode_i386.lo interface.lo layer1.lo layer2.lo layer3.lo tabinit.lo,,
```

2,这个目录确实不对,和`pwd`的结果不一致.

3,应该是之前编译的中间数据存在,然后切换了目录,再重新编译出现的问题.

4,在那个目录下

```
/Users/gikkiares/Desktop/PP_PersonalProject/Mp02_MyGoalProject/Mp0202_AthenaProject/Mp020202_TinyWindWriter/01_Content/01_Av/01_LameBuilder编译/LameBuilder_3.100/./01_input/lame-3.100/mpglib/common.c
```

这个文件,是确实不存在,所以提示:

```
*** No rule to make target ...
```



# 解决方案:

1,将build目录删除.

2,重新configure/make.