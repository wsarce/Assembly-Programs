ORG		150H
	MYDATA: DB '8','9','4','7','6','2','5'
	SOURCE	EQU		150H
	STORAGE	EQU		40H
	DPS		EQU		86H
	ORG		0H
START:
	MOV 	SP,	#50H		;Initialize stack to safe location
	MOV		DPS,	#00H	;Indicate accessing dptr0
	MOV 	DPTR, 	#SOURCE	;Initialize SOURCE address
	MOV		DPS,	#01H	;Indicate accessing dptr1
	MOV		DPTR,	#STORAGE;Initialize STORAGE address
	LCALL	PROCESS_STRING	;Process the indicated string
	ADD 	A, R2			;Load sum into A for division
	DIV		AB				;Generate average from sum
	SJMP	FINAL			;Cease translation & loop endlessly
	
	PROCESS_STRING:
    CLR		A
	MOV		DPS,	#00H	;Indicate accessing dptr0
    MOVC  	A, @A+DPTR		;Pass data table entry to A
	INC   	DPTR	
	JZ    	EXIT1			;If A is zero, conclude string
    LCALL  	PROCESS_CHAR	;Translate selected character
    SJMP  	PROCESS_STRING
	EXIT1:
	RET
	
	PROCESS_CHAR:
	MOV		DPS,	#01H		;Indicate accessing dptr1
	ANL		A, #0FH				;Mask upper nibble
	//POP		2					;Pop running sum
	ADD		A,	R2				;Add new entry to sum
	MOV		R2,	A
	//PUSH	2					;Store new sum
	INC		B					;Count values stored
	RET
	
	FINAL:
	SJMP FINAL
	END