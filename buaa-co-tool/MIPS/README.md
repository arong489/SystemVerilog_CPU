# MIPS CPU 模拟器

该 MIPS CPU 读入 8 位 16 进制指令
并输出对于 reg 和 ram 读写的结果和当前 PC 值

使用方式：

```cmd
python Simulator.py code.txt
```

输出格式：

* 写 reg
  * print(f"@{PC:0>8x}: ${wAddr:2d} <= {wData:0>8x}")
  * e.g. @00003000: $ 1 <= ffffffff
* 写 ram
  * print(f"@{PC:0>8x}: *{wAddr:0>8x} <= {wData:0>8x}")
  * e.g. @00003000: *00000000 <= ffffffff

## P5

### 指令集：

`add`, `sub`, `ori`, `lw`, `sw`, `beq`, `lui`, `jal`, `jr`, `nop`

### 寄存器与地址空间

* reg[31:0]
  * 其中 `0` 号寄存器保持 `0` 值，忽略写入
  * 其中 `1` 号寄存器值随时可能被汇编器修改

* IM[4095:0] [32]
  * 对应地址 [0x00003000,0x00006ffc)

* DM[3071:0] [32]
  * 对应地址 [0x00000000,0x00003000)