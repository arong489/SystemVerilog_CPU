.text
addi $s7,$s7,1
sw $0,0x7f00($0)
#———————中断测试
lui $t0,0x114
ori $t0,0x5140
ori $t1,$0,0x133
sw $0,0x7f00($0)
ori $1,$0,0x0401
mtc0 $1,$12
ori $1,$0,0x1
sw $1,0x7f00($0)
ori $1,$0,2
sw $1,0x7f04($0)
ori $1,$0,0x9
sw $1,0x7f00($0)
sw $t0,0($0)
lw $t3,0($0)
beq $t3,$t3,-0x1
lui $s0,0x3

#————————阻塞时中断
lui $t0,0x114
ori $t0,0x5140
ori $t1,$0,0x133
sw $0,0x7f00($0)
ori $1,$0,0x0401
mtc0 $1,$12
ori $1,$0,0x1
sw $1,0x7f00($0)
ori $1,$0,1
sw $1,0x7f04($0)
ori $1,$0,0x9
sw $1,0x7f00($0)
nop
sw $t0,0($0)
lw $t3,0($0)
beq $t3,$t3,0x4
lui $s0,0x114
ori $s0,$s0,0x5140
lui $s1,0x114
ori $s1,$s1,0x5140
lui $s2,0x114
ori $s2,$s2,0x5140

#—————————延迟槽中断，eret转发未实现考虑
ori $s6,$s7,0
sw $0,0x7f00($0)
ori $1,$0,0x0401
mtc0 $1,$12
ori $1,$0,0x1
sw $1,0x7f00($0)
ori $1,$0,3
sw $1,0x7f04($0)
ori $1,$0,0x9
sw $1,0x7f00($0)
mfc0 $1,$12
mtc0 $1,$12
beq $0,$0,0x4
mfc0 $1,$12
lui $s0,0x114
ori $s0,$s0,0x5140
lui $s1,0x114
ori $s1,$s1,0x5140
lui $s2,0x114
ori $s2,$s2,0x5140

#——————————延迟槽中断2
ori $s6,$s7,0
sw $0,0x7f00($0)
ori $1,$0,0x0401
mtc0 $1,$12
ori $1,$0,0x1
sw $1,0x7f00($0)
ori $1,$0,4
sw $1,0x7f04($0)
ori $1,$0,0x9
sw $1,0x7f00($0)
addi $t4,$s7,1
mfc0 $1,$12
mtc0 $1,$12
beq $t4,$s7,-0x4
mfc0 $1,$12
nop
nop
nop
ori $s0,$s0,0x5140
lui $s1,0x114
#————————异常时中断
sw $0,0x7f00($0)
ori $1,$0,0x0401
mtc0 $1,$12
ori $1,$0,0x1
sw $1,0x7f00($0)
ori $1,$0,3
sw $1,0x7f04($0)
ori $1,$0,0x9
sw $1,0x7f00($0)
lui $t0,0x7fff
ori $t0,$t0,0xffff
ori $1,$0,1
add $t0,$t0,$1
beq $t0,$0,-1
slt $t0,$0,$t0
nop
ori $1,$0,0x777

#————————异常时不受理中断
sw $0,0x7f00($0)
ori $1,$0,0x0401
mtc0 $1,$12
ori $1,$0,0x1
sw $1,0x7f00($0)
ori $1,$0,5
sw $1,0x7f04($0)
ori $1,$0,0x9
sw $1,0x7f00($0)
lui $t0,0x7fff
ori $t0,$t0,0xffff
ori $1,$0,1
add $t0,$t0,$1
lui $t4,0x333
#————————末尾指令中断
sw $0,0x7f00($0)
ori $1,$0,0x0401
mtc0 $1,$12
ori $1,$0,0x1
sw $1,0x7f00($0)
ori $1,$0,3
sw $1,0x7f04($0)
ori $1,$0,0x9
sw $1,0x7f00($0)
nop
sw $1,0x1140($0)
lw $1,0($0)
addi $t5,$1,-0x123



.ktext 0x4180
mfc0 $1,$13
sw $0,0x7f00($0)
andi $1,$1,0x7c
bne $1,$0,0x7
mfc0 $1,$14
beq $s6,$s7,0x2
nop
addi $1,$1,0x4
addi $s7,$s7,1
mtc0 $1,$14
eret
ori $1,$1,0x0404
sub $t0,$0,$1
eret
