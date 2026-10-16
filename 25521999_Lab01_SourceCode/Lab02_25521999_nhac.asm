# MSSV: 25521999
# a = 9, b= 9

# Dich cao do : 9 nua cung
# Mot donn vi nhip: 240ms
# Nhac cu: 24
# Am luong: 100

# Chu thich cac thanh ghi
# $s0: con tro mang cao do not
# $s1: con tro mang do dai not
# $s2: so not con lai cua ban nhac
# $s3: tong thoi luong du kien (ms)
# $s4: thoi diem bat dau
# $s5: cao do thuc (sau khi +a) cua not hien tai
# $s6: thoi luong not hien tai (ms)
# $s7: thoi gian do duoc (ms)

.data
.align 2

caoDoNot: .word 64,64,65,67,67,65,64,62,60,60,62,64,64,62,62
doDaiNot: .word 2,2,2,2,2,2,2,2,2,2,2,2,3,1,4
soNot: .word 15

dauCach: .asciiz " " 
xuongDong: .asciiz "\n"
thongBaoThoiGianDuKien: .asciiz "Tong du kien (ms): "
thongBaoThoiGianDoDuoc: .asciiz "Thoi gian do duoc (ms): "

.text
main:

	# Khoi tao gia tri cac thanh ghi cao do, do dai, so not 
	la $s0, caoDoNot
	la $s1, doDaiNot
	lw $s2, soNot
	
	# Khoi tao tong thoi luong du kien
	li $s3, 0
	
	# Lay thoi diem bat dau
	li $v0, 30
	syscall
	move $s4, $a0
	
	
phatNhac:
	# Dieu kien that vong lap
	beq $s2, $zero, phatNhacXong
	
	#Cao do va thoi luong not
	lw $s5, 0($s0)
	addiu $s5, $s5, 9
	
	lw $s6, 0($s1)
	li $t0, 240
	mul $s6, $s6, 240
	
	#Cap nhat vao tong thoi luong du kien
	addu $s3, $s3, $s6
	
	# In ra cao do, thoi luong
	move $a0, $s5
	li $v0, 1
	syscall
	
	la $a0, dauCach
	li $v0, 4
	syscall
	
	move $a0, $s6
	li $v0, 1
	syscall

	la $a0, xuongDong
	li $v0, 4
	syscall
	
	# Phat not nhac MIDI
	move $a0, $s5
	move $a1, $s6
	li $a2, 24
	li $a3, 100
	
	li $v0, 33
	syscall

	
	
	#Tro den phan tu tiep theo cua hai mang
	addiu $s0, $s0, 4
	addiu $s1, $s1, 4
	#Giam so not
	addiu $s2, $s2, -1
	
	j phatNhac
	
phatNhacXong:
	# Lay thoi diem keet thuc
	li $v0, 30
	syscall
	
	# Thoi gian do duoc 
	subu $s7, $a0, $s4
	
	# In thoi luong du kien
	la $a0, thongBaoThoiGianDuKien
	li $v0, 4
	syscall
	
	move $a0, $s3
	li $v0, 1
	syscall
	
	la $a0, xuongDong
	li $v0, 4
	syscall
	
	#In thoi gian do duoc thuc te
	la $a0, thongBaoThoiGianDoDuoc
	li $v0, 4
	syscall
	
	move $a0, $s7
	li $v0, 1
	syscall
	
	la $a0, xuongDong
	li $v0, 4
	syscall
	
	#Ket thuc chuong trinh
	li $v0, 10
	syscall
	
		

