import sys, random

def countSetBits(hex_str):
    x = int(hex_str, 16)
    count = 0
    while(x):
        count += (x & 1)
        x >>= 1
    return count
    
    
    
if (len(sys.argv) < 2):
    print("USAGE: python 96halfword_gen.py <output_file_name>")
    exit()
    
fout = open(sys.argv[1], 'w')

fout.write("MEMORY_INITIALIZATION_RADIX=16;\nMEMORY_INITIALIZATION_VECTOR=\n")
for x in range(32):
    fout.write("0000,\n")
num = hex(random.randint(0,65535))[2:].upper().zfill(4)
numSet = 0
for x in range(0,96):
    fout.write(num + ",\n")
    numSet += (countSetBits(num) > 8)
    num = hex(random.randint(0,65535))[2:].upper().zfill(4)

#fout.write(num)
#numSet += (countSetBits(num) > 8)

print(str(numSet) + " numbers have more 1's than 0's in file " + sys.argv[1] + "\n")
fout.close()
exit()
