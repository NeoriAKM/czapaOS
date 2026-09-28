[BITS 16]
[ORG 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov si, msg_boot
    call puts

    mov ah, 0x02
    mov al, 10 ; sector
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x80
    mov bx, 0x8000
    int 0x13
    jc error

    jmp 0x0000:0x8000

error:
    mov si, msg_error
    call puts
    hlt

puts:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp puts
.done:
    ret

msg_boot  db 'czapaOS Booting...', 13, 10, 0
msg_error db 'Disk read error!', 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55