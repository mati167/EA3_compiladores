include macros2.asm
include number.asm

.MODEL LARGE
.386
.STACK 200h

.DATA

S_1		 db		 "Ingrese un valor pivot mayor o igual a 1: ", '$', 44 dup (?)
pivot		 dd		 ?
resul		 dd		 ?
_2		 dd		 2
_3		 dd		 3
_4		 dd		 4
_1		 dd		 1
_5		 dd		 5
S_2		 db		 "Elemento no encontrado", '$', 24 dup (?)
S_3		 db		 "Elemento encontrado en posicion: ", '$', 35 dup (?)
@cont	dd	0
@0		dd	0
@1		dd	1


.CODE

MAIN:
MOV AX, @DATA
MOV DS, AX

	 DisplayString S_1 
	 newLine 
	 GetInteger pivot
	NEWLINE
 BRANCH_5:
	 FLD @cont		 
	 FLD @1		 
	 FADD 		 
	 FSTP @cont 			


	 FLD pivot		 
	 FLD _2		
	fxch
	fcom
	fstsw AX
	sahf

	 JNE BRANCH_12 				;Salto al branch 
	 FLD @cont 			;Cargo valor 
	 FSTP resul 			; Se lo asigno a la variable que va a guardar el resultado 

	 JMP BRANCH_36 				;Salto al branch 
 BRANCH_12:
	 FLD @cont		 
	 FLD @1		 
	 FADD 		 
	 FSTP @cont 			


	 FLD pivot		 
	 FLD _3		
	fxch
	fcom
	fstsw AX
	sahf

	 JNE BRANCH_18 				;Salto al branch 
	 FLD @cont 			;Cargo valor 
	 FSTP resul 			; Se lo asigno a la variable que va a guardar el resultado 

	 JMP BRANCH_36 				;Salto al branch 
 BRANCH_18:
	 FLD @cont		 
	 FLD @1		 
	 FADD 		 
	 FSTP @cont 			


	 FLD pivot		 
	 FLD _4		
	fxch
	fcom
	fstsw AX
	sahf

	 JNE BRANCH_24 				;Salto al branch 
	 FLD @cont 			;Cargo valor 
	 FSTP resul 			; Se lo asigno a la variable que va a guardar el resultado 

	 JMP BRANCH_36 				;Salto al branch 
 BRANCH_24:
	 FLD @cont		 
	 FLD @1		 
	 FADD 		 
	 FSTP @cont 			


	 FLD pivot		 
	 FLD _1		
	fxch
	fcom
	fstsw AX
	sahf

	 JNE BRANCH_30 				;Salto al branch 
	 FLD @cont 			;Cargo valor 
	 FSTP resul 			; Se lo asigno a la variable que va a guardar el resultado 

	 JMP BRANCH_36 				;Salto al branch 
 BRANCH_30:
	 FLD @cont		 
	 FLD @1		 
	 FADD 		 
	 FSTP @cont 			


	 FLD pivot		 
	 FLD _5		
	fxch
	fcom
	fstsw AX
	sahf

	 JNE BRANCH_36 				;Salto al branch 
	 FLD @cont 			;Cargo valor 
	 FSTP resul 			; Se lo asigno a la variable que va a guardar el resultado 

	 JMP BRANCH_36 				;Salto al branch 
 BRANCH_36:
	 DisplayString S_3 
	 newLine 
	 DisplayInteger resul 
	 newLine 


	 mov AX, 4C00h 	 ; Genera la interrupcion 21h
	 int 21h 	 ; Genera la interrupcion 21h

END MAIN
