.data
out: .word 0x00
in: .word 0x00

.text
lui x6,0xf #lui
auipc x7, 0xf #auipc

la x10, jalrtest
jalr x10 #jalr
addi x5, x0, 0x1

jalrtest:
addi x10, x0, 0xf
addi x11, x0, 0xa

bne x10, x11, bnetest #bne
addi x5, x0, 0x1

bnetest:
addi x10, x0, 0xa
addi x11, x0, 0xf

blt x10, x11, blttest #blt
addi x5, x0, 0x1

blttest:
addi x10, x0, 0xf
addi x11, x0, 0xa

bge x10, x11, bgetest #bge
addi x5, x0, 0x1

bgetest:
addi x10, x0, 0xff
addi x11, x0, 0xffffffff

bltu x10, x11, bltutest #bltu
addi x5, x0, 0x1

bltutest:
addi x10, x0, 0xffffffff
addi x11, x0, 0xff

bgeu x10, x11, bgeutest #bgeu
addi x5, x0, 0x1

bgeutest:
slti x5, x10, 0	#slti
addi x5, x0, 0
sltiu x5, x10, 0 #sltiu
addi x11, x0, 0xf

xori x10, x11, 0xa #xori
ori x10, x11, 0xf0 #ori
andi x10, x11, 0xa #andi
slli x10, x11, 0x1 #slli
addi x12, x0, 0xffffffff
srli x10, x12, 0x1 #srli
srai x10, x12, 0x1 #srai
sub x10, x12, x11 #sub
slt x10, x12, x11 #slt
sltu x10, x12, x11 #sltu
addi x10, x0, 0xf
addi x11, x0, 0xa
xor x10, x10, x11 #xor
addi x11, x0, 1
srl x10, x12, x11 #srl
sra x10, x12, x11 #sra
or x10, x12, x11 #or
and x10, x12, x11 #and

la x10, out
li x11, 0xff
sw x11, (x10)
li x11, 0xffff
sw x11, 4(x10)
lb x6, (x10) #lb
lh x6, 4(x10) #lh
lbu x6, (x10) #lbu
lhu x6, 4(x10) #lhu
sb x6, 8(x10) #sb
sh x6, 8(x10) #sh

