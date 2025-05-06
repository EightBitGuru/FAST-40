// KickAssembler 6502 custom opcode pseudocommands
// Copyright (C) 2025 8BitGuru <the8bitguru@gmail.com>

.pseudocommand hlt													// Halt (JAM/KIL)
{
			.byte $02												// [0]		Kill CPU by breaking internal T-state register
}

.pseudocommand dop operand											// Double-byte NOP (SKB)
{
			.if (operand.getType()==AT_IMMEDIATE)
				.byte $80											// [2]		Skip byte
			.if (operand.getType()==AT_ABSOLUTE)
				.byte $03											// [3]		Skip byte
			.if (operand.getType()==AT_IZEROPAGEX)
				.byte $14											// [4]		Skip byte
}

.pseudocommand isb operand											// Increment and Subtract (INS)
{
			.if (operand.getType()==AT_ABSOLUTE)
				.byte $E7											// [5]		INCremment memory and SBC	ZP
			.if (operand.getType()==AT_IZEROPAGEY)
				.byte $F3											// [8]		INCremment memory and SBC	(ZP),y
			.byte operand.getValue()
}

.pseudocommand zax													// Zero .A and .X
{
			.word $00AB												// [2]		LAX Immediate #$00 (Load .A and .X with zero, unstable with non-zero operands)
}

/*.pseudocommand aac												// AND A and set Carry (ANC)
{
			.byte $0B												// [2]
}
*/

/*.pseudocommand aso												// ASL and OR with .A (SLO)
{
			.byte $07												// [5]
			.byte $17												// [6]
			.byte $0F												// [6]
			.byte $1F												// [7]
			.byte $1B												// [7]
			.byte $03												// [8]
			.byte $13												// [8]
}
*/

/*.pseudocommand axs												// Subtract from .A AND .X (SBX)
{
			.byte $CB												// [2]
}
*/

/*.pseudocommand dcm												// Decrement and CMP .A (DCP)
{
			.byte $C7												// [5]
			.byte $D7												// [6]
			.byte $CF												// [6]
			.byte $DF												// [7]
			.byte $DB												// [7]
			.byte $C3												// [8]
			.byte $D3												// [8]
}
*/

/*.pseudocommand lse												// LSR and OR .A (SRE)
{
			.byte $07												// [5]
			.byte $17												// [6]
			.byte $0F												// [6]
			.byte $1F												// [7]
			.byte $1B												// [7]
			.byte $03												// [8]
			.byte $13												// [8]
}
*/

/*.pseudocommand oal												// OR .A and AND (LXA)
{
			.byte $AB												// [2]
}
*/

/*.pseudocommand xaa												// TXA and AND .A (ANE)
{
			.byte $8B												// [2]
}
*/

/*.pseudocommand xas												// Transfer .A AND .X to .SP (SHS)
{
			.byte $9B												// [2]
}
*/
