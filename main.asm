# Program #11: Connect Four
# Author: Lazlo F. Steele
# Due Date : Nov. 16, 2024 Course: CSC2025-2H1
# Created: Nov. 16, 2024
# Last Modified: Nov. 16, 2024
# Functional Description: Play connect four.
# Language/Architecture: MIPS 32 Assembly
####################################################################################################
# Algorithmic Description:
####################################################################################################
				.data
welcome_msg:	.asciiz "\nWelcome to Connect Four. Let's start a two player game...\n"
plyr_1_prmtp:	.asciiz "\nPlayer 1 select a column [1-7] > "
plyr_2_prmtp:	.asciiz "\nPlayer 2 select a column [1-7] > "
repeat_msg:		.asciiz "\nGo again? Y/N > "
invalid_msg:	.asciiz "\nInvalid input. Try again!\n"
bye: 			.asciiz "Toodles! ;)"

row_1_view:		.asciiz "\n|*|*|*|*|*|*|*|"
row_2_view:		.asciiz "\n|*|*|*|*|*|*|*|"
row_3_view:		.asciiz "\n|*|*|*|*|*|*|*|"
row_4_view:		.asciiz "\n|*|*|*|*|*|*|*|"
row_5_view:		.asciiz "\n|*|*|*|*|*|*|*|"
row_6_view:		.asciiz "\n|*|*|*|*|*|*|*|"
bottom:			.asciiz "\n|1|2|3|4|5|6|7|\n"

				.align	2
row_1_state:	.word	0, 0, 0, 0, 0, 0, 0
row_2_state:	.word	0, 0, 0, 0, 0, 0, 0
row_3_state:	.word	0, 0, 0, 0, 0, 0, 0
row_4_state:	.word	0, 0, 0, 0, 0, 0, 0
row_5_state:	.word	0, 0, 0, 0, 0, 0, 0
row_6_state:	.word	0, 0, 0, 0, 0, 0, 0

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
	move	$s0, $ra						# save return address for nesting
	jal 	display_board
	move	$ra, $s0						# restore return address for nesting

	jr 		$ra
####################################################################################################
# function: display_board
# purpose: to display the current game state to player
# registers used:
####################################################################################################
display_board:
	li		$v0, 4					# 
	
	la		$a0, row_1_view			# load welcome message	
	syscall							# and print
	la		$a0, row_2_view			# load welcome message	
	syscall							# and print
	la		$a0, row_3_view			# load welcome message	
	syscall							# and print
	la		$a0, row_4_view			# load welcome message	
	syscall							# and print
	la		$a0, row_5_view			# load welcome message	
	syscall							# and print
	la		$a0, row_6_view			# load welcome message	
	syscall							# and print
	la		$a0, bottom				# load welcome message	
	syscall							# and print
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
	li	$a1, 33						# length of buffer
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
	la $a1, 4					#
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
