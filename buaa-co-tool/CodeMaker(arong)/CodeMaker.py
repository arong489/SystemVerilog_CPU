from Define import *
from random import randint,sample


if __name__=='__main__':
    regs = getReg(15,1)
    inslist = []
    for reg in regs:
        inslist = fullReg(reg)
        print(inslist[0])
        print(inslist[1])
    inslist=getCalIns(regs,1000)
    for ins in inslist:
        print(ins)