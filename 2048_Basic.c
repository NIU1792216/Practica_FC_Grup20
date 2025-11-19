/**
  * Des d'aquest codi es fan les crides a les subrutines de assemblador. 
 * AQUEST CODI NO ES POT MODIFICAR I NO S'HA DE LLIURAR.
 **/

#include <stdlib.h>
#include <stdio.h>
#include <termios.h>     //termios, TCSANOW, ECHO, ICANON
#include <unistd.h>      //STDIN_FILENO

extern int developer;    //Variable declarada en assemblador que indica el grup desenvolupador

/**
 * Constants
 */
#define DimMatrix  4     //dimensió de la matriu
#define SizeMatrix DimMatrix*DimMatrix //=16


/**
 * Definició de variables globals
 */
int  rowScreen;		//Fila per a posicionar el cursor a la pantalla.
int  colScreen;		//Columna per a posicionar el cursor a la pantalla.
int  row;			//Fila de la matriu.
int  col;			//Columna de la matriu
int  rowInsert=0;	//Fila en la que volem inserir fitxa
int  number;       //Numero que volem mostrar.
int  score;        // Punts acumulats al marcador.                    
   
char charac;   		//Caràcter llegit de teclat i per a escriure a pantalla.
char state  = '1';    // '0': Sortir, hem premut la tecla 'ESC' per a sortir.
                       // '1': Continuem jugant.
                       // '2': Continuem jugant però s'han fet canvis a la matriu.
                       // '3': Hem fet un 2048
                       // '4': No hem pogut inserir fitxa
 
                       
                       
                       
// Matriu 4x4 on guardem els números del joc.
// Accés a les matrius en C: utilitzem fila (0..[DimMatrix-1]) i 
// columna(0..[DimMatrix-1]) (m[fila][columna]).
// Accés a les matrius en assemblador: S'hi accedeix com si fos un vector 
// on indexMat (0..[DimMatrix*DimMatrix-1]). 
// indexMat=((fila*DimMatrix)+(columna))*2 (2 perquè la matriu és de tipus short).
// WORD[m+indexMat] (WORD perquè és de tipus short) 
// (indexMat ha de ser un registre de tipus long/QWORD:RAX,RBX,..,RSI,RDI,..,R15).
short m[DimMatrix][DimMatrix]        = { {    0,    2,     2,     2},
                                         {    0,    8,     8,     0},
                                         {    8,    0,     0,     0},
                                         {    4,    4,     0,     2} };

// Matriu aauxiliar
short mAux[DimMatrix][DimMatrix]     = { {    0,    0,     8,     8},
                                         {    0,    0,     4,     16},
                                         {    2,    2,     0,     0},
                                         {    4,    2,     4,     0} };



/**
 * Definició de les funcions de C
 */

void gotoxy_C();
void printch_C();
void getch_C();

void clearscreen_C();
void printMenu_C();
void printBoard_C();
void printMessage_C();
void play_C();

/**
 * Definició de les subrutines d'assemblador que es criden des de C.
 */
extern void showCursor();
extern void showNumber();
extern void showMatrix();
extern void copyMatrix();
extern void shiftNumbers();
extern void addPairs();



/**
 * Esborrar la pantalla
 * 
 * Variables globals utilitzades:   
 * Cap
 * 
 * Aquesta funció no es crida des d'assemblador
 * i no hi ha definida una subrutina d'assemblador equivalent.
 */
void clearScreen_C(){
   
    printf("\x1B[2J");
    
}



/**
 * Situar el cursor a la fila indicada per la variable (rowScreen) i a 
 * la columna indicada per la variable (colScreen) de la pantalla.
 * 
 * Variables globals utilitzades:   
 * (rowScreen): Fila de la pantalla on posicionem el cursor.
 * (colScreen): Columna de la pantalla on posicionem el cursor.
 * 
 * S'ha definit un subrutina en assemblador equivalent 'gotoxy' per a 
 * poder cridar aquesta funció guardant l'estat dels registres del 
 * processador. Això es fa perquè les funcions de C no mantenen 
 * l'estat dels registres.
 */
void gotoxy_C(){
   
   printf("\x1B[%d;%dH",rowScreen,colScreen);
   
}


/**
 * Mostrar un caràcter guardat a la variable (charac) a la pantalla, 
 * en la posició on està el cursor.
 * 
 * Variables globals utilitzades:   
 * (charac): Caràcter que volem mostrar.
 * 
 * S'ha definit un subrutina en assemblador equivalent 'printch' per a
 * cridar aquesta funció guardant l'estat dels registres del processador.
 * Això es fa perquè les funcions de C no mantenen l'estat dels registres.
 */
void printch_C(){

   printf("%c",charac);
   
}



/**
 * Llegir una tecla i guardar el caràcter associat a la variable (charac)
 * sense mostrar-lo per pantalla. 
 * 
 * Variables globals utilitzades:   
 * (charac): Caràcter que llegim de teclat.
 * 
 * S'ha definit un subrutina en assemblador equivalent 'getch' per a
 * cridar aquesta funció guardant l'estat dels registres del processador.
 * Això es fa perquè les funcions de C no mantenen l'estat dels 
 * registres.
 */
void getch_C(){

   static struct termios oldt, newt;

   /*tcgetattr obtenir els paràmetres del terminal
   STDIN_FILENO indica que s'escriguin els paràmetres de l'entrada estàndard (STDIN) sobre oldt*/
   tcgetattr( STDIN_FILENO, &oldt);
   /*es copien els paràmetres*/
   newt = oldt;

   /* ~ICANON per a tractar l'entrada de teclat caràcter a caràcter no com a línia sencera acabada amb /n
      ~ECHO per a què no mostri el caràcter llegit*/
   newt.c_lflag &= ~(ICANON | ECHO);          

   /*Fixar els nous paràmetres del terminal per a l'entrada estàndard (STDIN)
   TCSANOW indica a tcsetattr que canvii els paràmetres immediatament. */
   tcsetattr( STDIN_FILENO, TCSANOW, &newt);

   /*Llegir un caràcter*/
   charac = (char) getchar();                 
    
   /*restaurar els paràmetres originals*/
   tcsetattr( STDIN_FILENO, TCSANOW, &oldt);
   
}


/**
 * Mostrar a la pantalla el menú del joc i demanar una opció.
 * Només accepta una de les opcions correctes del menú ('0'-'9')
 * 
 * Variables globals utilitzades:   
 * (rowScreen): Fila de la pantalla on posicionem el cursor.
 * (colScreen): Columna de la pantalla on posicionem el cursor.
 * (charac)   : Caràcter que llegim de teclat.
 * (developer): ((char *)&developer): Variable definida en el codi assemblador.
 * 
 * Aquesta funció no es crida des d'assemblador
 * i no hi ha definida una subrutina d'assemblador equivalent.
 */
void printMenu_C(){
    clearScreen_C();
    rowScreen = 1;
    colScreen = 1;
    gotoxy_C();
    printf("                                    \n");
    printf("           Developed by:            \n");
    printf("        ( %s )   \n",(char *)&developer);
    printf(" __________________________________ \n");
    printf("|                                  |\n");
    printf("|            MAIN MENU             |\n");
    printf("|__________________________________|\n");
    printf("|                                  |\n");
    printf("|         1. ShowCursor            |\n");
    printf("|         2. ShowNumber            |\n");
    printf("|         3. ShowMatrix            |\n");
    printf("|         4. CopyMatrix            |\n");
    printf("|         5. ShiftNumbers          |\n");
    printf("|         6. AddPairs              |\n");
    printf("|         7. RotateMatrix          |\n");
    printf("|         8. OnePlay               |\n");
    printf("|         9. PlayGame              |\n");
    printf("|         0. Exit                  |\n");
    printf("|__________________________________|\n");
    printf("|                                  |\n");
    printf("|            OPTION:               |\n");
    printf("|__________________________________|\n"); 

    charac=' ';
    while (charac < '0' || charac > '9') {
      rowScreen = 20;
      colScreen = 22;
      gotoxy_C();
      getch_C();
      printch_C();
   }
   
}



/**
 * Mostrar el tauler de joc a la pantalla. Les línies del tauler.
 * 
 * Variables globals utilitzades:   
 * (rowScreen): Fila de la pantalla on posicionem el cursor.
 * (colScreen): Columna de la pantalla on posicionem el cursor.
 *  
 * Aquesta funció es crida des de C i des d'assemblador,
 * i no hi ha definida una subrutina d'assemblador equivalent.
 */
void printBoard_C(){

   rowScreen = 1;
   colScreen = 1;
   gotoxy_C();
   printf(" _________________________________________________  \n"); //01
   printf("|                                                  |\n"); //02
   printf("|                  2048 PUZZLE  v1.0               |\n"); //03
   printf("|                                                  |\n"); //04
   printf("|     Join the numbers and get to the 2048 tile!   |\n"); //05
   printf("|__________________________________________________|\n"); //06
   printf("|                                                  |\n"); //07
   printf("|            0        1        2        3          |\n"); //08
   printf("|        +--------+--------+--------+--------+     |\n"); //09
   printf("|      0 |        |        |        |        |     |\n"); //10
   printf("|        +--------+--------+--------+--------+     |\n"); //11
   printf("|      1 |        |        |        |        |     |\n"); //12
   printf("|        +--------+--------+--------+--------+-    |\n"); //13
   printf("|      2 |        |        |        |        |     |\n"); //14
   printf("|        +--------+--------+--------+--------+     |\n"); //15
   printf("|      3 |        |        |        |        |     |\n"); //16
   printf("|        +--------+--------+--------+--------+     |\n"); //17
   printf("|          Score:   ______                         |\n"); //18
   printf("|__________________________________________________|\n"); //19
   printf("|                                                  |\n"); //20
   printf("|  (ESC)Exit  (i)Up   (j)Left  (k)Down  (l)Right   |\n"); //21
   printf("|__________________________________________________|\n"); //22
   
}



void printMessage_C() {

   rowScreen = 23;
   colScreen = 12;
   gotoxy_C();

   switch(state){
      case '0':
         printf("<<<<<< EXIT: (ESC) Pressed >>>>>>");
      break;
      
      case '3':
         printf("<<<<<<<< 2048 YOU WIN >>>>>>>");
      break;

      case '5':
         printf("<<<<<<<< YOU HAVE LOST >>>>>>>");
      break;


    }
     
}
 
 
 

/**
 * Programa Principal
 * 
 */
int main(void){
   
   while (charac!='0') {
     clearScreen_C();
     printMenu_C();    
      
      switch(charac){
         case '1':// Mostrar Cursor
            clearScreen_C();  
            printBoard_C();
             
            row = 2;
            col = 1;

            showCursor();

			getch_C();
			
            rowScreen = 17;
            colScreen = 30;
            gotoxy_C();
            printf(" Press any key ");
            getch_C();                        
         break;
         
         case '2':// Mostrar Número
            clearScreen_C();  
            printBoard_C(); 
            row = 1;
            col = 2;

            showCursor();

     
            number = 1204;

            showNumber(); 

            rowScreen = 17;
            colScreen = 30;
            gotoxy_C();
            printf(" Press any key ");
            getch_C();
         break;
         
         case '3': //Mostrar el contingut de la matriu.
            clearScreen_C();  
            printBoard_C(); 

            showMatrix(); 
            
            rowScreen = 17;
            colScreen = 30;
            gotoxy_C();
            printf(" Press any key ");
            getch_C();
         break;
         
         case '4': //Copiar matriu mAux a m
            clearScreen_C(); 
            printBoard_C();

            copyMatrix();

            showMatrix();
            rowScreen = 17;
            colScreen = 30;
            gotoxy_C();
            printf(" Press any key ");
            getch_C();
         break;

         case '5': //Desplaça números a la dreta
            clearScreen_C();  
            printBoard_C();
            
            showMatrix();
			getch_C();

            shiftNumbers(); 
 
            showMatrix();
            
            rowScreen = 17;
            colScreen = 30;
            gotoxy_C();
            printf(" Press any key ");
            getch_C();
         break;
         
         case '6': //Fer parelles
            clearScreen_C();  
            printBoard_C(); 
            showMatrix();
            getch_C();
            
            addPairs();

            showMatrix();
            
            rowScreen = 17;
            colScreen = 30;
            gotoxy_C();
            printf(" Press any key ");
            getch_C();
         break;

         
         case '7': //Rotar matriu en sentit del rellotge
            clearScreen_C();  
            printBoard_C(); 
			



            rowScreen = 17;
            colScreen = 30;
            gotoxy_C();
            printf(" Press any key ");
            getch_C();
         break;
         
         
         case '8':    
            clearScreen_C();  
            printBoard_C(); 

            rowScreen = 17;
            colScreen = 30;
            gotoxy_C();
            printf(" Press any key ");
            getch_C();
         break;

         case '9':    
            clearScreen_C();  
            printBoard_C(); 


            printMessage_C();
            rowScreen = 17;
            colScreen = 30;
            gotoxy_C();
            printf(" Press any key ");
            getch_C();
         break;


      }
   }
   printf("\n\n");
   
   return 0;
}
