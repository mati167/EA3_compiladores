include macros2.asm
include number.asm

.MODEL LARGE
.386
.STACK 200h

.DATA

S_1      db      ""Ingrese un valor pivot mayor o igual a 1: "", '$'
pivot        dd      ?
resul        dd      ?
_1       dd      1
_2       dd      2
_3       dd      3
_4       dd      4
_5       dd      5
_6       dd      6
S_2      db      ""Elemento encontrado en posicion: "", '$'
@cont       dd  0
@1      dd  1


.CODE

MAIN:
MOV AX, @DATA
MOV DS, AX

     DisplayString S_1 
     newLine 
     GetFloat pivot
 BRANCH_5
     FLD @cont       
     FLD @1      
     FADD        
     FSTP @cont             


     FLD pivot       
     FLD _1     
     FCOMP      
     FFREE ST(0)    
     FSTSW AX       
     SAHF           

     JNE BRANCH_12              ;Salto al branch 
     FLD @cont          ;Cargo valor 
     FSTP resul             ; Se lo asigno a la variable que va a guardar el resultado 

     JMP BRANCH_42              ;Salto al branch 
 BRANCH_12
     FLD @cont       
     FLD @1      
     FADD        
     FSTP @cont             


     FLD pivot       
     FLD _2     
     FCOMP      
     FFREE ST(0)    
     FSTSW AX       
     SAHF           

     JNE BRANCH_18              ;Salto al branch 
     FLD @cont          ;Cargo valor 
     FSTP resul             ; Se lo asigno a la variable que va a guardar el resultado 

     JMP BRANCH_42              ;Salto al branch 
 BRANCH_18
     FLD @cont       
     FLD @1      
     FADD        
     FSTP @cont             


     FLD pivot       
     FLD _3     
     FCOMP      
     FFREE ST(0)    
     FSTSW AX       
     SAHF           

     JNE BRANCH_24              ;Salto al branch 
     FLD @cont          ;Cargo valor 
     FSTP resul             ; Se lo asigno a la variable que va a guardar el resultado 

     JMP BRANCH_42              ;Salto al branch 
 BRANCH_24
     FLD @cont       
     FLD @1      
     FADD        
     FSTP @cont             


     FLD pivot       
     FLD _4     
     FCOMP      
     FFREE ST(0)    
     FSTSW AX       
     SAHF           

     JNE BRANCH_30              ;Salto al branch 
     FLD @cont          ;Cargo valor 
     FSTP resul             ; Se lo asigno a la variable que va a guardar el resultado 

     JMP BRANCH_42              ;Salto al branch 
 BRANCH_30
     FLD @cont       
     FLD @1      
     FADD        
     FSTP @cont             


     FLD pivot       
     FLD _5     
     FCOMP      
     FFREE ST(0)    
     FSTSW AX       
     SAHF           

     JNE BRANCH_36              ;Salto al branch 
     FLD @cont          ;Cargo valor 
     FSTP resul             ; Se lo asigno a la variable que va a guardar el resultado 

     JMP BRANCH_42              ;Salto al branch 
 BRANCH_36
     FLD @cont       
     FLD @1      
     FADD        
     FSTP @cont             


     FLD pivot       
     FLD _6     
     FCOMP      
     FFREE ST(0)    
     FSTSW AX       
     SAHF           

     JNE BRANCH_42              ;Salto al branch 
     FLD @cont          ;Cargo valor 
     FSTP resul             ; Se lo asigno a la variable que va a guardar el resultado 

     JMP BRANCH_42              ;Salto al branch 
 BRANCH_42
     DisplayString S_2 
     newLine 
     DisplayFloat resul,2 
     newLine 


     mov AX, 4C00h   ; Genera la interrupcion 21h
     int 21h     ; Genera la interrupcion 21h

END MAIN
