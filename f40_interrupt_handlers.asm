// FAST-40 IRQ/NMI routines
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_interrupt_handlers

// IRQ handler (called via IRQVECL vector)
irq_handler:
.pc = * "irq_handler"
{
			lda vic20.os_zpvars.CRSRMODE					// [3]		get cursor blink mode (0=flash)
			bne kernalirq									// [2/3]	skip cursor blink if no flash
			dec vic20.os_zpvars.CRSRTIME					// [5]		decrement cursor countdown
			bpl kernalirq									// [3/2]	skip cursor blink if still counting
			jsr blink_cursor								// [6]		blink cursor
kernalirq:	jsr vic20.kernal.UDTIM							// [6]		update clock ($F734)
			jmp vic20.kernal.IRQTAPE						// [3]		jump to tape/keyboard IRQ entrypoint ($EAEF)
}


// Undraw cursor if required
undraw_cursor:
.pc = * "undraw_cursor"
{
			bit f40_runtime_memory.CRSRUDRW					// [3]		test cursor undraw flag b7
			bpl blinkexit									// [2/3]	skip undraw if not required
			lda vic20.os_zpvars.CRSRBLNK					// [3]		get cursor blink phase flag
			beq blinkexit									// [2/3]	skip undraw if phase is off
			sta f40_runtime_memory.CRSRUDRW					// [3]		clear cursor undraw flag (.A=1 but we only care about b7)
// Fall-through into blink_cursor
}


// Blink cursor
blink_cursor:
.pc = * "blink_cursor"
{
			ldy #7											// [2]		index offset for cursor mask
loop:		lda (f40_runtime_memory.CRSRBITL),y				// [5]		get bitmap byte
			eor f40_runtime_memory.CRSRMASK					// [3]		apply inversion mask
			sta (f40_runtime_memory.CRSRBITL),y				// [6]		set bitmap byte
			dey												// [2]		decrement index
			bpl loop										// [3/2]	loop for next byte
			lda vic20.os_zpvars.CRSRBLNK					// [3]		get cursor blink phase flag
			tay												// [2]		stash in .Y for later
			eor #1											// [2]		invert blink phase flag
			sta vic20.os_zpvars.CRSRBLNK					// [3]		set cursor blink phase flag
			lda f40_static_data.BLNKTIME,y					// [4]		get cursor blink timer for this phase
			sta vic20.os_zpvars.CRSRTIME					// [3]		reset cursor countdown
@blinkexit:	rts												// [6]
}


// NMI handler (called from stock NMI via CARTWARM vector)
nmi_handler:
.pc = * "nmi_handler"
{
			bit f40_runtime_memory.Memory_Bitmap-1			// [4]		test last byte of MERGROUT (set when FAST-40 is active)
			bpl stocknmi									// [2/3]	if b7 not set then FAST-40 is not active so do stock NMI
			bit vic20.via1.V1PORTAO 						// [3]		tickle VIA1 Port A to acknowledge NMI
			jsr vic20.kernal.UDTIM							// [6]		update clock ($F734)
			jsr vic20.kernal.CHKSTOP 						// [6]		check if [RUN/STOP] pressed
			beq rsrestore									// [2/3]	do RS/RESTORE if so
			jmp vic20.kernal.INTEXIT						// [3]		jump to stock NMI exit
stocknmi:	jmp vic20.kernal.NMINOA0						// [3]		jump to stock NMI handler (no cartridge)
rsrestore:	jsr vic20.kernal.INITIO							// [6]		reset VIA interrupts
			jsr f40_helper_routines.reset_vectors			// [6]		reset KERNAL and FAST-40 vectors
			jsr f40_helper_routines.configure_vic			// [6]		reset 40x24 mode
			jsr f40_controlcode_handlers.clear_screen 		// [6]		clear screen
			jmp (vic20.basic.BASICWRM)						// [5]		do BASIC warm-start
}
