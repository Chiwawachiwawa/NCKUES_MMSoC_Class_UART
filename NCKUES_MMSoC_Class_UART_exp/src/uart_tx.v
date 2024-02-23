//****************************************Copyright (c)****************************************//
//Created by    : Rei_Fu_Zhang
//Copyright     : NCKU_ES_MMNLAB(only for education)
//Descriptions  : uart_tx
//
//---------------------------------------------------------------------------------------------
//*********************************************************************************************// 

module uart_tx(
 input          clk                  , 
 input          rst_n                , 
 input          uart_tx_en           ,
 input [7:0]    uart_tx_data         , 
 output reg     uart_txd             , 
 output reg     uart_tx_busy 
 );



    parameter UART_BPS          =      115200               ;
    parameter CLK_FREQ          =      50000000             ;
    localparam BAUD_CNT_MAX     =      CLK_FREQ/UART_BPS    ;

    reg [7:0]   tx_reg;
    reg [3:0]   tx_cnt;
    reg [15:0]  BD_cnt;

//deal with saving data_i to tx_reg when uart_tx_en == 1
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_reg       = 8'b0;
        uart_tx_busy = 1'b0;
    end
    else if(uart_tx_en) begin
        tx_reg       <= uart_tx_data  ;
        uart_tx_busy <= 1'b1          ;
    end
    else if(tx_cnt == 4'd9 && BD_cnt ==  BAUD_CNT_MAX - BAUD_CNT_MAX/16)begin // when tx_cnt is full stop sending
        tx_reg          <= 8'd0         ;
        uart_tx_busy    <= 1'b0         ;
    end
    else begin
        tx_reg          <= tx_reg       ;
        uart_tx_busy    <= uart_tx_busy ;
    end 
end

// BD_cnt
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        BD_cnt <= 16'b0;
    end
    else if(uart_tx_busy) begin
        if (BD_cnt < BAUD_CNT_MAX - 1) begin
            BD_cnt <= BD_cnt + 16'd1;
        end
        else begin
            BD_cnt <= 16'd0         ;//rst cnt
        end
    end
    else begin
        BD_cnt <= 16'd0             ;//rst cnt
    end
end


//set tx_cnt
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_cnt <= 4'b0;
    end
    else if(uart_tx_busy) begin
        if (BD_cnt == BAUD_CNT_MAX - 1) begin
            tx_cnt <= tx_cnt + 1'd1;
        end
        else begin
            tx_cnt <= tx_cnt;
        end
    end
    else begin
        tx_cnt <= 4'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        uart_txd <= 1'd1;
    end
    else if(uart_tx_busy)begin
        case (tx_cnt)
            4'd0 : uart_txd <= 1'd0; //start bit 
            4'd1 : uart_txd <= tx_reg[0];
            4'd2 : uart_txd <= tx_reg[1];
            4'd3 : uart_txd <= tx_reg[2];
            4'd4 : uart_txd <= tx_reg[3];
            4'd5 : uart_txd <= tx_reg[4];
            4'd6 : uart_txd <= tx_reg[5];
            4'd7 : uart_txd <= tx_reg[6];
            4'd8 : uart_txd <= tx_reg[7];
            4'd9 : uart_txd <= 1'b1     ; //end bit 
            default: uart_txd <= 1'b1;
        endcase
    end
    else begin
        uart_txd <= 1'd1;
    end    
end





endmodule