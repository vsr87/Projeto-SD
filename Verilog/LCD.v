module LCD(clk, S, SR, SSA, a, SSB, b, Sestado, EN, RS, RW, data);

input [15:0] S; // entrada do resultado
input SR; // entrada da sinal da saida
input SSA, SSB; // entrada dos sinais das entradas
input [7:0] a, b; // entrada dos inputs
input [2:0] Sestado; // entarda do estado_atual
input clk;

output reg EN, RS, RW;
output reg[7:0] data; // saida no LCD

reg [31:0] counter = 0;
reg [1:0] state;
reg [7:0] instructions;
parameter MS = 50_000; // delay 1 milisegundo
parameter WRITE = 0, WAIT = 1;


initial 
	begin
    data = 0;
    EN = 0;
    RW = 0;
    RS = 0;
	 state = WRITE;
	 instructions = 0;
	end
	
	
always @(posedge clk) begin
    case (state)
        WRITE: begin
            if (counter == MS - 1) begin
                state <= WAIT; 
					 counter <= 0;
					 EN <= 0;
            end 			
				else begin
                counter <= counter + 1;
            end
        end
		  
        WAIT: begin
            if (counter == MS - 1) begin
                state <= WRITE; 
					 counter <= 0;
					 EN <= 1;
                if (instructions < 21) instructions <= instructions + 1;
					 else instructions <= 2;
					 
            end else begin
                counter <= counter + 1;
            end
        end

        default: counter <= 0;
    endcase 
end

always @(posedge clk) begin // maquina de estados LCD

	if(Sestado != 0) begin // Sestado != Desligado
		case (instructions) 
			0: begin data <= 8'b00111000; RS <= 0; end // Mode Function
			1: begin data <= 8'b00000001; RS <= 0; end // CLEAR
			2: begin data <= 8'b10000000; RS <= 0; end // posicao a
			3: begin                                                    // sinal a
					if(SSA==0) begin data <= 8'b00101011; RS <= 1; end // +
					else begin data <= 8'b00101101; RS <= 1; end          // -
				end
			4: begin data <= 8'd48+(a/100); RS <= 1; end     // centena a
			5: begin data <= 8'd48+((a/10)%10); RS <= 1; end // dezena a
			6: begin data <= 8'd48+(a%10); RS <= 1; end      // unidade a
			7: begin data <= 8'b10000110; RS <= 0; end // posicao op
			8: begin
																	// op
					if(Sestado == 2)begin data <= 8'd43; RS <= 1; end   // +
					if(Sestado == 4)begin data <= 8'd45; RS <= 1; end   // -
					if(Sestado == 3)begin data <= 8'b0111_1000; RS <= 1; end  // X
				end
			9:begin data <= 8'b10001001; RS <= 0; end // posicao b
			10: begin                                                   // sinal b
					if(SSB==0) begin data <= 8'b00101011; RS <= 1; end // +
					else begin data <= 8'b00101101; RS <= 1; end          // -
				end
			11: begin data <= 8'd48+(b/100); RS <= 1; end     // centena b
			12: begin data <= 8'd48+((b/10)%10); RS <= 1; end // dezena b
			13: begin data <= 8'd48+(b%10); RS <= 1; end      // unidade b
			14: begin data <= 8'b11000000; RS <= 0; end // posicao s
			15: begin 
					if(Sestado!= 1 && Sestado != 0 && (Sestado == 2 || Sestado == 3 || Sestado == 4))begin // Sestado != Ligado													// sinal saida
						if(SR==0) begin data <= 8'b00101011; RS <= 1; end // +
						else begin data <= 8'b00101101; RS <= 1; end      // -
					 end
				 end
			16: begin
					if(Sestado!= 1 && Sestado != 0 && (Sestado == 2 || Sestado == 3 || Sestado == 4))begin data <= 8'd48+(S/10000); RS <= 1;end //dezena milhar saida
				 end
			17: begin
					if(Sestado!= 1 && Sestado != 0 && (Sestado == 2 || Sestado == 3 || Sestado == 4))begin data <= 8'd48+((S/1000)%10); RS <= 1;end //milhar saida
				 end
			18: begin
					if(Sestado!= 1 && Sestado != 0 && (Sestado == 2 || Sestado == 3 || Sestado == 4))begin data <= 8'd48+((S/100)%10); RS <= 1;end //centena saida
				 end
			19: begin
					if(Sestado!= 1 && Sestado != 0 && (Sestado == 2 || Sestado == 3 || Sestado == 4))begin data <= 8'd48+((S/10)%10); RS <= 1;end //dezena saida
				 end
			20: begin
					if(Sestado!= 1 && Sestado != 0 && (Sestado == 2 || Sestado == 3 || Sestado == 4))begin data <= 8'd48+(S%10); RS <= 1;end //unidade saida
				 end
			default: begin data <= 8'b10000000; RS <= 0; end
		endcase
	end
	else begin data <= 8'b00000001; RS <= 0; end // if desligado
	
end

endmodule