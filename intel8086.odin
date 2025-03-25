#+feature dynamic-literals
package main

import "core:os"
import "core:fmt"

opcodes := map[int]string {
	0b100010 = "mov",
}

full_width_registers := map[int]string {
	0b000 = "ax",
	0b001 = "cx",
	0b010 = "dx",
	0b011 = "bx",
	0b100 = "sp",
	0b101 = "bp",
	0b110 = "si",
	0b111 = "di",
}

half_width_registers := map[int]string {
	0b000 = "al",
	0b001 = "cl",
	0b010 = "dl",
	0b011 = "bl",
	0b100 = "ah",
	0b101 = "ch",
	0b110 = "dh",
	0b111 = "bh",
}

main::proc() {
	file_path := os.args[1]
	data, ok := os.read_entire_file_from_filename(file_path, context.allocator)
	if !ok {
		fmt.println("Could not read file")
		return
	}

	phase := 0
	opcode: string
	d: int
	w: int
	mod: int
	reg: int
	rm: int
	dest: string
	source: string

	for byte in data {
		switch phase {
		case 0:
			opcode = opcodes[0b111111 & int(byte >> 2)]
			d = 0b1 & int(byte >> 1)
			w = 0b1 & int(byte)
			phase += 1
		case 1:
			mod = 0b11 & int(byte >> 6)
			reg = 0b111 & int(byte >> 3)
			rm = 0b111 & int(byte)
			if d == 1 {
				dest = encoded_register_field(reg, w)
				source = encoded_register_field(rm, w)
			} else {
				source = encoded_register_field(reg, w)
				dest = encoded_register_field(rm, w)
			}
			fmt.printf("%s %s, %s\n", opcode, dest, source)
			phase = 0
		}
	}

}

encoded_register_field::proc(reg: int, w: int) -> string {
	if w == 0 {
		return half_width_registers[reg]
	} else {
		return full_width_registers[reg]
	}
}
