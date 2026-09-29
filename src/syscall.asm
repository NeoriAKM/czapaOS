[BITS 16]

putc:   ; AL = symb
    push ax
    mov ah, 0x0E
    int 0x10
    pop ax
    ret

puts:   ; SI = str before 0
    lodsb
    or al, al
    jz .done
    call putc
    jmp puts
.done:
    ret


clear:
    mov ax, 0x0003
    int 0x10
    ret

set_prompt:
    ; si = new prompt ; di = old prompt ;
    push si
    push di
    push ax
.loop:
    lodsb
    stosb
    or al, al
    jnz .loop
    jmp .done
.done:

    pop ax
    pop di
    pop si
    ret


gets:
    push ax
    push di
    push cx
    push bx

    xor bx, bx

.loop:
    mov ah, 0x00
    int 0x16
    cmp al, 13 ; Enter
    je .done
    cmp al, 8  ; Backspace
    je .backspace
    cmp al, 32
    jb .loop
    cmp bx, cx
    jae .loop

    mov [di], al
    inc di
    inc bx

    call putc
    jmp .loop
.done:
    mov byte [di], 0
    mov [buf_len], bx

    mov al, 13
    call putc
    mov al, 10
    call putc

    pop bx
    pop cx
    pop di
    pop ax
    ret
.backspace:
    cmp bx, 0
    je .loop

    dec di
    dec bx

    mov al, 8
    call putc
    mov al, ' '
    call putc
    mov al, 8
    call putc
    jmp .loop