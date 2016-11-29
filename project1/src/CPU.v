module CPU
(
  clk_i,
  start_i
);

// Ports
input               clk_i;
input               start_i;

wire	[31:0]	inst_addr, inst, mux5_o, RSdata, RTdata, pc4addr, mux7_o, mux1_o;
wire	[31:0] 	EXMEM_ALUresult, signExt, IDEX_immediate, Jump_32;
wire	[27:0]	Jump_28;
wire	[4:0]   MEMWB_RDaddr, IDEX_RTaddr, EXMEM_RDaddr;
wire			MEMWB_RegWrite, Branch, Equal, Jump, isBranch, Flush;
wire			IDEX_MemRead, EXMEM_RegWrite;

assign isBranch = Branch & Equal;
assign Flush = Jump | isBranch;
assign Jump_32 = {mux1_o[31:28], Jump_28};

initial begin
  $dumpfile("mytest.vcd");
  $dumpvars;
end
wire WriteIFID;

wire        mux8_RegDst;
wire        mux8_ALUSrc;
wire [1:0]  mux8_ALUOp;
wire        mux8_MemRead;
wire        mux8_MemToReg;
wire        mux8_RegWrite;
wire        mux8_select;

wire [4:0]  mux3_data2;
wire        mux3_select;

wire        mux4_select;

wire        mux5_select;
wire [31:0] mux5_data1;
wire [31:0] mux5_data2;

wire [1:0]  mux6_select;
wire [31:0] mux6_dataDft;

wire [1:0]  mux7_select;
wire [31:0] mux7_dataDft;

wire [31:0] ALUresult;

wire        EX_MemRead, EX_MemWrite, EX_MemtoReg, EX_RegWrite;
wire        MEM_MemtoReg;

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
  .data1_i	(Shift_Beq.data_o),
  .data2_i   	(IF_ID.pc4addr_o),
  .data_o     (mux1.data2_i)
);


PC PC(
  .clk_i        (clk_i),
  .start_i      (start_i),
  .PCWrite_i	(Hazard_Detection.WritePC_o),
  .pc_i         (mux2.data_o),
  .pc_o         (inst_addr)
);

Instruction_Memory Instruction_Memory(
  .addr_i     (inst_addr),
  .instr_o    (IF_ID.instr_i)
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
  .addr_i     (EXMEM_ALUresult),
  .data_i		(EX_MEM.RDdata_o),
  .MemRead_i	(EX_MEM.MemRead_o),
  .MemWrite_i	(EX_MEM.MemWrite_o),
  .data_o    	(MEM_WB.Memdata_i)
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

  .WritePC_o		(PC.PCWrite_i),
  .WriteIFID_o	(WriteIFID),
  .mux8_o			(mux8_select)
);

Forwarding	Forwarding(
  .EXMEM_RegWrite_i	(EXMEM_RegWrite),
  .EXMEM_RegRD_i		(EXMEM_RDaddr),
  .MEMWB_RegWrite_i	(MEMWB_RegWrite),
  .MEMWB_RegRD_i		(MEMWB_RDaddr),
  .IDEX_RegRS_i		(ID_EX.RSaddr_o),
  .IDEX_RegRT_i		(IDEX_RTaddr),

  .ForwardA_o			(mux6_select),
  .ForwardB_o			(mux7_select)
);

ALU ALU(
  .data1_i    (mux6.data_o),
  .data2_i    (mux4.data_o),
  .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
  .data_o     (ALUresult)
);



ALU_Control ALU_Control(
  .funct_i    (IDEX_immediate[5:0]),
  .ALUOp_i    (ID_EX.ALUOp_o),
  .ALUCtrl_o  (ALU.ALUCtrl_i)
);



IF_ID IF_ID(
  .clk_i      (clk_i),
  .WriteIFID_i (WriteIFID),
  .Flush_i	(Flush),
  .pc4addr_i	(pc4addr),
  .instr_i	(Instruction_Memory.instr_o),
  .pc4addr_o	(Add_BeqAddr.data2_i),
  .instr_o	(inst)
);

ID_EX ID_EX(
  .clk_i      (clk_i),
  .RegDst_i   (mux8.RegDst_o),
  .ALUSrc_i   (mux8.ALUSrc_o),
  .ALUOp_i	(mux8.ALUOp_o),
  .MemRead_i	(mux8.MemRead_o),
  .MemWrite_i	(mux8.MemWrite_o),
  .MemtoReg_i (mux8.MemtoReg_o),
  .RegWrite_i (mux8.RegWrite_o),

  .RSdata_i	(RSdata),
  .RTdata_i	(RTdata),
  .immediate_i(signExt),
  .RSaddr_i	(inst[25:21]),
  .RTaddr_i	(inst[20:16]),
  .RDaddr_i	(inst[15:11]),

  .RegDst_o   (mux3_select),
  .ALUSrc_o   (mux4_select),
  .ALUOp_o	(ALU_Control.ALUOp_i),
  .MemRead_o	(IDEX_MemRead),
  .MemWrite_o	(EX_MemWrite),
  .MemtoReg_o (EX_MemtoReg),
  .RegWrite_o (EX_RegWrite),

  .RSdata_o	(mux6_dataDft),
  .RTdata_o	(mux7_dataDft),
  .immediate_o(IDEX_immediate),
  .RSaddr_o	(Forwarding.IDEX_RegRS_i),
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
  .RDaddr_i	(mux3.data_o),

  .MemRead_o  (Data_Memory.MemRead_i),
  .MemWrite_o	(Data_Memory.MemWrite_i),
  .MemtoReg_o (MEM_MemtoReg),
  .RegWrite_o (EXMEM_RegWrite),

  .ALUresult_o(EXMEM_ALUresult),
  .RDdata_o	(Data_Memory.data_i),
  .RDaddr_o	(EXMEM_RDaddr)
);

MEM_WB MEM_WB(
  .clk_i      (clk_i),
  .MemtoReg_i (MEM_MemtoReg),
  .RegWrite_i (EXMEM_RegWrite),

  .Memdata_i	(Data_Memory.data_o),
  .ALUresult_i(EXMEM_ALUresult),
  .RDaddr_i	(EXMEM_RDaddr),

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
  .data_o		(Add_BeqAddr.data1_i)
);

MUX5 mux3(
  .data1_i    (IDEX_RTaddr),
  .data2_i    (mux3_data2),
  .select_i   (mux3_select),
  .data_o     (EX_MEM.RDaddr_i)
); 
MUX32 mux1(
  .data1_i    (pc4addr),
  .data2_i    (Add_BeqAddr.data_o),
  .select_i   (isBranch),
  .data_o     (mux1_o)
);

MUX32 mux2(
  .data1_i    (mux1_o),
  .data2_i    (Jump_32),
  .select_i   (Jump),
  .data_o     (PC.pc_i)
);

MUX32 mux4(
  .data1_i    (mux7_o),
  .data2_i    (IDEX_immediate),
  .select_i   (mux4_select),
  .data_o     (ALU.data2_i)
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
  .data_o		(ALU.data1_i)
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

  .RegDst_o   (ID_EX.RegDst_i),
  .ALUSrc_o   (ID_EX.ALUSrc_i),
  .ALUOp_o	(ID_EX.ALUOp_i),
  .MemRead_o	(ID_EX.MemRead_i),
  .MemWrite_o	(ID_EX.MemWrite_i),
  .MemtoReg_o (ID_EX.MemtoReg_i),
  .RegWrite_o (ID_EX.RegWrite_i)
);

always @(posedge clk_i) begin
  //$display("ALU_data2: %b", ALU.data2_i);
  //$display("mux4_data1: %b", mux4.data1_i);
  //$display("mux4_data2: %b", mux4.data2_i);
  //$display("mux4_select: %b", mux4.select_i);
  //$display("Ctrl_o: %b", Control.ALUSrc_o);
  //$display("mux8_i: %b", mux8.ALUSrc_i);
  //$display("idexo: %b", ID_EX.RDaddr_o);
  //$display("exmemo: %b", EX_MEM.RDaddr_o);
  //$display("mux3_i2: %b", mux3.data2_i);
  //$display("mux3_i1: %b", mux3.data1_i);
  //$display("mux3_sel: %b", mux3.select_i);
  //$display("Instr_i: %b", IF_ID.instr_i);
  //$display("rdaddr_o: %b", MEM_WB.RDaddr_o);
  //$display("HD: %d", Hazard_Detection.WritePC_o);
  //$display("PCWrite: %d", PC.PCWrite_i);
  //$display("rs: %b", Registers.RSdata_o);
  //$display("rt: %b", Registers.RTdata_o);
  //$display("rd: %b", Registers.RDdata_i);
  //$display("rd_addr: %b", Registers.RDaddr_i);
  //$display("Writeifid_o: %b", Hazard_Detection.WriteIFID_o);
  //$display("Writeifid_i: %b", IF_ID.WriteIFID_i);
  //$display("WriteIFID: %b", WriteIFID);
end

endmodule

