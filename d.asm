* Similar to the ones before, this program counts through the sequence 0000 0000 to 1111 1111 and
* again to 0000 0000. Additionally, if the strobe A switch is cycled from up to down, the count
* of the sequence is reversed.

* The reversing is achieved by having a variable UPDOWN in memory which can either be set to $00 
* or $ff. The main loop that counts either up or down first performs a check to this variable
* and, according to what it's set to, counts up or down. If UPDOWN is $ff, the loop counts up,
* and conversely, if UPDOWN is $00, it counts down. 

* If the interrupt service routine is entered through cycling strobe A from up to down, it prints
* a message to the LCD display informing the user that the count of the sequence has been reversed.
* It resets the strobe A flag so that upon exiting the interrupt service routine, a new interrupt is
* not immediately triggered. It also changes the value stored in UPDOWN so that the next time the
* counting loop checks whether to count up or down, it will did the opposite to what it did before
* the execution of the interrupt service routine. 

* The delay loop remains unchanged from the previous program and works the same way. 


* data definitions

STACK	EQU	$00ff	initialize bottom of stack
LCD	EQU	$1040	LCD display
IRQ	EQU	$FFF2	IRQ vector

PIOC	EQU	$1002	Parallel I/O Control Register
PORTCL	EQU	$1005	alternate latched port C
DDRC	EQU	$1007	Data Direction for port C

LIGHTS	EQU	$1004	Port B data reg

UPDOWN	EQU	$b600	this is the flag whether to count up or down, further down initialized to $ff for counting up

	ORG	IRQ
	FDB	IRQISR	set up interrupt service routine vector

	ORG	$c000

* main program

	LDS	#STACK	initialise stack
	CLR	DDRC	initialise port C to all inputs
	LDAB	$00	loads value $00 into accumulator B
	STAB	LCD	clear LCD display
	LDAA	#%01000000	loads value %01000000 into accumulator A
	STAA	PIOC	enable Strobe A interrupt on falling edge
	CLRA		clear A 
	CLI		enable IRQ

* loop counting up or down

	LDAB	#$ff	loads $ff into B
	STAB	UPDOWN	stores B in memory location UPDOWN to set the up/down flag 
Loop	STAA	LIGHTS	stores A in LIGHTS memory location
	LDAB	#$00	loads value of $00 into accumulator B
	CMPB	UPDOWN	compares accumulator B to UPDOWN
	BNE	UP	if zero, then branch to UP, otherwise continue to counting down
	DECA		decreases A to count down
	BSR	Delay	branches to delay loop
	CMPA	#$00	compares A to $00
	BNE	Loop	if not zero, branches to Loop
	STAA	LIGHTS	stores A in LIGHTS memory location
	WAI		waits for interrupt	
UP	INCA		increases A to count up
	BSR	Delay	branches to delay loop
	CMPA	#$00	compares A to $00
	BNE	Loop	branches to Loop if not zero
	STAA	LIGHTS	stores A in LIGHTS memory location
	WAI		waits for interrupt

* delay loop

Delay	PSHA		pushes A to stack so that A can be used for delay loop
	LDAA	#$00	loads $00 into A
	LDAB	#$00	loads $00 into B
Loop_del	INCA		increases A
	CMPA	#$ff	compares A to $ff
	BNE	Loop_del	if not zero, branches to Loop_del, will be zero each time A reaches $ff
	INCB		increases B, counts how many times A has reached $ff
	CMPB	#$09	compares B to $0c to see whether or not to exit delay loop
	BNE	Loop_del	if not zero, branches to Loop_del
	PULA		pulls from stack into accumulator A to continue where left off before delay loop
	RTS		return from subroutine to exit delay loop

* IRQ interrupt service routine

TEXT	FCC	"Count reversed by user"
IRQISR	CLRA		clears A
	STAA	LCD	clear LCD display
	LDAA	PIOC	reads PIOC once
	LDAA	PORTCL	reads PORTCL once so that strobe A flag is cleared
	LDAB	#22	number of characters in LCD message
	LDX	#TEXT	loads first address of text message into X
Loop_IRQ	LDAA	0,X	retrieve character from LCD message
	STAA	LCD	display retrieved character on LCD display
	INX		increase X 
	DECB		decrease B to repeat character retrieval until all characters are displayed on LCD
	BNE	Loop_IRQ	branch to Loop_IRQ until B is equal to zero
	LDAB	UPDOWN	loads UPDOWN value into B
	CMPB	#$ff	compares B to $ff to find out what UPDOWN should be changed to
	BNE	Change_U	if not zero, branch to Change_U to change UPDOWN to up flag value $ff
	LDAA	#$00	loads $00 into A
	STAA	UPDOWN	stores A in UPDOWN to change it to down flag value $00
	BRA	End_IRQ	branches to end of interrupt service routine
Change_U	LDAA	#$ff	loads $ff into A
	STAA	UPDOWN	stores A in UPDOWN to change it to up flag value $ff
End_IRQ	RTI		return from interrupt service routine, goes back to where the program was before the interrupt