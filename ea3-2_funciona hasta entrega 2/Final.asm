include macros2.asm
include number.asm

.MODEL SMALL
.386
.STACK 200h

.DATA
NEW_LINE DB 0AH,0DH,'$'
CWprevio DW ?
è· db ""Ingrese un valor pivot mayor o igual a 1: "", '$'
(·· db ""Elemento encontrado en posicion: "", '$'

.CODE
START:
MOV AX, @DATA
MOV DS, AX
FINIT

