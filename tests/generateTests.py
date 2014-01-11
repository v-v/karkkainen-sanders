# generate tests sets for SA

from sys import *
import numpy as np

if len(argv) != 3:
	print "Usage: ", argv[0], "<output file name> <lenght>"
	exit()

out = np.random.randint(ord('A'), ord('Z'), int(argv[2]))

fd = open(argv[1], "wb")

for i in range(int(argv[2])):
	fd.write(str(unichr(out[i])))
