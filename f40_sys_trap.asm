// FAST-40 Custom SYS interceptor
// Copyright (C) 2026 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_sys_trap

// SYS trap to accept 1-3 additional 1-byte parameters
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
vecreload:	jmp f40_helper_routines.reload_vectors			// [3]		reload VIC vectors
}


// SYS handler for SHIFT/RUNSTOP write-protect flag
// => CPUAREG  Enable/disable
write_protect:
.pc = * "write_protect"
{
			lda f40_runtime_memory.Memory_Bitmap 			// [4]		get bitmap
			ldx vic20.os_vars.CPUAREG 						// [4]		get SYS parameter
			bne enable 										// [2/3]	any non-zero value means enable the flag
			and #%11011111									// [2]		clear write-protect b5
			bne update 										// [3/3]	bitmap is always non-zero
enable:		ora #%00100000									// [2]		set write-protect b5
update:		sta f40_runtime_memory.Memory_Bitmap 			// [4]		update bitmap for new b5 setting
@scram:		rts												// [6]
}


// SYS handler for pixel plot/unplot
// => CPUAREG  Pixel X (0-159)
// => CPUXREG  Pixel Y (0-191)
// => CPUYREG  Colour (0-7, $FF = unplot)
plot_pixel:
.pc = * "plot_pixel"
{
			lax vic20.os_vars.CPUAREG						// [4]		get X-coordinate to .A and .X
			lsr												// [2]		divide by 8 for matrix column
			lsr												// [2]
			lsr												// [2]
			sta f40_runtime_memory.TEMPBH					// [3]		save matrix column
			txa												// [2]		get X-coordinate back
			and #7											// [2]		mask pixel column within cell
			tay												// [2]		set mask lookup index
			lda f40_static_data.PLOTMASK,y					// [4]		get bitmap mask
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
			lda f40_runtime_memory.Character_Matrix,y		// [4]	get matrix character at pixel location
			lsr												// [2]		shift hi-nybble down
			lsr												// [2]
			lsr												// [2]
			lsr												// [2]
			tax												// [2]		set hi-byte table index
			lda f40_static_data.BITADDRH-1,x				// [4]		get bitmap address hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		set bitmap address hi-byte
			ldy f40_runtime_memory.TEMPBH					// [3]		reload matrix index
			lda f40_runtime_memory.Character_Matrix,y		// [4]	re-read matrix character for lo-byte index
			and #%00001111									// [2]		mask low nybble for bitmap lo-byte index
			tay												// [2]		set lo-byte table index
			lda f40_static_data.BITADDRL,y					// [4]		get bitmap address lo-byte
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
