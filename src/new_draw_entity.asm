update_object:
    MOV [DELETE_LAYER], R5  ; Deletes previous frame for layer stored in R5

	MOV [R2], R3  ; UPDATE MEMORY OF OBJECT WITH NEW X POSITION
	MOV [R2+2], R4  ; UPDATE MEMORY OF OBJECT WITH NEW Y POSITION

    CALL draw_entity ; DRAW OBJECT IN NEW COORDINATES 

    RET


; ***************************************************************************
; * DRAW ENTITY
; * Arguments
; *     - R2 -> Base address of entity/object
; * _________________________________________________________________________
; R0 - Entity/object base address
; R1 - Sprite base address
; R2 - Length of sprite, current x pos
; R3 - Height of sprite, current y pos
; R5 - Sprite Table y pos
; R6 - Sprite Table x pos
; R7 - Address of pixel color
; ***************************************************************************
draw_entity:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R5
    PUSH R6
    PUSH R7
    MOV R0, [R2+6] ; Get base address of sprites
    
    MOV R1, [R0]   ; Sprite length
    MUL R1, [R0+2] ; Multiply with sprite height to get sprite area
    MUL R1, 2      ; Multiply by 2 for correct memory address
    ADD R1, 4      ; Add 4 to skip to next subsprite length (subsprite mapping offset)
    
    MOV R0, R2     ; Get base address of entity
    MUL R1, [R0+4] ; Finally multiply by subsprite index to get base address of current subsprite

    MOV R2, [R1]   ; Length of sprite
    MOV R3, [R1+2] ; Height of sprite  

    MOV R5, -1 ; Start at -1 to account for first ADD
    draw_from_table:
        ADD R5, 1  ; Increment Sprite table to next line
        CMP R5, R3 ; Reached last pixel already if so end draw loop?
        JZ end_draw_entity ; All pixels rendered
        MOV R6, 0 ; Start Sprite Table x pos at 0 (columns)
        inner_loop:
            CALL check_pixel_address ; Check if the current pixel is invisble and therefore skippable and calculate offsets
            JZ skip_draw
            CALL draw_pixel ; dont skip so draw pixel
            
            skip_draw:
                ADD R6, 1  ; Next column
                CMP R6, R2 ; Reached last pixel of line?
                JZ draw_from_table ; If so go to next line
                JMP inner_loop ; Continue drawing line

    end_draw_entity:
        POP R7
        POP R6
        POP R5
        POP R3
        POP R2
        POP R1
        POP R0
        RET

draw_pixel:
    PUSH R2
    PUSH R3

    MOV R2, [R0]   ; Current x coord
    MOV R3, [R0+2] ; Current y coord
    ADD R2, R6     ; Add x coord + offset for correct column
    ADD R3, R5     ; Add y coord + offset for correct line
    
    MOV [SET_COLUMN], R2 ; Set pixel column
    MOV [SET_LINE], R3   ; Set pixel Line
    MOV R2, [R7]         ; get color from address of pixel - R7 calculated by check_pixel_adress
    
    MOV [SET_PIXEL], R2 ; Draw pixel

    POP R3
    POP R2
    RET 

; Calculates the address of a given pixel from its table
; Saves that value in R7
check_pixel_address:
    PUSH R0
    PUSH R5
    PUSH R6

    MOV R7, [R1] ; Get sprite length
    MUL R5, R7   ; 2D coords into 1D -> length*x + y
    ADD R5, R6   ; 2D coords into 1D -> length*x + y
    SHL R5, 1    ; Multiply by 2 due to byte-adressable memory design (only pair addresses)
    ADD R5, 4    ; Add offset of 4 because the table starts at (Base Address + 4)
    ADD R5, R1   ; Add the base address of object and get final address
    
    MOV R7, R5   ; Save it in R7
    MOV R0, [R7] ; Read the value (color)
    CMP R0, 0 ; check if pixel is empty for later

    POP R6
    POP R5
    POP R0
    RET