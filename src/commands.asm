%include "src/const.asm"

%macro CMD 3
    mov si, buffer
    mov di, %1
    call streq
    jc %2
%endmacro

process_cmd:
    mov di, [buf_len]
    mov bx, buffer
    mov byte [bx + di], 0

    cmp byte [buffer], 0
    je .empty_return

    mov si, buffer
    call split_args
    mov [arg_ptr], si

    CMD cmd_help,  .help,   0
    CMD cmd_about, .about,  0
    CMD cmd_clear, .clear,  0
    CMD cmd_reboot,.reboot, 0
    CMD cmd_logo,  .logo,   0
    CMD cmd_prpt,  .prpt,   0
    CMD cmd_mem,   .mem,    0
    CMD cmd_ver,   .ver,    0
    CMD cmd_echo,  .echo,   0
    ; undefined
    mov si, msg_unknown
    call puts
    ret
.empty_return:
    ret

.help:
    mov si, msg_help
    call puts
    ret

.about:
    mov si, msg_about
    call puts
    ret

.clear:
    call clear
    ret

.reboot:
    mov ax, 0x0000
    int 0x19
    ret

.logo:
    mov si, msg_ascii
    call puts
    ret
.prpt:
    mov si, msg_prpt1
    call puts

    mov di, buffer
    mov cx, 63
    call gets ; bx = answ

    mov si, buffer
    mov di, shell_pt
    call set_prompt

    mov si, msg_prpt2
    call puts
    ret

.echo:
    mov si, [arg_ptr]
    test si, si
    jz .empty
    call puts
.empty:
    mov si, msg_rn0 ; \r \n and \0
    call puts
    ret

.mem:
    xor ax, ax
    int 0x12
    call putdec
    mov si, msg_mem
    call puts
    ret

.ver:
    mov si, msg_ver
    call puts
    ret

arg_ptr dw 0

msg_help:
    db '===== Commands: =====', 13, 10
    db 'help   : show list of commands', 13, 10
    db 'abt    : About system', 13, 10
    db 'clear  : just clearing screen bro', 13, 10
    db 'reboot : rebooting ur PC', 13, 10
    db 'logo   : print to screen big ASCII OS logo', 13, 10
    db 'prpt   : changes your shell-prompt', 13, 10
    db 'mem    : shows your memory size', 13, 10
    db 'ver    : CzapaOS version', 13, 10
    db 'echo   : Prints all, thats you type after command', 13, 10
    db '=====================', 13, 10, 10, 0

msg_about:
    db 'You are using:  CzapaOS v', VERSION, 13, 10
    db '-------------------------', 13, 10
    db SECTORS, ' sectors using', 13, 10
    db '16 bit (REAL MODE)', 13, 10, 0

msg_prpt1 db 'Your new prompt: ', 0
msg_prpt2 db 'Success!', 13, 10, 0

msg_mem db ' KB', 13, 10, 0

msg_ver db 'CzapaOS v', VERSION, ' | release day: ', LAST_UPDATE_DATA, 13, 10, 0

msg_rn0 db 13, 10, 0