# 对拍工具

从命令行分别读入 MIPS.py 模拟输出文件和 待check的输出文件

***待check文件需要有时间戳，因为有dm和reg倒序输出的问题，没有时间戳会拍不了***
**支持对$0的过滤，检查$0写入是否为0，会给出警告**

使用方法:

```cmd
python Diff.py stdfile checkfile
```

输出可能结果

- 两文件read over结果 >>>the same<<<
- 一个读完，另一个没有，too much/too few 但是其它部分>>>the same<<<
- 都没读完，报错报告出错行数，请自行找文件对比

