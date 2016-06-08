* This program also counts through a sequence that starts at 0000 0000 and finishes
* as soon as it reaches 0000 0000 again. The difference to the program from before
* is that it has a delay loop. After incrementing A, it first branches to the subroutine.
* The subroutine pushes A onto the stack so that it can make use of the accumulator
* without disrupting the flow of the counting sequence. The subroutine then loads 
* #$00 into both A and B and then enters its loop. The loop increments A so long
* until it reaches #$ff, i.e. 255 times. For each time A reaches 255 times, it
* increments B by one, essentially counting how many times A has reached 255 and been
* subsequently reset. If A has reached 255 #$0f, i.e. 15, times, the subroutine exits
* its loop, pulls the original A from the stack, and returns from the subroutine
* back to the main loop. This delay loop makes it so that the sequence in the LED 
* lights counts up approximately once per second. 

* program code

	LDS	$00ff	initializes stack bottom at $00ff

* main loop

	ORG	$c000	places code at $c000 onwards
	LDAA	#$00	start position for switches loaded into A
Loop_0	STAA	LIGHTS	stores A into LIGHTS
	INCA		increments A
	BSR	Delay	branches to subroutine
	CMPA	#$00	checks whether the end has been reached
	BNE	Loop_0	branches if not
	STAA	LIGHTS	stores A last time in LIGHTS
	WAI		waits for interrupt

* delay loop

Delay	PSHA		pushes A onto stack so that it can be used in subroutine without losing count
	LDAA	#$00	loads A with #$00
	LDAB	#$00	loads B with #$00
Loop_1	INCA		increments A
	CMPA	#$ff	checks whether A has reached #$ff
	BNE	Loop_1	branches if not 
	INCB		increments B
	CMPB	#$0f	checks whether A has reached #$ff a total number of #$0f times
	BNE	Loop_1	branches if not
	PULA		pulls original A from stack to continue in main loop
	RTS		exits subroutine, goes back to main loop

* data definitions

LIGHTS	EQU	$1004	port B data reg