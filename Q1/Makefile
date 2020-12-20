compile:
	nasm -f bin Q1_2019126.asm -o Q1_2019126.bin

run: compile
	qemu-system-x86_64 -fda Q1_2019126.bin
