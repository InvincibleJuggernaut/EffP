import bitstring, random
from decimal import Decimal, getcontext

getcontext().prec = 30
iteration = 1000000
span = 999999

def to_twos_complement_hex(value, bit_width=32):
    if value < 0:
        value = (1 << bit_width) + value
    return hex(value)[2:].upper().zfill(bit_width // 4)

with open("TestVectorFPNumbers", "w") as f:
    for i in range(iteration):

        original_num = random.uniform(-span, span)
        b = bitstring.BitArray(float=original_num, length=32)
        
        bin_str = b.bin
        hex_str = b.hex.upper()
        
        precise_32bit_float = b.float
        
        d = Decimal(str(abs(precise_32bit_float))).normalize()
        int_part = int(d)
        frac_part = d - int_part
        frac_str = str(frac_part).lstrip("0.") or "0"
        scale = 10 ** len(frac_str)
        frac_int = int(frac_str)
        
        if precise_32bit_float < 0:
            int_part = -int_part
        
        int_hex = to_twos_complement_hex(int_part)
        frac_hex = to_twos_complement_hex(frac_int)
        scale_hex = to_twos_complement_hex(scale)
        f.write(f"{hex_str}_{int_hex}_{frac_hex}_{scale_hex}\n")