;%include "io.inc"
;define Constants for read and write
SYS_WRIT equ 4 
SYS_READ equ 3
STDIN    equ 0
STDOUT   equ 1
;define COnstants for Exit
SYS_EXIT equ 1

;Macro for write on Screan
%macro write_string 2
    mov eax, SYS_WRIT
    mov ebx, STDOUT
    mov ecx, %1
    mov edx, %2
    int 80h
%endmacro

;Macro for read input string
%macro read_string 2
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, %1
    mov edx, %2
    int 80h
%endmacro

%macro exit_code 0
    mov eax, SYS_EXIT
    mov ebx, 0
    int 80h
%endmacro    

%macro check_operator 1
    cmp byte [operator], '+'
    je summ
    cmp byte [operator], '-'
    je subt
    cmp byte [operator], '*'
    je mult
    cmp byte [operator], '/'
    je divi
    cmp byte [operator], 'e'
    je exit_c
    cmp byte [operator], 'c'
    je continue
    jmp w_i_excp ;stands for wong input exeption 
%endmacro    
section .data
    msg1 db 'Please Enter fst operand: ',0x0a,0xD 
    len1 equ $ - msg1
    msg2 db 'Please Enter sec operand: ',0x0a,0xD 
    len2 equ $ - msg2
    msg3 db 'Please Enter the operator: ' ,0x0a,0xD 
    len3 equ $ - msg3
    msg4 db "The Result is: ",0x0a,0xD 
    len4 equ $ - msg4
    msg5 db 'Press "e" to Exit OR Press "c" to continue',0x0a,0xD 
    len5 equ $ - msg5
    ;msg6 db 'The Final Result is: ',0x0a,0xD 
    ;len6 equ $ - msg6
    msg7 db 'Wrong input exeption. ',0x0a,0xD 
    len7 equ $ - msg7    
    newl db 0xA,0xD          ;newline
    newlen equ $ - newl
    
    plus equ byte'+'
    minus equ byte'-'
    len_si equ 1
    zero dd 0.0
    ten dd 10.0
    hundred dd 1000.0
    ne dd -1.0      
  
    

section .bss
    
 
    input resb 100
    input_len equ $-input
    
    input1 resb 100
    input_len1 equ $-input1
    
    op1 resb 100
    op1_len equ $-op1
    op2 resb 100
    op2_len equ $-op2
    temp resb 100
    temp_len equ $-temp
    
    operator resb 20
    operator_len equ $-operator
    
    c_or_e resb 20
    c_or_e_len equ $ - c_or_e
    
    tail resb 100
    tail_len equ $-tail
    head resb 100
    head_len equ $-head
section .text

global _start
_start:
        ; r8 and r9 are use in itos and r15 and r12 in stoi
        mov rbp, rsp; for correct debugging
        mov ebp, esp; for correct debugging
        
        write_string msg1, len1            ;print first string
        read_string  input, input_len      ;read fist operand 
        
        mov rsi, input
        call stof
        movss xmm4 ,dword[zero]
        movss xmm4 ,xmm0                      ;now we have op1 integer in op1
        cvtss2si eax ,xmm4
here:
        call clear_input
        xor rsi, rsi
                                        
next_round:        
        write_string msg2, len2            ;print second string
        read_string input, input_len       ;read second operand
        
        mov rsi, input
        call stof
        movss xmm5 ,dword[zero]
        movss xmm5 ,xmm0                    ;now we have op1 integer in op1
        call clear_input
        xor rsi, rsi

        
        write_string msg3, len3             ;print operator string
        read_string  operator, operator_len            ;read operator
        
              
        check_operator operator
        
        
        done:
           
            push rbx
            write_string msg4, len4
            pop rbx
            movss xmm3 ,xmm4
            mulss xmm4 ,dword[hundred]
            xor rax, rax
            cvtss2si eax ,xmm4
            push rax

            mov rsi, tail
            call itofs
            xor rsi, rsi
            
            mov rax,4
            mov rbx,1
            mov rcx, head
            mov rdx, r9
            int 80h
            call clear_head
            xor rsi, rsi
            call clear_tail
l2:
l3:            write_string newl, newlen
l4:            write_string msg5, len5
l5:            read_string operator, operator_len       
l6:            pop rax
 
l7:            check_operator operator
l8:                                    
            jmp exit_c
                  
        
;Sum=================================================
summ:
        addss xmm4 ,xmm5
        jmp done

;Sub=================================================
subt:
        subss xmm4 ,xmm5
        jmp done
;multi=================================================
mult:
        mulss xmm4 ,xmm5
        jmp done
;division=================================================
divi:
        divss xmm4 ,xmm5
        jmp done

;exeption=================================================
w_i_excp:
        ;print operator
        mov eax, SYS_WRIT
        mov ebx, STDOUT
        mov ecx, msg7
        mov edx, len7
        int 80h
        ;print new line
        mov eax, SYS_WRIT
        mov ebx, STDOUT
        mov ecx, newl
        mov edx, newlen
        int 80h
        jmp exit_c


;continue=================================================
continue:
        cvtsi2ss xmm4 ,eax
        divss xmm4 ,dword[hundred]
        jmp next_round


;exit=================================================
exit_c:
       mov eax, 1
       mov ebx, 0
       int 80h
        

stof:
        xor rax, rax
        xor ecx, ecx
        xor r15b, r15b
        xor r13b, r13b
        movss xmm0 ,dword[zero]
        movss xmm1 ,dword[zero]
        cmp byte[rsi], plus
        je sign
        cmp byte[rsi], minus
        jne forbf
        sign:
            mov r15b, [rsi]
            inc rsi
        forbf:
            xor ebx, ebx
            mov bl, byte[rsi]
            cmp bl, '.'
            h3:
            je afterdot
            befordot:
            sub bl, '0'
            mulss xmm0 ,dword[ten]
            cvtsi2ss xmm1, ebx
            addss xmm0 ,xmm1
            inc rsi
            cmp byte[rsi+1], 0     ;we assume that user just enter valid nums so we check null
            jnz forbf
            cmp r13b, 1
            jne minuse
        afterdot:
            mov r13b, 1 
            movss xmm2 ,dword[ten]
            inc rsi
        foraf:
            xor ebx, ebx
            mov bl, byte[rsi]
            sub bl, '0'        
            cvtsi2ss xmm1 ,ebx
            divss xmm1 ,xmm2
            addss xmm0 ,xmm1
            mulss xmm2 ,xmm2
            inc rsi
            cmp byte[rsi+1], 0     ;we assume that user just enter valid nums so we check null
            jnz foraf
        minuse:
        cmp r15b, minus
        jne end
        mulss xmm0 ,[ne]
        
        end:
 
        ret
        
itofs:
        ;create a revesre string of input int the reverse it
        ;eax has the integer
        ;three to the last should be "." we use r14 as counter
        ;rsi is pointing to the tail(end of string)
        ;head is pointing to the start of the String
        ;r9 will keep the length    
        xor rdi, rdi                
        xor rdx, rdx
        xor r14, r14
        mov r14, -4   ;three to the last
        mov rdi, head
        xor r8, r8
        cmp eax, 0
        jnl while
        neg eax
        mov byte[rdi], minus
        dec r14
        inc rdi
        inc r8        
        while:
            inc r8b
            xor rdx, rdx
            mov ecx, 10    
            div ecx
            xor rbx, rbx
            mov ebx, eax
            add dl, '0'
            mov [rsi], dl            
            inc rsi
            cmp eax, 0
            jz div_zero
            xor rax, rax
            mov eax, ebx
            jmp while 
        div_zero:               ;will reverse the string to output
            mov r9,r8           ;r9 will keep the length
            inc r9
            add r14, r9
            dec rsi
            l1:
            xor rcx,rcx
            cmp r14, 0
            je  placedot
            mov cl, [rsi]
            mov [rdi], cl
            inc rdi
            dec rsi
            dec r14
            dec r8
            cmp r8, 0
            jg  l1
            jmp ende
        placedot:
            mov [rdi], byte '.'
            inc rdi
            inc r9
            dec r14
            jmp l1                  
        ende:
        ret
        
clear_input:
            mov rsi, input
            mov ecx, input_len
            lpc:
                mov [rsi], byte 0
                inc rsi
                loop lpc
            ret
clear_head:
            mov rsi, head
            mov ecx, head_len
            lpch:
                mov [rsi], byte 0
                inc rsi
                loop lpch
            ret
clear_tail:
            mov rsi, tail
            mov ecx, tail_len
            lpch1:
                mov [rsi], byte 0
                inc rsi
                loop lpch1
            ret                                                                                                                                        