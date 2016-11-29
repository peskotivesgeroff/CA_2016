module Hazard_Detection
(
    IDEX_MemRead_i,
	IDEX_RegRT_i,
	IFID_RegRS_i,
	IFID_RegRT_i,

	WritePC_o,
	WriteIFID_o,
	mux8_o
);

input               IDEX_MemRead_i;
input   [4:0]		IDEX_RegRT_i, IFID_RegRS_i, IFID_RegRT_i;
output              WritePC_o, WriteIFID_o, mux8_o;

reg					WritePC_o, WriteIFID_o, mux8_o;
initial WritePC_o = 1'b1;
initial WriteIFID_o = 1'b1;
initial mux8_o = 1'b0;

//always@(*) begin
  //$display("Writeifid_o: %b", WriteIFID_o);
//end

always@(IDEX_MemRead_i or IDEX_RegRT_i or IFID_RegRS_i or IFID_RegRT_i) begin
  if(IDEX_MemRead_i && ((IDEX_RegRT_i == IFID_RegRS_i) || (IDEX_RegRT_i ==IFID_RegRT_i))) begin //stall
    	WritePC_o = 1'b0;
    	WriteIFID_o = 1'b0;
    	mux8_o	  = 1'b1;
    end
	else begin
		WritePC_o = 1'b1;
		WriteIFID_o = 1'b1;
    	mux8_o	  = 1'b0;
	end
end

endmodule
