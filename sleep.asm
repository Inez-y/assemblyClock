;------------------------------------------
section .bss
    count resb 1 ; Reserve a byte for the loop counter

section .data
    msg db 'The current time is: ', 0

section .text
global _start

_start:
    mov [count], 5 ; Set the loop to run 5 times

loop_start:
    ; Print the initial message
    mov eax, msg
    call sprint

    ; Get the current time (number of seconds since the Unix epoch)
    mov eax, 4 ; syscall number for sys_time
    xor ebx, ebx ; ebx must be zeroed out for sys_time
    int 0x80
    ; eax now contains the current time

    ; Print the current time
    call iprintLF

    ; Sleep for 2 seconds
    mov eax, 2 ; Number of seconds to sleep
    call sleep

    ; Decrement our loop counter and check if it's zero
    dec byte [count]
    jz exit_loop

    ; If not zero, jump back to the beginning of the loop
    jmp loop_start

exit_loop:
    ; Exit the program
    mov eax, 1 ; syscall number for sys_exit
    xor ebx, ebx ; return code 0
    int 0x80
    
<---update some stuff--->

; int slen(String message)
; String length calculation function
slen:
    push    ebx
    mov     ebx, eax
 
nextchar:
    cmp     byte [eax], 0
    jz      finished
    inc     eax
    jmp     nextchar
 
finished:
    sub     eax, ebx
    pop     ebx
    ret
 
 
;------------------------------------------
; void iprintLF(Integer number)
; Integer printing function with linefeed (itoa)
iprintLF:
    call    iprint          ; call our integer printing function
 
    push    eax             ; push eax onto the stack to preserve it while we use the eax register in this function
    mov     eax, 0Ah        ; move 0Ah into eax - 0Ah is the ascii character for a linefeed
    push    eax             ; push the linefeed onto the stack so we can get the address
    mov     eax, esp        ; move the address of the current stack pointer into eax for sprint
    call    sprint          ; call our sprint function
    pop     eax             ; remove our linefeed character from the stack
    pop     eax             ; restore the original value of eax before our function was called
    ret
 
; for calculator
atoi:
    push    ebx             ; preserve ebx on the stack to be restored after function runs
    push    ecx             ; preserve ecx on the stack to be restored after function runs
    push    edx             ; preserve edx on the stack to be restored after function runs
    push    esi             ; preserve esi on the stack to be restored after function runs
    mov     esi, eax        ; move pointer in eax into esi (our number to convert)
    mov     eax, 0          ; initialise eax with decimal value 0
    mov     ecx, 0          ; initialise ecx with decimal value 0
 
.multiplyLoop:
    xor     ebx, ebx        ; resets both lower and uppper bytes of ebx to be 0
    mov     bl, [esi+ecx]   ; move a single byte into ebx register's lower half
    cmp     bl, 48          ; compare ebx register's lower half value against ascii value 48 (char value 0)
    jl      .finished       ; jump if less than to label finished
    cmp     bl, 57          ; compare ebx register's lower half value against ascii value 57 (char value 9)
    jg      .finished       ; jump if greater than to label finished
 
    sub     bl, 48          ; convert ebx register's lower half to decimal representation of ascii value
    add     eax, ebx        ; add ebx to our integer value in eax
    mov     ebx, 10         ; move decimal value 10 into ebx
    mul     ebx             ; multiply eax by ebx to get place value
    inc     ecx             ; increment ecx (our counter register)
    jmp     .multiplyLoop   ; continue multiply loop
 
.finished:
    cmp     ecx, 0          ; compare ecx register's value against decimal 0 (our counter register)
    je      .restore        ; jump if equal to 0 (no integer arguments were passed to atoi)
    mov     ebx, 10         ; move decimal value 10 into ebx
    div     ebx             ; divide eax by value in ebx (in this case 10)
 
.restore:
    pop     esi             ; restore esi from the value we pushed onto the stack at the start
    pop     edx             ; restore edx from the value we pushed onto the stack at the start
    pop     ecx             ; restore ecx from the value we pushed onto the stack at the start
    pop     ebx             ; restore ebx from the value we pushed onto the stack at the start
    ret

;------------------------------------------
; void iprint(Integer number)
; Integer printing function (itoa)
iprint:
    push    eax             ; preserve eax on the stack to be restored after function runs
    push    ecx             ; preserve ecx on the stack to be restored after function runs
    push    edx             ; preserve edx on the stack to be restored after function runs
    push    esi             ; preserve esi on the stack to be restored after function runs
    mov     ecx, 0          ; counter of how many bytes we need to print in the end
 
divideLoop:
    inc     ecx             ; count each byte to print - number of characters
    mov     edx, 0          ; empty edx
    mov     esi, 10         ; mov 10 into esi
    idiv    esi             ; divide eax by esi
    add     edx, 48         ; convert edx to it's ascii representation - edx holds the remainder after a divide instruction
    push    edx             ; push edx (string representation of an intger) onto the stack
    cmp     eax, 0          ; can the integer be divided anymore?
    jnz     divideLoop      ; jump if not zero to the label divideLoop
 
printLoop:
    dec     ecx             ; count down each byte that we put on the stack
    mov     eax, esp        ; mov the stack pointer into eax for printing
    call    sprint          ; call our string print function
    pop     eax             ; remove last character from the stack to move esp forward
    cmp     ecx, 0          ; have we printed all bytes we pushed onto the stack?
    jnz     printLoop       ; jump is not zero to the label printLoop
 
    pop     esi             ; restore esi from the value we pushed onto the stack at the start
    pop     edx             ; restore edx from the value we pushed onto the stack at the start
    pop     ecx             ; restore ecx from the value we pushed onto the stack at the start
    pop     eax             ; restore eax from the value we pushed onto the stack at the start
    ret
 ;------------------------------------------
; void sprint(String message)
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
 
 
;------------------------------------------
; void sprintLF(String message)
; String printing with line feed function
sprintLF:
    call    sprint
 
    push    eax
    mov     eax, 0AH
    push    eax
    mov     eax, esp
    call    sprint
    pop     eax
    pop     eax
    ret
 
 
 

;------------------------------------------
; void sleep(int seconds)
; Sleep function to wait for a given number of seconds
sleep:
    mov     eax, 35         ; invoke SYS_SLEEP (kernel opcode 35)
    int     80h             ; call the kernel
    ret

;------------------------------------------
; void exit()
; Exit program and restore resources
quit:
    mov     ebx, 0
    mov     eax, 1
    int     80h
    ret
    
SECTION .data
msg        db      'Seconds since Jan 01 1970: ', 0h     ; a message string

SECTION .text
global  _start

_start:
    ; Print the message
    mov     eax, msg        ; move our message string into eax for printing
    call    sprint          ; call our string printing function

    ; Get seconds since Jan 01 1970
    mov     eax, 13         ; invoke SYS_TIME (kernel opcode 13)
    int     80h             ; call the kernel

    ; Print the seconds
    call    iprintLF        ; call our integer printing function with linefeed

    ; Sleep for 2 seconds
    mov     eax, 2          ; 2 seconds
    call    sleep           ; call sleep function

    ; Print the message again
    mov     eax, msg        ; move our message string into eax for printing
    call    sprint          ; call our string printing function

    ; Get seconds since Jan 01 1970 again
    mov     eax, 13         ; invoke SYS_TIME (kernel opcode 13)
    int     80h             ; call the kernel

    ; Print the seconds again
    call    iprintLF        ; call our integer printing function with linefeed

    ; Quit the program
    call    quit            ; call our quit function