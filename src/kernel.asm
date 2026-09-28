[BITS 16]
[ORG 0x8000]

%include "src/const.asm"

start:
    mov si, default_shell_pt
    mov di, shell_pt
    call set_prompt

    call clear
    mov si, msg_kernel
    call puts
    mov si, msg_ascii
    call puts

    call prompt_out

hang:
    ;sti
    ;hlt

    ; AL - ASCII  AH - scan-code
    mov ah, 0x00
    int 0x16

    cmp al, 13 ; Enter
    je newline
    cmp al, 8  ; Backspace
    je backspace
    cmp al, 32
    jb hang
    call add_char_to_buffer
    jmp hang

newline:
    mov al, 13
    call putc
    mov al, 10
    call putc
    
    call process_cmd

    mov word [buf_len], 0
    mov word [buffer], 0

    call prompt_out
    jmp hang

backspace:
    cmp word [buf_len], 0
    je hang

    dec word [buf_len]
    mov al, 8
    call putc
    mov al, ' '
    call putc
    mov al, 8
    call putc
    jmp hang

; ====================== SHELL ====================== ;
prompt_out:
    mov si, shell_pt
    call puts
    ret

; =========== STR OPs ===========

streq:
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .ne
    or al, al
    jz .eq
    inc si
    inc di
    jmp .loop
.ne:
    clc
    ret
.eq:
    stc
    ret

; --- Defs ---

add_char_to_buffer:
    mov di, [buf_len]
    cmp di, 63 ; size = 64 Bytes
    jae .done
    mov bx, buffer
    mov [bx + di], al
    inc word [buf_len]
    call putc
    ret
.done:
    ret


;  ------============================------
; ------============ Data ============------
;  ------============================------

msg_kernel: 
    db 'czapaOS Kernel loaded! ', SECTORS
    db ' sectors mode', 13, 10, 0     

msg_ascii:
    db '   0000  0000000   0000    00000     0000        000000     0000  ', 13, 10
    db '  00  00     00   00  00   00  00   00  00      00    00   00   0 ', 13, 10
    db ' 00         00   00    00  00  00  00    00    00      00   00    ', 13, 10
    db ' 00        00    00000000  00000   00000000    00      00     00  ', 13, 10
    db '  00  00  00     00    00  00      00    00     00    00   0   00 ', 13, 10
    db '   0000  000000  00    00  00      00    00      000000     0000  ', 13, 10, 10
    db 0


%include "src/syscall.asm"
%include "src/commands.asm"


cmd_help   db 'help'  , 0
cmd_about  db 'abt'   , 0
cmd_clear  db 'clear' , 0
cmd_reboot db 'reboot', 0
cmd_logo   db 'logo'  , 0

msg_unknown db 'Unknown command', 13, 10, 0

; --- Buffer ---
buffer  times 64 db 0
buf_len dw 0

shell_pt times 64 db 0
default_shell_pt db 'ChapaOS-user: '

times 5120-($-$$) db 0