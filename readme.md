# 简单5级流水线CPU仿真

## 内容

这是buaa的计算机组成实验作业，一个支持异常与中断的 5 级流水线 CPU

支持的指令和它的机器码如下:

```py
"001000" : "addi",
"100011" : "lw",
"101011" : "sw",
"000100" : "beq",
"000101" : "bne" ,
"001010" : "slti",
"001011" : "sltiu",
"001111" : "lui",
"001101" : "ori",
"001100" : "andi",
"100001" : "lh"  ,
"101001" : "sh"  ,
"100000" : "lb"  ,
"101000" : "sb"  ,
"100000" : "add",
"100010" : "sub",
"100100" : "and",
"100101" : "or",
"100111" : "nor",
"101010" : "slt",
"101011" : "sltu",
"000000" : "sll",
"000010" : "srl",
"001000" : "jr",
"000000" : "nop",
"011000" : "mult",
"011001" : "multu",
"011010" : "div",
"011011" : "divu",
"010000" : "mfhi",
"010010" : "mflo",
"010001" : "mthi",
"010011" : "mtlo",
"000010" : "j",
"000011" : "jal"
```

## 测试工具

在 buaa-co-tool 中，为了弥补没时间迭代测试工具的中断测试功能，我手搓了几组具有代表性的数据，足以应付课程的正确性要求