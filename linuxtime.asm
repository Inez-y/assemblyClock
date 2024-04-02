SECTION .data
msg             db      'Seconds since Jan 01 1970(Linux Time): ', 0h     ; a message string
current_time    dd      0           ; variable to store current time, initialized to 0
lines_to_print  equ     10          ; number of lines to print

SECTION .bss
input_buffer    resb    1           ; buffer to store user input

SECTION .text
global  _start

_start:
    ; Print the initial message
    mov     eax, msg        ; move our message string into eax for printing
    call    sprint          ; call our string printing function

    ; Loop to print lines
    mov     ebx, lines_to_print         ; Number of lines to print
printLoop:
    ; Get current time
    mov     eax, 13         ; invoke SYS_TIME (kernel opcode 13)
    int     80h             ; call the kernel
    mov     [current_time], eax  ; Store the current time

    ; Print the current time
    mov     eax, [current_time]  ; Move current time into eax
    call    iprintLF            ; Call integer printing function with linefeed

    ; Decrement the counter
    dec     ebx

    ; Check if we've printed enough lines
    jnz     printLoop

    ; Check for user input to quit the program
    mov     eax, 3          ; Invoke SYS_READ (kernel opcode 3)
    mov     ebx, 0          ; Standard input (file descriptor 0)
    mov     ecx, input_buffer ; Buffer to store user input
    mov     edx, 1          ; Number of bytes to read
    int     80h             ; Call the kernel to read input

    cmp     byte [input_buffer], 'q'  ; Check if the user entered 'q' to quit
    jne     printLoop      ; Jump back to printLoop if 'q' is not entered

quitProgram:
    ; Exit the program
    mov     eax, 1          ; Invoke SYS_EXIT (kernel opcode 1)
    xor     ebx, ebx        ; Exit status 0
    int     80h             ; Call the kernel to exit

;------------------------------------------
; Your other functions and code follow...

; String length calculation function
slen:
    push    ebx
    mov     ebx, eax

.nextchar:
    cmp     byte [eax], 0
    jz      .finished
    inc     eax
    jmp     .nextchar

.finished:
    sub     eax, ebx
    pop     ebx
    ret

; String printing function
sprint:
    push    edx
    push    ecx
    push    ebx
    push    eax
    call    slen

    mov     edx, eax
    pop     eax

    mov     ecx, eax
    mov     ebx, 1
    mov     eax, 4
    int     80h

    pop     ebx
    pop     ecx
    pop     edx
    ret

; Integer printing function with linefeed
iprintLF:
    call    iprint
    push    eax
    mov     eax, 0Ah
    push    eax
    mov     eax, esp
    call    sprint
    pop     eax
    pop     eax
    ret

; Integer printing function
iprint:
    push    eax
    push    ecx
    push    edx
    push    esi
    mov     ecx, 0

.divideLoop:
    inc     ecx
    mov     edx, 0
    mov     esi, 10
    idiv    esi
    add     edx, 48
    push    edx
    cmp     eax, 0
    jnz     .divideLoop

.printLoop:
    dec     ecx
    mov     eax, esp
    call    sprint
    pop     eax
    cmp     ecx, 0
    jnz     .printLoop

    pop     esi
    pop     edx
    pop     ecx
    pop     eax
    ret

; Exit program
quit:
    mov     ebx, 0
    mov     eax, 1
    int     80h
    ret

