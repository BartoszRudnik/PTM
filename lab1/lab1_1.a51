ljmp start;
org 0100h;
	start:
	mov a, #0ffH;
	mov r0, #0ffH;
	mov r1, #0ffH;
	mov r2, #0ffH;
	add a, r0;
	mov r3, a;
	mov a, r1;
	addc a, r2;
	mov r4, a;
	mov r5, #CY;
	EXIT:
	nop;
	nop;
	nop;
	jmp $;
	end start;