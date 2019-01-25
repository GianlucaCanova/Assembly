;Print_String.asm
;nasm -f obj Print_String.asm
;alink -oPE Print_String.obj -subsys console
;It works only on Windows OS

;tell compiler what type of cpu use
cpu 386

;tell compiler of generate 32 bit code
bits 32

;import functions
extern GetStdHandle
import GetStdHandle kernel32.dll 

extern WriteConsoleA
import WriteConsoleA kernel32.dll

extern ExitProcess
import ExitProcess kernel32.dll

extern SetConsoleMode
import SetConsoleMode kernel32.dll

extern ReadConsoleA
import ReadConsoleA kernel32.dll

;data segment
segment .data use32
  mex db "Insert a string:",13,10     ;string to print a video at the begining
  mex_length equ $ - mex              ;length of string mex
  mex2 db "You have insert: "         ;string to print at the end
  mex2_length equ $ - mex2            ;length of string mex2
  
  stdHandler dd 0                     ;contains after the result of call [GetStdHandle] for writeconsole  
  input_handler dd 0                  ;contains after the result of call [GetStdHandle] for readconsole

  num_chars_mex dd 0                  ;num chars already written
  num_chars_mex2 dd 0                 ;num chars already writtern
  num_chars_input dd 0                ;num chars already writtern
  
  buffer_length dd 128                ;length of buffer lp_buffer
  lpNumberOfCharsRead dd 0            ;contains the number of chars read

segment .bss

  lp_buffer resb 128                  ;array of char readed

;code segment
segment .text use32

;Info this start label tell to compiler where instruction start
  ..start:
    push dword -11                     ; STD_OUTPUT_HANDLE
    call [GetStdHandle]                ; eax = Console handle (rax in x64)
    
    mov [stdHandler], eax              ;copy the result of call in stdHandler
    push dword 0                       ;(_Reserved_       LPVOID  lpReserved
    push dword num_chars_mex           ;_Out_            LPDWORD lpNumberOfCharsWritten,
    push dword mex_length              ;_In_             DWORD   nNumberOfCharsToWrite,
    push dword mex                     ;_In_       const VOID    *lpBuffer,
    push dword [stdHandler]            ;_In_             HANDLE  hConsoleOutput)BOOL WINAPI WriteConsole
    call [WriteConsoleA]               ;https://docs.microsoft.com/en-us/windows/console/writeconsole

    push dword -10                     ; STD_INPUT_HANDLE
    call [GetStdHandle]                ; eax = Console handle (rax in x64)
    mov [input_handler], eax           ; copy the result of call in input_handler 

    push dword 7                       ;(_In_ DWORD  dwMode,         ENABLE_ECHO_INPUT 0x0004 + ENABLE_LINE_INPUT 0x0002 + ENABLE_PROCESSED_INPUT 0x0001
    push dword [input_handler]         ;_In_ HANDLE hConsoleHandle,
    call [SetConsoleMode]              ;)BOOL WINAPI SetConsoleMode  https://docs.microsoft.com/en-us/windows/console/setconsolemode

    push dword 0                       ;(_In_opt_ LPVOID  pInputControl,
    push dword lpNumberOfCharsRead     ;_Out_    LPDWORD lpNumberOfCharsRead,
    push dword [buffer_length]         ;_In_     DWORD   nNumberOfCharsToRead,
    push dword lp_buffer               ;_Out_    LPVOID  lpBuffer, 
    push dword [input_handler]         ;_In_     HANDLE  hConsoleInput 
    call [ReadConsoleA]                ;)BOOL WINAPI ReadConsole     https://docs.microsoft.com/en-us/windows/console/readconsole

    push dword 0                       ;(_Reserved_       LPVOID  lpReserved
    push dword num_chars_mex2          ;_Out_            LPDWORD lpNumberOfCharsWritten,
    push dword mex2_length             ;_In_             DWORD   nNumberOfCharsToWrite,
    push dword mex2                    ;_In_       const VOID    *lpBuffer,
    push dword [stdHandler]            ;_In_             HANDLE  hConsoleOutput)BOOL WINAPI WriteConsole
    call [WriteConsoleA]               ;https://docs.microsoft.com/en-us/windows/console/writeconsole

    push dword 0                       ;(_Reserved_       LPVOID  lpReserved
    push dword num_chars_input         ;_Out_            LPDWORD lpNumberOfCharsWritten,
    push dword [lpNumberOfCharsRead]   ;_In_             DWORD   nNumberOfCharsToWrite,
    push dword lp_buffer               ;_In_       const VOID    *lpBuffer,
    push dword [stdHandler]            ;_In_             HANDLE  hConsoleOutput)BOOL WINAPI WriteConsole
    call [WriteConsoleA]               ;https://docs.microsoft.com/en-us/windows/console/writeconsole

    push dword 0                       ; exit code = 0
    call [ExitProcess]                 ; terminate program
