
#for python > 3.0

import re #for regex 
import sys
usage = "USAGE: lifeconvert.py infilename outfilename"

if len(sys.argv) != 3:
        print(usage)
        sys.exit(0)
        
infname = sys.argv[1]
outfname = sys.argv[2]
outfile = open(outfname, mode='w')
infile = open(infname, mode='r')
if not infile:
        print("did not open file")

line = infile.readline()
height = 1 #incremented each time we read
width = 0 #for now hold zero till we find the width
while True:
        if (re.match(r'^\!',line)):
                line = infile.readline() #read another line
                if not line: break
                continue #skip comments
        elif (width == 0): #found a non comment line, snag the width for the first time
                width = len(line) - 1 #don't count \n
        hexstr = re.sub(r'O','FF ',line)
        hexstr = re.sub(r'\.','00 ',hexstr)
        print(hexstr,file=outfile,end='')
        line = infile.readline() #read another line
        if not line:
                break
        else:
                height = height + 1 #increase the height var

#now print width and length at start of file
print('// (height,width) = (' + str(height) + ',' + str(width) + ')',
        file=outfile)

infile.close()
outfile.close()
print('done')
