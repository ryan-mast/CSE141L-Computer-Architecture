.text
mov	$0,	0x0
mov	$2,	0x80
loop:
ld	$3,	$2
bitcnt	$3
jdne	$2,	0x20,	loop
str	$0,	0x2
halt
