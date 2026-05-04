// FAST-40 Custom SYS trap
// Copyright (C) 2026 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_sys_trap

// SYS trap to accept 1-3 additional 1-byte parameters
sys_trap:
.pc = * "sys_trap"
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


// SYS handler for reset modes
// => CPUAREG  Reset mode
sys_reset:
.pc = * "sys_reset"
{

			// check syntax
			tay												// [2]		copy to .A to set flags
			beq coldstart									// [2/3]	no parameter means restart FAST-40
			cmp #$ff										// [2]		check if first character is vector
			beq vecreload									// [2/3]	do vector reload if so
			ldx #$0b										// [2]		set error code (syntax)
			cmp #$3a										// [2]		check if first character is non-numeric
			bcs error										// [2/3]	scram if not a number

			// handle parameter
			jsr vic20.basic.CHECKNUM 						// [6]		go look for numeric value in command string
			txa												// [2]		copy parameter to .A
			pha												// [3]		stash parameter to Stack
			cmp #0											// [2]		check parameter
			beq chkmem										// [2/3]	do the unexpanded reset
			cmp #3											// [2]		check parameter
			beq chkmem										// [2/3]	do the 3K reset
			cmp #8											// [2]		check parameter
			beq chkmem										// [2/3]	do the 8K+ reset

			// handle errors
			ldx #$0e										// [2]		set error code (illegal quantity)
error:		jmp (vic20.os_vars.ERRMSG)						// [5]		issue error and do BASIC warm-start
coldstart:	jmp vic20.kernal.RESET							// [3]		do cold-start for FAST-40 startup
vecreload:	jsr vic20.os_zpvars.CHRGET						// [6]		call CHRGET to get a byte
			jmp f40_helper_routines.reload_vectors			// [3]		reload VIC vectors
nomatch:	jmp vic20.basic.BASICGET 						// [3]		jump to stock BASIC logic to continue decode

			// do reset
chkmem:		jsr vic20_memory_test.memory_test 				// [6]		clear and test memory (except Stack)	
			tay	 											// [2]		stash memory expansion bitmap in .Y
			ldx #$10										// [2]		unexpanded memory start
			pla 											// [4]		get reset parameter
			beq config0										// [3/2]	do unexpanded reset
			cmp #8											// [2]		check if 8K+ requested
			beq config8										// [3/2]	do 8K+ reset

			// unexpanded and 3K reset
			ldx #$04										// [2]		3K memory start
config0:	stx vic20.os_vars.BASICH						// [4]		set Start-of-BASIC pointer hi-byte
			ldx #$1e										// [2]		unexpanded/3K screen start
			stx vic20.os_vars.SCRNMEMP						// [4]		set screen memory page
			bne reset										// [3/3]	continue with reset processing

			// check if RAM in BLK1 for 8K reset
config8:	tya 											// [2]		get memory expansion bitmap	
			lsr												// [2]		shift BLK0 bit to Carry
			lsr												// [2]		shift BLK1 bit to Carry
			bcc config0										// [2/3]	do unexpanded reset if nothing in BLK1

			// 8K+ reset
			stx vic20.os_vars.SCRNMEMP						// [4]		set screen memory page (.x = #$10)
			ldx #$12										// [2]		8K+ memory start
			stx vic20.os_vars.BASICH						// [4]		set Start-of-BASIC pointer hi-byte
			ldx #$40										// [2]		top of RAM for BLK1
			lsr												// [2]		shift BLK2 bit to Carry
			bcc reset										// [2/3]	skip BLK3 check if BLK2 is empty
			ldx #$60										// [2]		top of RAM for BLK2
			lsr												// [2]		shift BLK3 bit to Carry
			bcc reset										// [2/3]	skip if BLK3 is empty
			ldx #$80										// [2]		top of RAM for BLK3

			// do reset processing (can't call stock reset as it would blow our wedge vector away)
reset:		stx vic20.os_vars.OSMEMTPH						// [4]		set top-of-memory pointer hi-byte
			jsr vic20.kernal.RESKVEC						// [6]		reset KERNAL I/O vectors
			jsr vic20.kernal.INITIO							// [6]		reset VIA interrupts
			jsr vic20.kernal.INITSCRN						// [6]		reset VIC configuration for 22-column screen
			jsr vic20.basic.INITBASV						// [6]		initialise BASIC vectors
			jsr f40_helper_routines.reset_wedge				// [6]		reset BASIC wedge
			jmp vic20.basic.INIT2 							// [3]		jump to BASIC after vector init
}


// SYS handler for SHIFT/RUNSTOP write-protect flag
// => CPUAREG  Enable/disable
sys_write_protect:
.pc = * "sys_write_protect"
{
			lda f40_runtime_memory.Memory_Bitmap 			// [4]		get bitmap
			ldx vic20.os_vars.CPUAREG 						// [4]		get SYS parameter
			bne enable 										// [2/3]	any non-zero value means enable the flag
			and #%11011111									// [2]		clear write-protect b5
			bne update 										// [3/3]	bitmap is always non-zero
enable:		ora #%00100000									// [2]		set write-protect b5
update:		sta f40_runtime_memory.Memory_Bitmap 			// [4]		update bitmap for new b5 setting
			rts												// [6]
}


// SYS handler for pixel plot/unplot
// => CPUAREG  Pixel X (0-159)
// => CPUXREG  Pixel Y (0-191)
// => CPUYREG  Colour (0-7, $FF = unplot)
plot_pixel:
.pc = * "plot_pixel"
{
			lda vic20.os_vars.CPUAREG				// [4]		X pixel
			lsr										// [2]
			lsr										// [2]
			lsr										// [2]		char_col (0-19)
			tax										// [2]
			stx f40_runtime_memory.TEMPBH			// [3]		save char_col
			clc										// [2]
			lda f40_static_data.PLOTCOLL,x			// [4]		column bitmap lo base
			adc vic20.os_vars.CPUXREG				// [4]		+ Y pixel
			sta f40_runtime_memory.TEMPAL			// [3]
			lda f40_static_data.PLOTCOLH,x			// [4]		column bitmap hi base
			adc #0									// [2]
			sta f40_runtime_memory.TEMPAH			// [3]
			lda vic20.os_vars.CPUAREG				// [4]		X pixel
			and #7									// [2]		pixel column within cell (0-7)
			tay										// [2]
			lda f40_static_data.PLOTMASK,y			// [4]		bit mask
			sta f40_runtime_memory.TEMPBL			// [3]
			ldy #0									// [2]
			bit vic20.os_vars.CPUYREG				// [4]		test colour b7 ($FF = unplot)
			bmi unplot								// [2/3]

			lda (f40_runtime_memory.TEMPAL),y		// [5]		get bitmap byte
			ora f40_runtime_memory.TEMPBL			// [3]		set pixel bit
			sta (f40_runtime_memory.TEMPAL),y		// [6]
			lda vic20.os_vars.CPUXREG				// [4]		Y pixel
			lsr										// [2]
			lsr										// [2]
			lsr										// [2]
			lsr										// [2]		char_row (0-11)
			tay										// [2]
			lda f40_static_data.CROWOFFS,y			// [4]		char_row x 20
			clc										// [2]
			adc f40_runtime_memory.TEMPBH			// [3]		+ char_col
			tay										// [2]
			lda vic20.os_vars.CPUYREG				// [4]		colour (0-7)
			sta vic20.colour_ram.COLOUR1,y			// [5]
			rts										// [6]

unplot:		lda f40_runtime_memory.TEMPBL			// [3]		bit mask
			eor #$FF								// [2]		invert -> bit clear mask
			and (f40_runtime_memory.TEMPAL),y		// [5]
			sta (f40_runtime_memory.TEMPAL),y		// [6]
			rts										// [6]
}
