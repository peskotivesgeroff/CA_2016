module MUX_Forward
(
	dataEX_i,
	dataMEM_i,
	dataDft_i,
	select_i,
	data_o
);

input   [31:0]      dataEX_i, dataMEM_i, dataDft_i;
input	[1:0]		select_i;
output  [31:0]      data_o;

assign data_o = (select_i == 2'b10) ? dataEX_i:
				(select_i == 2'b01) ? dataMEM_i:
				dataDft_i;

endmodule
