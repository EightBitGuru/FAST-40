// FAST-40 helper routines which are not location-dependent
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_helper_routines

// Set temporary pointer for specified line
// => X			Text buffer line index
// <= TEMPAL/H	Pointer to specified line
set_line_address:
.pc = * "set_line_address"
{
			ldy f40_runtime_memory.TXTBUFSQ,x 				// [4]		get text buffer sequence index for line
			lda f40_static_data.TROWADDR.lo,y 				// [4]		get text buffer address lo-byte
			sta f40_runtime_memory.TEMPAL					// [3]		set text buffer pointer lo-byte
			lda f40_static_data.TROWADDR.hi,y 				// [4]		get text buffer address hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		set text buffer pointer hi-byte
			rts												// [6]
}


// Set text buffer pointer for specified line
// => X			Text buffer line index
// <= SCRNLNL/H	Pointer to specified line
set_line_pointer:
.pc = * "set_line_pointer"
{
			ldy f40_runtime_memory.TXTBUFSQ,x 				// [4]		get text buffer sequence index for line
			lda f40_static_data.TROWADDR.lo,y 				// [4]		get text buffer address lo-byte
			sta vic20.os_zpvars.SCRNLNL						// [3]		set screen line pointer lo-byte
			lda f40_static_data.TROWADDR.hi,y 				// [4]		get text buffer address hi-byte
			sta vic20.os_zpvars.SCRNLNH						// [3]		set screen line pointer hi-byte
			rts												// [6]
}


// Initialise all screen tables
initialise_screen:
.pc = * "initialise_screen"
{
			jsr f40_interrupt_handlers.undraw_cursor		// [6]		undraw cursor if required

			// clear bitmap and text buffer, and reset colour memory
			ldx vic20.os_vars.CURRCOLR						// [3]		get current text colour
			ldy #240										// [2]		bitmap index (240 * 16 = 3840)
initloop1:	lda #0											// [2]		initialise bitmap to zero
			sta f40_runtime_memory.Screen_Bitmap-1,y		// [5]		clear byte at offset on each page in bitmap
			sta f40_runtime_memory.Screen_Bitmap+239,y		// [5]		3x faster than a loop
			sta f40_runtime_memory.Screen_Bitmap+479,y		// [5]
			sta f40_runtime_memory.Screen_Bitmap+719,y		// [5]
			sta f40_runtime_memory.Screen_Bitmap+959,y		// [5]
			sta f40_runtime_memory.Screen_Bitmap+1199,y		// [5]
			sta f40_runtime_memory.Screen_Bitmap+1439,y		// [5]
			sta f40_runtime_memory.Screen_Bitmap+1679,y		// [5]
			sta f40_runtime_memory.Screen_Bitmap+1919,y		// [5]
			sta f40_runtime_memory.Screen_Bitmap+2159,y		// [5]
			sta f40_runtime_memory.Screen_Bitmap+2399,y		// [5]
			sta f40_runtime_memory.Screen_Bitmap+2639,y		// [5]
			sta f40_runtime_memory.Screen_Bitmap+2879,y		// [5]
			sta f40_runtime_memory.Screen_Bitmap+3119,y		// [5]
			sta f40_runtime_memory.Screen_Bitmap+3359,y		// [5]
			sta f40_runtime_memory.Screen_Bitmap+3599,y		// [5]
			txa												// [2]		get text colour from .X
			sta vic20.colour_ram.COLOUR1-1,y				// [5]		set byte at offset in colour matrix
			lda #vic20.screencodes.SPACE					// [2]		[SPACE]
			sta f40_runtime_memory.Text_Buffer-1,y			// [5]		clear byte at offset in text buffer
			sta f40_runtime_memory.Text_Buffer+239,y		// [5]
			sta f40_runtime_memory.Text_Buffer+479,y		// [5]
			sta f40_runtime_memory.Text_Buffer+719,y		// [5]
			dey												// [2]		decrement index
			bne initloop1									// [3/2]	loop for next location

			// reset text buffer sequence and line continuation tables
			ldx #f40_runtime_constants.SCREEN_ROWS			// [2]		row index
initloop2:	txa	 											// [2]		copy to .A
			sta f40_runtime_memory.TXTBUFSQ,x				// [5]		set sequence byte
			tya	 											// [2]		copy to .A (.A = 0)
			sta f40_runtime_memory.LINECONT,x				// [5]		set continuation byte
			dex												// [2]		decrement index
			bpl initloop2									// [3/2]	loop until done
			rts												// [6]
}


// Do SHIFT/C= case switch screen redraw
// => A			Case flag
// => X			Must be non-zero
case_redraw:
.pc = * "case_redraw"
{
			sta f40_runtime_memory.CASEFLAG					// [3]		set glyph case flag
			stx vic20.os_zpvars.CRSRMODE					// [3]		set cursor blink mode (!0 = no flash)
			lda #0											// [2]
			sta vic20.os_zpvars.CRSRBLNK					// [3]		clear cursor blink phase flag
// Fall-through into redraw_lines_to_bottom
}


// Redraw text buffer lines to bottom
// => A			Redraw start line
redraw_lines_to_bottom:
.pc = * "redraw_lines_to_bottom"
{
			ldx #f40_runtime_constants.SCREEN_ROWS			// [2]		bitmap redraw lower line limit
// Fall-through into redraw_line_range
}


// Redraw text buffer line range
// => A			Redraw start line
// => X			Redraw end line
redraw_line_range:
.pc = * "redraw_line_range"
{
			sta f40_runtime_memory.DRAWROWS					// [3]		stash redraw upper line limit
setrow:		stx f40_runtime_memory.REGXSAVE					// [3]		stash line for later
			jsr set_line_address							// [6]		set address of line in TEMPAL/H
			txa												// [2]		copy line index to .A for divide
			lsr												// [2]		divide by two for character matrix row
			tay												// [2]		stash in .Y for index into row offset table

			// get matrix character for column 19 of matrix row in .Y
			lda #19											// [2]		matrix column
			clc												// [2]		clear Carry for addition
			adc f40_static_data.CROWOFFS,y					// [4]		calculate character matrix index
			tay												// [2]		stash index in .Y for lookup
			lda f40_runtime_memory.Character_Matrix,y		// [4]		get matrix character
			tay												// [2]		stash character in .Y

			// calculate bitmap draw address using matrix character
// TODO: Test when InsDel starts calling this again
//.break
			//lda f40_runtime_memory.REGXSAVE					// [3]		get stashed cursor row (0-23)
			txa 											// [2]		get current line
			and #%00000001									// [2]		mask LSB (odd/even)
			asl												// [2]		multiply by 2...
			asl												// [2]		... by 4 ...
			asl												// [2]		... by 8
			adc f40_static_data.BITADDRL-16,y				// [5]		add bitmap address lo-byte
			sta f40_runtime_memory.TEMPBL					// [3]		set draw address lo-byte
			lda f40_static_data.BITADDRH-16,y				// [4]		get bitmap address hi-byte
			sta f40_runtime_memory.TEMPBH					// [3]		set draw address hi-byte
			ldy #38											// [2]		column index
getchars:	sty f40_runtime_memory.REGYSAVE					// [3]		stash column index for later

			// set first (left) character data address
			lax (f40_runtime_memory.TEMPAL),y				// [5]		get character from line
			lda f40_static_data.GLPHADDR.lo,x				// [4]		get character glyph data address lo-byte
			sta f40_runtime_memory.TEMPCL					// [3]		set data read address lo-byte
			lda f40_static_data.GLPHADDR.hi,x				// [4]		get character glyph data address hi-byte
			clc												// [2]		clear Carry for addition
			adc f40_runtime_memory.CASEFLAG					// [3]		add renderer glyph case offset
			sta f40_runtime_memory.TEMPCH					// [3]		set data read address hi-byte

			// check if both characters in this pair are the same
			iny												// [2]		next column
			txa												// [2]		move character to .A
			cmp (f40_runtime_memory.TEMPAL),y				// [5]		compare character from line
			beq samechar									// [2/3]	simple copy if the same

			// set second (right) character data address
			lax (f40_runtime_memory.TEMPAL),y				// [5]		get character from line
			lda f40_static_data.GLPHADDR.lo,x				// [4]		get character glyph data address lo-byte
			sta f40_runtime_memory.TEMPDL					// [3]		set data read address lo-byte
			lda f40_static_data.GLPHADDR.hi,x				// [4]		get character glyph data address hi-byte
			clc												// [2]		clear Carry for addition
			adc f40_runtime_memory.CASEFLAG					// [3]		add renderer glyph case offset
			sta f40_runtime_memory.TEMPDH					// [3]		set data read address hi-byte

			// merge character data with bitmap
			ldy #7											// [2]		glyph bytes to process
merge:		lda (f40_runtime_memory.TEMPCL),y				// [5]		get left character glyph data byte
			and #$F0										// [2]		mask-off right nybble
			sta f40_runtime_memory.LINECHAR					// [3]		stash left nybble
			lda (f40_runtime_memory.TEMPDL),y				// [5]		get right character glyph data byte
			and #$0F										// [2]		mask-off left nybble
			ora f40_runtime_memory.LINECHAR					// [3]		merge with left nybble
			sta (f40_runtime_memory.TEMPBL),y				// [6]		set bitmap byte
			dey												// [2]		decrement glyph byte counter
			bpl merge										// [3/2]	loop for next glyph byte
			bmi setaddr 									// [3/3]	go for next character pair

			// copy two identical characters to bitmap
samechar:	ldy #7											// [2]		glyph bytes to process
copyloop:	lda (f40_runtime_memory.TEMPCL),y				// [5]		get left character glyph data byte
			sta (f40_runtime_memory.TEMPBL),y				// [6]		set bitmap byte
			dey												// [2]		decrement glyph byte counter
			bpl copyloop									// [3/2]	loop for next glyph byte

			// decrement bitmap address for next character pair
setaddr:	lda f40_runtime_memory.TEMPBL					// [3]		get draw address lo-byte
			clc												// [2]		clear Carry for subtraction
			sbc #191										// [2]		subtract for previous column
			sta f40_runtime_memory.TEMPBL					// [3]		set draw address lo-byte
			bcs nextcol										// [3/2]	skip hi-byte decrement if no wrap
			dec f40_runtime_memory.TEMPBH					// [5]		decrement draw address hi-byte
nextcol:	ldy f40_runtime_memory.REGYSAVE					// [3]		get column index back
			dey												// [2]		decrement for next column pair
			dey												// [2]
			bpl getchars									// [3/2]	loop for next column
			ldx f40_runtime_memory.REGXSAVE					// [3]		get cursor row back
			dex												// [2]		decrement line index
			cpx f40_runtime_memory.DRAWROWS					// [3]		check redraw line limit
			//bpl setrow										// [3/2]	loop until done
			bmi exit										// [3/2]	exit when done
			jmp setrow										// [3]		loop for next row

exit:		dec vic20.os_zpvars.CRSRMODE					// [5]		reset cursor blink mode
			rts												// [6]
}


// Reload VIC vectors
reload_vectors:
.pc = * "reload_vectors"
{
			ldx #V1CPAL-V1CNTSC-1							// [2]		vector byte count
getbyte:	lda V1CNTSC,x									// [4]		get vector byte
			dex												// [2]		decrement for next byte
			stx f40_runtime_memory.TEMPAL					// [3]		stash .X for later
			sbc #64											// [2]		subtract offset
			sbc f40_runtime_memory.TEMPAL					// [3]		subtract index
			sta vic20.vectors.KVECBUFF,x					// [5]		stash for reload
			lda V1CNTSC,x									// [4]		get vector byte
			inx												// [2]		increment for previous byte
			stx f40_runtime_memory.TEMPAL					// [3]		stash .X for later
			sbc #64											// [2]		subtract offset
			sbc f40_runtime_memory.TEMPAL					// [3]		subtract index
			sta vic20.vectors.KVECBUFF,x					// [5]		stash for reload
			dex												// [2]		decrement for extra byte
			dex												// [2]
			bpl getbyte										// [3/2]	loop until done
			lda #<vic20.vectors.KVECBUFF					// [2]		pointer to interrupt reload vector lo-byte
			ldy #>vic20.vectors.KVECBUFF					// [2]		pointer to interrupt reload vector hi-byte
			jsr vic20.vectors.KVECLOAD						// [6]		load vectors
			jmp vic20.basic.NEWSTT							// [3]		BASIC warm-start
}


// Configure VIC settings for 40x24 mode
configure_vic:
.pc = * "configure_vic"
{
			ldx #15											// [2]		set register index
getbyte:	lda f40_static_data.VICNTSC,x					// [4]		get VIC register value
			sta vic20.vic.VCSCRNX,x							// [5]		set VIC register
			dex												// [2]		decrement index
			bpl getbyte										// [3/2]	loop until done

			// alter VIC settings for PAL mode if required
			bit f40_runtime_memory.Memory_Bitmap 			// [4]		get b7 for PAL/NTSC
			bpl settext										// [3/2]	skip PAL if NTSC
			lda f40_static_data.VICPAL						// [4]		get PAL value
			sta vic20.vic.VCSCRNX							// [4]		set VIC register
			lda f40_static_data.VICPAL+1					// [4]		get PAL value
			sta vic20.vic.VCSCRNY							// [4]		set VIC register
settext:	lda #0											// [2]
			sta f40_runtime_memory.CASEFLAG					// [3]		set glyph case flag ($00=upper-case, $08=lower-case)
			lda #BLUE										// [2]
			sta vic20.os_vars.CURRCOLR						// [4]		set current text colour
@exit:		rts												// [6]
}


// Delete a character and handle continuation line contraction
delete_character:
.pc = * "delete_character"
{
			lax vic20.os_zpvars.CRSRROW						// [3]		get cursor row (0-23)
			ora vic20.os_zpvars.CRSRLPOS					// [3]		merge cursor column (0-39)
			beq exit										// [2/3]	scram if at top-left corner
 			lda f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for this line
			sta f40_runtime_memory.REGASAVE					// [3]		stash byte for later
			ora vic20.os_zpvars.CRSRLPOS					// [3]		merge cursor column (0-39)
			beq movecrsr									// [2/3]	scram if first column of first line of group

			// populate work buffer
			jsr f40_interrupt_handlers.undraw_cursor		// [6]		undraw cursor if required
			jsr transfer_lines_to_buffer					// [6]		transfer text buffer lines to work buffer

			// set shuffle pointers and byte count
			lda #>f40_runtime_memory.InsDel_Buffer			// [2]		get work buffer hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		set source pointer hi-byte
			lda #<f40_runtime_memory.InsDel_Buffer			// [2]		get work buffer lo-byte
			clc												// [2]		clear Carry for addition
			adc f40_runtime_memory.LINECHAR					// [3]		add cursor position in work buffer
			tay												// [2]		stash for lo-bytes
			sty f40_runtime_memory.TEMPAL					// [3]		set source pointer lo-byte
			dey												// [2]		decrement
			sty f40_runtime_memory.TEMPBL					// [3]		set destination pointer lo-byte

.break
			ldx f40_runtime_memory.DRAWROWE					// [3]		get last line of block
 			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for last line
			ldx f40_static_data.LINEADD+1,y					// [4]		get length addition as buffer extent
			inx	
			txa
			sec												// [2]		set Carry for subtraction
			sbc f40_runtime_memory.LINECHAR					// [3]		subtract cursor position in work buffer
			sta f40_runtime_memory.LINECHAR					// [3]		stash count for later

			// shuffle bytes down at cursor position
			ldy #0											// [2]		initialise copy index
shuffle:	lda (f40_runtime_memory.TEMPAL),y				// [5]		get character from work buffer
			sta (f40_runtime_memory.TEMPBL),y				// [6]		set character down one byte
			iny												// [2]		increment index
			cpy f40_runtime_memory.LINECHAR					// [3]		check for count
			bne shuffle										// [3/2]	loop until done

			// Copy work buffer back to logical lines
			// here we at
.break
			lda #>f40_runtime_memory.InsDel_Buffer			// [2]		get work buffer hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		set source pointer hi-byte
			lda #<f40_runtime_memory.InsDel_Buffer			// [2]		get work buffer hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		set source pointer hi-byte
			ldx f40_runtime_memory.DRAWROWS					// [3]		get first line of block
			jsr set_line_address							// [6]		set TEMPAL/H to address of line in .X
			jsr copy_buffer_to_line

			// Clear continuation marker if line length has dropped below a line boundary

			// refresh modified rows
.break
redraw:		lda f40_runtime_memory.DRAWROWS					// [3]		get redraw start row
			ldx f40_runtime_memory.DRAWROWE					// [3]		get redraw end row
			jsr redraw_line_range							// [6]		redraw changed lines
movecrsr:	jmp f40_controlcode_handlers.cursor_left		// [3]		move cursor left
}

// // Delete a character and handle continuation line contraction
// delete_character:
// .pc = * "delete_character"
// {
// //.break
// 			lax vic20.os_zpvars.CRSRROW						// [3]		get cursor row (0-23)
// 			ora vic20.os_zpvars.CRSRLPOS					// [3]		merge cursor column (0-39)
// 			beq exit										// [2/3]	scram if at top-left corner
//  			lda f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for this line
// 			ora vic20.os_zpvars.CRSRLPOS					// [3]		merge cursor column (0-39)
// 			beq movecrsr									// [2/3]	scram if first column of first line of group

// 			// set redraw start row
// 			jsr f40_interrupt_handlers.undraw_cursor		// [6]		undraw cursor if required
// 			lda vic20.os_zpvars.CRSRLPOS					// [3]		get cursor column
// 			bne setfirst 									// [3/2]	skip row decrement if not first column
// 			dex												// [2]		start at previous row if deleting from column 0
// setfirst:	stx f40_runtime_memory.DRAWROWS					// [3]		stash redraw start row

// 			// stash start-of-line wrap characters
// nextline:	inx												// [2]		increment row for next line
// 			cpx #f40_runtime_constants.SCREEN_ROWS+1		// [2]		check if beyond last screen line
// 			bcs	allchecked									// [2/3]	skip further line checks if past last line
//  			lda f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for this line
// 			beq	allchecked									// [2/3]	skip further line checks if end of group
//  			jsr set_line_pointer 							// [6]		set line buffer pointer to next line
// 			ldy #0											// [2]
// 			lda (vic20.os_zpvars.SCRNLNL),y					// [5]		get first character from this line
// 			pha												// [3]		ST stash for shuffle wrap later
// 			jmp nextline									// [3]		loop back for next line
// allchecked:	lda #vic20.screencodes.SPACE					// [2]		[SPACE] for the end of the last line
// 			pha												// [3]		ST stash for shuffle wrap later

// 			// set redraw end row and shuffle characters back
// 			dex												// [2]		back up to previous line
//  			stx f40_runtime_memory.DRAWROWE					// [3]		stash for redraw end
// prevline:	jsr set_line_pointer 							// [6]		set line buffer pointer to line in .X
// 			sta f40_runtime_memory.TEMPAH					// [3]		set temporary address hi-byte
// 			ldy vic20.os_zpvars.SCRNLNL						// [3]		get screen line pointer lo-byte
// 			dey												// [2]		decrement for shuffle
// 			sty f40_runtime_memory.TEMPAL					// [3]		set temporary address lo-byte
// 			ldy vic20.os_zpvars.CRSRLPOS					// [3]		get cursor column
// 			cpx f40_runtime_memory.DRAWROWS					// [3]		compare this row with redraw start row
// 			bcc redraw 										// [2/3]	less than, so all rows processed
// 			beq checkcol									// [2/3]	do column check if on first row
// 			ldy #1											// [2]		set shuffle start column
// 			bne shuffle 									// [3/3]	shuffle line
// checkcol:	cpy #0											// [2]		check if first column
// 			bne shuffle										// [3/2]	do line shuffle if not deleting from first column

// 			// just overwrite last character on this row
// 			ldy #f40_runtime_constants.SCREEN_COLUMNS		// [2]		set last column
// 			inc f40_runtime_memory.TEMPAL					// [5]		increment temporary address lo-byte
// 			bne wrapchar									// [3/3]	set character

// 			// shuffle characters down on this row
// shuffle:	sty f40_runtime_memory.REGYSAVE					// [3]		stash shuffle start column
// 			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for current line
// 			lda f40_static_data.LINELEN,y					// [4]		get line length for current line
// 			sta f40_runtime_memory.REGASAVE					// [3]		stash line length for compare later
// 			ldy f40_runtime_memory.REGYSAVE					// [3]		get shuffle start column
// movechar:	lda (vic20.os_zpvars.SCRNLNL),y					// [5]		get character
// 			sta (f40_runtime_memory.TEMPAL),y				// [6]		set character one position back
// 			iny												// [2]		increment character index
// 			cpy f40_runtime_memory.REGASAVE					// [3]		check if at end of line
// 			bcc movechar									// [3/2]	less than, loop until done
// 			beq movechar									// [3/2]	equal, loop until done

// 			// wrap first character to end of previous line
// wrapchar:	pla												// [4]		ST get end-of-line character
// 			sta (f40_runtime_memory.TEMPAL),y				// [6]		set last character on line
// 			dex												// [2]		back up to previous line
// 			bpl prevline									// [3/3]	loop until all rows shuffled

// 			// refresh modified rows
// redraw:		lda f40_runtime_memory.DRAWROWS					// [3]		get redraw start row
// 			ldx f40_runtime_memory.DRAWROWE					// [3]		get redraw end row
// 			jsr redraw_line_range							// [6]		redraw changed lines
// movecrsr:	jmp f40_controlcode_handlers.cursor_left		// [3]		move cursor left
// }


// Insert blank line and/or set line continuation
// => X			Text buffer line index
insert_blank_line:
.pc = * "insert_blank_line"
{
			lda f40_runtime_memory.LINECONT,x				// [5]		get continuation byte for this line
			bne exit										// [2/3]	scram if already a continuation

			// check for any non-space on the line
			lda #vic20.screencodes.SPACE					// [2]		[SPACE]
			ldy #f40_runtime_constants.SCREEN_COLUMNS		// [2]		set index to end of line
checkspace:	cmp (vic20.os_zpvars.SCRNLNL),y					// [6]		find last non-space character on line
			bne notspace									// [2/3]	exit if not a space
			dey												// [2]		decrement character index
			bpl checkspace									// [3/2]	loop for next character
notspace:	tya 											// [2]		move to .A to set flags
			bmi set_continuation_previous					// [3/2]	just set continuation byte if no insert needed

			// set line address for bottom row
			stx f40_runtime_memory.REGXSAVE 				// [3]		stash current row
			ldx #f40_runtime_constants.SCREEN_ROWS			// [3]		last line (before shuffle)
			jsr set_line_address							// [6]		set address of line in TEMPAL/H

			// check which line insert is happening
			ldx f40_runtime_memory.REGXSAVE 				// [3]		get stashed row
			cpx #f40_runtime_constants.SCREEN_ROWS			// [2]		check if on bottom row
			bne calclines									// [3/2]	do insert if not

			// no insert needed on bottom row
			jsr set_continuation_previous					// [3]		just set continuation byte
			jmp clear_text_bytes 							// [3/3]	clear row in TEMPAL/H

			// shuffle continuation table and text buffer sequence table 'down' a row
calclines:	lax f40_controlcode_handlers.dispatch_page		// [4]		get screen line constant (22) to .A and .X
			sec												// [2]		set Carry for subtraction
			sbc f40_runtime_memory.REGXSAVE 				// [3]		subtract stashed row
			tay	 											// [2]		set line shuffle counter
copyloop:	lda f40_runtime_memory.TXTBUFSQ,x 				// [5]		get buffer key byte
			sta f40_runtime_memory.TXTBUFSQ+1,x 			// [5]		move to next line slot
			lda f40_runtime_memory.LINECONT,x 				// [5]		get continuation byte
			sta f40_runtime_memory.LINECONT+1,x 			// [5]		move to next line slot
			dex												// [2]		decrement line index
			dey												// [2]		decrement loop counter
			bpl copyloop									// [3/2]	loop until shuffle complete

			// set continuation byte and text buffer for inserted line
			jsr set_continuation_current					// [6]		set continuation byte
			lda f40_runtime_memory.TXTBUFOF 				// [4]		get text buffer sequence overflow byte
			sta f40_runtime_memory.TXTBUFSQ,x 				// [5]		insert into new line slot
			lda #0											// [2]
			sta f40_runtime_memory.LINCNTOF 				// [4]		clear line continuation overflow
			jmp clear_text_bytes 							// [3/3]	clear row in TEMPAL/H
}


// Set continuation byte to one greater than previous line
// => X			Text buffer line index
set_continuation_previous:
.pc = * "set_continuation_previous"
{
			txa												// [2]		move to .A to set flags
			beq set_continuation_current					// [2/3]	skip decrement if on first line
			dex												// [2]		decrement for previous line
// Fall-through into set_continuation_current
}


// Set continuation byte to one greater than current line
// => X			Text buffer line index
set_continuation_current:
.pc = * "set_continuation_current"
{
			ldy f40_runtime_memory.LINECONT,x				// [5]		get continuation byte for previous line
			iny												// [2]		increment byte for next line
			inx												// [2]		increment line index for next line
			shy f40_runtime_memory.LINECONT,x				// [5]		set continuation byte for next line
			rts												// [6]
}


// Insert a character and handle continuation line expansion
insert_character:
.pc = * "insert_character"
{
// 			ldx vic20.os_zpvars.CRSRROW						// [3]		get cursor row (0-23)
// 			stx f40_runtime_memory.DRAWROWS					// [3]		stash redraw start row

// 			// initialise end-of-line wrap characters
// checkline:	ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for this line
// 			lda f40_static_data.LINELEN,y					// [4]		get line length for this line
// 			tay	 											// [2]		set end-of-line column index
// 			lda (vic20.os_zpvars.SCRNLNL),y					// [5]		get end-of-line character
// 			pha												// [3]		stash for shuffle later
// 			ldy f40_runtime_memory.LINECONT+1,x				// [4]		get continuation byte for next line
// 			beq	allchecked									// [2/3]	skip further line checks if end of group
// 			inx												// [2]		increment for next line
// 			jsr set_line_pointer 							// [6]		set line buffer pointer to line in .X
// 			bne checkline									// [3/3]	loop back for next line

// 			// check for line limit, line continuation/insert, and screen scroll
// 			// .A = last EOL character / .X = last line of block / .Y = 0
// allchecked:	cmp #vic20.screencodes.SPACE					// [2]		check if last EOL character is [SPACE]
// 			bne checklen 									// [2/3]	need to scroll/insert line if not
// 			pla												// [4]		discard last stashed EOL character
// 			sta f40_runtime_memory.LINECHAR 				// [3]		clear refresh-to-end flag in b7
// 			bpl setendrow 									// [3/3]	set end row and do shuffle
// checklen:	lda f40_runtime_memory.LINECONT,x				// [4]		get last continuation byte for block
// 			lsr												// [2]		shift right
// 			bne maxlength 									// [2/3]	scram if at maximum line length
// 			cpx #f40_runtime_constants.SCREEN_ROWS			// [2]		check if on the last screen line
// 			beq scroll										// [2/3]	scroll the screen if so

// 			// insert line
// 			inx												// [2]		increment for next line
// 			jsr set_line_pointer 							// [6]		set line buffer pointer to line in .X
// 			jsr insert_blank_line 							// [6]		insert blank line for continuation
// 			lda #%10000000									// [2]
// 			sta f40_runtime_memory.LINECHAR 				// [3]		set refresh-to-end flag in b7
// 			bne setline 									// [3/3]	reset line pointer and do shuffle

// 			// scroll screen
// scroll:		jsr scroll_lines_up								// [6]		scroll the screen
// 			ldx vic20.os_zpvars.CRSRROW						// [3]		get cursor row
// 			dex												// [2]		decrement for scroll ...
// 			dex												// [2]		... twice
// 			stx vic20.os_zpvars.CRSRROW						// [3]		reset cursor row
// 			stx f40_runtime_memory.DRAWROWS					// [3]		reset redraw start row
// 			ldx #f40_runtime_constants.SCREEN_ROWS-1		// [2]		set current row
// 			jsr set_continuation_previous					// [6]		set continuation byte for new line
// setline:	jsr set_line_pointer 							// [6]		set line buffer pointer to line in .X

// 			// shuffle characters forward
// setendrow:	stx f40_runtime_memory.DRAWROWE					// [3]		stash redraw end row
// 			jsr f40_interrupt_handlers.undraw_cursor		// [6]		undraw cursor if required
// nextline:	ldy vic20.os_zpvars.SCRNLNH						// [3]		get line pointer address hi-byte
// 			sty f40_runtime_memory.TEMPAH					// [3]		set temporary address hi-byte
// 			ldy vic20.os_zpvars.SCRNLNL						// [3]		get line pointer address lo-byte
// 			iny												// [2]		increment for next character
// 			sty f40_runtime_memory.TEMPAL					// [3]		set temporary address lo-byte
// 			ldy #0											// [2]		set shuffle start column
// 			cpx f40_runtime_memory.DRAWROWS					// [3]		check if we are on start row
// 			bne skipit										// [2/3]	skip shuffle override if not on cursor row
// 			ldy vic20.os_zpvars.CRSRLPOS					// [3]		get cursor column
// skipit:		sty f40_runtime_memory.REGYSAVE					// [3]		stash shuffle start column for later
// 			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for current line
// 			lda f40_static_data.LINELEN,y					// [4]		get line length for current line
// 			tay												// [2]		set character index
// 			dey												// [2]		decrement to skip last character
// 			cmp vic20.os_zpvars.CRSRLPOS					// [3]		check if cursor at end of line
// 			bne movechar									// [3/2]	do shuffle if not
// 			cpx f40_runtime_memory.DRAWROWS					// [3]		check if we are on start row
// 			beq setchar										// [2/3]	skip shuffle at end of line on start row
// movechar:	lda (vic20.os_zpvars.SCRNLNL),y					// [5]		get character
// 			sta (f40_runtime_memory.TEMPAL),y				// [6]		set character one position forward
// 			dey												// [2]		decrement character index
// 			cpy f40_runtime_memory.REGYSAVE					// [4]		check if at shuffle start column
// 			bpl movechar									// [3/2]	loop until done

// 			// wrap last character to start of next line, or insert space
// setchar:	lda #vic20.screencodes.SPACE					// [2]		[SPACE]
// 			cpx f40_runtime_memory.DRAWROWS					// [3]		check if we are on start row
// 			beq insertchar 									// [2/3]	skip end-of-line character pull if so
// 			pla												// [4]		get stashed end-of-line character
// insertchar:	iny												// [2]		increment character index for insert
// 			sta (vic20.os_zpvars.SCRNLNL),y					// [6]		set insert character
// 			dex												// [2]		decrement back to previous row
// 			cpx f40_runtime_memory.DRAWROWS					// [3]		check if we are on start row
// 			bmi redraw										// [3/2]	exit loop when all rows shuffled
// 			jsr set_line_pointer 							// [6]		set line buffer pointer to line in .X
// 			bne nextline 									// [3/3]	loop for previous line

// 			// refresh modified rows
// redraw:		inc vic20.os_zpvars.INSRTCNT					// [5]		increment pending INSERT count
// 			lda f40_runtime_memory.DRAWROWS					// [3]		get redraw start row
// 			bit f40_runtime_memory.LINECHAR 				// [3]		get refresh-to-end flag
// 			bmi tobottom									// [3/2]	redraw to end if flag set
// 			ldx f40_runtime_memory.DRAWROWE					// [3]		get redraw end row
// 			jmp redraw_line_range							// [3]		redraw changed lines
// tobottom:	jmp redraw_lines_to_bottom						// [3]		redraw all lines to end of screen

// 			// discard unwanted end-of-line characters if no insert possible
// maxlength:	inx												// [4]		increment line
// discard:	pla												// [4]		discard stashed end-of-line character
// 			dex												// [2]		decrement for next row
// 			cpx f40_runtime_memory.DRAWROWS					// [3]		check if at start row
// 			bne discard										// [3/2]	loop until all discarded
			rts												// [6]
}


// Reset FAST-40 vectors
reset_vectors:
.pc = * "reset_vectors"
{
			jsr vic20.kernal.RESKVEC						// [6]		reset KERNAL I/O vectors
			lda #<f40_keyboard_decode.decode_keypress		// [2]		get SHIFT/CTRL/C= key handler lo-byte
			sta vic20.os_vars.DECODEL						// [4]		set decode vector lo-byte
			lda #>f40_keyboard_decode.decode_keypress		// [2]		get SHIFT/CTRL/C= key handler hi-byte
			sta vic20.os_vars.DECODEH						// [4]		set decode vector hi-byte
			lda #<f40_interrupt_handlers.irq_handler		// [2]		get IRQ handler lo-byte
			sta vic20.os_vars.IRQVECL						// [4]		set IRQ vector lo-byte
			lda #>f40_interrupt_handlers.irq_handler		// [2]		get IRQ handler hi-byte
			sta vic20.os_vars.IRQVECH						// [4]		set IRQ vector hi-byte
			lda #<f40_character_input.character_input		// [2]		get character input handler lo-byte
			sta vic20.os_vars.INPVEC2L						// [4]		set input vector lo-byte
			lda #>f40_character_input.character_input		// [2]		get character input handler hi-byte
			sta vic20.os_vars.INPVEC2H						// [4]		set input vector hi-byte
			lda #<f40_character_output.character_output		// [2]		get character output handler lo-byte
			sta vic20.os_vars.OUTVEC2L						// [4]		set output vector lo-byte
			lda #>f40_character_output.character_output		// [2]		get character output handler hi-byte
			sta vic20.os_vars.OUTVEC2H						// [4]		set output vector hi-byte
.if(EnableBRKDebugging)
{
			lda #<vic20_debug_handler.brk_handler			// [2]		get BRK handler lo-byte
			sta vic20.os_vars.BRKVECL						// [4]		set BRK vector lo-byte
			lda #>vic20_debug_handler.brk_handler			// [2]		get BRK handler hi-byte
			sta vic20.os_vars.BRKVECH						// [4]		set BRK vector hi-byte
}
// Fall-through into reset_wedge
}


// Reset BASIC wedge vector
reset_wedge:
.pc = * "reset_wedge"
{
			lda #<f40_basic_wedge.decode_command			// [2]		get BASIC decode handler lo-byte
			sta vic20.os_vars.NEWCODEL						// [4]		set decode vector lo-byte
			lda #>f40_basic_wedge.decode_command			// [2]		get BASIC decode handler hi-byte
			sta vic20.os_vars.NEWCODEH						// [4]		set decode vector hi-byte
			rts												// [6]
}


// Zap lines 0/1 and insert blank lines at 22/23
scroll_lines_up:
.pc = * "scroll_lines_up"
{
			lda vic20.os_vars.SHFTCTRL						// [4]		get SHIFT/CTRL flag
			and #%00000100									// [2]		mask CTRL bit
			beq nodelay										// [3/2]	skip delay if [CTRL] not pressed

			// do [CTRL] scroll delay
			ldy #0											// [2]		outer loop delay counter
delayloop:	dex												// [2]		decrement inner loop counter
			nop												// [2]		waste a couple of cycles
			bne delayloop									// [3/2]	do inner loop
			dey												// [2]		decrement outer loop counter
			bne delayloop									// [3/2]	do outer loop
			sty vic20.os_zpvars.KEYCOUNT 					// [2]		reset key count

			// stash matrix character pointer for top row
nodelay:	lda f40_runtime_memory.Character_Matrix			// [4]		get first character from first matrix row
			and #$0F										// [2]		mask top nybble
			tay												// [2]		set matrix lookup row offset
			lda f40_static_data.CROWOFFS,y					// [4]		get matrix lookup row pointer lo-byte
			sta f40_runtime_memory.MATROWL					// [3]		set matrix row pointer lo-byte

			// shuffle character and colour matrices 'up' a row
			ldy #36											// [2]		set character matrix index
matrixup:	lda f40_runtime_memory.Character_Matrix-16,y	// [4]		get character matrix byte (from #22 onwards)
			sta f40_runtime_memory.Character_Matrix-36,y	// [5]		set character one row back (to #0 onwards)
			lda vic20.colour_ram.COLOUR1-16,y				// [5]		get byte at offset in colour matrix
			sta vic20.colour_ram.COLOUR1-36,y				// [5]		set byte at offset in colour matrix
			iny												// [2]		increment index
			bne matrixup									// [3/2]	loop until done

			// set bottom row bitmap pointer and clear for matrix character
			ldy #19											// [2]		set character matrix index
resetchars:	sty f40_runtime_memory.REGYSAVE					// [3]		stash character matrix index
			lax (f40_runtime_memory.MATROWL),y				// [5]		get matrix character
			lda f40_static_data.BITADDRL-16,x				// [4]		get associated bitmap address lo-byte
			sta f40_runtime_memory.TEMPAL					// [3]		set bitmap draw address lo-byte
			lda f40_static_data.BITADDRH-16,x				// [4]		get associated bitmap address hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		set bitmap draw address hi-byte
			lda #0											// [2]
			ldy #15											// [2]		bitmap row index
zapbitmap:	sta (f40_runtime_memory.TEMPAL),y				// [6]		clear bitmap row byte
			dey												// [2]		decrement row index
			bpl zapbitmap									// [3/2]	loop until done

			// set bottom row matrix character and colour
			ldy f40_runtime_memory.REGYSAVE					// [3]		get character matrix index
			txa												// [2]		get matrix character
			sta f40_runtime_memory.Character_Matrix+220,y	// [5]		store in character matrix
			lda vic20.os_vars.CURRCOLR						// [4]		get current text colour
			sta vic20.colour_ram.COLOUR1+220,y				// [5]		set byte at offset in colour matrix
			dey												// [2]		decrement index
			bpl resetchars									// [3/2]	loop until done

			// shuffle continuation and text buffer sequence tables 'up' two rows
			ldx #206										// [2]		bytes to copy (50 bytes)
loop:		lda f40_runtime_memory.LINECONT-206,x			// [5]		get byte
			sta f40_runtime_memory.LINCNTUF-206,x			// [5]		stash two bytes back
			inx												// [2]
			bne loop										// [3/2]	loop until done

			// reset continuation bytes
			stx f40_runtime_memory.LINECONT 				// [4]		clear first row line continuation
			stx f40_runtime_memory.LINECONT+22				// [4]		clear last two rows line continuation
			stx f40_runtime_memory.LINECONT+23				// [4]
			stx f40_runtime_memory.LINCNTOF 				// [4]		clear overflow line continuation

			// loop buffer sequence bytes around to end of table
			lda f40_runtime_memory.TXTBUFUF					// [4]		get old first entry
			sta f40_runtime_memory.TXTBUFSQ+22				// [4]		stash in line 22
			lda f40_runtime_memory.TXTBUFUF+1				// [4]		get old second entry
			sta f40_runtime_memory.TXTBUFSQ+23				// [4]		stash in line 23

			// clear text bytes for bottom two lines
			ldx #f40_runtime_constants.SCREEN_ROWS-1		// [2]		first line to clear
			jsr set_line_address							// [6]		set address of line in TEMPAL/H
			jsr clear_text_bytes 							// [6]		clear row in TEMPAL/H
			inx												// [2]		increment for next line to clear
			jsr set_line_address							// [6]		set address of line in TEMPAL/H
// Fall-through into clear_text_bytes
}


// Set bytes of text buffer to spaces
// => TEMPAL/H	Pointer to text buffer line start
clear_text_bytes:
.pc = * "clear_text_bytes"
{
			lda #vic20.screencodes.SPACE					// [2]		[SPACE]
			ldy #f40_runtime_constants.SCREEN_COLUMNS		// [2]		text buffer bytes to clear
clearloop:	sta (f40_runtime_memory.TEMPAL),y				// [6]		clear text buffer byte
			dey												// [2]		decrement index
			bpl clearloop									// [3/2]	loop until done
			rts												// [6]
}


// Calculate logical line length (with trailing spaces removed) and continuation group start/end lines
// <= A		Line length
// <= X		Continuation group start line
// <= Y		Continuation group end line
// TODO: can this be optimised using similar logic to transfer_rows_to_buffer?
get_line_details:
.pc = * "get_line_details"
{
			ldx vic20.os_zpvars.CRSRROW						// [3]		get cursor row
findnext:	inx												// [2]		increment row for next line
			cpx #f40_runtime_constants.SCREEN_ROWS+1		// [2]		check screen line limit
 			bcs	saveline									// [2/3]	stop if beyond last line
			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for this line
			bne findnext									// [2/3]	loop until start of next group
saveline:	stx f40_runtime_memory.REGXSAVE 				// [3]		stash next group start line for later
prevline:	dex												// [2]		back to previous line
			jsr set_line_pointer 							// [6]		set line buffer pointer to line in .X
			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for this line
			sty f40_runtime_memory.REGYSAVE 				// [3]		stash continuation byte for later
			lda f40_static_data.LINELEN,y					// [4]		get line length of this line
			tay	 											// [2]		set line index
			lda #vic20.screencodes.SPACE					// [2]		[SPACE]
checkspace:	cmp (vic20.os_zpvars.SCRNLNL),y					// [5]		check character on line
			bne notspace									// [2/3]	stop if not [SPACE]
			dey												// [2]		decrement line index
			bpl checkspace									// [3/2]	loop for next character
			ldy f40_runtime_memory.REGYSAVE 				// [3]		get stashed line continuation byte
			bne prevline									// [3/3]	loop for previous line
			tya	 											// [2]		set line length to zero
			beq exit	 									// [3/3]	all done
notspace:	iny												// [2]		increment for 1-based index
			tya												// [2]		begin line length tally
			ldy f40_runtime_memory.REGYSAVE 				// [3]		get stashed line continuation byte
			beq exit	 									// [2/3]	all done if on first line of group
addlength:	dey												// [2]		decrement line continuation byte
			bmi exit										// [2/3]	all done when before continuation group start
			sec												// [2]		set Carry for 1-based length addition
			adc f40_static_data.LINELEN,y					// [3]		add line length of this line
			bne addlength 									// [3/3]	loop for previous line
exit:		pha								 				// [3]		stash line length to Stack
			lda f40_runtime_memory.REGXSAVE 				// [3]		get stashed next group start line
			tay												// [2]		copy to .Y
			dey												// [2]		decrement for this group end line
			clc												// [2]		clear Carry for subtraction
			sbc f40_runtime_memory.LINECONT,y				// [4]		subtract continuation byte for this line
			tax												// [2]		set group start line
			pla												// [4]		get stashed line length from Stack
			rts												// [6]
}


// Transfer text buffer lines to the work buffer
// => X			Screen line number
// <= DRAWROWS	First line of block
// <= DRAWROWE	Last line of block
// <= LINECHAR	Buffer cursor position
transfer_lines_to_buffer:
.pc = * "transfer_lines_to_buffer"
{
			lda #>f40_runtime_memory.InsDel_Buffer			// [2]		get work buffer hi-byte
			sta f40_runtime_memory.TEMPBH					// [3]		set buffer pointer hi-byte

			// compute work buffer cursor position and find first line of continuation block
			lda vic20.os_zpvars.CRSRLPOS					// [3]		get cursor column (0-39)
			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for this line
 			clc												// [2]		clear Carry for addition
			adc f40_static_data.LINEADD,y					// [4]		add length addition for this line
			sta f40_runtime_memory.LINECHAR					// [3]		stash work buffer cursor position
			txa												// [2]		shift line number to .A
 			sec												// [2]		set Carry for subtraction
			sbc f40_runtime_memory.LINECONT,x				// [4]		subtract continuation byte for this line
			tax												// [2]		first line of block
			stx f40_runtime_memory.DRAWROWS					// [3]		stash first line of block

			// copy text buffer lines to work buffer
setline:	jsr set_line_address							// [6]		set TEMPAL/H to address of line in .X
			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for current line
			lda f40_static_data.IDBUFFLO,y					// [4]		get work buffer offset lo-byte
			sta f40_runtime_memory.TEMPBL					// [3]		set buffer pointer lo-byte
			lda f40_static_data.LINEADD+1,y					// [4]		get length addition as buffer extent
			tay												// [2]		stash extent in .Y
			lda #vic20.screencodes.SPACE					// [2]		[SPACE]
			sta f40_runtime_memory.InsDel_Buffer,y			// [5]		set trailing [SPACE]
			jsr copy_line_to_buffer							// [6]		copy line to buffer
			inx												// [2]		increment line index
			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for this line
			bne	setline 									// [3/2]	loop until all lines copied
			dex												// [2]		decrement line
			stx f40_runtime_memory.DRAWROWE					// [3]		stash last line of block
			rts												// [6]
}


// Copy text buffer row to work buffer
// => TEMPAL/H	Pointer to text buffer row
// => TEMPBL/H	Pointer to work buffer
copy_line_to_buffer:
.pc = * "copy_line_to_buffer"
{
			ldy #f40_runtime_constants.SCREEN_COLUMNS		// [2]		set byte copy count
loop:		lda (f40_runtime_memory.TEMPAL),y				// [5]		get byte from text buffer
			sta (f40_runtime_memory.TEMPBL),y				// [6]		set byte in work buffer
			dey												// [2]		decrement count
			bpl loop										// [3/2]	loop until done
			rts												// [6]
}


// Copy work buffer to text buffer row
// => TEMPAL/H	Pointer to text buffer row
// => TEMPBL/H	Pointer to work buffer
copy_buffer_to_line:
.pc = * "copy_buffer_to_line"
{
			ldy #f40_runtime_constants.SCREEN_COLUMNS		// [2]		set byte copy count
loop:		lda (f40_runtime_memory.TEMPBL),y				// [5]		get byte in work buffer
			sta (f40_runtime_memory.TEMPAL),y				// [6]		set byte from text buffer
			dey												// [2]		decrement count
			bpl loop										// [3/2]	loop until done
			rts												// [6]
}
