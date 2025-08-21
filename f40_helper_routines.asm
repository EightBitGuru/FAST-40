// FAST-40 helper routines (location-independent)
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_helper_routines

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


// Set temporary pointer for specified line
// => X			Text buffer line index
// <= TEMPAL/H	Pointer to specified line
set_temp_line_pointer:
.pc = * "set_temp_line_pointer"
{
			ldy f40_runtime_memory.TXTBUFSQ,x 				// [4]		get text buffer sequence index for line
			lda f40_static_data.TROWADDR.lo,y 				// [4]		get text buffer address lo-byte
			sta f40_runtime_memory.TEMPAL					// [3]		set text buffer pointer lo-byte
			lda f40_static_data.TROWADDR.hi,y 				// [4]		get text buffer address hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		set text buffer pointer hi-byte
			rts												// [6]
}


// Initialise screen tables
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


// Insert blank line and/or set line continuation
// => X			Text buffer line index
insert_blank_line:
.pc = * "insert_blank_line"
{
			stx f40_runtime_memory.REGXSAVE 				// [3]		stash current row
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
			bpl shuffle										// [2/3]	shuffle tables if line is not spaces

			// set continuation byte
setbyte:	ldy f40_runtime_memory.LINECONT-1,x				// [4]		get continuation byte for previous line
			iny												// [2]		increment byte for next line
			shy f40_runtime_memory.LINECONT,x				// [5]		set continuation byte for next line
@exit:		rts												// [6]

			// shuffle continuation table and text buffer sequence table 'down' a row
shuffle:	lax f40_controlcode_handlers.dispatch_page		// [4]		get screen line constant (22) to .A and .X
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
 			ldx f40_runtime_memory.REGXSAVE 				// [3]		get stashed row
			lda f40_runtime_memory.TXTBUFOF 				// [4]		get text buffer sequence overflow byte
			sta f40_runtime_memory.TXTBUFSQ,x 				// [5]		insert into new line slot
			lda #0											// [2]
			sta f40_runtime_memory.LINCNTOF 				// [4]		clear line continuation overflow
			sta f40_runtime_memory.REGXSAVE 				// [3]		clear stashed row
			beq setbyte										// [3/3]	set continuation for inserted row
}


// Delete a character
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

			// populate work buffer from screen lines
			jsr f40_interrupt_handlers.undraw_cursor		// [6]		undraw cursor if required
			jsr transfer_lines_to_buffer					// [6]		populate work buffer

			// set shuffle pointers and byte count
			lda #>f40_runtime_memory.InsDel_Buffer			// [2]		get work buffer hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		set source pointer hi-byte
			lda #<f40_runtime_memory.InsDel_Buffer			// [2]		get work buffer lo-byte
			clc												// [2]		clear Carry for addition
			adc f40_runtime_memory.LINECHAR					// [3]		add cursor position in work buffer
			sta f40_runtime_memory.TEMPAL					// [3]		set source pointer lo-byte
			sbc #0											// [2]		subtract 1 for shuffle
			sta f40_runtime_memory.TEMPBL					// [3]		set destination pointer lo-byte
			ldx f40_runtime_memory.DRAWROWE					// [3]		get last line of block
 			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for last line
			ldx f40_static_data.LINEADD+1,y					// [4]		get length addition as buffer extent
			inx												// [2]		add 1 for trailing byte
			txa												// [2]		move for subtraction
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

			// Copy work buffer back to screen lines and refresh them
			jsr transfer_buffer_to_lines					// [6]		transfer work buffer to text buffer lines
			lda f40_runtime_memory.DRAWROWS					// [3]		get redraw start row
			ldx f40_runtime_memory.DRAWROWE					// [3]		get redraw end row
			jsr redraw_line_range							// [6]		redraw changed lines
movecrsr:	jmp f40_controlcode_handlers.cursor_left		// [3]		move cursor left
}


// Insert a character and handle continuation line expansion
insert_character:
.pc = * "insert_character"
{
			jsr get_line_details							// [6]		populate work buffer and get line details
			cmp #vic20.screen.MAX_LINE_LENGTH				// [2]		check if line already full
			beq exit										// [2/3]	scram if no inserts possible

			// set shuffle pointers
			tax 											// [2]		stash line length
			jsr f40_interrupt_handlers.undraw_cursor		// [6]		undraw cursor if required
			lda #>f40_runtime_memory.InsDel_Buffer			// [2]		get work buffer hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		set source pointer hi-byte
			lda #<f40_runtime_memory.InsDel_Buffer			// [2]		get work buffer lo-byte
			adc f40_runtime_memory.LINECHAR					// [3]		add cursor position in work buffer
			sta f40_runtime_memory.TEMPAL					// [3]		set source pointer lo-byte
			adc #1											// [2]		add 1 for shuffle
			sta f40_runtime_memory.TEMPBL					// [3]		set destination pointer lo-byte
			txa 											// [2]		get line length
			sbc f40_runtime_memory.LINECHAR					// [3]		subtract cursor position
			tay	 											// [2]		set shuffle count

			// shuffle bytes up at cursor position and insert space
shuffle:	lda (f40_runtime_memory.TEMPAL),y				// [5]		get character from work buffer
			sta (f40_runtime_memory.TEMPBL),y				// [6]		set character up one byte
			dey												// [2]		decrement index
			bpl shuffle										// [3/2]	loop until done
			iny												// [2]		.Y = 0
			lda #vic20.screencodes.SPACE					// [2]		[SPACE]
			sta (f40_runtime_memory.TEMPAL),y				// [6]		set character

			// check if we have extended a logical line
			inc vic20.os_zpvars.INSRTCNT					// [5]		increment pending INSERT count
			iny 											// [2]		work buffer line index (.Y = 1)
			inx 											// [2]		increment line length
			cpx #f40_runtime_constants.LINE_1_OVERRUN		// [2]		check for line overrun
			beq addline										// [2/3]	do insert/scroll
			cpx #f40_runtime_constants.LINE_2_OVERRUN		// [2]		check for line overrun
			bne refresh										// [3/2]	no extension so just refresh updated lines
			iny 											// [2]		work buffer line index (.Y = 2)

			// clear extended line in work buffer ready for insert/scroll
addline:	ldx f40_static_data.IDBUFFLO,y					// [4]		get work buffer line 2 or 3 address
			inx												// [2]		increment lo-byte for 39 bytes
			stx f40_runtime_memory.TEMPAL					// [3]		set buffer pointer lo-byte
			ldy #f40_runtime_constants.SCREEN_COLUMNS-1		// [2]		set byte count
setspace:	sta (f40_runtime_memory.TEMPAL),y				// [6]		set character
			dey												// [2]		decrement index
			bpl setspace									// [3/2] 	loop until done

			// do insert or scroll
			ldx f40_runtime_memory.DRAWROWE					// [3]		get last line of block
			inx 											// [2]		increment for line extension
			cpx #f40_runtime_constants.SCREEN_ROWS+1		// [2]		check if beyond the last screen line
			beq scroll										// [2/3]	scroll the screen if so

			jsr set_line_pointer 							// [6]		set line buffer pointer to line in .X
			jsr insert_blank_line 							// [6]		insert blank line for continuation
			ldx #f40_runtime_constants.SCREEN_ROWS			// [2]		bottom of screen for lower line limit
			stx f40_runtime_memory.DRAWROWE					// [3]		set redraw end row
			bne refresh										// [3/3]	refresh to end of screen

			// scroll screen
scroll:		jsr scroll_lines_up								// [6]		scroll the screen
			dex												// [2]		decrement row (.X = 23)
			jsr set_line_pointer 							// [6]		set line buffer pointer to line in .X
			jsr insert_blank_line 							// [6]		insert blank line for continuation
			dex												// [2]		decrement row for scroll ...
			dex												// [2]		... twice (.X = 21)
			stx vic20.os_zpvars.CRSRROW						// [3]		reset cursor row
			stx f40_runtime_memory.DRAWROWS					// [3]		reset redraw start row

			// Copy work buffer back to screen lines and refresh them
refresh:	jsr transfer_buffer_to_lines					// [6]		transfer work buffer to text buffer lines
			ldx f40_runtime_memory.DRAWROWE					// [3]		get redraw end row
// Fall-through into redraw_line_range
}


// Redraw text buffer line range
// => DRAWROWS	Redraw start line
// => X			Redraw end line
// TODO: optimise this
redraw_line_range:
.pc = * "redraw_line_range"
{
setrow:		stx f40_runtime_memory.REGXSAVE					// [3]		stash line for later
			jsr set_temp_line_pointer						// [6]		set address of line in TEMPAL/H
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
			sbc #f40_runtime_constants.BITMAP_OFFSET		// [2]		subtract for previous column
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


// Calculate logical line length (with trailing spaces removed) and continuation group start/end lines
// <= A		Line length
// <= X		Continuation group start line
// <= Y		Continuation group end line
get_line_details:
.pc = * "get_line_details"
{
			ldx vic20.os_zpvars.CRSRROW						// [3]		get cursor row
			jsr transfer_lines_to_buffer					// [6]		populate work buffer
			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for last line in block
			ldx f40_static_data.LINESUM,y					// [4]		get line length sum for last line in block
			lda #vic20.screencodes.SPACE					// [2]		[SPACE]
checkspace:	cmp f40_runtime_memory.InsDel_Buffer,x			// [4]		check character in buffer
			bne done										// [2/3]	stop if not [SPACE]
			dex												// [2]		decrement character index
			bpl checkspace									// [3/2]	loop for next character
done:		inx												// [2]		add 1 to length
			txa 											// [2]		set line length
			ldx f40_runtime_memory.DRAWROWS					// [3]		get first line of block
			ldy f40_runtime_memory.DRAWROWE					// [3]		get last line of block
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

			// loop buffer sequence bytes around to end of table
			lda f40_runtime_memory.TXTBUFUF					// [4]		get old first entry
			sta f40_runtime_memory.TXTBUFSQ+22				// [4]		stash in line 22
			lda f40_runtime_memory.TXTBUFUF+1				// [4]		get old second entry
			sta f40_runtime_memory.TXTBUFSQ+23				// [4]		stash in line 23
			stx f40_runtime_memory.LINCNTOF 				// [4]		clear overflow line continuation

			// clear text bytes for bottom two lines
			ldx #f40_runtime_constants.SCREEN_ROWS-1		// [2]		first line to clear
			jsr clear_text_bytes 							// [6]		clear row in TEMPAL/H
			inx												// [2]		increment for next line to clear
// Fall-through into clear_text_bytes
}


// Set bytes of text buffer to spaces
// => X			Text buffer line index
clear_text_bytes:
.pc = * "clear_text_bytes"
{
			jsr set_temp_line_pointer						// [6]		set address of row in TEMPAL/H
			lda #vic20.screencodes.SPACE					// [2]		[SPACE]
			ldy #f40_runtime_constants.SCREEN_COLUMNS		// [2]		text buffer bytes to clear
clearloop:	sta (f40_runtime_memory.TEMPAL),y				// [6]		clear text buffer byte
			dey												// [2]		decrement index
			bpl clearloop									// [3/2]	loop until done
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

			// set copy pointers and trailing space
setline:	jsr set_temp_line_pointer						// [6]		set TEMPAL/H to address of line in .X
			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for current line
			lda f40_static_data.IDBUFFLO,y					// [4]		get work buffer offset lo-byte
			sta f40_runtime_memory.TEMPBL					// [3]		set buffer pointer lo-byte
			lda f40_static_data.LINEADD+1,y					// [4]		get length addition as buffer extent
			tay												// [2]		stash extent in .Y
			lda #vic20.screencodes.SPACE					// [2]		[SPACE]
			sta f40_runtime_memory.InsDel_Buffer,y			// [5]		set trailing [SPACE]

			// copy text buffer lines to work buffer
			ldy #f40_runtime_constants.SCREEN_COLUMNS		// [2]		set byte copy count
loop:		lda (f40_runtime_memory.TEMPAL),y				// [5]		get byte from text buffer
			sta (f40_runtime_memory.TEMPBL),y				// [6]		set byte in work buffer
			dey												// [2]		decrement count
			bpl loop										// [3/2]	loop until done
			inx												// [2]		increment line index
			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for this line
			bne	setline 									// [3/2]	loop until all lines copied
			dex												// [2]		decrement line
			stx f40_runtime_memory.DRAWROWE					// [3]		stash last line of block
			rts												// [6]
}


// Transfer work buffer to text buffer lines
// => DRAWROWS	First line of block
transfer_buffer_to_lines:
.pc = * "transfer_buffer_to_lines"
{
			ldx f40_runtime_memory.DRAWROWS					// [3]		get first line of block
setline:	jsr set_temp_line_pointer						// [6]		set TEMPAL/H to address of line in .X
			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for current line
			lda f40_static_data.IDBUFFLO,y					// [4]		get work buffer offset lo-byte
			sta f40_runtime_memory.TEMPBL					// [3]		set source pointer lo-byte

			// copy work buffer to text buffer line
			ldy #f40_runtime_constants.SCREEN_COLUMNS		// [2]		set byte copy count
loop:		lda (f40_runtime_memory.TEMPBL),y				// [5]		get byte in work buffer
			sta (f40_runtime_memory.TEMPAL),y				// [6]		set byte from text buffer
			dey												// [2]		decrement count
			bpl loop										// [3/2]	loop until done
			inx												// [2]		increment line index
			ldy f40_runtime_memory.LINECONT,x				// [4]		get continuation byte for this line
			bne	setline 									// [3/2]	loop until all lines copied
			rts												// [6]
}
