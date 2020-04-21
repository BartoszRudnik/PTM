ljmp start;
org 0000h;
	start:	
	MOV DPTR, #1000H;
	MOV A, #60H;
	MOVX @DPTR, A;
	INC DPTR;
	MOV A, #50H;
	MOVX @DPTR, A;
	CLR A;	
	MOVX A, @DPTR;
	DEC DPL;	
	MOVX A, @DPTR;
	nop;
	nop;
	nop;
	jmp $;
	end start;
	