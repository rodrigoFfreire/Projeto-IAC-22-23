

rot_hexa_dec:
    PUSH R1
    PUSH R2
    PUSH R9

    MOV R1, 1000
    MOV R2, 10

    MOV R8, 0 ;inicialização do resultado decimal

    loop_hexa_dec:
        MOD R9, R1 
        DIV R1, R2

        CMP R1, 0 ; se for 0 termina o loop
        JNZ ret_hexa_dec

        MOV R3, R9
        DIV R3, R1

        SHL R8, 4 ;desloca para a esquerda para a entrada do novo digito
        OR R8, R3 ;vai escrevendo o resultado

        JMP loop_hexa_dec

    ret_hexa_dec:
    POP R9
    POP R3
    POP R2
    POP R1
    RET