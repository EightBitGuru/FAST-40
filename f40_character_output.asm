// FAST-40 CHROUT vector handler
// Copyright (C) 2026 8BitGuru <the8bitguru@gmail.com>

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

			// check if character is in the low/high control code range
			bpl checklo										// [2/3]	skip to low-range check if char < $80
			cmp #vic20.screencodes.INVSPACE					// [2]		check if high-range control code (char >= $A0)
			bcs notcode										// [2/3]	not a control code ($A0-$FF = inverse chars)
			cmp #vic20.screencodes.F1						// [2]		check if char >= $85
			bcc shiftchk									// [2/3]	not a control code ($80-$84)
			and #$1F										// [2]		mask for 5-bit index ($85-$9F)
			tay												// [2]		set high-range control code handler lookup index
			lda f40_static_data.CODEIDXH,y					// [4]		get high-range control code address index
			bmi notcode										// [2/3]	$FF = not a control code
			tay												// [2]		set control code handler address table index
			bpl iscode										// [3/3]	handle high-range control code

checklo:	cmp #vic20.screencodes.SPACE					// [2]		check if low-range control code (char >= $20)
			bcs shiftchk										// [2/3]	not a control code ($20-$7F = printable chars)
			tay												// [2]		set low-range control code handler lookup index
			lda f40_static_data.CODEIDXL,y					// [4]		get low-range control code address index
			bmi notcode										// [2/3]	$FF = not a control code
			tay												// [2]		set control code handler address table index
			bpl iscode										// [3/3]	handle low-range control code

			// character is not a control code
notcode:	txa												// [2]		restore char from .X (A and N clobbered by earlier path)
shiftchk:	bpl notshifted									// [3/2]	not shifted if b7 is clear
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
			lda vic20.os_vars.CURRCOLR						// [4]		get character colour
			sta (vic20.os_zpvars.COLRPTRL),y				// [4]		set colour RAM byte under cursor

			// set glyph data pointer and dispatch to unrolled merge routine
			lda f40_static_data.GLPHADDR.lo,x				// [4]		get character glyph data address lo-byte
			sta f40_runtime_memory.TEMPAL					// [3]		set ZP glyph pointer lo-byte
			lda f40_static_data.GLPHADDR.hi,x				// [4]		get character glyph data address hi-byte
			ora f40_runtime_memory.CASEFLAG					// [3]		add renderer glyph case offset
			sta f40_runtime_memory.TEMPAH					// [3]		set ZP glyph pointer hi-byte
			ldy #7											// [2]		glyph bytes to process (zero-based)
			lda f40_runtime_memory.CRSRMASK					// [3]		get column mask
			bpl mergleft									// [3/2]	left column if b7 clear ($0F)
			jmp f40_runtime_memory.MERGBITR					// [3]		right-column merge ($F0)
mergleft:	jmp f40_runtime_memory.MERGBITL					// [3]		left-column merge ($0F)

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
			lda f40_static_data.CONCODEL,y					// [4]		get control code handler address lo-byte
			sta f40_runtime_memory.TEMPBL					// [3]		set dispatch address lo-byte
			lda #>f40_controlcode_handlers.insert			// [2]		get control code handler page hi-byte
			sta f40_runtime_memory.TEMPBH					// [3]		set dispatch address hi-byte
			lda #0											// [2]		zero .A for any handlers that need it
			jmp (f40_runtime_memory.TEMPBL)					// [5]		jump to control code handler

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
			bne charout_tidyup								// [3/2]	non-zero means we didn't cross line boundary

			// check line continuation limit
			ldx vic20.os_zpvars.CRSRROW						// [3]		get cursor row
			lda f40_runtime_memory.LINECONT-1,x				// [4]		get previous line continuation byte
			lsr												// [2]		shift right
			bne charout_tidyup								// [2/3]	skip continuation if at maximum

			// extend (and possibly insert) line
			jsr f40_helper_routines.insert_blank_line		// [6]		insert blank line for continuation
 			lda f40_runtime_memory.REGXSAVE 				// [3]		get stashed row
			bne charout_tidyup								// [2/3]	skip redraw if no line inserted
			jsr f40_helper_routines.clear_text_bytes 		// [6]		clear text buffer row in .X
			stx f40_runtime_memory.DRAWROWS					// [3]		set redraw start row
			ldx #f40_runtime_constants.SCREEN_ROWS			// [2]		use bottom of screen for lower line limit
			jsr f40_helper_routines.redraw_line_range		// [6]		redraw changed lines to bottom of screen
			jsr f40_controlcode_handlers.reset_text_pointer	// [6]		reset line pointers
// Fall-through into charout_tidyup
}


// finalise character output
charout_tidyup:
.pc = * "charout_tidyup"
{
			jsr f40_interrupt_handlers.undraw_cursor 		// [6]		undraw cursor if required

			lda vic20.os_zpvars.CRSRROW						// [3]		get cursor row
			lsr												// [2]		divide by two for character matrix row
			tay												// [2]		stash index into row offset table

			ldx vic20.os_zpvars.CRSRLPOS					// [3]		get cursor position on logical line
			lda f40_static_data.COLOFFS,x					// [4]		get cursor blink mask for column
			sta f40_runtime_memory.CRSRMASK					// [3]		set cursor blink mask

			txa												// [2]		get cursor position back
			lsr												// [2]		divide by two for character matrix column
			clc												// [2]		clear Carry for addition
			adc f40_static_data.CROWOFFS,y					// [4]		add character matrix offset
			tay												// [2]		set character matrix index

			lax f40_runtime_memory.Character_Matrix,y		// [4]		get matrix character into .A and .X
			lsr												// [2]		divide by 16 for table index
			lsr												// [2]
			lsr												// [2]
			lsr												// [2]

			tay												// [2]		set hi-byte table index
			lda f40_static_data.BITADDRH-1,y				// [4]		get bitmap address hi-byte
			sta f40_runtime_memory.CRSRBITH					// [3]		set cursor draw address hi-byte

			txa												// [2]		restore matrix character from .X
			and #%00001111									// [2]		mask low nybble for table index
			tax												// [2]		set bitmap lo-byte table index
			ldy vic20.os_zpvars.CRSRROW						// [3]		get cursor row
			lda f40_static_data.ROWOFFS,y					// [4]		get bitmap row offset for row
			clc												// [2]		clear Carry (lsr chain above may have set it)
			adc f40_static_data.BITADDRL,x					// [4]		add bitmap address lo-byte (carry always 0 after)
			sta f40_runtime_memory.CRSRBITL					// [3]		set cursor draw address lo-byte

			pla												// [4]		pull .Y, .X and .A from Stack
			tay												// [2]
			pla												// [4]
			tax												// [2]
			pla												// [4]
			rts												// [6]
}
