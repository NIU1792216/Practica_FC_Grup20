#!/bin/bash

yasm -f elf64 -g dwarf2 -o codi_objecte.o Basic_Enunciat.asm 2> aux_yasm
gcc -no-pie -mincoming-stack-boundary=3 -g -o executable codi_objecte.o 2048_Basic.c 2> aux_gcc

lin_yasm=`wc -l < aux_yasm`
lin_gcc=`wc -l < aux_gcc`
if [[ $lin_yasm -ge 2 || $lin_gcc -ge 2 ]]
then
	echo "Error:"
	echo "==========Yasm=============="
	cat aux_yasm
	echo "============================"
	echo "==========gcc==============="
	cat aux_gcc
	echo "============================"
else
	./executable
fi
