import sys
import re

def readStd(file,linenum):
    while True:
        linenum += 1
        line = file.readline()
        if line == "" :
            return False,"",""
        else :
            searchans = re.search(r"@\s*([0-9a-f]*)\s*:\s*([*$])\s*([0-9a-f]*)\s*<=\s*([0-9a-f]*)",line,re.I)
            if searchans != None :
                parts = searchans.groups()
                if len(parts) and all(i!="" for i in parts) :
                    return line,linenum,parts

def readCheck(file,linenum):
    while True:
        linenum += 1
        line = file.readline()
        if line == "" :
            return False,"","",""
        else :
            searchans = re.search(r"\s*([0-9]*)\s*@\s*([0-9a-f]*)\s*:\s*([*$])\s*([0-9a-f]*)\s*<=\s*([0-9a-f]*)",line,re.I)
            if searchans != None :
                parts = searchans.groups()
                if( parts[2]=="*" or parts[3]!="0") and len(parts)==5 and all(i!="" for i in parts) :
                    return line,linenum,parts[0],parts[1:]
                if parts[3]=='0' and parts[2]=="$":
                    if len(parts)==5 and all(i!="" for i in parts) and parts[4]!="00000000":
                        print (f"[Warning: sample line = {linenum}]\n\t\tthe value write to reg $0 "+parts[4]+" is not equal to zero")

def skipcheck(stdfile,stdori,stdline,stdans,checkori,checkfile,checkline,checktime,checkans) :
    std = []
    check = []
    nexttime = checktime
    while nexttime == checktime:
        if stdori != False : std.append((stdans,stdline,stdori))
        check.append((checkans,checkline,checkori))
        stdori,stdline,stdans = readStd(stdfile,stdline)
        checkori,checkline,nexttime,checkans = readCheck(checkfile,checkline)
    
    std = sorted(std)
    check = sorted(check)

    for i,j in zip(std,check):
        if i[0]!=j[0]:
            print (f"[Error  stdandredLine={i[1]} sampleLine={j[1]}]\nstdans:{i[2]}\nsample\t{j[2]}")
            return "Error","","","","","",""
    return stdori,stdline,stdans,checkori,checkline,nexttime,checkans
    



if __name__=='__main__':
    if len(sys.argv)<3 :
        print("we need two files!!!")
        exit()
    stdandpath = sys.argv[1]
    checkpath = sys.argv[2]


    with open(stdandpath,"r") as stdfile :
        with open(checkpath,"r") as checkfile :
            stdline = 0
            checkline = 0
            while True:
                stdori,stdline,stdans = readStd(stdfile,stdline)
                checkori,checkline,timecheck,checkans = readCheck(checkfile,checkline)

                if checkori == False and stdori == False :
                    print ("stadandard file read over")
                    print ("sample file read over")
                    break
                elif checkori == False :
                    print ("sample file read over")
                    print (f"stdfile endline {stdline}")
                    print ("[Warning]:\n\t\tthe sample file output too few")
                    break
                elif stdori == False :
                    print ("stadandard file read over")
                    print (f"samplefile endline {checkline}")
                    print ("[Warning]:\n\t\tthe sample file output too much")
                    break

                if stdans != checkans : 
                    if stdans[0] != checkans[0]:
                        while stdans != checkans and stdans[0] != checkans[0]:
                            stdori,stdline,stdans,checkori,checkline,timecheck,checkans = skipcheck(stdfile,stdori,stdline,stdans,checkori,checkfile,checkline,timecheck,checkans)
                            if stdori == "Error" :
                                exit()
                            if checkori == False and stdori == False :
                                print ("stadandard file read over")
                                print ("sample file read over")
                                print("\t\t>>>the same<<<")
                                exit()
                            elif checkori == False :
                                print ("sample file read over")
                                print (f"stdfile endline {stdline}")
                                print ("[Warning]:\n\t\tthe sample file output too few")
                                print("\t\t>>>the same<<<")
                                exit()
                            elif stdori == False :
                                print ("stadandard file read over")
                                print (f"samplefile endline {checkline}")
                                print ("[Warning]:\n\t\tthe sample file output too much")
                                print("\t\t>>>the same<<<")
                                exit()
                        if stdans != checkans and stdans[0] == checkans[0]:
                            print (f"[Error  stdandredLine={stdline} sampleLine={checkline}]\nstdans:{stdori}\nsample\t{checkori}")
                            exit()
                    else:
                        print (f"[Error  stdandredLine={stdline} sampleLine={checkline}]\nstdans:{stdori}\nsample\t{checkori}")
                        exit()
                
                if checkori == False or stdori == False : break

    print("\t\t>>>the same<<<")
