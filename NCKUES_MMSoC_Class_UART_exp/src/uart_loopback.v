//****************************************Copyright (c)****************************************//
//Created by    : Rei_Fu_Zhang
//Copyright     : NCKU_ES_MMNLAB(only for education)
//Descriptions  : loop_back_top_for_testing_uart
//
//---------------------------------------------------------------------------------------------
//*********************************************************************************************// 
module uart_loopback(
    input            sys_clk  ,   
    input            sys_rst_n,   
        
    input            uart_rxd ,   
    output           uart_txd     
    );

//parameter define
parameter CLK_FREQ = 50000000;    
parameter UART_BPS = 115200  ;    

//wire define
wire         uart_rx_done;    
wire  [7:0]  uart_rx_data;    
wire               clk_50;
//*****************************************************
//**                    main code
//*****************************************************

uart_rx #(
    .CLK_FREQ  (CLK_FREQ),
    .UART_BPS  (UART_BPS)
    )    
    u_uart_rx(
    .clk           (clk_50     ),
    .rst_n         (sys_rst_n   ),
    .uart_rxd      (uart_rxd    ),
    .uart_rx_done  (uart_rx_done),
    .uart_rx_data  (uart_rx_data)
    );

uart_tx #(
    .CLK_FREQ  (CLK_FREQ),
    .UART_BPS  (UART_BPS)
    )    
    u_uart_tx(
    .clk          (clk_50     ),
    .rst_n        (sys_rst_n   ),
    .uart_tx_en   (uart_rx_done),
    .uart_tx_data (uart_rx_data),
    .uart_txd     (uart_txd    ),
    .uart_tx_busy (            )
    );
    
rpll_27_50 rpll_27_50_u(
        .clkout(clk_50), //output clkout
        .clkin(sys_clk) //input clkin
    );

endmodule
