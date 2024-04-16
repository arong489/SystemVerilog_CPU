
def reverse_dict(d):
    return {v: k for k, v in d.items()}


index_to_reg = {
    "00000" : "$zero",  # 0
    "00001" : "$at",  # 由编译器生成的复合指令使用
    "00010" : "$v0",  # 计算结果和表达式求值
    "00011" : "$v1",
    "00100" : "$a0",  # 参数
    "00101" : "$a1",
    "00110" : "$a2",
    "00111" : "$a3",
    "01000" : "$t0",  # 临时变量
    "01001" : "$t1",
    "01010" : "$t2",
    "01011" : "$t3",
    "01100" : "$t4",
    "01101" : "$t5",
    "01110" : "$t6",
    "01111" : "$t7",
    "10000" : "$s0",  # 保留寄存器
    "10001" : "$s1",
    "10010" : "$s2",
    "10011" : "$s3",
    "10100" : "$s4",
    "10101" : "$s5",
    "10110" : "$s6",
    "10111" : "$s7",  # 更多临时变量
    "11000" : "$t8",
    "11001" : "$t9",
    "11010" : "$k0",
    "11011" : "$k1",
    "11100" : "$gp",  # 全局指针
    "11101" : "$sp",  # 栈指针
    "11110" : "$fp",  # 帧指针
    "11111" : "$ra",  # 返回地址
}

"""
index_to_reg = {
    "00000" : "$ 0",  # 0
    "00001" : "$ 1",  # 由编译器生成的复合指令使用
    "00010" : "$ 2",  # 计算结果和表达式求值
    "00011" : "$ 3",
    "00100" : "$ 4",  # 参数
    "00101" : "$ 5",
    "00110" : "$ 6",
    "00111" : "$ 7",
    "01000" : "$ 8",  # 临时变量
    "01001" : "$ 9",
    "01010" : "$10",
    "01011" : "$11",
    "01100" : "$12",
    "01101" : "$13",
    "01110" : "$14",
    "01111" : "$15",
    "10000" : "$16",  # 保留寄存器
    "10001" : "$17",
    "10010" : "$18",
    "10011" : "$19",
    "10100" : "$20",
    "10101" : "$21",
    "10110" : "$22",
    "10111" : "$23",  # 更多临时变量
    "11000" : "$24",
    "11001" : "$25",
    "11010" : "$26",
    "11011" : "$27",
    "11100" : "$28",  # 全局指针
    "11101" : "$29",  # 栈指针
    "11110" : "$30",  # 帧指针
    "11111" : "$31",  # 返回地址
}
"""

reg_to_index = reverse_dict(index_to_reg)

R_index_to_inst = {
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
}

R_inst_to_index = reverse_dict(R_index_to_inst)

#signal registers that used
R_format = {
    "add"   : 0b111,
    "sub"   : 0b111,
    "and"   : 0b111,
    "or"    : 0b111,
    "nor"   : 0b111,
    "slt"   : 0b111,
    "sltu"  : 0b111,
    "sll"   : 0b011,
    "srl"   : 0b011,
    "jr"    : 0b100,
    "nop"   : 0b000,
    "mult"  : 0b110,
    "multu" : 0b110,
    "div"   : 0b110,
    "divu"  : 0b110,
    "mfhi"  : 0b001,
    "mflo"  : 0b001,
    "mthi"  : 0b100,
    "mtlo"  : 0b100,

}


I_index_to_inst = {
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
}

I_inst_to_index = reverse_dict(I_index_to_inst)

I_format = {
    "sltiu" : "cal",
    "ori"   : "cal",
    "andi"  : "cal",
    "slti"  : "cal",
    "addi"  : "cal",
    "lw"    : "load",
    "sw"    : "store",
    "lh"    : "load",
    "sh"    : "store",
    "lb"    : "load",
    "sb"    : "store",
    "beq"   : "branch",
    "bne"   : "branch",
    "lui"   : "imm",
}

J_index_to_inst = {"000010" : "j", "000011" : "jal"}

J_inst_to_index = reverse_dict(J_index_to_inst)


def zeroEXTnum(binstrnum) :
    return int(binstrnum,2)

def sigEXTnum(binstrnum,orilength="",exlength=32) :
    if orilength == "":
        differ = exlength - len(binstrnum)
    else :
        temp = exlength -len(binstrnum)
        differ = exlength - orilength
        differ = temp if temp < differ else differ 
    if differ < 0 :
        raise SystemError ("the length of num"+binstrnum+f"beyond {exlength:d}")
    else :
        sign = "1" if binstrnum[0] == 1 and (orilength=="" or len(binstrnum)>=orilength) else "0"
        return int((binstrnum[0]*differ)+binstrnum,2)

def zeroEXTnum_hex(hexstrnum:str,exlength=32) :
    if hexstrnum[0] == '-':
        return ((1<<exlength)-1)^((int(hexstrnum[1:],16) if hexstrnum[1:3]=="0x" else int(hexstrnum[1:]))-1)
    else:
        return int(hexstrnum,16) if hexstrnum[:2]=="0x" else int(hexstrnum)

def sigEXTnum_hex(hexstrnum:str,orilength="",exlength=32) :
    if hexstrnum[0] == '-':
        hexstrnum = int(hexstrnum[1:],16) if hexstrnum[1:3] == "0x" else int(hexstrnum[1:])
        return ((1<<exlength)-1)^(hexstrnum-1)
    else :
        if orilength=="" : orilength = (len(hexstrnum)-2)*4 if hexstrnum[:2] == "0x" else len(hexstrnum)*4
        hexstrnum = int(hexstrnum,16) if hexstrnum[:2] == "0x" else int(hexstrnum)
        sign = "1" if hexstrnum&(1<<(orilength-1))!=0 else "0"
        hexstrnum = format(hexstrnum&((1<<exlength)-1),"b")
        distances = exlength - len(hexstrnum)
        return int(sign*distances+hexstrnum,2)

def signed(num:int,length:int=32):
    fullnum = (1<<length)-1
    header = 1<<(length-1)
    num&=fullnum
    if num&header!=0 :
        return -((fullnum^num)+1)
    else:
        return num

def arithmetic_right_shift(num:int,shift:int):
    shift %= 32
    sign =0x100000000 if num & 0x80000000 != 0 else 0
    return (num>>shift)|((sign-1)^((sign>>shift)-1))
