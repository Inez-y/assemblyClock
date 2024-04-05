;------------------------------------------
; atoi function: Converts a string representing an integer to an integer value
;------------------------------------------
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
global  _start
 
_start:
 
    mov     eax, msg        ; Move the address of the message string into eax for printing
    call    sprint          ; Call the sprint function to print the message string
 
    mov     eax, 13         ; Move the system call number for SYS_TIME into eax
    int     80h             ; Invoke the kernel to execute the SYS_TIME system call, which retrieves the current time
 
    call    iprintLF        ; Call the iprintLF function to print an integer followed by a linefeed

    ; Print "Sleep"
    mov eax, 4              ; Move the system call number for sys_write into eax
    mov ebx, 1              ; Set ebx to 1, which is the file descriptor for stdout
    mov ecx, bmessage       ; Move the address of the "Sleep" message into ecx
    mov edx, bmessagel      ; Move the length of the "Sleep" message into edx
    int 0x80                ; Invoke the kernel to execute the sys_write system call, which prints the message
  
    ; Sleep for 2 seconds and 0 nanoseconds
    mov dword [tv_sec], 2   ; Move the value 2 (seconds) into tv_sec
    mov dword [tv_usec], 0  ; Move the value 0 (nanoseconds) into tv_usec
    mov eax, 162            ; Move the system call number for SYS_NANOSLEEP into eax
    mov ebx, timeval        ; Move the address of timeval structure into ebx
    mov ecx, 0              ; Move 0 into ecx (unused parameter)
    int 0x80                ; Invoke the kernel to execute the SYS_NANOSLEEP system call, which sleeps for the specified duration
  
    ; Print "2 seconds passed!"
    mov eax, 4              ; Move the system call number for sys_write into eax
    mov ebx, 1              ; Set ebx to 1, which is the file descriptor for stdout
    mov ecx, emessage       ; Move the address of the "2 seconds passed!" message into ecx
    mov edx, emessagel      ; Move the length of the "2 seconds passed!" message into edx
    int 0x80                ; Invoke the kernel to execute the sys_write system call, which prints the message
  
    ; Sleep for 2 seconds and 0 nanoseconds
    mov dword [tv_sec], 2   ; Move the value 2 (seconds) into tv_sec
    mov dword [tv_usec], 0  ; Move the value 0 (nanoseconds) into tv_usec
    mov eax, 162            ; Move the system call number for SYS_NANOSLEEP into eax
    mov ebx, timeval        ; Move the address of timeval structure into ebx
    mov ecx, 0              ; Move 0 into ecx (unused parameter)
    int 0x80                ; Invoke the kernel to execute the SYS_NANOSLEEP system call, which sleeps for the specified duration
  
    ; Print "another 2 seconds passed!"
    mov eax, 4              ; Move the system call number for sys_write into eax
    mov ebx, 1              ; Set ebx to 1, which is the file descriptor for stdout
    mov ecx, zmessage       ; Move the address of the "Another 2 seconds passed!" message into ecx
    mov edx, zmessagel      ; Move the length of the "Another 2 seconds passed!" message into edx
    int 0x80                ; Invoke the kernel to execute the sys_write system call, which prints the message

    ; Exit the program
    mov eax, 1              ; Move the system call number for SYS_EXIT into eax
    mov ebx, 0              ; Move the exit status (0) into ebx
    int 0x80                ; Invoke the kernel to execute the SYS_EXIT system call, which terminates the program

section .data
msg        db      'Seconds since Jan 01 1970: ', 0h     ; Define the message string

timeval:                    ; Define timeval structure to store time values
    tv_sec  dd 0            ; Define tv_sec field (seconds)
    tv_usec dd 0            ; Define tv_usec field (microseconds)

bmessage  db "Sleep", 10, 0      ; Define the "Sleep" message string with a newline and null terminator
bmessagel equ $ - bmessage       ; Calculate the length of the "Sleep" message

emessage  db "2 seconds passed!", 10, 0    ; Define the "2 seconds passed!" message string with a newline and null terminator
emessagel equ $ - emessage                 ; Calculate the length of the "2 seconds passed!" message
  
zmessage  db "Another 2 seconds passed!", 10, 0    ; Define the "Another 2 seconds passed!" message string with a newline and null terminator
zmessagel equ $ - zmessage                         ; Calculate the length of the "Another 2 seconds passed!" message
