%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

// Estructuras de datos
typedef struct{
    char nombre[51];
	char tipoDato[51];
	char valor[51];
	char longitud[51];
}t_datoTS;

//funciones
int cant_reglas;
char lista_reglas[1000][300];
void insertar_regla(char* regla);
void generar_archivo_reglas(); 


// Variables globales
FILE *yyin;
FILE *ts;


/**** INICIO TERCETOS ****/

int Indprog;
int Indsent;
int Indread;
int Indasig;
int Indposicion;
int Indlista;
int Indwrite;
int Indresult;

struct terceto {
	char *uno;
	char *dos;
	char *tres;
};
struct terceto tercetos[1000];
int terceto_index = 100;

int crearTerceto_ccc(char *uno, char *dos, char *tres);
int crearTerceto_cci(char *uno, char *dos, int tres);
int crearTerceto_cii(char *uno, int dos, int tres);
int crearTerceto_fcc(float uno, char *dos, char *tres);
int crearTerceto_icc(int uno, char *dos, char *tres);
int crearTerceto_cic(char *uno, int dos, char *tres);

void save_tercetos();
/**** FIN TERCETOS ****/



/**** Inicio assembler ****/
char lista_operandos_assembler[100][100];
int cant_op = 0;

void genera_asm();
char* guardadoEnTabla(char *cte_o_id);
char* getCodOp(char*);



int lista_valores = 0;



/**** Fin assembler ****/

// Cabeceras de funciones
int yylex();
int yyerror();
int crearTS();
%}

%union
{
	char *id;
	int ent;
	char *cad;
}

%token PARA
%token PARC
%token CA
%token CC
%token PYC
%token COMA
%token ASIGNA
%token MAS
%token POSICION
%token WRITE
%token READ
%token <id> ID
%token <ent> CTE
%token <cad> CTE_S

%%

S: prog	
	{
		Indsent = Indprog;
		insertar_regla("S -> prog");
		generar_archivo_reglas();
		genera_asm();
		printf("\nCompilacion OK.\n");
	}

prog: sent
		{
			Indprog = Indsent;
			insertar_regla("prog -> sent");
			printf("%s\n", "1");
		}

prog: prog sent 
		{
			Indprog = Indsent;
			insertar_regla("prog -> prog sent");
			printf("%s\n", "1");
		}

sent: read {
			Indsent = Indread;
			insertar_regla("sent -> read");
			//printf("%s\n", "3");
		} |
		write {
			Indsent = Indwrite;
			insertar_regla("sent -> write");
			//printf("%s\n", "4");
		}| 
		asig
		{
			Indsent = Indasig;
			insertar_regla("sent -> asig");
			//printf("%s\n", "5");
		}

read: READ  ID {
			Indread = crearTerceto_cic("READ",crearTerceto_ccc($2, "",""),"");
			insertar_regla("read -> READ ID");
			//printf("%s\n", "6");
		}

asig:  ID  ASIGNA

		{ Indasig = crearTerceto_ccc($1, "",""); }
		posicion
		{
			insertar_regla("asig -> ID ASIGNA posicion");
			 // Indasig = crearTerceto_cii("=",Indasig,Indposicion);
				Indasig = Indresult; 
		}

posicion:  POSICION PARA ID PYC CA 

		{	Indposicion = crearTerceto_ccc($3, "","");
			Indposicion = crearTerceto_cic("POSICION",Indposicion,"");
		}

		lista CC PARC
		{
			insertar_regla("posicion -> POSICION PARA ID PYC CA lista CC PARC");
			 //Indposicion = crearTerceto_cii("POSICION",Indposicion,Indlista);
			 printf("lista tiene: %d\n", lista_valores);
		}

posicion: POSICION PARA ID PYC CA CC PARC
		{
			insertar_regla("posicion -> POSICION PARA ID PYC CA CC PARC");
			Indposicion = crearTerceto_cii("POSICION",crearTerceto_ccc($3, "",""),Indposicion);
			printf("lista tiene: %d\n", lista_valores);
		}

lista: CTE
		{
			printf(" la constante sola es: %d\n", $1);
			insertar_regla("lista -> CTE");
			Indlista = crearTerceto_cii("CMP",Indposicion,crearTerceto_icc($1,"",""));
			crearTerceto_cic("BNE",terceto_index+3,"");
			Indresult = crearTerceto_cii("=",Indasig,Indlista);
			crearTerceto_ccc("BI","","");
			lista_valores++;
		}

lista: lista COMA CTE
		{
			//crearTerceto_ccc("BRANCH","","");
			insertar_regla("lista -> lista COMA CTE");
			Indlista = crearTerceto_cii("CMP",Indposicion,crearTerceto_icc($3,"",""));
			crearTerceto_cic("BNE",terceto_index+3,"");
			Indresult = crearTerceto_cii("=",Indasig,Indlista);
			crearTerceto_ccc("BI","","");
			lista_valores++;
		}

write: WRITE CTE_S	{
			insertar_regla("write -> WRITE CTE_S");
			Indwrite = crearTerceto_cic("WRITE",crearTerceto_ccc($2, "",""),"");
			//printf("%s\t%s\n", $1 "12");
		}

write:  WRITE ID
		{
			insertar_regla("write -> WRITE ID");
			Indwrite = crearTerceto_cic("WRITE",crearTerceto_ccc($2, "",""),"");
		}



%%

int main(int argc,char *argv[])
{
	
	if ((yyin = fopen(argv[1], "rt")) == NULL)
	{
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}
	else
	{
		if (crearTS()) 
		{
		
			yyparse();
			save_tercetos();
		}
		else 
		{
			printf("error");
			return 2;
		}
	}
	
  	fclose(yyin);
  	return 0;
}

int yyerror(void)
{
   	printf("Syntax Error\n");
	system ("Pause");
	exit (1);
}

int crearTS()
{
	if ((ts = fopen("ts.txt", "wt")) == NULL)
	{
		printf("No se puede abrir el archivo ts.txt\n");
		return 0;
	}
	else 
	{
		fprintf(ts, "%s\n", "NOMBRE                                    |TIPODATO                        |VALOR                                   |LONGITUD");
		fprintf(ts, "%s\n", "-----------------------------------------------------------------------------------------------------------------------------");
	}
	fclose(ts);
	return 1;
}


/* Tercetos */
int crearTerceto_ccc(char *uno, char *dos, char *tres) {
	struct terceto terc;
	int index = terceto_index;
	terc.uno = malloc(sizeof(char)*strlen(uno));
	strcpy(terc.uno, uno);
	terc.dos = malloc(sizeof(char)*strlen(dos));
	strcpy(terc.dos, dos);
	terc.tres = malloc(sizeof(char)*strlen(tres));
	strcpy(terc.tres, tres);
	tercetos[index] = terc;
	terceto_index++;
	return index; // devuelvo la pos del terceto creado
}

int crearTerceto_cci(char *uno, char *dos, int tres) {
	char *tres_char = (char*) malloc(sizeof(int));
	itoa(tres, tres_char, 10);

	return crearTerceto_ccc(uno, dos, tres_char);
}

int crearTerceto_cii(char *uno, int dos, int tres) {
	struct terceto terc;
	int index = terceto_index;

	char *dos_char = (char*) malloc(sizeof(int));
	itoa(dos, dos_char, 10);

	return crearTerceto_cci(uno, dos_char, tres);
}

int crearTerceto_fcc(float uno, char *dos, char *tres) {
	char *uno_char = (char*) malloc(sizeof(float));
	snprintf(uno_char, sizeof(float), "%f", uno);

	return crearTerceto_ccc(uno_char, dos, tres);
}

int crearTerceto_icc(int uno, char *dos, char *tres) {
	char *uno_char = (char*) malloc(sizeof(int));
	itoa(uno, uno_char, 10);

	return crearTerceto_ccc(uno_char, dos, tres);
}

int crearTerceto_cic(char *uno, int dos, char *tres) {
	char *dos_char = (char*) malloc(sizeof(int));
	itoa(dos, dos_char, 10);

	return crearTerceto_ccc(uno, dos_char, tres);
}

void save_tercetos() {
	FILE *file = fopen("Intermedia.txt", "wt");

	if(file == NULL)
	{
    	printf("(!) ERROR: No se pudo abrir el txt correspondiente a la generacion de codigo intermedio\n");
	}
	else
	{
		int i = 100;
		for (i;i<terceto_index;i++) {
			// printf("%d (%s, %s, %s)\n", i, tercetos[i].uno, tercetos[i].dos, tercetos[i].tres);
			fprintf(file, "%d (%s, %s, %s)\n", i, tercetos[i].uno, tercetos[i].dos, tercetos[i].tres);
		}
		fclose(file);
	}
}

/*
Inserta regla en la lista para dsp imprimir el archivo
*/
void insertar_regla(char* regla)
{
	//printf("	CANT %d ; REGLA %s \n", cant_reglas, regla);
	strcpy(lista_reglas[cant_reglas], regla);
	cant_reglas++;
}

/*
	Genera el archivo de reglas
*/
void generar_archivo_reglas() 
{
	FILE *file = fopen("reglas_involucradas.txt", "wt");
	
	int i;
	for(i=0;i<cant_reglas;i++)
	{
		fprintf(file, "%s\n", lista_reglas[i]);
	}
	fclose(file);
}


void genera_asm()
{
	int cont=0;
	char* file_asm = "Final.asm";
	FILE* pf_asm;
	char aux[10];
	
	int lista_etiquetas[1000];
	int cant_etiquetas = 0;
	char etiqueta_aux[10];

	char ult_op1_cmp[30];
	strcpy(ult_op1_cmp, "");
	char op1_guardado[30];

	if((pf_asm = fopen(file_asm, "wt")) == NULL)
	{
		printf("Error al generar el asembler \n");
		exit(1);
	}
	 /* generamos el principio del assembler, que siempre es igual */


	 fprintf(pf_asm, "include macros2.asm\n");
	 fprintf(pf_asm, "include number.asm\n");
	 fprintf(pf_asm, ".MODEL	LARGE \n");
	 fprintf(pf_asm, ".386\n");
	 fprintf(pf_asm, ".STACK 200h \n");

	 fprintf(pf_asm, ".CODE \n");
	 fprintf(pf_asm, "MAIN:\n");
	 fprintf(pf_asm, "\n");

    fprintf(pf_asm, "\n");
    fprintf(pf_asm, "\t MOV AX,@DATA 	;inicializa el segmento de datos\n");
    fprintf(pf_asm, "\t MOV DS,AX \n");
    fprintf(pf_asm, "\t MOV ES,AX \n");
    fprintf(pf_asm, "\t FNINIT \n");;
    fprintf(pf_asm, "\n");

	int i, j;
	int opSimple,  // Formato terceto (x,  ,  ) 
		opUnaria,  // Formato terceto (x, x,  )
		opBinaria; // Formato terceto (x, x, x)
	int agregar_etiqueta_final_nro = -1;
	
	// Armo el assembler
	for (i = 100; i < terceto_index; i++) 
	{
		//printf("TERCETO NUMERO %d \n", i);

		if (strcmp("", tercetos[i].dos) == 0) {
			opSimple = 1;
			opUnaria = 0;
			opBinaria = 0;
		} else if (strcmp("", tercetos[i].tres) == 0) {
			opSimple = 0;
			opUnaria = 1;
			opBinaria = 0;
		} else {
			opSimple = 0; 
			opUnaria = 0;
			opBinaria = 1;
		}

		for (j=101;j<=cant_etiquetas;j++) {
			if (i == lista_etiquetas[j])
			{
				sprintf(etiqueta_aux, "ETIQ_%d", lista_etiquetas[j]);
				fprintf(pf_asm, "%s: \n", etiqueta_aux);
			}
		}
		if (opSimple == 1) {
			// Ids, constantes
			cant_op++;
			strcpy(lista_operandos_assembler[cant_op], tercetos[i].uno);
		} 

	}




		 fclose(pf_asm);
	
}