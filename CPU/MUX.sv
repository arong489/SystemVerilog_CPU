`timescale 1ns/1ps
module MUX #(
    parameter Select_Width=1,
    localparam Input_Num=1<<Select_Width,
    parameter data_Width = 32
)(
    input [Select_Width-1:0] Select,
    input [data_Width-1:0] Inputs [Input_Num-1:0],
    output [data_Width-1:0] Output
);
    assign Output = Inputs[Select];
endmodule : MUX