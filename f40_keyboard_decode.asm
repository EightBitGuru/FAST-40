// FAST-40 DECODE vector handler
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace f40_keyboard_decode

// Handler for SHIFT/CTRL/C= keypresses
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
			bne checkshift									// [2/3]	pattern is not the same so check shift mode
			jmp vic20.kernal.STOPKEY						// [3]		enable VIA for RUN/STOP ($EBD6)
checkshift:	lda vic20.os_vars.SHFTMODE						// [4]		get shift mode flag b7 (0=unlocked, 1=locked)
			bmi scankey										// [2/3]	if shift mode locked then skip case toggle
			lda f40_runtime_memory.CASEFLAG					// [3]		get glyph case flag ($00=upper-case, $08=lower-case)
			eor #8											// [2]		flip case bit
			jsr f40_controlcode_handlers.set_case			// [6]		handle SHIFT/C= case switch in .A & .X
scankey:	jmp vic20.kernal.SCNKEY2						// [3]		jump into SCNKEY ($EB74)
}
