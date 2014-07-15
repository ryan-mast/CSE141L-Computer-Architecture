import sys, os

IMEM_DIR = "../Assembler/"
DMEM_DIR = "../Demo/"
      
if (len(sys.argv) < 3):
    print("USAGE: python testBubblesort.py <pos|mixed> <10|224>")
    exit()
    
type = sys.argv[1]
num = int(sys.argv[2])
if (type == "pos"):
    type = "all_pos"

sim = os.popen("java ISASimulator", "w")
sim.write("iload " + IMEM_DIR + "bubblesort_i.coe 0 \n")

sim.write("dload " + DMEM_DIR + str(num) + "_entry_" + type + "_d.coe 0 \n")

#sim.write("dump_dmem 32 " + str(num-1) + " \n")
sim.write("run \n")
sim.write("dump_dmem 32 " + str(num-1) + " \n")
sim.write("exit")

