# FAST-40

FAST-40 is a cartridge program for the Commodore VIC-20 which modifies the 22-column text screen to display 40 columns.  
It is software-only (no hardware modification is required) and needs a minimum of 8K expansion RAM to operate.

#### FAST-40 is copyright © 2025 [8-Bit Guru](mailto:the8bitguru@gmail.com). Free for non-commercial use.  

* Creation of modified or derivative works using, in whole or in part, any sourcecode, assets, or binary package originating from this project, ***for non-commercial use***, is permitted. You are required to clearly include a link reference to this project within your project if you create such works.

* Commercial reproduction and/or distribution of any part of the sourcecode, assets, or binary package originating from this project is expressly forbidden except by explicit consent from the copyright holder.

### Toolchain

* **Editor**  
My personal choice is [Visual Studio Code 1.99](https://code.visualstudio.com/). Any editor you're comfortable with will suffice.

* **Assembler**  
The sourcecode syntax targets [KickAssembler 5.25](https://theweb.dk/KickAssembler/Main.html#frontpage). No other build tool is required.  
Note that KickAssembler is written in Java and requires a Java runtime to be present. My preferred runtime is [AdoptJDK](https://adoptopenjdk.net/releases.html) but any should suffice.

* **Emulator**  
The code builds a binary cartridge image which can be used with ***xvic***, the VIC-20 emulator shipped with [VICE 3.9](https://vice-emu.sourceforge.io/). It can also be flashed/loaded into an appropriate EPROM or 'soft' cartridge hardware product for use with a real VIC-20.

* **Extensions**  
I use 3rd-party VSCode extension [Kick Assembler 8-Bit Retro Studio 0.23.3](https://gitlab.com/retro-coder/commodore/kick-assembler-vscode-ext) which provides 6502 syntax highlighting and automatically invokes KickAssembler and VICE during build/test without needing to switch out to a command prompt.

### Building and running the binary

To build the binary image (an 8K auto-start cartridge) execute KickAssembler in the **Source** directory as follows:
 
    java -jar [Your_KickAssembler_Path]\KickAss.jar main.asm -o fast40.bin -binfile

To use the image as a cartridge with ***xvic***:

    [Your_VICE_Path]\bin\xvic.exe -memory 0,1 -cartA fast40.bin

### Expansion Cartridges and JiffyDOS

FAST-40 works when loaded into the Final Expansion 3 cartridge.
FAST-40 works with the JiffyDOS v6.01 Kernal ROM.

Other 'soft' cartridges or RAM-switcher boards which can load binary cartridge images *should* work as expected.

### Undocumented OpCodes

FAST-40 expects to run on a VIC-20 fitted with a standard NMOS 6502, which features a number of 'undocumented' opcodes that arise as byproducts of the instruction decode circuitry. They typically combine parts of other instructions and often yield obscure functionality or unpredictable results, and are not part of the official opcode list. However a few of them are reliably useful and are commonly included in programs seeking to minimise code size and/or cycle times.

Although not used extensively within FAST-40, some use of these opcodes is made where they offer a space or time saving. A typical example is the LAX instruction, which can be used in some addressing modes to simultaneously load a value into both the Accumulator and X-Register (hence **L**oad **A** and **X**) and thus requires fewer bytes and cycles than the standard pairing of LDA/TAX.

Later variants of the 6502 (including the CMOS 65C02) replaced these undocumented opcodes, either with NOP instructions or with completely new instructions such as BRA. FAST-40 will therefore **not** operate correctly (if at all) on these microprocessors.

### Usage

The cartridge image uses the standard $A000 auto-start mechanism and does not require any additional action to begin operation.

#### Configuration

FAST-40 auto-detects which video standard (PAL or NTSC) is in use, and is compatible with both.

FAST-40 requires a minimum of 8K RAM (BLK1, $2000-$3FFF) and will happily work with additional RAM in BLK2/BLK3 if present. A text buffer of just under 1K is reserved at the top of the highest available 8K block, leaving the rest free for BASIC.

If the 3K RAM block is populated (BLK0, $0400-$0FFF) then FAST-40 will use that as the buffer reservation area instead, leaving all of BLK1/2/3 available to BASIC and 2K available for machine-code use at the start of BLK0 ($0400-$0BFF).

FAST-40 uses all of the unexpanded RAM area ($1000-$1FFF) for video display reconfiguration.

#### RESET command

FAST-40 provides a new BASIC command to easily switch between memory configurations without having to swap cartridges.

    RESET [0|3|8]   Switch to specified video/memory configuration
    
        RESET		Switch to 40-column display, 8K+ mode
        RESET 0		Switch to 22-column display, unexpanded mode
        RESET 3		Switch to 22-column display, 3K mode (if RAM is present in BLK0)
        RESET 8		Switch to 22-column display, 8K+ mode

#### Memory Usage

FAST-40 makes extensive changes to the memory layout governing video display organisation and presentation, so any program written in either BASIC or machine-code which writes directly to video or colour memory will, at best, fail to produce the expected result. At worst, the internal configuration of the 40-column display mode may be compromised and only a system reset will trigger a rebuild of those structures.

FAST-40 also sets various VIC registers to specific values in order to put the hardware into the correct mode for the 40-column display, and programs altering those registers will almost certainly disrupt the presentation and management of this mode.

The following memory blocks and VIC registers are used by FAST-40 and should be considered 'out of bounds' for programs.

    $0003-$0004     Not normally used by BASIC.     [only used if BRK debugging is enabled at build time]
    $00D9-$00F1     Normally used as the BASIC screen editor line-link table.
    $02A1-$02FF     Not normally used by BASIC.
    $0C00-$0FFF     Reserved for the FAST-40 text buffer if there is 3K RAM in BLK0.
    $1000-$1FFF     Normally used as the unexpanded screen and RAM area.
    $3C00-$3FFF     Reserved for the FAST-40 text buffer if BLK0 is empty and 8K in BLK1.
    $5C00-$5FFF     Reserved for the FAST-40 text buffer if BLK0 is empty and 16K in BLK1/2.
    $7C00-$7FFF     Reserved for the FAST-40 text buffer if BLK0 is empty and 24K in BLK1/2/3.
    $9400-$95FF     Normally used as colour memory when RAM is in BLK1/2/3.

    $9000           Screen x-position
    $9001           Screen y-position
    $9002           Screen address and columns
    $9003           Screen rows and character height
    $9005           Screen address and character generator address

### Programming Caveats

Programs wishing to operate in 40-column mode should not read/write video or colour memory directly, but instead use the PRINT statement (in BASIC) or call the CHROUT vector at $FFD2 (in machine-code). Both are configured to route their output through to the custom display logic within FAST-40, and thereby allow it to manage screen output.

Common programming techniques such as switching character-case by altering the value at address 36869 ($9005), adjusting cursor blink phase, frequency, or position by altering the relevant zero-page values at $CC/$CD/$CF/$D3/$D6, or otherwise directly interacting with screen editor functionality via zero-page or other addresses is discouraged. Such interactions are unlikely to yield the expected result or (more likely) will disrupt FAST-40 operation.

FAST-40 supports all PRINTable control codes including those for cursor positioning, colour selection, reverse-mode, etc. Although there is no 'visible' control code to reproduce the action of the CTRL/C= key combination for switching between upper- and lower-case, the codes do exist and can be generated with CHR$(14) and CHR$(142).

FAST-40 hooks several I/O and system vectors in order to augment or replace stock display functionality; programs wishing to provide additional features whilst maintaining the 40-column display mode should capture the following vectors as needed before overwriting them with their own, and then end their processing by passing control to the captured addresses.

    $028F/$0290     SHIFT/CTRL/C= key decode
    $0308/$0309     BASIC decode
    $0314/$0315     IRQ interrupt
    $0316/$0317     BRK interrupt       [only used if BRK debugging is enabled at build time]
    $0324/$0325     Character input
    $0326/$0327     Character output

Due to inherent limitations in the VIC design there is no way to preserve the usual 1:1 relationship between individual text-mode characters and their respective colour attribute when in 40-column mode - although all text colours are supported, they operate on 2x2 blocks of characters. Keep in mind that the colour resolution is half that of the text resolution and plan your colour choices accordingly to avoid attribute clash.

## Who is 8-Bit Guru?

8-Bit Guru (also: Eight-Bit Guru, 8BitGuru, 8BG) is the nom de guerre of Mark Johnson. I'm a professional coder from the UK who has been telling computers what to do since 1981. My day job is all about C# backend processing systems which provide RESTful APIs for petcare-related websites, and my hobby projects mostly involve writing 6502 assembly-language for 8-bit machines like the VIC-20.

## Credit where it's due

The following VIC-20 gurus at [Denial](https://sleepingelephant.com/ipw-web/bulletin/bb/index.php) actively participated in the beta-test phase. Their time and effort spent testing, sending bug reports, and assisting with crash diagnosis is greatly appreciated.

* tokra
* mathom
