DATA1	EQU	055H
DATA2	EQU	0AAH
SPAN	EQU	011H
STORAGE	EQU	020H
CR 		EQU	0C0H			;Load Carraige Return command
ORG	120H
TXT:	DB	'Memory Error', 0
TXT2:	DB	'Memory Check', 0
TXT3:	DB	'Complete', 0
	
ORG	0H
START:
	MOV	SP,	#50H		;Initialize stack safely
	LCALL	LCD_init	;Initialize the output ports & LCD
	LCALL	DELAY200MS	;Ensure LCD has time to power up
	MOV	R0,	#20H		;Load data's first register
	MOV	R1,	#11H		;Load data's length in registers
	MOV	A,	#DATA1		;Load the first piece of data to check with
	MOV	R2,	A			;Store written value for verification
	LCALL	POPULATE_MEM;Populate the data region with the chosen data value
	MOV	R0,	#20H		;Reset memory span
	MOV	R1,	#11H
	LCALL	VERIFY_MEM	;Verify memory location for chosen data value
	MOV	R0,	#20H		;Reset data starting register
	MOV	R1,	#11H		;Reset data length in registers
	MOV	A,	#DATA2		;Load second piece of test data
	MOV	R2,	A			;Load written data for verification
	LCALL	POPULATE_MEM;Populate memory zone with second test value
	MOV	R0,	#20H		;Reset memory span
	MOV	R1,	#11H
	LCALL	VERIFY_MEM	;Verify memory zone using second test value
	SJMP	SUCCESS		;If both tests pass, jump to success message

POPULATE_MEM:
	MOV	@R0, A					;Write test data to storage register
	INC		R0					;Increment to next register in data section
	DJNZ	R1,	POPULATE_MEM	;Increment check to progress through set number of registers
	RET
	
VERIFY_MEM:
	MOV	A,	@R0					;Read tested data to accumulator for manipulation
	INC		R0					;Increment to next register in data zone
	XRL	A,	R2					;Determine equality
	JNZ		ERROR				;If inequal bits detected, jump to error
	DJNZ	R1,	VERIFY_MEM		;Else continue incremental processing
	RET
	
ERROR:
	MOV		DPTR,#TXT	;Point the data pointer to the text string
	LCALL  	LCD_string	;Write string to LCD
	LJMP	FINAL
SUCCESS:
	MOV		DPTR,#TXT2	;Point the data pointer to the text string
	LCALL  	LCD_string	;Write string to LCD
	LCALL	LCD_cr
	MOV		DPTR,#TXT3
	LCALL	LCD_string
	LJMP	FINAL

LCD_init:
	
	;Initialization of ports
	MOV 	A, #0		;Load all zeros for port 1 configuration
	MOV		P1, A		;Configure port 1 as an output
	MOV 	A, #0		;Load all zeros for port 2 configuration
	MOV		P2, A		;Configure port 2 as an output
	
	;Initialization of LCD
	MOV		A,#38H	
	LCALL	LCD_cmd		;Function Set Command pulse 1
	LCALL	DELAY200MS
	LCALL	LCD_cmd		;Function Set Command pulse 2
	LCALL	DELAY200MS
	LCALL	LCD_cmd		;Function Set Command pulse 3
	LCALL	DELAY200MS
	LCALL	LCD_cmd		;Function Set (5 x 7, 2 line)
	LCALL	DELAY200MS
	MOV 	A,#08H		;Display off
	LCALL	LCD_cmd
	LCALL	DELAY200MS
	MOV		A,#01H		;clear LCD
  	LCALL	LCD_cmd
	LCALL	DELAY200MS
	MOV		A,#06H		;Increment mode, no shifting
	LCALL	LCD_cmd
	LCALL	DELAY200MS
	MOV		A,#0EH		;Display on, cursor on
  	LCALL	LCD_cmd
	LCALL	DELAY200MS
	RET

LCD_string:
    CLR   	A
    MOVC  	A,@A+DPTR	;Pass data table entry to A
	JZ    	EXIT1		;If A is zero, conclude string
    LCALL  	LCD_data		;Send character pointed to by A to LCD
    INC   	DPTR		;Move to next character
    SJMP  	LCD_string
	EXIT1:
	RET

LCD_cr: 
	MOV   	A,#CR
    LCALL	LCD_cmd		;Send CR command to LCD
    RET
	
DELAY200MS:
	PUSH	3
	MOV		R3,	#200
LOOP:
	LCALL	DELAY1MS
	DJNZ	R3,	LOOP
	POP		3
	RET
DELAY1MS:
	PUSH 	3			;Preserve used registers
	PUSH 	4
	MOV 	R3, #33		;External delay loop sentinal value
LOOP2:
	MOV 	R4, #255	;Internal delay loop sentinal value
LOOP1:
	DJNZ 	R4, LOOP1	;Wait until internal loop comcludes
	DJNZ 	R3, LOOP2	;Wait until external loop concludes
	POP 	4			;Replace preserved values
	POP		3
	RET
	
LCD_data:
	MOV		P1,A
	SETB 	P2.0		;Set RS pin (indicating data)
	CLR 	P2.1		;Clear RW pin, indicating writing
	SETB 	P2.2		;Begin enable bit pulse
	LCALL 	DELAY200MS	;Wait momentarily for actions to complete
	CLR		P2.2		;End enable bit pulse
	RET

LCD_cmd:
	MOV		P1, A		;Move the accumulator's command to port 1
	CLR 	P2.0		;Clear RS pin (indicating a command)
	CLR		P2.1		;Clear RW pin (indicating writing)
	SETB 	P2.2		;Begin enable bit pulse
	ACALL 	DELAY200MS	;Wait momentarily for actions to complete
	CLR 	P2.2		;End enable bit pulse
	RET
	
FINAL:
	SJMP	FINAL		;Loop infinitely once finished
END
