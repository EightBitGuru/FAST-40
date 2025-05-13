# FAST-40

FAST-40 is a cartridge ROM program for the Commodore VIC-20 which reconfigures the stock 22x23 text screen to display a denser 40x24 mode. It is written entirely in 6502 assembly language and requires a minimum of 8K expansion RAM to run.

No hardware modification to the ROM or display generation/output circuitry is required.

Other (vintage) 40-column programs typically suffer from some combination of sluggish performance, visual glitching, or screen-editor functionality issues. FAST-40 was designed to cleanly render a 40x24 text display at close to stock 22x23 speeds whilst faithfully reproducing screen-editor functionality, and in fact it achieves a throughput rate of around 89% of the hardware-rendered display despite software-rendering almost twice as much text data. It is, notably, ***faster*** at rendering a 40x24 text display than a Commodore 64 using the stock ROM and VIC-II hardware.

#### FAST-40 is copyright © 2025 [8-Bit Guru](mailto:the8bitguru@gmail.com).

* Creation of modified or derivative works ***for non-commercial use*** using, in whole or in part, any sourcecode, assets, or binary package originating from this project is permitted. You are required to clearly include a credit and link reference to this project within your project if you create such works.

* Commercial reproduction and/or distribution of any part of the sourcecode, assets, or binary package originating from this project is **expressly forbidden** except by explicit consent from the copyright holder.

* The FAST-40 project is hosted on [GitHub](https://github.com/EightBitGuru/FAST-40).

### Toolchain

* **Editor**  
My personal choice is [Visual Studio Code](https://code.visualstudio.com/). Any editor you're comfortable with will suffice.

* **Assembler**  
The sourcecode syntax targets [KickAssembler 5.25](https://theweb.dk/KickAssembler/Main.html#frontpage). No other build tool is required.  
Note that KickAssembler is written in Java and requires a Java runtime to operate. My preferred runtime is [AdoptJDK](https://adoptopenjdk.net/releases.html).

* **Emulator**  
The code builds a binary cartridge image which can be used with ***xvic***, the VIC-20 emulator shipped with [VICE](https://vice-emu.sourceforge.io/).

* **Extensions**  
I use 3rd-party VSCode extension [Kick Assembler 8-Bit Retro Studio 0.23.3](https://gitlab.com/retro-coder/commodore/kick-assembler-vscode-ext) which provides 6502 syntax highlighting and automatically invokes KickAssembler and VICE during build/test without needing to switch out to a command prompt.

### Build and Run

The sourcecode produces a standard BLK5 ($A000-$BFFF) 8K cartridge ROM binary.

Execute KickAssembler in your working copy directory to build the binary:
 
    java -jar [Your_KickAssembler_Path]\KickAss.jar main.asm -o fast40.bin -binfile

To use the binary with ***xvic***:

    [Your_VICE_Path]\bin\xvic.exe -memory 0,1 -cartA fast40.bin

The cartridge auto-starts via the standard **A0CBM** signature-detection mechanism.

Both PAL and NTSC video standards are supported - the code detects which of a 6560 or 6561 VIC is present and adjusts the display configuration accordingly.

### Expansion Cartridges and JiffyDOS

FAST-40 can be flashed/loaded into an appropriate EPROM or 'soft' cartridge product such as the Final Expansion 3 cartridge and then used with a real VIC-20.

FAST-40 will detect and work with the JiffyDOS v6.01 Kernal replacement ROM if present.

### Memory Requirement

FAST-40 uses all of the 4K unexpanded RAM area ($1000-$1FFF) for video display reconfiguration, and requires a minimum of 8K expansion RAM in BLK1 ($2000-$3FFF). A text buffer of just under 1K is reserved at the top of the highest available 8K block, leaving the rest free for BASIC - it will happily work with additional expansion RAM in BLK2 and BLK3 if present.

If the 3K expansion RAM area in BLK0 ($0400-$0FFF) is also populated then FAST-40 will preferentially use the top of that as the text buffer area instead, leaving the lower 2K ($0400-$0BFF) of it available for machine-code programs and all of BLK1 (and BLK2/BLK3 if populated) available to BASIC.

### Memory Usage

FAST-40 makes changes to numerous memory areas, VIC registers, and system vectors in order to configure and manage the 40x24 mode. Except where noted, these area should be considered 'out of bounds' for other programs:

    $0003-$0004     Not normally used by BASIC/KERNAL.     [only used if BRK debugging is enabled at build time]
    $00D9-$00F1     Normally used as the BASIC screen editor line-link table.
    $02A1-$02FF     Not normally used by BASIC/KERNAL.
    $0C00-$0FFF     Reserved for the FAST-40 text buffer if there is 3K RAM in BLK0.
    $1000-$1FFF     Normally used as the unexpanded screen and RAM area.
    $3C00-$3FFF     Reserved for the FAST-40 text buffer if BLK0 is empty and 8K in BLK1.
    $5C00-$5FFF     Reserved for the FAST-40 text buffer if BLK0 is empty and 16K in BLK1/2.
    $7C00-$7FFF     Reserved for the FAST-40 text buffer if BLK0 is empty and 24K in BLK1/2/3.
    $9400-$95FF     Normally used as colour memory when RAM is in BLK1/2/3.

VIC registers used by FAST-40 to configure the 40x24 mode:

    $9000           Screen x-position
    $9001           Screen y-position
    $9002           Screen memory address and columns
    $9003           Screen rows and character height
    $9005           Screen memory address and character generator address

FAST-40 hooks several system vectors in order to manage the 40x24 mode; these vectors may be modified by other programs wishing to provide additional functionality, provided they first capture the target address of whichever vector(s) they need before replacing them with their own. When finalising their processing they should end by passing control to the captured FAST-40 addresses:

    $028F/$0290     SHIFT/CTRL/C= key decode
    $0308/$0309     BASIC decode
    $0314/$0315     IRQ interrupt
    $0316/$0317     BRK interrupt       [only used if BRK debugging is enabled at build time]
    $0324/$0325     Character input
    $0326/$0327     Character output

Unplanned writes to the text buffer, display bitmap, colour memory, and screen-editor management areas will be repaired whenever the screen is cleared with SHIFT/CLR-HOME.

Unplanned writes to the VIC registers, system vectors, and/or other runtime memory structures can almost always be repaired via a RUNSTOP/RESTORE reset.

Unplanned writes to the underlying display character matrix and other critical areas will require a system reset to trigger a repair of those structures.

#### RESET command

FAST-40 provides a new BASIC command to easily reset the system and/or switch between memory configurations without having to swap cartridges.

    RESET [0|3|8]   Switch to specified video/memory configuration
    
        RESET		Switch to 40x24 8K+ mode
        RESET 0		Switch to 22x23 unexpanded mode
        RESET 3		Switch to 22x23 3K mode (if RAM is present in BLK0)
        RESET 8		Switch to 22x23 8K+ mode

### Programming Caveats

Programs wishing to operate in 40x24 mode should not read/write video or colour memory directly, but instead use the PRINT statement (in BASIC) or call the CHROUT vector at $FFD2 (in machine-code). Both are configured to route their output through to the custom display logic within FAST-40, and thereby allow it to manage screen output.

Common programming techniques such as switching character-case by altering the value at address 36869 ($9005), adjusting cursor blink phase, frequency, or position by altering the relevant zero-page values at $CC/$CD/$CF/$D3/$D6, or otherwise directly interacting with screen editor functionality via zero-page or other addresses is discouraged. Such interactions are unlikely to yield the expected result or (more likely) will disrupt FAST-40 operation.

FAST-40 supports all PRINTable control codes including those for cursor positioning, colour selection, reverse-mode, etc. Although there is no 'visible' control code to reproduce the action of the SHIFT/C= key combination for switching between upper- and lower-case, the codes do exist and can be generated with CHR$(14) and CHR$(142).

Limitations in the VIC design mean there is no way to preserve the usual 1:1 relationship between individual text-mode characters and their respective colour attribute when in 40x24 mode. All text colours are supported but they operate on 2x2 blocks of characters - the colour resolution is half that of the text resolution, so plan your colour layout accordingly to avoid attribute clash.

### Undocumented OpCodes

FAST-40 expects to run on a VIC-20 fitted with a standard NMOS 6502, which features a number of 'undocumented' opcodes - some use of which is made where they offer a space or time saving. Later variants of the 6502 (including the CMOS 65C02) disable or replace these undocumented opcodes, and FAST-40 will not operate correctly (if at all) on these microprocessors.

## Who is 8-Bit Guru?

8-Bit Guru (also: Eight-Bit Guru, 8BitGuru, 8BG) is the nom de guerre of Mark Johnson. I'm a professional coder from the UK who has been telling computers what to do since 1981. My day job is all about C# backend processing systems which provide RESTful APIs for petcare-related websites, and my hobby projects mostly involve writing 6502 assembly-language for 8-bit machines like the VIC-20.

## Credit where it's due

The following VIC-20 afficionados at [Denial](https://sleepingelephant.com/ipw-web/bulletin/bb/index.php) actively participated in the beta-test phase. Their time and effort spent testing, sending bug reports, and assisting with crash diagnosis is greatly appreciated.

* tokra
* mathom

### Beta 1 (9th April 2025)
* Initial release for testing.

### Beta 2 (21st April 2025)
* Fixed a bug where entering long BASIC lines would sometimes lose the character in column 40, causing syntax errors (reported by **tokra@denial**)
* Fixed a bug where data fed to the INPUT command included the prompt in the returned value and therefore broke it (reported by **mathom@denial**)
* Fixed a bug where inserting a character into a long line would sometimes erroneously insert a blank line after it
* Fixed a bug where doing a character insert in column 40 erroneously placed the inserted [SPACE] into column 39
* Fixed a bug in the screen-scrolling logic where consecutive text buffer lines were wrongly expected to be contiguous in memory
* Fixed a bug where RUNSTOP/RESTORE didn't reset the default text colour and character-case
* Added a simple CPU register display to the BRK handler to help debug JiffyDOS crash (reported by **mathom@denial**)
* Added an alternate build option to do LOAD"$",8 / LIST on SHIFT/RUNSTOP
* Tweaked the PAL/NTSC startup test to save the result for RUNSTOP/RESTORE and thereby avoid repeated re-tests
* Tweaked the cursor blink phase timings to help cursor visibility during rapid/repeated movement (reported by **mathom@denial**)

### Beta 2A (22nd April 2025)
* Fixed a bug where Stack poisoning from a previous bugfix caused mayhem in the insert and delete key handlers (reported by **tokra@denial**)

### Beta 3 (24th April 2025)
* Fixed a bug where deleting a character from column 1 replaced the character in column 39 on the previous line instead of column 40
* Fixed a bug where deleting a character from column 1 of an unlinked line produced an unwanted side-effect on the previous line
* Fixed a bug where the screen-scroll CTRL-delay code intermittently failed to execute (reported by **tokra@denial**)

### Release (2nd May 2025)
* Fixed the hard crash when running against the JiffyDOS Kernal
* Added the JiffyDOS banner to the startup message (if present)
* Fixed a bug where the startup RAM detection wasn't triggering a clean reset if BLK1 is empty
