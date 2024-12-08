.data
grid: .byte 32:42
border_1: .asciiz "| "
border_2: .asciiz " | "
interlayer: .asciiz " --- --- --- --- --- --- ---\n"
colNumber: .asciiz "  1   2   3   4   5   6   7\n"
enter: .asciiz "\n"
player1_piece: .asciiz "X"
player2_piece: .asciiz "O"
empty: .asciiz " "
text_welcome: .asciiz "---------->>>Welcome to the classic Connect 4 game!<<<----------\nIn this strategic and entertaining game, your goal is to be the first player to connect four of your patterned pieces in a row,\neither vertically, horizontally, or diagonally.\nThe rules are simple and easy to follow:\n1.  The game board is a 7-column by 6-row grid.\n2.  Each player selects a column number between 1 and 7 to place their piece.\n3.  The piece will drop from the top and stack at the bottom of the chosen column.\n4.  Players take turns until one player connects four pieces in a line horizontally, vertically, or diagonally, or until the\nboard is full and no player can make a connection of four pieces.\n\nNow, let's get the game started! Simply enter a number between 1 and 7 to choose the column where your patterned\npiece will be placed. Remember, strategy and timing are key to winning. Good luck!\n\n"
text_player1_turn: .asciiz "Player 1, it's your turn.\nSelect a column to play. Must be between 1 and 7.\nEnter a number: "
text_player2_turn: .asciiz "Player 2, it's your turn.\nSelect a column to play. Must be between 1 and 7.\nEnter a number: "
text_overRange: .asciiz "\nPlease enter an integer between 1 and 7!\nEnter a number: "
text_startConfirm: .asciiz "-----Press any button to start the game-----"
text_full: .asciiz "\nThis column is full, please change the column to add pieces!\nEnter a number: "
text_tie: .asciiz "------GAME OVER------\nThe game is tied!\n"
text_player1_win: .asciiz "------GAME OVER------\nCongratulations! Player 1 wins!\n"
text_player2_win: .asciiz "------GAME OVER------\nCongratulations! Player 2 wins!\n"

.text
.globl main


main:
	li $v0, 4					#Welcome message
	la $a0, text_welcome
	syscall
	jal display_board				#Display the chessboard
	li $s7, 0					#Set the total number of steps to 0
	j player1_turn					#Start with player 1's turn


#----------Check if the input value is out of range and if the target column is full----------
test_range:
	add $s0, $v0, $zero				#Stores the input value
	li $t0, 0
	li $t1, 8
	slt $t2, $s0, $t1
	beq $t2, $zero, error_overRange
	slt $t2, $t0, $s0
	beq $t2, $zero, error_overRange
	addi $s0, $s0, 34				#Move the position to the bottom row
	j test_full					#Check if the target column is full

test_full:
	lb $t0, grid($s0)
	lb $t1, empty
	beq $t0, $t1, test_piece			#Check if this position is empty
	addi $s0, $s0, -7				#Move the position up one row
	li $t1, -1
	slt $t1, $t1, $s0
	beq $t1, $zero, error_full			#Check if the top row has a piece
	j test_full
	
error_overRange:
	la $a0, text_overRange				#Error message
	li $v0, 4
	syscall
	li $v0, 5					#Reenter the number
	syscall
	j test_range
	
error_full:
	la $a0, text_full				#Error message
	li $v0, 4
	syscall
	li $v0, 5					#Reenter the number
	syscall
	j test_range


#----------Player turn----------
player1_turn:
	li $v0, 4
	la $a0, text_player1_turn			#Turn start message
	syscall
	li $s6, 1					#Set current turn is player 1 turn
	li $v0, 5					#Enter input values
	syscall
	j test_range
	
player2_turn:
	li $v0, 4
	la $a0, text_player2_turn			#Turn start message
	syscall
	li $s6, 2					#Set current turn is player 1 turn
	li $v0, 5					#Enter input values
	syscall
	j test_range
	
test_piece:
	li $t1, 1
	beq $s6, $t1, player1_add			#Jump to player 1 adds pieces
	j player2_add					#Jump to player 2 adds pieces
	
player1_add:
	lb $t0, player1_piece				#Load player 1's piece pattern
	sb $t0, grid($s0)				#Input into the chessboard
	addi $s7, $s7, 1				#Total number of steps plus 1
	jal display_board				#Display the chessboard
	lb $t0, player1_piece				#Load player 1's piece pattern
	j test_winCheck

player2_add:
	lb $t0, player2_piece				#Load player 2's piece pattern
	sb $t0, grid($s0)				#Input into the chessboard
	addi $s7, $s7, 1				#Total number of steps plus 1
	jal display_board				#Display the chessboard
	lb $t0, player2_piece				#Load player 2's piece pattern
	j test_winCheck



#----------Print chessboard----------
display_board:
	la $a0, enter					#Enter
	li $v0, 4
	syscall
	la $a0, colNumber				#Display number of columns
	li $v0, 4
	syscall
	add $t0, $zero, $zero				#Set the number of items $t0 to zero
while: 
	beq $t0, 42, back				#Iterate over each item
	la $a0, border_1				#Print left border
	li $v0, 4
	syscall
	add $t1, $zero, $zero				#Set the number of columns $t1 to 0
row: 
	beq $t1, 7, rowComplete				#Iterate over each columns
	lb $a0, grid($t0)				#Load the values in the chessboard
	li $v0, 11
	syscall
	la $a0, border_2				#Print the middle border
	li $v0, 4
	syscall
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j row
rowComplete:
	la $a0, enter					#Enter at the end of the row
	li $v0, 4
	syscall
	la $a0, interlayer				#Print interlayer
	li $v0, 4
	syscall
	j while 
back:
	jr $ra
	
							

#----------Check if the game is over----------			
test_winCheck:
	beq $s7, 42, exit_tie				#Tie or not (42 total steps)
	add $t2, $zero, $t0				#Set $t2 to be the chess piece pattern
	#Determine the horizontal direction of the piece
	add $t0, $zero, $zero
	add $s1, $s0, $zero
	jal test_rowNumber
	jal right
	addi $t0, $t0, -1
	add $s1, $s0, $zero
	jal left
	#Determine the vertical direction of the piece
	add $t0, $zero, $zero
	add $s1, $s0, $zero
	jal down
	addi $t0, $t0, -1
	add $s1, $s0, $zero
	jal up
	#Determine the top right and bottom left pieces	
	add $t0, $zero, $zero
	add $s1, $s0, $zero
	jal upper_left
	addi $t0, $t0, -1
	add $s1, $s0, $zero
	jal test_rowNumber
	jal lower_right
	#Determine the top left and bottom right pieces
	add $t0, $zero, $zero
	add $s1, $s0, $zero
	jal test_rowNumber
	jal upper_right
	addi $t0, $t0, -1
	add $s1, $s0, $zero
	jal test_rowNumber
	jal lower_left
	#Move on to the next turn
	beq $s6, 1, player2_turn
	beq $s6, 2, player1_turn

#Determine the number of rows in the current position $s1
test_rowNumber:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
	li $s5 6
	jal cal_rowEnd
	slt $t6, $s1, $s3
	beq $t6, 0, exit
	li $s5 5
	jal cal_rowEnd
	slt $t6, $s1, $s3
	beq $t6, 0, exit
	li $s5 4
	jal cal_rowEnd
	slt $t6, $s1, $s3
	beq $t6, 0, exit
	li $s5 3
	jal cal_rowEnd
	slt $t6, $s1, $s3
	beq $t6, 0, exit
	li $s5 2
	jal cal_rowEnd
	slt $t6, $s1, $s3
	beq $t6, 0, exit
	li $s5 1
	jal cal_rowEnd
	slt $t6, $s1, $s3
	beq $t6, 0, exit
	
exit:
	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	jr $ra

#Determine the start index and end index of the row which $s1 is in
cal_rowEnd:
	li $t6, 7
	mul $s4, $s5, $t6
	addi $s3, $s4, -7
	addi $s4, $s4, -1
	jr $ra
	
right:
	li $t5, 1
	addi $t1, $s4, 1
	j checkLoop_horizontal
	
left:
	li $t5, -1
	addi $t1, $s3, -1
	j checkLoop_horizontal
	
down:
	li $t5, 7
	j checkLoop_vertical
	
up:	
	li $t5, -7
	j checkLoop_vertical
	
upper_left:
	li $t5, -8
	li $t7, -1
	j checkLoop_diagonal

lower_right:
	li $t5, 8
	li $t7, 1
	j checkLoop_diagonal
	
upper_right:
	li $t5, -6
	li $t7, -1
	j checkLoop_diagonal

lower_left:
	li $t5, 6
	li $t7, 1
	j checkLoop_diagonal

checkLoop_horizontal:
	beq $t0, 4, exit_win				#Determine if there are four pieces connected in a line
	beq $s1, $t1, noWin				#Determine if it is beyond the side bondary
	lb $t4, grid($s1)
	bne $t2, $t4, noWin				#Determines if it is a piece of the same player
	addi $t0, $t0, 1				#The number of pieces connected in a row plus 1
	add $s1, $s1, $t5				#The current position $s1 changes
	j checkLoop_horizontal
	
checkLoop_vertical:
	beq $t0, 4, exit_win				#Determine if there are four pieces connected in a line
	li $t1, 42					#Determine if it is beyond the bottom bondary
	slt $t3, $t1, $s1
	beq $t3, 1, noWin
	li $t1, -1					#Determine if it is beyond the top bondary
	slt $t3, $t1, $s1
	beq $t3, 0, noWin
	lb $t4, grid($s1)
	bne $t2, $t4, noWin				#Determines if it is a piece of the same player	
	addi $t0, $t0, 1				#The number of pieces connected in a row plus 1
	add $s1, $s1, $t5				#The current position $s1 changes
	j checkLoop_vertical
	
checkLoop_diagonal:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
	beq $t0, 4, exit_win				#Determine if there are four pieces connected in a line
	jal cal_rowEnd					#Gets the start index and end index at the current position
	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	slt $t6, $s1, $s3				#Determine if it is beyond left side bondary
	beq $t6, 1, noWin
	slt $t6, $s4, $s1				#Determine if it is beyond right side bondary
	beq $t6, 1, noWin
	li $t3, 1
	slt $t6, $s5, $t3				#Determine if it is beyond top side bondary
	beq $t6, 1, noWin
	li $t3, 6
	slt $t6, $t3, $s5				#Determine if it is beyond bottom side bondary
	beq $t6, 1, noWin
	lb $t4, grid($s1)
	bne $t2, $t4, noWin				#Determines if it is a piece of the same player
	addi $t0, $t0, 1				#The number of pieces connected in a row plus 1
	add $s1, $s1, $t5				#The current position $s1 changes
	add $s5, $s5, $t7				#row number change
	j checkLoop_diagonal
	
noWin:
	jr $ra

#Determine who win
exit_win:
	beq $s6, 1, exit_player1Win
	beq $s6, 2, exit_player2Win
	
exit_player1Win:
	li $v0, 4
	la $a0, text_player1_win
	syscall
	li $v0, 10
	syscall
	
exit_player2Win:
	li $v0, 4
	la $a0, text_player2_win
	syscall
	li $v0, 10
	syscall
	
exit_tie:
	li $v0, 4
	la $a0, text_tie
	syscall
	li $v0, 10
	syscall
	
	
	
	
	
	
	
