# Program #11: Connect Four
# Author: Lazlo F. Steele
# Due Date : Nov. 16, 2024 Course: CSC2025-2H1
# Created: Nov. 16, 2024
# Last Modified: Nov. 19, 2024
# Functional Description: Play connect four.
# Language/Architecture: MIPS 32 Assembly
####################################################################################################
# Algorithmic Description:
#	welcome user
#	while valid plays exist and no player has won:
#		for each player:
#			choose column:
#				if column is full then try again, otherwise...
#				token drops to greatest empty row in chosen column
#				if there are four in a row player wins
#			iterate player
#	play again?
####################################################################################################
				.data
welcome_msg:	.asciiz "\nWelcome to Connect Four. Let's start a two player game...\n"
plyr_1_prmpt:	.asciiz "\nPlayer 1 select a column [1-7] > "
plyr_2_prmpt:	.asciiz "\nPlayer 2 select a column [1-7] > "
p1_wins:		.asciiz "\nPlayer 1 wins!"
p2_wins:		.asciiz "\nPlayer 2 wins!"
repeat_msg:		.asciiz "\nGo again? Y/N > "
cats_game_msg:	.asciiz "\nCat's Game...\n"
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
victor_flag:	.word	0

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
	li		$a0, 0					# 0 tokens placed
	j		game_loop_prep			# play the game!
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
game_loop_prep:								#
	move $s2, $a0							# move the token counter to saved register
game_loop:									#
	player_1_turn:							#
		la		$a0, plyr_1_prmpt			#
		li		$a1, 1						# 
		jal		game_turn					# p1 turn
											#
	player_2_turn:							#
		la		$a0, plyr_2_prmpt			#
		li		$a1, 2						# 
		jal		game_turn					# p2 turn
											#
	blt		$s2, 42, game_loop				# repeat until all tiles have been played
											#
	la		$a0, cats_game_msg				#
	li		$v0, 4							#
	syscall									# then it's a tie!
											#
	j		again							# again?
											#
####################################################################################################
# function: game_turn
# purpose: 
# registers used:
####################################################################################################
game_turn:								#
	move	$s3, $a0					# player prompt
	move	$s4, $a1					# player number
										#
	li		$v1, 0						# initialize invalid play flag
										#
	move	$s1, $ra					# save return address for nesting
	jal 	display_board				# display the current tokens
	move	$ra, $s1					# restore return address for nesting
										#
	move	$s1, $ra					# save return address for nesting
	move	$a0, $s3					# load the player prompt
	jal		get_input					# prompt for user input
	move	$ra, $s1					# restore return address for nesting
										#
	move	$s1, $ra					# save return address for nesting
	move	$a0, $v0					# move returned user input to argument
	jal		validate_input				# and validate
	move	$ra, $s1					# restore return address for nesting
	beq		$v1, 1, game_turn			# if invalid play, try again
										#
	move	$s1, $ra					# save return address for nesting
	move	$a0, $v0					# move validated input to argument
	jal		format_input				# and format it
	move	$ra, $s1					# restore return address for nesting
										#
	move	$s1, $ra					# save return address for nesting
	move	$a0, $v0					# move the formatted input to argument
	move	$a1, $s4					# mark as player 1
	jal		check_tile					# place that tile!
	move	$ra, $s1					# restore return address for nesting
	beq		$v1, 1, game_turn			# if column full, try again
										#
	addi	$s2, $s2, 1					# count the tile as placed
										#
	move	$s1, $ra					# save return address for nesting
	jal		check_victory				# did anyone win?
	move	$ra, $s1					# restore return address for nesting
										#
	jr		$ra							#
										#
####################################################################################################
# function: get_input
# purpose: to get the column the player would like to drop their token in.
# registers used:
####################################################################################################
get_input:									#
		li		$v0, 4						#
		syscall								# print player prompt
											#
		li		$v0, 8						#
		la		$a0, buffer					#
		li		$a1, 2						#
		syscall								# get player input
											#
		lb		$v0, 0($a0)					# load first byte from buffer
		jr		$ra							#
####################################################################################################
# function: validate_input
# purpose: to ensure input is a valid column.
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
# function: check_tile
# purpose: to 
# registers used:
####################################################################################################
check_tile:								#
	move $t0, $a0						# formatted input
	move $t1, $a1						# player value
										#
	la		$t2, board_state			#
	add		$t2, $t2, $t0				# move selector to the correct column
	lw		$t3, 0($t2)					#
	bnez	$t3, invalid_play			# if column full then not valid play
										#
	li		$t7, 0						# check for bottom of column 0 is top, 6 is bottom
	check_next_row:						#
		la	$t5, next_row				# 
		lw	$t5, 0($t5)					# load value for 7 word offset
										#
		add $t6, $t2, $t5				# check next row down
		lw	$t6, 0($t6)					#
										#
		bnez 	$t6, place_glyph		# if next row down not empty then place the glyph
										#
		addi	$t7, $t7, 1				# iterate the row counter to check for bottom of column
		beq		$t7, 6, place_glyph		# if bottom of column then place the token
										#
		add	$t2, $t2, $t5				# iterate to next row down
		j	check_next_row				# and repeat
										#
	place_glyph:						#
		sw		$t1, 0($t2)				# store the player value in the appropriate cell
										#
	jr		$ra							# return to caller
										#									
####################################################################################################
# function: check_victory
# purpose: to check if a player wins in their turn
# registers used:
####################################################################################################
check_victory:										#
	la		$t0, board_state						# load positions of all tiles
	li		$t5, 0									# 
	li		$t6, 1									# column counter
	li		$t7, 1									# row counter
	for_cell:										#
		lw		$t1, 0($t0)							# working cell
		ble		$t6, 7, same_row					#
		li		$t6, 1								# reset column
		addi	$t7, $t7, 1							# iterate row
		same_row:									#
		beqz	$t1, next_cell						# if cell is empty, skip
		li		$t2, 1								# how many in a row
		move	$t3, $t0							# working array
		move	$t8, $t6							# working column
		check_horizontal:							#
			bgt		$t8, 4, check_vertical_prep		# if column is greater than 4, not able to connect four on this row
			lw		$t4, 4($t3)						# look at the next cell to the right
			bne		$t1, $t4, check_vertical_prep	# if no match then check vertical
			addi	$t3, $t3, 4						# iterate to the next cell
			addi	$t2, $t2, 1						# if equal columns add 1 to the count
			addi	$t8, $t8, 1						# increment column counter
			beq		$t2, 4, victory					# if four in a row then somebody wins!
			j		check_horizontal				# keep checking!
													#
		check_vertical_prep:						#
			li		$t2, 1							# how many in a row
			move	$t3, $t0						# working array
			move	$t8, $t7						# working row
		check_vertical:								#
			blt		$t8, 3, check_diagonal_r_prep	# if row is less than 3, not able to connect four on this column
			lw		$t4, -28($t3)					# -28 is one row above
			bne		$t1, $t4, check_diagonal_r_prep	# if chosen cell doesn't have an adjacent match then skip!
			addi	$t3, $t3, -28					# go up one!
			addi	$t2, $t2, 1						# if equal columns add 1 to the count
			beq		$t2, 4, victory					# if there are four in a row then somebody wins!
			j		check_vertical					# keep checking!
													#
		check_diagonal_r_prep:						#
			li		$t2, 1							# how many in a row
			move	$t3, $t0						# working array
			move	$t8, $t6						# working column
		check_diagonal_r:							#
			bgt		$t8, 4, check_diagonal_l_prep	# if column is greater than 4, not able to connect four on this diagonal
			lw		$t4, -24($t3)					#
			bne		$t1, $t4, check_diagonal_l_prep	#
			addi	$t3, $t3, -24					#
			addi	$t2, $t2, 1						# if equal columns add 1 to the count
			beq		$t2, 4, victory					#
			j		check_diagonal_r				#
													#
		check_diagonal_l_prep:						#
			li		$t2, 1							# how many in a row
			move	$t3, $t0						# working array
			move	$t8, $t6						# working column
		check_diagonal_l:							#
			blt		$t8, 4, next_cell				# if column is less than 4, not able to connect four on this diagonal
			lw		$t4, -32($t3)					#
			bne		$t1, $t4, next_cell				#
			addi	$t3, $t3, -32					#
			addi	$t2, $t2, 1						# if equal columns add 1 to the count
			beq		$t2, 4, victory					#
			j		check_diagonal_l				#
													#
		next_cell:									#
			addi	$t0, $t0, 4						# move the board position over by 4
			addi	$t5, $t5, 1						# iterate cell number
			addi	$t6, $t6, 1						# iterate row number
			beq		$t5, 42, no_win					# if all cells have been checked and nobody wins the go back to the game!
			j		for_cell						# otherwise keep checking!
													#
	victory:										#
		move	$s1, $ra							# save return address for nesting
		jal 	display_board						#
		move	$ra, $s1							# restore return address for nesting

		beq		$t1, 1, player1_wins				# if the connect four is for p1 then they win
		beq		$t1, 2, player2_wins				# if it is for p2 then p2 wins!
													#
	player1_wins:									#													#
		la		$a0, p1_wins						#
		li		$v0, 4								#
		syscall										# print p1 victory message
													#
		j		again								# play again?
													#
	player2_wins:									#
		la		$a0, p2_wins						#
		li		$v0, 4								#
		syscall										# print p2 victory message
													#
		j		again								# play again?
													#
	no_win:											#
		jr		$ra									# if no win then return to caller
													#
####################################################################################################
# function: invalid_play
# purpose: to raise an invalid play flag and return to caller
# registers used:
####################################################################################################
invalid_play:					#
	la	$a0, invalid_msg		# 
	li	$v0, 4					#
	syscall						# print invalid message
								#
	li	$v1, 1					# set invalid flag
								#
	jr $ra						# and return to caller
								#
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
	
	li	$t0, 0
	li	$t1, 0
	la	$t2, board_state
	reset_board:
		sw	$t0, 0($t2)
		
		addi	$t1, $t1, 1
		addi	$t2, $t2, 4
		bne		$t1, 42, reset_board
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
