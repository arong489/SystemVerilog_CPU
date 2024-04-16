import sys
sys.path.append('.')
from MIPS.PC import PC
from MIPS.Define import reg_to_index
class RegFile:

    __reg = [0]*32
    __hi = 0
    __lo = 0
    __c0 = 0
    __OutputEnable = True

    def __init__(self) -> None:
        raise SystemError("it's static class!!!")

    #ToDo:保留，用来初始化一些mars中有值的寄存器
    @classmethod
    def mipsInitial(cls):
        pass

    @classmethod
    def outconfig(cls,ifoutput:bool=True):
        if ifoutput :cls.__OutputEnable = True
        else : cls.__OutputEnable = False

    @classmethod
    def special_write(cls,addr_list,data_list):
        if(type(addr_list)==str):
            if addr_list=="hi":
                cls.__hi = data_list&0xffffffff
            elif addr_list=="lo":
                cls.__lo = data_list&0xffffffff
            elif addr_list=="c0":
                cls.__c0 = data_list&0xffffffff
        else :
            for addrstr,data in zip(addr_list,data_list):
                if addrstr=="hi":
                    cls.__hi = data&0xffffffff
                elif addrstr=="lo":
                    cls.__lo = data&0xffffffff
                elif addrstr=="c0":
                    cls.__c0 = data&0xffffffff
        PC.next()

    @classmethod
    def special_read(cls,addr_list:str|list[str]):
        if type(addr_list) is str:
            if addr_list=="hi":
                return cls.__hi
            elif addr_list=="lo":
                return cls.__lo
            elif addr_list=="c0":
                return cls.__c0
        elif type(addr_list) is list:
            read_list = []
            for addrstr in addr_list:
                if addrstr=="hi":
                    addr_list.append(cls.__hi)
                elif addrstr=="lo":
                    addr_list.append(cls.__lo)
                elif addrstr=="c0":
                    addr_list.append(cls.__c0)
            return read_list

    @staticmethod
    def __getnormaladdr(addrstr:str):
        if type (addrstr) != str:
            SystemError("none str GRFaddr")
            return 0
        else :
            if addrstr[0] == '$' and addrstr[1:].strip().isdecimal():
                return int(addrstr[1:].strip(),10)
            elif all(i=='0' or i=='1' for i in addrstr) and len(addrstr)<=5 :
                return int(addrstr,2)
            else: return int(reg_to_index[addrstr],2)

    @classmethod
    def write(cls,addr_list,data_list):
        if(type(addr_list)!=list):
            addr = RegFile.__getnormaladdr(addr_list)
            if addr>0 and addr<32:
                cls.__reg[addr] = data_list&0xffffffff
                if RegFile.__OutputEnable : print(f"@{PC._value:0>8x}: ${addr:2d} <= {cls.__reg[addr]:0>8x}",end="")
            elif addr != 0 :
                raise SystemError(f"reg file Waddr {addr:2d} out of 0-31")
        else :
            for addrstr,data in zip(addr_list,data_list):
                addr = RegFile.__getnormaladdr(addrstr)
                if addr>0 and addr<32:
                    cls.__reg[addr] = data&0xffffffff
                    if RegFile.__OutputEnable : print(f"@{PC._value:0>8x}: ${addr:2d} <= {cls.__reg[addr]:0>8x}",end="")
                elif addr != 0 :
                    raise SystemError(f"reg file Waddr {addr:2d} out of 0-31")
        PC.next()
    
    @classmethod
    def read(cls,addr_list:str|list[str]):
        if type(addr_list) is str:
            return cls.__reg[RegFile.__getnormaladdr(addr_list)]
        elif type(addr_list) is list:
            return (cls.__reg[RegFile.__getnormaladdr(addrstr)] for addrstr in addr_list)