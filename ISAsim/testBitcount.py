import os

IMEM_DIR = "../Assembler/"
DMEM_DIR = "../Demo/"

sim = os.popen("java ISASimulator", "w")
sim.write("iload " + IMEM_DIR + "bitcount_i.coe 0 \n")
sim.write("dload " + DMEM_DIR + "problem1_d.coe 0 \n")
sim.write("dump_dmem 2 0 \n")
sim.write("run \n")
sim.write("dump_dmem 2 0 \n")
sim.write("exit")