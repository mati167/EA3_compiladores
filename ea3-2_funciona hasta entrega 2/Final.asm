include macros2.asm
include number.asm
.MODEL	LARGE 
.386
.STACK 200h 
.CODE 
MAIN:


	 MOV AX,@DATA 	;inicializa el segmento de datos
	 MOV DS,AX 
	 MOV ES,AX 
	 FNINIT 

