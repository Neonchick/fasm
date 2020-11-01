format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strX            db 'X%d of %d segment ', 0
        strY            db 'Y%d of %d segment ', 0
        strIncorrect    db 'Incorrect value', 10, 0
        strScanInt      db '%d', 0
        strYes          db 'These segments can be sides of a right triangle', 10, 0
        strNo           db 'These segments can not be sides of a right triangle', 10, 0

        lenSqr1B        dd ?
        lenSqr2B        dd ?
        lenSqr3B        dd ?
        lenSqr1L        dd ?
        lenSqr2L        dd ?
        lenSqr3L        dd ?
        tempX           dd ?
        tempY           dd ?
        tempX2          dd ?
        tempY2          dd ?
        tempLenSqrB     dd ?
        tempLenSqrL     dd ?
        tempN           dd ?
        tempSide        dd ?
        tempLenSqr1B    dd ?
        tempLenSqr2B    dd ?
        tempLenSqr3B    dd ?
        tempLenSqr1L    dd ?
        tempLenSqr2L    dd ?
        tempLenSqr3L    dd ?
        fl              dd ?
        temp            dd ?

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) get all lengths
        call AllGetLen
; 2) check all lengths
        call AllCheck
finish:
        call [getch]

        push 0
        call [ExitProcess]
;--------------------------------------------------------------------------
Error:
        push strIncorrect
        call [printf]
        jmp finish
;--------------------------------------------------------------------------
CoorInput:
        push [tempN]
        push [tempSide]
        push strX
        call [printf]
        add esp, 12

        push tempX
        push strScanInt
        call [scanf]
        add esp, 8
        cmp eax, 1
        jne Error
        mov eax, [tempX]
        cmp eax, 0
        jl Error
        cmp eax, 65535
        jg Error

        push [tempN]
        push [tempSide]
        push strY
        call [printf]
        add esp, 12

        push tempY
        push strScanInt
        call [scanf]
        add esp, 8
        cmp eax, 1
        jne Error
        mov eax, [tempY]
        cmp eax, 0
        jl Error
        cmp eax, 65535
        jg Error

        ret
;--------------------------------------------------------------------------
AllGetLen:
        mov eax, 1
        mov [tempN], eax
        call GetLen
        mov eax, [tempLenSqrL]
        mov [lenSqr1L], eax
        mov eax, [tempLenSqrB]
        mov [lenSqr1B], eax

        mov eax, 2
        mov [tempN], eax
        call GetLen
        mov eax, [tempLenSqrL]
        mov [lenSqr2L], eax
        mov eax, [tempLenSqrB]
        mov [lenSqr2B], eax

        mov eax, 3
        mov [tempN], eax
        call GetLen
        mov eax, [tempLenSqrL]
        mov [lenSqr3L], eax
        mov eax, [tempLenSqrB]
        mov [lenSqr3B], eax
        ret
;--------------------------------------------------------------------------
GetLen:
        mov eax, 1
        mov [tempSide], eax
        call CoorInput
        mov eax, [tempX]
        mov [tempX2], eax
        mov eax, [tempY]
        mov [tempY2], eax
        mov eax, 2
        mov [tempSide], eax
        call CoorInput

        mov eax, [tempX]
        sub eax, [tempX2]
        cmp eax, 0
        jge NotNegX
        neg eax
NotNegX:
        mul eax
        mov [tempLenSqrL], eax
        mov [tempLenSqrB], edx

        mov eax, [tempY]
        sub eax, [tempY2]
        cmp eax, 0
        jge NotNegY
        neg eax
NotNegY:
        mul eax
        add [tempLenSqrL], eax
        jnc NoAddLen
        add [tempLenSqrB], 1
NoAddLen:
        add [tempLenSqrB], edx
        ret
;--------------------------------------------------------------------------
AllCheck:
        mov eax, [lenSqr1L]
        mov [tempLenSqr1L], eax
        mov eax, [lenSqr1B]
        mov [tempLenSqr1B], eax
        mov eax, [lenSqr2L]
        mov [tempLenSqr2L], eax
        mov eax, [lenSqr2B]
        mov [tempLenSqr2B], eax
        mov eax, [lenSqr3L]
        mov [tempLenSqr3L], eax
        mov eax, [lenSqr3B]
        mov [tempLenSqr3B], eax
        call Check
        cmp eax, 1
        jne Check2
        push strYes
        call [printf]
        add esp, 4
        ret
Check2:
        mov eax, [lenSqr1L]
        mov [tempLenSqr1L], eax
        mov eax, [lenSqr1B]
        mov [tempLenSqr1B], eax
        mov eax, [lenSqr3L]
        mov [tempLenSqr2L], eax
        mov eax, [lenSqr3B]
        mov [tempLenSqr2B], eax
        mov eax, [lenSqr2L]
        mov [tempLenSqr3L], eax
        mov eax, [lenSqr2B]
        mov [tempLenSqr3B], eax
        call Check
        cmp eax, 1
        jne Check3
        push strYes
        call [printf]
        add esp, 4
        ret
Check3:
        mov eax, [lenSqr3L]
        mov [tempLenSqr1L], eax
        mov eax, [lenSqr3B]
        mov [tempLenSqr1B], eax
        mov eax, [lenSqr2L]
        mov [tempLenSqr2L], eax
        mov eax, [lenSqr2B]
        mov [tempLenSqr2B], eax
        mov eax, [lenSqr1L]
        mov [tempLenSqr3L], eax
        mov eax, [lenSqr1B]
        mov [tempLenSqr3B], eax
        call Check
        cmp eax, 1
        jne CanNot
        push strYes
        call [printf]
        add esp, 4
        ret
CanNot:
        push strNo
        call [printf]
        add esp, 4
        ret
;--------------------------------------------------------------------------
Check:
        mov eax, 0
        mov [fl], eax

        mov eax, [tempLenSqr1L]
        add eax, [tempLenSqr2L]
        jnc NoAddCheck
        mov [temp], eax
        mov eax, 1
        mov [fl], eax
        mov eax, [temp]
NoAddCheck:
        cmp eax, [tempLenSqr3L]
        je CheckB
        mov eax, 0
        ret
CheckB:
        mov eax, [tempLenSqr1B]
        add eax, [tempLenSqr2B]
        add eax, [fl]
        cmp eax, [tempLenSqr3B]
        je CheckOk
        mov eax, 0
        ret
CheckOk:
        mov eax, 1
        ret
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'