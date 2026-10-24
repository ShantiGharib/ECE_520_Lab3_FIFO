import random
import sys
import time
import pathlib
def main():
	WIDTH_TB_LINE = 79
	DEPTH_TB_LINE = 80
	ALMOST_EMPTY_THRESHOLD_TB_LINE = 81
	ALMOST_FULL_THRESHOLD_TB_LINE = 82
	READ_LATENCY_TB_LINE = 83

	bit_width              = 24  # values may be changed	
	almost_empty_threshold =  3  # values may be changed 
	depth                  = 16  # values may be changed
	almost_full_threshold  =  9  # values may be changed
	read_latency 		   =  4  # values may be changed 

	
	if (bit_width >= 32):
		print("Can't inject unsigned integers 32 bits or wider into simulation. Please use a lower width\n")
		exit()
	
	script_dir = pathlib.Path(__file__).resolve().parent
	testbench_path = script_dir.parent / "ECE_520_Lab3_FIFO.srcs" / "sim_1" / "new" / "fifo_tb_random.vhd"
	out_path = script_dir.parent / "sim" / "input_data.txt"
	out_path_writes_only = script_dir.parent / "sim" / "input_data_writes_only.txt"
	random.seed(int(time.time()))
	i = 0
	
	steps = random.randint(20, 1024)
	output_str = list(str())
	output_writes_only_str = list(str())
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

	write_operation_bias = random.randint(200, 950) #20-95%
	reset_operation_bias = random.randint( 10,  25) #1-2.5%
	fifo_elements = int(0)
	writes_only_curr_line = int(0)
	read_latency_checker = int(0)
	while (i < steps):
		read_latency_checker <<= 0x01
		operation_random_idx = random.randint(1, 1000)
		if (operation_random_idx <= write_operation_bias):
			random_num = random.randint(0, (2 ** bit_width) - 1)
			output_str.append("+" + str(random_num) + "\n")
			if fifo_elements != depth:
				output_writes_only_str.append(str(random_num) + "\n")
				fifo_elements = fifo_elements + 1
		elif (operation_random_idx <= write_operation_bias + reset_operation_bias):
			output_str.append("R\n")
			fifo_elements = 0
			read_latency_checker = 0
			if (writes_only_curr_line == 0):
				output_writes_only_str.clear()
			else:
				output_writes_only_str = output_writes_only_str[0 : writes_only_curr_line]
		else:
			output_str.append("-\n")
			if fifo_elements != 0:
				read_latency_checker |= 0x01
				fifo_elements = fifo_elements - 1
		i = i + 1
		if ((read_latency_checker & (1 << read_latency)) == (1 << read_latency)):
			writes_only_curr_line = writes_only_curr_line + 1

	if (len(output_str) != 0):
		output_str[-1] = output_str[-1][0:-1]
	
	if (len(output_writes_only_str) != 0):
		output_writes_only_str[-1] = output_writes_only_str[-1][0:-1]

	file = open(out_path,'w')
	file.writelines(output_str)
	file.close()

	file = open(out_path_writes_only,'w')
	file.writelines(output_writes_only_str)
	file.close()

	#editing testbench for bit_width and depth
	file = open(testbench_path, 'r')
	lines = file.readlines()
	file.close()
	file = open(testbench_path, 'w')
	#########################################
	lines[WIDTH_TB_LINE-1] = "    constant WIDTH_TB : integer := " + str(bit_width) + ";\n"
	lines[DEPTH_TB_LINE-1] = "    constant DEPTH_TB : integer := " + str(depth) + ";\n"
	lines[ALMOST_EMPTY_THRESHOLD_TB_LINE-1] = "    constant ALMOST_EMPTY_THRESHOLD_TB : integer := " + str(almost_empty_threshold) + ";\n"
	lines[ALMOST_FULL_THRESHOLD_TB_LINE-1]  = "    constant ALMOST_FULL_THRESHOLD_TB : integer := " + str(almost_full_threshold) + ";\n"
	lines[READ_LATENCY_TB_LINE-1] 			= "    constant READ_LATENCY_TB : integer := " + str(read_latency) + ";\n"
	#########################################
	file.writelines(lines)
	file.close()


main()