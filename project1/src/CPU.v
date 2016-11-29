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

Control Control(
    .Op_i       (inst[31:26]),
    .RegDst_o   (mux8.RegDst_i),
    .ALUSrc_o   (mux8.ALUSrc_i),
    .MemtoReg_o (mux8.MemtoReg_i),
    .RegWrite_o (mux8.RegWrite_i),
    .MemRead_o	(mux8.MemRead_i),
    .MemWrite_o	(mux8.MemWrite_i),
    .Branch_o	(Branch),
    .Jump_o		(Jump),
    .ALUOp_o	(mux8.ALUOp_i)
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
	.WriteIFID_o	(IF_ID.WriteIFID_i),
	.mux8_o			(mux8.select_i)
);

Forwarding	Forwarding(
	.EXMEM_RegWrite_i	(EXMEM_RegWrite),
	.EXMEM_RegRD_i		(EXMEM_RDaddr),
	.MEMWB_RegWrite_i	(MEMWB_RegWrite),
	.MEMWB_RegRD_i		(MEMWB_RDaddr),
	.IDEX_RegRS_i		(ID_EX.RSaddr_o),
	.IDEX_RegRT_i		(IDEX_RTaddr),

	.ForwardA_o			(mux6.select_i),
	.ForwardB_o			(mux7.select_i)
);

ALU ALU(
    .data1_i    (mux6.data_o),
    .data2_i    (mux4.data_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (EX_MEM.ALUresult_i)
);



ALU_Control ALU_Control(
    .funct_i    (IDEX_immediate[5:0]),
    .ALUOp_i    (ID_EX.ALUOp_o),
    .ALUCtrl_o  (ALU.ALUCtrl_i)
);



IF_ID IF_ID(
	.clk_i      (clk_i),
	.WriteIFID_i(Hazard_Detection.WriteIFID_o),
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

    .RegDst_o   (mux3.select_i),
    .ALUSrc_o   (mux4.select_i),
    .ALUOp_o	(ALU_Control.ALUOp_i),
    .MemRead_o	(IDEX_MemRead),
    .MemWrite_o	(EX_MEM.MemWrite_i),
    .MemtoReg_o (EX_MEM.MemtoReg_i),
    .RegWrite_o (EX_MEM.RegWrite_i),

    .RSdata_o	(mux6.dataDft_i),
    .RTdata_o	(mux7.dataDft_i),
    .immediate_o(IDEX_immediate),
    .RSaddr_o	(Forwarding.IDEX_RegRS_i),
    .RTaddr_o	(IDEX_RTaddr),
    .RDaddr_o	(mux3.data2_i)
);

EX_MEM EX_MEM(
	.clk_i      (clk_i),
	.MemRead_i  (IDEX_MemRead),
    .MemWrite_i	(ID_EX.MemWrite_o),
    .MemtoReg_i (ID_EX.MemtoReg_o),
    .RegWrite_i (ID_EX.RegWrite_o),

    .ALUresult_i(ALU.data_o),
    .RDdata_i	(mux7_o),
    .RDaddr_i	(mux3.data_o),

    .MemRead_o  (Data_Memory.MemRead_i),
    .MemWrite_o	(Data_Memory.MemWrite_i),
    .MemtoReg_o (MEM_WB.MemtoReg_i),
    .RegWrite_o (EXMEM_RegWrite),

    .ALUresult_o(EXMEM_ALUresult),
    .RDdata_o	(Data_Memory.data_i),
    .RDaddr_o	(EXMEM_RDaddr)
);

MEM_WB MEM_WB(
	.clk_i      (clk_i),
    .MemtoReg_i (EX_MEM.MemtoReg_o),
    .RegWrite_i (EXMEM_RegWrite),

    .Memdata_i	(Data_Memory.data_o),
    .ALUresult_i(EXMEM_ALUresult),
    .RDaddr_i	(EXMEM_RDaddr),

    .MemtoReg_o (mux5.select_i),
    .RegWrite_o (MEMWB_RegWrite),

    .Memdata_o	(mux5.data2_i),
    .ALUresult_o(mux5.data1_i),
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
    .data2_i    (ID_EX.RDaddr_o),
    .select_i   (ID_EX.RegDst_o),
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
    .select_i   (ID_EX.ALUSrc_o),
    .data_o     (ALU.data2_i)
);

MUX32 mux5(
    .data1_i    (MEM_WB.ALUresult_o),
    .data2_i    (MEM_WB.Memdata_o),
    .select_i   (MEM_WB.MemtoReg_o),
    .data_o     (mux5_o)
);

MUX_Forward mux6(
	.dataEX_i	(EXMEM_ALUresult),
	.dataMEM_i	(mux5_o),
	.dataDft_i	(ID_EX.RSdata_o),
	.select_i	(Forwarding.ForwardA_o),
	.data_o		(ALU.data1_i)
);

MUX_Forward mux7(
	.dataEX_i	(EXMEM_ALUresult),
	.dataMEM_i	(mux5_o),
	.dataDft_i	(ID_EX.RTdata_o),
	.select_i	(Forwarding.ForwardB_o),
	.data_o		(mux7_o)
);

MUX_Hazard mux8(
	.RegDst_i   (Control.RegDst_o),
    .ALUSrc_i   (Control.ALUSrc_o),
    .ALUOp_i	(Control.ALUOp_o),
    .MemRead_i	(Control.MemRead_o),
    .MemWrite_i	(Control.MemWrite_o),
    .MemtoReg_i (Control.MemtoReg_o),
    .RegWrite_i (Control.RegWrite_o),
    .select_i	(Hazard_Detection.mux8_o),

    .RegDst_o   (ID_EX.RegDst_i),
    .ALUSrc_o   (ID_EX.ALUSrc_i),
    .ALUOp_o	(ID_EX.ALUOp_i),
    .MemRead_o	(ID_EX.MemRead_i),
    .MemWrite_o	(ID_EX.MemWrite_i),
    .MemtoReg_o (ID_EX.MemtoReg_i),
    .RegWrite_o (ID_EX.RegWrite_i)
);

always @(*) begin
  //$display("HD: %d", Hazard_Detection.WritePC_o);
  //$display("PCWrite: %d", PC.PCWrite_i);
  //$display("rs: %b", Registers.RSdata_o);
  //$display("rt: %b", Registers.RTdata_o);
  //$display("rd: %b", Registers.RDdata_i);
  //$display("rd_addr: %b", Registers.RDaddr_i);
end

endmodule

