ORG		120H
MYDATA:		DB	'2017'
SOURCE	EQU		120H
STORAGE	EQU		040H
DPS		EQU		86H
NEEDSHIFT	EQU	PSW.5
ORG		0H
	START:
	MOV 	SP,	#50H		;Initialize stack to safe location
	MOV		DPS,	#00H	;Indicate accessing dptr0
	MOV 	DPTR, 	#SOURCE	;Initialize SOURCE address
	MOV		DPS,	#01H	;Indicate accessing dptr1
	MOV		DPTR,	#STORAGE;Initialize STORAGE address
	SETB	NEEDSHIFT		;Initialize shifting flag
	LCALL	PROCESS_STRING	;Process the indicated string
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
	JNB		NEEDSHIFT,  NOSHIFT	;If shift is not needed, jump to relevant chunk
	ANL		A, #0FH				;Mask upper nibble
	SWAP	A					;Shift lower nibble to upper nibble	
	MOV		@R2, A			;Store translated value
	CLR		NEEDSHIFT			;Indicate that next value will populate lower bit
	RET
	NOSHIFT:
	ANL		A, #0FH			;Mask upper nibble
	MOV		B,	A
	CLR		A
	MOVC	A,	@A+DPTR
	ORL		A,	B			;Combine lower nibble with stored upper nibble
	MOVX	@DPTR, A		;Store complete value
	INC		DPTR			;One byte has now been populated, move on
	SETB	NEEDSHIFT		;Indicate next value will be shifted
	RET
	FINAL:
	SJMP FINAL
	END
