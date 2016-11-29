module Forwarding
(
    EXMEM_RegWrite_i,
	EXMEM_RegRD_i,
	MEMWB_RegWrite_i,
	MEMWB_RegRD_i,
	IDEX_RegRS_i,
	IDEX_RegRT_i,

	ForwardA_o,
	ForwardB_o
);

input				EXMEM_RegWrite_i, MEMWB_RegWrite_i;
input   [4:0]       EXMEM_RegRD_i, MEMWB_RegRD_i, IDEX_RegRS_i, IDEX_RegRT_i;
output	[1:0]		ForwardA_o, ForwardB_o;

reg		[1:0]		ForwardA_o, ForwardB_o;


always@(EXMEM_RegWrite_i or MEMWB_RegWrite_i or  EXMEM_RegRD_i or MEMWB_RegRD_i or IDEX_RegRS_i or IDEX_RegRT_i) begin
    if(EXMEM_RegWrite_i && (EXMEM_RegRD_i != 5'b0) && (EXMEM_RegRD_i == IDEX_RegRS_i))
		ForwardA_o = 2'b10;
	else begin
		if(MEMWB_RegWrite_i && (MEMWB_RegRD_i != 5'b0) && (MEMWB_RegRD_i == IDEX_RegRS_i))
			ForwardA_o = 2'b01;
		else
			ForwardA_o = 2'b11;
	end

	if(EXMEM_RegWrite_i && (EXMEM_RegRD_i != 5'b0) && (EXMEM_RegRD_i == IDEX_RegRT_i))
		ForwardB_o = 2'b10;
	else begin
		if(MEMWB_RegWrite_i && (MEMWB_RegRD_i != 5'b0) && (MEMWB_RegRD_i == IDEX_RegRT_i))
			ForwardB_o = 2'b01;
		else
			ForwardB_o = 2'b11;
	end

end

endmodule
