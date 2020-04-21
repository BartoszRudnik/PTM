ljmp start;
org 0100h;	
start: mov a, #09H;
	mov r0, #08H;
	mov r1, #0faH;
	mov r2, #0d5H;
	SUBB a, r0;
	mov r3, a;
	mov a, r1;
	SUBB a, r2;
	mov r4, a;
	nop;
	nop;
	nop;
	jmp $;
	end start;
 
	