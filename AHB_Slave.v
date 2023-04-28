`timescale 1ns / 1ps

module AHB_Slave(Hclk, Hresetn, Hreadyin, Hwrite, Htrans, Haddr, Hwdata, Prdata,
        valid, Hwrite_reg, Hresp, temp_selx, Haddr1, Haddr2, Hwdata1, Hwdata2, Hrdata);
        
        
//--------------------------- Port Declaration --------------------------
input Hclk, Hresetn, Hreadyin ,Hwrite;
input [1:0] Htrans;
input [31:0] Haddr, Hwdata, Prdata;

output reg valid, Hwrite_reg;
output [1:0] Hresp;
output reg [2:0] temp_selx;
output reg [31:0] Haddr1, Haddr2, Hwdata1, Hwdata2;
output [31:0] Hrdata; 


//------------------------- Parameter Declaration ------------------------

//Type of Current Transfer being initiated by AHB Master ([1:0]Htrans):
parameter IDLE = 2'b00,       //Idle or Exclusive Transfer
          BUSY = 2'b01,       //Busy or Locked Transfer
          NONSEQ = 2'b10,     //Non-sequential Transfer
          SEQ = 2'b11;        //Sequential Transfer

//Status of the current Transfer:
parameter OKAY = 2'b00,
          ERROR = 2'b01,
          RETRY = 2'b10,
          SPLIT =2'b11;

//Address of Peripheral devices(APB Slaves) on the APB :
parameter INTERURPT_CONTROLLER = 3'b001,
          COUNTER_TIMER = 3'b010,
          REMAP_PAUSE = 3'b100,
          UNDEFINED = 3'b000;
       	      

//---------------------- Implementing logic for valid ----------------------
always @(Hreadyin,Haddr,Htrans,Hresetn)
begin
    if(Hresetn == 0)
        valid = 0;
    else if ((Hreadyin == 1) && (Haddr >= 32'h8000_0000 && Haddr < 32'h8C00_0000) && (Htrans == NONSEQ || Htrans == SEQ))
	   valid = 1;
	else if ((Hreadyin == 0) || Haddr >= 32'h8C00_0000 || (Htrans == IDLE || Htrans == BUSY))
	   valid = 0;

end


//-------------- Implementing Slave Select Logic for temp_selx --------------
always @(Haddr,Hresetn)
begin
    if (Hresetn && (Haddr >= 32'h8000_0000 && Haddr < 32'h8400_0000))
        temp_selx = INTERURPT_CONTROLLER;
    else if (Hresetn && (Haddr >= 32'h8400_0000 && Haddr < 32'h8800_0000))
        temp_selx = COUNTER_TIMER;
    else if (Hresetn && (Haddr >= 32'h8800_0000 && Haddr < 32'h8C00_0000))
        temp_selx = REMAP_PAUSE;
    else if (Hresetn && (Haddr >= 32'h8C00_0000 && Haddr < 32'hBFFF_FFFF))
        temp_selx = UNDEFINED;
end


//------------------------- Implementing Pipeline Logic -------------------------

//For Address Bus:
always @(posedge Hclk)
begin
    if(Hresetn==0)
    begin
        Haddr1 <= 0;
        Haddr2 <= 0;
    end
    
    else
    begin
        Haddr1 <= Haddr;
        Haddr2 <= Haddr1;
    end		
end

//For Data Bus:
always @(posedge Hclk)
begin	
    if(Hresetn==0)
	begin
	   Hwdata1 <= 0;
	   Hwdata2 <= 0;
	end
	
	else
	begin
		Hwdata1 <= Hwdata;
		Hwdata2 <= Hwdata1;
	end		
end

//For Control Signal:
always @(posedge Hclk)
begin	
	if(Hresetn==0)
		Hwrite_reg <= 0;
	else
		Hwrite_reg <= Hwrite;
end 
	
	
//------------------- Implementing logic for Hrdata --------------------
assign Hrdata = Prdata;   //Hrdata is directly driven with current value of Prdata.


//-------------- Implementing logic for Transfer Response --------------
assign Hresp = OKAY;   //AHB Slave always generates OKAY Response
	
	       
endmodule
