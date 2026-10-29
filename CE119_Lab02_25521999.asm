.data
w1:  .word 0x8A7B6C5D
b1:  .byte -128, 127, -1
     .align 2
w2:  .word 1
s1:  .asciiz "IT012"

    .align 2
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

chuoi_1:    .asciiz "(a+b)*[c-{d/e}]"          
chuoi_2:    .asciiz "f(x[i]{j}))"             
chuoi_3:    .asciiz "{[(])}"                  
chuoi_4:    .asciiz "((a)"                    
chuoi_5:    .asciiz ""                         
chuoi_6:    .asciiz "no brackets here"         
chuoi_7:    .asciiz "]"                       
chuoi_P:    .asciiz "([{([{([{([{}])}])}])}])"  
nhan_vi_tri: .asciiz "vi_tri="
nhan_ma_loi: .asciiz " ma_loi="

hai_cham:   .asciiz ": "

.text
# Thanh ghi duoc xai trong chuong trinh:
# $s0: dia chi mang diem, $s1: so phan tu.
# $s2: diem nho nhat; $s3: diem lon nhat; $s4: dia chi hist.
main:
    la   $s0, w1
    lw   $t0, 0($s0)      # (a)
    lb   $t0, 0($s0)      # (b)
    lb   $t0, 3($s0)      # (c)
    lbu  $t0, 3($s0)      # (d)
    lb   $t0, 4($s0)      # (e)
    lbu  $t0, 4($s0)      # (f)
    lw   $t0, 4($s0)      # (g)
    li   $t1, 0xAB
    sb   $t1, 1($s0)      # (h)
    lw   $t0, 0($s0)      # (i)

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

# Thanh ghi trong chuong trinh chinh:
# $a0: dia chi chuoi truyen vao thu tuc, sau do la tham so in.
# $s0: luu vi tri tra ve; $s1: luu ma loi tra ve.
# $v0: vi tri tra ve hoac ma syscall; $v1: ma loi tra ve.
    # Doi chuoi load vao $a0 de check cho cac tinh huong khac 
    la   $a0, chuoi_P
    jal  check_brackets

sau_kiem_tra:                     
    move $s0, $v0
    move $s1, $v1

    la   $a0, nhan_vi_tri
    li   $v0, 4
    syscall
    move $a0, $s0
    li   $v0, 1
    syscall

    la   $a0, nhan_ma_loi
    li   $v0, 4
    syscall
    move $a0, $s1
    li   $v0, 1
    syscall
    
    li   $a0, 10
    li   $v0, 11
    syscall

# Thanh ghi duoc xai trong chuong trinh:
# $s0: dia chi mang diem, $s1: so phan tu.
# $s4: dia chi hist.
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

# check_brackets: duyet chuoi tu trai sang phai.
# Input: $a0 chuoi dau vao / Output: $v0 = vi tri, $v1 = ma loi

# Quy uoc thanh ghi:
# $t0: dia chi ky tu dang xet; $t1: vi tri ky tu dang xet.
# $t2: ma ASCII ky tu dang xet; $t3: ma ASCII de so sanh.
# $t4: ngoac mo can co de khop voi ngoac dong dang xet.
# $t5: ngoac mo lay tu dinh ngan xep.
# $t9: moc $sp ban dau, giu nguyen den khi tra ve.
# $sp: dinh ngan xep, moi ngoac mo chiem 1 word (4 byte).
# Moi duong thoat deu khoi phuc $sp tai nhan ngoac_tra_ve.

check_brackets:
    move $t9, $sp
    move $t0, $a0
    li   $t1, 1

ngoac_loop:
    lbu  $t2, 0($t0)
    beq  $t2, $zero, ngoac_hop_le

    # Gap ngoac mo thi day len ngan xep.
    li   $t3, 40                  
    beq  $t2, $t3, mo_ngoac
    li   $t3, 91                  
    beq  $t2, $t3, mo_ngoac
    li   $t3, 123                 
    beq  $t2, $t3, mo_ngoac

    # Gap ngoac dong thi xac dinh ngoac mo can khop.
    li   $t3, 41                  
    beq  $t2, $t3, ngoac_dong_tron
    li   $t3, 93                  
    beq  $t2, $t3, ngoac_dong_vuong
    li   $t3, 125                 
    beq  $t2, $t3, ngoac_dong_nhon
    j    ngoac_tiep_theo               # Bo qua ky tu khac ngoac

mo_ngoac:
    addi $sp, $sp, -4             # Push: giam $sp truoc, ghi sau
    sw   $t2, 0($sp)
    j    ngoac_tiep_theo


ngoac_dong_tron:
    li   $t4, 40                  # Can ngoac mo '('
    j    ngoac_xet_dong
ngoac_dong_vuong:
    li   $t4, 91                  # Can ngoac mo '['
    j    ngoac_xet_dong
ngoac_dong_nhon:
    li   $t4, 123                 # Can ngoac mo '{'
ngoac_xet_dong:
    beq  $sp, $t9, ngoac_rong
    lw   $t5, 0($sp)              # Pop: doc truoc, tang $sp sau
    addi $sp, $sp, 4
    bne  $t5, $t4, ngoac_khac_loai


ngoac_tiep_theo:
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j    ngoac_loop

ngoac_hop_le:
    bne  $sp, $t9, ngoac_thieu
    move $v0, $zero               # Ngan xep rong: chuoi hop le
    move $v1, $zero
    j    ngoac_tra_ve

ngoac_khac_loai:
    move $v0, $t1
    li   $v1, 1
    j    ngoac_tra_ve

ngoac_rong:
    move $v0, $t1
    li   $v1, 2
    j    ngoac_tra_ve

ngoac_thieu:
    move $v0, $t1                 # Luc gap '\0', vi tri = do dai + 1
    li   $v1, 3
    j    ngoac_tra_ve

ngoac_tra_ve:
    move $sp, $t9                 # Khoi phuc ca khi con nhieu ngoac mo
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
