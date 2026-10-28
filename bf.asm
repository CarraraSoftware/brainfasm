format ELF64 executable 3 
entry main

STDIN  = 0
STDOUT = 1
STDERR = 2

SYS_READ  = 00
SYS_WRITE = 01
SYS_EXIT  = 60

TAPE_SIZE       = 1024 * 10
ADDR_STACK_SIZE = 1024 * 10

plus  = '+'
minus = '-'
right = '>'
left  = '<'
dot   = '.'
comma = ','
lbrak = '['
rbrak = ']'

macro cp_byte source, offset, dest {
    mov RAX, source
    add AX, word [offset]
    mov RAX, [RAX]
    mov [dest], AL
}

macro cp_word source, offset, dest {
    mov RAX, source
    add AX, word [offset]
    mov RAX, [RAX]
    mov [dest], AX
}

macro str_byte source, dest, offset {
    mov RAX, dest
    add AX, word [offset]
    mov BL, byte [source]
    mov [RAX], BL
}

macro str_word source, dest, offset {
    mov RAX, dest
    add AX, word [offset]
    mov BX, word [source]
    mov [RAX], BX
}


;; CODE SEGMENT
segment readable executable

print:
;; param:
;; mov RSI, <str*>
;; mov RDX, <strlen>
    push RAX
    push RDI
    mov RAX, SYS_WRITE
    mov RDI, STDOUT
    syscall
    pop RDI
    pop RAX
    ret

print_byte:
;; param:
;; mov RSI, <char*>
    push RDX
    mov RDX, 1
    call print
    pop RDX
    ret

read_byte:
;; param
;; mov RSI, <char*>
    push RAX
    push RDI
    push RDX
    mov RAX, SYS_READ    
    mov RDI, STDIN
    mov RDX, 1
    syscall
    pop RDX
    pop RDI
    pop RAX
    ret

die:
    mov RAX, SYS_EXIT
    mov RDI, 0
    syscall

main:   


.loop:
    cmp [ip_], srclen - 1
    jge .end

    xor RAX, RAX
    xor RBX, RBX

    cp_byte src, ip_, cur_instr
    
    
    cmp [cur_instr], plus  ;; case '+':
    jne .plus_different
    cp_byte tape, dp_, data_byte
    inc [data_byte]
    str_byte data_byte, tape, dp_
    jmp .next


.plus_different:
    cmp [cur_instr], minus ;; case '-':
    jne .minus_different
    cp_byte tape, dp_, data_byte
    dec [data_byte]
    str_byte data_byte, tape, dp_
    jmp .next


.minus_different:
    cmp [cur_instr], right ;; case '>':
    jne .right_different
    inc [dp_]
    jmp .next

.right_different:
    cmp [cur_instr], left ;; case '<':
    jne .left_different
    dec [dp_]
    jmp .next

.left_different:
    cmp [cur_instr], dot ;; case '.':
    jne .dot_different
    cp_byte tape, dp_, data_byte
    mov RSI, data_byte
    call print_byte
    jmp .next
    
.dot_different:
    cmp [cur_instr], comma ;; case ',':
    jne .comma_different
    mov RSI, char
    call read_byte
    str_byte char, tape, dp_
    jmp .next

.comma_different:
    cmp [cur_instr], lbrak  ;; case '[':
    jne .lbrak_different
    str_word ip_, addrs, addrs_idx
    add [addrs_idx], 2
    jmp .next


.lbrak_different:
    cmp [cur_instr], rbrak ;; case ']':
    jne .rbrak_different
    sub [addrs_idx], 2

    cp_byte tape, dp_, data_byte
    cmp byte [data_byte], 0
    je .next
    cp_word addrs, addrs_idx, ip_
    jmp .loop

.rbrak_different: ;; unknwon instruction

.next:
    inc byte [ip_]
    jmp .loop

.end:
    mov [cur_instr], byte 10
    mov RSI, cur_instr
    call print_byte
    call die


;; DATA SEGMENT
segment readable writeable

src file "helloworld.bf"
srclen = $-src

error db "COMMA NOT IMPLEMENTED", 0x0A
errorlen = $-error

unk db "UNKNOWN INSTRUCTION", 0x0A
unklen = $-error

tape rb TAPE_SIZE
addrs rb ADDR_STACK_SIZE

addrs_idx dw 0
ip_       dw 0
dp_       dw 0

char      db 0
cur_instr db 0
data_byte db 0
