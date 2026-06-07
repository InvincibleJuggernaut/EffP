# IEEE-754 Floating Point Arithmetic Unit

## 1. Introduction

This project implements a complete IEEE-754 single-precision (32-bit) floating-point arithmetic unit in Verilog. It provides a hardware-based solution for decimal-to-floating-point conversion and four fundamental arithmetic operations: addition, subtraction, multiplication, and division.

The design targets FPGA implementation and includes support for converting decimal inputs (split into integer and fractional parts with a scaling factor) into IEEE-754 format. Each arithmetic operation is implemented as a dedicated hardware module for direct computation on floating-point numbers without requiring software emulation.

**Key Specifications:**
- Standard: IEEE-754 Single Precision (32-bit)
- Sign: 1 bit
- Exponent: 8 bits (bias of 127)
- Mantissa: 23 bits (implicit leading 1)
- Operations Supported: Addition, Subtraction, Multiplication, Division, and Decimal-to-FP Conversion
- Language: Verilog HDL
- Approach: Fully combinatorial hardware implementation

---

## 2. Working of Operations

### 2.1 Decimal to Floating Point Conversion (dec_to_fp.v)

**Purpose:** Convert decimal numbers (integer + fractional parts) into IEEE-754 format.

**Implementation Details:**
- **Input Format:** Q32.32 fixed-point representation (32-bit integer, 32-bit fractional part)
- **Scaling Factor:** User-provided divisor for fractional component normalization
- **Algorithm:**
  1. Separates integer and fractional components from input
  2. Handles two's complement representation for negative numbers
  3. Combines integer and fractional parts into a 64-bit intermediate value
  4. Searches for the position of the leading '1' bit (index_of_leading_one)
  5. Calculates exponent as: 127 (bias) + (leading_one_position - 32) for normalization
  6. Extracts 23-bit mantissa from bits adjacent to the leading '1'
  7. Packs result as: [Sign (1 bit) | Exponent (8 bits) | Mantissa (23 bits)]

**Key Features:**
- Handles both positive and negative numbers using two's complement
- Automatically normalizes the result to IEEE-754 standard form
- Special case handling for zero values

---

### 2.2 Floating Point Addition (fp_add_sub.v)

**Purpose:** Add or subtract two IEEE-754 numbers based on operation control signal.

**Implementation Details:**
- **Operation Control:** op = 0 for addition, op = 1 for subtraction
- **Algorithm (Step-by-step):**
  1. **Extract Components:** Separate sign, exponent, and mantissa (24 bits with implicit leading 1)
  2. **Exponent Alignment:** Calculate difference between exponents; right-shift smaller mantissa to align decimal points
  3. **Operation Selection (based on signs):**
     - Same sign: Add mantissas, preserve sign
     - Different signs: Subtract smaller from larger, adjust sign accordingly
  4. **Mantissa Computation:** Perform 24-bit addition or subtraction
  5. **Normalization:** Re-normalize if carry occurs or leading 1 is lost
     - If carry (bit 24 = 1): Right-shift once, increment exponent
     - If no carry: Left-shift until leading 1 is found, decrement exponent proportionally
  6. **Pack Result:** Combine normalized sign, exponent, and 23-bit mantissa

**Special Cases Handled:**
- Adding operands of opposite signs with equal magnitude (cancellation)
- Mantissa overflow during addition
- Mantissa underflow requiring left-shifting

**Complexity:** Highly branched logic with multiple processing paths for different sign combinations (18+ distinct processing stages).

---

### 2.3 Floating Point Multiplication (fp_mul.v)

**Purpose:** Multiply two IEEE-754 numbers.

**Implementation Details:**
- **Algorithm:**
  1. **Extract Components:** Obtain signs, exponents, and 24-bit mantissas
  2. **Early Termination:** Return zero if either input is zero
  3. **Mantissa Multiplication:** Use repeated shift-and-add algorithm on 24-bit operands to generate 48-bit product
     - For each bit of A_mantissa (LSB-first):
       - If bit is 1: Add B_mantissa to product, shift B_mantissa left
       - If bit is 0: Only shift B_mantissa left
     - Result: 48-bit product with potential leading 1 in upper bits
  4. **Normalization:** 
     - Left-shift product until MSB (bit 47) is 1
     - Count normalization shifts (binary_point)
  5. **Exponent Calculation:** result_exp = A_exp + B_exp - binary_point - 126
     - Subtracts 126 instead of 127 because the 48-bit product has one extra bit of weight
  6. **Sign Determination:** result_sign = A_sign XOR B_sign
  7. **Pack Result:** Combine sign, calculated exponent, and upper 23 bits of normalized product

**Key Optimization:** Uses iterative multiplication (Multiply and Accumulate) to handle 24-bit × 24-bit → 48-bit multiplication efficiently in hardware.

---

### 2.4 Floating Point Division (fp_div.v)

**Purpose:** Divide two IEEE-754 numbers (A ÷ B).

**Implementation Details:**
- **Algorithm:**
  1. **Extract Components:** Obtain signs, exponents, and 24-bit mantissas
  2. **Mantissa Alignment:** Right-shift both mantissas to ensure LSB = 1 for accurate division
  3. **Integer Division (24 bits):**
     - Initialize remainder with A_mantissa, divisor with B_mantissa << 24
     - For 24 iterations:
       - Test if remainder ≥ divisor
       - If yes: subtract divisor, set quotient bit to 1
       - Shift remainder left by 1 for next iteration
     - Result: 24-bit integer quotient
  4. **Fractional Division:**
     - Perform 25 additional iterations on shifted remainder for fractional bits
     - Uses subtraction-and-test method (non-restoring division)
     - Builds 24-bit fractional quotient
  5. **Combine Results:** Concatenate integer and fractional quotients into 48-bit result
  6. **Normalization:** Left-shift until MSB is 1; count leading zeros
  7. **Exponent Calculation:** Adjusts based on:
     - Difference between input exponents
     - Number of leading zeros in quotient
     - Formula adapts for three cases: A_exp < B_exp, intermediate, and A_exp >> B_exp
  8. **Pack Result:** Combine sign (XOR of input signs), calculated exponent, and 23-bit mantissa

**Complexity:** Most complex operation; uses non-restoring division for efficiency with 49 iterations for integer and fractional parts.

---

### 2.5 Top Module Integration (fp_top.v)

**Purpose:** Unified interface for all operations; instantiates all arithmetic modules.

**Architecture:**
- Instantiates two dec_to_fp converters for inputs A and B
- Instantiates all four arithmetic modules: fp_add_sub (configured for add), fp_add_sub (configured for subtract), fp_mul, fp_div
- Multiplexer selects output based on 4-bit control signal:
  - control[3:0] = 0: Addition
  - control[3:0] = 1: Subtraction
  - control[3:0] = 2: Multiplication
  - control[3:0] = 3: Division

---

## 3. Advantages and Disadvantages of Approaches Used

### Advantages

**Addition/Subtraction Module:**
- ✅ **Comprehensive sign handling:** Multiple conditional branches ensure correct results for all sign combinations without additional normalization overhead
- ✅ **Merged operation logic:** Single module handles both addition and subtraction via control signal, reducing area overhead
- ✅ **Correct alignment:** Exponent-based alignment prevents precision loss from premature truncation

**Multiplication Module:**
- ✅ **Efficient Shift-and-Add:** Avoids complex multiplication hardware; uses simple iterative architecture
- ✅ **High precision intermediate:** 48-bit product preserves full precision before normalization
- ✅ **Simple exponent correction:** Direct formula (exp_A + exp_B - shifts - 126) is straightforward

**Division Module:**
- ✅ **Non-restoring algorithm:** More efficient than restoring division; requires fewer cycles and simpler restoration logic
- ✅ **Fractional part extraction:** Separate iterations for integer and fractional quotients enable accurate multi-bit results
- ✅ **Handles wide exponent range:** Adaptive exponent calculation addresses three different magnitude scenarios

**Overall Design:**
- ✅ **Modular architecture:** Independent modules allow testing and optimization of each operation separately
- ✅ **Reusable components:** dec_to_fp converter can be invoked multiple times in larger systems
- ✅ **Combinatorial implementation:** No clocking required; single-cycle latency enables pipelining at higher levels

---

### Disadvantages

**Addition/Subtraction Module:**
- ❌ **Excessive branching:** 18+ distinct processing stages create massive multiplexer trees, increasing area and reducing timing
- ❌ **Code duplication:** Repeated sign/magnitude handling logic across multiple branches; could be factored into helper functions
- ❌ **Slow for large operand counts:** Many nested conditionals limit scalability to higher precision (64-bit or 128-bit operations)
- ❌ **Limited normalization:** Left-shift normalization loop uses a fixed 24-cycle bound, which may be excessive for some inputs

**Multiplication Module:**
- ❌ **Sequential shift-and-add:** Inherently iterative; 24 iterations required in combinatorial logic → long critical path
- ❌ **No partial product addition:** Single accumulator means all 24 terms added sequentially; parallel Dadda/Wallace tree would accelerate
- ❌ **Fixed 48-bit intermediate:** Wastes area for smaller intermediate results; opportunity for dynamic bit-width optimization
- ❌ **No overflow/underflow flags:** Module silently handles exponent wrap-around without indication

**Division Module:**
- ❌ **Most complex and slowest:** 49+ iterations (24 integer + 25 fractional) in combinatorial logic creates very long critical path
- ❌ **Three-case exponent logic:** Different branches for exponent calculation increase complexity and potential for errors
- ❌ **Fractional precision limits:** 24-bit fractional quotient may be insufficient for cascaded divisions or high-precision applications
- ❌ **Non-restoring may be less intuitive:** Harder to debug than simple restoring division; requires careful tracking of sign bits

**Decimal Conversion Module:**
- ❌ **Q32.32 assumption:** Fixed fractional format limits flexibility; non-standard input scaling
- ❌ **Loop-based leading-one detection:** Iterates 64 times per conversion; could use priority encoder for O(1) lookup
- ❌ **Scaling factor division:** Performs division on fractional part, which is slow and may introduce precision loss
- ❌ **No rounding modes:** Always truncates mantissa; IEEE-754 standard defines multiple rounding modes (nearest, towards-zero, etc.)

**System-Level:**
- ❌ **Fully combinatorial:** No pipelining within modules; long critical paths can bottleneck frequency scaling
- ❌ **Lacks exception handling:** No support for denormalized numbers, infinities, or NaN propagation
- ❌ **No control signals:** Overflow/underflow flags only present in add/sub module; absent in mul/div
- ❌ **Test results show precision loss:** 2.3%-2.7% failure rate in conversion and addition operations, indicating rounding or alignment errors

---

## Results

<h5>Without using decimal to floating point conversion</h5>

| Operation      | Total Testcases | Pass #  | Fail # | Fail %     |
|----------------|-----------------|--------|------|------------|
| Addition       | 100,000       | 99,972| 28   | 0.0280%    |
| Subtraction    | 1,000,000       | 999,757| 243  | 0.0243%    |
| Multiplication | 1,000,000       | 999,762| 238  | 0.0238%    |
| Division       | 1,000,000       | 999,753| 247  | 0.0247%    |


<h5>When using decimal to floating point conversion</h5>

| Operation                          | Total Testcases | Pass #    | Fail #  | Fail %   |
|-----------------------------------|------------------|---------|--------|----------|
| Decimal to floating point conversion | 1,000,000       | 989,806 | 27,239 | 2.7519%  |
| Addition                           | 1,000,000       | 976,137 | 23,863 | 2.3863%  |
