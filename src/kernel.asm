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

hang:
    call prompt_out
    mov di, buffer
    mov cx, 63
    call gets

    cmp bx, 0
    je hang

    call process_cmd

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
cmd_prpt   db 'prpt'  , 0

msg_unknown db 'Unknown command', 13, 10, 0

; --- Buffer ---
buffer  times 64 db 0
buf_len dw 0

shell_pt times 64 db 0
default_shell_pt db 'CzapaOS-user: '

times 5120-($-$$) db 0