KEY_START_GAME EQU 0CH

main_menu:
    PUSH R0
    PUSH R1

    loop_main_menu:
        CALL keyboard_listner
        MOV R0, [LAST_PRESSED_KEY]
        MOV R1, KEY_START_GAME
        CMP R0, R1
        JNZ loop_main_menu

    POP R0
    POP R1
    RET