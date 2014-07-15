ld	$2,	0x4
mov	$0, 0x8
forward:
	addi	$1,	$2,	0x20
	addi	$5,	$2,	0x20
	beq	$0,	$2
	backward:
		subi	$5,	$5,	0x1
		ld	$3,	$1
		ld	$4,	$5
		scg	$3,	$4
		scl	$3,	$4
		str	$7,	$1
		str	$6,	$5
	jdne	$1,	$2,	backward
jine	$0,	$2,	forward
halt