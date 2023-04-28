`timescale 1ns / 1ps

module BridgeTop(Hclk, Hresetn, Hwrite, Hreadyin, Hreadyout, Hwdata, Haddr, Htrans,
                Prdata, Penable, Pwrite, Pselx, Paddr, Pwdata, Hresp, Hrdata);

//Port Declaration:   
input Hclk, Hresetn, Hwrite, Hreadyin;
input[1:0] Htrans;
input [31:0] Hwdata, Haddr, Prdata;

output Penable, Pwrite, Hreadyout;
output [1:0] Hresp; 
output [2:0] Pselx;
output [31:0] Paddr, Pwdata, Hrdata;

//Intermediate Nets:
wire valid, Hwrite_reg;
wire [2:0] temp_selx;  
wire [31:0] Haddr1, Haddr2, Hwdata1, Hwdata2;
  
//Instantiating AHB Slave and APB FSM Controller:
AHB_Slave Slave(Hclk, Hresetn, Hreadyin, Hwrite, Htrans, Haddr, Hwdata, Prdata,
        valid, Hwrite_reg, Hresp, temp_selx, Haddr1, Haddr2, Hwdata1, Hwdata2, Hrdata);

APB_Controller FSM(Hclk, Hresetn, Hwrite, Hwrite_reg, valid, temp_selx, Hwdata1, Hwdata2, 
                    Haddr1, Haddr2, Penable, Pwrite, Pselx, Paddr, Pwdata, Hreadyout);
    
    
endmodule
