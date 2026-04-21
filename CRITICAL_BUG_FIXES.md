# CRITICAL BUG FIXES Documentation

This document outlines the critical bugs found in the Verilog design of the IEEE 754 Single Precision 32-bit ALU along with their respective fixes.

## Issue #1: Missing clk Ports in sqrt_top.v (Lines 61-87)
**Problem:** The `sqrt_top.v` file was missing the clock ports necessary for synchronous operations.

**Root Cause:** During synthesis, the clock signals were not propagated to the required modules, causing timing issues. 

**Impact:** This leads to no behavior during simulation when the clock signal is triggered. 

**Fix:** Add appropriate clock ports in the module declaration.
```verilog
module sqrt_top (
    input clk,
    ...
);
```  

## Issue #2: 16-bit vs 32-bit Exception Output Mismatch in sqrt_exception.v
**Problem:** The `sqrt_exception.v` file was designed to handle 16-bit outputs while the expected output was 32-bit.

**Root Cause:** Miscommunication between the design specification and implementation. 

**Impact:** This results in incorrect exception reporting and can produce erroneous outputs in the ALU. 

**Fix:** Change the output declaration to 32-bit.
```verilog
output [31:0] exception_output,
```  

## Issue #3: Undefined Wires SEL and sign_out in ADD_SUB.v (Line 47)
**Problem:** In `ADD_SUB.v`, wires `SEL` and `sign_out` were declared but not defined.

**Root Cause:** The absence of assignments to these wires led to undefined behaviors in simulations. 

**Impact:** It can lead to unpredictable results or latch-ups during the operation of the ALU. 

**Fix:** Assign the wires appropriately in the logic.
```verilog
assign SEL = ...;
assign sign_out = ...;
```  

## Issue #4: Missing sign_out Output Declaration in Comparison Module
**Problem:** The output `sign_out` was not declared in the comparison module.

**Root Cause:** Omitting important declarations leads to unexpected behavior in comparisons. 

**Impact:** Functional comparison operations which rely on this output will fail. 

**Fix:** Declare the output in the module.
```verilog
output sign_out,
```  

## Issue #5: Uninitialized Array in Top.v
**Problem:** The array in `Top.v` was found to be uninitialized, leading to potential data corruption. 

**Root Cause:** Arrays must be initialized properly to avoid undefined states.

**Impact:** This can affect the whole design’s behavior and reliability during simulation and real-world application. 

**Fix:** Initialize the array at the time of declaration.
```verilog
reg [N:0] my_array = '{default:0};
```  

## Issue #6: Undriven Exception Outputs in Fdivision.v
**Problem:** Exception outputs in `Fdivision.v` were found to be undriven under certain conditions.

**Root Cause:** Paths to drive the exception outputs were not fully implemented. 

**Impact:** It can cause overflow/underflow situations to go unnoticed. 

**Fix:** Ensure all exception conditions drive the outputs.
```verilog
if (condition) begin
    exception_output = ...;
end
```  

This documentation serves as a guide to critical bugs and ensures engineers can implement necessary fixes accordingly.