///////////////////////////////////////////////////////////
// Name File : ADC128S022_DRIVER									//
// Autor : Dyomkin Pavel Mikhailovich 							//
// Company : FLEXLAB													//
// Description : ADC128S022_DRIVER							  	//
// Start design : 03.08.2022 										//
// Last revision : 03.08.2022 									//
///////////////////////////////////////////////////////////

module ADC128S022_DRIVER (input clk_in, start_convert, reset, ADC_SDAT,

								  output reg ADC_SCLK, ADC_CS_N, ADC_SADDR,
								  
								  output reg [15:0] data_out
								  );
				 
								  
parameter divider_clk = 16;						// 50 MHz / 16 = 3 MHz for ADC_SCLK
parameter quantity_clk = 16;


reg [7:0] state;	
reg [7:0] next_state;

		  
localparam IDLE 							= 8'd0;
localparam START							= 8'd1;
localparam START_GENERATE				= 8'd2;
localparam REVERSE_CLK              = 8'd3;
localparam STOP							= 8'd4;
		  
reg process_flg;

reg [7:0] cnt;

reg [7:0] cnt_quantity_clk;

	

initial begin
	
	ADC_SCLK <= 1'b1;
	ADC_CS_N <= 1'b1;
	ADC_SADDR <= 1'b0; 
	
	state <= 1'b0;	
	next_state <= 1'b0;
	
	process_flg <= 1'b0;
	
	cnt <= 1'b0;
	cnt_quantity_clk <= 1'b0;	
	
	data_out <= 1'b0;
	
	
end		




			
always @* 	
		
		case (state)
			
			IDLE:
						
				
				if (start_convert == 1'b1) begin
					next_state <= START;
				end
				
				else begin
					next_state <= IDLE;
				end
				
				
			START:	
			
				if (cnt == divider_clk) begin
					next_state <= START_GENERATE;
				end
				
				else begin
					next_state <= START;
				end
				
			START_GENERATE:
			
				if (cnt == divider_clk) begin
					next_state <= REVERSE_CLK;
				end
				
				else begin
					next_state <= START_GENERATE;
				end
				
				
			REVERSE_CLK:
			
				if (cnt == divider_clk && cnt_quantity_clk < quantity_clk) begin
					next_state <= START_GENERATE;
				end
				
				else if (cnt == divider_clk && cnt_quantity_clk == quantity_clk) begin
					next_state <= STOP;
				end
				
				else begin
					next_state <= REVERSE_CLK;
				end
				
			
					
			
			STOP:

				if (state == STOP) begin
					next_state <= IDLE;
				end
				
				else begin
					next_state <= STOP;
				end
		
				
				
			default:
				next_state <= IDLE;
		
		endcase
		
		
always @(posedge clk_in) begin
	
	if (state == START) begin
		process_flg <= 1'b1;
		ADC_CS_N <= 1'b0;

		ADC_SADDR <= 1'b0;		
	end
	
	if (process_flg == 1'b1) begin			
		cnt <= cnt + 1'b1;
	end
	
	if (cnt == divider_clk) begin
		cnt <= 1'b0;
	end
	
	if (state == START_GENERATE) begin
		ADC_SCLK <= 1'b0;
	end
	
	if (state == REVERSE_CLK) begin
		ADC_SCLK <= 1'b1;
	end
	
	if (state == STOP) begin
			
		process_flg <= 1'b0;				
		ADC_CS_N <= 1'b1;	
		
		cnt <= 1'b0;
		
	
	end
	
		
end	

always @(posedge ADC_SCLK or negedge process_flg) begin		

	
	if (!process_flg) begin														
		cnt_quantity_clk <= 1'b0;
	end
	
	else begin
		cnt_quantity_clk <= cnt_quantity_clk + 1'b1;
		data_out <=  {data_out[15:0], ADC_SDAT};
	end
	
end



always @(posedge clk_in or negedge reset) begin 
	
	
	if(!reset) begin
		state <= IDLE;
	end
	
	else begin
		state <= next_state;
	end
end		

	
	
endmodule


//data_out <=  {data_out[7:0], Rx_in}; shift reg