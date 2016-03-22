import sys, random
    
if (len(sys.argv) < 2):
    print("USAGE: python bubblesort_gen.py <output_file_name> [num_elements]")
    exit()
    
fout = open(sys.argv[1], 'w')

fout.write("MEMORY_INITIALIZATION_RADIX=16;\nMEMORY_INITIALIZATION_VECTOR=\n")
for x in range(4):
    fout.write("0000,\n")

if (len(sys.argv) == 3):
    numEntries = int(sys.argv[2])
    if (numEntries > 224):
        print("WARNING: Number of elements in array exceeds 224")
else:
    numEntries = random.randint(0, 224)
fout.write(hex(numEntries)[2:].upper().zfill(4) + ",\n")

for x in range(27):
    fout.write("0000,\n")

num = hex(random.randint(0,65535))[2:].upper().zfill(4)

for x in range(numEntries-1):
    fout.write(num + ",\n")
    num = hex(random.randint(0,65535))[2:].upper().zfill(4)

fout.write(num)

print(str(numEntries) + " element array in file " + sys.argv[1] + "\n")
fout.close()
exit()
