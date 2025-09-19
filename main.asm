// FAST-40 cartridge for VIC-20
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.var EnableBRKDebugging = false                         // BRK register dump

.import source "kickass_opcodes.asm"		            // KickAssembler opcode pseudocommands
.import source "vic20_system_constants.asm"				// VIC-20 system constants
.import source "vic20_system_memory.asm"				// VIC-20 system memory labels
.import source "f40_runtime_memory.asm"					// FAST-40 runtime memory labels
.import source "f40_runtime_constants.asm"				// FAST-40 runtime constants

.pc = $A000 "CART"	    								// Cartridge header
cart:
.word vic20_memory_test.memory_test		    			// Cartridge cold-start vector
.word f40_interrupt_handlers.nmi_handler				// Cartridge warm-start vector
.byte 'A','0',$C3,$C2,$CD								// Cartridge autostart signature (A0CBM)

data:
.import source "f40_static_data.asm"					// Static data structures

code:
.import source "f40_character_output.asm"				// CHROUT vector handler
.import source "f40_controlcode_handlers.asm"			// Control code output handlers
.import source "f40_interrupt_handlers.asm"				// IRQ/NMI vector handler
.import source "f40_basic_wedge.asm"		    		// BASIC decode vector handler
.import source "f40_helper_routines.asm"			    // General helper routines
.import source "f40_vic_configuration.asm"				// Configuration data
.import source "f40_keyboard_decode.asm"				// Control key decode vector handler
.import source "vic20_memory_test.asm"					// Memory test
.import source "f40_runtime_setup.asm"					// Runtime memory / system setup
.import source "f40_character_input.asm"				// CHRIN vector handler

.if(EnableBRKDebugging)
{
.import source "vic20_debug_handler.asm"				// BRK debugging information
}

.print "CODE BYTES: "+[*-code]
.print "DATA BYTES: "+[code-data]
.print "TOT. BYTES: "+[*-cart]
.print "FREE BYTES: "+[4096-[*-cart]]

.pc = $B000 "CHARDATA"
glyphs:
.import source "f40_glyph_data.asm"						// FAST-40 glyph data (4096 bytes)
