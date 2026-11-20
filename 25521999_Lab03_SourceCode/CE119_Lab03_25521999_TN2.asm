# Danh sach thanh ghi:
# $s0: chua con tro duyet, ban dau la dia chi string
# $s1: chua vi tri dau cua tu hien tai dang xet
# $s2: dia chi byte 0 o cuoi chuoi
# $ra: thanh ghi chua dia chi quay ve sau loi goi thu tuc

.data
chuoi1:  .asciiz "kien truc may tinh"
chuoi2:  .asciiz "mips"
chuoi3:  .asciiz ""
chuoi4:  .asciiz "a bc def"
chuoi5:  .asciiz "mot lenh jr tra quyen ve noi goi"
gach:    .asciiz "|"
xuongDong:   .asciiz "|\n"

.text
main:

        la    $a0, chuoi1
        jal   reverse_words
        la    $a0, gach
        li    $v0, 4
        syscall
        la    $a0, chuoi1
        syscall
        la    $a0, xuongDong
        syscall

        la    $a0, chuoi2
        jal   reverse_words
        la    $a0, gach
        li    $v0, 4
        syscall
        la    $a0, chuoi2
        syscall
        la    $a0, xuongDong
        syscall

        la    $a0, chuoi3
        jal   reverse_words
        la    $a0, gach
        li    $v0, 4
        syscall
        la    $a0, chuoi3
        syscall
        la    $a0, xuongDong
        syscall

        la    $a0, chuoi4
        jal   reverse_words
        la    $a0, gach
        li    $v0, 4
        syscall
        la    $a0, chuoi4
        syscall
        la    $a0, xuongDong
        syscall

        la    $a0, chuoi5
        jal   reverse_words
        la    $a0, gach
        li    $v0, 4
        syscall
        la    $a0, chuoi5
        syscall
        la    $a0, xuongDong
        syscall

        li    $v0, 10
        syscall

# Leaf procedure strlen: dem so byte truoc khi gap byte 0.
# Tham so: $a0 = dia chi ASCIIZ string. Tra ve: $v0 = length.
# Thanh ghi: $v0, $t0, $t1. 

strlen:
        move  $t0, $a0
        move  $v0, $zero
len_loop:
        lbu   $t1, 0($t0)
        beq   $t1, $zero, len_done
        addi  $v0, $v0, 1
        addi  $t0, $t0, 1
        j     len_loop
len_done:
        jr    $ra


# Leaf procedure rev_range: dao toan doan [$a0, $a1] tai cho.
# Tham so: $a0 = dia chi ASCIIZ string, $a1 = dia chi cuoi. Tra ve: Khong
# Thanh ghi: $t0-$t4. $a0, $a1 giu nguyen.

rev_range:
        move  $t0, $a0
        move  $t1, $a1
rr_loop:
        sltu  $t2, $t0, $t1
        beq   $t2, $zero, rr_done
        lbu   $t3, 0($t0)
        lbu   $t4, 0($t1)
        sb    $t4, 0($t0)
        sb    $t3, 0($t1)
        addi  $t0, $t0, 1
        addi  $t1, $t1, -1
        j     rr_loop
rr_done:
        jr    $ra

# reverse_words: dao toan bo chuoi, roi dao lai tung tu.
# Tham so: $a0 = dia chi ASCIIZ string. Tra ve: string da duoc dao.
# Thanh ghi: $a0, $a1, $v0, $t0-$t4, $s0-$s2, $ra, $sp.
# $s0 = con tro duyet chuoi; $s1 = con tro o dau tung tu; $s2 = dia chi byte 0 ket thuc chuoi.
# Khung 16 bytes: 0=$s2, 4=$s1, 8=$s0, 12=$ra.

reverse_words:
        addi  $sp, $sp, -16
        sw    $ra, 12($sp)
        sw    $s0, 8($sp)
        sw    $s1, 4($sp)
        sw    $s2, 0($sp)

        move  $s0, $a0
        jal   strlen
        addu  $s2, $s0, $v0

        beq   $v0, $zero, rw_done     #if strlen(s) == 0 -> return 

        move  $a0, $s0                
        addi  $a1, $s2, -1
        jal   rev_range
        
        move  $s1, $s0
rw_scan:
        sltu  $t0, $s0, $s2
        beq   $t0, $zero, rw_last
        lbu   $t0, 0($s0)
        addi  $t1, $0, 32
        bne   $t0, $t1, rw_next     # ($t0 == " ")? rev_range : rw_next
        move  $a0, $s1
        addi  $a1, $s0, -1
        jal   rev_range
        addi  $s1, $s0, 1
rw_next:
        addi  $s0, $s0, 1
        j     rw_scan
rw_last:
        move  $a0, $s1
        addi  $a1, $s2, -1
        jal   rev_range
rw_done:
        lw    $s2, 0($sp)
        lw    $s1, 4($sp)
        lw    $s0, 8($sp)
        lw    $ra, 12($sp)
        addi  $sp, $sp, 16
        jr    $ra
