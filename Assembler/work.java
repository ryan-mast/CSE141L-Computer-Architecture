import java.io.*;
import java.util.*;

class SymbolTableEntry
{
  String symbol;
  int address;
}

class SymbolTable
{
	int i,j;
	SymbolTableEntry[] entries;

	SymbolTable()	
	{
	    entries = new SymbolTableEntry[128];
	    for(int j=0;j<128;j++)
	      entries[j] = new SymbolTableEntry();
		i=0;
	}

	SymbolTable(int n)
	{
	    entries = new SymbolTableEntry[n];
	    for(int j=0;j<n;j++)
	      entries[j] = new SymbolTableEntry();
		i=0;
	}

	public void add(String symbol,int address)
	{
	    entries[i].symbol = symbol;
	    entries[i++].address = address;
	}

	public int find(String symbol)
	{
		for(j=0;j<i;j++)
		{
			if(symbol.equalsIgnoreCase(entries[j].symbol))
				return entries[j].address;
        }
		return -1;
	}

	public void print()
	{
		for(j=0;j<i;j++)
			System.out.println(entries[j].symbol+"\t"+(Integer.toHexString(entries[j].address)));
	}

	public int leng()
	{
		return i;
	}
}

/* The following is an assembler extends the Assembler class written by Hung-Wei */
class work extends Assembler
{
    work()	{}
    /* Constructor with every input/output file initialized*/
    work(String[] args) throws IOException
    {
    	sourceFile = new BufferedReader(new FileReader(args[0]));
    	out_code = new BufferedWriter(new FileWriter(args[1]+"_i.coe"));
    	out_data = new BufferedWriter(new FileWriter(args[1]+"_d.coe"));
    }
    /* symbol table */
    public SymbolTable symbolTable = new SymbolTable();

    /* add the labels into symbol table */
    void processLabel(String label)
    {
        if(currentCodeSection == 0)
        {
            symbolTable.add(label,programCounter);
        }
        else
        {
            symbolTable.add(label,dataMemoryAddress);
        }
    }

	public void replaceInstructionLabel(Instruction instruction)
	{
	  for(int i = 0; i < instruction.operands.length; i++)
	  {
	    if(instruction.operands[i].getOperandType().equalsIgnoreCase("label"))
	    {
	      instruction.operands[i].name = "0x"+Integer.toHexString(programCounter - symbolTable.find(instruction.operands[i].name)).toUpperCase();
        }
      }
    }

    String generateCode(Instruction instruction)
    {
      String machineCode="";
        // replace the symbols with real address
      String[] zeros={"","0","00", "000", "0000", "00000", "000000"};
      if(instruction.operator.equalsIgnoreCase("halt"))
      {
        machineCode = "000000000000";
      }
	  else if (instruction.operator.equalsIgnoreCase("tbd"))
	  {
		machineCode = "001000000000";
	  }
	  else if (instruction.operator.equalsIgnoreCase("beq"))
	  {
		machineCode = "011000010000";
	  }
      else if(instruction.operator.equalsIgnoreCase("addi"))
      {
		// opcode
        machineCode = "010";
		  
		// rt
        String register = Integer.toBinaryString(instruction.operands[0].extractRegisterNumber());
        machineCode += zeros[3 - register.length()] + register;
		
		// rs
		register = Integer.toBinaryString(instruction.operands[1].extractRegisterNumber());
		machineCode += zeros[3 - register.length()] + register;
		  
		// imm
		int imm = instruction.operands[2].extractImmediate();
		String immediate = ((imm == 1) ? "00" : ((imm == 31) ? "01" : ((imm == 32) ? "10" : "11")));
        machineCode += zeros[2 - immediate.length()] + immediate;
		  
		// funct
		machineCode += "0";
      }
      else if(instruction.operator.equalsIgnoreCase("subi"))
      {
    	  // opcode
		  machineCode = "010";
		  
		  // rt
		  String register = Integer.toBinaryString(instruction.operands[0].extractRegisterNumber());
		  machineCode += zeros[3 - register.length()] + register;
		  
		  // rs
		  register = Integer.toBinaryString(instruction.operands[1].extractRegisterNumber());
		  machineCode += zeros[3 - register.length()] + register;
		  
		  // imm
		  int imm = instruction.operands[2].extractImmediate();
		  String immediate = ((imm == 1) ? "00" : ((imm == 31) ? "01" : ((imm == 32) ? "10" : "11")));
		  machineCode += zeros[2 - immediate.length()] + immediate;
		  
		  // funct
		  machineCode += "1";
      }
      else if(instruction.operator.equalsIgnoreCase("ld"))
      {
		  // opcode
    	  machineCode = "100";
		  
		  // rt
		  String register = Integer.toBinaryString(instruction.operands[0].extractRegisterNumber());
		  machineCode += zeros[3 - register.length()] + register;
		  
		  // rs
		  if (instruction.operands[1].getOperandType().equals("register")) {
			  register = Integer.toBinaryString(instruction.operands[1].extractRegisterNumber());
			  machineCode += zeros[3 - register.length()] + register;
		  } else {
			  machineCode += "000"; // This can mean that the register operand is not used
		  }
			  
		  // imm
		  String immediate = "00";
		  int imm = 0;
		  if (instruction.operands.length > 2) {
			 imm = instruction.operands[2].extractImmediate();
			 immediate = ((imm == 4) ? "11" : ((imm == 2) ? "10" : ((imm == 1) ? "01" : "00")));
		  } else if (instruction.operands[1].getOperandType().equals("immediate")) {
			  imm = instruction.operands[1].extractImmediate();
			  immediate = ((imm == 4) ? "11" : ((imm == 2) ? "10" : ((imm == 1) ? "01" : "00")));
		  }
		  machineCode += immediate;
		  
		  // funct
		  machineCode += "0";
      }  
	  else if(instruction.operator.equalsIgnoreCase("str"))
      {
		  // opcode
    	  machineCode = "100";
		  
		  // rt
		  String register = Integer.toBinaryString(instruction.operands[0].extractRegisterNumber());
		  machineCode += zeros[3 - register.length()] + register;
		  
		  // rs
		  if (instruction.operands[1].getOperandType().equals("register")) {
			  register = Integer.toBinaryString(instruction.operands[1].extractRegisterNumber());
			  machineCode += zeros[3 - register.length()] + register;
		  } else {
			  machineCode += "000"; // This can mean that the register operand is not used
		  }
		  
		  // imm
		  String immediate = "00";
		  int imm = 0;
		  if (instruction.operands.length > 2) {
			  imm = instruction.operands[2].extractImmediate();
			  immediate = ((imm == 4) ? "11" : ((imm == 2) ? "10" : ((imm == 1) ? "01" : "00")));
		  } else if (instruction.operands[1].getOperandType().equals("immediate")) {
			  imm = instruction.operands[1].extractImmediate();
			  immediate = ((imm == 4) ? "11" : ((imm == 2) ? "10" : ((imm == 1) ? "01" : "00")));
		  }
		  machineCode += immediate;
		  
		  // funct
		  machineCode += "1";
      }
      else if(instruction.operator.equalsIgnoreCase("scg"))
      {
		  // opcode
    	  machineCode = "101";
		  
		  // rt
		  String register = Integer.toBinaryString(instruction.operands[0].extractRegisterNumber());
		  machineCode += zeros[3 - register.length()] + register;
		  
		  // rs
		  register = Integer.toBinaryString(instruction.operands[1].extractRegisterNumber());
		  machineCode += zeros[3 - register.length()] + register;
		  
		  // imm
		  machineCode += "00";
		  
		  // funct
		  machineCode += "0";
      }
      else if(instruction.operator.equalsIgnoreCase("scl"))
      {
    	  // opcode
    	  machineCode = "101";
		  
		  // rt
		  String register = Integer.toBinaryString(instruction.operands[0].extractRegisterNumber());
		  machineCode += zeros[3 - register.length()] + register;
		  
		  // rs
		  register = Integer.toBinaryString(instruction.operands[1].extractRegisterNumber());
		  machineCode += zeros[3 - register.length()] + register;
		  
		  // imm
		  machineCode += "00";
		  
		  // funct
		  machineCode += "1";
      }
      else if(instruction.operator.equalsIgnoreCase("jdne"))
      {
		  // opcode
    	  machineCode = "110";
		  
		  // rt
		  String register = Integer.toBinaryString(instruction.operands[0].extractRegisterNumber());
		  machineCode += zeros[3 - register.length()] + register;
		  
		  // rs/imm(32)
		  if (instruction.operands[1].getOperandType().equals("register")) {
			  register = Integer.toBinaryString(instruction.operands[1].extractRegisterNumber());
			  machineCode += zeros[3 - register.length()] + register;
		  } else {
			  machineCode += "000";
		  }
		  
		  // JumpOffsetBackwards
		  int imm = instruction.operands[2].extractImmediate();
		  String immediate = ((imm == 11) ? "11" : ((imm == 7) ? "10" : ((imm == 2) ? "01" : "00")));
		  machineCode += immediate;
		  
		  // funct
		  machineCode += "0";
      }
      else if(instruction.operator.equalsIgnoreCase("jine"))
      {
    	  // opcode
    	  machineCode = "110";
		  
		  // rt
		  String register = Integer.toBinaryString(instruction.operands[0].extractRegisterNumber());
		  machineCode += zeros[3 - register.length()] + register;
		  
		  // rs/imm(32)
		  if (instruction.operands[1].getOperandType().equals("register")) {
			  register = Integer.toBinaryString(instruction.operands[1].extractRegisterNumber());
			  machineCode += zeros[3 - register.length()] + register;
		  } else {
			  machineCode += "000";
		  }
		  
		  // JumpOffsetBackwards
		  int imm = instruction.operands[2].extractImmediate();
		  String immediate = ((imm == 11) ? "11" : ((imm == 7) ? "10" : ((imm == 2) ? "01" : "00")));
		  machineCode += immediate;
		  
		  // funct
		  machineCode += "1";
      }
      else if(instruction.operator.equalsIgnoreCase("mov"))
      {
		  // opcode
    	  machineCode = "111";
		  
		  // rt
		  String register = Integer.toBinaryString(instruction.operands[0].extractRegisterNumber());
		  machineCode += zeros[3 - register.length()] + register;
		  
		  // imm
		  int imm = instruction.operands[1].extractImmediate();
		  String immediate = Integer.toBinaryString(imm >> 3);
		  if ((imm >> 3) > 1)
			  immediate = "10";
		  machineCode += zeros[5 - immediate.length()] + immediate;

		  // funct
		  machineCode += "0";
      }
      else if(instruction.operator.equalsIgnoreCase("bitcnt"))
      {
    	  // opcode
		  machineCode = "111";
		  
		  // rt
		  String register = Integer.toBinaryString(instruction.operands[0].extractRegisterNumber());
		  machineCode += "000";
		  machineCode += zeros[3 - register.length()] + register;
		  
		  // junk
		  machineCode += "00";
		  
		  // funct
		  machineCode += "1";
      }
      else
      {
        System.out.println("Unknown Instruction!: " + instruction.operator);
        return null;
      } 
      return machineCode;
    }

    void initialization() throws IOException
    {
      //BufferedReader machineDefinitionFile;
      //machineDefinitionFile = new BufferedReader(new FileReader("machine.def"));
      String keywordString = ".text .word .data .fill";
      keywords = keywordString.split(" ");
    }

    void updateProgramCounter(Instruction instruction)
    {
          programCounter++;
    }

    void replaceMemoryLabel()
    {
      for(int j=0;j<memory.leng();j++)
      {
	    if(Assembler.getOperandType(memory.entries[j].data)=="label")
	    {
		  String[] zeros={"","0","00","000","0000","00000","000000","0000000","00000000","000000000"};
		  memory.entries[j].data = "0x"+zeros[6 - Integer.toHexString(symbolTable.find(memory.entries[j].data)).toUpperCase().length()] +Integer.toHexString(symbolTable.find(memory.entries[j].data)).toUpperCase();
        }
      }
    }

    public static void main(String[] arg) throws IOException 
    {
      work assembler = new work(arg);
      assembler.AssembleCode(arg);
    }

}
