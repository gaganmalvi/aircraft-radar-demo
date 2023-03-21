; Write a program in 8086 that can read and write
; data to a file

.model small
.stack 100h
.data
    success_open_msg db "File successfully opened.", "$"
    success_create_msg db "File successfully created.", "$"
    success_write_msg db "Written to file success.", "$"
    err_msg db "File was unable to be opened.", "$"
    
    radar_title db "Radar", "$"
    
    def_cur_pos_r dw 2
    def_cur_pos_c dw 1
    
    def_cur_pos_end_c dw 318
    def_cur_pos_end_r dw 199
    
    mid_pos_r dw 100
    mid_pos_c dw 160

    creating_file db "Creating file...", "$"

    filename db "data.txt", 0
    handle dw ?
    
    input_msg db "Enter text to write to file: ", "$"
    buffer db 10 dup(?)
    newline db 13, 10, "$"
.code

; Assign variable b to a
Assign macro a, b
    mov ax, [b]
    mov [a], ax    
endm

;a = -a 
Negate macro a
    mov ax, [a]
    neg ax
    mov [a], ax    
endm

;a = a+1 
IncVar macro a
    mov ax, [a]
    inc ax
    mov [a], ax    
endm

;a = a-1 
DecVar macro a
    mov ax, [a]
    dec ax
    mov [a], ax    
endm

Compare2Variables macro a, b
    mov cx, [a]
    cmp cx, [b]
endm

CompareVariableAndNumber macro a, b
    mov cx, [a]
    cmp cx, b
endm

;c = a+b
AddAndAssign macro c, a, b
    mov ax, [a]
    add ax, [b]
    mov [c], ax
endm 

;c = a-b
SubAndAssign macro c, a, b
    mov ax, [a]
    sub ax, [b]
    mov [c], ax
endm

;d = a+b+c
Add3NumbersAndAssign macro d, a, b, c
    mov ax, [a]
    add ax, [b]
    add ax, [c]
    mov [d], ax
endm 

;d = a-b-c
Sub3NumbersAndAssign macro d, a, b, c
    mov ax, [a]
    sub ax, [b]
    sub ax, [c]
    mov [d], ax
endm

exit macro
    mov ax, 4c00h
    int 21h
endm

open_file macro
    mov ah, 3dh
    mov al, 2
    lea dx, filename
    int 21h
    jc err_o
    mov handle, ax
    
    jmp done_o

    err_o:
        create_file
    
    done_o:
        print_line success_open_msg
endm

create_file macro
    mov ah, 3ch
    mov cx, 0
    lea dx, filename
    int 21h
    jc err_c
    mov handle, ax
    jmp done_c
    
    err_c:
        print_line err_msg

    done_c:
        print_line success_create_msg
        print_line newline
endm

print_line macro msg 
    mov ah, 09h
    lea dx, msg
    int 21h    
endm

input_line macro buffer
    print_line input_msg
    mov ah, 0ah
    lea dx, buffer
    int 21h
endm

write_file macro handle, text, len
    mov bx, handle
    mov ah, 42h ; LSEEK
    mov al, 2 ; Position relative to EOF
    mov cx, 0 ; Offset MSW
    mov dx, 0 ; Offset LSW
    int 21h

    lea dx, text
    mov cx, len
    mov ah, 40h 
    int 21h
endm

append_to_file macro handle, text, len
    write_file handle, text, len
    write_file handle, newline, 1
    print_line newline
    print_line success_write_msg
endm

set_cur_pos macro row, col
    mov ah, 2
    mov bh, 0
    mov dh, row
    mov dl, col
    int 10h
endm

DrawPixel macro row, col
    mov ah, 0ch
    mov cx, col
    mov dx, row
    int 10h
endm

DrawAirplane macro row, col, color
    mov al, color

    DrawPixel row-7, col
    DrawPixel row-6, col
    DrawPixel row-5, col
    DrawPixel row-4, col
    DrawPixel row-3, col
    DrawPixel row-2, col
    DrawPixel row-1, col
    DrawPixel row, col
    DrawPixel row+1, col
    DrawPixel row+2, col
    DrawPixel row+3, col
    DrawPixel row+4, col
    
    DrawPixel row-5, col-1
    DrawPixel row-4, col-1
    DrawPixel row-3, col-1
    DrawPixel row-2, col-1
    DrawPixel row-1, col-1
    DrawPixel row, col-1
    DrawPixel row+1, col-1
    DrawPixel row+2, col-1

    DrawPixel row-5, col+1
    DrawPixel row-4, col+1
    DrawPixel row-3, col+1
    DrawPixel row-2, col+1
    DrawPixel row-1, col+1
    DrawPixel row, col+1
    DrawPixel row+1, col+1
    DrawPixel row+2, col+1

    DrawPixel row, col+2
    DrawPixel row, col+3
    DrawPixel row, col+4
    DrawPixel row, col+5
    DrawPixel row, col+6
    
    DrawPixel row, col-2
    DrawPixel row, col-3
    DrawPixel row, col-4
    DrawPixel row, col-5
    DrawPixel row, col-6

    DrawPixel row-1, col+2
    DrawPixel row-1, col+3
    DrawPixel row-1, col+4
    DrawPixel row-1, col+5
    
    DrawPixel row-1, col-2
    DrawPixel row-1, col-3
    DrawPixel row-1, col-4
    DrawPixel row-1, col-5

    DrawPixel row-2, col+2
    DrawPixel row-2, col+3
    DrawPixel row-2, col+4
    
    DrawPixel row-2, col-2
    DrawPixel row-2, col-3
    DrawPixel row-2, col-4

    DrawPixel row+4, col+1
    DrawPixel row+4, col+2
    DrawPixel row+4, col+3
    
    DrawPixel row+4, col-1
    DrawPixel row+4, col-2
    DrawPixel row+4, col-3
    
    DrawPixel row+3, col+1
    DrawPixel row+3, col+2

    DrawPixel row+3, col-1
    DrawPixel row+3, col-2
endm

DrawCircle macro circleCenterX, circleCenterY, radius
    ;C# Code
;         int balance;
;         int xoff;
;         int yoff;
    balance dw 0
    xoff dw 0
    yoff dw 0 
    
    xplusx dw 0
    xminusx dw 0
    yplusy dw 0
    yminusy dw 0
    
    xplusy dw 0
    xminusy dw 0
    yplusx dw 0
    yminusx dw 0
    
    
    ;C# Code
    ;         xoff = 0;
    ;         yoff = radius;
    ;         balance = -radius;
    
    Assign yoff, radius
    
    Assign balance, radius
    Negate balance
    
    
    ;C# Code
    ;         while (xoff <= yoff)
    ;         {
    draw_circle_loop:
        AddAndAssign xplusx, circleCenterX, xoff
        SubAndAssign xminusx, circleCenterX, xoff
        AddAndAssign yplusy, circleCenterY, yoff
        SubAndAssign yminusy, circleCenterY, yoff

        AddAndAssign xplusy, circleCenterX, yoff
        SubAndAssign xminusy, circleCenterX, yoff
        AddAndAssign yplusx, circleCenterY, xoff
        SubAndAssign yminusx, circleCenterY, xoff
     
    ;C# Code
    ;        DrawPixel(circleCenterX + yoff, circleCenterY - xoff);
    ; part 1 from angle 0 to 45 counterclockwise
    DrawPixel xplusy, yminusx
    
    ;C# Code
    ;       DrawPixel(circleCenterX + xoff, circleCenterY - yoff);
    ; part 2 from angle 90 to 45 clockwise
    DrawPixel xplusx, yminusy
    
    ;C# Code
    ;       DrawPixel(circleCenterX - xoff, circleCenterY - yoff); 
    ; part 3 from angle 90 to 135 counterclockwise
    DrawPixel xminusx, yminusy
    
    ;C# Code
    ;        DrawPixel(circleCenterX - yoff, circleCenterY - xoff); 
    ; part 4 from angle 180 to 135 clockwise
    DrawPixel xminusy, yminusx
    
    ;C# Code
    ;       DrawPixel(circleCenterX - yoff, circleCenterY + xoff); 
    ; part 5 from angle 180 to 225 counterclockwise
    DrawPixel xminusy, yplusx
    
        ;C# Code
    ;       DrawPixel(circleCenterX - xoff, circleCenterY + yoff); 
    ; part 6 from angle 270 to 225 clockwise
    DrawPixel xminusx, yplusy
        
    ;C# Code
    ;       DrawPixel(circleCenterX + xoff, circleCenterY + yoff); 
    ; part 7 from angle 270 to 315 counterclockwise
    DrawPixel xplusx, yplusy
    
    
    ;C# Code
    ;       DrawPixel(circleCenterX + yoff, circleCenterY + xoff); 
    ; part 8 from angle 360 to 315 clockwise
    DrawPixel xplusy, yplusx

    
    ;C# Code
    ;        balance = balance + xoff + xoff;
    Add3NumbersAndAssign balance, balance, xoff, xoff
    
    ;C# Code
    ;            if (balance >= 0)
    ;            {
    ; 
    ;               yoff = yoff - 1;
    ;               balance = balance - yoff - yoff;
    ;               
    ;            }
    ; 
    ;            xoff = xoff + 1;
    CompareVariableAndNumber balance, 0
    jl balance_negative
    ;balance_positive:
    DecVar yoff
    
    Sub3NumbersAndAssign balance, balance, yoff, yoff
    
    balance_negative:
        IncVar xoff
    
    ;C# Code
    ;         while (xoff <= yoff)
    Compare2Variables xoff, yoff
    jg end_drawing
    jmp draw_circle_loop
    
    end_drawing:

endm

main proc far
    mov ax, @data
    mov ds, ax
    
    mov ah, 0
    mov al, 13h
    int 10h 

    mov ah, 2
    mov dh, 2
    mov dl, 2
    mov bh, 0
    int 10h
    print_line radar_title

    mov al, 1100b

    first:
        DrawPixel def_cur_pos_r, def_cur_pos_c
        inc def_cur_pos_c
        cmp def_cur_pos_c, 319
        jne first
    
    last:
        DrawPixel def_cur_pos_end_r, def_cur_pos_end_c
        dec def_cur_pos_end_c
        cmp def_cur_pos_end_c, 1
        jne last

    mov def_cur_pos_c, 1
    mov def_cur_pos_r, 2

    left:
        DrawPixel def_cur_pos_r, def_cur_pos_c
        inc def_cur_pos_r
        cmp def_cur_pos_r, 200
        jne left

    mov def_cur_pos_end_r, 199
    mov def_cur_pos_end_c, 318

    right:
        DrawPixel def_cur_pos_end_r, def_cur_pos_end_c
        dec def_cur_pos_end_r
        cmp def_cur_pos_end_r, 2
        jne right
    
    DrawCircle mid_pos_r, mid_pos_c, 90
    
    DrawAirplane 100, 160, 02h
    DrawAirplane 80, 90, 04h
    DrawAirplane 120, 230, 06h

    DrawAirplane 150, 130, 08h

    exit
main endp

end