// VIC-20 BRK debugging handler
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace vic20_debug_handler

.label HEXCHAR1	= $0003	    		//	8-bit Decimal-to-Hex first character
.label HEXCHAR2	= $0004		    	//	8-bit Decimal-to-Hex second character

// BRK handler (called via BRKVECL vector)
brk_handler:
.pc = * "brk_handler"
{
			ldx #46 										// [2]		message bytes to copy
getbyte:	lda DEBUGMSG,x 									// [4]		get message byte
			sta vic20.cpu.STACK,x 							// [5]		copy to RAM
			dex 											// [2]		decrement index#
			bpl getbyte 									// [3/2]	loop until done

			// populate .Y
			pla												// [4]		get .Y from Stack
			jsr decimal_to_hex 								// [6]		convert to hex
			lda HEXCHAR1									// [3]		get first hex character
			sta vic20.cpu.STACK+13 							// [4]		set message byte
			lda HEXCHAR2									// [3]		get second hex character
			sta vic20.cpu.STACK+14 							// [4]		set message byte

			// populate .X
			pla												// [4]		get .X from Stack
			jsr decimal_to_hex 								// [6]		convert to hex
			lda HEXCHAR1									// [3]		get first hex character
			sta vic20.cpu.STACK+8 							// [4]		set message byte
			lda HEXCHAR2									// [3]		get second hex character
			sta vic20.cpu.STACK+9 							// [4]		set message byte

			// populate .A
			pla												// [4]		get .A from Stack
			jsr decimal_to_hex 								// [6]		convert to hex
			lda HEXCHAR1									// [3]		get first hex character
			sta vic20.cpu.STACK+3 							// [4]		set message byte
			lda HEXCHAR2									// [3]		get second hex character
			sta vic20.cpu.STACK+4 							// [4]		set message byte

			// populate flag bits
			pla												// [4]		get .SR from Stack
			sta HEXCHAR1									// [3]		stash for bit extraction
			lda #94 										// [2]		flag set indicator
			ldx #7 											// [2]		flag count
nextbit:	ror HEXCHAR1									// [5]		shift flag bit to Carry
			bcc notset	 									// [2/3]	skip indicator if not set
			cpx #2 											// [2]		check if this is b5
			beq notset 										// [2/3]	skip b5
			sta vic20.cpu.STACK+37,x						// [4]		set flag bit indicator
notset:		dex 											// [2]		decrement flag index
			bpl nextbit										// [3/2]	loop until done

			// populate .PCL
			pla												// [4]		get .PCL from Stack
			sec 											// [2]		set Carry for subtract
			sbc #2 											// [2]		adjust for BRK address
			php 											// [3]		stash flags for underflow result in Carry
			jsr decimal_to_hex 								// [6]		convert to hex
			lda HEXCHAR1									// [3]		get first hex character
			sta vic20.cpu.STACK+28 							// [4]		set message byte
			lda HEXCHAR2									// [3]		get second hex character
			sta vic20.cpu.STACK+29							// [4]		set message byte

			// populate .PCH
			plp 											// [4]		get flags for .PCL underflow result in Carry
			pla												// [4]		get .PCH from Stack
			bcs noadjust									// [3/2]	skip .PCH decrement if no .PCL underflow
			sbc #0 											// [2]		decrement .PCH (Carry is clear)
noadjust:	jsr decimal_to_hex 								// [6]		convert to hex
			lda HEXCHAR1									// [3]		get first hex character
			sta vic20.cpu.STACK+26 							// [4]		set message byte
			lda HEXCHAR2									// [3]		get second hex character
			sta vic20.cpu.STACK+27							// [4]		set message byte

			// populate .SP
			tsx 											// [2]		get .SP
			txa 											// [2]		move to .A for conversion
			jsr decimal_to_hex 								// [6]		convert to hex
			lda HEXCHAR1									// [3]		get first hex character
			sta vic20.cpu.STACK+35 							// [4]		set message byte
			lda HEXCHAR2									// [3]		get second hex character
			sta vic20.cpu.STACK+36 							// [4]		set message byte

			// do re-initialisation, display debugging message, and do warm-start
			jsr vic20.kernal.RESKVEC						// [6]		reset vectors
			jsr vic20.kernal.INITIO							// [6]		reset VIA interrupts
			jsr vic20.kernal.INITSCRN						// [6]		initialise VIC
			lda #<vic20.cpu.STACK							// [2]		pointer to FAST-40 message string lo-byte
			ldy #>vic20.cpu.STACK							// [2]		pointer to FAST-40 message string hi-byte
			jsr vic20.basic.STROUT							// [6]		display string
			jmp (vic20.basic.BASICWRM)						// [5]		do BASIC warm-start
}


// Convert 8-bit binary to two hex characters
// => A				Input value
// <= HEXCHAR1/2	Output hex characters
decimal_to_hex:
.pc = *	"decimal_to_hex"
{
			tax 											// [2]		stash in .X for later
			and #%00001111									// [2]		mask off upper nybble
			tay 											// [2]		set character lookup index
			lda HEXCHARS,y 									// [4]		get second hex character
			sta HEXCHAR2									// [3]		stash for display
			txa 											// [2]		get stashed value back
			lsr 											// [2]		shift...
			lsr 											// [2]		...lower...
			lsr 											// [2]		......nybble...
			lsr 											// [2]		.........out
			tay 											// [2]		set character lookup index
			lda HEXCHARS,y 									// [4]		get second hex character
			sta HEXCHAR1									// [3]		stash for display
			rts 											// [6]
}

DEBUGMSG:							// Debugging message template
.pc = * "DEBUGMSG"
.byte vic20.screencodes.BLACK
.text "A:-- X:-- Y:-- NVBDIZC"
.text "PC:----  SP:--        "
.byte vic20.screencodes.BLUE,0

HEXCHARS:				// Hexadecimal character table
.pc = * "HEXCHARS"
.text "0123456789ABCDEF"
