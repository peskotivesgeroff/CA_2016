module IF_ID
(
    clk_i,
    Flush_i,
    WriteIFID_i,
	pc4addr_i,
	instr_i,
	pc4addr_o,
	instr_o
);


input               clk_i, Flush_i, WriteIFID_i;
input   [31:0]      pc4addr_i, instr_i;
output  [31:0]      pc4addr_o, instr_o;

reg     [31:0]      pc4addr_o, instr_o;

always@(posedge clk_i) begin
  //$display("instr_i: %b", instr_i);
  //$display("instr_o: %b", instr_o);
  //$display("Writeifid_i_in: %b", WriteIFID_i);
    if(WriteIFID_i) begin
		if(Flush_i) begin
			pc4addr_o <= 32'b0;
			instr_o <= 32'b0;
		end
		else begin
			pc4addr_o <= pc4addr_i;
			instr_o <= instr_i;
		end
    end
    else begin
    	pc4addr_o <= pc4addr_o;
		instr_o <= instr_o;
    end
end

endmodule
