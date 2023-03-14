/*
This file is part of gamelib-x64.

Copyright (C) 2014 Tim Hegeman

gamelib-x64 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

gamelib-x64 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with gamelib-x64. If not, see <http://www.gnu.org/licenses/>.
*/

.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.data
	#variables

	SNAKEARRAY_X: 	.space 100         # memory space for the number table
	SNAKEARRAY_Y: 	.space 100         # memory space for the number table

	playerX:		.quad	40
	playerY:		.quad	12
	appleX:			.quad	159
	appleY:			.quad 	23
	direction:		.quad	4
	snakeLenght:	.quad	1


	score:          .quad 0x0               #initialize a score in memory to 0.
	highest:        .quad 0x0               #add a place to save the highest achieved score.



.section .game.text
	#constants
	.equ    VIDMEM, 0xB8000               		# start VGA text memory
	.equ    VIDMEM_END, 0xB8FA0                 # VIDMEM + 4000 = VIDMEM_END (80x25 characters, occupying 2 bytes of memory so 80 x 25 x 2 = 4000 bytes)
	.equ	SCREEMW, 0x50						# 80 charcters wide
	.equ	SCREENH, 0x19						# 25 charcters height
	.equ	WINDCOND, 0xA						# win condition is 10 appels
	
	############################
	.equ	BGCOLOR, 0x1020						# word, 1 - blue background, 0 - black foreground, 20 - space
	.equ	APPLECCOLOR, 0x4020					# red apple
	.equ	SNAKECOLOR, 0x2020					# green snake
	.equ	TIMER, 0x04C						# counter
	##############################

	.equ    left, 0x4B                      	# left arrow scan code
	.equ    right, 0x4D                     	# right arrow scan code
	.equ    down, 0x50                      	# down arrow scan code



gameInit:
	movq    $33333, %rdi            			# generate interupt every 33,333 ms, aka 30Hz
    call    setTimer                			# call setTimer to load 30 Hz
    
	snakeInit:
		#init snake array
		movq	$0, %rbx
		leaq    SNAKEARRAY_X(%rip), %rax   # load address of SNAKEARRAY_X table into rax
		leaq    SNAKEARRAY_Y(%rip), %rcx   # load address of SNAKEARRAY_Y table into rcx

		movq	playerX, %rsi
		movq    %rsi, (%rax, %rbx)

		movq	playerY, %rsi
		movq    %rsi, (%rcx, %rbx)

gameLoop:
	#clear screen every loop
	movq    $VIDMEM, %rdi         					# start of VGA text memory
	clearScreen:
		movw 	$BGCOLOR, (%rdi)     			    
		addq 	$2, %rdi          					# move to the next character, 2 bytes
		cmpq 	$VIDMEM_END, %rdi     				# check if at the end of VGA text memory
		jl 		clearScreen

	movq    $VIDMEM, %rdi         					# start of VGA text memory
	drawSnake:	
		movq	$0, %rbx
		movq	snakeLenght, %rcx

		leaq    SNAKEARRAY_X(%rip), %r15   # load address of SNAKEARRAY_X table into r15
		leaq    SNAKEARRAY_Y(%rip), %r14   # load address of SNAKEARRAY_Y table into r14

		movq	(%r15, %rbx), %r13			#X
		movq	(%r14, %rbx), %r12			#Y

		movq	$160, %rax
		imul	%r12
		addq	%rax, %rdi

		movq	$2, %rax
		imul	%r13
		addq	%rax, %rdi

		movw 	$SNAKECOLOR, (%rdi)
		movq    $VIDMEM, %rdi  

		addq	$1, %rbx
		subq	$1, %rcx

		cmpq	$0, %rcx
		jg		drawSnake
	drawApple:
		movq    appleX, %r13   # load address of SNAKEARRAY_X table into r15
		movq    appleY, %r12   # load address of SNAKEARRAY_X table into r15

		movq	$160, %rax
		imul	%r12
		addq	%rax, %rdi

		movq	$2, %rax
		imul	%r13
		addq	%rax, %rdi

		movw 	$APPLECCOLOR, (%rdi)

		





		// movq 	$0, %rbx				# array counter
		// movq	snakeLenght, %rcx		# loop counter
		
		// leaq    SNAKEARRAY_X(%rip), %r15   # load address of SNAKEARRAY_X table into rax
		// leaq    SNAKEARRAY_Y(%rip), %r14   # load address of SNAKEARRAY_Y table into rdx
		// snakeLoop:





		// 	movq	$80, %rax
		// 	movq	(%r14, %rbx), %r8
		// 	imul	%r8;

		// 	movq	%rax, %r9

		// 	movq	$2, %rax
		// 	movq	(%r15, %rbx), %r8
		// 	imul	%r8;

		// 	addq	%rax, %r9

		// 	movq	%r9, (%rdi)
		// 	addq	$2, %rbx
		// 	decq	%rcx

		// 	cmpq 	$0, %rcx     				# check if at the end of VGA text memory
		// 	jg 		snakeLoop

		
	

	ret





	// imul. SRC RDX:RAX = RAX * SRC

	// movq    $VIDMEM, %rdi         				# start of VGA text memory
	// clearScreen:
	// 	movb $0x0,  (%rdi)     			    	# write nothing to the character cell
	// 	movb $0x0 , 1(%rdi)    			   	 	# write the background attribute BLACK to the next byte
	// 	addq $2, %rdi          					# move to the next character, 2 bytes
	// 	cmpq $VIDMEM_END, %rdi     				# check if at the end of VGA text memory
	// 	jl clearScreen