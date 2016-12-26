module CPU
(
	clk_i,
	rst_i,
	start_i,
   
	mem_data_i, 
	mem_ack_i, 	
	mem_data_o, 
	mem_addr_o, 	
	mem_enable_o, 
	mem_write_o
);

//input
input clk_i;
input rst_i;
input start_i;

initial begin
  $dumpfile("mytest.vcd");
  $dumpvars;
end

//
// to Data Memory interface		
//
input	[256-1:0]	mem_data_i; 
input				mem_ack_i; 	
output	[256-1:0]	mem_data_o; 
output	[32-1:0]	mem_addr_o; 	
output				mem_enable_o; 
output				mem_write_o; 

//
// add your project1 here!
//

wire	[31:0]	inst_addr, inst, mux5_o, RSdata, RTdata, pc4addr, mux7_o, mux1_o;
wire	[31:0] 	EXMEM_ALUresult, signExt, IDEX_immediate, Jump_32;
wire	[27:0]	Jump_28;
wire	[4:0]   MEMWB_RDaddr, IDEX_RSaddr, IDEX_RTaddr, EXMEM_RDaddr;
wire			MEMWB_RegWrite, Branch, Equal, Jump, isBranch, Flush;
wire			IDEX_MemRead, EXMEM_RegWrite;

assign isBranch = Branch & Equal;
assign Flush = Jump | isBranch;
assign Jump_32 = {mux1_o[31:28], Jump_28};

initial begin
  $dumpfile("mytest.vcd");
  $dumpvars;
end

// Add_BeqAddr
wire [31:0] shift_beq_data;
wire [31:0] IFID_pc4addr_o;
wire [31:0] add_beq_out;

// PC
wire        PCWrite;
wire [31:0] PC_i;

// Instruction Memory
wire [31:0] instr;

// Data Memory
wire [31:0] DM_data;
wire        DM_write;
wire        DM_read;

// Mux8
wire        mux8_RegDst;
wire        mux8_ALUSrc;
wire [1:0]  mux8_ALUOp;
wire        mux8_MemRead;
wire        mux8_MemToReg;
wire        mux8_RegWrite;
wire        mux8_select;

wire        mux8_RegDst_o;
wire        mux8_ALUSrc_o;
wire [1:0]  mux8_ALUOp_o;
wire        mux8_MemRead_o;
wire        mux8_MemToReg_o;
wire        mux8_RegWrite_o;
wire        mux8_select_o;

// Mux3
wire [4:0]  mux3_data2;
wire        mux3_select;
wire [4:0]  mux3_data_o;

// Mux4
wire        mux4_select;

// Mux5
wire        mux5_select;
wire [31:0] mux5_data1;
wire [31:0] mux5_data2;

// Mux6
wire [1:0]  mux6_select;
wire [31:0] mux6_dataDft;

// Mux7
wire [1:0]  mux7_select;
wire [31:0] mux7_dataDft;

// ALU
wire [31:0] ALUresult;
wire [31:0] ALU_data1;
wire [31:0] ALU_data2;

// ALU Control
wire [2:0]  ALUCtrl;
wire [1:0]  ALUOp;

// IF_ID
wire WriteIFID;

// ID_EX to EX_MEM
wire        EX_MemRead, EX_MemWrite, EX_MemtoReg, EX_RegWrite;

// EX_MEM to MEM_WB
wire        MEM_MemtoReg;
wire [31:0]	MEM_Memdata;

//Stall
wire stall;

Control Control(
  .Op_i       (inst[31:26]),
  .RegDst_o   (mux8_RegDst),
  .ALUSrc_o   (mux8_ALUSrc),
  .MemtoReg_o (mux8_MemtoReg),
  .RegWrite_o (mux8_RegWrite),
  .MemRead_o	(mux8_MemRead),
  .MemWrite_o	(mux8_MemWrite),
  .Branch_o	(Branch),
  .Jump_o		(Jump),
  .ALUOp_o	(mux8_ALUOp)
);


Adder Add_PC(
  .data1_i	(inst_addr),
  .data2_i   	(32'd4),
  .data_o     (pc4addr)
);

Adder Add_BeqAddr(
  .data1_i	(shift_beq_data),
  .data2_i   	(IFID_pc4addr_o),
  .data_o     (add_beq_out)
);

Sign_Extend Sign_Extend(
  .data_i     (inst[15:0]),
  .data_o     (signExt)
);

Hazard_Detection Hazard_Detection(
  .IDEX_MemRead_i	(IDEX_MemRead),
  .IDEX_RegRT_i	(IDEX_RTaddr),
  .IFID_RegRS_i	(inst[25:21]),
  .IFID_RegRT_i	(inst[20:16]),

  .WritePC_o		(PCWrite),
  .WriteIFID_o	(WriteIFID),
  .mux8_o			(mux8_select)
);

Forwarding	Forwarding(
  .EXMEM_RegWrite_i	(EXMEM_RegWrite),
  .EXMEM_RegRD_i		(EXMEM_RDaddr),
  .MEMWB_RegWrite_i	(MEMWB_RegWrite),
  .MEMWB_RegRD_i		(MEMWB_RDaddr),
  .IDEX_RegRS_i		(IDEX_RSaddr),
  .IDEX_RegRT_i		(IDEX_RTaddr),

  .ForwardA_o			(mux6_select),
  .ForwardB_o			(mux7_select)
);

ALU ALU(
  .data1_i    (ALU_data1),
  .data2_i    (ALU_data2),
  .ALUCtrl_i  (ALUCtrl),
  .data_o     (ALUresult)
);



ALU_Control ALU_Control(
  .funct_i    (IDEX_immediate[5:0]),
  .ALUOp_i    (ALUOp),
  .ALUCtrl_o  (ALUCtrl)
);



IF_ID IF_ID(
  .clk_i      (clk_i),
  .WriteIFID_i (WriteIFID),
  .Flush_i	(Flush),
  .pc4addr_i	(pc4addr),
  .instr_i	(instr),
  .stall_i  (stall),
  .pc4addr_o	(IFID_pc4addr_o),
  .instr_o	(inst)
);

ID_EX ID_EX(
  .clk_i      (clk_i),
  .RegDst_i   (mux8_RegDst_o),
  .ALUSrc_i   (mux8_ALUSrc_o),
  .ALUOp_i	(mux8_ALUOp_o),
  .MemRead_i	(mux8_MemRead_o),
  .MemWrite_i	(mux8_MemWrite_o),
  .MemtoReg_i (mux8_MemtoReg_o),
  .RegWrite_i (mux8_RegWrite_o),

  .RSdata_i	(RSdata),
  .RTdata_i	(RTdata),
  .immediate_i(signExt),
  .RSaddr_i	(inst[25:21]),
  .RTaddr_i	(inst[20:16]),
  .RDaddr_i	(inst[15:11]),
  .stall_i  (stall),

  .RegDst_o   (mux3_select),
  .ALUSrc_o   (mux4_select),
  .ALUOp_o	(ALUOp),
  .MemRead_o	(IDEX_MemRead),
  .MemWrite_o	(EX_MemWrite),
  .MemtoReg_o (EX_MemtoReg),
  .RegWrite_o (EX_RegWrite),

  .RSdata_o	(mux6_dataDft),
  .RTdata_o	(mux7_dataDft),
  .immediate_o(IDEX_immediate),
  .RSaddr_o	(IDEX_RSaddr),
  .RTaddr_o	(IDEX_RTaddr),
  .RDaddr_o	(mux3_data2)
);

EX_MEM EX_MEM(
  .clk_i      (clk_i),
  .MemRead_i  (IDEX_MemRead),
  .MemWrite_i	(EX_MemWrite),
  .MemtoReg_i (EX_MemtoReg),
  .RegWrite_i (EX_RegWrite),

  .ALUresult_i(ALUresult),
  .RDdata_i	(mux7_o),
  .RDaddr_i	(mux3_data_o),
  .stall_i  (stall),

  .MemRead_o  (DM_read),
  .MemWrite_o	(DM_write),
  .MemtoReg_o (MEM_MemtoReg),
  .RegWrite_o (EXMEM_RegWrite),

  .ALUresult_o(EXMEM_ALUresult),
  .RDdata_o	(DM_data),
  .RDaddr_o	(EXMEM_RDaddr)
);

MEM_WB MEM_WB(
  .clk_i      (clk_i),
  .MemtoReg_i (MEM_MemtoReg),
  .RegWrite_i (EXMEM_RegWrite),

  .Memdata_i	(MEM_Memdata),
  .ALUresult_i(EXMEM_ALUresult),
  .RDaddr_i	(EXMEM_RDaddr),
  .stall_i  (stall),

  .MemtoReg_o (mux5_select),
  .RegWrite_o (MEMWB_RegWrite),

  .Memdata_o	(mux5_data2),
  .ALUresult_o(mux5_data1),
  .RDaddr_o	(MEMWB_RDaddr)
);

Eq Eq(
  .data1_i	(RSdata),
  .data2_i	(RTdata),
  .Equal_o	(Equal)
);

Shift_Jump Shift_Jump(
  .data_i		(inst[25:0]),
  .data_o		(Jump_28)
);

Shift_Beq Shift_Beq(
  .data_i		(signExt),
  .data_o		(shift_beq_data)
);

MUX32 mux1(
  .data1_i    (pc4addr),
  .data2_i    (add_beq_out),
  .select_i   (isBranch),
  .data_o     (mux1_o)
);

MUX32 mux2(
  .data1_i    (mux1_o),
  .data2_i    (Jump_32),
  .select_i   (Jump),
  .data_o     (PC_i)
);

MUX5 mux3(
  .data1_i    (IDEX_RTaddr),
  .data2_i    (mux3_data2),
  .select_i   (mux3_select),
  .data_o     (mux3_data_o)
); 

MUX32 mux4(
  .data1_i    (mux7_o),
  .data2_i    (IDEX_immediate),
  .select_i   (mux4_select),
  .data_o     (ALU_data2)
);

MUX32 mux5(
  .data1_i    (mux5_data1),
  .data2_i    (mux5_data2),
  .select_i   (mux5_select),
  .data_o     (mux5_o)
);

MUX_Forward mux6(
  .dataEX_i	(EXMEM_ALUresult),
  .dataMEM_i	(mux5_o),
  .dataDft_i	(mux6_dataDft),
  .select_i	(mux6_select),
  .data_o		(ALU_data1)
);

MUX_Forward mux7(
  .dataEX_i	(EXMEM_ALUresult),
  .dataMEM_i	(mux5_o),
  .dataDft_i	(mux7_dataDft),
  .select_i	(mux7_select),
  .data_o		(mux7_o)
);

MUX_Hazard mux8(
  .RegDst_i   (mux8_RegDst),
  .ALUSrc_i   (mux8_ALUSrc),
  .ALUOp_i	(mux8_ALUOp),
  .MemRead_i	(mux8_MemRead),
  .MemWrite_i	(mux8_MemWrite),
  .MemtoReg_i (mux8_MemtoReg),
  .RegWrite_i (mux8_RegWrite),
  .select_i	(mux8_select),

  .RegDst_o   (mux8_RegDst_o),
  .ALUSrc_o   (mux8_ALUSrc_o),
  .ALUOp_o	(mux8_ALUOp_o),
  .MemRead_o	(mux8_MemRead_o),
  .MemWrite_o	(mux8_MemWrite_o),
  .MemtoReg_o (mux8_MemtoReg_o),
  .RegWrite_o (mux8_RegWrite_o)
);
/*
PC PC(
  .clk_i        (clk_i),
  .start_i      (start_i),
  .PCWrite_i	  (PCWrite),
  .pc_i         (PC_i),
  .pc_o         (inst_addr)
);

Instruction_Memory Instruction_Memory(
  .addr_i     (inst_addr),
  .instr_o    (instr)
);

Registers Registers(
  .clk_i      (clk_i),
  .RSaddr_i   (inst[25:21]),
  .RTaddr_i   (inst[20:16]),
  .RDaddr_i   (MEMWB_RDaddr),
  .RDdata_i   (mux5_o),
  .RegWrite_i (MEMWB_RegWrite),
  .RSdata_o   (RSdata),
  .RTdata_o   (RTdata)
);

Data_Memory Data_Memory(
  .clk_i      (clk_i),
  .addr_i     (EXMEM_ALUresult),
  .data_i		  (DM_data),
  .MemRead_i	(DM_read),
  .MemWrite_i	(DM_write),
  .data_o    	(MEM_Memdata)
);
*/

PC PC
(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.start_i(start_i),
	.pcEnable_i(PCWrite),
	.pc_i(PC_i),
	.stall_i(stall),
	.pc_o(inst_addr)
);

Instruction_Memory Instruction_Memory(
	.addr_i(inst_addr), 
	.instr_o(instr)
);

Registers Registers(
	.clk_i(clk_i),
	.RSaddr_i(inst[25:21]),
	.RTaddr_i(inst[20:16]),
	.RDaddr_i(MEMWB_RDaddr), 
	.RDdata_i(mux5_o),
	.RegWrite_i(MEMWB_RegWrite), 
	.RSdata_o(RSdata), 
	.RTdata_o(RTdata) 
);

//data cache
dcache_top dcache
(
    // System clock, reset and stall
	.clk_i(clk_i), 
	.rst_i(rst_i),
	
	// to Data Memory interface		
	.mem_data_i(mem_data_i), 
	.mem_ack_i(mem_ack_i), 	
	.mem_data_o(mem_data_o), 
	.mem_addr_o(mem_addr_o), 	
	.mem_enable_o(mem_enable_o), 
	.mem_write_o(mem_write_o), 
	
	// to CPU interface	
	.p1_data_i(DM_data), 
	.p1_addr_i(EXMEM_ALUresult), 	
	.p1_MemRead_i(DM_read), 
	.p1_MemWrite_i(DM_write), 
	.p1_data_o(MEM_Memdata), 
	.p1_stall_o(stall)
);

endmodule
