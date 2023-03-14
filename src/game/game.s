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
.equ    vgaTextStart, 0xB8000               #start VGA text memory
.equ    vgaTextEnd, 0xB8FA0                 #vgaTextStart + 4000 = VgaTextEnd (80x25 characters, occupying 2 bytes of memory so 80 x 25 x 2 = 4000 bytes)

.section .game.text


gameInit:
	movq    $33333, %rdi            		#generate interupt every 33,333 ms, aka 30Hz
    call    setTimer                		#call setTimer to load it to 30 Hz
    
	movq    $vgaTextStart, %rdi         	#start of graphics memory
	clearScreen:
		movb $0x0,  (%rdi)     			    # write nothing to the character cell
		movb $0x0 , 1(%rdi)    			    # write the background attribute BLACK to the next byte
		addq $2, %rdi          				# move to the next character, 2 bytes
		cmpq $vgaTextEnd, %rdi     			# check if at the end of VGA text memory
		jl clearScreen            			

gameLoop:
	ret
