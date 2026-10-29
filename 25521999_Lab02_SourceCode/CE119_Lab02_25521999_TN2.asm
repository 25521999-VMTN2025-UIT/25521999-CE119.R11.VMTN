.data
diem_T1:    .word 4, 1, 6, 7, 0, 3, 5, 0, 4, 7, 2, 1
diem_T2:    .word 10
diem_T3:    .word 4, 4, 4, 4, 4
grade_tab:  .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3
            .align 2 # Dung de can le cho hist
hist:    .word 0, 0, 0, 0
nho_nhat:   .asciiz "min="
lon_nhat:   .asciiz " max="
nhom_g0:    .asciiz "g0="
nhom_g1:    .asciiz " g1="
nhom_g2:    .asciiz " g2="
nhom_g3:    .asciiz " g3="

.text
# Thanh ghi duoc xai trong chuong trinh:
# $s0: dia chi mang diem, $s1: so phan tu.
# $s2: diem nho nhat; $s3: diem lon nhat; $s4: dia chi hist.
main:
    # Load tuy y ba bo so lieu khac nhau T1,T2,T3 
    la   $s0, diem_T1
    li   $s1, 12
    la   $s4, hist

    # Tim min, max.
    move $a0, $s0
    move $a1, $s1
    jal  stats

    move $s2, $v0    # Luu vao mem $s2 min
    move $s3, $v1    # Luu vao mem $s3 max

    # Dem so diem thuoc moi nhom.
    move $a0, $s0
    move $a1, $s1
    la   $a2, grade_tab
    move $a3, $s4
    jal  histogram

    # Xuat ra man hinh min=... max=...
    la   $a0, nho_nhat
    li   $v0, 4
    syscall
    move $a0, $s2
    li   $v0, 1
    syscall
    la   $a0, lon_nhat
    li   $v0, 4
    syscall
    move $a0, $s3
    li   $v0, 1
    syscall
    li   $a0, 10                  # Ky tu xuong dong
    li   $v0, 11
    syscall

    # XUat ra man hinh g0=... g1=... g2=... g3=...
    la   $a0, nhom_g0
    li   $v0, 4
    syscall
    lw   $a0, 0($s4)
    li   $v0, 1
    syscall
    la   $a0, nhom_g1
    li   $v0, 4
    syscall
    lw   $a0, 4($s4)
    li   $v0, 1
    syscall
    la   $a0, nhom_g2
    li   $v0, 4
    syscall
    lw   $a0, 8($s4)
    li   $v0, 1
    syscall
    la   $a0, nhom_g3
    li   $v0, 4
    syscall
    lw   $a0, 12($s4)
    li   $v0, 1
    syscall
    li   $a0, 10
    li   $v0, 11
    syscall

    li   $v0, 10
    syscall

# Thu tuc stats
# $a0 = dia chi mang diem, $a1 = n.
# $v0 = min, $v1 = max.
# $t0 = diem dang xet; $t1 = thanh ghi tam luu ket qua beq 
# $a0 tang 4 sau moi phan tu; $a1 dem so phan tu con lai.
stats:
    lw   $v0, 0($a0)             # Lay phan tu dau lam min 
    move $v1, $v0                # Lay phan tu dau lam max
    addi $a0, $a0, 4             
    addi $a1, $a1, -1

stats_loop:
    beq  $a1, $zero, stats_xong  # if(a1=0) -> done
    lw   $t0, 0($a0)             # $t0 = arr[i]

    slt  $t1, $t0, $v0           # diem dang xet < min? 
    beq  $t1, $zero, stats_max_check
    move $v0, $t0                # cap nhat min

stats_max_check:
    slt  $t1, $v1, $t0           # max < diem dang xet?
    beq  $t1, $zero, stats_update
    move $v1, $t0                # cap nhat max

stats_update:
    addi $a0, $a0, 4
    addi $a1, $a1, -1
    j    stats_loop

stats_xong:
    jr   $ra


# histogram: xoa 4 bo dem, roi tra bang de dem.
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


