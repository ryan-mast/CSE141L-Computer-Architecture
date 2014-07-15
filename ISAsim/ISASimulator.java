import java.util.ArrayList;
import java.util.concurrent.LinkedBlockingQueue; // for channels
import java.io.BufferedReader;
import java.io.FileReader;
import java.math.BigInteger;
import java.util.Iterator;
import java.io.InputStreamReader;
import java.util.StringTokenizer;

public class ISASimulator {

     public static final int D_MEM_SIZE = 8192;
     public static final int I_MEM_SIZE = 8192;

     // constant values that depends on your ISA
     // TODO: modify this
     public static final int REG_FILE_SIZE = 8;
     public static final int OPCODE_LENGTH = 3;

     private int PC; // current program counter
     private int inst_count; // number of instructions we have executed for the simulator

     private String[] inst_mem; // inst_mem is kept in a string for easier parsing of opcode/operands/etc
     private short[] data_mem;
     private short[] reg_file;

     private boolean condition_bit;
     private boolean halt;
	
	private boolean debug; // should debug statements be printed out?

     // default constructor
     public ISASimulator() { 
	  // init PC to 0
	  PC = 0;

	  // initialize memories
	  inst_mem = new String[I_MEM_SIZE];
	  data_mem = new short[D_MEM_SIZE];

	  initMem(true);
	  initMem(false);

	  // initialize register file
	  reg_file = new short[REG_FILE_SIZE];

	  initRegFile(); // clear registers

          condition_bit = false;
          halt = false;
		 debug = false;
     }

     // reset everythinig to it's initial state (i.e. memory/registers/channels cleared and PC = 0)
     public void resetSimulator() {
	  PC = 0;
	  halt = false;
		
	  // reset memory
	  clearMem(true);
	  clearMem(false);

	  // reset register file
	  clearRegFile();

          condition_bit = false;
     }

     // initialize the memory (create and zero out)
     public void initMem(boolean imem) {
	  if(imem) { for(int i = 0; i < I_MEM_SIZE; ++i) inst_mem[i] = new String("000000000000"); } //inst_mem 12 bit
	  else { for(int i = 0; i < D_MEM_SIZE; ++i) data_mem[i] = (short) 0; }
     }

     // clears the memory: imem = true means inst memory, false = data mem
     public void clearMem(boolean imem) {
	  if(imem) {
	       for(int i = 0; i < I_MEM_SIZE; ++i) inst_mem[i] = "000000000000";
	  }
	  else {
	       for(int i = 0; i < D_MEM_SIZE; ++i) data_mem[i] = (short) 0;
	  }
     }

     // init the reg files to all 0's
     public void initRegFile() { for(int i = 0; i < REG_FILE_SIZE; ++i) reg_file[i] = (short) 0; }

     // clears the register file
     public void clearRegFile() {
	  for(int i = 0; i < REG_FILE_SIZE; ++i)
	       reg_file[i] = (short) 0;
     }

     /*
      * Description: loads either imem (imem = true) or dmem with a COE file (starting at address "start_addr")
      *
      * Returns: true if successful, false otherwise
      *
      * Note: dmem expects the input to be in 2's complement format... this is a bit hackish as sometimes the memory location will
      * be a pointer and therefore not really be 2's complement. However, we can (reasonably) assume that this won't be a
      * problem because the addresses used will never be large enough to have a MSB of 1 (since the memory is small enough)
      */
     public boolean loadMem(String coe, int start_addr, boolean imem) {
	  int curr_addr = start_addr; // which address we are currently pointing to
	  int curr_line = -1; // line number of the file that is currently read in
	  String line, tmp;
	  int radix = 16; // radix being used... default is 16

	  BufferedReader in = null;

	  // load COE file
	  try { in = new BufferedReader(new FileReader(coe)); }
	  catch(Exception e) { 
	       System.out.println("Couldn't open file: " + coe + ". Load failed."); 
	       return false;
	  }

	  // read in first 2 lines of COE, which have a specific format
	  try {
	       line = in.readLine(); // this line should be MEMORY_INITIALIZATION_RADIX=XXX
	       curr_line++;
	       if(!line.contains("MEMORY_INITIALIZATION_RADIX=")) {
		    System.out.println("Expected MEMORY_INITIALIZATION_RADIX=...; on line 0 of file. Load failed.");
		    return false;
	       }

	       // extract the radix value from the string
	       String radix_string = line.split("=")[1];
	       radix_string = radix_string.substring(0,radix_string.length()-1); // strip off the trailing ";"
	       radix = Integer.valueOf(radix_string).intValue(); // convert to int

	       // only support binary and hex for now
	       if(radix != 2 && radix != 16) {
		    System.out.println("Radix format must be 2 (binary) or 16 (decimal). Load failed.");
		    return false;
	       }

	       line = in.readLine(); // this line should be MEMORY_INITIALIZATION_VECTOR=
	       curr_line++;
	       if(!line.contentEquals("MEMORY_INITIALIZATION_VECTOR=")) {
		    System.out.println("line 1 must be \"MEMORY_INITIALIZATION_VECTOR=\". Load failed.");
		    return false;
	       }
	  }
	  catch(Exception e) {
	       System.out.println("Error reading input file. Load failed.");
	       return false;
	  }
		
	  // loop through file and get all the info
	  try {
	       line = in.readLine();
	       curr_line++;

	       while(line != null) { // stop when we read EOF
		    if((imem && curr_addr >= I_MEM_SIZE) || (!imem && curr_addr >= D_MEM_SIZE)) {
			 System.out.println("Too many addresses specified in COE file. Load failed.");
			 return false;
		    }

		    // if imem then we simply set the mem location as the binary version of the string (minus the trailing ',')
		    // if radix isn't binary, then conversion to binary must take place here must take place here
		    tmp = "";
		    if(imem) {
			 // strip off trailing ',' if there is one (should be EOF soon if not one)
			 if(line.substring(line.length()-1,line.length()).equals(","))
			      line = line.substring(0,line.length()-1);

			 // make sure the string is the correct length (based on radix)
			 if((radix == 2 && line.length() != 12) || (radix == 16 && line.length() != 3)) {
			      System.out.println(line + " (line " + curr_line + ") has incorrect format. Load failed.");
			      return false;
			 }

			 // radix 2 means we just copy the string over to the imem location
			 if(radix == 2) {
			      inst_mem[curr_addr] = line;
			      curr_addr++;
			 }
			 else { // need to convert each digit to binary string first
			      // since our instruction length is not a multiple of 4, the first hex digit must be 0 or 1
			      if(line.charAt(0) != '0' && line.charAt(0) != '1') {
				   System.out.println(line + " (line " + curr_line + "): First hex value must be 0 or 1. Load failed.");
				   return false;
			      }
			      else { // tack on first value
				   if(line.charAt(0) == '0') tmp = "0";
				   else tmp = "1";
			      }

			      String hexString = "";
			      // loop through and convert all the values
			      for(int i = 1; i < line.length(); ++i) {
				   hexString = hexToBin(line.charAt(i));
				   if(hexString.length() == 0) { // make sure the value was 0 - f and not some random char
					System.out.println(line + " (line " + curr_line + "): Non-Hex value encountered. Load failed.");
					return false;
				   }
				   tmp += hexString;
			      }

			      inst_mem[curr_addr] = tmp;
			      curr_addr++;
			 }
		    }

		    else { // convert to Int16 before loading into dmem
			 line = line.substring(0,line.length()-1); // strip off the trailing ','

			 // make sure the string is the correct length (based on radix)
			 if((radix == 2 && line.length() != 16) || (radix == 16 && line.length() != 4)) {
			      System.out.println(line + " (line " + curr_line + ") has incorrect format. Load failed.");
			      return false;
			 }

			 // radix 2 means we just copy the string over to the imem location
			 if(radix == 2)
			      tmp = line;

			 else { // need to convert each digit to binary string first
			      String binaryString = "";
			      // loop through and convert all the values
			      for(int i = 0; i < line.length(); ++i) {
				   binaryString = hexToBin(line.charAt(i));
				   if(binaryString.length() == 0) { // make sure the value was 0 - f and not some random char
					System.out.println(line + " (line " + curr_line + "): Non-Hex value encountered. Load failed.");
					return false;
				   }
				   tmp += binaryString;
			      }
			 }
			 data_mem[curr_addr] = (short) Integer.parseInt(tmp, 2);
			 curr_addr++;
		    }//half-words in an array have more ones than zeros. For example, the binary number 1101

		    line = in.readLine(); // read in next line
		    curr_line++;
	       } // end while

	       in.close();
	  }
	  catch(Exception e) {
	       System.out.println("Error reading input file. Load failed.");
	       return false;
	  }

	  return true;
     }

     // given a character (0 - f) returns a string of the binary representation of that num
     public String hexToBin(char hex_char) {
	  String result;
	  switch(Character.digit(hex_char,16)) {
	  case 0:
	       result = "0000";
	       break;
	  case 1:
	       result = "0001";
	       break;
	  case 2:
	       result = "0010";
	       break;
	  case 3:
	       result = "0011";
	       break;
	  case 4:
	       result = "0100";
	       break;
	  case 5:
	       result = "0101";
	       break;
	  case 6:
	       result = "0110";
	       break;
	  case 7:
	       result = "0111";
	       break;
	  case 8:
	       result = "1000";
	       break;
	  case 9:
	       result = "1001";
	       break;
	  case 10:
	       result = "1010";
	       break;
	  case 11:
	       result = "1011";
	       break;
	  case 12:
	       result = "1100";
	       break;
	  case 13:
	       result = "1101";
	       break;
	  case 14:
	       result = "1110";
	       break;
	  case 15:
	       result = "1111";
	       break;
	  default:
	       result = "";
	       break;
	  }
		
	  return result;
     }

     public void printIMem() { printIMem(0, I_MEM_SIZE-1); }
     public void printDMem() { printIMem(0, D_MEM_SIZE-1); }

     // disassembles instructions starting at start_addr and going to start_addr+range
     public void printIMem(int start_addr, int range) {
	  // sanity check of inputs
	  if(range < 0) {
	       System.out.println("Range must be positive.");
	       return;
	  }
	  if(start_addr + range >= I_MEM_SIZE) {
	       System.out.println("startaddr + size must be less than " + I_MEM_SIZE);
	       return;
	  }

	  // loop through and print values
	  for(int i = start_addr; i < start_addr + range; ++i)
	       System.out.println("IMEM[" + i + "]: " + inst_mem[i]);
     }

     // prints data mem contents from start_addr to start_addr+range
     public void printDMem(int start_addr, int range) {
	  // sanity check of inputs
	  if(range < 0) {
	       System.out.println("Range must be non-negative.");
	       return;
	  }
	  if(start_addr + range >= D_MEM_SIZE) {
	       System.out.println("startaddr + size must be less than " + D_MEM_SIZE);
	       return;
	  }

	  // loop through and print values
	  for(int i = start_addr; i <= start_addr + range; ++i)
	       System.out.println("DMEM[" + i + "]: " + Integer.toHexString((int)data_mem[i] & 0x0000ffff));
     }

     // prints the contents of all the registers
     public void printRegFile() {
	  for(int i = 0; i < REG_FILE_SIZE; ++i)
	       System.out.println("$"+ i + ": 0x" + Integer.toHexString((int)reg_file[i] & 0x0000ffff));
     }

     // set specific register to a specific value
     public void setReg(int reg_num, short value) {
	  // sanity check of input
	  if(reg_num < 0 || reg_num >= REG_FILE_SIZE) {
	       System.out.println("Invalid register number: " + reg_num);
	       return;
	  }

	  reg_file[reg_num] = value;
     }

     // set specific imem location (addr) to a specific value
     public void setIMem(int addr, String value) {
	  // sanity check of input
	  if(addr < 0 || addr >= I_MEM_SIZE) {
	       System.out.println("Address out of range: " + addr);
	       return;
	  }

	  if(!isIMemFormat(value)) {
	       System.out.println("Incorrect format: " + value);
	       return;
	  }

	  inst_mem[addr] = value;
     }

     // makes sure that this is a 12 bit binary number in string format
     public boolean isIMemFormat(String value) {
	  if(value.length() != 12) return false;
		
	  // see if all chars are 0 or 1
	  for(int i = 0; i < 12; ++i) {
	       if(value.charAt(i) != '0' && value.charAt(i) != '1') return false;
	  }
	  return true;
     }

     // set specific dmem location (addr) to a specific value
     public void setDMem(int addr, short value) {
	  // sanity check of input
	  if(addr < 0 || addr >= D_MEM_SIZE) {
	       System.out.println("Address out of range: " + addr);
	       return;
	  }
	  data_mem[addr] = value;
     }

     // sign extend a string to a given length (assumes (i.e. doesn't check) it is a string of 0's and 1's)
     public String signExtend(String value, int length) {
	  String sign_bit = value.substring(0,1);

	  while(value.length() < length) value = sign_bit + value;

	  return value;
     }


     // execute num_insts instruction
     public void execute(int num_insts) {
	  // sanity check of inputs
	  if(num_insts < 1) {
	       System.out.println("Number of instructions must be positive.");
	       return;
	  }

	  int num_done = 0; // number of instructions we have completed so far
	  String curr_inst; // the current instruction
	  String opcode_str; // string representing the opcode
	  String funct_str;
	  String rs_reg_str, rt_reg_str;
	  int opcode;  // the opcode in integer form (so we can use a case statement)
	  int funct;
	  int rs, rt, imm;

	  while(num_done < num_insts) {
	       curr_inst = inst_mem[PC]; // get the next instruction

		  printDebug("Curr_inst: " + curr_inst + "\n\t Len: " + curr_inst.length());
	       
		   opcode_str = curr_inst.substring(0,OPCODE_LENGTH); // get the op-code bits
	       opcode = Integer.valueOf(opcode_str,2).intValue();
	       
	       funct_str = curr_inst.substring(11, 12);
	       funct = Integer.valueOf(funct_str,2).intValue();
	       
		  printDebug("Opcode: " + opcode_str + "\n\t Funct: " + funct_str);

	       switch (opcode) {
	       case 0:
	         opcode_str = curr_inst.substring(OPCODE_LENGTH,OPCODE_LENGTH+8);
                 if(Integer.valueOf(opcode_str,2).intValue() == 0)
                   halt = true;
				   printDebug("Instruction: halt");
                 PC++;
		    break;
	       case 1:
			 // Reserved
	    	 printDebug("Instruction: TBD");
	    	 PC++;
		    break;
		    
	       case 2:
	    	   if(funct == 0){
	    		   printDebug("Instruction: Addi");
	    		   //01 31
	    		   //10 32
	    		   rs_reg_str = curr_inst.substring(3, 6);
	    		   rt_reg_str = curr_inst.substring(6, 9);
	    		   rs = Integer.valueOf(rs_reg_str,2).intValue();
	    		   rt = Integer.valueOf(rt_reg_str,2).intValue();
	    	   
	    		   int imm_num;
	    		   String imm_str = curr_inst.substring(9, 11);
	    		   if(imm_str.equals("01")){
	    			   imm_num = 30;
	    		   }
	    		   else{
	    			   imm_num = 31;
	    		   }
	    		   reg_file[rs] = (short)(reg_file[rt] + (short)imm_num);
				   printDebug("\treg_file[" + rs + "] = reg_file[" + rt + "] + " + imm_num);
	    	   
	    	   }
	    	   
	    	   if(funct == 1){
	    		   printDebug("Instruction: Subi");  
	    		   
	    		   rs_reg_str = curr_inst.substring(3, 6);
	    		   rt_reg_str = curr_inst.substring(6, 9);
	    		   rs = Integer.valueOf(rs_reg_str,2).intValue();
	    		   rt = Integer.valueOf(rt_reg_str,2).intValue();
	    		   
	    		   
	    		   String imm_str = curr_inst.substring(9, 11);
	    		   int imm_num = 1;
	    		   
	    		   reg_file[rs] = (short)(reg_file[rt] - (short)imm_num);
				   printDebug("\treg_file[" + rs + "] = reg_file[" + rt + "] - " + imm_num);
	    	   }
	    	    
	    	   
	    	   PC++;
		    break;
		    
	       case 3:
				   printDebug("Instruction: Beq");
				   if (reg_file[0] == reg_file[2]) {
					   printDebug("\tTaken");
					   PC += 10;
				   } else {
					   printDebug("\tNot Taken");
					   PC++;
				   }
		    break;
		    
	       case 4:
				rs_reg_str = curr_inst.substring(3, 6);
				rt_reg_str = curr_inst.substring(6, 9);
				String imm_str = curr_inst.substring(9,11);
				imm = Integer.valueOf(imm_str,2).intValue();
				if (imm == 3) imm = 4;
				rs = Integer.valueOf(rs_reg_str,2).intValue();
				rt = Integer.valueOf(rt_reg_str,2).intValue();
				int reg_offset = imm + ((rt != 0)?reg_file[rt]:0);
				   
				if(funct == 0) {
					printDebug("Instruction: ld\n\treg_file[" + rs + "] = mem[" + reg_offset + "]");
					setReg(rs, data_mem[reg_offset]);
				}
				
				if(funct == 1) {
					printDebug("Instruction: str\n\tmem[" + reg_offset + "] = reg_file[" + rs + "]");
					setDMem(reg_offset, reg_file[rs]);
				}
	    	   
	    	   PC++;
		    break;
		    
	       case 5:
				rs_reg_str = curr_inst.substring(3, 6);
				rt_reg_str = curr_inst.substring(6, 9);
				rs = Integer.valueOf(rs_reg_str,2).intValue();
				rt = Integer.valueOf(rt_reg_str,2).intValue();
				short rs_val = reg_file[rs];
				short rt_val = reg_file[rt];
				   
				if(funct == 0) {
					printDebug("Instruction: scg");
					if (rs_val < rt_val) {
						setReg(7, reg_file[rt]);
						printDebug("\t" + rs_val + " < " + rt_val);
					} else {
						setReg(7, reg_file[rs]);
						printDebug("\t" + rt_val + " <= " + rs_val);
					}
				}
				   
				if(funct == 1) {
				   printDebug("Instruction: scl");   
					if (rt_val < rs_val) {
						setReg(6, reg_file[rt]);
						printDebug("\t" + rt_val + " < " + rs_val);
					} else {
						setReg(6, reg_file[rs]);
						printDebug("\t" + rs_val + " <= " + rt_val);
					}
				}
				   
	    	   PC++;
		    break;
		    
	       case 6:
	    	   //Jump if not equal and decrement
	    	   if(funct == 0){
	    		   printDebug("Instruction: jdne");
	    		   
	    		   //read off the target bits we use to compare our rs register with
	    		   String rt_str = curr_inst.substring(6,9);
	    		   //conver to an int value
	    		   rt = Integer.valueOf(rt_str,2).intValue();
		    	   //read off the bits for the register we use to compare to the rt value
		    	   String dec_reg = curr_inst.substring(3, 6);
		    	   //convert to int
		    	   int dec_reg_num = Integer.valueOf(dec_reg,2).intValue();
	    		   
		    	   //Compare the rs register to the rt value, 
				   if((rt == 0) && (reg_file[dec_reg_num] == 32)){
					   printDebug("\tNot Taken");
					   PC++;
					   break;
				   }
				   else if((rt == 2) && (reg_file[dec_reg_num] == 32+reg_file[0])){
					   printDebug("\tNot Taken");
	    			   PC++;
	    			   break;
	    		   }
	    		   
	    		   reg_file[dec_reg_num] = (short)(reg_file[dec_reg_num] - (short)1 );
	    	   }
		       
		      //Jump i fnot equal and increment
		       if(funct == 1){
		    	   printDebug("Instruction: jine");  
		  	   
		  	   		//	read off the target bits we use to compare our rs register with
		  	   		String rt_str = curr_inst.substring(6,9);
    		   		//conver to an int value
    		   		rt = Integer.valueOf(rt_str,2).intValue();
    		   		//read off the bits for the register we use to compare to the rt value
	    	   		String inc_reg = curr_inst.substring(3, 6);
	    	   		//convert to int
	    	   		int inc_reg_num = Integer.valueOf(inc_reg,2).intValue();
    		   
	    	   		//Compare the rs register to the rt value, 
    		   		if((reg_file[inc_reg_num] >= reg_file[rt])){
						printDebug("\tNot Taken");
    			   		PC++;
    			   		break;
    		   		}
		       
    		   		reg_file[inc_reg_num] = (short)(reg_file[inc_reg_num] + (short)1 );
				   
    		   
		       }
		    	   

		       //Read off Jump Destination bits
		       String jmp_addr = curr_inst.substring(9, 11);
		       //Convert the jmp_addr binary string to an int value
		       int jmp = Integer.valueOf(jmp_addr,2).intValue();
				
				   if (jmp_addr.equals("10")) {
					   jmp = 7;
				   } else if (jmp_addr.equals("11")) {
					   jmp = 11;
				   } else if (jmp_addr.equals("01")) {
					   jmp = 2;
				   }
							  
		       //Get the rs reg that we are decrementing, the first 3 bits after the opcode   
		       String dec_reg = curr_inst.substring(3, 6);
		       //convert the rs reg to an int value
		       int dec_reg_num = Integer.valueOf(dec_reg,2).intValue();
		       //decrement the register value   
		    	   
		       //Jump backward
		       PC = PC - jmp;
				printDebug("\tTaken back by " + jmp);
		    break;
		    
	       case 7:
				if(funct == 0) {
					printDebug("Instruction: Mov");
		    	   String mov_imm = curr_inst.substring(6, 11);
		    	   mov_imm += "000";
		    	   int mov_imm_num = Integer.valueOf(mov_imm,2).intValue();
					if (mov_imm_num != 0) mov_imm_num -= 1;
					if (mov_imm_num == 7) mov_imm_num = 1;
					if (mov_imm_num > 7) mov_imm_num = 127;
		    	   
		    	   
		    	   String rs_str = curr_inst.substring(3, 6);
		    	   rs = Integer.valueOf(rs_str,2).intValue();
		    	   reg_file[rs] = (short) mov_imm_num;
					printDebug("\treg_file[" + rs + "] = " + mov_imm_num);
	    	   }
		    	   
				if(funct == 1) {
					printDebug("Instruction: Bitcnt");
					short v = (short) reg_file[Integer.valueOf(curr_inst.substring(OPCODE_LENGTH+3, OPCODE_LENGTH+6), 2)];
					short c = (short) (v - ((v >> 1) & 0x5555));
					c = (short) (((c >> 2) & 0x3333) + (c & 0x3333));
					c = (short) (((c >> 4) + c) & 0x0F0F);
					c = (short) (((c >> 8) + c) & 0x00FF);
					printDebug("\tBits Set = " + c);
					if (c > 8)
						setReg(0, (short)(reg_file[0]+1));
				}
				PC++;
		    break;
		    
	       case 8:
		    break;
	       case 9:
		    break;
	       case 10:
		    break;
	       case 11:
		    break;
	       case 12:
		    break;
	       case 13:
		    break;
	       case 14:
		    break;
	       case 15:
		    break;
	       case 16:
		    break;
	       case 17:
		    break;
	       case 18:
		    break;
	       case 19:
		    break;
	       case 20:
		    break;
	       case 21:
		    break;
	       case 22:
		    break;
	       case 23:
		    break;
	       case 24:
		    break;
	       case 25:
		    break;
	       case 26:
		    break;
	       case 27:
		    break;
	       case 28:
		    break;
	       case 29:
		    break;
	       case 30:
		    break;
	       case 31:
		    break;
	       case 32:
		    break;
	       default:
		    System.err.println("invalid opcode encountered at PC=" + PC);
		    return;
	       }
			
		  printDebug("-----------------------------------------");
	       inst_count++; // increase our global counter

	       num_done++; // just finished another instruction
	  }
     }

	public void printDebug(String str) {
		if (debug)
			System.out.println(str);
	}
	
     // while loop asking for user input for next command
     public void run() {
	  // set up to read user input from console
	  BufferedReader cons = new BufferedReader(new InputStreamReader(System.in));

	  if(cons == null) {
	       System.out.println("No console available. Quitting.");
	       System.exit(1);
	  }

	  String input = null;
	  StringTokenizer input_tokens = null; 
	  String curr_token;

	  while(true) {
	       System.out.print(">> "); // "command prompt"

	       try {
		    input = cons.readLine(); // get input from user
	       } catch (Exception e) {
		    System.out.println("Couldn't read input.  Bye.");
		    System.exit(1);
	       }

	       input_tokens = new StringTokenizer(input); // tokenize the input for easier parsing

	       // make sure it is a valid command and do that command
	       curr_token = input_tokens.nextToken();
	       if(curr_token.equals("iload")) {
		    if(input_tokens.countTokens() != 2) System.out.println("usage: iload $file_name $start_addr");
		    else {
			 String file_name = input_tokens.nextToken();
			 int start_addr = Integer.parseInt(input_tokens.nextToken());
			 loadMem(file_name,start_addr,true);
		    }
	       }
	       else if(curr_token.equals("dload")) {
		    if(input_tokens.countTokens() != 2) System.out.println("usage: dload $file_name $start_addr");
		    else {
			 String file_name = input_tokens.nextToken();
			 int start_addr = Integer.parseInt(input_tokens.nextToken());
			 loadMem(file_name,start_addr,false);
		    }
	       }
	       else if(curr_token.equals("go")) {
		    if(input_tokens.countTokens() != 1) System.out.println("usage: go $number");
		    else {
			 int number = Integer.parseInt(input_tokens.nextToken());
			 execute(number);
		    }
	       }
	       else if(curr_token.equals("run")) {
                    while(halt == false)
                      execute(1);
	       }
	       else if(curr_token.equals("dump_reg")) {
		    printRegFile();
	       }
	       else if(curr_token.equals("set_reg")) {
		    if(input_tokens.countTokens() != 2) System.out.println("usage: set_reg $reg_num $value");
		    else {
			 int reg_num = Integer.parseInt(input_tokens.nextToken());
			 short value = (short) Integer.parseInt(input_tokens.nextToken());
			 setReg(reg_num,value);
		    }
	       }
	       else if(curr_token.equals("dump_imem")) {
		    if(input_tokens.countTokens() != 2) System.out.println("usage: dump_imem $start_addr $range");
		    else {
			 int start_addr = Integer.parseInt(input_tokens.nextToken());
			 int range = Integer.parseInt(input_tokens.nextToken());
			 printIMem(start_addr,range);
		    }
	       }
	       else if(curr_token.equals("set_imem")) {
		    if(input_tokens.countTokens() != 2) System.out.println("usage: set_imem $addr $value");
		    else {
			 int addr = Integer.parseInt(input_tokens.nextToken());
			 String value = input_tokens.nextToken();
			 setIMem(addr,value);
		    }
	       }
	       else if(curr_token.equals("dump_dmem")) {
		    if(input_tokens.countTokens() != 2) System.out.println("usage: dump_dmem $start_addr $range");
		    else {
			 int start_addr = Integer.parseInt(input_tokens.nextToken());
			 int range = Integer.parseInt(input_tokens.nextToken());
			 printDMem(start_addr,range);
		    }
	       }
	       else if(curr_token.equals("set_dmem")) {
		    if(input_tokens.countTokens() != 2) System.out.println("usage: set_dmem $addr $value");
		    else {
			 int addr = Integer.parseInt(input_tokens.nextToken());
			 short value = (short) Integer.parseInt(input_tokens.nextToken());
			 setDMem(addr,value);
		    }
	       }
	       else if(curr_token.equals("instr_count")) {
		    System.out.println(inst_count + " instructions executed so far");
	       }
	       else if(curr_token.equals("dump_pc")) {
		    System.out.println("current PC is " + PC);
	       }
	       else if(curr_token.equals("reset")) {
		    resetSimulator();
	       }
		   else if(curr_token.equals("resetPC")) {
			   PC = 0;
			   halt = false;
		   }
		   else if (curr_token.equals("toggleDebug")) {
			   debug = !debug;
		   }
	       else if(curr_token.equals("exit")) {
		    System.out.println("leaving so soon? ... Bye!");
		    break;
	       }
	       else {
		    System.out.println("unrecognized command.");
	       }
	  }
     }

     public static void main(String[] args) {
	  ISASimulator sim = new ISASimulator();

	  sim.run(); // run the simulator
     }
}
