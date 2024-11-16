				.data
welcome_msg:	.asciiz "\nWelcome to Connect Four. Let's start a two player game..."
plyr_1_prmtp:	.asciiz "\nPlayer 1 select a column [1-7] > "
plyr_2_prmtp:	.asciiz "\nPlayer 2 select a column [1-7] > "
repeat_msg:		.asciiz "\nGo again? Y/N > "
invalid_msg:	.asciiz "\nInvalid input. Try again!\n"
bye: 			.asciiz "Toodles! ;)"

row_1_view:		.asciiz "|*|*|*|*|*|*|*|"
row_2_view:		.asciiz "|*|*|*|*|*|*|*|"
row_3_view:		.asciiz "|*|*|*|*|*|*|*|"
row_4_view:		.asciiz "|*|*|*|*|*|*|*|"
row_5_view:		.asciiz "|*|*|*|*|*|*|*|"
row_6_view:		.asciiz "|*|*|*|*|*|*|*|"
bottom:			.asciiz "|1|2|3|4|5|6|7|"

				.align	2
row_1_state:	.word	0, 0, 0, 0, 0, 0, 0
row_2_state:	.word	0, 0, 0, 0, 0, 0, 0
row_3_state:	.word	0, 0, 0, 0, 0, 0, 0
row_4_state:	.word	0, 0, 0, 0, 0, 0, 0
row_5_state:	.word	0, 0, 0, 0, 0, 0, 0
row_6_state:	.word	0, 0, 0, 0, 0, 0, 0

buffer:			.space	2


