ljmp start;
org 0100h;
	start: mov r0, #23H;
	mov r1, #27H;
	mov r2, #51H;
	mov r3, #82H;
	mov r4, #55H;
	mov r5, #92H;
	mov r6, #88H;
	mov r7, #02H;
	mov DPTR, #1000H;
	mov a,r0;
	movx @DPTR,a;
	inc DPTR;
	mov a,r1;
	movx @DPTR,a;
	inc DPTR;
	mov a,r2;
	movx @DPTR,a;
	inc DPTR;
	mov a,r3;
	movx @DPTR,a;
	inc DPTR;
	mov a,r4;
	movx @DPTR,a;
	inc DPTR;
	mov a,r5;
	movx @DPTR,a;
	inc DPTR;
	mov a,r6;
	movx @DPTR,a;
	inc DPTR;
	mov a,r7;
	movx @DPTR,a;
	
	mov DPTR,#1000H;
	mov r2, #08H;
	mov b, #00H;
	
	LOAD:
	movx a,@DPTR;
	inc DPTR;
	CJNE a,b,CHECK;
	CHECK:
	JNC MAX;	
	DJNZ r2, LOAD;
	mov a, r2;
	JZ EXIT;
	
	MAX:
	mov b,a;
	DJNZ r2, LOAD;
	
	EXIT:		
	nop;
	nop;
	nop;
	jmp $;
	end start;