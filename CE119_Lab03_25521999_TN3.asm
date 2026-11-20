.data
n: .word 20
Tong: .asciiz "F(n) = "
xuongDong: .asciiz "\n"
.text
main:
        lw    $a0, n
        jal   fib_rec
        move  $s0, $v0

        la    $a0, Tong
        li    $v0, 4
        syscall

        move  $a0, $s0
        li    $v0, 1
        syscall

        la    $a0, xuongDong
        li    $v0, 4
        syscall
        
        li    $v0, 10
        syscall

# fib_rec: Fibonacci de quy.
# Tham so: $a0 = n >= 0. Tra ve: $v0 = F(n).
# Thanh ghi: $a0, $v0, $t0, $s0, $s1, $ra, $sp.
# $s0 = n; $s1 = F(n-1)
# Khung 12 bytes: 0=$s1, 4=$s0, 8=$ra.
fib_rec:
        addi  $sp, $sp, -12
        sw    $ra, 8($sp)
        sw    $s0, 4($sp)
        sw    $s1, 0($sp)

        move  $s0, $a0                  #Giu n vi a0 se doi khi goi de quy.
        slti  $t0, $s0, 2               #if(n<2) {F(n) = n}
        bne   $t0, $zero, fr_base

        # Tinh F(n-1)
        addi  $a0, $s0, -1
        jal   fib_rec
        move  $s1, $v0
        # Tinh F(n-2)
        addi  $a0, $s0, -2
        jal   fib_rec
        addu  $v0, $s1, $v0             # F(n) = F(n-1) + F(n-2)

        j     fr_done
fr_base:
        move  $v0, $s0
fr_done:
        lw    $s1, 0($sp)
        lw    $s0, 4($sp)
        lw    $ra, 8($sp)
        addi  $sp, $sp, 12
        jr    $ra


# fib_iter: tinh F(n) bang vong lap
# Tham so : $a0 = n    Tra ve : $v0 = F(n)
# Thanh ghi: $t0-$t3 (thu tuc la)
fib_iter:
        move  $v0, $zero        #a = F(0)
        li    $t0, 1            #b = F(1)
        move  $t1, $zero        #i = 0
fi_loop:
        slt   $t2, $t1, $a0
        beq   $t2, $zero, fi_done
        addu  $t3, $v0, $t0     #a + b
        move  $v0, $t0
        move  $t0, $t3
        addiu $t1, $t1, 1
        j     fi_loop
fi_done:
        jr    $ra

