module alsu_tb();

reg [2:0] A, B, opcode;
reg cin, serial_in, direction, red_op_A, red_op_B, bypass_A, bypass_B, clk, rst;
wire [5:0] out;
wire [15:0] leds;

integer i,j;

ALSU DUT (A,B,opcode,cin,serial_in,direction,red_op_A,red_op_B,bypass_A,bypass_B,clk,rst,out,leds);

initial begin
  clk = 0;
  forever
   #1 clk = ~clk;
end

initial begin
  //reseting
  #2;
  rst = 1;
  A = 0;
  B = 0;
  opcode = 3'b000;
  cin = 1'b0;
  serial_in = 1'b0;
  direction = 1'b0;
  red_op_A = 1'b0;
  red_op_B = 1'b0;
  bypass_A = 1'b0;
  bypass_B = 1'b0;
  #2 rst = 0;

  // test case 1: AND operation
  #4;
  A = 3'b101;
  B = 3'b010;
  opcode = 3'b000;

  // test case 2: XOR operation
  #4
  opcode = 3'b001;
  // test case 3: addition operation
  #4;
  opcode = 3'b010;
  cin = 1'b1;
  // test case 4: multiplication operation
  #4;
  opcode = 3'b011;
  cin = 1'b0;

  // test case 5: shift left
  #4;
  opcode = 3'b100;
  serial_in = 1'b0;
  direction = 1'b1;

  // test case 6: shift right
  #4;  
  opcode = 3'b100;
  serial_in = 1'b1;
  direction = 1'b0;
    // test case 7: rotate left
  #4;
  opcode = 3'b101;
  serial_in = 1'b0;
  direction = 1'b1;
    // test case 8: rotate right
  #4;
  opcode = 3'b101;
  direction = 1'b0;
  #2 rst = 1;
  #2 rst = 0;
  //test case 9: bypass operations
 #4;
  #2 rst = 1;
  #2 rst = 0;
  opcode=3'b000;
  for(j=0;j<7;j=j+1)
  begin  //if red_op_A and red_op_B are 1 poriorty was set to A
    @(negedge clk);
    bypass_A=$random;
    bypass_B=$random;
    opcode=opcode+1;
    #2;
  end
  bypass_A=0;
  bypass_B=0;
  
  // test case 10: reduction operation 

  #4; //AND reduction
  #2 rst = 1;
  #2 rst = 0;
  opcode = 3'b000;
  red_op_A=1;
  red_op_B=0;
  #4;
  red_op_A=0;
  red_op_B=1;
  #4;
  red_op_A=1; //operation will done on A as pariorty is set to A
  red_op_B=1;
  
  #4; // XOR reduction
  #2 rst = 1;
  #2 rst = 0;
  opcode = 3'b001;
  red_op_A=1;
  red_op_B=0;
  #4;
  red_op_A=0;
  red_op_B=1;
  #4;
  red_op_A=1; //operation will done on A as pariorty is set to A
  red_op_B=1;

  //test case 11: random test on reduction operation to test all invalid cases
  #4;
  opcode=3'b000;
  #2 rst = 1;
  #2 rst = 0;
  for(i=0;i<7;i=i+1)
  begin
    @(negedge clk);
    red_op_A=$random;
    red_op_B=$random;
    opcode=opcode+1;
    #2;
  end
  red_op_A=0;
  red_op_B=0;

 //test case 12: invalid opcode
  #2 rst = 1;
  #2 rst = 0;
 #4;
 opcode = 3'b110;
 #4;
 opcode = 3'b111;
 $stop;
 end

endmodule