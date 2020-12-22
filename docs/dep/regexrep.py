# -*- coding: utf-8 -*-
import sys
import re

with open(sys.argv[1],'r') as file:
    filedata = file.read()
    filedata = re.sub(sys.argv[2], sys.argv[3], filedata)
with open(sys.argv[1],'w') as file:
    file.write(filedata)
