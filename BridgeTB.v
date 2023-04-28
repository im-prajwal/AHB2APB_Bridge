`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Engineer: Prajwal H N 
// 
// Create Date: 11.04.2023 20:41:18
//
// Design Name: 
// Module Name: BridgeTB
// Project Name: AHB2APB Bridge 
//////////////////////////////////////////////////////////////////////////////////

module BridgeTB();

//----------- Declaring Test Bench signals to drive ports of DUT -----------//

//Input to BridgeTB:
reg Hclk;
reg Hresetn;

//Inputs to AHB Master Interface:
wire[31:0] Hrdata;
wire[1:0] Hresp;
wire Hreadyout;

//Inputs to Bridge Top and Outputs of AHB Master Interface:      
wire Hwrite;
wire Hreadyin;
wire [1:0] Htrans;
wire [31:0] Haddr;
wire [31:0] Hwdata;

//Inputs to APB Slave Interface and Outputs of Bridge Top:
wire Pwrite;
wire Penable;
wire [2:0] Pselx;
wire [31:0] Paddr;
wire [31:0] Pwdata;

//Input to Bridge Top and Output of APB Slave Interface: 
wire [31:0] Prdata;


//------------Instantiating DUTs and mapping TB signals to DUT ports------------//
AHB_Master dutM(Hclk,Hresetn,Hreadyout,Hresp,Hrdata,Hwrite,Hreadyin,Htrans,Hwdata,Haddr);
BridgeTop dutB(Hclk, Hresetn, Hwrite, Hreadyin, Hreadyout, Hwdata, Haddr, Htrans, Prdata, Penable, Pwrite, Pselx, Paddr, Pwdata, Hresp, Hrdata);
APB_Slave dutS(Pwrite, Pselx, Penable, Paddr, Pwdata, Prdata);


//--------------------------Driving Signals---------------------------//
//Clock Generation:
initial
begin
   Hclk = 0;
   forever #5 Hclk = ~ Hclk;
end

//Reset:
task reset;
begin
   Hresetn = 0;
   #8;
   Hresetn = 1;
   end
endtask
 
//Single Read:
initial
begin
    reset;
    dutM.singleRead;
    @(posedge Hclk);
    dutM.singleWrite;
    @(posedge Hclk);
end

initial #120 $finish;

endmodule
