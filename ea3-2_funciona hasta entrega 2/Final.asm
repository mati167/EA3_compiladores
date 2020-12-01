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


.CODE
START:
MOV AX, @DATA
MOV DS, AX

	 DisplayString S_1 
	 newLine 
	 GetFloat pivot
 BRANCH_6
	 JMP BRANCH_36 	;Salto al branch 
 BRANCH_14
	 JMP BRANCH_30 	;Salto al branch 
 BRANCH_20
	 JMP BRANCH_24 	;Salto al branch 
 BRANCH_26
	 JMP BRANCH_18 	;Salto al branch 
 BRANCH_32
	 JMP BRANCH_12 	;Salto al branch 
 BRANCH_38
	 JMP BRANCH_6 	;Salto al branch 
	 DisplayString S_2 
	 newLine 
	 DisplayString S_2 
	 newLine 
