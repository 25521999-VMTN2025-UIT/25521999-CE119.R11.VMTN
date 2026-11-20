.data
ketqua: .asciiz "Ket qua: "
.text
main:
        li    $a0, 5            # x = 5
        jal   outer             # v0 = outer(5)
        move  $s0, $v0
        li    $v0, 4
        la    $a0, ketqua
        syscall
        move  $a0, $s0
        li    $v0, 1
        syscall
        li    $v0, 10
        syscall
# outer: outer(x) = inner(x) + 1.
# Tham so: $a0 = x. Tra ve: $v0 = 2*x + 1.
# Thanh ghi: $v0, $ra, $sp.
# Khung 4 bytes: 0=$ra.
outer:
        addi  $sp, $sp, -4
        sw    $ra, 0($sp)

        jal   inner
        addi  $v0, $v0, 1

        lw    $ra, 0($sp)
        addiu $sp, $sp, 4
        jr    $ra
# inner: inner(x) = 2*x, thu tuc la.
# Tham so: $a0 = x. Tra ve: $v0 = 2*x.
# Thanh ghi: $v0.
inner:
        add   $v0, $a0, $a0
        jr    $ra
