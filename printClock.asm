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
msg             db      'Elapsed time since program started: ', 0h ; message string for elapsed time
start_msg       db      'Program started. Press x to quit or o to display timelapse.', 0h ; message string for program start
stop_msg        db      'Program stopped.', 0h                  ; message string for program stop
quit_msg        db      'Quitting program.', 0h                ; message string for quitting program
delay_sec       dd      2           ; delay time in seconds
stop_char       db      'x', 0      ; Character to stop the program
disp_char       db      'o', 0      ; Character to display time lapse

SECTION .bss
start_time      resd    1           ; Start time in seconds since epoch
input_buffer    resb    1           ; Buffer to store user input

SECTION .text
global  _start

_start:

; Get the start time
mov     eax, 0            ; Invoke SYS_TIME (kernel opcode 0)
int     80h               ; Call the kernel
mov     [start_time], eax ; Store the start time

; Print program start message
mov     eax, start_msg    ; Move our start message string into eax for printing
call    sprint            ; Call our string printing function

; Wait for user input
waitInput:
mov     eax, 3            ; Invoke SYS_READ (kernel opcode 3)
mov     ebx, 0            ; Standard input (file descriptor 0)
mov     ecx, input_buffer ; Buffer to store user input
mov     edx, 1            ; Number of bytes to read
int     80h               ; Call the kernel to read input

; Check user input
cmp     byte [input_buffer], 'x'  ; Check if the user entered 'x' to stop
je      quitProgram      ; Jump to quitProgram if 'x' is entered

cmp     byte [input_buffer], 'o'  ; Check if the user entered 'o' to display time lapse
je      displayTimeLapse  ; Jump to displayTimeLapse if 'o' is entered

jmp     waitInput        ; Continue waiting for input if no valid option is entered

printLoop:
    ; Get current time
    mov     ebx, 0          ; Null pointer for timezone (not used)
    mov     eax, 1          ; Invoke SYS_TIME (kernel opcode 1)
    int     80h             ; Call the kernel
    sub     eax, [start_time] ; Calculate elapsed time

    ; Print elapsed time
    mov     ebx, eax        ; Move elapsed time to ebx
    call    iprintLF        ; Call our integer printing function with linefeed

    ; Delay for 2 seconds
    mov     eax, 35         ; Invoke SYS_NANOSLEEP (kernel opcode 35)
    xor     ebx, ebx        ; ebx should be zero for the syscall
    mov     ecx, delay_sec  ; Load delay_sec into ecx
    xor     edx, edx        ; Clear edx (no nanoseconds)
    int     80h             ; Call the kernel to sleep

    ; Check for user input to stop the program
    mov     eax, 3          ; Invoke SYS_READ (kernel opcode 3)
    mov     ebx, 0          ; Standard input (file descriptor 0)
    mov     ecx, input_buffer ; Buffer to store user input
    mov     edx, 1          ; Number of bytes to read
    int     80h             ; Call the kernel to read input

    cmp     byte [input_buffer], 'x'  ; Check if the user entered 'x' to stop
    je      quitProgram      ; Jump to quitProgram if 'x' is entered

    cmp     byte [input_buffer], 'o'  ; Check if the user entered 'o' to display time lapse
    je      displayTimeLapse  ; Jump to displayTimeLapse if 'o' is entered

    jmp     printLoop       ; Jump back to printLoop to print again

displayTimeLapse:
    ; Display elapsed time since program started
    mov     eax, msg        ; Move our message string into eax for printing
    call    sprint          ; Call our string printing function

    ; Get current time
    mov     ebx, 0          ; Null pointer for timezone (not used)
    mov     eax, 1          ; Invoke SYS_TIME (kernel opcode 1)
    int     80h             ; Call the kernel
    sub     eax, [start_time] ; Calculate elapsed time

    ; Print elapsed time
    mov     ebx, eax        ; Move elapsed time to ebx
    call    iprintLF        ; Call our integer printing function with linefeed

    ; Jump back to waiting for input
    jmp     waitInput

quitProgram:
    ; Print program stop message
    mov     eax, quit_msg   ; Move our quit message string into eax for printing
    call    sprint          ; Call our string printing function

    ; Exit the program
    mov     eax, 1          ; Invoke SYS_EXIT (kernel opcode 1)
    xor     ebx, ebx        ; Exit status 0
    int     80h             ; Call the kernel to exit
