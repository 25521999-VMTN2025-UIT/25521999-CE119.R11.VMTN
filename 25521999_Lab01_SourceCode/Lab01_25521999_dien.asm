# Chu thich cac thanh ghi
# $s0 : chua input X (kWh)
# $s1 : chua tien dien dua tren luong dien X da su dung (dong)
# $s2 : chua can duoi cua bac dien hien tai
# $s3 : con tro tren mang nguong cua bac dien
# $s4 : con tro tren mang don gia dien

.data
.align 2 # can chinh theo 4 byte , du lieu se duọc luu theo kieu word(4byte)
nguongDien: .word 50, 100, 200, 300, 400, 9999
donGiaDien: .word 1780, 1840, 2130, 2680, 3030, 3180

nhap: .asciiz "Nhap so kWh (0...9999): "
nhapLoi: .asciiz "Gia tri khong hop le, nhap lai.\n"
ketQua: .asciiz "Tien dien: "
donVi: .asciiz " dong\n"

.text
main:
nhapLai:
	la $a0, nhap
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	move $s0, $v0
	
	sltiu $t0, $s0, 10000
	bne $t0, $0, nhapDung
	
	la $a0, nhapLoi
	li $v0, 4 
	syscall
	
	j nhapLai

nhapDung:

	li $s1, 0
	li $s2, 0
	la $s3, nguongDien
	la $s4, donGiaDien
	
tinhCacBacDau:
	lw $t0, 0($s3) 
	lw $t1, 0($s4)
	# Kiem tra co phai la bac cuoi chua
	slt $t2, $t0, $s0
	beq $t2, $zero, tinhBacCuoi
	
	#Cong tien dien bac hien tai
	subu $t3, $t0, $s2
	mul $t4, $t3, $t1
	addu $s1, $s1, $t4
	
	move $s2, $t0 # $s2 = $t0 , tang can duoi len thanh can duoi cua nguong tiep theo
	addiu $s3, $s3, 4 # pointer = pointer + 4 byte
	addiu $s4, $s4, 4 # pointer = pointer + 4 byte

	j tinhCacBacDau
tinhBacCuoi:
	#Tinh tien dien bac cuoi
	subu $t3, $s0, $s2
	mul $t4, $t3, $t1
	addu $s1, $s1, $t4
	
	la $a0, ketQua
	li $v0, 4
	syscall
	
	move $a0, $s1
	li $v0, 1
	syscall
	
    	la $a0, donVi
    	li $v0, 4
   	syscall
	
	li $v0, 10
	syscall
	
	