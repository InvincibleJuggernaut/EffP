import bitstring, random 

#span = 9999999999999999999999999999999
span = 99999999999999999999999
iteration = 1000000

def ieee754(flt):
    b = bitstring.BitArray(float=flt, length=32)
    return b

with open("TestVectorDivision", "w") as f:

    for i in range(iteration):
        a = ieee754(random.uniform(-span, span))
        b = ieee754(random.uniform(-span, span))
        ab = ieee754(a.float / b.float)

        f.write(a.hex +"_" +  b.hex  +  "_" + ab.hex + "\n")


