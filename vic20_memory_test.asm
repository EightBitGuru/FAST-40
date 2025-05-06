// VIC-20 RAM test 
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.filenamespace vic20_memory_test

.var EnableBLK5Test = false 								// test BLK5 (might nuke RAM-loaded cartridges)
.var PreserveStack = true									// preserve Stack if called after POST

// memory test working addresses
.label RAMBITS	= $0000										//	expansion RAM bitmap
.label TESTADDL	= $0001										//	test address lo-byte
.label TESTADDH	= $0002										//	test address hi-byte
.label ENDPAGEH	= $0003										//	end page hi-byte
.label COLRTEST	= $0003										//	colour RAM data byte
.label STACKPTR = $0004										//	stashed .SP

// RAM test
// <= RAMBITS	Memory population bits
memory_test:
.pc = *	"memory_test"
{
			sei												// [2]		disable interrupts
			cld												// [2]		clear Decimal flag

			// test ZP
			ldx #0 											// [2]		initialise ZP offset
			ldy #%11111111									// [2]		first test bit-pattern
nextzp:		tya												// [2]		move bit-pattern to .A for test
zptest:		sta vic20.os_zpvars.USRJMP,x					// [4]		store pattern
			cmp vic20.os_zpvars.USRJMP,x					// [4]		check it
			bne testfail									// [2/3]	store failed, game over
			adc #0											// [2]		add 1 in the carry flag to yield second test bit-pattern (%00000000)
			beq zptest										// [3/2]	loop around to test next pattern
			inx												// [2]		increment location index
			bne nextzp										// [3/2]	loop around to test next location

			// test memory after ZP
.if(PreserveStack)
{
			tsx 											// [2]		get .SP
			inx												// [2]		increment so .X in POST is zero
			stx STACKPTR									// [3]		stash for later
}
.if(EnableBLK5Test)
{
			ldx #7											// [2]		memory table index for BLK5
}
else
{
			ldx #5											// [2]		memory table index for BLK3
}
			iny												// [2]		main RAM address line / byte memory test address lo-byte index (.Y = 0)
newblock:	lda PAGEADDH+1,x								// [4]		get test address end page
			sta ENDPAGEH									// [3]		set test address end hi-byte
			lda PAGEADDH,x									// [4]		get block test address start page
			sta TESTADDH									// [3]		set test address start hi-byte
.if(PreserveStack)
{
			cmp #>vic20.cpu.STACK							// [3]		are we testing the Stack now?
			beq skipstack									// [2/3]	check if we need to skip it
}
			// memory test first stage
nextbyte:	lda #%11111111									// [2]		first test bit-pattern
bytetest:	sta (TESTADDL),y								// [6]		store pattern
			cmp (TESTADDL),y								// [5]		check it
			beq testpass									// [3/2]	store worked

			// test failed - was it in onboard memory?
			lda ENDPAGEH									// [3]		get test address end hi-byte
			cmp #>vic20.ram.RAMBLK0							// [2]		failure in 1K onboard?
			beq testfail									// [2/3]	yep, critical failure
			cmp #>vic20.ram.RAMBLK1							// [2]		failure in 4K onboard?
			beq testfail									// [2/3]	yep, critical failure

			// not in onboard memory, clear expansion bit
			clc												// [2]		clear carry
			bcc setbit										// [3/3]	set expansion bit

			// memory test failed, game over
testfail:	lda #$2A										// [2]		red screen/border
			sta vic20.vic.VCSCRNCO							// [4]		set VIC colour register
			hlt												// [0]		halt (and catch fire)

			// check if we're in POST (and skip the Stack test if not)
skipstack:	
.if(PreserveStack)
{
			lda STACKPTR									// [3]		get stashed .SP
			beq nextbyte 									// [2/3]	zero means POST so do test
			bne nextpage 									// [3/3]	skip Stack page
}

			// page address hi-bytes
PAGEADDH:	.byte >vic20.cpu.STACK
			.byte >vic20.ram.RAMBLK0
			.byte >vic20.ram.RAMMAIN
			.byte >vic20.ram.RAMBLK1
			.byte >vic20.ram.RAMBLK2
			.byte >vic20.ram.RAMBLK3
			.byte >vic20.character_generator.UCROM
			.byte >vic20.cartridge.RAMBLK5
			.byte >vic20.basic.BASICCLD

			// memory test second stage
testpass:	adc #0											// [2]		add 1 in the carry flag to yield second test bit-pattern (%00000000)
			beq bytetest									// [3/2]	loop around to test next pattern
			iny												// [2]		next test address on current page
			bne nextbyte									// [3/2]	loop back to first pattern

			// page tested, loop for next
nextpage:	lda ENDPAGEH									// [3]		get test address end hi-byte
			inc TESTADDH									// [5]		increment memory test address hi-byte
			cmp TESTADDH									// [5]		check for end of block
			bne nextbyte									// [3/3]	continue test at next page
			cmp #>vic20.ram.RAMBLK0							// [2]		1K onboard?
			beq skipbit										// [2/3]	yep, no expansion bit
			cmp #>vic20.ram.RAMBLK1							// [2]		4K onboard?
			beq skipbit										// [2/3]	yep, no expansion bit

			// set or clear memory expansion bit
			sec												// [2]		set carry for rotate
setbit:		rol RAMBITS										// [5]		rotate carry into expansion RAM bitmap

.if(EnableBLK5Test)
{
			cmp #>vic20.basic.BASICCLD						// [2]		did we just test 8K BLK5?
			bne skipbit										// [3/2]	no, carry on
			dex												// [2]		double-decrement to skip UCROM
}

skipbit:	dex												// [2]		decrement memory table index for next block
			bpl newblock									// [3/2]	loop back if not finished

			// colour memory test
			ldx #>vic20.colour_ram.COLOUR1					// [2]		colour memory start
			stx TESTADDH									// [3]		store test address start hi-byte
			ldx #>vic20.unmapped.UNMAPPED					// [2]		colour memory end
nextnybl:	lda #%00001111									// [2]		first colour nybble test bit-pattern
nybltest:	sta COLRTEST									// [3]		store pattern at test data location
			sta (TESTADDL),y								// [6]		store pattern at indirect test address with .Y offset
			lda (TESTADDL),y								// [5]		get pattern
			and #%00001111									// [2]		mask-off upper nybble
			cmp COLRTEST									// [3]		compare with test data
			bne testfail									// [3/2]	store failed
			lda #%00000000									// [2]		second test bit-pattern
			cmp COLRTEST									// [3]		compare with test data
			bne nybltest									// [3/2]	loop back for second test
			iny												// [2]		next test address on current page
			bne nextnybl									// [3/2]	loop back to first pattern
			inc TESTADDH									// [5]		increment memory test address hi-byte
			cpx TESTADDH									// [5]		check for end of block
			bne nextnybl									// [3/2]	continue test at next page

			// set the cassette buffer pointers and RAM bitmap
			lda #<vic20.os_vars.CASSBUFF					// [2]		get cassette buffer lo-byte
			sta vic20.os_zpvars.TBUFFSTL					// [3]		set cassette buffer pointer lo-byte
			lda #>vic20.os_vars.CASSBUFF					// [2]		get cassette buffer hi-byte
			sta vic20.os_zpvars.TBUFFSTH					// [3]		set cassette buffer pointer hi-byte
			lda vic20_memory_test.RAMBITS					// [3]		get RAM population bits
			sta f40_runtime_memory.Memory_Bitmap			// [4]		stash for use later

			// check if called during POST or from somewhere else
			ldx vic20_memory_test.STACKPTR					// [3]		get stashed .SP
			beq continue									// [3/2]	continue if in POST
			rts												// [6]		return to caller if not
continue:
}
