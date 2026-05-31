// FAST-40 Custom SYS interceptor
// Copyright (C) 2026 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_sys_trap

// SYS trap to accept 1-4 additional 1-byte parameters
interceptor:
.pc = * "interceptor"
{
			ldy #1											// [2]		set CHRGET command offset
			lda (vic20.os_zpvars.EXECPTRL),y       			// [6]		get byte from CHRGET execution pointer
			cmp #vic20.tokens.SYS                  			// [2]		check if SYS token
			beq getparms									// [2/3]	get additional parameters
			jmp vic20.basic.BASICGET 						// [3]		not SYS so jump back to BASIC decode

getparms:	jsr vic20.os_zpvars.CHRGET  		          	// [6]		advance to SYS token
			jsr vic20.os_zpvars.CHRGET  		          	// [6]		advance to SYS address operand
			jsr vic20.basic.FRMNUM              		  	// [6]		get SYS address into FAC1
			jsr vic20.basic.GETADR							// [6]		convert address to integer

			ldy #0											// [2]		set CHRGET command offset
			lda (vic20.os_zpvars.EXECPTRL),y 				// [5]		get byte from CHRGET execution pointer
			cmp #$2c                               			// [2]		check for comma
			bne done  	                     			    // [3/2]	no comma so use existing CPUAREG
			jsr vic20.basic.GETBYTE                			// [6]		get second operand
			stx vic20.os_vars.CPUAREG             			// [4]		stash in standard .A parameter

			ldy #0											// [2]		set CHRGET command offset
			lda (vic20.os_zpvars.EXECPTRL),y 				// [5]		get byte from CHRGET execution pointer
			cmp #$2c                               			// [2]		check for comma
			bne done 	                      			    // [3/2]	no comma so use existing CPUXREG
			jsr vic20.basic.GETBYTE                			// [6]		get third operand
			stx vic20.os_vars.CPUXREG             			// [4]		stash in standard .X parameter

			ldy #0											// [2]		set CHRGET command offset
			lda (vic20.os_zpvars.EXECPTRL),y 				// [5]		get byte from CHRGET execution pointer
			cmp #$2c                               			// [2]		check for comma
			bne done 	                      			    // [3/2]	no comma so use existing CPUYREG
			jsr vic20.basic.GETBYTE                			// [6]		get fourth operand
			stx vic20.os_vars.CPUYREG             			// [4]		stash in standard .Y parameter

			ldy #0											// [2]		set CHRGET command offset
			lda (vic20.os_zpvars.EXECPTRL),y 				// [5]		get byte from CHRGET execution pointer
			cmp #$2c                               			// [2]		check for comma
			bne done 	                      			    // [3/2]	no comma so use existing SYSPARM
			jsr vic20.basic.GETBYTE                			// [6]		get fifth operand
			stx f40_runtime_memory.SYSPARM        			// [3]		stash in SYS 4th parameter byte

done:		lda #>(vic20.basic.NEWSTT-1)					// [2]		get BASIC return address hi-byte
			pha												// [3]		push to Stack
			lda #<(vic20.basic.NEWSTT-1)					// [2]		get BASIC return address lo-byte
			pha												// [3]		push to Stack
			jmp vic20.basic.SYS2							// [3]		jump into standard SYS handler
}


// SYS handler for vector reload
vector_reload:
.pc = * "vector_reload"
{
			lda vic20.os_vars.CPUAREG 						// [4]		get SYS parameter
			cmp #$ff										// [2]		check if we got the vector key
			bne scram										// [3/2]	scram if not
vecreload:	jmp f40_character_input.reload_vectors			// [3]		reload VIC vectors
}


// SYS handler for SHIFT/RUNSTOP write-protect flag
// => CPUAREG  Enable/disable
write_protect:
.pc = * "write_protect"
{
			lda f40_runtime_memory.MEMBITS			// [3]		get bitmap
			ldx vic20.os_vars.CPUAREG 						// [4]		get SYS parameter
			bne enable 										// [2/3]	any non-zero value means enable the flag
			and #%11011111									// [2]		clear write-protect b5
			bne update 										// [3/3]	bitmap is always non-zero
enable:		ora #%00100000									// [2]		set write-protect b5
update:		sta f40_runtime_memory.MEMBITS			// [3]		update bitmap for new b5 setting
@scram:		rts												// [6]
}


// SYS handler for pixel plot/unplot
// => CPUAREG  Pixel X (0-159)
// => CPUXREG  Pixel Y (0-191)
// => CPUYREG  Colour (0-7, $FF = unplot)
plot_pixel:
.pc = * "plot_pixel"
{
			lda vic20.os_vars.CPUXREG						// [4]		get Y-coordinate
			cmp #192										// [2]		check Y max+1 (0-191 valid)
			bcs bad											// [2/3]	error if out of range
			lax vic20.os_vars.CPUAREG						// [4]		get X-coordinate to .A and .X
			cmp #160										// [2]		check X max+1 (0-159 valid)
			bcs bad											// [2/3]	in range, continue
			lsr												// [2]		divide by 8 for matrix column
			lsr												// [2]
			lsr												// [2]
			sta f40_runtime_memory.TEMPBH					// [3]		save matrix column
			txa												// [2]		get X-coordinate back
			and #7											// [2]		mask pixel column within cell
			tay												// [2]		set mask lookup index
			lda f40_static_data.PLOTMASK,y					// [3]		get bitmap mask
			sta f40_runtime_memory.TEMPBL					// [3]		stash bitmap mask

			lda vic20.os_vars.CPUXREG						// [4]		get Y-coordinate
			tax												// [2]		save Y for within-character offset
			lsr												// [2]		divide by 16 for matrix row
			lsr												// [2]
			lsr												// [2]
			lsr												// [2]
			tay												// [2]		set matrix row index
			clc												// [2]		clear Carry for addition
			lda f40_static_data.CROWOFFS,y					// [4]		get character matrix row offset
			adc f40_runtime_memory.TEMPBH					// [3]		add matrix column
			sta f40_runtime_memory.TEMPBH					// [3]		save matrix index (reuse TEMPBH)
			tay												// [2]		set character matrix index
			txa												// [2]		get Y-coordinate (.X still holds Y here)
			and #$0F										// [2]		mask for row within character cell (0-15)
			sta f40_runtime_memory.TEMPAL					// [3]		save Y-within-character
			lda f40_runtime_memory.Character_Matrix,y		// [4]		get matrix character at pixel location
			lsr												// [2]		shift hi-nybble down
			lsr												// [2]
			lsr												// [2]
			lsr												// [2]
			tax												// [2]		set hi-byte table index
			lda f40_static_data.BITADDRH-1,x				// [3]		get bitmap address hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		set bitmap address hi-byte
			ldy f40_runtime_memory.TEMPBH					// [3]		reload matrix index
			lda f40_runtime_memory.Character_Matrix,y		// [4]		re-read matrix character for lo-byte index
			and #%00001111									// [2]		mask low nybble for bitmap lo-byte index
			tay												// [2]		set lo-byte table index
			lda f40_static_data.BITADDRL,y					// [3]		get bitmap address lo-byte
			clc												// [2]		clear Carry (corrupted by preceding LSRs)
			adc f40_runtime_memory.TEMPAL					// [3]		add Y-within-character (max $F0+$0F=$FF, no carry)
			sta f40_runtime_memory.TEMPAL					// [3]		set bitmap address lo-byte

			ldy #0											// [2]		set bitmap offset
			bit vic20.os_vars.CPUYREG						// [4]		test colour parameter b7 ($FF = unplot)
			bmi unplot										// [2/3]	do unplot if required

			lda (f40_runtime_memory.TEMPAL),y				// [5]		get bitmap byte
			ora f40_runtime_memory.TEMPBL					// [3]		set pixel bit
			sta (f40_runtime_memory.TEMPAL),y				// [6]		save merged bitmap byte
			ldy f40_runtime_memory.TEMPBH					// [3]		get matrix index (same index for colour matrix)
			lda vic20.os_vars.CPUYREG						// [4]		get colour parameter
			sta vic20.colour_ram.COLOUR1,y					// [5]		set colour matrix byte
			rts												// [6]

unplot:		lda f40_runtime_memory.TEMPBL					// [3]		get bitmap mask
			eor #$FF										// [2]		invert mask
			and (f40_runtime_memory.TEMPAL),y				// [5]		merge existing bitmap byte
			sta (f40_runtime_memory.TEMPAL),y				// [6]		save merged bitmap byte
			rts												// [6]
}


// SYS handler for character poke
// => CPUAREG  Column X (0-39)
// => CPUXREG  Row Y (0-23)
// => CPUYREG  Screen code
// => SYSPARM  Colour
poke_character:
.pc = * "poke_character"
{
			lda vic20.os_vars.CPUAREG						// [4]		get column parameter
			cmp #40											// [2]		check X max+1 (0-39 valid)
			bcs bad											// [2/3]	error if out of range
			ldx vic20.os_vars.CPUXREG						// [4]		get row parameter
			cpx #24											// [2]		check Y max+1 (0-23 valid)
			bcc ok											// [2/3]	in range, continue
@bad:		jmp vic20.basic.ILLEGAL							// [3]		issue illegal quantity error
ok:			ldy f40_runtime_memory.TXTBUFSQ,x				// [4]		get text buffer sequence index for row
			lda f40_static_data.TROWADDR.lo,y				// [4]		get text buffer address lo-byte
			sta f40_runtime_memory.TEMPAL					// [3]		set text buffer pointer lo-byte
			lda f40_static_data.TROWADDR.hi,y				// [4]		get text buffer address hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		set text buffer pointer hi-byte
			ldy vic20.os_vars.CPUAREG						// [4]		get column parameter
			lda vic20.os_vars.CPUYREG						// [4]		get screen code
			sta (f40_runtime_memory.TEMPAL),y				// [6]		write screen code to text buffer
			txa												// [2]		get row back
			lsr												// [2]		divide by two for colour matrix row
			tay												// [2]		set CROWOFFS index
			lda f40_static_data.CROWOFFS,y					// [4]		get colour matrix row offset
			sta f40_runtime_memory.TEMPAL					// [3]		set colour pointer lo-byte
			lda #>vic20.colour_ram.COLOUR1					// [2]		colour RAM hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		set colour pointer hi-byte
			lda vic20.os_vars.CPUAREG						// [4]		get column parameter
			lsr												// [2]		divide by two for colour matrix column
			tay												// [2]		set colour column index
			lda f40_runtime_memory.SYSPARM					// [3]		get colour parameter
			and #7											// [2]		mask to hires colour range (bit 3 enables multicolour)
			sta (f40_runtime_memory.TEMPAL),y				// [6]		write colour to colour RAM
			stx f40_runtime_memory.DRAWROWS					// [3]		set redraw start row
			jmp f40_helper_routines.redraw_line_range		// [3]		redraw row (X = row = end line)
}
