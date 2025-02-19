ljmp start

P5 equ 0F8H
P7 equ 0DBH
	
LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF2DH       ; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80     // put cursor to second line  
#define  INITDISP 0x38     // LCD init (8-bit mode)  
#define  HOM2     0xc0     // put cursor to second line  
#define  LCDON    0x0e     // LCD nn, cursor off, blinking off
#define  CLEAR    0x01     // LCD display clear

// linie klawiatury - sterowanie na port P5
#define LINE_1		0x7f	// 0111 1111
#define LINE_2		0xbf	// 1011 1111
#define	LINE_3		0xdf	// 1101 1111
#define LINE_4		0xef	// 1110 1111
#define ALL_LINES	0x0f	// 0000 1111

ORG 000BH     				; obsluga przerwania
	MOV TH0, #3CH 			; przeladowanie
	MOV TL0, #0B0H 			; stalej timera na 50ms
	DEC R0        			; korekta licznika
	RETI          			; powr�t z przerwania

org 0100H
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x          ; x � parametr wywolania macra � bajt sterujacy
           LOCAL loop       ; LOCAL oznacza ze etykieta loop moze sie powt�rzyc w programie
loop: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,loop       ; testowanie najstarszego bitu akumulatora
                            ; � wskazuje gotowosc LCD
      MOV  DPTR,#LCDcontrol ; DPTR zaladowany adresem do podania bajtu sterujacego
      MOV  A, x             ; do akumulatora trafia argument wywolania macra�bajt sterujacy
      MOVX @DPTR,A          ; bajt sterujacy podany do LCD � zadana akcja widoczna na LCD
      ENDM
	  
// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO
      LOCAL tutu            ; LOCAL oznacza ze etykieta tutu moze sie powt�rzyc w programie
      PUSH ACC              ; odlozenie biezacej zawartosci akumulatora na stos
tutu: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,tutu       ; testowanie najstarszego bitu akumulatora
                        ; � wskazuje gotowosc LCD
      MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
      POP  ACC              ; w akumulatorze ponownie kod ASCII znaku na LCD
      MOVX @DPTR,A          ; kod ASCII podany do LCD � znak widoczny na LCD
      ENDM
	  
// macro do inicjalizacji wyswietlacza � bez parametr�w
init_LCD MACRO
         LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR � inicjalizacja LCD
         LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR � czyszczenie LCD
         LCDcntrlWR #LCDON    ; wywolanie macra LCDcntrlWR � konfiguracja kursora
         ENDM
		 
// funkcja wypisania liczby dla potrzeb zegara
putdigitLCD:	mov b, #10
				div ab				; uzyskanie cyfry dziesiatek
				add a, #30H			; konwersja cyfry na kod ASCII
				acall putcharLCD
				mov a, b			; ladowanie cyfry jednosci
				add a, #30H			; konwersja na LCD
				acall putcharLCD
				ret

// funkcaj wypisywania znaku na LCD
putcharLCD:	LCDcharWR
			ret
		 

// wyznaczanie biezacej wartosci zegara i jego wyswietlanie na LCD
ZEGAR:		INC R3				; licznik sekund
			MOV A, R3			; obsluga sekund
			CLR C
			SUBB A, #60			; przepelnienie sekund
			JZ MINUTY
			LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, R5			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R1			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R3			; sekundy
			ACALL putdigitLCD
			JMP FINAL
MINUTY:		MOV R3, #00H		; zerowanie sekund
			INC R1				; licznik minut
			MOV A, R1			; obsluga minut
			CLR C
			SUBB A, #60			; przepelnienie minut
			JZ GODZINY
			LCDcntrlWR #HOME	; wyswiwtlenie calego zegara
			MOV A, R5			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R1			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R3			; sekundy
			ACALL putdigitLCD
			JMP FINAL
GODZINY:	MOV R1, #00H		; zerowanie minut
			INC R5				; licznik godzin
			MOV A, R5
			CLR C
			SUBB A, #24			; przepelenienie godzin - doba
			JNZ EKRAN
			MOV R5, #00H		; zerowanie godzin
EKRAN:		LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, R5			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R1			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R3			; sekundy
			ACALL putdigitLCD
FINAL:		RET

        ; program gl�wny
START:	init_LCD

		LCDcntrlWR #CLEAR
		LCDcntrlWR #HOME
	
		MOV TMOD, #01H 			; konfiguracja timera
		MOV TH0, #3CH 			; ladowanie
		MOV TL0, #0B0H 			; stalej timera na 50ms
		SETB TR0      			; timer start
		MOV IE, #82H  			; przerwania wlacz
		MOV R5, #00H			; inicjacja zegara
		MOV R1, #00H
		MOV R3, #0FFH
		ACALL ZEGAR				; wyswietlenie zainicjowanego zegara
		MOV A, #0FH
		MOV P1, A    			; zapalenie di�d
		MOV R0, #20 			; licznik odmierzen 20 x 50ms
		
CZEKAM: MOV A, R0   			; czekam, a timer
		JNZ CZEKAM   			; mierzy laczny czas 1s
	
Dalej:	MOV R0, #20				; po zgloszeniu przerwania - ustawiam na nowo licznik odmierzen 20 x 50ms
		ACALL ZEGAR				; utuchomeinie procedury oblugi i wyswietlenia zegara
		MOV A, P1  				; zmiana
		CPL A       			; swiecenia
		MOV P1, A    			; di�d
		
off:	mov r4, #LINE_1
		mov	a, r4
		mov	P5, a
		mov a, P7
		anl a, r4		
		subb a, #7BH
		jnz CZEKAM
		CLR TR0		
		jmp on
		
		JMP CZEKAM    			; czekam na kolejna sekunde		
		
on: 	mov r4, #LINE_1
		mov	a, r4
		mov	P5, a
		mov a, P7
		anl a, r4
		subb a, #77H
		jnz on
		SETB TR0		
		jmp CZEKAM		
		
		NOP
		NOP
		NOP
		JMP $
END START
