format PE console
entry start
include 'win32a.inc'
section '.data' data readable writable
        formatNum db ' %d', 0

        A rd 1
        B rd 1
        C rd 1

        fn db 'Write first number: ', 0
        sn db 'Write second number: ', 0
        frn db 'Write third number: ', 0
        rs db 'Max: %d', 0

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

                push frn
                call [printf]

                push C
                push formatNum
                call[scanf]

                mov ecx, [A]

                cmp ecx, [B]
                jg nextCmp

                mov ecx, [B]

                nextCmp:
                        cmp ecx, [C]
                        jg result

                        mov ecx, [C]

                result:

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
