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

	SNAKEARRAY_X: 	.space 1000         # memory space for the number table
	SNAKEARRAY_Y: 	.space 1000         # memory space for the number table


	appleX:			.quad	16
	appleY:			.quad 	8
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

	playerX:		.byte	0x40
	playerY:		.byte	100

gameInit:
	movq    $33333, %rdi            			# generate interupt every 33,333 ms, aka 30Hz
    call    setTimer                			# call setTimer to load 30 Hz
    
	movq    $VIDMEM, %rdi         				# start of VGA text memory
	clearScreen:
		movb $0x0,  (%rdi)     			    	# write nothing to the character cell
		movb $0x0 , 1(%rdi)    			   	 	# write the background attribute BLACK to the next byte
		addq $2, %rdi          					# move to the next character, 2 bytes
		cmpq $VIDMEM_END, %rdi     				# check if at the end of VGA text memory
		jl clearScreen

	snakeInit:
		#init snake array
		movq    $0, %rbx            # initialize 'i' to 0.
		head:
			leaq    SNAKEARRAY_X(%rip), %rax # load address of NUMBERS table into rax
			leaq    SNAKEARRAY_Y(%rip), %rcx # load address of NUMBERS table into rcx

			movb	playerX, %sil
			movb    %sil, (%rax, %rbx)

			movb	playerY, %sil
			movb    %sil, (%rcx, %rbx)

			movq	$0, %rdi
			movb	(%rcx, %rbx), %dl
			movq	$0, %rsi
			movb	$0x0f, %cl
			call	putChar


			incq    %rbx                # increment 'i' 
		body:
			movb    $0, (%rax, %rbx)    # set number table entry 'i' to '0'
			movb    $0, (%rcx, %rbx)    # set number table entry 'i' to '0'

			incq    %rbx                # increment 'i'                      
			cmpq    $1000, %rbx         # while 'i' < 1000                   
			jl      body               	# go to start of loop1

	

gameLoop:
	

	ret
