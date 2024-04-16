import sys
sys.path.append('.')
from MIPS.PC import PC
class DM:

    __datamem = [0]*0xc00
    __OutputEnable = True
    
    def __init__(self) -> None:
        raise SystemError("it's static class!!!")

    @classmethod
    def outconfig(cls,ifoutput:bool=True):
        if ifoutput :cls.__OutputEnable = True
        else : cls.__OutputEnable = False

    @classmethod
    def write(cls,addr,data,bytenum=4):
        """
        :param bytenum: write bytes num(4 for sw,2 for sh,1 for sb)
        """
        addr&=0xffffffff
        if(bytenum!=1 and bytenum!=2 and bytenum!=4):
            raise SystemError(f"data memory write module error!!!\n\t\twrite bytes num ={bytenum:d}")
        if(addr&(bytenum-1)!=0):
            raise SystemError("data memory write address exception!!!\n\t\ttype:{0:s}\taddr:{1:x}".format("sw" if bytenum==4 else "sh",addr))
        if(addr<0 or 0x3000<addr):
            raise SystemError("data memory write address {0:0>8x} range out of 0-0x3000!!!".format(addr))
        
        if bytenum == 4:
            addr >>= 2
            cls.__datamem[addr] = data&(0xffffffff)
        elif bytenum == 2:
            shift = (addr>>1)&1
            select = 0x0000ffff if shift==1 else 0xffff0000
            addr >>= 2
            cls.__datamem[addr] = (cls.__datamem[addr]&select)|((data&0xffff)<<(shift*16))
        elif bytenum == 1:
            shift = addr & 0b11
            addr >>= 2
            select = 0xffffffff ^ (0xff<<(shift*8))
            cls.__datamem[addr] = (cls.__datamem[addr]&select)|((data&0xff)<<(shift*8))
        if DM.__OutputEnable : print(f"@{PC._value:0>8x}: *{addr<<2:0>8x} <= {cls.__datamem[addr]:0>8x}",end="")
        PC.next()

    def __signext(num,bytenum):
        sign = 0xffffffff if (num&(1<<(bytenum*8-1)))!=0 else 0
        return num | (sign^(sign>>((4-bytenum)*8)))

    @classmethod
    def read(cls,addr,bytenum=4,extmodule=1):
        """
        :param bytenum :    read bytes num(4 for lw,2 for lh,1 for lb)
        :param extmodule :  1 for signed load ; 0 for unsigned load
        """
        addr&=0xffffffff
        if(bytenum!=1 and bytenum!=2 and bytenum!=4):
            raise SystemError(f"data memory read module error!!!\n\t\twrite bytes num ={bytenum:d}")
        if(addr&(bytenum-1)!=0):
            raise SystemError("data memory read address exception!!!\n\t\ttype:{0:s}\taddr:{1:x}".format("sw" if bytenum==4 else "sh",addr))
        if(addr<0 or 0x3000<addr):
            raise SystemError("data memory read address {0:0>8x} range out of 0-0x3000!!!".format(addr))

        if bytenum == 4 :
            addr >>= 2
            return cls.__datamem[addr]
        elif bytenum == 2 :
            shift = (addr>>1)&1
            select = 0xffff0000 if shift==1 else 0x0000ffff
            addr >>= 2
            temp =(cls.__datamem[addr]&select)>>(shift*16)
            return DM.__signext(temp,2) if extmodule==1 else temp
        elif bytenum == 1 :
            shift = addr & 0b11
            select = 0xff << (shift*8)
            addr>>=2
            temp = (cls.__datamem[addr]&select)>>(shift*8)
            return DM.__signext(temp,1) if extmodule==1 else temp