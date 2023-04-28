`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Prajwal H N 
// 
// Create Date: 11.04.2023 19:48:38
//
// Design Name: 
// Module Name: APB_Slave
// Project Name: AHB2APB Bridge 
//////////////////////////////////////////////////////////////////////////////////


module APB_Slave(Pwrite, Pselx, Penable, Paddr, Pwdata, Prdata);

//Port Declarations:
input Pwrite,Penable;
input [2:0] Pselx;
input [31:0] Pwdata,Paddr;
output reg [31:0] Prdata;


//Generating Prdata:
always@(*)
begin
    if (~Pwrite && Penable)
        Prdata=$random;
    else
        Prdata=32'hxx;
end


endmodule
