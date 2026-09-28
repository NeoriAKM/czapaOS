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
    ; si = new prompt
    ; di = old prompt
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