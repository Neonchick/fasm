;Номер варианта: 14
;Задание: Разработать программу, которая вводит одномерный массив A[N],
;формирует из элементов массива А новый массив В с заменой всех
;отрицательных элементов значением максимального.
format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'Size of vector? ', 0
        strIncorSize db 'Incorrect value', 10, 0
        strVecA db 10, 'Vector A:', 10, 0
        strVecB db 10, 'Vector B:', 10, 0
        strVecElemI  db '[%d]? ', 0
        strScanInt   db '%d', 0
        strMaxValue  db 10, 'Max = %d', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        vec_size     dd 0
        max          dd 0
        i            dd ?
        tmp          dd ?
        bel          dd ?
        tva          dd ?
        tvb          dd ?
        tmpStack     dd ?
        vec          rd 100
        vecb         rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector input
        call VectorInput
; 2) get vector max
        call VectorMax
; 3) out of sum
        push [max]
        push strMaxValue
        call [printf]
; 4) create vector B
        call CreateVectorB
; 5) vector A output
        push strVecA
        call [printf]
        mov ebx, vec
        call VectorOut
; 5) vector B output
        push strVecB
        call [printf]
        mov ebx, vecb
        call VectorOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        cmp eax, 1
        jne error
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jle error
        cmp eax, 100
        jg  error
        jmp getVector
; fail size
error:
        push [vec_size]
        push strIncorSize
        call [printf]
        jmp finish
; else continue...
getVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        cmp eax, 1
        jne error
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;--------------------------------------------------------------------------
VectorMax:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec
        mov eax, [ebx]
        mov [max], eax
        jmp oldMax
maxVecLoop:
        cmp ecx, [vec_size]
        je endMaxVector      ; to end of loop
        mov eax, [ebx]
        cmp [max], eax
        jge oldMax
        mov [max], eax

oldMax:
        inc ecx
        add ebx, 4
        jmp maxVecLoop
endMaxVector:
        ret
;--------------------------------------------------------------------------
CreateVectorB:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec
        mov [tva], ebx
        mov ebx, vecb
        mov [tvb], ebx
        mov ebx, 0
createVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endCreateVector       ; to end of loop

        ; input element
        mov [i], ecx

        add ebx, vec
        mov eax, [ebx]
        mov [bel], eax
        cmp eax, 0
        jge notNegative
        mov eax, [max]
        mov [bel], eax

notNegative:
        mov ebx, [tmp]
        add ebx, vecb
        mov eax, [bel]
        mov [ebx], eax

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp createVecLoop
endCreateVector:
        ret
;--------------------------------------------------------------------------
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        je endOutputVector      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop
endOutputVector:
        mov esp, [tmpStack]
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