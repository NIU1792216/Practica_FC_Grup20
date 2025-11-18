section .note.GNU-stack noalloc noexec nowrite progbits
section .data               
;Canviar Identificador_Grup per l'identificador del vostre grup.
developer db "20",0

;Constants que també estan definides en C.
DimMatrix    equ 4
SizeMatrix   equ DimMatrix*DimMatrix ;=16

section .text        
;Variables definides en Assemblador.
global developer                        

;Subrutines d'assemblador que es criden des de C.
global showCursor, showNumber, showMatrix, copyMatrix, shiftNumbers, addPairs


;Variables definides en C.
extern rowScreen, colScreen, charac, number, row, col, rowInsert
extern m, mAux, score, state

;Funcions de C que es criden des de assemblador
extern gotoxy_C, getch_C, printch_C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ATENCIÓ: Recordeu que en assemblador les variables i els paràmetres 
;;   de tipus 'char' s'han d'assignar a registres de tipus  
;;   BYTE (1 byte): al, ah, bl, bh, cl, ch, dl, dh, sil, dil, ..., r15b
;;   les de tipus 'short' s'han d'assignar a registres de tipus 
;;   WORD (2 bytes): ax, bx, cx, dx, si, di, ...., r15w
;;   les de tipus 'int' s'han d'assignar a registres de tipus 
;;   DWORD (4 bytes): eax, ebx, ecx, edx, esi, edi, ...., r15d
;;   les de tipus 'long' s'han d'assignar a registres de tipus 
;;   QWORD (8 bytes): rax, rbx, rcx, rdx, rsi, rdi, ...., r15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Les subrutines en assemblador que heu d'implementar són:
;;   showCursor, showNumber, showMatrix, shiftNumbers, addPairs
;;   copyMatrix, rotateMatrix, onePlay, playGame.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina es dóna feta. NO LA PODEU MODIFICAR.
; Situar el cursor a la fila indicada per la variable (rowScreen) i a 
; la columna indicada per la variable (colScreen) de la pantalla,
; cridant la funció gotoxy_C.
; 
; Variables globals utilitzades:   
; (rowScreen): Fila de la pantalla on posicionem el cursor.
; (colScreen): Columna de la pantalla on posicionem el cursor.
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy:
   push rbp
   mov  rbp, rsp
   ;guardem l'estat dels registres del processador perquè
   ;les funcions de C no mantenen l'estat dels registres.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi


   call gotoxy_C
 
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina es dóna feta. NO LA PODEU MODIFICAR.
; Llegir una tecla i guarda el caràcter associat a la variable (charac)
; sense mostrar-la per pantalla, cridant la funció getch_C. 
; 
; Variables globals utilitzades:   
; (charac): Caràcter que llegim de teclat.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getch:
   push rbp
   mov  rbp, rsp
   ;guardem l'estat dels registres del processador perquè
   ;les funcions de C no mantenen l'estat dels registres.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi

   call getch_C
 
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   
   mov rsp, rbp
   pop rbp
   ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina es dóna feta. NO LA PODEU MODIFICAR.
; Mostrar un caràcter guardat a la variable (charac) a la pantalla, 
; en la posició on està el cursor, cridant la funció printch_C
; 
; Variables globals utilitzades:   
; (charac): Caràcter que volem mostrar.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch:
   push rbp
   mov  rbp, rsp
   ;guardem l'estat dels registres del processador perquè
   ;les funcions de C no mantenen l'estat dels registres.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi

   call printch_C
 
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret
   




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A partir de la posició de la matriu row i col
; calcular la posició que ha d'ocupar aquesta component a la pantalla
; i posicionar el cursor a la posició corresponent
; posant els valors adequats a rowScreen i colScreen,
; i després cridant a la subrutina gotoxy.
; La posició a la pantalla (rowScreen, colScreen)
; corresponent a la component (row, col) de la matriu
; ve determinada per les equacions:
; 
; 		rowScreen = row*2 + 10
; 		colScreen = col*9 + 13
;
; HEU DE TENIR EN COMPTE EL TIPUS DE LES VARIABLES 
; PER A DETERMINAR ELS REGISTRES QUE HEU DE FER SERVIR
;
; Variables globals utilitzades:   
; (row)   		: Fila de la matriu.
; (col)			: Columna de la matriu.
; (rowScreen)	: Fila de la pantalla on posicionem el cursor.
; (colScreen)	: Columna de la pantalla on posicionem el cursor.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
showCursor:
   push rbp
   mov  rbp, rsp
   push rax
   push rbx
   mov eax,dword[row]
   shl eax,1
   add eax,10
   mov dword[rowScreen],eax
   mov ebx,dword[col]
   mov eax,9
   mul ebx
   add eax,13
   mov dword[colScreen],eax
   call gotoxy
   pop rbx
   pop rax
   mov rsp, rbp
   pop rbp
   ret

   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar per pantalla, a la posició del tauler corresponent
; un valor sencer emmagatzemat a la variable number de tipus int (DWORD) 
; de 4 dígits (number <= 9999). Si (number) és més gran que 9999 canviarem el valor a 9999.
; Per a poder treure per pantalla un valor numèric cal convertir-lo
; al conjunt de caràcters ASCII que representen aquest valor. 
; Si el número és 1234 s'ha de mostrar per pantalla els caràcters '1', '2', '3' i '4'.
; Si el número no té 4 dígits, els dígits de més a l'esquerra no s'han de mostrar.
; Per exemple, 23 ha de ser ' ', ' ', '2' i '3'
; Fins i tot, si el número és 0, ha de ser ' ', ' ', ' ' i ' '.
; Hi ha diverses formes de fer aquest procés.
; Però totes necessiten dividions per 10 (o potències de 10).
; S'han de mostrar els dígits (caràcter ASCII) a partir de la posició 
; corresponent a row i col.
; Per a mostrar els caràcters cal cridar a la subrutina printch.
; Quan es crida a la subrutina printch es treu un caràcter per pantalla
; i el cursor ja avança de forma automàtica a la posició següent
; de forma que no cal tornar a posicionar el cursor
;
; Variables globals utilitzades:   
; (number)   	: Número que volem mostrar.
; (row)			: Fila de la matriu on volem posicionar el cursor.
; (col)			: Columna de la matriu on volem posicionar el cursor.
; (rowScreen)	: Fila de la pantalla on posicionem el cursor.
; (colScreen)	: Columna de la pantalla on posicionem el cursor.
; (charac)   	: Caràcter a escriure a pantalla.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
showNumber:
   push rbp
   mov  rbp, rsp
   call showCursor
   push rax
   push rbx
   push rdx
   push rcx
   mov ebx,1000
   mov eax,dword[number]
   mov ecx,dword[number]

b_zero:
;Aquest bucle repetirà la divisió sense imprimir el resultat fins que
;el resultat sigui diferent a zero
   call f_dividir
   cmp eax,0
   jg b_nZero
   mov dword[charac],20h
   call printch
   call f_disminuir
   jmp b_zero

b_nZero:
   add eax,30h
   mov dword[charac],eax
   call printch
   call f_disminuir
   call f_dividir
   jmp b_nZero

f_dividir:
;Aquesta funció fa la divisió de ecx entre ebx i desa el res. a eax i ecx
   mov eax,ecx
   mov edx,0
   div ebx
   mov ecx,edx
   ret
f_disminuir:
;Les següents línies divideixen ebx entre 10, borren eax, edx.
   cmp ebx,1
   jle divisor_1
   mov eax,ebx
   mov ebx,10
   mov edx,0
   div ebx
   mov ebx,eax
   jmp fi_decrement
divisor_1:
   pop rax
   jmp fi_showNumber
fi_decrement:
   ret

fi_showNumber:
   pop rcx
   pop rdx
   pop rbx
   pop rax
   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar el contingut de la matriu (m) al Tauler de Joc 
; S'ha de recórrer tota la matriu (m), i per a cada element de la matriu
; posicionar el cursor a la pantalla i mostrar el número d'aquella 
; posició de la matriu.
; Per a posicionar el cursor heu de recorrer totes les files i columnes de la matriu de 1 en 1
; Alhora, heu d'anar passant d'element en element incrementant l'índex d'accés a la matriu
; de dos en dos perquè les dades son de tipus short (WORD).
; Un cop que teniu la fila (row) i columna (col) i el valor posat a (number)
; heu de cridar a showCursor i showNumber.
;
; Variables globals utilitzades:   
; (number)   	: Número que volem mostrar.
; (row)			: Fila de la matriu on volem posicionar el cursor.
; (col)			: Columna de la matriu on volem posicionar el cursor.
; (rowScreen)	: Fila de la pantalla on posicionem el cursor.
; (colScreen)	: Columna de la pantalla on posicionem el cursor.
; (m)        	: Matriu on guardem els nombres del joc.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
showMatrix:
   push rbp
   mov  rbp, rsp
   push rsi
   push rax
   push rbx
   push rdx
   
inici_mostrar_m:
   mov rsi,0
   mov eax,0
   mov edx,0
bucle_mostrar_m:
   cmp rsi,32
   jge fi_mostrar_m
   mov ax,word[m + rsi]
   mov dword[number],eax
   call f_trobar_ij
   call showCursor
   call showNumber
   add rsi,2
   jmp bucle_mostrar_m

f_trobar_ij:
   mov ebx,8
   mov rax,rsi
   div ebx
   mov dword[row],eax
   shr edx,1
   mov dword[col],edx
   ret

fi_mostrar_m:
   pop rdx
   pop rbx
   pop rax
   pop rsi
   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copiar els valors de la matriu (mAux) a la matriu (m).
; La matriu (mAux) no s'ha de modificar, 
; els canvis s'han de fer a la matriu (m).
; Per recórrer la matriu en assemblador l'índex va de 0 (posició [0][0])
; a 30 (posició [3][3]) amb increments de 2 perquè les dades son de 
; tipus short(WORD) 2 bytes.
; No cal mostrar la matriu.
;
; Variables globals utilitzades:   
; (m)       : Matriu on guardem els nombres del joc.
; (mAux): Matriu amb els nombres rotats a la dreta.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
copyMatrix:
   push rbp
   mov  rbp, rsp
   push rsi
   push rax
   mov rsi,0
recorre_mat:
   cmp rsi,32
   jge fi_cpMat
   mov ax,word[mAux+rsi]
   mov word[m+rsi],ax
   add rsi,2
   jmp recorre_mat
fi_cpMat:
   pop rax
   pop rsi
   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Desplaça a la dreta els números de cada fila de la matriu (m),
; mantenint l'ordre dels números i posant els zeros a l'esquerra.
; Recórrer la matriu per files de dreta a esquerra i de baix a dalt.
; Per recórrer la matriu en assemblador, en aquest cas, l'índex va de la
; posició 30 (posició [3][3]) a la 0 (posició [0][0]) amb decrements de
; 2 perquè les dades son de tipus short(WORD) 2 bytes.
; Si es desplaça un número (NO ELS ZEROS), posarem la variable 
; (state) a '2'.
; A cada fila, si troba un 0, mira si hi ha un número diferent de zero,
; a la mateixa fila per a posar-lo en aquella posició.
; Si una fila de la matriu és: [2,0,4,0] i state = '1', quedarà [0,0,2,4] 
; i state = '2'.
;
; Variables globals utilitzades:   
; (m)    : Matriu on guardem els nombres del joc.
; (state): Estat del joc. ('2': S'han fet moviments).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shiftNumbers:
   push rbp
   mov  rbp, rsp
   push rsi
   push rax
   push rbx
   push rcx
   
   mov rsi,30

b_mat_inv_fn:
   mov rbx,0
   cmp rsi,0
   jle fi_shft_Nbr

mat_inv_nz:
   cmp rbx,4
   jge b_mat_inv_fn
   cmp word[m+rsi],0
   je mat_inv_z
   sub rsi,2
   add rbx,1
   jmp mat_inv_nz
   
mat_inv_z:
   mov rcx,rsi
b_shft_z
   sub rsi,2
   add rbx,1
   cmp rbx,4
   jge b_mat_inv_fn
   cmp word[m+rsi],0
   je b_shft_z
   mov ax, word[m+rsi]
   mov word[m+rsi],0
   mov word[m+rcx],ax
   shl rbx,1
   add rsi,rbx
   mov rbx,0
   jmp mat_inv_nz
   
fi_shft_Nbr:
   pop rcx
   pop rbx
   pop rax
   pop rsi
   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aparellar nombres iguals des de la dreta de la matriu (m).
; Recórrer la matriu per files de dreta a esquerra i de baix a dalt. 
; Quan es trobi una parella, dos caselles consecutives amb el mateix 
; número, ajuntem la parella posant la suma de la parella a la casella 
; de la dreta, un 0 a la casella de l'esquerra.
; Si una fila de la matriu és: [8,4,4,2] i state = 1'', 
; quedarà [8,0,8,2] i state = '2'.
; Per recórrer la matriu en assemblador, en aquest cas, l'índex va de la
; posició 30 (posició [3][3]) a la 0 (posició [0][0]) amb increments de 
; 2 perquè les dades son de tipus short(WORD) 2 bytes.
; No s'ha de mostrar la matriu.
;
; Variables globals utilitzades:   
; (m)    : Matriu on guardem els nombres del joc.
; (state): Estat del joc. ('2': S'han fet moviments).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
addPairs:
   push rbp
   mov  rbp, rsp





   mov rsp, rbp
   pop rbp
   ret
   

