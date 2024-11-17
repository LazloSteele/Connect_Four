# Program #11: Connect Four
# Author: Lazlo F. Steele
# Due Date : Nov. 16, 2024 Course: CSC2025-2H1
# Created: Nov. 16, 2024
# Last Modified: Nov. 17, 2024
# Functional Description: Play connect four.
# Language/Architecture: MIPS 32 Assembly
####################################################################################################
# Algorithmic Description:
####################################################################################################
				.data
welcome_msg:	.asciiz "\nWelcome to Connect Four. Let's start a two player game...\n"
plyr_1_prmpt:	.asciiz "\nPlayer 1 select a column [1-7] > "
plyr_2_prmpt:	.asciiz "\nPlayer 2 select a column [1-7] > "
repeat_msg:		.asciiz "\nGo again? Y/N > "
invalid_msg:	.asciiz "\nInvalid input. Try again!\n"
bye: 			.asciiz "\nToodles! ;)"

newline:		.asciiz "\n"
bar:			.asciiz	"|"
empty_glyph:	.asciiz "*"
p1_glyph:		.asciiz "X"
p2_glyph:		.asciiz	"O"
bottom:			.asciiz "\n|1|2|3|4|5|6|7|\n"

				.align	2
board_state:	.word	0, 0, 0, 0, 0, 0, 0, 
						0, 0, 0, 0, 0, 0, 0, 
						0, 0, 0, 0, 0, 0, 0, 
						0, 0, 0, 0, 0, 0, 0, 
						0, 0, 0, 0, 0, 0, 0, 
						0, 0, 0, 0, 0, 0, 0
next_row:		.word	28

buffer:			.space	2
				
				.globl main
				
				.text
####################################################################################################
# function: main
# purpose: to control program flow
# registers used:
#	$a0 - argument passed
#	$s0 - decimal places found in get_int
####################################################################################################
main:								#
	jal		welcome					# welcome the user
									#
	jal		game_loop				#
									#
	j		again					#
									#
####################################################################################################
# function: welcome
# purpose: to welcome the user to our program
# registers used:
#	$v0 - syscall codes
#	$a0 - passing arugments to subroutines
#	$ra	- return address
####################################################################################################	
welcome:							# 
	la	$a0, welcome_msg			# load welcome message
	li	$v0, 4						# 
	syscall							# and print
									#
	jr	$ra							# return to caller
									#
####################################################################################################
# function: game_loop
# purpose: to control the gameplay
# registers used:
####################################################################################################
game_loop:
	player_1_turn:
		li		$v1, 0
	
		move	$s0, $ra						# save return address for nesting
		jal 	display_board
		move	$ra, $s0						# restore return address for nesting
		
		move	$s0, $ra
		la		$a0, plyr_1_prmpt
		jal		get_input
		move	$ra, $s0
		
		move	$s0, $ra
		move	$a0, $v0
		jal		validate_input
		move	$ra, $s0		
		beq		$v1, 1, player_1_turn		# if invalid play, try again
		
		move	$s0, $ra
		move	$a0, $v0
		jal		format_input
		move	$ra, $s0	
		
		move	$s0, $ra
		move	$a0, $v0
		li		$a1, 1
		jal		check_tile
		move	$ra, $s0
	
	player_2_turn:
		move	$s0, $ra						# save return address for nesting
		jal 	display_board
		move	$ra, $s0						# restore return address for nesting
		
		li		$v0, 4
		la		$a0, plyr_2_prmpt
		syscall	
		
		li		$v0, 8
		la		$a0, buffer
		li		$a1, 2
		syscall

		lb		$t0, 0($a0)					# load first byte from buffer
											#
		li		$t1, '1'					# 
		blt 	$t0, $t1, invalid_plyr_2	# if it is less than '1' then invalid
		li		$t1, '7'					#
		bgt 	$t0, $t1, invalid_plyr_2	# if it is greater than '4' then invalid
											#
		addi 	$t0, $t0, -48				# subtract '0' to store as integer in flag
		addi	$t0, $t0, -1				# subtract 1 for 0 based indexing
		li		$t1, 4						#
		mul		$t0, $t0, $t1				# multiply by 4 for word offset
		
		la		$t2, board_state			#
		add		$t2, $t2, $t0				# move selector to the correct column
		lw		$t3, 0($t2)					#
		bnez	$t3, invalid_plyr_2			# column full
		
		li		$t7, 0
		check_next_row2:
			la	$t5, next_row
			lw	$t5, 0($t5)
			
			add $t6, $t2, $t5				# check next row down
			lw	$t6, 0($t6)
			
			bnez $t6, place_glyph2			# if next row down not empty then place the glyph

			addi $t7, $t7, 1			
			beq	 $t7, 6, place_glyph2
			
			add	$t2, $t2, $t5
			j	check_next_row2
			
		place_glyph2:
			li		$t4, 2
			sw		$t4, 0($t2)									
											#

	
	j		game_loop	
	jr 		$ra

	invalid_plyr_2:
		la	$a0, invalid_msg		# 
		li	$v0, 4					#
		syscall						# print invalid message
		
		j player_2_turn

####################################################################################################
# function: get_input
# purpose: to get the column the player would like to drop their token in.
# registers used:
####################################################################################################
get_input:
		li		$v0, 4
		syscall
		
		li		$v0, 8
		la		$a0, buffer
		li		$a1, 2
		syscall

		lb		$v0, 0($a0)					# load first byte from buffer
		jr		$ra
####################################################################################################
# function: validate_input
# purpose: to ensure input is a valid column and to .
# registers used:
####################################################################################################
validate_input:								#
		move	$t0, $a0					#
											#
		li		$t1, '1'					# 
		blt 	$t0, $t1, invalid_play		# if it is less than '1' then invalid
		li		$t1, '7'					#
		bgt 	$t0, $t1, invalid_play		# if it is greater than '4' then invalid
											#
		move	$v0, $t0					# return the validated user input value
											#
		jr		$ra							#
											#
####################################################################################################
# function: format_input
# purpose: to format input appropriately
# registers used:
####################################################################################################
format_input:								#
		move	$t0, $a0					#
											#
		addi 	$t0, $t0, -48				# subtract '0' to store as integer
		addi	$t0, $t0, -1				# subtract 1 for 0 based indexing
		li		$t1, 4						#
		mul		$t0, $t0, $t1				# multiply by 4 for word offset
											#
		move	$v0, $t0					#
											#
		jr		$ra							#
											#
####################################################################################################
# function: check tile
# purpose: to 
# registers used:
####################################################################################################
check_tile:
	move $t0, $a0
	move $t1, $a1

	la		$t2, board_state			#
	add		$t2, $t2, $t0				# move selector to the correct column
	lw		$t3, 0($t2)					#
	bnez	$t3, invalid_play			# column full
										#
	li		$t7, 0
	check_next_row:
		la	$t5, next_row
		lw	$t5, 0($t5)
		
		add $t6, $t2, $t5				# check next row down
		lw	$t6, 0($t6)
		
		bnez 	$t6, place_glyph			# if next row down not empty then place the glyph
			
		addi	$t7, $t7, 1
		beq		$t7, 6, place_glyph

		add	$t2, $t2, $t5
		j	check_next_row
		
	place_glyph:
		sw		$t1, 0($t2)
		
	jr		$ra
											#									
####################################################################################################
# function: invalid_play
# purpose: to raise an invalid play flag and return to caller
# registers used:
####################################################################################################
invalid_play:
	la	$a0, invalid_msg		# 
	li	$v0, 4					#
	syscall						# print invalid message
	
	li	$v1, 1
	
	jr $ra
####################################################################################################
# function: display_board
# purpose: to display the current game state to player
# registers used:
####################################################################################################
display_board:
	li		$v0, 4					# 
	li		$t0, 0					# row counter
	la		$t2, board_state
	
	new_row:
		beq		$t0, 6, board_done
		li		$t1, 0					# column counter
		
		li		$v0, 11
		la		$a0, newline
		lb		$a0, 0($a0)
		syscall
		la		$a0, bar
		lb		$a0, 0($a0)
		syscall
		new_column:
			lw		$t3, 0($t2)
			
			beq		$t3, 1, cell_x
			beq		$t3, 2, cell_o
			
			la		$a0, empty_glyph
			lb		$a0, 0($a0)
			syscall
			j		cell_done
			
			cell_x:
				la		$a0, p1_glyph
				lb		$a0, 0($a0)
				syscall
				j		cell_done		
			cell_o:
				la		$a0, p2_glyph
				lb		$a0, 0($a0)
				syscall
				j		cell_done		
			cell_done:			
				la		$a0, bar
				lb		$a0, 0($a0)
				syscall
			
				addi	$t1, $t1, 1
				addi	$t2, $t2, 4			# iterate to next entry on board_state
				bne		$t1, 7, new_column
		addi	$t0, $t0, 1
		j		new_row
	board_done:
		la		$a0, bottom
		li		$v0, 4
		syscall
									#
	jr		$ra						#
									#
####################################################################################################
# function: re-enter
# purpose: to clear the buffer and re-enter the main loop
# registers used:
#	$a0 - buffer address
#	$a1 - buffer length
####################################################################################################
re_enter:							#
	la	$a0, buffer					# load buffer address
	li	$a1, 2						# length of buffer
	jal	reset_buffer				# clear the buffer
	j	main						# let's do the time warp again!
									#
####################################################################################################
# function: reset_buffer
# purpose: to reset the buffer for stability and security
# registers used:
#	$t0 - buffer address
#	$t1 - buffer length
#	$t2 - reset value (0)
#	$t3 - iterator
####################################################################################################	
reset_buffer:									#
	move		$t0, $a0						# buffer to $t0
	move		$t1, $a1						# buffer_size to $t1
	li			$t2, 0							# to reset values in buffer
	li 			$t3, 0							# initialize iterator
	reset_buffer_loop:							#
		bge 	$t3, $t1, reset_buffer_return	#
		sw		$t2, 0($t0)						# store a 0
		addi	$t0, $t0, 4						# next word in buffer
		addi 	$t3, $t3, 1						# iterate it!
		j reset_buffer_loop 					# and loop!
	reset_buffer_return:						#
		jr 		$ra								#
												#
####################################################################################################
# macro: upper
# purpose: to make printing messages more eloquent
# registers used:
#	$t0 - string to check for upper case
#	$t1 - ascii 'a', 'A'-'Z' is all lower value than 'a'
# variables used:
#	%message - message to be printed
####################################################################################################		
upper:							#
	move $s0, $ra				#
	move $t0, $a0				# load the buffer address
	li $t1, 'a'					# lower case a to compare
	upper_loop:					#
		lb $t2, 0($t0)			# load next byte from buffer
		blt $t2, $t1, is_upper	# bypass uppercaserizer if character is already upper case (or invalid)
		to_upper:				# 
			subi $t2, $t2, 32	# Convert to uppercase (ASCII difference between 'a' and 'A' is 32)
		is_upper:				#
			sb $t2, 0($t0)		# store byte
		addi $t0, $t0, 1		# next byte
		bne $t2, 0, upper_loop	# if not end of buffer go again!
	move $ra, $s0				#
	jr $ra						#
								#
####################################################################################################
# function: again
# purpose: to user to repeat or close the program
# registers used:
#	$v0 - syscall codes
#	$a0 - message storage for print and buffer storage
#	$t0 - stores the memory address of the buffer and first character of the input received
#	$t1 - ascii 'a', 'Y', and 'N'
####################################################################################################
again:							#		
	la $a0, repeat_msg			#
	li $v0, 4					#
	syscall						#
								#
	la $a0, buffer				#
	la $a1, 2					#
	li $v0, 8					#
	syscall						#
								#
	la $a0, buffer				#
	jal upper					# load the buffer for string manipulation
								#
	la $t0, buffer				#
	lb $t0, 0($t0)				#
	li $t1, 'Y'					# store the value of ASCII 'Y' for comparison
	beq $t0, $t1, re_enter		# If yes, go back to the start of main
	li $t1, 'N'					# store the value of ASCII 'N' for comparison
	beq $t0, $t1, end			# If no, goodbye!
	j again_invalid				# if invalid try again...
								#
	again_invalid:				#
		la $a0, invalid_msg		#
		li $v0, 4				#
		syscall					#
								#
####################################################################################################
# function: end
# purpose: to eloquently terminate the program
# registers used:
#	$v0 - syscall codes
#	$a0 - message addresses
####################################################################################################	
end:	 					#
	la		$a0, bye		#
	li		$v0, 4			#
	syscall					#
							#
	li 		$v0, 10			# system call code for returning control to system
	syscall					# GOODBYE!
							#
####################################################################################################
