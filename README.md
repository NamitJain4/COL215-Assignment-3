# AES Decryption Implementation in VHDL

## Project Overview

This project implements an **AES (Advanced Encryption Standard) Decryption Engine** in VHDL for FPGA deployment on the Basys3 development board. The implementation focuses on the inverse operations of AES encryption, including inverse substitution bytes, inverse shift rows, inverse mix columns, and XOR operations with round keys.

## Project Structure and File Descriptions

### Core Implementation Files

#### 1. `controller.vhd` - Main Control Unit
- **Purpose**: Top-level controller that orchestrates the entire AES decryption process
- **Key Features**:
  - State machine implementation with states: ReadInput, InvShiftRows, InvSubBytes, XOR_RoundKey, InvMixColumns, seg_display, WriteOutput, Completed
  - Manages the flow of data through different AES decryption stages
  - Interfaces with all sub-modules
  - Handles input/output operations and 7-segment display control
- **Dependencies**: All other VHDL modules

#### 2. `inv_sub_byte.vhd` - Inverse Substitution Bytes
- **Purpose**: Implements the inverse S-box transformation
- **Key Features**:
  - Uses Block RAM (BRAM) to store the inverse S-box lookup table
  - Takes 8-bit input and produces 8-bit output using inverse substitution
  - Utilizes `blk_mem_gen_2` component for memory access
- **Dependencies**: `inv_sbox.txt` (lookup table), BRAM IP core

#### 3. `InvRowShift.vhd` - Inverse Row Shifting
- **Purpose**: Implements the inverse shift rows transformation
- **Key Features**:
  - Shifts rows in the opposite direction of the standard AES shift rows
  - Uses 4:1 multiplexers to perform the shifting operation
  - Processes 32-bit input (one row at a time)
- **Dependencies**: `mux4x1.vhd`

#### 4. `inv_mix_cols.vhd` - Inverse Mix Columns
- **Purpose**: Implements the inverse mix columns transformation
- **Key Features**:
  - Performs Galois Field (GF(2^8)) multiplication
  - Applies the inverse mix columns matrix to each column
  - Uses custom `gmul` function for GF multiplication
- **Dependencies**: None (self-contained)

#### 5. `xor_operation.vhd` - XOR Operation
- **Purpose**: Simple XOR gate for round key addition
- **Key Features**:
  - Performs bitwise XOR between two 8-bit inputs
  - Used in the AddRoundKey step of AES decryption
- **Dependencies**: None

#### 6. `round_key_reader.vhd` - Round Key Management
- **Purpose**: Manages round key access and addressing
- **Key Features**:
  - Reads round keys from Block RAM
  - Implements address mapping for proper key scheduling
  - Uses `blk_mem_gen_0` component for key storage
- **Dependencies**: BRAM IP core

### Display and Interface Files

#### 7. `digital_display_3.vhd` - Seven-Segment Display Driver
- **Purpose**: Controls the 7-segment display on Basys3 board
- **Key Features**:
  - Displays 32-bit hexadecimal data across 4 digits
  - Includes time-multiplexing for multiple digit display
  - Maps hexadecimal values to 7-segment patterns
- **Dependencies**: None

#### 8. `mux4x1.vhd` - 4:1 Multiplexer
- **Purpose**: 4-to-1 multiplexer for 8-bit data paths
- **Key Features**:
  - Selects one of four 8-bit inputs based on 2-bit select signal
  - Used primarily in the inverse row shift operation
- **Dependencies**: None

### Testbench Files

#### 9. `controller_tb.vhd` - Main Controller Testbench
- **Purpose**: Tests the main controller functionality
- **Key Features**:
  - Provides clock generation
  - Monitors all output signals including 7-segment display outputs
- **Dependencies**: `controller.vhd`

#### 10. `the_tb.vhd` - Display Testbench
- **Purpose**: Tests the 7-segment display functionality
- **Key Features**:
  - Tests various hexadecimal input patterns
  - Verifies display multiplexing and segment patterns
- **Dependencies**: `digital_display_3.vhd`

### Configuration and Data Files

#### 11. `basys3 (2).xdc` - Constraints File
- **Purpose**: Pin assignments and timing constraints for Basys3 FPGA board
- **Key Features**:
  - Maps VHDL signals to physical FPGA pins
  - Defines clock constraints and I/O standards
- **Usage**: Required for synthesis and implementation

#### 12. `input_file.txt` - Input Data
- **Purpose**: Contains the ciphertext to be decrypted
- **Format**: Memory initialization file with decimal values
- **Content**: 16 bytes of encrypted data with expected output

#### 13. `inv_sbox.txt` - Inverse S-box Lookup Table
- **Purpose**: Contains the AES inverse substitution box values
- **Format**: Memory initialization file with hexadecimal values
- **Usage**: Loaded into BRAM for inverse S-box transformations

#### 14. `controller.bit` - Bitstream File
- **Purpose**: Compiled FPGA configuration file
- **Usage**: Can be directly programmed to Basys3 FPGA

## File Dependencies

```
controller.vhd (main)
├── digital_display_3.vhd
├── xor_operation.vhd
├── inv_mix_cols.vhd
├── InvRowShift.vhd
│   └── mux4x1.vhd
├── inv_sub_byte.vhd
│   └── inv_sbox.txt
└── round_key_reader.vhd

Testbenches:
├── controller_tb.vhd → controller.vhd
└── the_tb.vhd → digital_display_3.vhd

Configuration:
├── basys3 (2).xdc (pin constraints)
├── input_file.txt (test data)
└── controller.bit (compiled bitstream)
```

## How to Use

### 1. Simulation
1. **For Controller Testing**:
   - Open `controller_tb.vhd` in your VHDL simulator
   - Ensure all dependencies are included in the project
   - Run simulation to observe the AES decryption process

2. **For Display Testing**:
   - Use `the_tb.vhd` to test 7-segment display functionality
   - Verify hexadecimal pattern display on simulated outputs

### 2. FPGA Implementation
1. **Quick Deployment**:
   - Use `controller.bit` file to directly program the Basys3 board
   - Connect the board and use Vivado Hardware Manager

2. **Full Synthesis**:
   - Create new Vivado project targeting Basys3 (xc7a35tcpg236-1)
   - Add all `.vhd` files to the project
   - Add `basys3 (2).xdc` as constraints file
   - Add `input_file.txt` and `inv_sbox.txt` as memory initialization files
   - Generate Block RAM IP cores (blk_mem_gen_0, blk_mem_gen_1, blk_mem_gen_2)
   - Synthesize, implement, and generate bitstream

### 3. Operation
- The system automatically reads input data from Block RAM
- Performs AES decryption through multiple rounds
- Displays results on 7-segment display
- Expected output for provided input: `F5C392a1A1339b88`

## System Architecture

The AES decryption process follows these steps:
1. **Read Input**: Load 128-bit ciphertext from memory
2. **Initial Round Key Addition**: XOR with final round key
3. **Inverse Rounds** (9 iterations):
   - Inverse Shift Rows
   - Inverse Substitute Bytes  
   - XOR with Round Key
   - Inverse Mix Columns
4. **Final Round**:
   - Inverse Shift Rows
   - Inverse Substitute Bytes
   - XOR with initial round key
5. **Display Output**: Show decrypted plaintext on 7-segment display

## Clock and Timing
- **Clock Frequency**: 100 MHz (10ns period as defined in constraints)
- **Display Refresh**: Controlled by internal clock dividers
- **State Machine**: Synchronized to main clock with wait states for proper timing

## Memory Requirements
- **Round Keys**: Stored in Block RAM (blk_mem_gen_0)
- **Input/Output Data**: Stored in Block RAM (blk_mem_gen_1)  
- **Inverse S-box**: Stored in Block RAM (blk_mem_gen_2)

## Additional Notes
- The implementation uses a state machine approach for sequential processing
- All arithmetic operations are performed in appropriate Galois Fields for AES compliance
- The design is optimized for educational purposes and FPGA resource constraints
- Error handling and edge cases are managed through state machine design

For detailed implementation specifics and mathematical foundations, refer to the accompanying `report.pdf` and `assignment description.pdf` files.
