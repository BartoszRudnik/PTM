ljmp start

org 050h
	
	delay: 	mov r0, #255
	tam:	mov r1, #255
	tu:		djnz r1, tu	
			djnz r0, tam
			ret
			
		
org 0100h
	
	naprz:	mov r5, #08H;
			mov DPTR, #1000H;
	dal:	movx a, @DPTR;
			inc DPTR;
			mov p1, a;
			acall delay;
			djnz r5, dal;
			ret;
			
org 0200h
	
	wtyl: mov r6, #08H;
		  mov DPTR, #1007H;
	tl:	  movx a, @DPTR;
		  dec DPL;
		  mov p1, a;
		  acall delay;
		  djnz r6, tl;
		  ret;				

org 0300h	
	
start:	mov DPTR, #1000H;
		mov a, #01H;
		movx @DPTR, a;
		inc DPTR;
		mov a, #02H;
		movx @DPTR, a;
		inc DPTR;
		mov a, #04H;
		movx @DPTR, a;
		inc DPTR;
		mov a, #08H;
		movx @DPTR, a;
		inc DPTR;
		mov a, #10H;
		movx @DPTR, a;
		inc DPTR;
		mov a, #20H;
		movx @DPTR, a;
		inc DPTR;
		mov a, #040H;
		movx @DPTR, a;
		inc DPTR
		mov a, #080H;
		movx @DPTR, a;		
		
		mov DPTR, #1000H;
		
	
GUZIK:	mov a, p3;
		mov p1, a;
		

czesc1: mov r7, #10;
mruga:	acall naprz;			
		acall wtyl;
		djnz r7, mruga;
		
		
		mov DPTR, #1000H;
		mov a, #01H;
		movx @DPTR, a;
		inc DPTR;
		mov a, #03H;
		movx @DPTR, a;
		inc DPTR;
		mov a, #07H;
		movx @DPTR, a;
		inc DPTR;
		mov a, #0FH;
		movx @DPTR, a;
		inc DPTR;
		mov a, #1FH;
		movx @DPTR, a;
		inc DPTR;
		mov a, #3FH;
		movx @DPTR, a;
		inc DPTR;
		mov a, #7FH;
		movx @DPTR, a;
		inc DPTR
		mov a, #0FFH;
		movx @DPTR, a;		
		
		mov DPTR, #1000H;
		
		
czesc2: mov r7, #10;
mruga2: acall naprz;
		acall wtyl;
		djnz r7, mruga2;
	
		nop;
		nop;
		nop;
		jmp $;
		end start;