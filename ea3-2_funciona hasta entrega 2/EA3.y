%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

#define TOTAL			50
#define	VARIABLE		0
#define STRING			1
#define	INTEGER			2


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
struct terceto tercetos[100];
int terceto_index = 0;

int crearTerceto_ccc(char *uno, char *dos, char *tres);
int crearTerceto_cci(char *uno, char *dos, int tres);
int crearTerceto_cii(char *uno, int dos, int tres);
int crearTerceto_fcc(float uno, char *dos, char *tres);
int crearTerceto_icc(int uno, char *dos, char *tres);
int crearTerceto_cic(char *uno, int dos, char *tres);

void save_tercetos();
/**** FIN TERCETOS ****/


/**** Inicio assembler ****/
struct tabla {
		char *nombre;
		int	var;
		char *valorS;
		int	valorI;
};


struct tabla variables_id[TOTAL];
int tablaIndex = 0;

char lista_operandos_assembler[100][100];
int cant_op = 0;

void genera_asm();
char* guardadoEnTabla(char *cte_o_id);
char* getCodOp(char*);

void generarInicio(FILE *arch);
void generarInicioCodigo(FILE* arch);
void generarFinal(FILE *arch);
void generarTabla(FILE *arch);

struct tabla buscarTipoTS(char* nombreVar);


void insertarentablaCTE_I(int cte);
void insertarentablaCTE_S(char *str);
void insertarentablaID(char* id);
char *generaNombreASM(char *str, int tipo);

int lista_valores = 0;
int total_variables = 0;
int contString = 0;



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
			printf("%s\n", "2");
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
			printf("%s\n", "6");
			
			insertarentablaID($2);
		}

asig:  ID  ASIGNA

		{ Indasig = crearTerceto_ccc($1, "","");
		insertarentablaID($1);
		}
		posicion
		{
			
			insertar_regla("asig -> ID ASIGNA posicion");
			 // Indasig = crearTerceto_cii("=",Indasig,Indposicion);
				Indasig = Indresult; 
		}

posicion:  POSICION PARA ID PYC CA 

		{	
			crearTerceto_cic("BRANCH",terceto_index,"");
			Indposicion = crearTerceto_ccc($3, "","");
			//Indposicion = crearTerceto_cic("POSICION",Indposicion,"");
			//insertarentablaID($3);
			
		}

		lista CC PARC
		{
			insertar_regla("posicion -> POSICION PARA ID PYC CA lista CC PARC");
			 //Indposicion = crearTerceto_cii("POSICION",Indposicion,Indlista);
			 printf("lista tiene: %d\n", lista_valores);
			 crearTerceto_ccc("BRANCH","_X_","");
		}

posicion: POSICION PARA ID PYC CA CC PARC
		{
			insertar_regla("posicion -> POSICION PARA ID PYC CA CC PARC");
			crearTerceto_ccc("BRANCH","_X_","");
			//Indposicion = crearTerceto_cii("POSICION",crearTerceto_ccc($3, "",""),Indposicion);
			Indposicion = crearTerceto_ccc($3, "","");
			printf("lista tiene: %d\n", lista_valores);
			//insertarentablaID($3);
			crearTerceto_ccc("BRANCH","_X_","");
		}

lista: CTE
		{
			printf(" la constante sola es: %d\n", $1);
			insertar_regla("lista -> CTE");
			Indlista = crearTerceto_cii("CMP",Indposicion,crearTerceto_icc($1,"",""));
			crearTerceto_cic("BNE",terceto_index+3,"");
			Indresult = crearTerceto_cii("=",Indasig,Indlista);
			crearTerceto_ccc("BI","_X_","");
			lista_valores++;
			insertarentablaCTE_I($1);
		}

lista: lista COMA CTE
		{
			crearTerceto_ccc("BRANCH","_X_","");
			insertar_regla("lista -> lista COMA CTE");
			Indlista = crearTerceto_cii("CMP",Indposicion,crearTerceto_icc($3,"",""));
			crearTerceto_cic("BNE",terceto_index+3,"");
			Indresult = crearTerceto_cii("=",Indasig,Indlista);
			crearTerceto_ccc("BI","_X_","");
			lista_valores++;
			insertarentablaCTE_I($3);
		}

write: WRITE CTE_S	{
			
			insertar_regla("write -> WRITE CTE_S");
			Indwrite = crearTerceto_cic("WRITE",crearTerceto_ccc($2, "",""),"");
			printf("%s\t%s\n", $2 ,"12");
			insertarentablaCTE_S($2);
			
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
	if ((ts = fopen("ts.txt", "w")) == NULL)
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
		int i = 0;
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


		generarInicio(pf_asm);
		generarTabla(pf_asm);
		generarInicioCodigo(pf_asm);

	int i, j;
	int opSimple,  // Formato terceto (x,  ,  ) 
		opUnaria,  // Formato terceto (x, x,  )
		opBinaria; // Formato terceto (x, x, x)
	int agregar_etiqueta_final_nro = -1;
	
		
	// Armo el assembler
	for (i = 0; i < terceto_index; i++) 
	{
		printf("\n%s\n",tercetos[i].uno);
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
		

		if (opSimple == 1) {
			// Ids, constantes
			cant_op++;
			strcpy(lista_operandos_assembler[cant_op], tercetos[i].uno);
		}
		else if (opUnaria == 1) {
			
			// Saltos, write, read
			
			if (strcmp("WRITE", tercetos[i].uno) == 0) 
			{	
				
				struct tabla dato = buscarTipoTS(tercetos[atoi(tercetos[i].dos)].uno);

				if(dato.var == STRING){
					
					fprintf(pf_asm, "\t DisplayString %s \n", dato.nombre);
					
					}
				else
					fprintf(pf_asm, "\t DisplayFloat %s,2 \n", dato.nombre);
				// Siempre inserto nueva linea despues de mostrar msj
					fprintf(pf_asm, "\t newLine \n");
					
			}
			else if (strcmp("READ", tercetos[i].uno) == 0) 
			{
					// pongo getfloat para manejar todo con fld en las operaciones
					fprintf(pf_asm, "\t GetFloat %s\n", tercetos[atoi(tercetos[i].dos)].uno);	
			}
			else // saltos
			{
				
				char *codigo = getCodOp(tercetos[i].uno);
				
				if(strcmp(codigo, "JMP") ==0 ){
					fflush(pf_asm); 
					fprintf(pf_asm, "\t %s BRANCH_%d \t\t\t\t;Salto al branch \n", codigo, i + (--lista_valores*6)+1);
					//lista_valores--;
				}
				else if(strcmp(codigo, "BRANCH") ==0){
				
					fflush(pf_asm); 
					fprintf(pf_asm, " BRANCH_%d\n", i);
				}
				else if(strcmp(codigo, "JNE") ==0){
					fflush(pf_asm); 
					fprintf(pf_asm, "\t %s BRANCH_%s \t\t\t\t;Salto al branch \n", codigo,tercetos[i].dos);
				}
			}
 		}/*
		else {
			// Expresiones ; Comparaciones ; Asignacion
			char *op2 = (char*) malloc(100*sizeof(char));
			strcpy(op2, lista_operandos_assembler[cant_op]);
			cant_op--;

			char *op1 = (char*) malloc(100*sizeof(char));
			if (strcmp(tercetos[i].uno, "CMP" ) == 0 && strcmp(ult_op1_cmp, tercetos[i].dos) == 0 )
			{
				strcpy(op1, op1_guardado);
			}
			else 
			{
				strcpy(op1, lista_operandos_assembler[cant_op]); 
				cant_op--;
				strcpy(op1_guardado, op1);
			}
			
			if (strcmp(tercetos[i].uno, "=" ) == 0)
			{
				int tipo = buscarTipoTS(tercetos[atoi(tercetos[i].dos)].uno);
				if (tipo == Float | tipo == Integer) // Si se quiere separar integer hay que ver tambien las expresiones
				{
					fprintf(pf_asm, "\t FLD %s \t;Cargo valor \n", guardadoEnTabla(op1));
					fprintf(pf_asm, "\t FSTP %s \t; Se lo asigno a la variable que va a guardar el resultado \n", guardadoEnTabla(op2));
				}
				else
				{0
					fprintf(pf_asm, "\t mov si,OFFSET %s \t;Cargo en si el origen\n", guardadoEnTabla(op1));
					fprintf(pf_asm, "\t mov di,OFFSET %s \t; cargo en di el destino \n", guardadoEnTabla(op2));
					fprintf(pf_asm, "\t STRCPY\t; llamo a la macro para copiar \n");
				}	
			}
			else if (strcmp(tercetos[i].uno, "CMP" ) == 0)
			{
				int tipo = buscarTipoTS(op1);
				if (tipo == Float | tipo == Integer) 
				{
					fprintf(pf_asm, "\t FLD %s\t\t;comparacion, operando1 \n", guardadoEnTabla(op1));
					fprintf(pf_asm, "\t FLD %s\t\t;comparacion, operando2 \n", guardadoEnTabla(op2));
					fprintf(pf_asm, "\t FCOMP\t\t;Comparo \n");
					fprintf(pf_asm, "\t FFREE ST(0) \t; Vacio ST0\n");
					fprintf(pf_asm, "\t FSTSW AX \t\t; mueve los bits C a FLAGS\n");
					fprintf(pf_asm, "\t SAHF \t\t\t;Almacena el registro AH en el registro FLAGS \n");
				}
				else
				{
					fprintf(pf_asm, "\t mov si,OFFSET %s \t;Cargo operando1\n", guardadoEnTabla(op1));
					fprintf(pf_asm, "\t mov di,OFFSET %s \t; cargo operando2 \n", guardadoEnTabla(op2));
					fprintf(pf_asm, "\t STRCMP\t; llamo a la macro para comparar \n");	
				}

				strcpy(ult_op1_cmp, tercetos[i].dos);
			}
			else
			{
				sprintf(aux, "_aux%d", i); // auxiliar relacionado al terceto
				fflush(pf_asm);
				fprintf(pf_asm, "\t FLD %s \t;Cargo operando 1\n", guardadoEnTabla(op1));
				fprintf(pf_asm, "\t FLD %s \t;Cargo operando 2\n", guardadoEnTabla(op2));
				fflush(pf_asm);

				fprintf(pf_asm, "\t %s \t\t;Opero\n", getCodOp(tercetos[i].uno));
				fprintf(pf_asm, "\t FSTP %s \t;Almaceno el resultado en una var auxiliar\n", guardadoEnTabla(aux));
				
				cant_op++;
				strcpy(lista_operandos_assembler[cant_op], aux);
			}*/

	}

		 fclose(pf_asm);
	
}

void generarInicio(FILE *arch){
  fprintf(arch, "include macros2.asm\ninclude number.asm\n\n.MODEL SMALL\n.386\n.STACK 200h\n\n");
}

void generarInicioCodigo(FILE* arch){
	fprintf(arch, ".CODE\nSTART:\nMOV AX, @DATA\nMOV DS, AX\n\n");
}

void generarFinal(FILE *arch){
    fprintf(arch, "\nMOV AH, 1\nINT 21h\nMOV AX, 4C00h\nINT 21h\n\nEND START\n");
	// TODO: Preguntar por flags y escribir subrutinas
}

void generarTabla(FILE *arch){
	int fin_tabla;
    fprintf(arch, ".DATA\n\n");

    for(int i=0; i<total_variables; i++){
		printf("NOMBRE ASSEMBLER:	%s\n", variables_id[i].nombre);
        fprintf(arch, "%s\t ", variables_id[i].nombre);
        switch(variables_id[i].var){
        case INTEGER:
            fprintf(arch, "dd\t %d\n", variables_id[i].valorI);
            break;
        case STRING:
            fprintf(arch, "db\t \"%s\", '$'\n", variables_id[i].valorS);
            break;
        default: //Es una variable int, float o puntero a string
            fprintf(arch, "dd\t ?\n");
        }
    }
	fprintf(arch, "@cont\tdd\t0\n");
	fprintf(arch, "_1_\tdd\t1\n");
    fprintf(arch, "\n\n");
}

void insertarentablaCTE_I(int cte){
	if(lista_valores < TOTAL){
		char *str = malloc(3);;
		char *nombre;
		struct tabla tabla_aux;
		itoa(cte, str,10);
		nombre = generaNombreASM(str, INTEGER);
		tabla_aux.nombre = malloc(sizeof(char)*strlen(nombre)+1);
		strcpy(tabla_aux.nombre,nombre);
		tabla_aux.valorI = cte;
		tabla_aux.var = INTEGER;
		variables_id[total_variables] = tabla_aux;
		total_variables++;
	}
	else{
		printf("\nDemasiadas variables y constantes\n");
		exit(4);
	}
	
}

void insertarentablaCTE_S(char *str){
	char* nombre;
	struct tabla tabla_aux;
	if(lista_valores < TOTAL){
		
		tabla_aux.valorS = malloc(sizeof(char)*strlen(str)+1);
		tabla_aux.nombre = malloc(sizeof(char)*strlen(str)+1);
		
		nombre = generaNombreASM(str, STRING);
		
		tabla_aux.nombre = malloc(sizeof(char)*strlen(nombre)+1);
		strcpy(tabla_aux.nombre,nombre);


		strcpy(tabla_aux.valorS,str);
		tabla_aux.var = STRING;
		variables_id[total_variables] = tabla_aux;
		total_variables++;
		}
	else{
		printf("\nDemasiadas variables y constantes\n");
		exit(4);
	}
	
}

void insertarentablaID(char* id){
	
	printf("ID = %s\n", id);
	if(lista_valores < TOTAL){
		struct tabla tabla_aux;
		tabla_aux.nombre = malloc(sizeof(char)*strlen(id)+1);
		strcpy(tabla_aux.nombre,id);
		tabla_aux.var = VARIABLE;
		variables_id[total_variables] = tabla_aux;
		total_variables++;
	}
	else{
		printf("\nDemasiadas variables y constantes\n");
		exit(4);
	}

}

char *generaNombreASM(char *str, int tipo){
	char* nombre;
	char* aux = malloc(sizeof(char)*strlen(str)+1);;
	
	switch(tipo){
	case INTEGER:
		 nombre = malloc(sizeof(char)*strlen(str)+2);
		 strcpy(nombre,"_");
		strcat(nombre, str);
		break;
	case STRING:
		nombre = malloc(sizeof(char)*strlen(str)+2);
		contString++;
		sprintf(aux,"S_%d", contString);
		strcpy(nombre, aux);
		break;
	};
	return nombre;

}

struct tabla buscarTipoTS(char* nombreVar) {

	int i,a;
		
		char *nomCte = malloc(sizeof(char)*strlen(nombreVar)+2);
		strcpy(nomCte, nombreVar);

		for(i=0; i< total_variables;i++){
			if( strcmp(nomCte, variables_id[i].valorS) == 0){
				return variables_id[i];
			}
		
		}
}

char* getCodOp(char* token)
{
	if(!strcmp(token, "="))
	{
		return "MOV";
	}
	else if(!strcmp(token, "BNE"))
	{
		return "JNE";
	}
	else if (!strcmp(token, "BI")) {
		return "JMP";
	}
	else if (!strcmp(token, "BRANCH")){
		return "BRANCH";
	}
	else if (!strcmp(token, "POSICION")){
		return "POSICION";
	}
}