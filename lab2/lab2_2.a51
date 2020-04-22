ljmp start

p6 EQU 0FAH
	
org 050h
			
	delay: 	mov r0, #0FFH;
	tutam:  mov r1, #0FFH;
	tam: 	mov r2, #0FFH;
	tu: 	djnz r2, tu;
			djnz r1, tam;
			djnz r0, tutam;
			ret
		
org 0100h
	
	start:  
	
	mruga:  ANL p6, #0AEH;
			acall delay;
			ORL p6, #01H;
			acall delay;
			ORL p6, #10H;
			acall delay;
			ORL p6, #40H;
			acall delay;
			ANL p6, #0BFH;
			acall delay;
			ANL p6, #0EFH;
			acall delay;
			ANL p6, #0FEH;
			acall delay;
			ORL p6, #0FFH;
			acall delay;
						
			jmp mruga
			
	nop
	nop
	nop
	jmp $
	end start