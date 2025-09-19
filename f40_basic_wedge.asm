// FAST-40 BASIC command wedge
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_basic_wedge

// Handler for BASIC extensions
decode_command:
.pc = * "decode_command"
{
			ldy #5											// [2]		command text length (1-based)
chkcmd:		lda (vic20.os_zpvars.EXECPTRL),y				// [6]		get byte from CHRGET execution pointer
			cmp f40_static_data.WEDGECMD-1,y				// [4]		compare with our command
			bne nomatch										// [2/3]	scram if no match
			dey												// [2]		decrement index
			bne chkcmd										// [3/2]	loop until command check done

			// found our RESET command
			ldy #6											// [2]		bytes to process
getbyte:	jsr vic20.os_zpvars.CHRGET						// [6]		call CHRGET to get a byte
			dey												// [2]		decrement count
			bne getbyte										// [3/2]	loop until done

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
