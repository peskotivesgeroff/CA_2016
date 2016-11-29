module Eq
(
    data1_i,
    data2_i,
    Equal_o
);

input   [31:0]      data1_i, data2_i;
output				Equal_o;

reg					Equal_o;

always@(data1_i or data2_i) begin
    if(data1_i == data2_i)
		Equal_o = 1;
	else
		Equal_o = 0;
end

endmodule
