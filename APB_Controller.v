`timescale 1ns / 1ps

module APB_Controller(Hclk, Hresetn, Hwrite, Hwrite_reg, valid, temp_selx, Hwdata1, Hwdata2, 
                    Haddr1, Haddr2, Penable, Pwrite, Pselx, Paddr, Pwdata, Hreadyout);

//Port Declaration:            
input Hclk, Hresetn, valid, Hwrite, Hwrite_reg;
input [2:0] temp_selx;
input [31:0] Haddr1, Haddr2, Hwdata1, Hwdata2; 
//input Prdata;    //Not needed. Either used in Slave or Controller to drive Hrdata.

output reg Pwrite, Penable, Hreadyout;  
output reg [2:0] Pselx;
output reg [31:0] Paddr, Pwdata;


//Defining FSM States:
parameter ST_IDLE = 3'b000,
          ST_WWAIT = 3'b001,
          ST_READ = 3'b010,
          ST_WRITE = 3'b011,
          ST_WRITEP = 3'b100,
          ST_RENABLE = 3'b101,
          ST_WENABLE = 3'b110,
          ST_WENABLEP = 3'b111;


//Variables to hold the value of present and next state with default state:
reg [2:0] stateP = ST_IDLE;
reg [2:0] stateN = ST_IDLE;       


//-------------------Reset Logic/Present State Logic (Sequential Logic)------------------
always @(posedge Hclk)
begin: Reset_Logic
    if(Hresetn == 0)
        stateP <= ST_IDLE;
    else
        stateP <= stateN;
end


//------------------------Next State Logic (Combinational Logic)-------------------------
always @(stateP, valid, Hwrite, Hwrite_reg)
begin: NextState_Logic

case(stateP)

    ST_IDLE:
    begin
        if(~valid)
            stateN = ST_IDLE;
        else if (valid && Hwrite)
            stateN = ST_WWAIT;
        else if (valid && ~Hwrite)
            stateN = ST_READ;  
    end
            
    ST_WWAIT:
    begin
        if(~valid)
            stateN = ST_WRITE;
        else
            stateN = ST_WRITEP;
    end

    ST_READ: stateN = ST_RENABLE;
            
    ST_WRITE:
    begin
        if(~valid)
            stateN = ST_WENABLE;
        else
            stateN = ST_WENABLEP;           
    end
            
    ST_WRITEP: stateN = ST_WENABLEP;   
            
    ST_RENABLE:
    begin
        if(~valid)
            stateN = ST_IDLE;
        else if (valid && Hwrite)
            stateN = ST_WWAIT;
        else if (valid && ~Hwrite)
            stateN = ST_READ;
    end
            
    ST_WENABLE:
    begin
        if(~valid)
            stateN = ST_IDLE;
        else if (valid && Hwrite)
            stateN = ST_WWAIT;
        else if (valid && ~Hwrite)
            stateN = ST_READ;
    end  
            
    ST_WENABLEP:
    begin
        if(~Hwrite_reg)
            stateN = ST_READ;
        else if(~valid && Hwrite_reg)
            stateN = ST_WRITE;
        else if(valid && Hwrite_reg)
            stateN = ST_WRITEP;
    end
            
    default: stateN = ST_IDLE;   
                       
endcase

end 


//---------------------------------Output Logic------------------------------------ 

//Temporary Registers:
reg Penable_temp, Hreadyout_temp, Pwrite_temp;
reg [2:0] Pselx_temp;
reg [31:0] Paddr_temp, Pwdata_temp;
reg pending;

//Combinational Output Logic:
always @(*)
begin: Combinational_Output_Logic

    case(stateP)
        ST_IDLE:
        begin
            Pselx_temp = 0;          //No APB Slave/Peripheral to be selected
            Penable_temp = 0;        //Transfer is not allowed to occur/Transfer is complete
            Hreadyout_temp = 1;      //AHB Interface is ready to initiate a transfer(Read or Write) 
        end
        
        ST_WWAIT:
        begin 
            pending = 1;                
            Pselx_temp = 0;          
            Penable_temp = 0;
            Hreadyout_temp = 1;
        end
        
        ST_READ:
        begin
            Paddr_temp = Haddr1;       //Address is decoded and driven onto Paddr
            Pselx_temp = temp_selx;   //Relevant Pselx depending on address is driven HIGH
            Pwrite_temp = 0;          //Read Transfer. Therefore, Pwrite = 0
            Penable_temp = 0;         //Transfer is not valid yet
            Hreadyout_temp = 0;       //AHB is not ready to receive data yet
        end
        
        ST_WRITE:
        begin
            Paddr_temp = Haddr1;      //Address is decoded and driven onto Paddr
            Pselx_temp = temp_selx;   //Relevant Pselx depending on address is driven HIGH
            Pwrite_temp = 1;          //Write Transfer. Therefore, Pwrite = 1
            Penable_temp = 0;         //Read Transfer is not valid yet
            Hreadyout_temp = 0;       //AHB is not ready to send data yet
            Pwdata_temp = Hwdata1;
        end
        
        ST_WRITEP:
        begin
            if(pending==1)                //Address is decoded and driven onto Paddr
            begin
                Paddr_temp = Haddr1;
                Pwdata_temp = Hwdata1;
            end
            else
            begin
                Paddr_temp = Haddr2;
                Pwdata_temp = Hwdata2;
            end
            
            Pselx_temp = temp_selx;    //Relevant Pselx depending on address is driven HIGH
            Pwrite_temp = 1;           //Write Transfer. Therefore, Pwrite = 1
            Penable_temp = 0;          //Write Transfer is not valid yet
            Hreadyout_temp = 0;        //AHB is not ready to send data yet   
        end
        
        ST_RENABLE:
        begin
            Penable_temp = 1;          //Read Transfer is made valid and can be executed
            Hreadyout_temp = 1;        //AHB is ready to receive data now
            //Pwrite_temp = 0;           //Not necessary as previous state ST_READ has already made Pwrite_temp LOW
            Pselx_temp = temp_selx;    //Not necessary as previous state ST_READ has already done this
        end
        
        ST_WENABLE:
        begin
            Penable_temp = 1;          //Write Transfer is made valid and can be executed
            Hreadyout_temp = 1;        //AHB is ready to send data now
            //Pwrite_temp = 1;           //Not necessary as previous state ST_WRITE has already made Pwrite_temp HIGH
            Pselx_temp = temp_selx;    //Not necessary as previous state ST_WRITE has already done this
        end
        
        ST_WENABLEP:
        begin
            pending = 0;
            Penable_temp = 1;          //Write Transfer is made valid and can be executed
            Hreadyout_temp = 1;        //AHB is ready to send data now
            //Pwrite_temp = 1;           //Not necessary as previous states ST_WRITE or ST_WRITEP have already made Pwrite_temp HIGH
            Pselx_temp = temp_selx;      //Not necessary as previous states ST_WRITE or ST_WRITEP have already done this
        end    
    endcase

end

//Sequential Output Logic:
always @(posedge Hclk)
begin: Sequential_Output_Logic
    if(~Hresetn)
    begin
        Paddr <= 0;
	    Pwrite <= 0;
	    Pselx <= 0;
	    Pwdata <= 0;
	    Penable <= 0;
	   Hreadyout <= 0;
    end
  
    else
    begin
        Paddr <= Paddr_temp;
        Pwrite <= Pwrite_temp;
        Pselx <= Pselx_temp;
        Pwdata <= Pwdata_temp;
        Penable <= Penable_temp;
        Hreadyout <= Hreadyout_temp;
    end    
end


endmodule