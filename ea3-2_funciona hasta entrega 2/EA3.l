%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

// Estructuras de datos
typedef struct filaTS {
	char nombre[50];
	char tipo[50];
} filaTS;

filaTS regTS;

// Variables globales
FILE *yyin;
FILE *ts;

// Cabeceras de funciones
int yylex();
void insertarEnTS(char *yytext, int isString);
void insertarVarEnTS();
int guardadoEnTabla(char *nombre, int var);
void removerComillas(char *str, char *aux);
char * removerEspacios(char *str);
char * removerDosPuntos(char *str);
%}

%option noyywrap  
%option yylineno 

DIGITO				[0-9]
LETRA				[a-zA-Z]
SIMBOLO				(" "|":"|"\n"|"\t")
ID					{LETRA}({LETRA}|{DIGITO})*
CTE					{DIGITO}+
CTE_S				\"({SIMBOLO}|{LETRA}|{DIGITO})+\"

%%
"="			    { return ASIGNA; }
"("				{ return PARA; }
")"				{ return PARC; }
"["             { return CA; }
"]"             { return CC; }
";"             { return PYC; }
","             { return COMA; }
"posicion"		{return	POSICION;}
"READ"			{return READ;}
"WRITE"			{return WRITE;}

{ID}				{
						if(!guardadoEnTabla(yytext,1))
						{
							strcpy(regTS.nombre, yytext);
							insertarVarEnTS();
						}
						yylval.id = strdup(yytext);
						return ID;
					}
{CTE}				{
						insertarEnTS(yytext, 0); 
						yylval.ent=atoi(yytext);
						return CTE;
					}
{CTE_S}				{
						insertarEnTS(yytext, 1); 
						yylval.cad = strdup(yytext); 
						return CTE_S;
					}
" "					{ }
"\n"      		
"\t"		
%%

void insertarEnTS(char *yytext, int isString)
{
	if(!guardadoEnTabla(yytext,0))
	{
		if ((ts = fopen("ts.txt", "a")) == NULL)
		{
			printf("No se puede abrir el archivo ts.txt\n");
		}
		
		else 
		{
			
			if (isString   )
			{
				
				char *str = yytext + 1;
				char *aux = malloc(sizeof(char)*40);
				char *sinEspacios = malloc(sizeof(char)*40);
				char *sinDosPuntos = malloc(sizeof(char)*40);
				
				removerComillas(str, aux);
				
				sinEspacios = removerEspacios(aux);
				
				sinDosPuntos = removerDosPuntos(sinEspacios);

				fprintf(ts, "_%-41s | %-30s | %-38s | %-30d\n", sinDosPuntos, "", aux, strlen(aux));
				
				/*
				free(aux);
				printf("antes de los free\n");
				free(sinEspacios);
				free(sinDosPuntos);
				*/
			}
			else 
			{
				fprintf(ts, "_%-41s | %-30s | %-38s | \n", yytext, "", yytext);
			}
			
		}
		fclose(ts);
	}
}

void insertarVarEnTS() 
{
	if ((ts = fopen("ts.txt", "a")) == NULL)
	{
		printf("No se puede abrir el archivo: ts.txt\n");
	}
	else 
	{
		fprintf(ts, "%-41s | %-30s | %-38s | \n", regTS.nombre, regTS.tipo, "-");
	}
	fclose(ts);
}

int guardadoEnTabla(char *nombre, int var)
{
    char str[200];
	char nom[50];
	char nompar[50];
	if (!var)
	{
		char par[50];
		strcpy(nompar,"");
		strcpy(par,"");
		strcpy(par,"_");
		strcat(nompar, par);
		strcat(nompar, nombre);
	}
	else
	{
		strcpy(nompar,nombre);
	}
	
    if ((ts = fopen("ts.txt", "r")) == NULL)
    {
        printf("No se puede abrir el archivo ts.txt\n");
    }
    else
    {
        while(fgets(str,200,ts)!=NULL)
		{
			sscanf( str, "%s", nom );
			if(strcmp(nompar, nom)==0)
			{
			    fclose(ts);
				return 1;
			}
        }
    }
    fclose(ts);
    return 0;
}

void removerComillas(char *str, char *aux)
{
    int longStr = strlen(str);
	
    strncpy(aux, str, longStr);
    *(aux + longStr - 1) = '\0';
	
}

char * removerEspacios(char *str)
{
	int longStr = strlen(str);
	int i;
	char *sinEspacios = strdup(str);
	
	for(i = 0; i < longStr; i++)
	{
		if (*(sinEspacios + i) == ' ') 
		{
			*(sinEspacios + i) = '_';
		}
	}
	
	return sinEspacios;
}

char * removerDosPuntos(char *str)
{
    int longStr = strlen(str);
	char *aux = strdup(str);
	char *ultDP = strrchr(aux, ':');
	
    *(ultDP) = '\0';
	
	return aux;
}