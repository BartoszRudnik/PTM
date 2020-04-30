ljmp start

LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF3DH       ; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80     // put cursor to second line  
#define  INITDISP 0x38     // LCD init (8-bit mode)  
#define  HOM2     0xc0     // put cursor to second line  
#define  LCDON    0x0e     // LCD nn, cursor off, blinking off
#define  CLEAR    0x01     // LCD display clear

org 0100H
	
// deklaracje tekstów
	text1:  db "a",00
	text2:	db "b",00
	text3:	db "c",00
	text4:	db "d",00
		
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
	  mov  83h, 06h			; DPH - 83h, r6 - 06h czyli MOV DPH, R6
	  mov  82h, 07h			; DPL - 82h, r7 - 07h czyli MOV DPL, R7
      ;MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
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
			
//funkcja wypisania lancucha znaków		
putstrLCD:  mov r7, #30h	; DPL ustawiony tak by byl w DPRT adres FF30H
nextchar:	clr a
			movc a, @a+dptr
			jz koniec
			push dph
			push dpl
			acall putcharLCD
			pop dpl
			pop dph
			inc r7			; dzieki temu mozliwa inkrementacja DPTR
			inc dptr
			sjmp nextchar
	koniec: ret

// program glówny
	start:	init_LCD
	
			mov r6, #0FFH	; adres LCDdataWR  equ 0FF3DH jest w parze R6-R7
			mov r7, #30H
			
			ANL P3,#00H
			
			
			sterowanie:			
			
			JB P3.2, skok // P3.2 i P3.3 musza miec wartosc 1, aby zakonczyc.
			JB P3.3, skok
			
			kontynuuj:
			
			JB P3.5, pierwszy
			JB P3.4, drugi
			JB P3.3, trzeci
			JB P3.2, czwarty	
			
			JMP sterowanie
		
		skok:   JMP wyjscie
			
	pierwszy:	LCDcntrlWR #CLEAR
				LCDcntrlWR #HOME
				mov dptr, #text1
				acall putstrLCD				
				JMP sterowanie
			
	drugi:		LCDcntrlWR #CLEAR
				LCDcntrlWR #HOME
				mov dptr, #text2
				acall putstrLCD				
				JMP sterowanie
			
	trzeci:		LCDcntrlWR #CLEAR
				LCDcntrlWR #HOME	
				mov dptr, #text3
				acall putstrLCD
				JMP sterowanie
			
	czwarty:	LCDcntrlWR #CLEAR
				LCDcntrlWR #HOME
				mov dptr, #text4
				acall putstrLCD
				JMP sterowanie
	
	dalej:      JMP kontynuuj 	
	wyjscie:	JNB P3.3, dalej
				JNB P3.2, dalej
			
		
	nop
	nop
	nop
	jmp $
	end start