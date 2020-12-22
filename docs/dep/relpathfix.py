# -*- coding: utf-8 -*-
import sys

def relpathfix(filename, strorg, strrep):
    with open(filename,'r') as file:
        filedata = file.read()
        filedata = filedata.replace(strorg,strrep)
    with open(filename,'w') as file:
        file.write(filedata)

relpathfix(sys.argv[1],sys.argv[2],sys.argv[3])
