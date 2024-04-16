import sys
sys.path.append('.')
from random import randint,sample
from MIPS.Excute import OutAccess as simulate
from MIPS.RegFile import RegFile

def reverse_dict(d):
    return {v: k for k, v in d.items()}


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
    "addi"  : "cal",
    "lw"    : "load",
    "sw"    : "store",
    "lh"    : "load",
    "sh"    : "store",
    "lb"    : "load",
    "sb"    : "store",
    "beq"   : "branch",
    "bne"   : "branch",
    "slti"  : "cal",
    "sltiu" : "cal",
    "lui"   : "imm",
    "ori"   : "cal",
    "andi"  : "cal",
}

J_index_to_inst = {"000010" : "j", "000011" : "jal"}

J_inst_to_index = reverse_dict( J_index_to_inst )

Cal_ins_list = [
    "add",  "sub",  "and",  "or",   "slt",  "sltu", 
    "mult", "multu","div",  "divu", "mfhi", "mflo", "mthi", "mtlo",
    "mult", "multu","mfhi", "mflo", "mthi", "mtlo",
    "addi", "lui",  "ori",  "andi"
]

def getReg(num:int=1,br:int=0,er:int=31,module:int=0) :
    if module==1 :
        middle=br
        span=er
        br=middle-span
        er=middle+span
    if num == 1:
        return format(randint(br,er),"05b")
    elif num > 1:
        reglist = []
        for i in range(num) :
            precheck=format(randint(br,er),"05b")
            while precheck in reglist :
                precheck=format(randint(br,er),"05b")
            reglist.append(precheck)
        return reglist

def getImm(num:int=1,base:int=4,Maxrange:int=0xc00,binaryLength:int=16,sign:int=2) :
    '''
    para:
        num         : imm prodeduce num
        base        : for example imm base 4 or 2 or 1
        Maxrange    : the MAX abs value
        binaryLength: attention! it will also limit Imm , it is always bigger than Maxrange 
        sign        : 0 for plus ; 1 for mins ; 2 for both OK
    '''
    if num==1 :
        randnumstr = format(randint(0,Maxrange)*base,f"0{binaryLength}b")
        if sign == 0 :return "0"+randnumstr[1:binaryLength]
        elif sign == 1: return "1"+randnumstr[1:binaryLength]
        else : return randnumstr[:binaryLength]
    elif num>1 :
        numlist=[]
        for i in range(num):
            randnumstr = format(randint(0,Maxrange)*base,f"0{binaryLength}b")
            if sign == 0 :numlist.append("0"+randnumstr[1:binaryLength]) 
            elif sign == 1: numlist.append("1"+randnumstr[1:binaryLength])
            else : numlist.append(randnumstr[:binaryLength])
        return numlist

def getRIns(funct:str,regs:list)->str:
    '''
    parameters:
        funct:funct name,please check if it is registered
        regs: the regs range we wanted
        shamet:
    return:
        a hex num ins str which's the length is eight
    '''
    if type(funct) is str and funct in R_index_to_inst.values():
        if type(regs) is str : regs = [regs]
        if R_format[funct] == 0b111:
            rs,rt,rd=sample(regs*18,3)
            return "{:06d}{:5s}{:5s}{:5s}{:05d}{:6s}".format(
                0,
                rs,
                rt,
                rd,
                0,
                R_inst_to_index[funct]
            )
        elif R_format[funct] == 0b011:
            rt,rd=sample(regs*18,2)
            shamet = getImm(1,1,32,5)
            return "{:06d}{:05d}{:5s}{:5s}{:5s}{:6s}".format(
                0,
                0,
                rt,
                rd,
                shamet,
                R_inst_to_index[funct]
            )
        elif R_format[funct]==0b100:
            rs=sample(regs*18,1)[0]
            return "{:06d}{:5s}{:05d}{:05d}{:05d}{:6s}".format(
                0,
                rs,
                0,
                0,
                0,
                R_inst_to_index[funct]
            )
        elif R_format[funct]==0b000:
            return "{:032b}".format(0)
        elif R_format[funct]==0b110:
            rs,rt=sample(regs*18,2)
            if funct=="div" or funct=="divu" or funct=='mult' or funct == 'multu':
                R_rs,R_rt=RegFile.read([rs,rt])
                while R_rs==0 or R_rt==0:
                    rs,rt=sample(regs*18,2)
                    R_rs,R_rt=RegFile.read([rs,rt])
            return "{:06d}{:5s}{:5s}{:05d}{:05d}{:6s}".format(
                0,
                rs,
                rt,
                0,
                0,
                R_inst_to_index[funct]
            )
        elif R_format[funct]==0b001:
            rd=sample(regs*18,1)[0]
            return "{:06d}{:05d}{:05d}{:5s}{:05d}{:6s}".format(
                0,
                0,
                0,
                rd,
                0,
                R_inst_to_index[funct]
            )
        elif R_format[funct]==0b100:
            rs=sample(regs*18,1)[0]
            return "{:06d}{:5s}{:05d}{:05d}{:05d}{:6s}".format(
                0,
                rs,
                0,
                0,
                0,
                R_inst_to_index[funct]
            )
def getIIns(funct,regs,care:int=2):
    if type(regs) is str : regs = [regs]
    if type(funct) is str and funct in I_index_to_inst.values():
        if I_format[funct]=="cal" or I_format[funct]=="load" or I_format[funct]=="store" or I_format[funct]=="branch":
            rs,rt = sample(regs*18,2)
            if I_format[funct]=="branch":
                imm = getImm(1,1,10,16,0)
            elif I_format[funct]=="load" or I_format[funct]=="store":
                if funct[-1] == "w":
                    tailchecker=0x3
                elif funct[-1] == "h":
                    tailchecker=0x1
                else : tailchecker=0
                baseAddr = RegFile.read(rs)
                imm = getImm(1,1,0xff,16)
                checkDMAddr = (baseAddr+int(imm,2))&0xffffffff
                while ((checkDMAddr&80000000) != 0 or checkDMAddr >= 0x3000 or (checkDMAddr&tailchecker) != 0):
                    rs = sample(regs*18,1)[0]
                    baseAddr = RegFile.read(rs)
                    imm = getImm(1,1,0xff,16)
                    checkDMAddr = (baseAddr+int(imm,2))&0xffffffff
            elif I_format [funct]=="cal":
                imm = getImm(1,1,0xffff,16,care)
            return "{:6s}{:5s}{:5s}{:16s}".format(
                I_inst_to_index[funct],
                rs,
                rt,
                imm
            )
        elif I_format[funct]=="imm":
            rt = sample(regs*18,1)[0]
            imm = getImm(1,1,0xffff,16,care)
            return "{:6s}{:05d}{:5s}{:16s}".format(
                I_inst_to_index[funct],
                0,
                rt,
                imm
            )
def getJIns(funct,imm_26):
    if type(funct) is str and funct in J_index_to_inst.values():
        return "{:6s}{:26s}".format(
            J_inst_to_index[funct],
            imm_26
        )

def HexIndex(binaryIndex,hexlength=8):
    return format(int(binaryIndex,2),f"0{hexlength}x")

def fullReg(regIndex:str,care:int=2):
    '''
    para:
        regIndex:the index of the reg wait to full
        care    : 0 for plus ; 1 for mins ; 2 both OK
    '''
    inslist = []
    inslist.append(HexIndex(getIIns("lui",regIndex,care)))
    inslist.append(HexIndex(getIIns("ori",regIndex)))
    simulate(inslist)
    return inslist

def getCalIns(regs:list|tuple,num:int=1):
    if num == 1:
        funct=sample(Cal_ins_list*18,1)[0]
        if funct in R_index_to_inst.values():
            ins = HexIndex(getRIns(funct,regs))
            simulate(ins)
            return ins
        else :
            ins = HexIndex(getIIns(funct,regs))
            simulate(ins)
            return ins
    if num > 1:
        inslist = []
        functs=sample(Cal_ins_list*4000,num)
        for funct in functs:
            if funct in R_index_to_inst.values():
                ins = HexIndex(getRIns(funct,regs))
                simulate(ins)
                inslist.append(ins)
            else :
                ins = HexIndex(getIIns(funct,regs))
                simulate(ins)
                inslist.append(ins)
        return inslist