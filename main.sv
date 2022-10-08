///////////////////////////////////////////////////////////
// Name File : main.sv												//
// Autor : Dyomkin Pavel Mikhailovich 							//
// Company : FLEXLAB													//
// Description : Sensor reader								  	//
// Start design : 28.09.2022 										//
// Last revision :04.09.2022  									//
///////////////////////////////////////////////////////////

module main
				#(
				  parameter gate_width = 10,
				  parameter MMa_width = 5
				 )
				
				 (
				  input logic clk, start_read, reset, ADC_SDAT,
				  output logic iv_hold, iv_reset,
				  output logic [gate_width:0] gate, 
				  output logic [MMa_width - 1:0] M, Ma,
				  
				  output logic ADC_SCLK, ADC_CS_N, ADC_SADDR, Tx_out,
				  output logic [7:0] LED
				  
				  
				 );				 
				 

parameter delay_launch_module	= 5;											 
//parameter row 						= 10;				//row x column = pixel
//parameter column 					= 25;
parameter reset_time 			= 100;
parameter accumulation_time 	= 100;

parameter iv_hold_time 			= 10;
parameter iv_reset_time			= 10;




logic [15:0] data_from_ADC;	
logic start_convert; 
logic ADC_process;	

logic TX_LAUNCH;
logic UART_TX_process;

			 
								  
logic [7:0] state;	
logic [7:0] next_state;

		  
localparam IDLE 							= 8'd0;
localparam START_READ					= 8'd1;
localparam ACCUMULATION					= 8'd2;
localparam SELECT_PIXEL					= 8'd3;
localparam IV_HOLD						= 8'd4;
localparam ADC								= 8'd5;
localparam UART_TRANSMIT				= 8'd6;
localparam IV_RESET						= 8'd7;
localparam RESET_SENSOR					= 8'd8;





		  
logic process_flg;

logic [12:0] reset_cnt;
logic [12:0] accum_cnt;
logic [12:0] row_cnt;
logic [12:0] column_cnt;
logic [12:0] iv_hold_cnt;
logic [12:0] iv_reset_cnt;

logic [7:0]  adc_cnt;
logic [7:0]	 uart_cnt;



assign LED[0] = process_flg;
assign LED[1] = ~Tx_out;


initial begin

	process_flg = 1'b0;
	
	gate <= {gate_width + 1{1'b1}};			//11'b11111111111;  
	M 	  <= {MMa_width {1'b1}};				//5'b11111;
	Ma   <= {MMa_width {1'b1}};
 
	iv_reset 	<= 1'b0;
	iv_hold		<= 1'b1;
	
	iv_hold_cnt 	<= 1'b0;
	iv_reset_cnt 	<= 1'b0;
	
	reset_cnt	<= 1'b0;
	accum_cnt 	<= 1'b0;
	row_cnt 		<= 1'b0;
	column_cnt 	<= 1'b0;
	
	start_convert <= 1'b0;
	TX_LAUNCH	  <= 1'b1;
	
end		



			
always @* 	
		
		case (state)
			
			IDLE:	
				
				if (process_flg == 1'b1) begin
					next_state <= START_READ;
				end
				
				else begin
					next_state <= IDLE;
				end
				
			START_READ:
				
				if (state == START_READ) begin
					next_state <= ACCUMULATION;
				end
				
				else begin
					next_state <= START_READ;
				end	
				
			ACCUMULATION:	
			
				if (state == ACCUMULATION && accum_cnt == accumulation_time) begin
					next_state <= SELECT_PIXEL;
				end
				
				else begin
					next_state <= ACCUMULATION;
				end
				
			SELECT_PIXEL:	
				
				if (state == SELECT_PIXEL) begin
					next_state <= IV_HOLD;
				end
				
				else begin
					next_state <= SELECT_PIXEL;
				end
				
			IV_HOLD:
				
				if (iv_hold_cnt == iv_hold_time) begin
					next_state <= ADC;
				end
				
				else if (gate == {1'b1, {gate_width{1'b0}}}) begin
					next_state <= RESET_SENSOR;
				end
				
				else begin
					next_state <= IV_HOLD;
				end				
				
			ADC:	
			
				if (adc_cnt >= 7'd5 && ADC_process == 1'b0) begin
					next_state <= UART_TRANSMIT;
				end
				
				else begin
					next_state <= ADC;
				end
				
			UART_TRANSMIT:	
							
				if (uart_cnt >= 7'd5 && UART_TX_process == 1'b0) begin
					next_state <= IV_RESET;
				end
				
				else begin
					next_state <= UART_TRANSMIT;
				end
				
			IV_RESET:
				
				if (iv_reset_cnt == iv_reset_time) begin
					next_state <= SELECT_PIXEL;
				end
				
				else begin
					next_state <= IV_RESET;
				end	
				
			RESET_SENSOR:
			
				if (state == RESET_SENSOR && reset_cnt == reset_time) begin
					next_state <= IDLE;
				end
				
				else begin
					next_state <= RESET_SENSOR;
				end
				
				
					
			default:
				next_state <= IDLE;
		
		endcase
		
		
always @(posedge clk) begin
	
	if (state == IDLE) begin
		start_convert <= 1'b0;
		TX_LAUNCH	  <= 1'b1;
		
		gate <= {gate_width + 1{1'b1}};		//11'b11111111111;  
		M 	  <= {MMa_width {1'b1}};			//5'b11111;
		Ma   <= {MMa_width {1'b1}};
		
		iv_reset 	<= 1'b0;
		iv_hold		<= 1'b1;
		
		iv_hold_cnt 	<= 1'b0;
		iv_reset_cnt 	<= 1'b0;
		
		accum_cnt 	<= 1'b0;
		reset_cnt 	<= 1'b0;
		row_cnt 		<= 1'b0;
		column_cnt 	<= 1'b0;
	end
	
	if (start_read == 1'b0) begin
		process_flg <= 1'b1;
	end
	
	if (state == START_READ) begin
		iv_reset <= 1'b1;
	end
	
	if (state == ACCUMULATION) begin
		accum_cnt <= accum_cnt + 1'b1;
		gate <= {gate_width + 1{1'b0}};			//11'b11111111111;  
		M 	  <= {MMa_width {1'b0}};				//5'b11111;
		Ma   <= {MMa_width {1'b0}};
	end
	
	if (accum_cnt == accumulation_time) begin
		accum_cnt <= 1'b0;
	end
	
	if (state == SELECT_PIXEL) begin
		
		iv_reset 	<= 1'b1;
		iv_hold		<= 1'b0;
		
		if (Ma == 1'b0) begin
			Ma <= Ma + 1'b1;
			M <= M + 1'b1;
			gate <= gate + 1'b1;
			
		end
		
		if (Ma != 1'b0) begin
			Ma <= Ma << 1;
		end
		
		
		if (Ma == {1'b1, {MMa_width - 1{1'b0}}}) begin			
			Ma   <= {{MMa_width - 1{1'b0}}, {1'b1}};														
			M 		<= M 	<< 1;
		end
		
		if (M == {1'b1, {MMa_width - 1{1'b0}}} && Ma == {1'b1, {MMa_width - 1{1'b0}}}) begin
			M 	  <= {{MMa_width - 1{1'b0}}, {1'b1}};
			gate <= gate << 1;
		end
		
	end
	
	if (state == IV_HOLD) begin
		iv_reset 	<= 1'b1;
		iv_hold		<= 1'b0;
		iv_hold_cnt <= iv_hold_cnt + 1'b1;
	end
	
	if (iv_hold_cnt == iv_hold_time) begin
		iv_hold_cnt <= 1'b0;
	end
	
	if (state == ADC && adc_cnt < delay_launch_module) begin
		start_convert <= 1'b1;
		adc_cnt <= adc_cnt + 1'b1;
	end
		
	if (adc_cnt == delay_launch_module) begin
		start_convert <= 1'b0;
	end
	
	if (state != ADC) begin
		adc_cnt <= 1'b0;
	end
	
	if (state == UART_TRANSMIT && uart_cnt < delay_launch_module) begin
		iv_reset 	<= 1'b0;
		iv_hold		<= 1'b1;
		uart_cnt <= uart_cnt + 1'b1;
		TX_LAUNCH 	<= 1'b0;
	end	
	
	if (uart_cnt == delay_launch_module) begin
		TX_LAUNCH 	<= 1'b1;
	end
	
	if (state != UART_TRANSMIT) begin
		uart_cnt <= 1'b0;
	end
	
	if (state == IV_RESET) begin
		iv_reset 	<= 1'b0;
		iv_hold		<= 1'b1;
		iv_reset_cnt <= iv_reset_cnt + 1'b1;
	end
	
	if (iv_reset_cnt == iv_reset_time) begin
		iv_reset_cnt <= 1'b0;
	end
			
	if (state == RESET_SENSOR) begin
		gate <= {gate_width + 1{1'b1}};			//11'b11111111111;  
		M 	  <= {MMa_width {1'b1}};				//5'b11111;
		Ma   <= {MMa_width {1'b1}};
		
		iv_reset 	<= 1'b0;
		iv_hold		<= 1'b1;
		
		reset_cnt <= reset_cnt + 1'b1;
		

	end


	
	if (reset_cnt == reset_time) begin
		reset_cnt <= 1'b0;
		process_flg <= 1'b0;
	end
	
	
		
end	





always @(posedge clk or negedge reset) begin 
	
	if(!reset) begin
		state <= IDLE;
	end
	
	else begin
		state <= next_state;
	end
end		


ADC128S022_DRIVER ADC1 		(.clk_in(clk), .start_convert(start_convert), .reset(reset), .process_flg(ADC_process),
									 .ADC_SDAT(ADC_SDAT), .ADC_SCLK(ADC_SCLK), .ADC_CS_N(ADC_CS_N), 
									 .ADC_SADDR(ADC_SADDR), .data_out(data_from_ADC));
									 
									 
UART_Tx UART_Tx  				(.clk_Tx(clk), .TX_LAUNCH(TX_LAUNCH), .reset(reset), .data_in(data_from_ADC[11:4]), 
									 .Tx_out(Tx_out), .transmit_flg(UART_TX_process));
	
	
endmodule


//data_out <=  {data_out[7:0], Rx_in}; shift reg