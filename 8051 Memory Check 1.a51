DATA1	EQU		055H
DATA2	EQU		0AAH
STORAGE	EQU		20H
CR 		EQU	0C0H			;Load Carraige Return command
ORG	120H
TXT:	DB	'Memory Error', 0
TXT2:	DB	'Memory Check Complete', 0
ORG		0H
	START:
	MOV	SP,		#050H	;Initialize stack safely
	MOV	020H,	#DATA1	;Store 55H in addresses from 20H to 30H
	MOV	021H,	#DATA1
	MOV	022H,	#DATA1
	MOV	023H,	#DATA1
	MOV	024H,	#DATA1
	MOV	025H,	#DATA1
	MOV	026H,	#DATA1
	MOV	027H,	#DATA1
	MOV	028H,	#DATA1
	MOV	029H,	#DATA1
	MOV	02AH,	#DATA1
	MOV	02BH,	#DATA1
	MOV	02CH,	#DATA1
	MOV	02DH,	#DATA1
	MOV	02EH,	#DATA1
	MOV	02FH,	#DATA1
	MOV	030H,	#DATA1
	
	MOV	A,	#DATA1
	XRL	A,	020H
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	021H
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	022H
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	023H
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	024H
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	025H
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	026H
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	027H
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	028H
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	029H
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	02AH
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	02BH
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	02CH
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	02DH
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	02EH
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	02FH
	JNZ	ERROR1
	MOV	A,	#DATA1
	XRL	A,	030H
	JNZ	ERROR1
	LCALL TEST2
	
ERROR1:
	MOV		DPTR,#TXT	;Point the data pointer to the text string
	LCALL  	LCD_string	;Write string to LCD
	LJMP	FINAL

TEST2:
	MOV	020H,	#DATA2	;Store 0AAH in addresses from 20H to 30H
	MOV	021H,	#DATA2
	MOV	022H,	#DATA2
	MOV	023H,	#DATA2
	MOV	024H,	#DATA2
	MOV	025H,	#DATA2
	MOV	026H,	#DATA2
	MOV	027H,	#DATA2
	MOV	028H,	#DATA2
	MOV	029H,	#DATA2
	MOV	02AH,	#DATA2
	MOV	02BH,	#DATA2
	MOV	02CH,	#DATA2
	MOV	02DH,	#DATA2
	MOV	02EH,	#DATA2
	MOV	02FH,	#DATA2
	MOV	030H,	#DATA2
	
	MOV	A,	#DATA2
	XRL	A,	020H
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	021H
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	022H
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	023H
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	024H
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	025H
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	026H
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	027H
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	028H
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	029H
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	02AH
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	02BH
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	02CH
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	02DH
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	02EH
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	02FH
	JNZ	ERROR2
	MOV	A,	#DATA2
	XRL	A,	030H
	JNZ	ERROR2
	
	MOV		DPTR,#TXT2	;Point the data pointer to the text string
	LCALL  	LCD_string	;Write string to LCD
	LJMP	FINAL
	
ERROR2:
	MOV		DPTR,#TXT	;Point the data pointer to the text string
	LCALL  	LCD_string	;Write string to LCD
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