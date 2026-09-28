%include "src/const.asm"


process_cmd:
    mov di, [buf_len]
    mov bx, buffer
    mov byte [bx + di], 0

    cmp byte [buffer], 0
    je .empty_return

    ; help
    mov si, buffer
    mov di, cmd_help
    call streq
    jc .help
    ; about
    mov si, buffer
    mov di, cmd_about
    call streq
    jc .about
    ; clear
    mov si, buffer
    mov di, cmd_clear
    call streq
    jc .clear
    ; reboot
    mov si, buffer
    mov di, cmd_reboot
    call streq
    jc .reboot
    ; logo
    mov si, buffer
    mov di, cmd_logo
    call streq
    jc .logo
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


msg_help:
    db '=== Commands: ===', 13, 10
    db 'help   : show list of commands', 13, 10
    db 'abt    : About system', 13, 10
    db 'clear  : just clearing screen bro', 13, 10
    db 'reboot : rebooting ur PC', 13, 10
    db 'logo   : print to screen big ASCII OS logo', 13, 10, 10, 0

msg_about:
    db 'You are using czapaOS v', VERSION, 13, 10
    db '-------------------------', 13, 10
    db SECTORS, ' sectors using', 13, 10
    db '16 bit (REAL MODE)', 13, 10, 0