import sys
sys.path.append('.')
from MIPS.PC import PC
from MIPS.Excute import ExCute

def readFile(filepath):
    with open(filepath, "r") as f:
        return f.readlines()

if __name__ == '__main__':
    codePath = sys.argv[1]
    sys.argv.count
    stop = False
    if(len(sys.argv)==3) :
        maxpathnum:int = int(sys.argv[2])
        stop = True
    code = readFile(codePath)
    PC.loadInstruct(code)
    PC.loadMachineCode(code)
    if stop :
        while PC._endsignal!=True and maxpathnum > 0:
            ExCute.run(PC.getInstruct())
            maxpathnum -= 1
    else :
        while PC._endsignal!=True :
            ExCute.run(PC.getInstruct())