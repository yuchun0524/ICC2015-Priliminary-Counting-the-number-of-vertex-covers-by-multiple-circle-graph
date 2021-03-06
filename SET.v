module SET (clk ,rst, en,central,radius, mode, busy, valid, candidate);
input clk;
input rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0]mode;
output reg busy;
output reg valid;
output reg [7:0]candidate;
reg [3:0] x1, y1, x2, y2, x3, y3;
reg [3:0] x, y;
reg [3:0] r1, r2, r3;
reg [1:0] store_mode;
reg [3:0] state;
reg [3:0] diff_x1, diff_x2, diff_x3, diff_y1, diff_y2, diff_y3;
wire [7:0] A = r1 * r1;
wire [7:0] B = r2 * r2;
wire [7:0] C = r3 * r3;
wire [8:0] square1 = diff_x1 * diff_x1 + diff_y1 * diff_y1 ;
wire [8:0] square2 = diff_x2 * diff_x2 + diff_y2 * diff_y2 ;
wire [8:0] square3 = diff_x3 * diff_x3 + diff_y3 * diff_y3 ;
//====================================================================
always@(posedge clk or posedge rst)
begin
  if(rst)
    begin
      busy <= 1'b0;
      valid <= 1'b0;
      {x1, y1, x2, y2, x3, y3} <= 24'd0;
      {x, y} <= 8'b00010001;
      {r1, r2, r3} <= 12'd0;
      store_mode <= 2'd0;
      state <= 4'd0;
      candidate <= 8'd0;
      {diff_x1, diff_x2, diff_x3, diff_y1, diff_y2, diff_y3} <= 24'd0;
    end
  else
    begin
      case(state)
        4'd0:begin
          if(en)
            begin
              {x1, y1, x2, y2, x3, y3} <= central;
              {r1, r2, r3} <= radius;
              store_mode <= mode;
              candidate <= 8'd0;
              valid <= 0;
              busy <= 1'b1;
              state <= 4'd1;
            end
          else
            begin
              {x1, y1, x2, y2, x3, y3} <= {x1, y1, x2, y2, x3, y3};
              {r1, r2, r3} <= {r1, r2, r3};
              store_mode <= store_mode;
              candidate <= candidate;
              valid <= valid;
              busy <= 1'b0;
              state <= 4'd0;
            end
          end
        4'd1:begin
          case(store_mode)  //synthesis parallel_case
            2'd0: state <= 4'd2;
            2'd1: state <= 4'd3;
            2'd2: state <= 4'd3;
            2'd3: state <= 4'd4;
            default: state <= 4'd0;
            endcase
          end
        4'd2:begin
          if(x >= x1)
            diff_x1 <= x - x1;
          else
            diff_x1 <= x1 - x;
          if(y >= y1)
            diff_y1 <= y - y1;
          else
            diff_y1 <= y1 - y;
          state <= 4'd5;
          end
        4'd3:begin
          if(x >= x1)
            diff_x1 <= x - x1;
          else
            diff_x1 <= x1 - x;
          if(y >= y1)
            diff_y1 <= y - y1;
          else
            diff_y1 <= y1 - y;
          if(x >= x2)
            diff_x2 <= x - x2;
          else
            diff_x2 <= x2 - x;
          if(y >= y2)
            diff_y2 <= y - y2;
          else
            diff_y2 <= y2 - y;
          case(store_mode)
            2'd1: state <= 4'd6;
            2'd2: state <= 4'd7;
            default: state <= 4'd0;
            endcase  
          end
        4'd4:begin
          if(x >= x1)
            diff_x1 <= x - x1;
          else
            diff_x1 <= x1 - x;
          if(y >= y1)
            diff_y1 <= y - y1;
          else
            diff_y1 <= y1 - y;
          if(x >= x2)
            diff_x2 <= x - x2;
          else
            diff_x2 <= x2 - x;
          if(y >= y2)
            diff_y2 <= y - y2;
          else
            diff_y2 <= y2 - y;
          if(x >= x3)
            diff_x3 <= x - x3;
          else
            diff_x3 <= x3 - x;
          if(y >= y3)
            diff_y3 <= y - y3;
          else
            diff_y3 <= y3 - y;
          state <= 4'd8;
          end
        4'd5:begin
          if(square1 <= A)
            candidate <= candidate + 1;
          else
            candidate <= candidate;
          state <= 4'd9;
          end
        4'd6:begin
          if(square1 <= A && square2 <= B)
            candidate <= candidate + 1;
          else
            candidate <= candidate;
          state <= 4'd9;
          end
        4'd7:begin
          if((square1 <= A && square2 > B) || (square1 > A && square2 <= B))
            candidate <= candidate + 1;
          else
            candidate <= candidate;
          state <= 4'd9;
          end
        4'd8:begin
          if((square1 <= A && square2 <= B && square3 > C)|| 
             (square1 <= A && square2 > B && square3 <= C)||
             (square1 > A && square2 <= B && square3 <= C))
            candidate <= candidate + 1;
          else
            candidate <= candidate;
          state <= 4'd9;
          end
        4'd9:begin
          if(x != 8)
            begin
              x <= x + 1;
              state <= 4'd1;
            end
          else
            begin
              if(y != 8)
                begin
                  x <= 1;
                  y <= y + 1;
                  state <= 4'd1;
                end
              else
                begin
                  state <= 4'd10;
                end
            end
          end
        4'd10:begin
          busy <= 0;
          valid <= 1;
          state <= 4'd0;
          x <= 1;
          y <= 1;
          end
        default:begin
          state <= 4'd0;
          end
        endcase
    end
end
endmodule