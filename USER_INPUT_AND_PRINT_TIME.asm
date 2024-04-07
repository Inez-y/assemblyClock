;------------------------------------------
; iprint function: Prints an integer to stdout
;------------------------------------------
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
    add     edx, 48         ; convert edx to its ascii representation - edx holds the remainder after a divide instruction
    push    edx             ; push edx (string representation of an integer) onto the stack
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
; iprintLF function: Prints an integer to stdout followed by a linefeed
;------------------------------------------
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
 
 
;------------------------------------------
; slen function: Calculates the length of a null-terminated string
;------------------------------------------
slen:
    push    ebx         ; Preserve the value of ebx by pushing it onto the stack
    mov     ebx, eax    ; Copy the address of the string (passed via eax) into ebx

nextchar:
    cmp     byte [eax], 0  ; Compare the byte at the address in eax to 0 (null terminator)
    jz      finished    ; If the byte is 0, indicating the end of the string, jump to 'finished'
    inc     eax         ; Move to the next character by incrementing the pointer in eax
    jmp     nextchar    ; Jump back to 'nextchar' to continue checking characters

finished:
    sub     eax, ebx    ; Calculate the length of the string by subtracting the initial address (ebx) from the final address (eax)
    pop     ebx         ; Restore the value of ebx by popping it from the stack
    ret                 ; Return the length of the string in eax

 

;------------------------------------------
; sprint function: Prints a null-terminated string to stdout
;------------------------------------------
sprint:
    push    edx             ; Preserve the value of edx by pushing it onto the stack
    push    ecx             ; Preserve the value of ecx by pushing it onto the stack
    push    ebx             ; Preserve the value of ebx by pushing it onto the stack
    push    eax             ; Preserve the value of eax by pushing it onto the stack
    call    slen            ; Call the slen function to get the length of the string
 
    mov     edx, eax        ; Move the length of the string (returned by slen) into the edx register
    pop     eax             ; Restore the original value of eax by popping it from the stack
    mov     ecx, eax        ; Set ecx to point to the string to print
    mov     ebx, 1          ; Set ebx to 1, which is the file descriptor for stdout
    mov     eax, 4          ; Set eax to 4, which is the system call number for sys_write
    int     80h             ; Call the kernel to write the string to stdout
 
    pop     ebx             ; Restore the preserved value of ebx by popping it from the stack
    pop     ecx             ; Restore the preserved value of ecx by popping it from the stack
    pop     edx             ; Restore the preserved value of edx by popping it from the stack
    ret                     ; Return from the function

;------------------------------------------
; _start function: Entry point of the program (main)
;------------------------------------------
section .data
msg1        db      'Please enter a digit (0-9): ', 0h  ; Prompt message for user input
msg2        db      'Your input is: ', 0h               ; Format for echoing user input
msg3        db      'Seconds since Jan 01 1970: ', 0h   ; Message prefix for current Unix time

section .bss
sinput:     resb    2                                   ; Reserve space for 1 digit of input and newline
currentTime resd    1                                   ; Reserve space for current time storage
sleepTime   resb    1                                   ; Reserve space for sleep duration
timeval     resb    16                                  ; Reserve space for timeval structure for nanosleep

section .text
global  _start                                           ; Define '_start' as the entry point of this program

_start:

    ; Get user input
    mov     eax, msg1                                   ; Load the address of the input prompt message into eax
    call    sprint                                      ; Call sprint to print the prompt message
    
    mov     edx, 2                                      ; Set the number of bytes to read (1 digit + newline)
    mov     ecx, sinput                                 ; Set ecx to the address of the buffer for input
    mov     ebx, 0                                      ; Set ebx to 0 for STDIN
    mov     eax, 3                                      ; System call number for SYS_READ
    int     80h                                         ; Invoke the system call to read user input
    
    mov     eax, msg2                            ; Load the address of the input format message
    call    sprint                                      ; Call sprint to print the format message
    
    movzx   eax, byte [sinput]                          ; Move the first byte of input into eax, zero-extended
    sub     al, '0'                                     ; Convert ASCII digit to its numeric value
    mov     [sleepTime], al                             ; Store the numeric value into sleepTime
    push    eax                                         ; Push the numeric value onto the stack for printing
    call    iprintLF                                    ; Call iprintLF to print the input digit and a newline

    ; Infinite loop
    jmp     loop_start                                  ; Jump to the start of the loop

loop_start:
    ; 1. Get and print the current time
    mov     eax, msg3                                   ; Load the address of the current time message prefix
    call    sprint                                      ; Call sprint to print the message prefix

    mov     eax, 13                                     ; System call number for SYS_TIME
    lea     ebx, [currentTime]                          ; Load the address of currentTime into ebx
    int     80h                                         ; Invoke the system call to get the current Unix time
    mov     eax, [currentTime]                          ; Move the current time into eax
    call    iprintLF                                    ; Call iprintLF to print the current Unix time and a newline

    ; 2. Sleep for n seconds
    movzx   eax, byte [sleepTime]                       ; Reload the sleep duration into eax, zero-extended
    mov     [timeval], eax                              ; Set the seconds part of timeval
    mov     dword [timeval + 4], 0                      ; Set the microseconds part of timeval to 0
    mov     eax, 162                                    ; System call number for SYS_NANOSLEEP
    lea     ebx, [timeval]                              ; Load the address of timeval into ebx
    mov     ecx, 0                                      ; Set ecx to 0 (unused parameter)
    int     80h                                         ; Invoke the system call to sleep for the specified duration

    jmp     loop_start                                  ; Repeat the loop
