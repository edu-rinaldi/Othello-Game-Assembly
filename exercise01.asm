.data
grid: .byte ' ':65
coords: .space 6
patta: .asciiz "PATTA\n"
nero: .asciiz "STA VINCENDO IL NERO\n"
bianco: .asciiz "STA VINCENDO IL BIANCO\n"
error: .asciiz "MOSSA ERRATA\n"
.text
.globl main

#---------- MACRO ----------

.macro printString(%strAddr)	#print stringa %strAddr = string address
	la $a0, %strAddr
	li $v0, 4
	syscall
	.end_macro

.macro printIntegerImmediate(%val)	#print integer from Immediate value
	li $a0, %val
	li $v0, 1
	syscall
	.end_macro
.macro printIntegerReg(%val)	 	#print integer from Register value
	add $a0, $a0, %val
	li $v0, 1
	syscall
	.end_macro

.macro printChar(%c)
	li $a0, %c
	li $v0, 11
	syscall
	.end_macro

.macro getVal(%mat, %i,%j)
	# mat = matrix address
	# i = row index
	# j = column index
	li $v0, 0
	#(8*i)+j
	sll $t0, %i, 3
	add $t0, $t0, %j
	
	lb $v0, %mat($t0)
	
	.end_macro

.macro insertValReg(%mat, %i, %j, %val)
	# mat = matrix address
	# i = row index
	# j = column index
	# val = value to insert
	
	# (8*i)+j	
	sll $t4, %i, 3
	add $t4, $t4, %j
	
	sb %val, %mat($t4)	# insert value in matAddress[i][j]
	li $t4, 0
	.end_macro

.macro insertVal(%mat,%i,%j,%val)
	# mat = matrix address
	# i = row index (immediate)
	# j = column index (immediate)
	# val = value to insert (immediate)
	
	# store i in $t0 register
	li $t0, %i
	# (8*i)+j	
	sll $t0, $t0, 3
	addi $t0, $t0, %j
	
	li $t1, %val		#store value in $t1
	sb $t1, %mat($t0)	# insert value in matAddress[i][j]
	.end_macro
	
.macro printCharMat(%mat,%i,%j)
	# mat = matrix address
	# i = row index (immediate)
	# j = column index (immediate)
	
	# store i in $t0 register
	li $t0, %i
	
	# (8*i)+j	
	sll $t0, $t0, 3
	addi $t0, $t0, %j
	
	# a0 <- mat[i][j]
	lb $a0, %mat($t0)
	li $v0, 11
	syscall
	.end_macro

.macro printMatrix(%mat)
	printChar('|')
	printCharMat(%mat,0,0)
	printCharMat(%mat,0,1)
	printCharMat(%mat,0,2)
	printCharMat(%mat,0,3)
	printCharMat(%mat,0,4)
	printCharMat(%mat,0,5)
	printCharMat(%mat,0,6)
	printCharMat(%mat,0,7)
	printChar('|')
	printChar('\n')
	printChar('|')
	printCharMat(%mat,1,0)
	printCharMat(%mat,1,1)
	printCharMat(%mat,1,2)
	printCharMat(%mat,1,3)
	printCharMat(%mat,1,4)
	printCharMat(%mat,1,5)
	printCharMat(%mat,1,6)
	printCharMat(%mat,1,7)
	printChar('|')
	printChar('\n')
	printChar('|')
	printCharMat(%mat,2,0)
	printCharMat(%mat,2,1)
	printCharMat(%mat,2,2)
	printCharMat(%mat,2,3)
	printCharMat(%mat,2,4)
	printCharMat(%mat,2,5)
	printCharMat(%mat,2,6)
	printCharMat(%mat,2,7)
	printChar('|')
	printChar('\n')
	printChar('|')
	printCharMat(%mat,3,0)
	printCharMat(%mat,3,1)
	printCharMat(%mat,3,2)
	printCharMat(%mat,3,3)
	printCharMat(%mat,3,4)
	printCharMat(%mat,3,5)
	printCharMat(%mat,3,6)
	printCharMat(%mat,3,7)
	printChar('|')
	printChar('\n')
	printChar('|')
	printCharMat(%mat,4,0)
	printCharMat(%mat,4,1)
	printCharMat(%mat,4,2)
	printCharMat(%mat,4,3)
	printCharMat(%mat,4,4)
	printCharMat(%mat,4,5)
	printCharMat(%mat,4,6)
	printCharMat(%mat,4,7)
	printChar('|')
	printChar('\n')
	printChar('|')
	printCharMat(%mat,5,0)
	printCharMat(%mat,5,1)
	printCharMat(%mat,5,2)
	printCharMat(%mat,5,3)
	printCharMat(%mat,5,4)
	printCharMat(%mat,5,5)
	printCharMat(%mat,5,6)
	printCharMat(%mat,5,7)
	printChar('|')
	printChar('\n')
	printChar('|')
	printCharMat(%mat,6,0)
	printCharMat(%mat,6,1)
	printCharMat(%mat,6,2)
	printCharMat(%mat,6,3)
	printCharMat(%mat,6,4)
	printCharMat(%mat,6,5)
	printCharMat(%mat,6,6)
	printCharMat(%mat,6,7)
	printChar('|')
	printChar('\n')
	printChar('|')
	printCharMat(%mat,7,0)
	printCharMat(%mat,7,1)
	printCharMat(%mat,7,2)
	printCharMat(%mat,7,3)
	printCharMat(%mat,7,4)
	printCharMat(%mat,7,5)
	printCharMat(%mat,7,6)
	printCharMat(%mat,7,7)
	printChar('|')
	printChar('\n')
	printChar('\n')
	.end_macro
	

.macro initGame(%mat)
	#insert B
	insertVal(%mat,3,3,'B')
	insertVal(%mat,4,4,'B')
	#insert N
	insertVal(%mat,3,4,'N')
	insertVal(%mat,4,3,'N')
	insertVal(%mat,8,0,0)
	.end_macro
	
	
.macro inside(%x,%y)
	li $v0, 0
	bltz %x, endInside
	bge %x, 8, endInside
	bltz %y, endInside
	bge %y, 8, endInside
	li $v0, 1
	endInside:
	 
	.end_macro
	

.macro countNB(%g,%n,%b)
	la $s5, %g
	li %n, 0 #count n
	li %b, 0 #count b
	countp:
	lb $t5, ($s5)
	beqz $t5,  endCountp
	bne $t5, 'N',checkB
	addi %n, %n, 1
	j noOne
	checkB:
	bne $t5, 'B', noOne
	addi %b, %b, 1
	j noOne
	noOne:
	addi $s5, $s5, 1
	j countp
	endCountp:
	.end_macro

#---------- END MACROS ----------

#---------- FUNCTIONS ----------

# a0= x   a1= y   a2= player
checkCoords:
	getVal(grid,$a1,$a0)
	bne $v0, ' ', endCheckCoords
	
	#for i=-1 to 1, for j=-1 to 1
	#a3 = i    t1 = j
	
	li $a3, -1
	li $t1, -1
	ICicle:
	beq $a3, 2, endCheckCoords
	JCicle:
	beq $t1, 2, endJCicle
	
	bnez $a3, continueCheck
	bnez $t1, continueCheck
	addi $t1, $t1, 1
	
	continueCheck:
	#store on stack
	subi $sp, $sp, 4
	sw $ra, ($sp)
	
	jal checkRecursive
	
	#restore from stack
	lw $ra, ($sp)
	addi $sp, $sp, 4
	addi $t1, $t1, 1
	j JCicle
	endJCicle:
	li $t1, -1
	addi $a3, $a3, 1
	j ICicle
	endCheckCoords:
		jr $ra	
# a0= x   a1= y   a2=p    a3= i   t1 = j
checkRecursive:
	add $t2, $a0, $t1	#t2 = x+j
	add $t3, $a1, $a3	#t3 = y+i
	
	#if not inside(x+j,y+i) or g[y+i][x+j] == ' ': return False
	inside($t2,$t3)		
	beq $v0, 1, otherControlBeforeCheckRecursive
	li $v1, 0
	jr $ra
	otherControlBeforeCheckRecursive:
	getVal(grid,$t3,$t2)
	bne $v0, ' ', otherControlCheckRecursive
	li $v1, 0
	jr $ra
	otherControlCheckRecursive:
	#if g[y+i][x+j] == p: return True
	getVal(grid,$t3,$t2)
	bne $v0, $a2, ControlCheckRecursive
	li $v1, 1
	jr $ra
	ControlCheckRecursive:
	
	#store on stack
	subi $sp, $sp, 20
	sw $a0, ($sp)
	sw $a1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $ra, 16($sp)
	
	#new params
	add $a0, $t2, $zero	#x+j
	add $a1, $t3, $zero	#y+i
	
	jal checkRecursive
	
	#restore from stack
	lw $a0, ($sp)
	lw $a1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	
	beqz $v1, endCheckRecursive
	li $s2, 1			#flag = True
	insertValReg(grid,$a1,$a0,$a2)	#g[y][x] = p
	insertValReg(grid,$t3,$t2,$a2)	#g[y+i][x+j] = p
	li $v1, 1			#return true
	jr $ra
	
	endCheckRecursive:
		li $v1, 0		#return false
		jr $ra
	

	

main:
	
	#initialize game
	initGame(grid)
	printMatrix(grid)
	
	#initialize vars
	li $s0, 1	#exit condition
	li $s1, 'N'	#init player (Nero)
	startGame:
	beq $s0, $zero, endGame
	
	#initialize flag
	li $s2, 0
	
	# read string in input
	la $a0, coords
	li $a1, 6
	li $v0, 8
	syscall
	
	#is stop?
	lb $t0, coords
	beq $t0, 'S', endGame
	
	# x = coords[0] - 97
	lb $s3, coords($zero)
	subi $s3, $s3, 97
	
	# y = coords[1] - 48
	lb $s4, coords($s0)
	subi $s4, $s4, 49
	

	#insertValReg
	add $a0, $s3, $zero
	add $a1, $s4, $zero
	add $a2, $s1, $zero
	jal checkCoords
	
	# N || B ?
	bne $s2, 1, printMossaNonValida
	beq $s1, 'N', toWhite
	li $s1, 'N'
	j printMatrixx
	toWhite:
	li $s1, 'B'
	
	printMatrixx:
	printMatrix(grid)
	j startGame
	printMossaNonValida:
	#printMatrix(grid)
	la $a0, error
	li $v0, 4
	syscall
	j startGame
	
	
	
	 
	
	endGame:
	countNB(grid, $s6, $s7)
	beq $s6, $s7, pattaGame
	bgt $s6, $s7, nWin

	#vince bianco
	la $a0, bianco
	li $v0, 4
	syscall
	j end
	nWin:
	la $a0, nero
	li $v0, 4
	syscall
	j end
	pattaGame:
	la $a0, patta
	li $v0, 4
	syscall
	end:
	li $v0, 10
	syscall
	



