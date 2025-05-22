	.eqv	SYS_EXIT0, 10
	.eqv	PRINT_STRING, 4
	.eqv	READ_STRING, 8
	.eqv	SLEEP, 32
	
	.data
msg:	.string	"Enter time in format 'mm:ss' : "
err:	.string "Data format is not correct!"
buf:	.space	7
heap:	.word	0x10040000

	.text
start:	la	a0, msg
	li	a7, PRINT_STRING
	ecall
	
	la	a0, buf
	li	a1, 7
	li	a7, READ_STRING
	ecall
	
# t0 & t1 - minutes
# t2 & t3 - seconds
# t4 - source pointer (buf) & counter
# t5 - heap pointer
# t6 - brush pointer
# s1 - 10
# s2 - 6
# s3 - pink paint
# s4 - black paint
# s5 - clean loop limit
# s6 - current digit

	addi	sp, sp, -28
	sw	ra, 0(sp)
	sw	s1, 4(sp)
	sw	s2, 8(sp)
	sw	s3, 12(sp)
	sw	s4, 16(sp)
	sw	s5, 20(sp)
	sw	s6, 24(sp)
	
	li	s1, 10
	li	s2, 6
	li	s3, 0x00cc99cc
	li	s4, 0x00000000
	li	s5, 9
	
	la	t4, buf
	lw	t5, heap
	addi	t5, t5, 528
	mv	t6, t5
	
	lbu	t0, (t4)
	addi	t4, t4, 1
	lbu	t1, (t4)
	addi	t4, t4, 2
	lbu	t2, (t4)
	addi	t4, t4, 1
	lbu	t3, (t4)
	
# check input
	li	t4, 48
	blt	t0, t4, halt
	blt	t1, t4, halt
	blt	t2, t4, halt
	blt	t3, t4, halt
	li	t4, 57
	bgt	t0, t4, halt
	bgt	t1, t4, halt
	bgt	t2, t4, halt
	bgt	t3, t4, halt
	
# convert from ASCII
	addi	t0, t0, -48
	addi	t1, t1, -48
	addi	t2, t2, -48
	addi	t3, t3, -48
	
	
# starting time
stime:	mv	t6, t5
	mv	s6, t0
	jal	ra, case
	addi	t6, t5, 24
	mv	s6, t1
	jal	ra, case
	addi	t6, t5, 48
	jal	ra, colon
	addi	t6, t5, 56
	mv	s6, t2
	jal	ra, case
	addi	t6, t5, 80
	mv	s6, t3
	jal	ra, case
	
	
# main program loop 
loop:	li	a0, 1000
	li	a7, SLEEP
	ecall
	
	
# counters - done
inc_t3:	addi	t3, t3, 1
	addi	t6, t5, 80	# wyświetlenie t3
	jal	ra, clean
	addi	t6, t5, 80
	mv	s6, t3
	jal	ra, case
	bne	t3, s1, loop
	
inc_t2:	mv	t3, zero
	addi	t2, t2, 1
	
	addi	t6, t5, 80	# wyświetlenie t3
	jal	ra, clean
	addi	t6, t5, 80	
	mv	s6, t3
	jal	ra, case
	
	addi	t6, t5, 56	# wyświetlenie t2
	jal	ra, clean
	addi	t6, t5, 56
	mv	s6, t2
	jal	ra, case
	
	bne	t2, s2, loop
	
inc_t1:	mv	t2, zero
	addi	t1, t1, 1
	
	addi	t6, t5, 56	# wyświetlenie t2
	jal	ra, clean
	addi	t6, t5, 56
	mv	s6, t2
	jal	ra, case
	
	addi	t6, t5, 24	# wyświetlenie t1
	jal	ra, clean
	addi	t6, t5, 24
	mv	s6, t1
	jal	ra, case
	
	bne	t1, s1, loop
	
inc_t0:	mv	t1, zero
	addi	t0, t0, 1
	
	addi	t6, t5, 24	# wyświetlenie t1
	jal	ra, clean
	addi	t6, t5, 24
	mv	s6, t1
	jal	ra, case
	
	mv	t6, t5		# wyświetlenie t0
	jal	ra, clean
	mv	t6, t5
	mv	s6, t0
	jal	ra, case
	b	loop
	
	
# switch - case
case:	mv	t4, zero
	beq	s6, t4, zero_
	addi	t4, t4, 1
	beq	s6, t4, one
	addi	t4, t4, 1
	beq	s6, t4, two
	addi	t4, t4, 1
	beq	s6, t4, three
	addi	t4, t4, 1
	beq	s6, t4, four
	addi	t4, t4, 1
	beq	s6, t4, five
	addi	t4, t4, 1
	beq	s6, t4, six
	addi	t4, t4, 1
	beq	s6, t4, seven
	addi	t4, t4, 1
	beq	s6, t4, eight
	addi	t4, t4, 1
	beq	s6, t4, nine
	ret
	
	
# cleanup - done
clean:	mv	t4, zero
	
cloop:	sw	s4, (t6)
	addi	t6, t6, 4
	sw	s4, (t6)
	addi	t6, t6, 4
	sw	s4, (t6)
	addi	t6, t6, 4
	sw	s4, (t6)
	addi	t6, t6, 4
	sw	s4, (t6)
	addi	t4, t4, 1
	addi	t6, t6, 112
	blt	t4, s5, cloop
	ret
	
	
# segments - done
horyz:	sw	s3, (t6)
	addi	t6, t6, 4
	sw	s3, (t6)
	addi	t6, t6, 4
	sw	s3, (t6)
	ret
	
vert:	sw	s3, (t6)
	addi	t6, t6, 128
	sw	s3, (t6)
	addi	t6, t6, 128
	sw	s3, (t6)
	ret

		
# digits & colon - done
colon:	addi	t6, t6, 384
	sw	s3, (t6)
	addi	t6, t6, 256
	sw	s3, (t6)
	ret

zero_:	addi	sp, sp, -4
	sw	ra, 0(sp)
	addi	t6, t6, 4
	jal	ra, horyz
	addi	t6, t6, 116
	jal	ra, vert
	addi	t6, t6, -240
	jal	ra, vert
	addi	t6, t6, 240
	jal	ra, vert
	addi	t6, t6, -240
	jal	ra, vert
	addi	t6, t6, 116
	jal	ra, horyz
	lw	ra, 0(sp)
	addi	sp, sp, 4
	ret

one:	addi	sp, sp, -4
	sw	ra, 0(sp)
	addi	t6, t6, 144
	jal	ra, vert
	addi	t6, t6, 256
	jal	ra, vert
	lw	ra, 0(sp)
	addi	sp, sp, 4
	ret
	
two:	addi	sp, sp, -4
	sw	ra, 0(sp)
	addi	t6, t6, 4
	jal	ra, horyz
	addi	t6, t6, 132
	jal	ra, vert
	addi	t6, t6, 116
	jal	ra, horyz
	addi	t6, t6, 116
	jal	ra, vert
	addi	t6, t6, 132
	jal	ra, horyz
	lw	ra, 0(sp)
	addi	sp, sp, 4
	ret
	
three:	addi	sp, sp, -4
	sw	ra, 0(sp)
	addi	t6, t6, 4
	jal	ra, horyz
	addi	t6, t6, 132
	jal	ra, vert
	addi	t6, t6, 116
	jal	ra, horyz
	addi	t6, t6, 132
	jal	ra, vert
	addi	t6, t6, 116
	jal	ra, horyz
	lw	ra, 0(sp)
	addi	sp, sp, 4
	ret

four:	addi	sp, sp, -4
	sw	ra, 0(sp)
	addi	t6, t6, 128
	jal	ra, vert
	addi	t6, t6, -240
	jal	ra, vert
	addi	t6, t6, 116
	jal	ra, horyz
	addi	t6, t6, 132
	jal	ra, vert
	lw	ra, 0(sp)
	addi	sp, sp, 4
	ret

five:	addi	sp, sp, -4
	sw	ra, 0(sp)
	addi	t6, t6, 4
	jal	ra, horyz
	addi	t6, t6, 116
	jal	ra, vert
	addi	t6, t6, 132
	jal	ra, horyz
	addi	t6, t6, 132
	jal	ra, vert
	addi	t6, t6, 116
	jal	ra, horyz
	lw	ra, 0(sp)
	addi	sp, sp, 4
	ret
	
six:	addi	sp, sp, -4
	sw	ra, 0(sp)
	addi	t6, t6, 4
	jal	ra, horyz
	addi	t6, t6, 116
	jal	ra, vert
	addi	t6, t6, 132
	jal	ra, horyz
	addi	t6, t6, 116
	jal	ra, vert
	addi	t6, t6, -240
	jal	ra, vert
	addi	t6, t6, 116
	jal	ra, horyz
	lw	ra, 0(sp)
	addi	sp, sp, 4
	ret
	
seven:	addi	sp, sp, -4
	sw	ra, 0(sp)
	addi	t6, t6, 4
	jal	ra, horyz
	addi	t6, t6, 132
	jal	ra, vert
	addi	t6, t6, 256
	jal	ra, vert
	lw	ra, 0(sp)
	addi	sp, sp, 4
	ret
	
eight:	addi	sp, sp, -4
	sw	ra, 0(sp)
	addi	t6, t6, 4
	jal	ra, horyz
	addi	t6, t6, 116
	jal	ra, vert
	addi	t6, t6, -240
	jal	ra, vert
	addi	t6, t6, 116
	jal	ra, horyz
	addi	t6, t6, 116
	jal	ra, vert
	addi	t6, t6, -240
	jal	ra, vert
	addi	t6, t6, 116
	jal	ra, horyz
	lw	ra, 0(sp)
	addi	sp, sp, 4
	ret
	
nine:	addi	sp, sp, -4
	sw	ra, 0(sp)
	addi	t6, t6, 4
	jal	ra, horyz
	addi	t6, t6, 116
	jal	ra, vert
	addi	t6, t6, -240
	jal	ra, vert
	addi	t6, t6, 116
	jal	ra, horyz
	addi	t6, t6, 132
	jal	ra, vert
	addi	t6, t6, 116
	jal	ra, horyz
	lw	ra, 0(sp)
	addi	sp, sp, 4
	ret
	
	
# incorrect input handling
halt:	la	a0, err
	li	a7, PRINT_STRING
	ecall
	
	
# finish
fin:	lw	s6, 24(sp)
	lw	s5, 20(sp)
	lw	s4, 16(sp)
	lw	s3, 12(sp)
	lw	s2, 8(sp)
	lw	s1, 4(sp)
	lw	ra, 0(sp)
	addi	sp, sp, 28
	
	li	a7, SYS_EXIT0
	ecall
	
