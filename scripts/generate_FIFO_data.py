import random
import sys
import time
import pathlib
def main():
	script_dir = pathlib.Path(__file__).resolve().parent
	out_path = script_dir.parent / "sim" / "input_data.txt"
	random.seed(int(time.time()))
	i = 0
	steps = random.randint(20, 1024)
	bit_width = random.randint(1, 64)
	depth = 2**random.randint(0, 9)
	ALMOST_EMPTY_THRESHOLD = random.randint(1, (int)(depth / 2))
	ALMOST_FULL_THRESHOLD  = random.randint(int(depth / 2), depth - 1)
	READ_LATENCY = random.randint(1, 8)
	output_str = "steps = " + str(steps)  + ", bit_width = " + str(bit_width) + ", depth = " + str(depth) + ", ALMOST_EMPTY_THRESHOLD = "
	output_str += str(ALMOST_EMPTY_THRESHOLD) + ", ALMOST_FULL_THRESHOLD = " + str(ALMOST_FULL_THRESHOLD) + ", READ_LATENCY = " + str(READ_LATENCY) + "\n"
	write_operation_bias = random.randint(20, 95)
	while (i < steps):
		operation_random_idx = random.randint(1, 100)
		if (operation_random_idx <= write_operation_bias):
			random_num = random.randint(0, (2 ** bit_width) - 1)
			output_str += str(random_num) + "\n"
		else:
			output_str += "-\n"
		i = i + 1

	file = open(out_path,'w')
	file.write(output_str)
	file.close()


main()