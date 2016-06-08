* This program uses the I/O Box LEDs to count through a sequence that starts at 
* 0000 0000 and finishes when it reaches 0000 0000 again. It first loads #$0000
* into accumulator A, then enters the loop. The loop stores the value of A into 
* LIGHTS which is the data register for port B that controls the LEDs. The program
* then increments A, compares it to #$00 to check whether it has reached the end,
* and branches back to the beginning of the loop if not. If the end is reached, 
* it stores the last value of A, #$00, into LIGHTS, and then waits for an interrupt.

* program code

	ORG	$c000	puts program code at position $c000 and onward
	LDAA	#$0000	start position for switches, loaded into A
Loop	STAA	LIGHTS	stores A in LIGHTS
	INCA		increases A
	CMPA	#$00	checks whether to stop or not
	BNE	Loop	branches if end not reached
	STAA	LIGHTS	stores A last time in LIGHTS
	WAI		waits for interrupt


* data definitions

LIGHTS	EQU	$1004	port B data reg 