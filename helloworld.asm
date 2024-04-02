; String length calculation function
slen:
    push    ebx
    mov     ebx, eax

    xor     ecx, ecx        ; Counter for string length
.loop:
    cmp     byte [eax+ecx], 0  ; Check for null-terminator
    je      .done
    inc     ecx
    jmp     .loop
.done:
    mov     eax, ecx        ; Return the length in eax
    pop     ebx
    ret

; String printing function
sprint:
    push    edx
    push    ecx
    push    ebx
    push    eax
    call    slen            ; Get the length of the string
    mov     edx, eax        ; Length for syscall
    pop     eax             ; Restore the original eax
    mov     ecx, eax        ; Pointer to the string
    mov     ebx, 1          ; File descriptor for stdout
    mov     eax, 4          ; Syscall number for write
    int     80h             ; Call the kernel
    pop     ebx
    pop     ecx
    pop     edx
    ret

; Integer printing function with linefeed
iprintLF:
    call    iprint          ; Call our integer printing function
    push    eax             ; Preserve eax
    mov     eax, 0Ah        ; ASCII value for linefeed
    push    eax             ; Push linefeed onto the stack
    mov     eax, esp        ; Move the address of the stack pointer to eax for sprint
    call    sprint          ; Call the string printing function
    pop     eax             ; Remove the linefeed from the stack
    pop     eax             ; Restore the original eax
    ret

; Integer printing function
iprint:
    push    eax             ; Preserve eax on the stack
    push    ecx             ; Preserve ecx on the stack
    push    edx             ; Preserve edx on the stack
    mov     ecx, 0          ; Counter of how many bytes we need to print in the end

SECTION .data
msg        db      'Seconds since Jan 01 1970: ', 0h     ; a message string
delay_sec  dd      2           ; delay time in seconds
delay_nsec dd      0           ; delay time in nanoseconds (0 for simplicity)


SECTION .text
global  _start

_start:

printLoop:
    ; Print current time
    mov     eax, msg        ; Move our message string into eax for printing
    call    sprint          ; Call our string printing function

    mov     eax, 13         ; Invoke SYS_TIME (kernel opcode 13)
    int     80h             ; Call the kernel

    call    iprintLF        ; Call our integer printing function with linefeed

    ; Delay for 2 seconds
    mov     eax, 35         ; Invoke SYS_NANOSLEEP (kernel opcode 35)
    xor     ebx, ebx        ; ebx should be zero for the syscall
    mov     ecx, delay_sec  ; Load delay_sec into ecx
    mov     edx, delay_nsec ; Load delay_nsec into edx
    int     80h             ; Call the kernel to sleep

    jmp     printLoop       ; Jump back to printLoop to print again


;time
SECTION .data
msg        db      'Seconds since Jan 01 1970: ', 0h     ; a message string
 
SECTION .text
global  _start
 
_start:
 
    mov     eax, msg        ; move our message string into eax for printing
    call    sprint          ; call our string printing function
 
    mov     eax, 13         ; invoke SYS_TIME (kernel opcode 13)
    int     80h             ; call the kernel
 
    call    iprintLF        ; call our integer printing function with linefeed
    call    quit            ; call our quit function