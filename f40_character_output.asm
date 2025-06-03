// FAST-40 CHROUT vector handler
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_character_output

// Vector handler for CHROUT (vectored through OUTVEC2 at $0326, through $F27A, to $E742)
character_output:
.pc = * "character_output"
{
			sta vic20.os_zpvars.CHARBYTE					// [3]		save output character
			pha												// [3]		push output character to Stack
			lda vic20.os_zpvars.DEVOUT						// [3]		get output device
			cmp #vic20.devices.SCREEN						// [2]		check if screen
			beq screen										// [3/2]	do output to screen
			jmp vic20.kernal.CHROUT2						// [3]		jump to KERNAL for non-screen output

			// output device is screen, so we handle it
screen:		txa												// [2]		save .X and .Y to Stack
			pha												// [3]
			tya												// [2]
			pha												// [3]
			lda #vic20.devices.KEYBOARD						// [2]
			sta vic20.os_zpvars.INPUTSRC					// [3]		set input source
			lax vic20.os_zpvars.CHARBYTE					// [3]		get output character to .A and .X

			// check if character is in a control code range
			cmp #vic20.screencodes.INVSPACE					// [2]		check if greater or equal to [INVERSE-SPACE]
			bcs notcode										// [2/3]	skip control code lookup if so
			cmp #vic20.screencodes.F1						// [2]		check if greater or equal to [F1]
			bcs checkcode									// [2/3]	do control code lookup if so
			cmp #vic20.screencodes.SPACE					// [2]		check if greater or equal to [SPACE]
			bcs notcode										// [2/3]	skip control code lookup if so

			// lookup character in control codes
checkcode:	ldy #34											// [2]		control code table index
testcode:	cmp f40_static_data.CONCODEC,y					// [4]		check for control character code
			beq iscode										// [3/2]	go handle control code
			dey												// [2]		decrement table index
			bpl testcode									// [3/2]	loop until done

			// character is not a control code
notcode:	txa												// [2]		transfer from .X to set flags
			bpl notshifted									// [3/2]	not shifted if b7 is clear
			cmp #%11000000									// [2]		check b7/b6
			bcs clearb7										// [3/2]	SHIFTed glyph if both set
			sbc #63											// [2]		CBMed glyph if only b6
clearb7:	and #%01111111									// [2]		clear b7 for appropriate glyph
			bne setrvs										// [3/3]	do RVS mode
notshifted:	jsr vic20.kernal.FLIPQUOT						// [6]		toggle quote-mode flag if character is a quote
			and #%00111111									// [2]		clear b6 for screen code
setrvs:		ora vic20.os_zpvars.RVSFLAG						// [3]		set/clear reverse mode

			// prepare for character render
renderchar:	tax												// [2]		set character screen code index
			ldy #0											// [2]
			sty vic20.os_zpvars.CRSRBLNK					// [3]		set cursor blink phase off
			sty f40_runtime_memory.CRSRUDRW					// [3]		clear cursor undraw flag
			ldy vic20.os_zpvars.INSRTCNT					// [3]		get pending INSERT count
			beq setchar										// [3/2]	skip decrement if already zero
			dec vic20.os_zpvars.INSRTCNT					// [5]		decrement pending INSERT count

			// output character to text buffer and set colour
setchar:	ldy vic20.os_zpvars.CRSRLPOS					// [3]		get cursor position on logical line (0-87)
			sta (vic20.os_zpvars.SCRNLNL),y					// [6]		write character to text buffer
			tya												// [2]		get matrix column from .Y
			lsr												// [2]		divide by two for character matrix column
			tay												// [2]		stash character matrix column in .Y
			lda vic20.os_vars.CURRCOLR						// [3]		get character colour
			sta (vic20.os_zpvars.COLRPTRL),y				// [4]		set colour RAM byte under cursor

			// set character data address and render masks
			lda f40_static_data.GLPHADDR.lo,x				// [4]		get character glyph data address lo-byte
			sta f40_runtime_memory.MERGROUT+1				// [4]		set data read address lo-byte
			lda f40_static_data.GLPHADDR.hi,x				// [4]		get character glyph data address hi-byte
			ora f40_runtime_memory.CASEFLAG					// [3]		add renderer glyph case offset
			sta f40_runtime_memory.MERGROUT+2				// [4]		set data read address hi-byte
			lda f40_runtime_memory.CRSRMASK					// [3]		get character mask
			eor #$FF										// [2]		invert it
			sta f40_runtime_memory.MERGROUT+11				// [4]		set screen bitmap mask

			// call self-modifying bitmap merge routine, which returns to line_contination
			ldy #7											// [2]		glyph bytes to process
			jmp f40_runtime_memory.MERGROUT					// [3]		jump to self-modifying render code

			// handle the control code
iscode:		cpx #vic20.screencodes.CR 						// [2]		check for [CR]
			beq actionit									// [2/3]	[CR] ignores inserts and quote mode
			cpx #vic20.screencodes.INSERT 					// [2]		check for [INS]
			beq chkquote									// [2/3]	[INS] ignores insert mode
			lda vic20.os_zpvars.INSRTCNT					// [3]		get pending INSERT count
			bne displayit									// [2/3]	display as a visible character if inserts pending
			cpx #vic20.screencodes.DELETE 					// [2]		check for [DEL]
			beq actionit									// [2/3]	[DEL] ignores quote mode
chkquote:	lda vic20.os_zpvars.QUOTMODE					// [3]		get editor quote mode
			bne displayit									// [2/3]	display as a visible character if in quote mode
actionit:	lda #%10000000									// [2]		cursor undraw bit
			sta f40_runtime_memory.CRSRUDRW					// [3]		set cursor undraw flag
			sta f40_runtime_memory.CRSRCOLF					// [3]		clear cursor colour flag
			lda #>character_output_tidyup					// [2]		get charout exit routine address hi-byte
			pha												// [3]		push to Stack
			lda #<character_output_tidyup-1					// [2]		get charout exit routine address lo-byte
			pha												// [3]		push to Stack
			lda #>f40_controlcode_handlers.dispatch_page	// [3]		get control code handler page hi-byte
			pha												// [3]		push to Stack
			lda f40_static_data.CONCODEL,y					// [4]		get control code handler address lo-byte
			pha												// [3]		push to Stack
			lda #0											// [2]		zero .A for any handlers that need it
			rts												// [6]		return via control code handler

			// convert the control code into displayable form
displayit:	clc												// [2]		clear Carry before addition
			txa												// [2]		get character code from .X
			bmi add64										// [2/3]	add 64 if b7 set, otherwise 128
			adc #64											// [2]		add 64
add64:		adc #64											// [2]		add 64
			bne renderchar									// [3/3]	render the character
}


// Handle line continuation
line_continuation:
.pc = * "line_continuation"
{
			iny												// [2]		.Y = 0
			sty f40_runtime_memory.CRSRCOLF					// [3]		set cursor colour flag
			jsr f40_controlcode_handlers.cursor_right		// [6]		move cursor after character output
			lda vic20.os_zpvars.CRSRLPOS					// [3]		get cursor column (0-39)
			bne character_output_tidyup						// [3/2]	non-zero means we didn't cross line boundary

			// check line continuation limit
			ldx vic20.os_zpvars.CRSRROW						// [3]		get cursor row
			lda f40_runtime_memory.LINECONT-1,x				// [4]		get previous line continuation byte
			lsr												// [2]		shift right
			bne character_output_tidyup						// [2/3]	skip continuation if at maximum

			// insert line
			jsr f40_helper_routines.insert_blank_line		// [6]		insert blank line for continuation
			bpl character_output_tidyup						// [2/3]	skip redraw if no line inserted (.Y is +ve)
			txa 											// [2]		get current line for redraw limit
			jsr f40_helper_routines.redraw_lines_to_bottom	// [6]		redraw changed lines to bottom of screen
			jsr f40_controlcode_handlers.reset_text_pointer	// [6]		reset line pointers
// Fall-through into character_output_tidyup
}


// finalise character output
character_output_tidyup:
.pc = * "character_output_tidyup"
{
			jsr f40_interrupt_handlers.undraw_cursor 		// [6]		undraw cursor if required
			lda vic20.os_zpvars.CRSRROW						// [3]		get cursor row (0-23)
			lsr												// [2]		divide by two for character matrix row
			tax												// [2]		stash in .X for index into row offset table
			lda vic20.os_zpvars.CRSRLPOS					// [3]		get cursor position on logical line (0-87)
			lsr												// [2]		divide by two for character matrix column
			tay												// [2]		stash matrix column in .Y for later
			lda #%00001111									// [2]		set mask for left character (even column)
			bcs setmask										// [3/2]	skip switch to right character if odd
			lda #%11110000									// [2]		set mask for right character (odd column)
setmask:	sta f40_runtime_memory.CRSRMASK					// [3]		set cursor blink mask
			tya												// [2]		get matrix column back from .Y
			clc												// [2]		clear Carry for addition
			adc f40_static_data.CROWOFFS,x					// [4]		add character matrix offset
			tay												// [2]		set character matrix index
			ldx f40_runtime_memory.Character_Matrix,y		// [4]		get matrix character
			ldy vic20.os_zpvars.CRSRROW						// [3]		get cursor row (0-23)
			lda f40_static_data.BITADDRL-16,x				// [4]		get bitmap address lo-byte
			adc f40_static_data.BROWOFFS,y					// [4]		add bitmap row offset (0 or 8)
			sta f40_runtime_memory.CRSRBITL					// [3]		set cursor draw address lo-byte
			lda f40_static_data.BITADDRH-16,x				// [4]		get bitmap address hi-byte
			sta f40_runtime_memory.CRSRBITH					// [3]		set cursor draw address hi-byte
			pla												// [4]		pull .Y, .X and .A from Stack
			tay												// [2]
			pla												// [4]
			tax												// [2]
			pla												// [4]
			rts												// [6]
}
