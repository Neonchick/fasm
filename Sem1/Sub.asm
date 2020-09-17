format PE console
entry start
include 'win32a.inc'
section '.data' data readable writable
        formatNum db ' %d', 0

        A rd 1
        B rd 1

        fn db 'Write first number: ', 0
        sn db 'Write second number: ', 0
        rs db 'Result: %d', 0

        NULL = 0

section '.code' code readable executable

        start:
                push fn
                call [printf]

                push A
                push formatNum
                call [scanf]

                push sn
                call [printf]

                push B
                push formatNum
                call[scanf]

                mov ecx, [A]
                sub ecx, [B]

                push ecx
                push rs
                call [printf]

                call [getch]

                push NULL
                call [ExitProcess]

section '.idata' import data readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess'

        import msvcrt,\
               printf, 'printf', \
               getch,      '_getch',\
                scanf, 'scanf'
