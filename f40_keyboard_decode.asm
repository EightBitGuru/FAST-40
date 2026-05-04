// FAST-40 DECODE vector handler
// Copyright (C) 2026 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_keyboard_decode

// Handler for SHIFT/CTRL/C= keypresses (called via DECODEL vector at $028F/0290 => $EBDC)
decode_keypress:
.pc = * "decode_keypress"
{
			lax vic20.os_vars.SHFTCTRL						// [4]		get SHIFT/CTRL flag
			cmp #3											// [2]		check for SHIFT/C=
			beq checklast									// [2/3]	if SHIFT/C= then check last pattern
			bit f40_runtime_memory.Memory_Bitmap 			// [4]		get b6 for JiffyDOS
			bvs jiffydos									// [2/3]	do relocated jump if JiffyDOS installed
			jmp vic20.kernal.DECODE2						// [3]		jump to stock DECODE2 entrypoint ($EC0F)
jiffydos:	jmp vic20.kernal.DECODE2J						// [3]		jump to JiffyDOS DECODE2 entrypoint ($EBF8)
checklast:	cmp vic20.os_vars.LASTSHFT						// [3]		compare with last control key pattern
			beq scankey										// [2/3]	same pattern: update LASTSHFT and exit
checkshift:	lda vic20.os_vars.SHFTMODE						// [4]		get shift mode flag b7 (0=unlocked, 1=locked)
			bmi scankey										// [2/3]	if shift mode locked then skip case toggle
			ror f40_runtime_memory.CRSRUDRW					// [6]		set cursor undraw b7 (Carry=1 here)
			jsr f40_interrupt_handlers.undraw_cursor		// [6]		undraw cursor if drawn
			lda f40_runtime_memory.CASEFLAG					// [3]		get glyph case flag ($00=upper-case, $08=lower-case)
			eor #8											// [2]		flip case bit
			jsr f40_controlcode_handlers.set_case			// [6]		handle SHIFT/C= case switch
scankey:	stx vic20.os_vars.LASTSHFT						// [4]		update last shift pattern
			jmp vic20.kernal.STOPKEY						// [3]		exit SCNKEY without adding to keyboard buffer ($EBD6)
}
