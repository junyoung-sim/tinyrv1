module Register (
	clk,
	rst,
	en,
	d,
	q
);
	parameter nbits = 32;
	input wire clk;
	input wire rst;
	input wire en;
	input wire [nbits - 1:0] d;
	output reg [nbits - 1:0] q;
	always @(posedge clk)
		if (rst)
			q <= {nbits {1'b0}};
		else
			q <= (en ? d : q);
endmodule
module ProcCtrl (
	clk,
	rst,
	c2d_imemreq_val_F,
	c2d_reg_en_F,
	c2d_pc_sel_F,
	c2d_reg_en_D,
	c2d_imm_type_D,
	c2d_op1_byp_sel_D,
	c2d_op2_byp_sel_D,
	c2d_op1_sel_D,
	c2d_op2_sel_D,
	c2d_csrr_sel_D,
	c2d_alu_fn_X,
	c2d_result_sel_X,
	c2d_dmemreq_val_M,
	c2d_dmemreq_type_M,
	c2d_wb_sel_M,
	c2d_rf_wen_W,
	c2d_rf_waddr_W,
	c2d_csrw_out0_en_W,
	c2d_csrw_out1_en_W,
	c2d_csrw_out2_en_W,
	d2c_eq_X,
	d2c_inst,
	trace_stall
);
	input wire clk;
	input wire rst;
	output wire c2d_imemreq_val_F;
	output wire c2d_reg_en_F;
	output reg [1:0] c2d_pc_sel_F;
	output wire c2d_reg_en_D;
	output reg [1:0] c2d_imm_type_D;
	output reg [1:0] c2d_op1_byp_sel_D;
	output reg [1:0] c2d_op2_byp_sel_D;
	output reg c2d_op1_sel_D;
	output reg [1:0] c2d_op2_sel_D;
	output reg [1:0] c2d_csrr_sel_D;
	output reg c2d_alu_fn_X;
	output reg [1:0] c2d_result_sel_X;
	output reg c2d_dmemreq_val_M;
	output reg c2d_dmemreq_type_M;
	output reg c2d_wb_sel_M;
	output reg c2d_rf_wen_W;
	output reg [4:0] c2d_rf_waddr_W;
	output reg c2d_csrw_out0_en_W;
	output reg c2d_csrw_out1_en_W;
	output reg c2d_csrw_out2_en_W;
	input wire d2c_eq_X;
	input wire [31:0] d2c_inst;
	output wire trace_stall;
	wire [31:0] inst_D;
	wire [31:0] inst_X;
	wire [31:0] inst_M;
	wire [31:0] inst_W;
	wire val_D;
	wire val_X;
	wire val_M;
	wire val_W;
	reg rs1_en_D;
	reg rs2_en_D;
	reg rf_wen_X;
	reg rf_wen_M;
	reg rf_wen_W;
	reg [4:0] rf_waddr_W;
	wire [4:0] rs1_D;
	wire [4:0] rs2_D;
	wire [4:0] rd_X;
	wire [4:0] rd_M;
	wire [4:0] rd_W;
	reg bypass_waddr_X_rs1_D;
	reg bypass_waddr_X_rs2_D;
	reg bypass_waddr_M_rs1_D;
	reg bypass_waddr_M_rs2_D;
	reg bypass_waddr_W_rs1_D;
	reg bypass_waddr_W_rs2_D;
	reg stall_lw_X_rs1_D;
	reg stall_lw_X_rs2_D;
	reg stall_D;
	reg stall_F;
	reg squash_D;
	reg squash_F;
	reg [11:0] csrr_num;
	reg [1:0] csrr_sel;
	reg [11:0] csrw_num;
	assign inst_D = d2c_inst;
	Register #(.nbits(32)) ir_DX(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(inst_D),
		.q(inst_X)
	);
	Register #(.nbits(32)) ir_XM(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(inst_X),
		.q(inst_M)
	);
	Register #(.nbits(32)) ir_MW(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(inst_M),
		.q(inst_W)
	);
	Register #(.nbits(1)) val_FD(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(~squash_F | stall_D),
		.q(val_D)
	);
	Register #(.nbits(1)) val_DX(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d((val_D & ~stall_D) & ~squash_D),
		.q(val_X)
	);
	Register #(.nbits(1)) val_XM(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(val_X),
		.q(val_M)
	);
	Register #(.nbits(1)) val_MW(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(val_M),
		.q(val_W)
	);
	always @(*) begin
		rs1_en_D = ((((((((inst_D | 32'b00000001111111111000111110000000) == 32'b00000001111111111000111110110011) | ((inst_D | 32'b11111111111111111000111110000000) == 32'b11111111111111111000111110010011)) | ((inst_D | 32'b00000001111111111000111110000000) == 32'b00000011111111111000111110110011)) | ((inst_D | 32'b11111111111111111000111110000000) == 32'b11111111111111111010111110000011)) | ((inst_D | 32'b11111111111111111000111110000000) == 32'b11111111111111111010111110100011)) | ((inst_D | 32'b11111111111111111000111110000000) == 32'b11111111111111111000111111100111)) | ((inst_D | 32'b11111111111111111000111110000000) == 32'b11111111111111111001111111100011)) | ((inst_D | 32'b11111111111111111000111110000000) == 32'b11111111111111111001111111110011);
		rs2_en_D = ((((inst_D | 32'b00000001111111111000111110000000) == 32'b00000001111111111000111110110011) | ((inst_D | 32'b00000001111111111000111110000000) == 32'b00000011111111111000111110110011)) | ((inst_D | 32'b11111111111111111000111110000000) == 32'b11111111111111111010111110100011)) | ((inst_D | 32'b11111111111111111000111110000000) == 32'b11111111111111111001111111100011);
		rf_wen_X = ((((((inst_X | 32'b00000001111111111000111110000000) == 32'b00000001111111111000111110110011) | ((inst_X | 32'b11111111111111111000111110000000) == 32'b11111111111111111000111110010011)) | ((inst_X | 32'b00000001111111111000111110000000) == 32'b00000011111111111000111110110011)) | ((inst_X | 32'b11111111111111111000111110000000) == 32'b11111111111111111010111110000011)) | ((inst_X | 32'b11111111111111111111111110000000) == 32'b11111111111111111111111111101111)) | ((inst_X | 32'b11111111111111111000111110000000) == 32'b11111111111111111010111111110011);
		rf_wen_M = ((((((inst_M | 32'b00000001111111111000111110000000) == 32'b00000001111111111000111110110011) | ((inst_M | 32'b11111111111111111000111110000000) == 32'b11111111111111111000111110010011)) | ((inst_M | 32'b00000001111111111000111110000000) == 32'b00000011111111111000111110110011)) | ((inst_M | 32'b11111111111111111000111110000000) == 32'b11111111111111111010111110000011)) | ((inst_M | 32'b11111111111111111111111110000000) == 32'b11111111111111111111111111101111)) | ((inst_M | 32'b11111111111111111000111110000000) == 32'b11111111111111111010111111110011);
		rf_wen_W = ((((((inst_W | 32'b00000001111111111000111110000000) == 32'b00000001111111111000111110110011) | ((inst_W | 32'b11111111111111111000111110000000) == 32'b11111111111111111000111110010011)) | ((inst_W | 32'b00000001111111111000111110000000) == 32'b00000011111111111000111110110011)) | ((inst_W | 32'b11111111111111111000111110000000) == 32'b11111111111111111010111110000011)) | ((inst_W | 32'b11111111111111111111111110000000) == 32'b11111111111111111111111111101111)) | ((inst_W | 32'b11111111111111111000111110000000) == 32'b11111111111111111010111111110011);
	end
	assign rs1_D = inst_D[19:15];
	assign rs2_D = inst_D[24:20];
	assign rd_X = inst_X[11:7];
	assign rd_M = inst_M[11:7];
	assign rd_W = inst_W[11:7];
	always @(*) begin
		bypass_waddr_X_rs1_D = (((((val_D & rs1_en_D) & val_X) & rf_wen_X) & (rs1_D == rd_X)) & (rd_X != 0)) & ((inst_X | 32'b11111111111111111000111110000000) != 32'b11111111111111111010111110000011);
		bypass_waddr_X_rs2_D = (((((val_D & rs2_en_D) & val_X) & rf_wen_X) & (rs2_D == rd_X)) & (rd_X != 0)) & ((inst_X | 32'b11111111111111111000111110000000) != 32'b11111111111111111010111110000011);
		bypass_waddr_M_rs1_D = ((((val_D & rs1_en_D) & val_M) & rf_wen_M) & (rs1_D == rd_M)) & (rd_M != 0);
		bypass_waddr_M_rs2_D = ((((val_D & rs2_en_D) & val_M) & rf_wen_M) & (rs2_D == rd_M)) & (rd_M != 0);
		bypass_waddr_W_rs1_D = ((((val_D & rs1_en_D) & val_W) & rf_wen_W) & (rs1_D == rd_W)) & (rd_W != 0);
		bypass_waddr_W_rs2_D = ((((val_D & rs2_en_D) & val_W) & rf_wen_W) & (rs2_D == rd_W)) & (rd_W != 0);
	end
	always @(*) begin
		stall_lw_X_rs1_D = ((((val_D & rs1_en_D) & val_X) & ((inst_X | 32'b11111111111111111000111110000000) == 32'b11111111111111111010111110000011)) & (rs1_D == rd_X)) & (rd_X != 0);
		stall_lw_X_rs2_D = ((((val_D & rs2_en_D) & val_X) & ((inst_X | 32'b11111111111111111000111110000000) == 32'b11111111111111111010111110000011)) & (rs2_D == rd_X)) & (rd_X != 0);
		stall_D = val_D & (stall_lw_X_rs1_D | stall_lw_X_rs2_D);
		stall_F = stall_D;
	end
	assign trace_stall = stall_F;
	always @(*) begin
		squash_D = (val_X & ((inst_X | 32'b11111111111111111000111110000000) == 32'b11111111111111111001111111100011)) & ~d2c_eq_X;
		squash_F = squash_D | (val_D & (((inst_D | 32'b11111111111111111111111110000000) == 32'b11111111111111111111111111101111) | ((inst_D | 32'b11111111111111111000111110000000) == 32'b11111111111111111000111111100111)));
	end
	assign c2d_reg_en_F = ~stall_F;
	assign c2d_imemreq_val_F = 1;
	always @(*)
		if (squash_D)
			c2d_pc_sel_F = 3;
		else if (val_D)
			casez (inst_D)
				32'bzzzzzzzzzzzzzzzzz000zzzzz1100111: c2d_pc_sel_F = 1;
				32'bzzzzzzzzzzzzzzzzzzzzzzzzz1101111: c2d_pc_sel_F = 2;
				default: c2d_pc_sel_F = 0;
			endcase
		else
			c2d_pc_sel_F = 0;
	assign c2d_reg_en_D = ~stall_D;
	always @(*)
		if (bypass_waddr_X_rs1_D)
			c2d_op1_byp_sel_D = 1;
		else if (bypass_waddr_M_rs1_D)
			c2d_op1_byp_sel_D = 2;
		else if (bypass_waddr_W_rs1_D)
			c2d_op1_byp_sel_D = 3;
		else
			c2d_op1_byp_sel_D = 0;
	always @(*)
		if (bypass_waddr_X_rs2_D)
			c2d_op2_byp_sel_D = 1;
		else if (bypass_waddr_M_rs2_D)
			c2d_op2_byp_sel_D = 2;
		else if (bypass_waddr_W_rs2_D)
			c2d_op2_byp_sel_D = 3;
		else
			c2d_op2_byp_sel_D = 0;
	always @(*)
		if (val_D & ((inst_D | 32'b11111111111111111000111110000000) == 32'b11111111111111111010111111110011)) begin
			csrr_num = inst_D[31:20];
			case (csrr_num)
				12'hfc2: csrr_sel = 0;
				12'hfc3: csrr_sel = 1;
				12'hfc4: csrr_sel = 2;
				default: csrr_sel = 1'sbx;
			endcase
		end
		else begin
			csrr_num = 1'sbx;
			csrr_sel = 1'sbx;
		end
	task automatic cs_D;
		input reg [1:0] imm_type_D;
		input reg op1_sel_D;
		input reg [1:0] op2_sel_D;
		input reg [1:0] csrr_sel_D;
		begin
			c2d_imm_type_D = imm_type_D;
			c2d_op1_sel_D = op1_sel_D;
			c2d_op2_sel_D = op2_sel_D;
			c2d_csrr_sel_D = csrr_sel_D;
		end
	endtask
	always @(*)
		if (val_D)
			casez (inst_D)
				32'b0000000zzzzzzzzzz000zzzzz0110011:
					cs_D(1'sbx, 0, 0, 1'sbx);
				32'bzzzzzzzzzzzzzzzzz000zzzzz0010011:
					cs_D(0, 0, 1, 1'sbx);
				32'b0000001zzzzzzzzzz000zzzzz0110011:
					cs_D(1'sbx, 0, 0, 1'sbx);
				32'bzzzzzzzzzzzzzzzzz010zzzzz0000011:
					cs_D(0, 0, 1, 1'sbx);
				32'bzzzzzzzzzzzzzzzzz010zzzzz0100011:
					cs_D(1, 0, 1, 1'sbx);
				32'bzzzzzzzzzzzzzzzzz000zzzzz1100111:
					cs_D(1'sbx, 0, 1'sbx, 1'sbx);
				32'bzzzzzzzzzzzzzzzzzzzzzzzzz1101111:
					cs_D(2, 1, 2, 1'sbx);
				32'bzzzzzzzzzzzzzzzzz001zzzzz1100011:
					cs_D(3, 0, 0, 1'sbx);
				32'bzzzzzzzzzzzzzzzzz010zzzzz1110011:
					cs_D(1'sbx, 1'sbx, 1'sbx, csrr_sel);
				32'bzzzzzzzzzzzzzzzzz001zzzzz1110011:
					cs_D(1'sbx, 1'sbx, 1'sbx, 1'sbx);
				default:
					cs_D(1'sbx, 1'sbx, 1'sbx, 1'sbx);
			endcase
		else
			cs_D(1'sbx, 1'sbx, 1'sbx, 1'sbx);
	task automatic cs_X;
		input reg alu_fn_X;
		input reg [1:0] result_sel_X;
		begin
			c2d_alu_fn_X = alu_fn_X;
			c2d_result_sel_X = result_sel_X;
		end
	endtask
	always @(*)
		if (val_X)
			casez (inst_X)
				32'b0000000zzzzzzzzzz000zzzzz0110011:
					cs_X(0, 0);
				32'bzzzzzzzzzzzzzzzzz000zzzzz0010011:
					cs_X(0, 0);
				32'b0000001zzzzzzzzzz000zzzzz0110011:
					cs_X(1'sbx, 1);
				32'bzzzzzzzzzzzzzzzzz010zzzzz0000011:
					cs_X(0, 0);
				32'bzzzzzzzzzzzzzzzzz010zzzzz0100011:
					cs_X(0, 0);
				32'bzzzzzzzzzzzzzzzzz000zzzzz1100111:
					cs_X(1'sbx, 1'sbx);
				32'bzzzzzzzzzzzzzzzzzzzzzzzzz1101111:
					cs_X(0, 0);
				32'bzzzzzzzzzzzzzzzzz001zzzzz1100011:
					cs_X(1, 1'sbx);
				32'bzzzzzzzzzzzzzzzzz010zzzzz1110011:
					cs_X(1'sbx, 2);
				32'bzzzzzzzzzzzzzzzzz001zzzzz1110011:
					cs_X(1'sbx, 1'sbx);
				default:
					cs_X(1'sbx, 1'sbx);
			endcase
		else
			cs_X(1'sbx, 1'sbx);
	task automatic cs_M;
		input reg dmemreq_val_M;
		input reg dmemreq_type_M;
		input reg wb_sel_M;
		begin
			c2d_dmemreq_val_M = dmemreq_val_M;
			c2d_dmemreq_type_M = dmemreq_type_M;
			c2d_wb_sel_M = wb_sel_M;
		end
	endtask
	always @(*)
		if (val_M)
			casez (inst_M)
				32'b0000000zzzzzzzzzz000zzzzz0110011:
					cs_M(0, 1'sbx, 0);
				32'bzzzzzzzzzzzzzzzzz000zzzzz0010011:
					cs_M(0, 1'sbx, 0);
				32'b0000001zzzzzzzzzz000zzzzz0110011:
					cs_M(0, 1'sbx, 0);
				32'bzzzzzzzzzzzzzzzzz010zzzzz0000011:
					cs_M(1, 0, 1);
				32'bzzzzzzzzzzzzzzzzz010zzzzz0100011:
					cs_M(1, 1, 1'sbx);
				32'bzzzzzzzzzzzzzzzzz000zzzzz1100111:
					cs_M(0, 1'sbx, 1'sbx);
				32'bzzzzzzzzzzzzzzzzzzzzzzzzz1101111:
					cs_M(0, 1'sbx, 0);
				32'bzzzzzzzzzzzzzzzzz001zzzzz1100011:
					cs_M(0, 1'sbx, 1'sbx);
				32'bzzzzzzzzzzzzzzzzz010zzzzz1110011:
					cs_M(0, 1'sbx, 0);
				32'bzzzzzzzzzzzzzzzzz001zzzzz1110011:
					cs_M(0, 1'sbx, 1'sbx);
				default:
					cs_M(1'sbx, 1'sbx, 1'sbx);
			endcase
		else
			cs_M(1'sbx, 1'sbx, 1'sbx);
	task automatic cs_W;
		input reg _rf_wen_W;
		input reg [4:0] _rf_waddr_W;
		begin
			c2d_rf_wen_W = _rf_wen_W;
			c2d_rf_waddr_W = _rf_waddr_W;
		end
	endtask
	always @(*)
		if (val_W) begin
			rf_waddr_W = inst_W[11:7];
			casez (inst_W)
				32'b0000000zzzzzzzzzz000zzzzz0110011:
					cs_W(1, rf_waddr_W);
				32'bzzzzzzzzzzzzzzzzz000zzzzz0010011:
					cs_W(1, rf_waddr_W);
				32'b0000001zzzzzzzzzz000zzzzz0110011:
					cs_W(1, rf_waddr_W);
				32'bzzzzzzzzzzzzzzzzz010zzzzz0000011:
					cs_W(1, rf_waddr_W);
				32'bzzzzzzzzzzzzzzzzz010zzzzz0100011:
					cs_W(0, 1'sbx);
				32'bzzzzzzzzzzzzzzzzz000zzzzz1100111:
					cs_W(0, 1'sbx);
				32'bzzzzzzzzzzzzzzzzzzzzzzzzz1101111:
					cs_W(1, rf_waddr_W);
				32'bzzzzzzzzzzzzzzzzz001zzzzz1100011:
					cs_W(0, 1'sbx);
				32'bzzzzzzzzzzzzzzzzz010zzzzz1110011:
					cs_W(1, rf_waddr_W);
				32'bzzzzzzzzzzzzzzzzz001zzzzz1110011:
					cs_W(0, 1'sbx);
				default:
					cs_W(1'sbx, 1'sbx);
			endcase
		end
		else begin
			rf_waddr_W = 1'sbx;
			cs_W(1'sbx, 1'sbx);
		end
	always @(*)
		if (val_W & ((inst_W | 32'b11111111111111111000111110000000) == 32'b11111111111111111001111111110011)) begin
			csrw_num = inst_W[31:20];
			case (csrw_num)
				12'h7c2: begin
					c2d_csrw_out0_en_W = 1;
					c2d_csrw_out1_en_W = 0;
					c2d_csrw_out2_en_W = 0;
				end
				12'h7c3: begin
					c2d_csrw_out0_en_W = 0;
					c2d_csrw_out1_en_W = 1;
					c2d_csrw_out2_en_W = 0;
				end
				12'h7c4: begin
					c2d_csrw_out0_en_W = 0;
					c2d_csrw_out1_en_W = 0;
					c2d_csrw_out2_en_W = 1;
				end
				default: begin
					c2d_csrw_out0_en_W = 0;
					c2d_csrw_out1_en_W = 0;
					c2d_csrw_out2_en_W = 0;
				end
			endcase
		end
		else begin
			csrw_num = 1'sbx;
			c2d_csrw_out0_en_W = 0;
			c2d_csrw_out1_en_W = 0;
			c2d_csrw_out2_en_W = 0;
		end
endmodule
module Adder (
	in0,
	in1,
	sum
);
	parameter nbits = 32;
	input wire [nbits - 1:0] in0;
	input wire [nbits - 1:0] in1;
	output reg [nbits - 1:0] sum;
	always @(*) sum = in0 + in1;
endmodule
module EqComp (
	in0,
	in1,
	eq
);
	parameter nbits = 32;
	input wire [nbits - 1:0] in0;
	input wire [nbits - 1:0] in1;
	output reg eq;
	always @(*) eq = in0 == in1;
endmodule
module Mux2 (
	sel,
	in0,
	in1,
	out
);
	parameter nbits = 32;
	input wire sel;
	input wire [nbits - 1:0] in0;
	input wire [nbits - 1:0] in1;
	output reg [nbits - 1:0] out;
	always @(*)
		case (sel)
			1'b0: out = in0;
			1'b1: out = in1;
		endcase
endmodule
module ALU (
	op,
	in0,
	in1,
	out
);
	parameter nbits = 32;
	input wire op;
	input wire [nbits - 1:0] in0;
	input wire [nbits - 1:0] in1;
	output wire [nbits - 1:0] out;
	wire [nbits - 1:0] sum;
	Adder #(.nbits(32)) adder(
		.in0(in0),
		.in1(in1),
		.sum(sum)
	);
	wire eq;
	EqComp #(.nbits(32)) eq_comp(
		.in0(in0),
		.in1(in1),
		.eq(eq)
	);
	Mux2 #(.nbits(32)) out_mux(
		.sel(op),
		.in0(sum),
		.in1({31'b0000000000000000000000000000000, eq}),
		.out(out)
	);
endmodule
module Mux4 (
	sel,
	in0,
	in1,
	in2,
	in3,
	out
);
	parameter nbits = 32;
	input wire [1:0] sel;
	input wire [nbits - 1:0] in0;
	input wire [nbits - 1:0] in1;
	input wire [nbits - 1:0] in2;
	input wire [nbits - 1:0] in3;
	output reg [nbits - 1:0] out;
	always @(*)
		case (sel)
			2'b00: out = in0;
			2'b01: out = in1;
			2'b10: out = in2;
			2'b11: out = in3;
		endcase
endmodule
module ImmGen (
	inst,
	imm_type,
	imm
);
	input wire [31:0] inst;
	input wire [1:0] imm_type;
	output reg [31:0] imm;
	reg [6:0] inst_unused;
	always @(*) begin
		inst_unused = inst[6:0];
		case (imm_type)
			2'b00: imm = {{21 {inst[31]}}, inst[30:25], inst[24:21], inst[20]};
			2'b01: imm = {{21 {inst[31]}}, inst[30:25], inst[11:8], inst[7]};
			2'b10: imm = {{12 {inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
			2'b11: imm = {{20 {inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
		endcase
	end
endmodule
module Regfile (
	clk,
	wen,
	waddr,
	wdata,
	raddr0,
	rdata0,
	raddr1,
	rdata1
);
	input wire clk;
	input wire wen;
	input wire [4:0] waddr;
	input wire [31:0] wdata;
	input wire [4:0] raddr0;
	output reg [31:0] rdata0;
	input wire [4:0] raddr1;
	output reg [31:0] rdata1;
	reg [31:0] R [0:31];
	always @(posedge clk) R[waddr] <= (wen & (waddr != 0) ? wdata : R[waddr]);
	always @(*) begin
		rdata0 = (raddr0 == 0 ? 32'b00000000000000000000000000000000 : R[raddr0]);
		rdata1 = (raddr1 == 0 ? 32'b00000000000000000000000000000000 : R[raddr1]);
	end
endmodule
module Multiplier (
	in0,
	in1,
	prod
);
	parameter nbits = 32;
	input wire [nbits - 1:0] in0;
	input wire [nbits - 1:0] in1;
	output reg [nbits - 1:0] prod;
	always @(*) prod = in0 * in1;
endmodule
module ProcDpath (
	clk,
	rst,
	imemreq_val,
	imemreq_addr,
	imemresp_data,
	dmemreq_val,
	dmemreq_type,
	dmemreq_addr,
	dmemreq_wdata,
	dmemresp_rdata,
	in0,
	in1,
	in2,
	out0,
	out1,
	out2,
	c2d_imemreq_val_F,
	c2d_reg_en_F,
	c2d_pc_sel_F,
	c2d_reg_en_D,
	c2d_imm_type_D,
	c2d_op1_byp_sel_D,
	c2d_op2_byp_sel_D,
	c2d_op1_sel_D,
	c2d_op2_sel_D,
	c2d_csrr_sel_D,
	c2d_alu_fn_X,
	c2d_result_sel_X,
	c2d_dmemreq_val_M,
	c2d_dmemreq_type_M,
	c2d_wb_sel_M,
	c2d_rf_wen_W,
	c2d_rf_waddr_W,
	c2d_csrw_out0_en_W,
	c2d_csrw_out1_en_W,
	c2d_csrw_out2_en_W,
	d2c_eq_X,
	d2c_inst,
	trace_addr,
	trace_inst,
	trace_data
);
	input wire clk;
	input wire rst;
	output wire imemreq_val;
	output wire [31:0] imemreq_addr;
	input wire [31:0] imemresp_data;
	output wire dmemreq_val;
	output wire dmemreq_type;
	output wire [31:0] dmemreq_addr;
	output wire [31:0] dmemreq_wdata;
	input wire [31:0] dmemresp_rdata;
	input wire [31:0] in0;
	input wire [31:0] in1;
	input wire [31:0] in2;
	output wire [31:0] out0;
	output wire [31:0] out1;
	output wire [31:0] out2;
	input wire c2d_imemreq_val_F;
	input wire c2d_reg_en_F;
	input wire [1:0] c2d_pc_sel_F;
	input wire c2d_reg_en_D;
	input wire [1:0] c2d_imm_type_D;
	input wire [1:0] c2d_op1_byp_sel_D;
	input wire [1:0] c2d_op2_byp_sel_D;
	input wire c2d_op1_sel_D;
	input wire [1:0] c2d_op2_sel_D;
	input wire [1:0] c2d_csrr_sel_D;
	input wire c2d_alu_fn_X;
	input wire [1:0] c2d_result_sel_X;
	input wire c2d_dmemreq_val_M;
	input wire c2d_dmemreq_type_M;
	input wire c2d_wb_sel_M;
	input wire c2d_rf_wen_W;
	input wire [4:0] c2d_rf_waddr_W;
	input wire c2d_csrw_out0_en_W;
	input wire c2d_csrw_out1_en_W;
	input wire c2d_csrw_out2_en_W;
	output wire d2c_eq_X;
	output wire [31:0] d2c_inst;
	output wire [31:0] trace_addr;
	output wire [31:0] trace_inst;
	output wire [31:0] trace_data;
	wire rf_wen;
	wire [4:0] rf_waddr;
	wire [31:0] rf_wdata;
	wire [4:0] rs1_addr;
	wire [4:0] rs2_addr;
	wire [31:0] rs1;
	wire [31:0] rs2;
	Regfile RF(
		.clk(clk),
		.wen(rf_wen),
		.waddr(rf_waddr),
		.wdata(rf_wdata),
		.raddr0(rs1_addr),
		.rdata0(rs1),
		.raddr1(rs2_addr),
		.rdata1(rs2)
	);
	wire [31:0] result_X_next;
	wire [31:0] result_M_next;
	wire [31:0] result_W_next;
	wire [31:0] op1_bypass;
	wire [31:0] op2_bypass;
	wire [31:0] pc;
	wire [31:0] pc_next;
	Register #(.nbits(32)) pc_F(
		.clk(clk),
		.rst(rst),
		.en(c2d_reg_en_F),
		.d(pc_next),
		.q(pc)
	);
	wire [31:0] pc_plus4;
	Adder #(.nbits(32)) pc_plus4_adder(
		.in0(pc),
		.in1(32'h00000004),
		.sum(pc_plus4)
	);
	wire [31:0] pc_jr;
	wire [31:0] pc_targ;
	wire [31:0] pc_jtarg;
	wire [31:0] pc_btarg;
	assign pc_jr = op1_bypass;
	assign pc_jtarg = pc_targ;
	Mux4 #(.nbits(32)) pc_mux(
		.sel(c2d_pc_sel_F),
		.in0(pc_plus4),
		.in1(pc_jr),
		.in2(pc_jtarg),
		.in3(pc_btarg),
		.out(pc_next)
	);
	assign imemreq_val = c2d_imemreq_val_F;
	assign imemreq_addr = pc;
	wire [31:0] inst;
	wire [31:0] inst_next;
	assign inst_next = imemresp_data;
	Register #(.nbits(32)) ir_FD(
		.clk(clk),
		.rst(rst),
		.en(c2d_reg_en_D),
		.d(inst_next),
		.q(inst)
	);
	assign d2c_inst = inst;
	wire [31:0] inst_pc;
	Register #(.nbits(32)) pc_FD(
		.clk(clk),
		.rst(rst),
		.en(c2d_reg_en_D),
		.d(pc),
		.q(inst_pc)
	);
	assign rs1_addr = inst[19:15];
	assign rs2_addr = inst[24:20];
	wire [31:0] imm;
	ImmGen immgen(
		.inst(inst),
		.imm_type(c2d_imm_type_D),
		.imm(imm)
	);
	Adder #(.nbits(32)) pc_targ_adder(
		.in0(inst_pc),
		.in1(imm),
		.sum(pc_targ)
	);
	Register #(.nbits(32)) btarg_DX(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(pc_targ),
		.q(pc_btarg)
	);
	Mux4 #(.nbits(32)) op1_bypass_mux(
		.sel(c2d_op1_byp_sel_D),
		.in0(rs1),
		.in1(result_X_next),
		.in2(result_M_next),
		.in3(result_W_next),
		.out(op1_bypass)
	);
	Mux4 #(.nbits(32)) op2_bypass_mux(
		.sel(c2d_op2_byp_sel_D),
		.in0(rs2),
		.in1(result_X_next),
		.in2(result_M_next),
		.in3(result_W_next),
		.out(op2_bypass)
	);
	wire [31:0] op1;
	wire [31:0] op2;
	wire [31:0] op1_next;
	wire [31:0] op2_next;
	Mux2 #(.nbits(32)) op1_mux(
		.sel(c2d_op1_sel_D),
		.in0(op1_bypass),
		.in1(inst_pc),
		.out(op1_next)
	);
	Mux4 #(.nbits(32)) op2_mux(
		.sel(c2d_op2_sel_D),
		.in0(op2_bypass),
		.in1(imm),
		.in2(32'h00000004),
		.in3(32'h00000000),
		.out(op2_next)
	);
	Register #(.nbits(32)) op1_DX(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(op1_next),
		.q(op1)
	);
	Register #(.nbits(32)) op2_DX(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(op2_next),
		.q(op2)
	);
	wire [31:0] sd_X;
	Register #(.nbits(32)) sd_DX(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(op2_bypass),
		.q(sd_X)
	);
	wire [31:0] csrr_next;
	Mux4 #(.nbits(32)) csrr_mux(
		.sel(c2d_csrr_sel_D),
		.in0(in0),
		.in1(in1),
		.in2(in2),
		.in3(32'b00000000000000000000000000000000),
		.out(csrr_next)
	);
	wire [31:0] csrr;
	Register #(.nbits(32)) csrr_DX(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(csrr_next),
		.q(csrr)
	);
	wire [31:0] out_DX;
	Register #(.nbits(32)) csrw_out_DX(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(op1_bypass),
		.q(out_DX)
	);
	wire [31:0] alu_out;
	ALU #(.nbits(32)) alu(
		.op(c2d_alu_fn_X),
		.in0(op1),
		.in1(op2),
		.out(alu_out)
	);
	assign d2c_eq_X = alu_out[0];
	wire [31:0] mul_out;
	Multiplier #(.nbits(32)) mul(
		.in0(op1),
		.in1(op2),
		.prod(mul_out)
	);
	Mux4 #(.nbits(32)) result_X_mux(
		.sel(c2d_result_sel_X),
		.in0(alu_out),
		.in1(mul_out),
		.in2(csrr),
		.in3(32'b00000000000000000000000000000000),
		.out(result_X_next)
	);
	wire [31:0] result_X;
	Register #(.nbits(32)) result_XM(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(result_X_next),
		.q(result_X)
	);
	wire [31:0] sd_M;
	Register #(.nbits(32)) sd_XM(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(sd_X),
		.q(sd_M)
	);
	wire [31:0] out_XM;
	Register #(.nbits(32)) csrw_out_XM(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(out_DX),
		.q(out_XM)
	);
	assign dmemreq_val = c2d_dmemreq_val_M;
	assign dmemreq_type = c2d_dmemreq_type_M;
	assign dmemreq_addr = result_X;
	assign dmemreq_wdata = sd_M;
	Mux2 #(.nbits(32)) wb_mux(
		.sel(c2d_wb_sel_M),
		.in0(result_X),
		.in1(dmemresp_rdata),
		.out(result_M_next)
	);
	wire [31:0] result_M;
	Register #(.nbits(32)) result_MW(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(result_M_next),
		.q(result_M)
	);
	wire [31:0] out_MW;
	Register #(.nbits(32)) csrw_out_MW(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.d(out_XM),
		.q(out_MW)
	);
	assign result_W_next = result_M;
	assign rf_wen = c2d_rf_wen_W;
	assign rf_waddr = c2d_rf_waddr_W;
	assign rf_wdata = result_W_next;
	Register #(.nbits(32)) csrw_out0(
		.clk(clk),
		.rst(rst),
		.en(c2d_csrw_out0_en_W),
		.d(out_MW),
		.q(out0)
	);
	Register #(.nbits(32)) csrw_out1(
		.clk(clk),
		.rst(rst),
		.en(c2d_csrw_out1_en_W),
		.d(out_MW),
		.q(out1)
	);
	Register #(.nbits(32)) csrw_out2(
		.clk(clk),
		.rst(rst),
		.en(c2d_csrw_out2_en_W),
		.d(out_MW),
		.q(out2)
	);
	assign trace_addr = pc;
	assign trace_inst = imemresp_data;
	assign trace_data = rf_wdata;
endmodule
module Proc (
`ifndef USE_POWER_PINS
	inout vccd1,
	inout vssd1,
`endif
	clk,
	rst,
	imemreq_val,
	imemreq_addr,
	imemresp_data,
	dmemreq_val,
	dmemreq_type,
	dmemreq_addr,
	dmemreq_wdata,
	dmemresp_rdata,
	in0,
	in1,
	in2,
	out0,
	out1,
	out2,
	trace_addr,
	trace_inst,
	trace_data,
	trace_stall
);
	input wire clk;
	input wire rst;
	output wire imemreq_val;
	output wire [31:0] imemreq_addr;
	input wire [31:0] imemresp_data;
	output wire dmemreq_val;
	output wire dmemreq_type;
	output wire [31:0] dmemreq_addr;
	output wire [31:0] dmemreq_wdata;
	input wire [31:0] dmemresp_rdata;
	input wire [31:0] in0;
	input wire [31:0] in1;
	input wire [31:0] in2;
	output wire [31:0] out0;
	output wire [31:0] out1;
	output wire [31:0] out2;
	output wire [31:0] trace_addr;
	output wire [31:0] trace_inst;
	output wire [31:0] trace_data;
	output wire trace_stall;
	wire c2d_imemreq_val_F;
	wire c2d_reg_en_F;
	wire [1:0] c2d_pc_sel_F;
	wire c2d_reg_en_D;
	wire [1:0] c2d_imm_type_D;
	wire [1:0] c2d_op1_byp_sel_D;
	wire [1:0] c2d_op2_byp_sel_D;
	wire c2d_op1_sel_D;
	wire [1:0] c2d_op2_sel_D;
	wire [1:0] c2d_csrr_sel_D;
	wire c2d_alu_fn_X;
	wire [1:0] c2d_result_sel_X;
	wire c2d_dmemreq_val_M;
	wire c2d_dmemreq_type_M;
	wire c2d_wb_sel_M;
	wire c2d_rf_wen_W;
	wire [4:0] c2d_rf_waddr_W;
	wire c2d_csrw_out0_en_W;
	wire c2d_csrw_out1_en_W;
	wire c2d_csrw_out2_en_W;
	wire d2c_eq_X;
	wire [31:0] d2c_inst;
	ProcCtrl ctrl(
		.clk(clk),
		.rst(rst),
		.c2d_imemreq_val_F(c2d_imemreq_val_F),
		.c2d_reg_en_F(c2d_reg_en_F),
		.c2d_pc_sel_F(c2d_pc_sel_F),
		.c2d_reg_en_D(c2d_reg_en_D),
		.c2d_imm_type_D(c2d_imm_type_D),
		.c2d_op1_byp_sel_D(c2d_op1_byp_sel_D),
		.c2d_op2_byp_sel_D(c2d_op2_byp_sel_D),
		.c2d_op1_sel_D(c2d_op1_sel_D),
		.c2d_op2_sel_D(c2d_op2_sel_D),
		.c2d_csrr_sel_D(c2d_csrr_sel_D),
		.c2d_alu_fn_X(c2d_alu_fn_X),
		.c2d_result_sel_X(c2d_result_sel_X),
		.c2d_dmemreq_val_M(c2d_dmemreq_val_M),
		.c2d_dmemreq_type_M(c2d_dmemreq_type_M),
		.c2d_wb_sel_M(c2d_wb_sel_M),
		.c2d_rf_wen_W(c2d_rf_wen_W),
		.c2d_rf_waddr_W(c2d_rf_waddr_W),
		.c2d_csrw_out0_en_W(c2d_csrw_out0_en_W),
		.c2d_csrw_out1_en_W(c2d_csrw_out1_en_W),
		.c2d_csrw_out2_en_W(c2d_csrw_out2_en_W),
		.d2c_eq_X(d2c_eq_X),
		.d2c_inst(d2c_inst),
		.trace_stall(trace_stall)
	);
	ProcDpath dpath(
		.clk(clk),
		.rst(rst),
		.imemreq_val(imemreq_val),
		.imemreq_addr(imemreq_addr),
		.imemresp_data(imemresp_data),
		.dmemreq_val(dmemreq_val),
		.dmemreq_type(dmemreq_type),
		.dmemreq_addr(dmemreq_addr),
		.dmemreq_wdata(dmemreq_wdata),
		.dmemresp_rdata(dmemresp_rdata),
		.in0(in0),
		.in1(in1),
		.in2(in2),
		.out0(out0),
		.out1(out1),
		.out2(out2),
		.c2d_imemreq_val_F(c2d_imemreq_val_F),
		.c2d_reg_en_F(c2d_reg_en_F),
		.c2d_pc_sel_F(c2d_pc_sel_F),
		.c2d_reg_en_D(c2d_reg_en_D),
		.c2d_imm_type_D(c2d_imm_type_D),
		.c2d_op1_byp_sel_D(c2d_op1_byp_sel_D),
		.c2d_op2_byp_sel_D(c2d_op2_byp_sel_D),
		.c2d_op1_sel_D(c2d_op1_sel_D),
		.c2d_op2_sel_D(c2d_op2_sel_D),
		.c2d_csrr_sel_D(c2d_csrr_sel_D),
		.c2d_alu_fn_X(c2d_alu_fn_X),
		.c2d_result_sel_X(c2d_result_sel_X),
		.c2d_dmemreq_val_M(c2d_dmemreq_val_M),
		.c2d_dmemreq_type_M(c2d_dmemreq_type_M),
		.c2d_wb_sel_M(c2d_wb_sel_M),
		.c2d_rf_wen_W(c2d_rf_wen_W),
		.c2d_rf_waddr_W(c2d_rf_waddr_W),
		.c2d_csrw_out0_en_W(c2d_csrw_out0_en_W),
		.c2d_csrw_out1_en_W(c2d_csrw_out1_en_W),
		.c2d_csrw_out2_en_W(c2d_csrw_out2_en_W),
		.d2c_eq_X(d2c_eq_X),
		.d2c_inst(d2c_inst),
		.trace_addr(trace_addr),
		.trace_inst(trace_inst),
		.trace_data(trace_data)
	);
endmodule
