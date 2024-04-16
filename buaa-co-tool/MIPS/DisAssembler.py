import sys
sys.path.append('.')
from MIPS.RegOrder import RegOrder
from MIPS.Define import *
class DisAssembler:

    __formars__ : bool = False

    def __init__(self) -> None:
        raise SystemError("it's static class!!!")

    @classmethod
    def OutConfig(cls,ifformars:bool=False):
        if ifformars : cls.__formars__ = True 

    @staticmethod
    def decode(codes:RegOrder|str|list) -> str:
        if isinstance(codes, RegOrder):
            op = codes.split([6])[0]
            if op == "000000":
                return DisAssembler.__R_decode(codes)
            elif op in I_index_to_inst.keys():
                return DisAssembler.__I_decode(codes)
            elif op in J_index_to_inst.keys():
                return DisAssembler.__J_decode(codes)
            else :
                SystemError("no such instruct temporatily\n\t\tplease conneted to Hongliang Cao")
        
        elif type(codes) is str:
            code = RegOrder(codes)
            op = code.split([6])[0]
            if op == "000000":
                return DisAssembler.__R_decode(code)
            elif op in I_index_to_inst.keys():
                return DisAssembler.__I_decode(code)
            elif op in J_index_to_inst.keys():
                return DisAssembler.__J_decode(code)
            else :
                SystemError("no such instruct temporatily\n\t\tplease conneted to Hongliang Cao")
        
        elif type(codes) is list:
            inss = []
            for code in codes:
                code = RegOrder(code)
                op = codes.split([6])[0]
                if op == "000000":
                    inss.append(DisAssembler.__R_decode(code))
                elif op in I_index_to_inst.keys():
                    inss.append(DisAssembler.__I_decode(code))
                elif op in J_index_to_inst.keys():
                    inss.append(DisAssembler.__J_decode(code))
                else :
                    SystemError("no such instruct temporatily\n\t\tplease conneted to Hongliang Cao")
            return inss
    

    @staticmethod
    def __R_decode(code:RegOrder):
        _, rs, rt, rd, shamt, funct = code.split([6, 11, 16, 21, 26, 32])
        funct = R_index_to_inst[funct]
        if R_format[funct] == 0b111 :
            return "{0:<9} {3:<3}, {1:<3}, {2:<3}".format(
                funct,
                index_to_reg[rs],
                index_to_reg[rt],
                index_to_reg[rd]
            )
        elif R_format[funct] == 0b011 :
            return "{0:<9} {2:<3}, {1:<3}, {3:#x}".format(
                funct,
                index_to_reg[rt],
                index_to_reg[rd],
                int(shamt,2)
            )
        elif R_format[funct] == 0b100 :
            return "{0:<9} {1:<3}".format(
                funct,
                index_to_reg[rs]
            )
        elif R_format[funct] == 0b000 :
            return funct
        elif R_format[funct] == 0b110 :
            return "{0:<9} {1:<3}, {2:<3}".format(
                funct,
                index_to_reg[rs],
                index_to_reg[rt]
            )
        elif R_format[funct] == 0b001 :
            return "{0:<9} {1:<3}".format(
                funct,
                index_to_reg[rd]
            )

    def __I_decode(code:RegOrder):
        op, rs, rt, imm = code.split([6, 11, 16, 32])
        funct = I_index_to_inst[op]
        if I_format[funct] == "cal":
            minus=signed(int(imm,2),16) if funct == "slti" or funct == "addi" else int(imm,2)
            return "{0:<9} {2:<3}, {1:<3}, {3:#x}".format(
                funct,
                index_to_reg[rs],
                index_to_reg[rt],
                minus if DisAssembler.__formars__ else int(imm,2) 
            )
        elif I_format[funct] == "load" or I_format[funct] == "store":
            return "{0:<9} {2:<3}, {3:#x}({1})".format(
                funct,
                index_to_reg[rs],
                index_to_reg[rt],
                signed(int(imm,2),16) if DisAssembler.__formars__ else int(imm,2)
            )
        elif I_format[funct] == "branch" :
            return "{0:<9} {1:<3}, {2:<3}, {3:#x}".format(
                funct,
                index_to_reg[rs],
                index_to_reg[rt],
                signed(int(imm,2),16) if DisAssembler.__formars__ else int(imm,2)
            )
        elif I_format[funct] == "imm" :
            return "{0:<9} {1:<3}, {2:#x}".format(
                funct,
                index_to_reg[rt],
                int(imm,2)
            )
    
    def __J_decode(code:RegOrder):
        op,imm = code.split([6, 32])
        funct = J_index_to_inst[op]
        return "{0:<9} {1:#x}".format(
            funct,
            int(imm,2)<<2 if DisAssembler.__formars__ else int(imm,2)
        )

if __name__ == "__main__":
    print("                            _ooOoo_                     ")
    print("                           o8888888o                    ")
    print("                           88  .  88                    ")
    print("                           (| -_- |)                    ")
    print("                            O\\ = /O                    ")
    print("                        ____/`---'\\____                ")
    print("                      .   ' \\| |// `.                  ")
    print("                       / \\||| : |||// \\               ")
    print("                     / _||||| -:- |||||- \\             ")
    print("                       | | \\\\\\ - /// | |             ")
    print("                     | \\_| ''\\---/'' | |              ")
    print("                      \\ .-\\__ `-` ___/-. /            ")
    print("                   ___`. .' /--.--\\ `. . __            ")
    print("                ."" '< `.___\\_<|>_/___.' >'"".         ")
    print("               | | : `- \\`.;`\\ _ /`;.`/ - ` : | |     ")
    print("                 \\ \\ `-. \\_ __\\ /__ _/ .-` / /      ")
    print("         ======`-.____`-.___\\_____/___.-`____.-'====== ")
    print("                            `=---='  ")
    print("                                                        ")
    print("         .............................................  ")
    print("                  佛祖镇楼             BUG辟邪          ")
    print("          Zen of python:                                ")
    print("                  Beautiful is better than ugly.；      ")
    print("                  Explicit is better than implicit.     ")
    print("                  Simple is better than complex.        ")
    print("                  Complex is better than complicated.   ")
    print("                  Flat is better than nested.           ")
    print("                  Sparse is better than dense.          ")
    print("                  Readability counts.                   ")
    print("                  Now is better than never.             ")
    print("                                         裂开的 XT-arong")
    
    while True:
        if len(sys.argv)==2 :
            DisAssembler.OutConfig(True)
        cin=input()
        while cin=="":
            cin=input()
        if cin.find("exit") != -1:
            break
        print(DisAssembler.decode(cin))