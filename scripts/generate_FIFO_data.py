import random
import sys
import time
import pathlib
def main(bit_width : int):
	script_dir = pathlib.Path(__file__).resolve().parent
	out_path = script_dir.parent / "sim" / "input_data.txt"
	out_path_writes_only = script_dir.parent / "sim" / "input_data_writes_only.txt"
	random.seed(int(time.time()))
	i = 0
	
	steps = random.randint(20, 1024)
	output_str = str()
	output_writes_only_str = str()
	#output_str = "steps = " + str(steps) + "\n"

	# bit_width = random.randint(1, 64)
	# output_str += "bit_width = " + str(bit_width) + "\n"
    
	# depth = 2**random.randint(0, 9)
	# output_str += "depth = " + str(depth) + "\n"
	
	# ALMOST_EMPTY_THRESHOLD = random.randint(1, (int)(depth / 2))
	# output_str += "ALMOST_EMPTY_THRESHOLD = " + str(ALMOST_EMPTY_THRESHOLD) + "\n" 
	
	# ALMOST_FULL_THRESHOLD  = random.randint(int(depth / 2), depth - 1)
	# output_str += "ALMOST_FULL_THRESHOLD = " + str(ALMOST_FULL_THRESHOLD) + "\n"
	
	# READ_LATENCY = random.randint(1, 8)
	# output_str += "READ_LATENCY = " + str(READ_LATENCY) + "\n"

	write_operation_bias = random.randint(20, 95)
	while (i < steps):
		operation_random_idx = random.randint(1, 100)
		if (operation_random_idx <= write_operation_bias):
			random_num = random.randint(0, (2 ** bit_width) - 1)
			output_str += "+" + str(random_num) + "\n"
			output_writes_only_str += str(random_num) + "\n"
		else:
			output_str += "-\n"
		i = i + 1

	if (len(output_str) != 0):
		output_str = output_str[0:-2]
	
	if (len(output_writes_only_str) != 0):
		output_writes_only_str = output_writes_only_str[0:-2]

	file = open(out_path,'w')
	file.write(output_str)
	file.close()

	file = open(out_path_writes_only,'w')
	file.write(output_writes_only_str)
	file.close()


main(int(input("Bit_Width = ")))