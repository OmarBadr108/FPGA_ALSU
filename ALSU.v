module ALSU (A,B,opcode,cin,serial_in,direction,red_op_A,red_op_B,bypass_A,bypass_B,clk,rst,out,leds);
parameter INPUT_PRIORITY = "A";
parameter FULL_ADDER = "ON";

input [2:0] A,B,opcode;
input cin,serial_in,direction,red_op_A,red_op_B,bypass_A,bypass_B,clk,rst;

output reg [5:0] out ;
output reg [15:0] leds ; 

reg invalid ;




wire [3:0] half_adder_out ;
wire [5:0] mult_out ;

c_addsub_0 your_instance_name (
  .A(A),  // input wire [2 : 0] A
  .B(B),  // input wire [2 : 0] B
  .S(half_adder_out)  // output wire [3 : 0] S
);



mult_gen_0 your_instance_name (
  .A(A),  // input wire [2 : 0] A
  .B(B),  // input wire [2 : 0] B
  .P(mult_out)  // output wire [5 : 0] P
);
	// output logic 
	always @(posedge clk or posedge rst) begin
		if (rst) begin 
			out <= 0 ;
			invalid <=0 ;
			leds <= 0 ;
		end
		else if (invalid) begin
		leds <= leds ^ 16'hFFFF ;
		out <= 0 ;
		end
		else begin 
			if (bypass_A && ~bypass_B) 
				out <= A ;
			else if (bypass_B && ~bypass_A)
				out <= B ;
			else if (bypass_B && bypass_A) begin 
				if (INPUT_PRIORITY == "A") out <= A ;
				else if (INPUT_PRIORITY == "B") out <= B ;
				else invalid <= 1 ;
			end
			else begin
				case (opcode)
					3'b000 : begin
								if (red_op_A && ~red_op_B) out <= &A ;
								else if (red_op_B && ~red_op_A) out <= &B ;
								else if (red_op_B && red_op_A) begin 
									if (INPUT_PRIORITY == "A") out <= &A ;
									else if (INPUT_PRIORITY == "B") out <= &B ;
								end
								else out <= A&B ; 
							 end
					3'b001 : begin
								if (red_op_A && ~red_op_B) out <= ^A ;
								else if (red_op_B && ~red_op_A) out <= ^B ;
								else if (red_op_B && red_op_A) begin 
									if (INPUT_PRIORITY == "A") out <= ^A ;
									else if (INPUT_PRIORITY == "B") out <= ^B ;
								end
								else out <= A^B ;
							 end
					3'b010 : begin
								if (FULL_ADDER == "ON") out <= A+B+cin ;
				 				else out <= {2'b0,half_adder_out} ;
							 end 
					3'b011 : out <= mult_out ;
					3'b100 : begin  // shift
								if (direction) // shift left
									out <={out[4:0],serial_in}; 
								else // shift right
									out <={serial_in,out[5:1]};
							 end  
					3'b101 : begin  // rotate
								if (direction) // rotate left
									out <={out[4:0],out[5]}; 
								else // rotate right
									out <={out[0],out[5:1]};
						 	 end  
					3'b110 : invalid <= 1 ;
					3'b111 : invalid <= 1 ;
				endcase
				if ( ((red_op_A==1)||(red_op_B==1)) && ( (opcode ==3'b010) || (opcode ==3'b011) || (opcode ==3'b100) || (opcode ==3'b101) ) ) invalid <=1;
			end
		end	
	end
endmodule