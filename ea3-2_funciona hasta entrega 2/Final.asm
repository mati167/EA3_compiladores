include macros2.asm
include number.asm

.MODEL SMALL
.386
.STACK 200h

.DATA

S_1	 db	 ""Ingrese un valor pivot mayor o igual a 1: "", '$'
pivot	 dd	 ?
resul	 dd	 ?
_1	 dd	 1
_2	 dd	 2
_3	 dd	 3
_4	 dd	 4
_5	 dd	 5
_6	 dd	 6
S_2	 db	 ""Elemento encontrado en posicion: "", '$'
@cont	dd	0
_1_	dd	1


.CODE
START:
MOV AX, @DATA
MOV DS, AX

	 DisplayString S_1 
	 newLine 
	 GetFloat pivot
 BRANCH_5
	 JNE BRANCH_12 				;Salto al branch 
	 JMP BRANCH_42 				;Salto al branch 
 BRANCH_12
	 JNE BRANCH_18 				;Salto al branch 
	 JMP BRANCH_42 				;Salto al branch 
 BRANCH_18
	 JNE BRANCH_24 				;Salto al branch 
	 JMP BRANCH_42 				;Salto al branch 
 BRANCH_24
	 JNE BRANCH_30 				;Salto al branch 
	 JMP BRANCH_42 				;Salto al branch 
 BRANCH_30
	 JNE BRANCH_36 				;Salto al branch 
	 JMP BRANCH_42 				;Salto al branch 
 BRANCH_36
	 JNE BRANCH_42 				;Salto al branch 
	 JMP BRANCH_42 				;Salto al branch 
 BRANCH_42
	 DisplayString S_2 
	 newLine 
	 DisplayString S_2 
	 newLine 
