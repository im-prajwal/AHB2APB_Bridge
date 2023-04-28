`timescale 1ns / 1ps

module AHB_Master(Hclk, Hresetn, Hreadyout, Hresp, Hrdata,
                  Hwrite, Hreadyin, Htrans, Hwdata, Haddr);

//Port Declaration:
input Hclk, Hresetn, Hreadyout;
input [1:0] Hresp;
input [31:0] Hrdata;
output reg Hwrite, Hreadyin;
output reg [1:0] Htrans;
output reg [31:0] Hwdata, Haddr;

reg [2:0] Hburst, Hsize;

//Task for Single Write:
task singleWrite ;
 begin
  @(posedge Hclk)
  #2;
   begin
    Hwrite = 1;
    Htrans = 2'b10;
    Hreadyin = 1;
    Haddr = 32'h8800_0001;
   end
  
  @(posedge Hclk)
  #2;
   begin
    Htrans = 2'b00;
    Hwdata = 8'hA3;
   end 
 end
endtask


//Task for Single Read:
task singleRead;
begin
    @(posedge Hclk)
    #2;
    begin
        Hwrite = 0;
        Htrans = 2'b10;
        Hreadyin = 1;
        Haddr = 32'h8000_00A2;
    end
  
    @(posedge Hclk)
    #2;
    begin
        Htrans = 2'b00;
    end 
end
endtask


endmodule
