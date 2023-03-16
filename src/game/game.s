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
// https://www.youtube.com/watch?v=kZr8sR9Gwag
.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.data
	#variables

	SNAKEARRAY_X: 	.space 1000         # memory space for the number table
	SNAKEARRAY_Y: 	.space 1000         # memory space for the number table

	playerX:		.quad	70
	playerY:		.quad	12
	appleX:			.quad	50
	appleY:			.quad 	12
	direction:		.quad	4			#could be byte?
	snakeLenght:	.quad	2


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

	.equ	upCode, 0x48							# up arrow scan code
	.equ    leftCode, 0x4B                      	# left arrow scan code
	.equ    rightCode, 0x4D                     	# right arrow scan code
	.equ    downCode, 0x50                      	# down arrow scan code


	.equ	up, 0x0
	.equ    left, 0x1                      	# left arrow scan code
	.equ    right, 0x2                     	# right arrow scan code
	.equ    down, 0x3                      	# down arrow scan code


gameInit:
	movq    $900000000, %rdi            		# generate interupt every 33,333 ms, aka 30Hz
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

		addq	$8, %rbx

		movq    $71, (%rax, %rbx)
		movq    $12, (%rcx, %rbx)



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
		movq	$0, %rbx					# array counter
		movq	snakeLenght, %rcx			# loop counter

		leaq    SNAKEARRAY_X(%rip), %r15   	# load address of SNAKEARRAY_X table into r15
		leaq    SNAKEARRAY_Y(%rip), %r14   	# load address of SNAKEARRAY_Y table into r14

		drawSnakeLoop:
		movq	(%r15, %rbx), %r13			#X
		movq	(%r14, %rbx), %r12			#Y

		movq	$160, %rax
		imul	%r12
		addq	%rax, %rdi

		movq	$2, %rax
		imul	%r13
		addq	%rax, %rdi

		movw 	$SNAKECOLOR, (%rdi)
		movq    $VIDMEM, %rdi  				# reload vid mem

		addq	$8, %rbx					# skip 8 bytes
		subq	$1, %rcx					# loop counter -= 1					

		cmpq	$0, %rcx
		jg		drawSnakeLoop
	drawApple:
		movq    appleX, %r13   # load address of appleX table into r15
		movq    appleY, %r12   # load address of appleY table into r15

		movq	$160, %rax
		imul	%r12
		addq	%rax, %rdi

		movq	$2, %rax
		imul	%r13
		addq	%rax, %rdi

		movw 	$APPLECCOLOR, (%rdi)
	
	moveSnake:
		movq	direction, %r15		# move current direction to r15
             
		cmpq    $up, %r15
        je      processUp	 
        cmpq    $left, %r15
        je      processLeft
        cmpq	$right, %r15
        je      processRight
        cmpq    $down, %r15
        je      processDown

		jmp 	playerInput			# bug?	

		processUp:
			subq	$1, playerY			# move UP 1 row
			jmp		updateSnake
		processDown:
			addq	$1, playerY			# move DOWN 1 row
			jmp		updateSnake
		processLeft:
			subq	$1, playerX			# move LEFT 1 col
			jmp		updateSnake
		processRight:
			addq	$1, playerX			# move RIGHT 1 col
			jmp		updateSnake

		updateSnake:							# update snake based on player movemnet
			leaq    SNAKEARRAY_X(%rip), %r15   	# load address of SNAKEARRAY_X table into r15
			leaq    SNAKEARRAY_Y(%rip), %r14   	# load address of SNAKEARRAY_Y table into r14

			movq	snakeLenght, %rax
			movq	$8, %rbx
			imul	%rbx
			movq	%rax, %rbx


			updateSnakeBody:
				subq	$8, %rbx
				movq	(%r15,%rbx), %rax
				addq	$8, %rbx
				movq	%rax, (%r15,%rbx)


				subq	$8, %rbx
				movq	(%r14,%rbx), %rax
				addq	$8, %rbx
				movq	%rax, (%r14,%rbx)

				subq	$8, %rbx
				cmpq	$0, %rbx
				jg		updateSnakeBody

			updateSnakeHead:
				movq	$0, %rbx
				leaq    SNAKEARRAY_X(%rip), %rax   # load address of SNAKEARRAY_X table into rax
				leaq    SNAKEARRAY_Y(%rip), %rcx   # load address of SNAKEARRAY_Y table into rcx

				movq	playerX, %rsi
				movq    %rsi, (%rax, %rbx)

				movq	playerY, %rsi
				movq    %rsi, (%rcx, %rbx)

		
			// snakeCollision:
			// 	cmpq	$1, snakeLenght
			// 	je		playerInput

			// 	leaq    SNAKEARRAY_X(%rip), %r15   	# load address of SNAKEARRAY_X table into r15
			// 	leaq    SNAKEARRAY_Y(%rip), %r14   	# load address of SNAKEARRAY_Y table into r14

			// 	movq	$8, %rbx
			// 	movq	snakeLenght, %rcx
			// 	subq	$1, %rcx

			// 	checkCollision:
			// 		movq	playerX, %rax
			// 		cmpq	(%r15, %rbx), %rax
			// 		jne		nextElement
					
			// 		movq	playerY, %rax
			// 		cmpq	(%r14, %rbx), %rax
			// 		je 		gameOver

			// 		nextElement:
			// 			subq	$1, %rcx
			// 			addq	$8, %rbx

			// 			cmpq	$0, %rcx
			// 			jg		checkCollision
						
		playerInput:
			call	readKeyCode            
			
			cmpq	$upCode, %rax               
			je      upPressed
			cmpq	$downCode, %rax             
			je      downPressed
			cmpq	$leftCode, %rax             
			je      leftPressed
			cmpq	$rightCode, %rax            
			je      rightPressed

			jmp 	checkApple

			upPressed:
				movq	$up, direction
				jmp		checkApple
			downPressed:
				movq	$down, direction
				jmp		checkApple
			leftPressed:
				movq	$left, direction
				jmp		checkApple
			rightPressed:
				movq	$right, direction
				jmp		checkApple

		checkApple:
			// movq	playerX, %rax
			// movq	appleX, %rbx

			// cmpq	%rax, %rbx
			// jne		end

			// movq	playerY, %rax
			// movq	appleY, %rbx
			
			// cmpq	%rax, %rbx
			// jne		end

			// addq	$1, snakeLenght

			// movq	$40, appleX
			// movq	$12, appleY
			// jmp		end


	gameOver:
		#implement game over
		
		
	end:
		// movq	snakeLenght, %rax
		// movb	%al, %dl 

		// movq	$0, %rdi
		// movq	$0, %rsi
		// movb	$0x0f, %cl
		// call	putChar
		ret

	

