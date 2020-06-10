ljmp start

P5 equ 0F8H
P7 equ 0DBH
p6 equ 0FAH
	
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

// procedura obslugi przerwania od portu szeregowego
org 0023H
			PUSH ACC		 ; by nie zniszczyc czegos co jest wazne w A
			JBC TI, wyslac	 ; odbieramy czy wysylamy dana
			MOV A, SBUF      ; czytanie z z portu szeregowego
			MOV R7, A		 ; zamiana odczytanego dziwolaga na ASCII
			ANL 07H, #0FH	 ; przyklad 1 - 71H zamiast 31H
			CLR C			 ; jest 0111 0001 a ma byc 0011 0001
			RRC A
			ANL A, #0F0H
			ORL A, R7
			MOV P1, A		 ; kod ASCII kontrolnie na diody
			ACALL putcharLCD ; odczytany znak z portu szeregowego na LCD
			CLR RI			 ; przerwanie powodowane odczytem z portu szeregowego obsluzone
			JMP final
	wyslac: MOV A, R5		   ; czy wazan dana do wysylki jest w buforze
			JNZ final		   ; jesli nie - to nic nie rób
			MOV A, R6		   ; dana do wyslania z bufora
			MOV SBUF, A        ; zapis do bufora portu szeregowego
			MOV R5, #0FFH      ; wyzerowanie flagi wyslania
	final:	POP ACC  
			RETI

// program glówny
org 0100H
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x          ; x – parametr wywolania macra – bajt sterujacy
           LOCAL loop       ; LOCAL oznacza ze etykieta loop moze sie powtórzyc w programie
loop: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,loop       ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
      MOV  DPTR,#LCDcontrol ; DPTR zaladowany adresem do podania bajtu sterujacego
      MOV  A, x             ; do akumulatora trafia argument wywolania macra–bajt sterujacy
      MOVX @DPTR,A          ; bajt sterujacy podany do LCD – zadana akcja widoczna na LCD
      ENDM
	  
// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO
      LOCAL tutu            ; LOCAL oznacza ze etykieta tutu moze sie powtórzyc w programie
      PUSH ACC              ; odlozenie biezacej zawartosci akumulatora na stos
tutu: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,tutu       ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
      MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
      POP  ACC              ; w akumulatorze ponownie kod ASCII znaku na LCD
      MOVX @DPTR,A          ; kod ASCII podany do LCD – znak widoczny na LCD
      ENDM
	  
// macro do inicjalizacji wyswietlacza – bez parametrów
init_LCD MACRO
         LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR – inicjalizacja LCD
         LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR – czyszczenie LCD
         LCDcntrlWR #LCDON    ; wywolanie macra LCDcntrlWR – konfiguracja kursora
         ENDM

// funkcja opóznienia

	delay:	mov r0, #15H
	one:	mov r1, #0FFH
	dwa:	mov r2, #0FFH
    trzy:	djnz r2, trzy
			djnz r1, dwa
			djnz r0, one
			ret
			
// funkcja wypisania znaku
putcharLCD:	LCDcharWR
			ret
			
// wylaczenie piszczyka 1kHz
BEEPOFF:	MOV A, P6
			CLR ACC.4
			MOV P6, A
			RET

// tablica przekodowania klawisze - ASCII w XRAM

keyascii:	mov dptr, #80EBH
			mov a, #"0"
			movx @dptr, a
			
			mov dptr, #8077H
			mov a, #"1"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"2"
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #"3"
			movx @dptr, a
			
			mov dptr, #80B7H
			mov a, #"4"
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #"5"
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #"6"
			movx @dptr, a
			
			mov dptr, #80D7H
			mov a, #"7"
			movx @dptr, a
			
			mov dptr, #80DBH
			mov a, #"8"
			movx @dptr, a
			
			mov dptr, #80DDH
			mov a, #"9"
			movx @dptr, a
			
			mov dptr, #807EH
			mov a, #"A"
			movx @dptr, a
			
			mov dptr, #80BEH
			mov a, #"B"
			movx @dptr, a
			
			mov dptr, #80DEH
			mov a, #"C"
			movx @dptr, a
			
			mov dptr, #80EEH
			mov a, #"D"
			movx @dptr, a
			
			mov dptr, #80E7H
			mov a, #"*"
			movx @dptr, a
			
			mov dptr, #80EDH
			mov a, #"#"
			movx @dptr, a
			
			ret

keyascii_A:	mov dptr, #80EBH
			mov a, #"A"
			movx @dptr, a
			
			mov dptr, #8077H
			mov a, #"B"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"C"
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #"D"
			movx @dptr, a
			
			mov dptr, #80B7H
			mov a, #"E"
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #"F"
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #"G"
			movx @dptr, a
			
			mov dptr, #80D7H
			mov a, #"H"
			movx @dptr, a
			
			mov dptr, #80DBH
			mov a, #"I"
			movx @dptr, a
			
			mov dptr, #80DDH
			mov a, #"J"
			movx @dptr, a		
			
			ret
			
keyascii_B: mov dptr, #80EBH
			mov a, #"a"
			movx @dptr, a
			
			mov dptr, #8077H
			mov a, #"b"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"c"
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #"d"
			movx @dptr, a
			
			mov dptr, #80B7H
			mov a, #"e"
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #"f"
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #"g"
			movx @dptr, a
			
			mov dptr, #80D7H
			mov a, #"h"
			movx @dptr, a
			
			mov dptr, #80DBH
			mov a, #"i"
			movx @dptr, a
			
			mov dptr, #80DDH
			mov a, #"j"
			movx @dptr, a		
			
			ret

keyascii_C: mov dptr, #80EBH
			mov a, #"0"
			movx @dptr, a
			
			mov dptr, #8077H
			mov a, #"1"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"2"
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #"3"
			movx @dptr, a
			
			mov dptr, #80B7H
			mov a, #"4"
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #"5"
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #"6"
			movx @dptr, a
			
			mov dptr, #80D7H
			mov a, #"7"
			movx @dptr, a
			
			mov dptr, #80DBH
			mov a, #"8"
			movx @dptr, a
			
			mov dptr, #80DDH
			mov a, #"9"
			movx @dptr, a		
			
			ret
 
// program glówny
    start:  init_LCD
	
			//acall keyascii
		
			ACALL BEEPOFF	 ; wylaczenie piszczyka
			mov R5, #0FFH
			mov R6, #20H
			
Sterowanie1:JNB P5.7, TRYB_A
			JNB P5.6, TRYB_B
			JNB P5.5, TRYB_C		
			jmp Sterowanie1
			
TRYB_A:		mov r0, #LINE_1
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0	
			mov r2, a
			subb a, #7EH
			jnz Sterowanie1
			
puszczony_a:mov a, P7
			anl a, r0
			clr c
			subb a, r2
			jz puszczony_a
			
			acall keyascii_A
			jmp	dalej
			
TRYB_B:		mov r0, #LINE_2
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0	
			mov r2, a	
			subb a, #0BEH
			jnz Sterowanie1
			
puszczony_b:mov a, P7
			anl a, r0
			clr c
			subb a, r2
			jz puszczony_b
			
			acall keyascii_B
			jmp	dalej

TRYB_C:		mov r0, #LINE_3
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0		
			mov r2, a
			subb a, #0DEH
			jnz Sterowanie1
			
puszczony_c:mov a, P7
			anl a, r0
			clr c
			subb a, r2
			jz puszczony_c
			
			acall keyascii_C
						
// ustawienie portu szeregowego i timera			
dalej:		MOV SCON, #50H	 ; tryb 1, 8 bitów danych, brak bitu parzystosci
			MOV TMOD, #20H   ; konfiguracja Timera 1, tryb 2
			MOV TH1, #0FDH   ; konfiguracja szybkosci transmisji szeregowej
			MOV TL1, #0FDH   ; 9600 bit/s 
			SETB TR1		 ; timer rusza
			MOV IE, #90H	 ; wlaczenie przerwan od portu szeregowego

		
// obsluga klawiatury i wysylki do portu szeregowego			
	
Sterowanie:	JNB P5.7, key_1
			JNB P5.6, key_2
			JNB P5.5, key_3
			JNB P5.4, key_4
			JMP Sterowanie	
	
	key_1:	mov r0, #LINE_1
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Sterowanie

puszczony1:	mov a, P7
			anl a, r0
			clr c
			subb a, r2
			jz puszczony1
	
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			mov r6, a			; bufor dla znaku ASCII do wysylki
			mov r5, #00H		; ustawienie znacznika ze wazna dana w buforze R6
			setb TI				; wymuszamy przerwanie do wysylki znaku
			acall putcharLCD
			jmp Sterowanie
						
	key_2:	mov r0, #LINE_2
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Sterowanie	

puszczony2:	mov a, P7
			anl a, r0
			clr c
			subb a, r2
			jz puszczony2

			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			mov r6, a
			mov r5, #00H
			setb TI			
			acall putcharLCD
			acall delay
			jmp Sterowanie
			
	key_3:	mov r0, #LINE_3
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Sterowanie	

puszczony3:	mov a, P7
			anl a, r0
			clr c
			subb a, r2
			jz puszczony3

			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			mov r6, a
			mov r5, #00H
			setb TI
			acall putcharLCD
			acall delay
			jmp Sterowanie
			
	key_4:	mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz skok
			
puszczony4:	mov a, P7
			anl a, r0
			clr c
			subb a, r2
			jz puszczony4
			
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			mov r6, a
			mov r5, #00H
			setb TI
		    acall putcharLCD
			acall delay
			
skok:		jmp Sterowanie 
 
    nop
    nop
    nop
    jmp $
    end start
