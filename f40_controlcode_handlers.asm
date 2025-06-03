// FAST-40 control code output handlers
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_controlcode_handlers
.align 256		// Page aligned for table addressing

dispatch_page:
.pc = * "dispatch_page"
.byte f40_runtime_constants.SCREEN_ROWS-1					// Push first routine on the page up a byte so JSR/RTS dispatch doesn't underflow

// Handle control code $94 (INSERT)
insert:
.pc = * "insert"
{
			jmp f40_helper_routines.insert_character		// [3]		insert character on current line
}


// Handle control code $14 (DELETE)
delete:
.pc = * "delete"
{
			jmp f40_helper_routines.delete_character		// [3]		delete character on current line
}


// Handle control code $93 (CLR)
clear_screen:
.pc = * "clear_screen"
{
			jsr f40_helper_routines.initialise_screen		// [6]		re-initialise all screen tables
// Fall-through into cursor_home
}


// Handle control code $13 (HOME)
// => A		Must be zero
cursor_home:
.pc = * "cursor_home"
{
			sta vic20.os_zpvars.CRSRLPOS					// [3]		reset cursor position on logical line (0-87)
			sta vic20.os_zpvars.CRSRROW						// [3]		reset cursor row
			beq reset_text_pointer							// [3/3]	reset line pointers
}


// Handle control code $0D (CARRIAGE RETURN) and $8D (SHIFT-CARRIAGE RETURN)
// => A		Must be zero
// => Z		Must be set
carriage_return:
.pc = * "carriage_return"
{
			sta vic20.os_zpvars.INSRTCNT					// [3]		reset pending INSERT count
			sta vic20.os_zpvars.RVSFLAG						// [3]		clear reverse flag
			sta vic20.os_zpvars.QUOTMODE					// [3]		clear cursor quote flag
			sta vic20.os_zpvars.CRSRLPOS					// [3]		reset cursor position on logical line (0-87)
			beq cursor_down									// [3/3]	move cursor down a line
}


// Handle control code $9D (CURSOR LEFT)
cursor_left:
.pc = * "cursor_left"
{
			dec vic20.os_zpvars.CRSRLPOS					// [5]		decrement cursor column (0-39)
			bpl reset_colour_pointer						// [3/2]	reset colour pointer if no underrun (column < 0)
			ldy vic20.os_zpvars.CRSRROW						// [3]		get cursor row (0-23)
			beq resetpos									// [2/3]	skip cursor-up if already on row 0
			ldy #f40_runtime_constants.SCREEN_COLUMNS		// [2]		last column on line
resetpos:	sty vic20.os_zpvars.CRSRLPOS					// [3]		reset cursor column
// Fall-through into cursor_up
}


// Handle control code $91 (CURSOR UP)
// => A		Must be zero
cursor_up:
.pc = * "cursor_up"
{
			dec vic20.os_zpvars.CRSRROW						// [5]		decrement cursor row
			bpl reset_text_pointer							// [3/2]	reset line pointers if no underrun (line >= 0)
			sta vic20.os_zpvars.CRSRROW						// [3]		reset cursor row to zero
			bmi reset_text_pointer							// [3/3]	reset line pointers after correction
}


// Handle control code $1D (CURSOR RIGHT)
cursor_right:
.pc = * "cursor_right"
{
			sec												// [2]		set Carry for subtraction
			lda #40											// [2]		one column beyond end of line
			isb vic20.os_zpvars.CRSRLPOS					// [5]		increment cursor column
			bne reset_colour_pointer						// [3/2]	reset colour pointer if no overrun (column > 39)
			sta vic20.os_zpvars.CRSRLPOS					// [3]		reset cursor column to start of line
// Fall-through into cursor_down
}


// Handle control code $11 (CURSOR DOWN)
cursor_down:
.pc = * "cursor_down"
{
			sec												// [2]		set Carry for subtraction
			lda #f40_runtime_constants.SCREEN_ROWS+1		// [2]		one line beyond end of screen
			isb vic20.os_zpvars.CRSRROW						// [5]		increment cursor line in .A
			bne reset_text_pointer							// [3/2]	reset line pointers if not beyond end of screen
			jsr f40_helper_routines.scroll_lines_up			// [6]		scroll all lines up when beyond last line
			lda #22											// [2]	 	cursor line after scroll
			sta vic20.os_zpvars.CRSRROW						// [3]		set cursor line
// Fall-through into reset_text_pointer
}


// Reset text buffer pointer for new line
reset_text_pointer:
.pc = * "reset_text_pointer"
{
			ldx vic20.os_zpvars.CRSRROW						// [3]		get cursor row
			jsr f40_helper_routines.set_line_pointer 		// [6]		set line buffer pointer to current line
// Fall-through into reset_colour_pointer
}


// Reset colour pointer for new line
reset_colour_pointer:
.pc = * "reset_colour_pointer"
{
			lda vic20.os_zpvars.CRSRROW						// [3]		get cursor row
			lsr												// [2]		divide row by two for colour offset
			tax												// [2]		copy colour offset to .X
			lda f40_static_data.CROWOFFS,x					// [4]		get colour matrix row offset
			sta vic20.os_zpvars.COLRPTRL					// [3]		set colour line pointer lo-byte
			bit f40_runtime_memory.CRSRCOLF					// [3]		get cursor colour flag
			bpl colexit										// [2/3]	skip colour read if clear
			ldx #0											// [2]		read colour byte under cursor
// Fall-through into set_colour_byte
}


// Handle colour control codes $05,$1C,$1E,$1F,$90,$9C,$9E,$9F (WHITE,RED,GREEN,BLUE,BLACK,PURPLE,YELLOW,CYAN)
// => X		Read colour from RAM when zero; otherwise set colour as given
set_colour_byte:
.pc = * "set_colour_byte"
{
			lda vic20.os_zpvars.CRSRLPOS					// [3]		get cursor column
			lsr												// [2]		divide by 2 for colour matrix
			tay												// [2]		set index for colour byte update
			txa	 											// [2]		move control code in .X to .A
			beq readcol										// [3/2]	read colour when .X=0
			jsr vic20.kernal.SETCOLCD						// [6]		set colour screen code
			txa												// [2]		move screen colour code to .A
			sta (vic20.os_zpvars.COLRPTRL),y				// [4]		set colour RAM byte
@colexit:	rts												// [6]
readcol:	lda (vic20.os_zpvars.COLRPTRL),y				// [5]		read colour RAM byte
			sta vic20.os_vars.CURRCOLR						// [4]		set cursor colour
			rts												// [6]
}


// Handle control code $0E/$8E (SWITCH CASE)
// => X		Control code passed from controlcode_dispatch
switch_case:
.pc = * "switch_case"
{
			lda vic20.basic.OROP+19,x						// [4]		get case value for switch ($00=upper-case, $08=lower-case)
			jmp f40_helper_routines.case_redraw				// [3]		do screen redraw for case switch
}


// Handle control codes $08/$09 (ENABLE/DISABLE SHIFT-C=)
// => X		Control code passed from controlcode_dispatch
shift_cbm:
.pc = * "shift_cbm"
{
			txa												// [2]		move control code to .A
			ror												// [2]		rotate b0 to Carry
			ror vic20.os_vars.SHFTMODE						// [5]		rotate Carry to shift mode lock b7
			rts												// [6]
}	


// Handle control codes $12/$92 (RVS ON/OFF)
// => X		Control code passed from controlcode_dispatch
rvs_mode:
.pc = * "rvs_mode"
{
			txa												// [2]		move control code to .A
			and #%10000000									// [2]		mask for b7
			eor #%10000000									// [2]		invert it
			sta vic20.os_zpvars.RVSFLAG						// [3]		set screen reverse flag
// Fall-through into inactive_code
}


// Handle control codes $03 (RUN/STOP) and $0A (LINE FEED)
// Note: These codes are not supported by the screen editor and therefore do nothing
inactive_code:
.pc = * "inactive_code"
{
			rts												// [6]
}
