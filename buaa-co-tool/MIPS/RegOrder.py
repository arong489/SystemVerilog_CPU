import re
class RegOrder :
    def __init__(self, value):
        if isinstance(value,RegOrder) :
            self._value = value._value
        elif type(value) is str :
            value = value.strip().replace(" ","")
            if value[:2] == "0x" :
                self._value = format(int(value,16),"032b")
            elif value[:2] == "0o" :
                self._value = format(int(value,8),"032b")
            elif value[:2] == "0b" :
                self._value = value.strip
            else :
                if re.search(r'[a-f]',value,flags=re.I) or len(value)==8:
                    self._value = format(int(value,16),"032b")
                elif all(i=="0" or i=="1" for i in value) and len(value)==32:
                    self._value=value
                else :
                    self._value = format(int(value),"032b")
                if len(self._value) != 32 :
                    raise SystemError("machine code length too long")
        else :
            raise SystemError("only machine code string can be registed!!!")

    def split(self,split_index_list) :
        res = []
        prew_i = 0
        for i in split_index_list:
            res.append(self._value[prew_i:i])
            prew_i = i
        return res