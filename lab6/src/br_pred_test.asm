.text
addi x10, x0, 10
addi x11, x0, 1
branch:
sub x10, x10, x11
bge x10, x0, branch