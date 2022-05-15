.data 
out: .word 0x0
in: .word 0x0

.text 
# fwd test
la a0, out
addi x5, x0, 0xf0	#addi
lw x5, 4(a0)	#lw

li x6, 0xf
li x7, 0xf0
add x8, x6, x7	#add
sub x9, x6, x7  #sub

#hazard test
li x6, 0xf
li x7, 0xf0
lw x5, 4(a0)
add x5, x8, x5
sub x5, x9, x5

#branch test
li x7, 0x1
li x8, 0x1

sub x7, x7, x8  #sub
beqz x7, HERE

add x6, x7, x8
sub x6, x7, x8

HERE:
li x6, 0xff
jal x6, HERE
