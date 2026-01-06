# Implementation of IEEE 754 Floating-Point Arithmetic (Single Precision)

## 📘 Overview
This project focuses on the design and verification of IEEE 754–compliant single-precision floating-point arithmetic units using Verilog HDL. A complete Floating-Point Unit (FPU) was developed to support addition, subtraction, multiplication, division, and square root operations. The design emphasizes correctness at the hardware level, modular implementation, and efficient use of resources, with functionality verified through simulation.

---

## 🎯 Project Objectives
- Understand and implement IEEE 754 single-precision floating-point arithmetic from the ground up  
- Design hardware-accurate arithmetic units using Verilog HDL  
- Validate functionality using simulation and testbenches  
- Integrate all arithmetic units into a unified Floating-Point Unit (FPU)

---

## ⚙️ Supported Operations
- Floating-point addition  
- Floating-point subtraction  
- Floating-point multiplication  
- Floating-point division (Newton–Raphson method)  
- Floating-point square root (Newton–Raphson method)

The design follows the IEEE 754 single-precision standard and includes handling of special cases such as zero, infinity, NaN, overflow, and underflow.

---

## 🧠 Design Methodology
The project was carried out in a structured and incremental manner:

- **Conceptual Understanding**  
  Studied IEEE 754 number representation, normalization, rounding, and exception handling.

- **Algorithm Modeling**  
  Developed and tested arithmetic algorithms using C and Python before hardware implementation.

- **RTL Design**  
  Implemented individual arithmetic units in Verilog HDL with modular and reusable design practices.

- **System Integration**  
  Integrated all arithmetic units into a top-level FPU with centralized control logic.

---

## 🏗️ Architecture Highlights
- **Adder/Subtractor**: 24-bit Kogge–Stone adder used for fast mantissa operations  
- **Multiplier**: Mantissa multiplication with exponent bias correction and normalization  
- **Divider**: Newton–Raphson–based reciprocal approximation  
- **Square Root**: Newton–Raphson iteration with exponent adjustment  
- **Top Module**: Modular FPU architecture enabling clean integration of functional units

---

## 🛠️ Tools & Technologies
- **HDL**: Verilog  
- **Simulation & Synthesis**: Xilinx Vivado, ModelSim  
- **Algorithm Prototyping**: C, Python  
- **Platform**: FPGA (simulation- and synthesis-oriented)

---

## 🚀 How to Use
1. Open the project in **Vivado / ModelSim**
2. Compile the Verilog source files
3. Run the provided testbenches for each arithmetic unit
4. Verify waveform outputs against IEEE 754 expected results

> Note: This is a design and simulation-focused academic project.

---

## 📊 Results & Verification
- Verified correctness across a wide range of test cases  
- Accurate handling of IEEE 754 special cases  
- Stable convergence for division and square root using Newton–Raphson iterations  
- Simulation waveforms confirm functional integrity of all arithmetic units

---

## 🔮 Future Improvements
- Full pipelining of all arithmetic units  
- Support for double-precision floating-point format  
- Power and area optimization  
- FPGA hardware validation with real-time inputs

---

## 👤 Authors
**Anirudh Hariharan**  
B.Tech, Electrical and Electronics Engineering  
National Institute of Technology Karnataka, Surathkal  

**Suchet Nayak**  
B.Tech, Electrical and Electronics Engineering  
National Institute of Technology Karnataka, Surathkal  

---

## 🎓 Academic Note
This project was developed as part of the **EE502 Cornerstone / Capstone Project** at NITK Surathkal and is intended for academic and educational purposes.

---

## 📜 License
This repository is shared for academic reference and learning purposes only.

