// FAST-40 CHRIN vector handler
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_character_input

// Vector handler for CHRIN (vectored through INPVEC2 at $0324 to $F20E)
character_input:
.pc = * "character_input"
{
			lda vic20.os_zpvars.DEVIN						// [3]		get input device
			beq keyboard									// [3/2]	handle keyboard input
			cmp #vic20.devices.SCREEN						// [2]		test for screen input device
			beq screen										// [3/2]	handle screen input
			jmp vic20.kernal.CHRIN2							// [3]		not keyboard or screen so let KERNAL handle it
screen:		sec												// [2]		set Carry (error flag) as we have no known path to here
			rts												// [6]

			// set for input from keyboard
keyboard:	txa												// [2]		stash .X and .Y to Stack
			pha												// [3]
			tya												// [2]
			pha												// [3]
			lda vic20.os_zpvars.INPUTSRC					// [3]		get input source (0=keyboard, !0=screen)
			bne screenin									// [2/3]	get input from screen

			// stash cursor position before input starts
			ldy vic20.os_zpvars.CRSRLPOS					// [3]		get cursor position for input start
			dey												// [2]		decrement for column index
 			sty vic20.os_zpvars.EOLPTR						// [3]		set physical input columnm
			sty vic20.os_zpvars.CRSRICOL					// [3]		set logical input column

			// wait for IRQ to put something in the keyboard buffer
waitkey:	lda vic20.os_zpvars.KEYCOUNT					// [3]		get keyboard buffer character count
			sta vic20.os_zpvars.CRSRMODE					// [3]		set cursor enable (0=flash, !0=no flash)
			beq waitkey										// [3/2]	loop until buffer contains something
			sei												// [2]		disable IRQ whilst we read buffer
			jsr vic20.kernal.GETCHAR						// [6]		get next char from buffer (and enable IRQ)

			// check for [SHIFT]+[RUN/STOP]
			cmp #vic20.screencodes.SHIFTRUN					// [2]		check for key
			bne checkcr 									// [3/2]	go check for [CR] if not

			// handle [SHIFT]+[RUN/STOP]
			sei												// [2]		disable IRQ whilst we stuff the buffer
			ldx #14											// [2]		command data length
 			stx vic20.os_zpvars.KEYCOUNT					// [3]		set keyboard buffer character count
loadloop:	lda f40_static_data.SRSLOAD-1,x					// [4]		get LOAD"$*",8 / LIST bytes
			sta vic20.os_vars.KEYBUFF-1,x					// [5]		inject into keyboard buffer
			dex												// [2]		decrement index
			bne loadloop									// [3/2]	loop for next character
			bit f40_runtime_memory.Memory_Bitmap 			// [4]		get b6 for JiffyDOS
			bvc waitkey										// [3/2]	execute if JiffyDOS not present
			lda #'*'										// [2]		asterisk
			sta vic20.os_vars.KEYBUFF+3						// [4]		inject into keyboard buffer
			ldx #4											// [2]		command data length
runloop:	lda f40_static_data.SRSRUN-1,x					// [4]		get RUN bytes
			sta vic20.os_vars.KEYBUFF+8,x					// [5]		inject into keyboard buffer
			dex												// [2]		decrement index
			bne runloop										// [3/2]	loop for next character
			beq waitkey										// [3/3]	execute

			// check for [CR] and output character if not
checkcr:	cmp #vic20.screencodes.CR						// [2]		check for [CR]
			beq docr										// [2/3]	go do [CR]
			jsr	f40_character_output.character_output		// [6]		output character
			bcc waitkey										// [3/3]	loop for next key from buffer (Carry is always clear)

			// handle [CR]
docr:		jsr f40_helper_routines.get_line_details		// [6]		get logical line length & start/end lines (.A/.Y/.X)
			beq lineend										// [2/3]	no input line to process if line length is zero
			sta vic20.os_zpvars.INPUTSRC					// [3]		set input source to screen (0=keyboard, !0=screen)
 			sta vic20.os_zpvars.LINELEN						// [3]		set logical line length
			sty vic20.os_zpvars.CRSRROW						// [3]		set cursor row to end of continuation group
 			stx vic20.os_zpvars.CRSRIROW					// [3]		set first input row for later
 			jsr f40_helper_routines.set_line_pointer 		// [6]		set line buffer pointer to line in .X
			ldy #0											// [2]
			sty vic20.os_zpvars.CRSRLPOS					// [3]		set cursor position for after line input

			// get character from screen for BASIC input
screenin:	inc vic20.os_zpvars.CRSRICOL					// [5]		increment screen input column
			ldy vic20.os_zpvars.CRSRICOL					// [3]		get screen input column
 			cpy vic20.os_zpvars.LINELEN						// [3]		check if beyond end of input line
			bcs lineend										// [2/3]	all done if beyond line length
			inc vic20.os_zpvars.EOLPTR						// [5]		increment stashed cursor position
			ldy vic20.os_zpvars.EOLPTR						// [3]		get stashed cursor position
			cpy #f40_runtime_constants.SCREEN_COLUMNS+1		// [2]		check physical column limit
			bne getchar										// [3/2]	no row increment if still on line

			inc vic20.os_zpvars.CRSRIROW					// [5]		increment screen input row
			ldx vic20.os_zpvars.CRSRIROW					// [3]		get screen input row
			jsr f40_helper_routines.set_line_pointer 		// [6]		set line buffer pointer to line in .X

			ldy #0											// [2]		reset cursor for new line
			sty vic20.os_zpvars.EOLPTR						// [3]		set stashed cursor position
getchar:	lax (vic20.os_zpvars.SCRNLNL),y					// [5]		get character from line

			// convert screen code to PETSCII
			asl												// [2]		multiply by 2
			sta vic20.os_zpvars.CHARBYTE					// [3]		stash character
			txa	 											// [2]		get character back
			and #%00111111									// [2]		mask off [SHIFT] and [CBM] bits
			bit vic20.os_zpvars.CHARBYTE					// [3]		test stashed character
			bpl checkcbm									// [3/2]	skip [SHIFT] if not set in stashed character
			ora #%10000000									// [2]		set [SHIFT] bit
checkcbm:	bcc setcbm										// [2/3]	Carry has original [SHIFT] bit
			ldx vic20.os_zpvars.QUOTMODE					// [3]		get editor quote mode (0=off, !0=on)
			bne flipquote									// [2/3]	skip [CBM] if quote mode enabled
setcbm:		bvs flipquote									// [2/3]	skip [CBM] if not set in stashed character
			ora #%01000000									// [2]		set [CBM] bit
flipquote:	jsr vic20.kernal.FLIPQUOT						// [6]		toggle quote-mode flag if character is a quote
			sta vic20.os_zpvars.CHARBYTE					// [3]		stash updated character
			bne exit										// [3/3]	return it

			// switch input source back to keyboard and output character if appropriate
lineend:	lda #vic20.screencodes.CR						// [2]		character is [CR]
			sta vic20.os_zpvars.CHARBYTE					// [3]		save character
			ldx #vic20.devices.KEYBOARD						// [2]		input is keyboard
			stx vic20.os_zpvars.INPUTSRC					// [4]		set input source
			ldx vic20.os_zpvars.DEVIN						// [3]		get input device
			cpx #vic20.devices.SCREEN						// [2]		is it the screen?
			beq retchar										// [2/3]	return the character if so
			ldx vic20.os_zpvars.DEVOUT						// [3]		get output device
			cpx #vic20.devices.SCREEN						// [2]		is it the screen?
			beq exit										// [3/2]	skip output

			// return character, fixing [PI] if required
retchar:	jsr f40_character_output.character_output		// [6]		output character
exit:		pla												// [4]		get .Y and .X back from Stack
			tay												// [2]
			pla												// [4]
			tax												// [2]
			lda vic20.os_zpvars.CHARBYTE					// [3]		get saved character
			cmp #vic20.screencodes.PICHAR					// [2]		test for [PI] character
			bne notpi										// [3/2]	skip to exit if not
			lda #vic20.screencodes.PITOKEN					// [2]		reset for alternate [PI] token code
notpi:		clc												// [2]		clear Carry (error flag)
			rts												// [6]
}
