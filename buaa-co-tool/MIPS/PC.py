import sys
sys.path.append('.')
import re
from MIPS.DisAssembler import DisAssembler
from MIPS.RegOrder import RegOrder
class PC:
    _value = 0x3000
    __order = [""]*0x1000
    __machine_code = [""]*0x1000
    __imcur = 0
    __imend = 0
    __maend = 0
    _endsignal = False
    __OutputEnable = True

    def __init__(self) :
        raise SystemError("it's static class!!!")

    @classmethod
    def outconfig(cls,ifoutput:bool=True):
        if ifoutput :cls.__OutputEnable = True
        else : cls.__OutputEnable = False
    
    @classmethod
    def loadInstruct(cls,ins) :
        if type(ins) is str:
            ins = ins.strip()
            if ins == "":
                pass
            else :
                cls.__order [cls.__imend] = DisAssembler.decode(RegOrder(ins)) if ins.replace(" ","").isalnum() else ins
                cls.__imend += 1
        elif type(ins) is list:
            for oneins in ins:
                oneins = oneins.strip()
                if oneins == "":
                    continue
                if type(oneins) is str:
                    cls.__order[cls.__imend] = DisAssembler.decode(RegOrder(oneins)) if oneins.replace(" ","").isalnum() else oneins
                    cls.__imend += 1
                else:
                    raise SystemError("only str can be load in IM")
    @classmethod
    def loadMachineCode(cls,ins) :
        if type (ins) is str:
            ins = ins.replace(" ","")
            ins.strip()
            if ins == "":
                pass
            elif ins.isalnum() :
                cls.__machine_code[cls.__maend] = ins
                cls.__maend += 1
            else :
                raise SystemError("code {} is illegal".format(ins))
        elif type (ins) is list:
            for oneins in ins:
                oneins = oneins.replace(" ","")
                oneins = oneins.strip()
                if oneins == "":
                    pass
                elif oneins.isalnum() :
                    cls.__machine_code[cls.__maend] = oneins
                    cls.__maend += 1
                else :
                    raise SystemError("code {} is illegal".format(oneins))


    @classmethod
    def next(cls,nPC="") :
        if nPC == "":
            if PC.__OutputEnable :print("")
            cls._value +=4
        elif type(nPC) is str:
            if nPC[:2] == "0x" :
                nPC = int(nPC,16)
            elif nPC[:2] == "0o" :
                nPC = int(nPC,8)
            elif nPC[:2] == "0b" :
                nPC = int(nPC,2)
            else :
                if re.search(r'[a-f]',nPC,flags=re.I) or len(nPC)==8:
                    nPC = int(nPC,16)
                else :
                    nPC = int(nPC)
                    
            nPC&=0xffffffff
            cls._value = nPC
        elif type(nPC) is int:

            nPC&=0xffffffff
            cls._value = nPC

        if (cls._value&0b11) != 0:
            raise SystemError("PC value {:#010x} is illegal".format(cls._value))

        if cls._value < 0x3000 or cls._value > 0x6ffc or cls._value%4 !=0:
            raise SystemError("PC value {:#010x} is wrong".format(cls._value))
        else :
            cls.__imcur = (cls._value - 0x3000) >> 2

        if cls.__imcur > cls.__imend:
            raise SystemError("PC value {:#010x} out of max im addr".format(cls._value))
        elif cls.__imcur == cls.__imend:
            cls._endsignal = True
        else :
            cls._endsignal = False

    @classmethod
    def getInstruct(cls):
        return cls.__order[cls.__imcur]

    @classmethod
    def getMachineCOde(cls):
        return cls.__machine_code[cls.__imcur]