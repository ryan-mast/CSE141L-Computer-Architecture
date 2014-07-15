////////////////////////////////////
//
// UCSD CSE 141 / 141L
// Instructor: Sat Garcia
// Lab1 Assembler Framework
// Design by Hung-Wei Tseng
// Modify by Po-Chao Huang
// Modified by Sat Garcia
//
////////////////////////////////////

Directory contain: 
   Assembler.java
   work.java
   Makefile
   example.s
   readme.txt

You are welcome to use any kind and any language to design your Assembler.  In order to reduce the
overhead in designing the Assembler, we have provided this basic framework for you.

The following instructions are based on using Linux for building your assembler.  You may use
another environment if you prefer.

1. At a minimum, you have to modify the generateCode function in work.java. There is currently a single
instruction, "addi", that is implemented as an example.  You are welcom to modify or add anything you
like in Assembler.java or work.java.

2. Use the command "make" to compile the work.java and Assembler.java.

3. To run the example program (example.s), use the command "make run-example". This should result
in a new file being created: "example_i.coe". After compiling, you can run the assembler with
different inputs. For this, use the command "java work input.s output". (In this example, it would read
in input.s and produce output_i.coe).

Have fun!
