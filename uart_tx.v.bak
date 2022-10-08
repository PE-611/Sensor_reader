///////////////////////////////////////////////////////////
// Name File : UART_Tx.v 											//
// Autor : Dyomkin Pavel Mikhailovich 							//
// Company : GSC RF TRINITI										//
// Description : UART Tx module								  	//
// Start design : 01.04.2021 										//
// Last revision : 09.08.2022 									//
///////////////////////////////////////////////////////////
module UART_Tx (input clk_Tx, TX_LAUNCH, reset,							// TX_LAUNCH is button or condition for transmit
					 input [7:0] data_in,
					 output reg UART_clk,		
					 output reg	Tx_out                           

					 );
					 
parameter Fclk = 50 * 1000000;			
parameter Fuart = 9600;								 	
parameter divider	= Fclk / Fuart; 

reg [7:0] state;	
reg [7:0] next_state;
reg [7:0] state_cnt;


localparam IDLE 							= 8'd0;
localparam START_BIT						= 8'd1;
localparam SET_DATA_BIT					= 8'd2;
localparam DEC_BIT_CNT					= 8'd3;
localparam STOP_TRANSMIT				= 8'd4;


reg transmit_flg;
initial transmit_flg <= 1'b0;


reg [24:0] cnt;
initial cnt <= 1'b0;	

reg [7:0] bit_cnt;
initial bit_cnt <= 8'd0;
//reg [7:0] data_for_transmit;
//initial data_for_transmit <= data_in;


initial Tx_out <= 1'b1;
			
always @* 	
		
		case (state)
			
			IDLE:
						
				
				if (TX_LAUNCH == 1'b0 && transmit_flg == 1'b0) begin
					next_state <= START_BIT;
				end
				
				else begin
					next_state <= IDLE;
				end
				
				
			START_BIT:	
			
				if (cnt == divider) begin
					next_state <= SET_DATA_BIT;
				end
				
				else begin
					next_state <= START_BIT;
				end
				
			SET_DATA_BIT:	
			
				if (cnt == divider) begin
					next_state <= DEC_BIT_CNT;
				end
				
				else begin
					next_state <= SET_DATA_BIT;
				end				
			
			DEC_BIT_CNT:
				
				if (bit_cnt == 8'd7) begin
					next_state <= STOP_TRANSMIT;
				end
				
				else begin
					next_state <= SET_DATA_BIT;
				end
			
			STOP_TRANSMIT:

				if (cnt == divider) begin
					next_state <= IDLE;
				end
				
				else begin
					next_state <= STOP_TRANSMIT;
				end
		
				
				
			default:
				next_state <= IDLE;
		
		endcase
		
		
always @(posedge clk_Tx) begin
	
	if (TX_LAUNCH == 1'b0) begin
		transmit_flg <= 1'b1;
	end
	
	if (transmit_flg == 1'b1) begin
		cnt <= cnt + 1'b1;
	end
	
	if (cnt == divider) begin
		cnt <= 1'b0;
	end
	
	if (state == IDLE) begin
		cnt <= 1'b0;
		transmit_flg <= 1'b0;
		bit_cnt <= 1'b0;
		Tx_out <= 1'b1;
	end
	
	if (state == START_BIT) begin
		Tx_out <= 1'b0;
	end
	
	if (state == SET_DATA_BIT) begin
		Tx_out <= data_in[bit_cnt];
	end
	
	if (state == DEC_BIT_CNT) begin
		bit_cnt <= bit_cnt + 1'b1;
	end
	
	if (state == STOP_TRANSMIT) begin
		Tx_out <= 1'b1;
	end
	
	
	
end	




always @(posedge clk_Tx or negedge reset) begin 
	
	
	if(!reset) begin
		state <= IDLE;
	end
	
	else begin
		state <= next_state;
	end
end		

	
	
endmodule


//data_out <=  {data_out[7:0], Rx_in}; shift reg