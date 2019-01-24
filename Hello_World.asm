;tell compiler what type of cpu use
cpu 386

;tell compiler of generate 32 bit code
bits 32

;import functions
extern GetStdHandle
import GetStdHandle kernel32.dll 

extern WriteConsoleA
import WriteConsoleA kernel32.dll

extern  ExitProcess
import ExitProcess kernel32.dll



;data segment
segment .data use32
  mex db "Hello World!!!",13,10   ;string to print a video
  mex_length equ $ - mex          ;length of string mex
  stdHandler dd 0                 ;to contains after the result of call [GetStdHandle]   
  num_chars dd 0                  ;num chars already written

;code segment
segment .text use32

;Info this start label tell to compiler where instruction start
  ..start:
    push dword -11                     ; STD_OUTPUT_HANDLE
    call [GetStdHandle]                ; eax = Console handle (rax in x64)
    
    mov [stdHandler], eax              ;copy the result of call in stdHandler
    push dword 0                       ;(_Reserved_       LPVOID  lpReserved
    push dword num_chars               ;_Out_            LPDWORD lpNumberOfCharsWritten,
    push dword mex_length              ;_In_             DWORD   nNumberOfCharsToWrite,
    push dword mex                     ;_In_       const VOID    *lpBuffer,
    push dword [stdHandler]            ;_In_             HANDLE  hConsoleOutput)BOOL WINAPI WriteConsole
    call [WriteConsoleA]               ;https://docs.microsoft.com/en-us/windows/console/writeconsole

    push dword 0                       ; exit code = 0
    call [ExitProcess]                 ; terminate program
