.data
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

.text
# Thanh ghi trong chuong trinh chinh:
# $a0: dia chi chuoi truyen vao thu tuc, sau do la tham so in.
# $s0: luu vi tri tra ve; $s1: luu ma loi tra ve.
# $v0: vi tri tra ve hoac ma syscall; $v1: ma loi tra ve.
main:
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

    li   $v0, 10
    syscall

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
