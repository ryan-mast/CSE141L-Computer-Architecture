////////////////////////////////////
//
// UCSD CSE 141 / 141L
// Instructor: Sat Garcia
// Lab1 Simulator Framework
// Design by Donghwan Jeon
// Modify by Po-Chao Huang (2010)
// Modified by Sat Garcia (2011)
//
////////////////////////////////////

Directory contain: 
   ISASimulator.java
   Makefile
   example_i.coe
   problem1_d.coe
   readme.txt

You are welcome to use any language to design your Simulator.  To help reduce the overhead in
designing a simulator, we have provided this basic framework for you.

If you run into trouble getting the framework setup, talk to the instructor, one of the TAs,
or post to Piazza.

The following description is based on your running this code on a Linux machine in a Linux
terminal. Since there is only a single Java file (ISASimulator.java), it should be simply to
set this up in your IDE of choice (e.g. Eclipse).

1. There are two "TODO" parts in the ISASimulator.java that you need to fill in.
To get you started, we have created an "addi" instruction with an OPCODE_LENGTH = 4.
You are not limited to modifying only the TODO parts but, at a minimum, you must
implement those parts.

2. Running "make" will compile your simulator (assuming you have not added any new Java
files).

3. Use the command "make run" to start your ISASimulator program.

4. Load your design, example_i.coe: "iload example_i.coe 0".

5. Run it for one instruction: "go 1".

6. Check the reg_file :"dump_reg"

7. For a full list of the supported commands, please see the Assembler and Simulator Framework
page on Moodle. There will also be a tutorial during the "lab section" during the first week
of class.

Have fun!

