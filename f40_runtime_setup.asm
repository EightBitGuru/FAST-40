// FAST-40 memory / system setup
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_runtime_setup

// Memory / system setup
// => A		RAM population bits
setup:
.pc = * "runtime_setup"
{
			ldy #<f40_runtime_memory.Text_Buffer			// [2]		get text buffer address lo-byte
			sty f40_runtime_memory.TXTBUFFL					// [3]		set text buffer pointer lo-byte
			ldy #0											// [2]		clear .Y
			lsr												// [2]		shift 3K BLK0 bit to Carry
			bcc chkblk1										// [2/3]	3K BLK0 is empty so check BLK1/2/3
			ldy #>f40_runtime_memory.Text_Buffer			// [2]		BLK0 text buffer address hi-byte

			// check which 8K bits are set
chkblk1:	lsr												// [2]		shift BLK1 bit to Carry
			bcs chkblk2										// [2/3]	nonzero means BLK1 is populated so check BLK2
			jmp vic20.kernal.RESET2							// [3]		FAST-40 can't run without at least 8K in BLK1

			// set memory configuration for BLK1/2/3
chkblk2:	ldx #$40										// [2]		top of RAM for BLK1
			lsr												// [2]		shift BLK2 bit to Carry
			bcc emptyblk									// [2/3]	skip BLK3 check if BLK2 is empty
			ldx #$60										// [2]		top of RAM for BLK2
			lsr												// [2]		shift BLK3 bit to Carry
			bcc emptyblk									// [2/3]	skip if BLK3 is empty
			ldx #$80										// [2]		top of RAM for BLK3

			// configure pointers for 8K/16K/24K
emptyblk:	txa												// [2]		move top of RAM to .A
			cpy #0											// [2]		check if using 3K BLK0
			bne setptrs										// [2/3]	nonzero means we are using it
			ldx #<f40_runtime_memory.Text_Buffer			// [2]		BLK1/2/3 text buffer address lo-byte
			stx vic20.os_vars.OSMEMTPL						// [4]		set top-of-memory pointer lo-byte
			sec												// [2]		not using BLK0 so set Carry for subtraction
			sbc #4											// [2]		subtract for text buffer reservation
			tay												// [2]		stash in .Y for text buffer

			// initialise memory pointers
setptrs:	sta vic20.os_vars.OSMEMTPH						// [4]		set top-of-memory pointer hi-byte
			sty f40_runtime_memory.TXTBUFFH					// [3]		set FAST-40 text buffer pointer hi-byte
			ldy #$10										// [2]		screen start is $1000
			sty vic20.os_vars.SCRNMEMP						// [4]		set screen memory page
			ldy #$20										// [2]		start of memory is $2000
			sty vic20.os_vars.BASICH						// [4]		set Start-of-BASIC pointer hi-byte
			ldx #f40_runtime_constants.SCREEN_ROWS			// [2]		row index
			clc												// [2]		clear Carry for addition

			// copy & compute text row address tables in RAM
copytab:	lda f40_static_data.TROWOFFL,x					// [4]		get text row address lo-byte
			sta f40_runtime_memory.TXTBUFRL,x				// [5]		stash in RAM
			lda f40_static_data.TROWOFFH,x					// [4]		get text row address hi-byte addition
			adc f40_runtime_memory.TXTBUFFH					// [3]		add text buffer base hi-byte
			sta f40_runtime_memory.TXTBUFRH,x				// [5]		stash in RAM
			dex												// [2]
			bpl copytab										// [3/2]	loop until done

			// copy self-modifying bitmap routine to RAM
			ldx #21											// [2]		bytes to copy (zero-based)
copycode:	lda f40_static_data.RAMCODE,x					// [4]		get code byte
			sta f40_runtime_memory.MERGROUT,x				// [5]		stash in RAM
			dex												// [2]
			bpl copycode									// [3/2]	loop until done

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
			jsr vic20.basic.INITV							// [6]		initialise BASIC vectors
			jsr vic20.basic.INITZP							// [6]		initialise BASIC zero-page data
			jsr f40_helper_routines.reset_vectors			// [6]		reset KERNAL and FAST-40 vectors

			// set VIC for PAL or NTSC
			ldy #0											// [2]		initialise bitmerge value
			lda #1											// [2]		raster line #2 (register counts in twos)
wait2:		cmp vic20.vic.VCRASTER							// [4]		check for line
			bne wait2										// [3/2]	loop until we hit it
wait268:	lda vic20.vic.VCRASTER							// [4]		get current raster line
			beq romcheck									// [3/2]	video mode is NTSC if we find line 0 before line 268
			cmp #134										// [2]		look for line 268 for PAL
			bne wait268										// [3/2]	loop until we find 0 or 268
			ldy #%10000000									// [2]		set PAL merge bit

			// Detect JiffyDOS ROM
romcheck:	ldx #7											// [2]		JiffyDOS identifier length
chkbyte:	lda f40_static_data.JIFFYDOS,x					// [4]		get byte from ROM
			cmp vic20.basic.BASICV2+1,x						// [4]		compare with power-up identifier
			bne notjiffy									// [3/2]	exit as soon as we get a mismatch
			dex												// [2]		decrement byte index
			bpl chkbyte										// [3/2]	loop until done
			tya												// [2]		get bitmerge value
			ora #%01000000									// [2]		set JiffyDOS bit
			tay	 											// [2]		stash merged bit
notjiffy:	tya	 											// [2]		get JiffyDOS bit
			ora f40_runtime_memory.Memory_Bitmap 			// [4]		merge both with memory bitmap
			sta f40_runtime_memory.Memory_Bitmap 			// [4]		stash with merged bits

			// initialise the 40x24 screen
			jsr f40_helper_routines.configure_vic			// [6]		set 40x24 mode
			dec f40_runtime_memory.TXTBUFFL					// [5]		decrement for page index offset operations
			lda #vic20.screencodes.CLRSCRN					// [2]		clear/home
			jsr f40_character_output.character_output		// [6]		display character

			// display startup messages
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
