#!/bin/bash

yasm -f elf64 -g dwarf2 -o codi_objecte.o Basic_Enunciat.asm
gcc -no-pie -mincoming-stack-boundary=3 -g -o executable codi_objecte.o 2048_Basic.c
./executable
