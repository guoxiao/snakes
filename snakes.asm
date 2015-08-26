
.model small
.386
.stack 200h
.data
    line db 256 dup(12)
    column db 30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45
    db 240 dup(?)
    direction db 1 ;1234 = right down left up
.code
show macro a,b,char,num
    push ax
    push bx
    push cx
    push dx
    mov dh,a
    mov dl,b
    mov bh,0
    mov ah,02h
    int 10h
    mov ah,9
    mov al,char
    mov bh,0
    mov bl,1eh
    mov cx,num
    int 10h
    pop dx
    pop cx
    pop bx
    pop ax
endm

drawsnake macro num
    local loops
    push cx
    push bx
    mov bx,num
    sub bl,13

    show line[bx],column[bx],'-',1
    inc bl
    mov cx,12
loops:
    show line[bx],column[bx],'=',1
    inc bl
    loop loops
    show line[bx],column[bx],'#',1
 ;   inc bl
    pop bx
    pop cx

endm

clear macro
    push ax
    push bx

    ;set screen
    mov al,0
    mov bh,1eh
    mov ch,0
    mov cl,0
    mov dh,24
    mov dl,79
    mov ah,6
    int 10h
    pop bx
    pop ax
endm


delay macro
    local dly
    push ax
    push cx
    mov cx,100000
dly:
    xor ax,ax
    loop dly
    pop cx
    pop ax
endm


checkchar macro
    ;mov ah,0
    ;int 16h
    mov ah,11h
    int 16h
endm

getchar macro
    mov ah,0
    int 16h
endm

readscreen macro
    push dx
    push bx
    mov bh,0
    mov ah,03h
    int 10h
    mov al,direction
    .if al==1
        inc dl
    .elseif al==2
        inc dh
    .elseif al==3
        dec dl
    .elseif al==4
        dec dh
    .endif
    mov ah,02h
    int 10h

    mov ah,08h
    int 10h
    .if al=='-' || al=='='
        jmp over
    .endif
    pop bx
    pop dx
endm
.startup
    ;set display mode
    mov al,03h
    mov ah,00
    int 10h
    clear
    ;hide
    mov ah,01h
    mov cx,1000h
    int 10h

    mov bx,13
    drawsnake  bx

loop1:
    mov dl,direction
    delay
    checkchar
    .if  !zero?
        getchar
        .if (dl!=3 && ah==77)
            mov dl,1
            mov direction,dl
        .elseif (dl!=1 && ah==75)
            mov dl,3
            mov direction,dl
        .elseif (dl!=2 && ah==72)
            mov dl,4
            mov direction,dl
        .elseif (dl!=4 && ah==80)
            mov dl,2
            mov direction,dl
        .elseif al=='Q' ||al=='q'||ah==1
            jmp over

        .elseif ah!=75 &&ah!=72 &&ah!=77 &&ah!=80
            getchar
            .if al=='Q'||al=='q'||ah==1
                jmp over
            .endif
        .endif
    .endif
;    .else
    readscreen
        .if dl==1
            mov al,column[bx]
            mov ah,line[bx]
            inc al
            .if al>=79
                sub al,79
            .endif
            inc bl
            mov column[bx],al
            mov line[bx],ah
            clear
            drawsnake bx
        .elseif dl==2
            mov al,column[bx]
            mov ah,line[bx]
            inc ah
            .if ah>=23
                sub ah,23
            .endif
            inc bl
            mov column[bx],al
            mov line[bx],ah
            clear
            drawsnake bx
        .elseif dl==3
            mov al,column[bx]
            mov ah,line[bx]

            .if al==0
                mov al,77
            .endif
            dec al
            inc bl
            mov column[bx],al
            mov line[bx],ah
            clear
            drawsnake bx
        .else
            mov al,column[bx]
            mov ah,line[bx]

            .if ah==0
                mov ah,23
            .endif
            dec ah
            inc bl
            mov column[bx],al
            mov line[bx],ah
            clear
            drawsnake bx
        .endif

    jmp loop1
over:
.exit 0
end
