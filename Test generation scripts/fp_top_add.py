import bitstring, random
from decimal import Decimal, getcontext

getcontext().prec = 50
iteration = 1000000
span = 999999

def to_twos_complement_hex(value, bits=32):
    if value < 0:
        value = (1 << bits) + value
    return f"{value:08X}"

def extract_parts(precise_float):
    d = Decimal(str(abs(precise_float))).normalize()
    int_part = int(d)
    frac_part = d - int_part
    frac_str = str(frac_part).lstrip("0.") or "0"
    scale = 10 ** len(frac_str)
    frac_int = int(frac_str)

    if precise_float < 0:
        int_part = -int_part

    int_hex = to_twos_complement_hex(int_part)
    frac_hex = to_twos_complement_hex(frac_int)
    scale_hex = to_twos_complement_hex(scale)

    return int_hex, frac_hex, scale_hex

with open("TestVectorTopAdd", "w") as f:
    for i in range(iteration):
        nums = []
        components = []

        for j in range(2):
            num = random.uniform(-span, span)
            b = bitstring.BitArray(float=num, length=32)
            precise_float = b.float
            int_hex, frac_hex, scale_hex = extract_parts(precise_float)
            nums.append(precise_float)
            components.append((int_hex, frac_hex, scale_hex))

        result_sum = nums[0] + nums[1]
        sum_bits = bitstring.BitArray(float=result_sum, length=32)
        sum_hex = sum_bits.hex.upper()

        int1_hex, frac1_hex, scale1_hex = components[0]
        int2_hex, frac2_hex, scale2_hex = components[1]

        line = f"{sum_hex}_{int1_hex}_{frac1_hex}_{scale1_hex}_{int2_hex}_{frac2_hex}_{scale2_hex}"
        f.write(line + "\n")