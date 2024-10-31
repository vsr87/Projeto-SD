module Verilog1(A, SA, SB, B, ON_OFF, So, Sub, Mult, clk, R, SR, SSA,RA, SSB, RB, Sestado);

input [7:0] A, B; // entradas
input SA, SB; // sinal de A e de B
input ON_OFF, So, Sub, Mult; // botões de ligar/desligar e os das operações
input clk;
output reg [15:0] R; // saida do resultado
output reg SR; // sinal da saida
output reg SSA, SSB; // sinais de saida das entradas
output reg [7:0] RA, RB; // saidas dos inputs
output reg[2:0] Sestado; // saida do estado atual

reg [2:0] estado_atual;
reg [3:0] estado_anterior;
parameter Desligado = 0, Ligado = 1, OpSoma = 2, OpMult = 3, OpSub = 4;

initial begin
	R = 0;
	SSA = 0;
	SSB = 0;
	RA = 0;
	RB = 0;
	estado_atual = Desligado;
	Sestado = Desligado;
end

always @ (*)
begin
    case(estado_atual)
	 
        Desligado : begin
				R = 0;
				SSA = 0;
				SSB = 0;
				RA = 0;
				RB = 0;
				Sestado = Desligado;
        end

        Ligado : begin
		  
            RA = A;
            RB = B;
				SSA = SA;
				SSB = SB;
				Sestado = Ligado;
				R = 0;
        end

        OpSoma : begin
		  
		  
		   RA = A;
		   RB = B;
			SSA = SA;
			SSB = SB;
			Sestado = OpSoma;
				
			if(SA == SB)
				begin
					SR = SA;
					R = A + B;
				end
				
			else 
				begin
			
				if(A > B)
					begin
					R = A - B; //sinais diferentes
					if(SA == 1)
						begin
						SR = 1;
						end
					else 
						begin
						SR = 0;
						end
					end
				else if(B>A)
					begin
					R = B - A;
					if(SB == 1)
						begin
						SR = 1;
						end
					else 
						begin
						SR = 0;
						end
					end
				else 
					begin
					SR = 0;
					R = 0;
					end
				
			end
				
				
        end

        OpMult : begin
		  
            RA = A;
            RB = B;
            R = A * B;
				SSA = SA;
				SSB = SB;
				Sestado = OpMult;
				
				if(SA == SB) 
					begin
						SR = 0;
					end				
				else 
					begin
						SR = 1;
					end
        end

        OpSub : 
				begin
				RA = A;
            RB = B;
				SSA = SA;
				SSB = SB;
				Sestado = OpSub;
				
				if(SA != SB)
					begin
					R = A + B;
					SR = SA;
					end
				else 
					begin
					if(A > B)
						begin
						R = A - B;
						SR = SA;
						end
					else if(B > A)
						begin
						R = B - A;
						SR = !SB;
						end
					else //se A=B e subtrair sinais iguais = 0 
						begin
						SR = 0;
						R = 0;
						end
					end
				end
    endcase
end

always @ (posedge clk) 
begin

    estado_anterior <= {So, Sub, Mult, ON_OFF};
		
	if(estado_anterior[0] && !ON_OFF)begin
			if(estado_atual == Desligado) estado_atual = Ligado;
			else estado_atual = Desligado;
		end
	else if(estado_anterior[1] && !Mult && estado_atual != Desligado) estado_atual = OpMult;
	else if(estado_anterior[2] && !Sub && estado_atual != Desligado) estado_atual = OpSub;
	else if(estado_anterior[3] && !So && estado_atual != Desligado) estado_atual = OpSoma;
end

endmodule