* This program moves a block of 16 bytes of RAM from memory location $0080 to $B680.
* It does so by first loading the start address of the original memory block into X
* and the first target address into Y. Then it loads the first byte to be moved into
* A from X with 0 offset and then stores that byte into Y with 0 offset. Subsequently,
* it increments both X and Y by one to move on which byte is now to be copied and to
* where. It checks whether it has reached the last of the 16 bytes by comparing X
* against #End which is the last memory location that a byte of the block should be 
* copied from. If it has reached the end of the block, it waits for an interrupt. 

* main program

	ORG	$c000	organizes the following program code at memory location $c000 and onward
	LDX	#$0080	loads X with #$0080, the original position of the 16 bytes
	LDY	#$B680	loads Y with #$B680, the target position of the 16 bytes
Loop	LDAA	0,X	loads into A what is in memory location X + 0
	STAA	0,Y	stores A into memory location Y + 0
	INX		increments X to move the next byte
	INY		increments Y 
	CPX	#End	checks whether the end of the block of 16 bytes has been reached
	BNE	Loop	loops if not
	WAI		wait for interrupt after the block has been moved

* data definitions

End	EQU	$0090	makes End equivalent to memory location $0090