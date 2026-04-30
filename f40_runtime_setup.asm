// FAST-40 memory / system setup
// Copyright (C) 2026 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_runtime_setup

// Memory / system setup from cold
// => A		RAM population bits
cold_start:
.pc = * "cold_start"
{
			lsr												// [2]		shift 3K BLK0 bit to Carry
			bcs setup										// [2/3]	3K BLK0 is populated
			jmp vic20.kernal.RESET2							// [3]		FAST-40 can't run without at least 3K in BLK0

			// set BASIC start
setup:		ldx #>vic20.ram.RAMBLK0							// [2]		get BASIC start address for 3K
			stx vic20.os_vars.BASICH						// [4]		set Start-of-BASIC pointer hi-byte
			ldx #>f40_runtime_memory.Text_Buffer			// [2]		get text buffer address hi-byte
			ldy #<f40_runtime_memory.Text_Buffer			// [2]		get text buffer address lo-byte

			// check which 8K bits are set (if any) and configure as appropriate
			lsr												// [2]		shift BLK1 bit to Carry
			bcc setmem										// [2/3]	skip 8K if BLK1 not populated
			ldy #0											// [2]
			ldx #>vic20.ram.RAMBLK1							// [2]		get BASIC start address for 8K
			stx vic20.os_vars.BASICH						// [4]		set Start-of-BASIC pointer hi-byte
			ldx #>vic20.ram.RAMBLK2							// [2]		top of RAM for BLK1
			lsr												// [2]		shift BLK2 bit to Carry
			bcc setmem										// [2/3]	skip BLK3 check if BLK2 is empty
			ldx #>vic20.ram.RAMBLK3							// [2]		top of RAM for BLK2
			lsr												// [2]		shift BLK3 bit to Carry
			bcc setmem										// [2/3]	skip if BLK3 is empty
			ldx #>vic20.character_generator.UCROM			// [2]		top of RAM for BLK3

			// set top-of-memory and screen page
setmem:		stx vic20.os_vars.OSMEMTPH						// [4]		set top-of-memory pointer hi-byte
			sty vic20.os_vars.OSMEMTPL						// [4]		set top-of-memory pointer lo-byte
			ldx #>vic20.ram.RAMMAIN							// [2]		get character matrix address hi-byte
			stx vic20.os_vars.SCRNMEMP						// [4]		set screen memory page

			// initialise BASIC
			jsr vic20.basic.INITBASV						// [6]		initialise BASIC vectors
			jsr vic20.basic.INITZP							// [6]		initialise BASIC zero-page data

			// check for PAL or NTSC
			ldy #0											// [2]		initialise bitmerge value
			lda #1											// [2]		raster line #2 (register counts in twos)
wait2:		cmp vic20.vic.VCRASTER							// [4]		check for line
			bne wait2										// [3/2]	loop until we hit it
wait268:	lda vic20.vic.VCRASTER							// [4]		get current raster line
			beq romcheck									// [3/2]	video mode is NTSC if we find line 0 before line 268
			cmp #134										// [2]		look for line 268 for PAL
			bne wait268										// [3/2]	loop until we find 0 or 268
			ldy #%10000000									// [2]		set PAL merge bit

			// look for JiffyDOS
romcheck:	ldx #4											// [2]		JiffyDOS identifier length (0-based)
chkbyte:	lda f40_static_data.JIFFYID,x					// [4]		get signature test byte
			cmp vic20.basic.BASICV2+1,x						// [4]		compare with power-up identifier in ROM
			bne notjiffy									// [3/2]	exit as soon as we get a mismatch
			dex												// [2]		decrement byte index
			bpl chkbyte										// [3/2]	loop until done
			tya												// [2]		get bitmerge value
			ora #%01000000									// [2]		set JiffyDOS bit
			tay	 											// [2]		stash merged bit
notjiffy:	tya	 											// [2]		get JiffyDOS bit
			ora f40_runtime_memory.Memory_Bitmap 			// [4]		merge both with memory bitmap
			sta f40_runtime_memory.Memory_Bitmap 			// [4]		stash with merged bits

			jsr warm_start									// [6]		do FAST-40 runtime setup

			// display cold-start messages
			lda #<f40_static_data.IDMSG1					// [2]		pointer to FAST-40 message string lo-byte
			ldy #>f40_static_data.IDMSG1					// [2]		pointer to FAST-40 message string hi-byte
			jsr vic20.basic.STROUT							// [6]		display string
			lda #<f40_static_data.IDMSG2					// [2]		pointer to FAST-40 message string lo-byte
			ldy #>f40_static_data.IDMSG2					// [2]		pointer to FAST-40 message string hi-byte

			bit f40_runtime_memory.Memory_Bitmap 			// [4]		get b6 for JiffyDOS
			bvc f40msg										// [3/2]	skip JiffyDOS banner if not present

			lda #<vic20.basic.BASICV2						// [2]		pointer to JiffyDOS message string lo-byte
			ldy #>vic20.basic.BASICV2						// [2]		pointer to JiffyDOS message string hi-byte
			jsr vic20.basic.STROUT							// [6]		display string
			lda #<f40_static_data.IDMSG3					// [2]		pointer to FAST-40 message string lo-byte
			ldy #>f40_static_data.IDMSG3					// [2]		pointer to FAST-40 message string hi-byte
f40msg:		jsr vic20.basic.STROUT							// [6]		display string
			jsr vic20.basic.INITMEM2						// [6]		output 'XXXX BYTES FREE' and reset BASIC pointers
			ldx #$fb										// [2]
			txs												// [2]		set .SP for BASIC
			cli												// [2]		enable interrupts
			jmp vic20.basic.READY							// [3]		jump to BASIC restart
}


// Memory / system setup from cold or RUNSTOP/RESTORE
warm_start:
.pc = * "warm_start"
{
			lda #<f40_runtime_memory.MERGBITL				// [2]		get BLK0 left-merge routine target address lo-byte
			sta f40_runtime_memory.TEMPAL					// [3]		stash in indirect pointer lo-byte
			lda #>f40_runtime_memory.MERGBITL				// [2]		get BLK0 left-merge routine target address hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		stash in indirect pointer hi-byte
			ldx #$0F										// [2]		left-variant mask
			jsr unroll_merge								// [6]		do copy/unroll expansion of left merge routine

			lda #<f40_runtime_memory.MERGBITR				// [2]		get BLK0 right-merge routine target address lo-byte
			sta f40_runtime_memory.TEMPAL					// [3]		stash in indirect pointer lo-byte
			lda #>f40_runtime_memory.MERGBITR				// [2]		get BLK0 right-merge routine target address hi-byte
			sta f40_runtime_memory.TEMPAH					// [3]		stash in indirect pointer hi-byte
			ldx #$F0										// [2]		right-variant mask
			jsr unroll_merge								// [6]		do copy/unroll expansion of right merge routine

			// initialise 40x24 screen character matrix
			ldy #240										// [2]		initialise table index
copychar:	lda f40_static_data.MATDATA-1,y					// [4]		get matrix character
			sta f40_runtime_memory.Character_Matrix-1,y		// [5]		store character in screen matrix
			dey												// [2]		decrement for next character
			bne copychar									// [3/2]	loop until chars 16-255 copied

			// intialise keyboard and display settings
			dey												// [2]		.Y = #$FF
			sty vic20.os_vars.REPMODE 						// [3]		set repeat on all keys
			ldx #10											// [2]
			stx vic20.os_vars.KEYBUFSZ						// [4]		set keyboard buffer length
			stx vic20.os_vars.REPSPEED						// [4]		set keyboard repeat initial delay
			ldx #vic20.devices.SCREEN						// [2]
			stx vic20.os_zpvars.DEVOUT						// [3]		set output device to screen
			ldx #>f40_static_data.MATDATA					// [2]		get matrix row address table hi-byte
			stx f40_runtime_memory.MATROWH					// [3]		set matrix row pointer hi-byte
			ldx #>vic20.colour_ram.COLOUR1					// [2]		colour RAM pointer hi-byte
			stx vic20.os_zpvars.COLRPTRH					// [3]		set colour line pointer hi-byte

			// configure hardware and vectors
			jsr vic20.kernal.INITIO							// [6]		initialise VIA interrupts
			jsr f40_helper_routines.reset_vectors			// [6]		reset KERNAL and FAST-40 vectors

			// initialise the 40x24 display
			jsr f40_helper_routines.configure_vic			// [6]		set 40x24 mode
			lda #vic20.screencodes.CLRSCRN					// [2]		clear/home
			jsr f40_character_output.character_output		// [6]		display character
			rts												// [6]
}


// Copy and unroll the bitmap glyph merge routine
unroll_merge:
.pc = * "unroll_merge"
{
			stx f40_runtime_memory.REGXSAVE					// [4]		save mask passed in X ($0F=left, $F0=right)
			ldx #7											// [2]		set iteration counter
nxtblock:	ldy #10											// [2]		set copy loop counter
copyloop:	lda f40_static_data.MERGCODE,y					// [4]		get merge routine template byte
			sta (f40_runtime_memory.TEMPAL),y				// [6]		stash in unroll area
			dey												// [2]		decrement for next byte
			bpl copyloop									// [3/2]	loop until done

			ldy #f40_static_data.MERGCODE_MASK_OFF			// [2]		get mask byte offset
			lda f40_runtime_memory.REGXSAVE					// [3]		get variant mask ($0F left / $F0 right)
			sta (f40_runtime_memory.TEMPAL),y				// [6]		write mask (no-op for left: overwrites $0F with $0F)

advance:	clc												// [2]		clear Carry for addition
			lda f40_runtime_memory.TEMPAL					// [3]		get target address lo-byte
			adc #10											// [2]		calculate next block address
			sta f40_runtime_memory.TEMPAL					// [3]		set target address lo-byte
			dex												// [2]		decrement block iteration counter
			bmi setjump										// [2/3]	finalise merge routine if all done

			inc f40_runtime_memory.TEMPAL					// [5]		skip DEY at end of template block
			bne nxtblock									// [3/3]	loop back for next block

setjump:	ldy #0											// [2]		set target address offset
			lda #JMP_ABS									// [2]		get JMP operand
			sta (f40_runtime_memory.TEMPAL),y				// [6]		patch JMP over last DEY
			iny												// [2]		increment offset
			lda #<f40_character_output.line_continuation	// [2]		get JMP target address lo-byte
			sta (f40_runtime_memory.TEMPAL),y				// [6]		patch JMP operand lo-byte
			iny												// [2]		increment offset
			lda #>f40_character_output.line_continuation	// [2]		get JMP target address hi-byte
			sta (f40_runtime_memory.TEMPAL),y				// [6]		patch JMP operand hi-byte
			rts												// [6]
}
