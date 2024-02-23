//****************************************Copyright (c)****************************************//
//Created by    : Rei_Fu_Zhang
//Copyright     : NCKU_ES_MMNLAB(only for education)
//Descriptions  : uart_rx
//
//---------------------------------------------------------------------------------------------
//*********************************************************************************************// 
module uart_rx (
    input clk               ,   
    input rst_n             , //active low

    input uart_rxd            ,

    output reg       uart_rx_done,
    output reg [7:0] uart_rx_data
);

//  parameters

parameter CLK_FREQ   =      50000000  ;
parameter UART_BPS   =      115200    ;
localparam BAUD_RATE_CNT_MAX = CLK_FREQ/UART_BPS; 

//  regs


reg rx_d0               ;
reg rx_d1               ;
reg rx_d2               ;

reg         rx_ready    ;
reg [3:0]   rx_cnt      ;
reg [15:0]  BD_cnt      ;
reg [7:0]   rx_data_tmp ;

//  wire
wire        start_en    ;

// get start signal
assign start_en = rx_d2 & (~rx_d1) & (~rx_ready);

//asyn to syn
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rx_d0 <= 1'd0; 
        rx_d1 <= 1'd0;
        rx_d2 <= 1'd0;
    end
    else begin
        rx_d0 <= uart_rxd; 
        rx_d1 <= rx_d0 ;
        rx_d2 <= rx_d1 ;
    end
end

//set rx_ready
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_ready <= 1'd0;
    end
    else if(start_en) begin
        rx_ready <= 1'b1;
    end
    else if((rx_cnt == 4'd9) && (BD_cnt == BAUD_RATE_CNT_MAX/2 - 1'd1)) begin
        rx_ready <= 1'b0;
    end
    else begin
        rx_ready <= rx_ready;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        BD_cnt <= 16'd0;
    end
    else if(rx_ready) begin
        if (BD_cnt < BAUD_RATE_CNT_MAX - 1'd1) begin
            BD_cnt <= BD_cnt + 16'd1; // counting
        end
        else begin
            BD_cnt <= 16'd0; //cnt == Baud rate need cycles reset
        end
    end
    else begin
        BD_cnt <= 16'd0; //rx end cnt = 0
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rx_cnt <= 4'd0;
    end
    else if (rx_ready)begin
        if(BD_cnt == BAUD_RATE_CNT_MAX - 1) begin
            rx_cnt <= rx_cnt + 1'd1;
        end
        else begin
            rx_cnt <= rx_cnt;
        end
    end
    else begin
        rx_cnt <= 4'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rx_data_tmp <= 8'b0;
    else if(rx_ready) begin                           
        if(BD_cnt == BAUD_RATE_CNT_MAX/2 - 1'b1) begin  
           case(rx_cnt)
               4'd1 : rx_data_tmp[0] <= rx_d2;   
               4'd2 : rx_data_tmp[1] <= rx_d2;
               4'd3 : rx_data_tmp[2] <= rx_d2;
               4'd4 : rx_data_tmp[3] <= rx_d2;
               4'd5 : rx_data_tmp[4] <= rx_d2;
               4'd6 : rx_data_tmp[5] <= rx_d2;
               4'd7 : rx_data_tmp[6] <= rx_d2;
               4'd8 : rx_data_tmp[7] <= rx_d2;   
               default : ;
            endcase  
        end
        else
            rx_data_tmp <= rx_data_tmp;
    end
    else
        rx_data_tmp <= 8'b0;
end   

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_rx_done <= 1'b0; 
        uart_rx_data  <= 8'b0;
    end
    else if(rx_cnt == 4'd9 && BD_cnt == BAUD_RATE_CNT_MAX/2 - 1'b1)begin
        uart_rx_done <= 1'b1;
        uart_rx_data  <= rx_data_tmp;
    end
    else begin
        uart_rx_done <= 1'd0;
        uart_rx_data  <= uart_rx_data;
    end
end



endmodule