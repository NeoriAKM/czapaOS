[BITS 16]
[ORG 0x8000]

%include "src/const.asm"

start:
    call clear
    mov si, msg_kernel
    call puts
    mov si, msg_ascii
    call puts
    
    call setup

hang:
    call prompt_out
    mov di, buffer
    mov cx, 63
    call gets

    cmp word [buf_len], 0
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

setup:
    mov si, msg_setup
    call puts

    mov di, buffer
    mov cx, 63
    call gets

    mov si, buffer
    cmp byte [buffer], 0
    jne .have_prompt
    mov si, default_shell_pt
.have_prompt:
    mov di, shell_pt
    call set_prompt
    ret

; si = string (buffer) ;; Return `si` as arguments ;

split_args:
    push ax
    push di

    mov di, si
.skip_cmd:
    mov al, [di]
    or al, al
    jz .no_args
    cmp al, ' '
    je .found_space
    inc di
    jmp .skip_cmd

.found_space:
    mov byte [di], 0
    inc di
.skip_spaces:
    cmp byte [di], ' '
    jne .done
    inc di
    jmp .skip_spaces

.done:
    mov si, di
    pop di
    pop ax
    ret

.no_args:
    xor si, si
    pop di
    pop ax
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
    db '   0000  000000  00    00  00      00    00      000000     0000  ', 13, 10
    db 10, 0


%include "src/syscall.asm"
%include "src/commands.asm"


cmd_help   db 'help'  , 0
cmd_about  db 'abt'   , 0
cmd_clear  db 'clear' , 0
cmd_reboot db 'reboot', 0
cmd_logo   db 'logo'  , 0
cmd_prpt   db 'prpt'  , 0
cmd_mem    db 'mem'   , 0
cmd_ver    db 'ver'   , 0
cmd_echo   db 'echo'  , 0

msg_unknown db 'Unknown command', 13, 10, 0

; --- Buffer ---
buffer  times 64 db 0
buf_len dw 0

shell_pt times 64 db 0
default_shell_pt db 'CzapaOS-user: ', 0

msg_setup db 'What is your shell prompt>> ', 0

times 5120-($-$$) db 0