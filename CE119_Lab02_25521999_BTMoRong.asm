.data
diem_T1:    .word 4, 1, 6, 7, 0, 3, 5, 0, 4, 7, 2, 1
grade_tab:  .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3
            .align 2 # Dung de can le cho hist
hist:    .word 0, 0, 0, 0
hai_cham:   .asciiz ": "

.text
# Thanh ghi duoc xai trong chuong trinh:
# $s0: dia chi mang diem, $s1: so phan tu.
# $s4: dia chi hist.
main:
    la   $s0, diem_T1
    li   $s1, 12
    la   $s4, hist

    # Dem so diem thuoc moi nhom.
    move $a0, $s0
    move $a1, $s1
    la   $a2, grade_tab
    move $a3, $s4
    jal  histogram

    # Xuat ra man hinh bieu do g0, g1, g2, g3.
    move $a0, $s4
    li   $a1, 4
    jal  draw_hist

    li   $v0, 10
    syscall

# histogram: xoa 4 bo dem, 
# $a0 = mang diem, $a1 = n ,
# $a2 = grade_tab, $a3 = con tro chua dia chi dau mang hist. 
# $t0 = diem dang xet; $t1 = offset goc cua nhom thong qua tra grade_tab[diem].
# $t2 = offset nhom * 4.
# $t3 = con tro dia chi hist[nhom]; $t4 = gia tri hien tai  cua bo dem.

histogram:
    #Reset $a3 
    sw   $zero, 0($a3)
    sw   $zero, 4($a3)
    sw   $zero, 8($a3)
    sw   $zero, 12($a3)
    beq  $a1, $zero, dem_nhom_xong

dem_nhom_lap:
    lw   $t0, 0($a0)                # Load phan tu thu i ra        
    add  $t1, $a2, $t0              # t1 = grade_tab[$t0]
    lbu  $t2, 0($t1)                # load byte dau t1 vao t2
    sll  $t2, $t2, 2                # t1 = {0,1,2,3} -> t2 = {0,4,8,12}
    add  $t3, $a3, $t2              # t3 = hist[t2]
    lw   $t4, 0($t3)                # doc ra gia tri hien tai roi tang 1 roi ghi lai vao $t3 tuc $a3 tuc $s4
    addi $t4, $t4, 1
    sw   $t4, 0($t3)                 
    addi $a0, $a0, 4                # Xet phan tu tiep theo
    addi $a1, $a1, -1               # Giam so phan tu can dem
    bne  $a1, $zero, dem_nhom_lap   # Kiem tra the thoat loop

dem_nhom_xong:
    jr   $ra

# draw_hist:
# $a0 = dia chi hist, $a1 = so nhom (4).
# $t0 = dia chi bo dem nhom dang in; $t1 = so nhom con lai.
# $t2 = chi so nhom (0, 1, 2, 3); $t3 = so ky tu | con phai in.

draw_hist:
    move $t0, $a0
    move $t1, $a1
    move $t2, $zero

in_nhom:
    beq  $t1, $zero, hoan_thanh
    lw   $t3, 0($t0)

    li   $a0, 103                 # In "g"
    li   $v0, 11
    syscall
    move $a0, $t2                 # In chi so nhom
    li   $v0, 1
    syscall
    la   $a0, hai_cham            # In ": "
    li   $v0, 4
    syscall

ve:
    beq  $t3, $zero, het_nhom_hien_tai 
    li   $a0, 124                 # In  "|"
    li   $v0, 11
    syscall
    addi $t3, $t3, -1             # Kiem tra coi het chua
    j    ve

het_nhom_hien_tai:
    li   $a0, 10
    li   $v0, 11
    syscall
    addi $t0, $t0, 4              # Sang bo dem ke tiep
    addi $t1, $t1, -1
    addi $t2, $t2, 1
    j    in_nhom

hoan_thanh:
    jr   $ra
