# PC值除了跳转外不用特意维护
import sys
sys.path.append('.')
from MIPS.PC import PC
from MIPS.DM import DM
from MIPS.RegFile import RegFile
from MIPS.Define import zeroEXTnum_hex,sigEXTnum_hex,signed
import re

class ExCute:
    def __init__(self) -> None:
        raise SystemError("it's static class!!!")
    
    __OutputEnable = True

    @classmethod
    def outconfig(cls,ifoutput:bool=True):
        if ifoutput :cls.__OutputEnable = True
        else : cls.__OutputEnable = False
        PC.outconfig(ifoutput)
        DM.outconfig(ifoutput)
        RegFile.outconfig(ifoutput)
    
    @staticmethod
    def __slipt_code(code:str):
        return (i for i in re.split("[\\s,()]",code) if i!="")
    @staticmethod
    def __delaying(enalble=True,link=False):
        if __name__=='__main__' :
            if ExCute.__OutputEnable :print("")
        if __name__!='__main__' and enalble :
            if link == False : PC.next()
            ExCute.run(PC.getInstruct())

    @staticmethod
    def __add(source:str):
        rd,rs,rt=ExCute.__slipt_code(source)
        A,B=RegFile.read([rs,rt])
        RegFile.write(rd,A+B)
    @staticmethod
    def __sub(source:str):
        rd,rs,rt=ExCute.__slipt_code(source)
        A,B=RegFile.read([rs,rt])
        RegFile.write(rd,A-B)
    @staticmethod
    def __and(source:str):
        rd,rs,rt=ExCute.__slipt_code(source)
        A,B=RegFile.read([rs,rt])
        RegFile.write(rd,A&B)
    @staticmethod
    def __or(source:str):
        rd,rs,rt=ExCute.__slipt_code(source)
        A,B=RegFile.read([rs,rt])
        RegFile.write(rd,A|B)
    @staticmethod
    def __nor(source:str):
        rd,rs,rt=ExCute.__slipt_code(source)
        A,B=RegFile.read([rs,rt])
        RegFile.write(rd,0xffffffff^(A|B))
    @staticmethod
    def __slt(source:str):
        rd,rs,rt=ExCute.__slipt_code(source)
        A,B=RegFile.read([rs,rt])
        ans = 1 if signed(A)<signed(B) else 0
        RegFile.write(rd,ans)
    @staticmethod
    def __sltu(source:str):
        rd,rs,rt=ExCute.__slipt_code(source)
        A,B=RegFile.read([rs,rt])
        ans = 1 if A<B else 0
        RegFile.write(rd,ans)
    @staticmethod
    def __sll(source:str):
        rd,rt,shamet=ExCute.__slipt_code(source)
        B=RegFile.read(rt)
        A=zeroEXTnum_hex(shamet)%32
        RegFile.write(rd,B<<A)
    @staticmethod
    def __srl(source:str):
        rd,rt,shamet=ExCute.__slipt_code(source)
        B=RegFile.read(rt)
        A=zeroEXTnum_hex(shamet)%32
        RegFile.write(rd,B>>A)
    @staticmethod
    def __jr(source:str):
        rs = source.strip()
        nPC = RegFile.read(rs)
        # 延迟槽
        ExCute.__delaying()

        PC.next(nPC)
    @staticmethod
    def __mult(source:str):
        rs,rt=ExCute.__slipt_code(source)
        A=RegFile.read(rs)
        B=RegFile.read(rt)
        temp=zeroEXTnum_hex(str(signed(A)*signed(B)),64)
        RegFile.special_write(("hi","lo"),(temp>>32,temp&0xffffffff))
    @staticmethod
    def __multu(source:str):
        rs,rt=ExCute.__slipt_code(source)
        A=RegFile.read(rs)
        B=RegFile.read(rt)
        temp= A*B
        RegFile.special_write(("hi","lo"),(temp>>32,temp&0xffffffff))
    @staticmethod
    def __div(source:str):
        rs,rt=ExCute.__slipt_code(source)
        A=signed(RegFile.read(rs))
        B=signed(RegFile.read(rt))
        sig=(A<0)!=(B<0)
        absA=abs(A)
        absB=abs(B)
        lo = zeroEXTnum_hex(str(-(absA//absB) if sig else (absA//absB)),32)
        hi = A - B*lo
        RegFile.special_write(("hi","lo"),(hi,lo))
    @staticmethod
    def __divu(source:str):
        rs,rt=ExCute.__slipt_code(source)
        A=RegFile.read(rs)
        B=RegFile.read(rt)
        RegFile.special_write(("hi","lo"),(A%B,A//B))
    @staticmethod
    def __mfhi(source:str):
        rd=source.replace(" ","")
        RegFile.write(rd,RegFile.special_read("hi"))
    @staticmethod
    def __mflo(source:str):
        rd=source.replace(" ","")
        RegFile.write(rd,RegFile.special_read("lo"))
    @staticmethod
    def __mthi(source:str):
        rs=source.replace(" ","")
        RegFile.special_write("hi",RegFile.read(rs))
    @staticmethod
    def __mtlo(source:str):
        rs=source.replace(" ","")
        RegFile.special_write("lo",RegFile.read(rs))

    @staticmethod
    def __addi(source:str):
        rt,rs,imm=ExCute.__slipt_code(source)
        A=RegFile.read(rs)
        B=sigEXTnum_hex(imm,16)
        RegFile.write(rt,A+B)
    @staticmethod
    def __slti(source:str):
        rt,rs,imm=ExCute.__slipt_code(source)
        A=RegFile.read(rs)
        B=zeroEXTnum_hex(imm,5)
        ans = 1 if signed(A)<signed(B) else 0
        RegFile.write(rt,ans)
    @staticmethod
    def __sltiu(source:str):
        rt,rs,imm=ExCute.__slipt_code(source)
        A=RegFile.read(rs)
        B=zeroEXTnum_hex(imm,5)
        ans = 1 if A<B else 0
        RegFile.write(rt,ans)
    @staticmethod
    def __ori(source:str):
        rt,rs,imm=ExCute.__slipt_code(source)
        A=RegFile.read(rs)
        B=zeroEXTnum_hex(imm)
        RegFile.write(rt,A|B)
    @staticmethod
    def __andi(source:str):
        rt,rs,imm=ExCute.__slipt_code(source)
        A=RegFile.read(rs)
        B=zeroEXTnum_hex(imm)
        RegFile.write(rt,A&B)
    @staticmethod
    def __lw(source:str):
        rt,imm,rs=ExCute.__slipt_code(source)
        addr=RegFile.read(rs)+sigEXTnum_hex(imm,16)
        RegFile.write(rt,DM.read(addr))
    @staticmethod
    def __sw(source:str):
        rt,imm,rs=ExCute.__slipt_code(source)
        addr=RegFile.read(rs)+sigEXTnum_hex(imm,16)
        DM.write(addr,RegFile.read(rt))
    @staticmethod
    def __lh(source:str):
        rt,imm,rs=ExCute.__slipt_code(source)
        addr=RegFile.read(rs)+sigEXTnum_hex(imm,16)
        RegFile.write(rt,DM.read(addr,2))
    @staticmethod
    def __sh(source:str):
        rt,imm,rs=ExCute.__slipt_code(source)
        addr=RegFile.read(rs)+sigEXTnum_hex(imm,16)
        DM.write(addr,RegFile.read(rt),2)
    @staticmethod
    def __lb(source:str):
        rt,imm,rs=ExCute.__slipt_code(source)
        addr=RegFile.read(rs)+sigEXTnum_hex(imm,16)
        RegFile.write(rt,DM.read(addr,1))
    @staticmethod
    def __sb(source:str):
        rt,imm,rs=ExCute.__slipt_code(source)
        addr=RegFile.read(rs)+sigEXTnum_hex(imm,16)
        DM.write(addr,RegFile.read(rt),1)
    @staticmethod
    def __beq(source:str):
        rt,rs,offset=ExCute.__slipt_code(source)
        offset = sigEXTnum_hex(offset,16)<<2
        nPC = PC._value+4+offset
        if RegFile.read(rs) == RegFile.read(rt):
            # 延迟槽
            ExCute.__delaying()
            
            PC.next(nPC)
        else :
            PC.next()
    @staticmethod
    def __bne(source:str):
        rt,rs,offset=ExCute.__slipt_code(source)
        offset = sigEXTnum_hex(offset,16)<<2
        nPC = PC._value+4+offset
        if RegFile.read(rs) != RegFile.read(rt):
            # 延迟槽
            ExCute.__delaying()
            
            PC.next(nPC)
        else :
            PC.next() 
    @staticmethod
    def __lui(source:str):
        rt,imm=ExCute.__slipt_code(source)
        imm = zeroEXTnum_hex(imm)<<16
        RegFile.write(rt,imm)
    
    @staticmethod
    def __j(source:str):
        instr_index = source.strip()
        instr_index = zeroEXTnum_hex(instr_index)<<2
        instr_index |= (PC._value&0xc0000000)
        # 延迟槽
        ExCute.__delaying()
            
        PC.next(instr_index)
    @staticmethod
    def __jal(source:str):
        instr_index = source.strip()
        instr_index = zeroEXTnum_hex(instr_index)<<2
        instr_index |= (PC._value&0xc0000000)
        RegFile.write("$ra",PC._value+8)
        # 延迟槽
        ExCute.__delaying(link=True)
            
        PC.next(instr_index)

    __OP_TO_FUNCTION = {
        "add"   : __add ,
        "sub"   : __sub ,
        "and"   : __and ,
        "or"    : __or ,
        "nor"   : __nor ,
        "slt"   : __slt ,
        "sltu"  : __sltu ,
        "sll"   : __sll ,
        "srl"   : __srl ,
        "jr"    : __jr ,
        "mult"  : __mult,
        "multu" : __multu,
        "div"   : __div,
        "divu"  : __divu,
        "mfhi"  : __mfhi,
        "mflo"  : __mflo,
        "mthi"  : __mthi,
        "mtlo"  : __mtlo,
        "addi"  : __addi ,
        "lw"    : __lw ,
        "sw"    : __sw ,
        "lh"    : __lh ,
        "sh"    : __sh ,
        "lb"    : __lb ,
        "sb"    : __sb ,
        "beq"   : __beq ,
        "bne"   : __bne ,
        "slti"  : __slti ,
        "sltiu" : __sltiu ,
        "lui"   : __lui ,
        "ori"   : __ori,
        "andi"  : __andi,
        "j"     : __j ,
        "jal"   : __jal,
    } 


    @staticmethod
    def run(codes:str|list):
        if type(codes) is list:
            for code in codes:
                if ExCute.__OutputEnable :
                    debuginf = PC.getMachineCOde()+"\t"+PC.getInstruct()
                    print(format(debuginf,"<40"),end='')
                if code == "nop" :
                    PC.next()
                    continue
                op,source = re.split("\\s",code,1)
                ExCute.__OP_TO_FUNCTION[op](source)
        elif type(codes) is str:
            if ExCute.__OutputEnable :
                debuginf = PC.getMachineCOde()+"\t"+PC.getInstruct()
                print(format(debuginf,"<40"),end="")
            if codes == "nop":
                PC.next()
            else:
                op,source = re.split("\\s",codes,1)
                ExCute.__OP_TO_FUNCTION[op](source)

def OutAccess(cin):
    ExCute.outconfig(False)
    PC.loadInstruct(cin)
    ExCute.run(PC.getInstruct())
    while PC._endsignal != True :
        ExCute.run(PC.getInstruct())


if __name__ == "__main__" :
    while True:
        cin=input()
        if cin == "":
            continue
        if cin.find("exit") != -1:
            break
        PC.loadInstruct(cin)
        ExCute.run(PC.getInstruct())
        while PC._endsignal != True :
            ExCute.run(PC.getInstruct())