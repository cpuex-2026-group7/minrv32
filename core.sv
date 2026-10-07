package core_pkg;

typedef enum logic [1:0] {
  IMM_TYPE_A, // {15'Sign, ofs[14:0], 2'b00}
  IMM_TYPE_B, // {17'sign, ofs[14:0]}
  IMM_TYPE_C, // {imm[19:0], 12'b0}
  IMM_TYPE_D  // {10'b0, ofs[19:0], 2'b00}
} imm_type_t;

typedef enum logic {
  EXT_SRC_IMM,
  EXT_SRC_HARD
} ext_src_t;

endpackage

interface instr_mem_if;

  logic [31:0] addr;
  logic [31:0] read_data;

  modport cpu(output addr, input read_data);
  modport mem(input addr, output read_data);

endinterface

interface data_mem_if;

  logic [31:0] addr;
  logic [31:0] write_data, read_data;
  logic we;

  modport cpu(input read_data, output addr, write_data, we);
  modport mem(input addr, write_data, we, output read_data);

endinterface

module core(
input clk
);

endmodule

/* list of hardcoded floating point values

0xBE4CCCCD
0xBDCCCCCD
0x38D1B717
0x3C23D70A
0x3C8EFA35
0x3D4CCCCD
0x3DCCCCCD
0x3E19999A
0x3E4CCCCD
0x3E99999A
0x3F666666
0x40490FDB
0x4CBEBC20
0x4E6E6B28

*/


module ext(
  input logic [19:0] instr,
  input core_pkg::imm_type_t imm_type,
  input core_pkg::ext_src_t ext_src,
  output logic [31:0] result
);

// IEEE 754 single-precision bit patterns (decimal values below are approximate).
localparam [31:0] hard_const [0:13] = '{
32'hBE4CCCCD, // -0.2
32'hBDCCCCCD, // -0.1
32'h38D1B717, // 0.0001
32'h3C23D70A, // 0.01
32'h3C8EFA35, // 0.0174532924 (pi / 180, degrees to radians)
32'h3D4CCCCD, // 0.05
32'h3DCCCCCD, // 0.1
32'h3E19999A, // 0.15
32'h3E4CCCCD, // 0.2
32'h3E99999A, // 0.3
32'h3F666666, // 0.9
32'h40490FDB, // 3.14159274 (pi)
32'h4CBEBC20, // 100000000 (1e8)
32'h4E6E6B28  // 1000000000 (1e9)
};

logic [31:0] imm_result;
logic [31:0] hard_result;

always_comb begin
  unique case(imm_type)
  core_pkg::IMM_TYPE_A: imm_result = {{15{instr[14]}}, instr[14:0], 2'b00};
  core_pkg::IMM_TYPE_B: imm_result = {{17{instr[14]}}, instr[14:0]};
  core_pkg::IMM_TYPE_C: imm_result = {instr[19:0], 12'b0};
  core_pkg::IMM_TYPE_D: imm_result = {10'b0, instr[19:0], 2'b00};
  endcase

  hard_result = hard_const[instr[3:0]];

  unique case(ext_src)
  core_pkg::EXT_SRC_IMM: result = imm_result;
  core_pkg::EXT_SRC_HARD: result = hard_result;
  endcase
end

endmodule
