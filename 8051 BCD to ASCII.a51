	ORG		150H
	MYDATA:		DB	42H, 58H, 64H, 29H
	SOURCE	EQU		150H
	STORAGE	EQU		50H
	DPS		EQU		86H
	ORG		0H
	START:
	MOV 	SP,	#50H		;Initialize stack to safe location
	MOV		DPS,	#00H	;Indicate accessing dptr0
	MOV 	DPTR, 	#SOURCE	;Initialize SOURCE address
	MOV		DPS,	#01H	;Indicate accessing dptr1
	MOV		DPTR,	#STORAGE;Initialize STORAGE address
	SJMP	FINAL			;Cease translation & loop endlessly
	PROCESS_STRING:
    CLR		A
	MOV		DPS,	#00H	;Indicate accessing dptr0
    MOVC  	A, @A+DPTR		;Pass data table entry to A
	INC   	DPTR	
	JZ    	EXIT1			;If A is zero, conclude string
    LCALL  	UNPACK_BCD		;Translate selected character
    SJMP  	PROCESS_STRING
	EXIT1:
	RET

	UNPACK_BCD:
	MOV		DPS,	#01H	;Select storage pointer
	MOV		R2,	A			;Make copy of value
	ANL		A,	#0F0H		;Mask upper nibble
	SWAP	A				;Swap nibbles of A
	ORL		A,	#30H		;Translate to ascii
//	MOV		@DPTR,	A		;Store ascii value
	INC		DPTR			;Move to next storage space
	MOV		A,	R2			;Load copy of first value
	ANL		A,	#0FH		;Mask lower nibble
	ORL		A,	#30H		;Translate to ascii
//	MOV		@DPTR,	A		;Store ascii value
	INC		DPTR			;Move to next storage space
	RET
	
	FINAL:
	SJMP FINAL
	END