format PE console
entry start
include 'win32a.inc'
section '.data' data readable writable
        formatNum db ' %d', 0

        N rd 1
        X rd 1

        fn db 'Write count of numbers: ', 0
        nn db 'Write number: ', 0
        er db 'Count mast be more than 0', 0
        rs db 'Min: %d', 0

        NULL = 0

section '.code' code readable executable

        start:
                push fn
                call [printf]

                push N
                push formatNum
                call [scanf]

                mov ecx, [N]
                cmp ecx, 0
                jg enterall

                push er
                call [printf]
                jmp allend

                enterall:
                push nn
                call [printf]

                push X
                push formatNum
                call[scanf]

                mov ebx, [X]

                mov edi, [N]
                dec edi

                lp:

                cmp edi, 0
                jz res

                push nn
                call [printf]

                push X
                push formatNum
                call[scanf]

                cmp ebx, [X]
                jl nextCmp

                mov ebx, [X]

                nextCmp:
                dec edi
                jmp lp

                res:
                push ebx
                push rs
                call [printf]

                allend:

                call [getch]

                push NULL
                call [ExitProcess]

section '.idata' import data readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import          kernel,\
                GetStdHandle,'GetStdHandle',\ 
                WriteConsole,'WriteConsoleA',\
                ReadConsole,'ReadConsoleA',\
                ExitProcess,'ExitProcess'

        import msvcrt,\
               printf, 'printf', \
               getch,      '_getch',\
                scanf, 'scanf'
