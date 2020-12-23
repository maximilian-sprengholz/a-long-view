# -*- coding: utf-8 -*-
import sys
import re

replace_string = ''
for i in range(3,len(sys.argv)):
    replace_string += sys.argv[i]

with open(sys.argv[1],'r') as file:
    filedata = file.read()
    filedata = re.sub(sys.argv[2], replace_string, filedata)
with open(sys.argv[1],'w') as file:
    file.write(filedata)
