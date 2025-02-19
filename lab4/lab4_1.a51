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
      mov 83h, 06h
	  mov 82h, 07h
							; � wskazuje gotowosc LCD
     // MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
      POP  ACC              ; w akumulatorze ponownie kod ASCII znaku na LCD
      MOVX @DPTR,A          ; kod ASCII podany do LCD � znak widoczny na LCD
      ENDM
	  
// macro do inicjalizacji wyswietlacza � bez parametr�w
init_LCD MACRO
         LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR � inicjalizacja LCD
         LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR � czyszczenie LCD
         LCDcntrlWR #LCDON    ; wywolanie macra LCDcntrlWR � konfiguracja kursora
         ENDM

// funkcja op�znienia

	delay:	mov r1, #0FFH
	jeden:	mov r2, #0FFH
	dwa:    mov r3, #0FFH	
    trzy:	djnz r3, trzy
			djnz r2, dwa
			djnz r1, jeden
			ret
			
// funkcja wypisania znaku
putcharLCD:	LCDcharWR
			ret

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
 
// program gl�wny
    start:  init_LCD			
			LCDcntrlWR #CLEAR
			LCDcntrlWR #HOME
			
			mov r6, #0FFH	; adres LCDdataWR  equ 0FF3DH jest w parze R6-R7
			mov r7, #30H	
				
			acall keyascii
								
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
			
puszczony:	mov a, P7
			anl a, r0
			clr c
			subb a, r2
			jz puszczony
			
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			acall putcharLCD
			inc r7
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
			acall putcharLCD
			inc r7
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
			acall putcharLCD
			inc r7
			jmp Sterowanie
						
	key_4:	mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz tu
			
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
			acall putcharLCD
			inc r7
tu:			jmp Sterowanie
			 
    nop
    nop
    nop
    jmp $
    end start
