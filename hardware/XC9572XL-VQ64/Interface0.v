`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:42:02 04/04/2022 
// Design Name: 
// Module Name:    Interface0 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Interface0(
    input ZX_CK,  /* The CK signal, sometimes referred to as PHICPU or ΦCPU is available on Lower Pin 8.
                     This clock signal is generated by the ULA and is interrupted during contended memory access.
                     On the UK 128 the ULA clock pin is connected directly to the edge connector and is inverted by TR3 to drive the Z80.
                     On the +2 the ULA clock pin is inverted by a NOT gate to generate the clock for the Z80.
                     It is then inverted again by a second NOT gate to generate the edge connector CK.
                     The CK signal is NOT connected on the Investrónica ZX Spectrum 128.
                   */

    input ZX_M1,  /* Machine Cycle One (output, active Low). M1, together with MREQ, indicates that the
                     current machine cycle is the op code fetch cycle of an instruction execution. M1, when
                     operating together with IORQ, indicates an interrupt acknowledge cycle.
                   */
    input ZX_MREQ,  /* Memory Request (output, active Low, tristate). MREQ indicates that the address
                       bus holds a valid address for a memory read or a memory write operation.
                     */

    input ZX_IORQ,  /* Input/Output Request (output, active Low, tristate). IORQ indicates that the lower
                       half of the address bus holds a valid I/O address for an I/O read or write operation. IORQ
                       is also generated concurrently with M1 during an interrupt acknowledge cycle to indicate
                       that an interrupt response vector can be placed on the data bus.
                     */

    input ZX_RD,  /* Read (output, active Low, tristate). RD indicates that the CPU wants to read data from
                     memory or an I/O device. The addressed I/O device or memory should use this signal to
                     gate data onto the CPU data bus.
                   */

    input ZX_WR,  /* Write (output, active Low, tristate). WR indicates that the CPU data bus contains
                     valid data to be stored at the addressed memory or I/O location
                   */

    input ZX_RFSH,  /* Refresh (output, active Low). RFSH, together with MREQ, indicates that the lower
                       seven bits of the system's address bus can be used as a refresh address to the system's
                       dynamic memories.
                     */

    input [15:0] ZX_ADDR, /* Address Bus (output, active High, tristate). A15-A0 form a 16-bit Address Bus,
                             which provides the addresses for memory data bus exchanges (up to 64KB) and for I/O
                             device exchanges.
                           */
    inout [7:0] ZX_DATA, /* Data Bus (input/output, active High, tristate). D7-D0 constitute an 8-bit
                            bidirectional data bus, used for data exchanges with memory and I/O
                          */

    output ZX_INT, /* Interrupt Request (input, active Low). An Interrupt Request is generated by I/O
                      devices. The CPU honors a request at the end of the current instruction if the internal soft-
                      ware-controlled interrupt enable flip-flop (IFF) is enabled. INT is normally wired-OR and
                      requires an external pull-up for these applications.
                    */

    output ZX_NMI, /* Nonmaskable Interrupt (input, negative edge-triggered). NMI contains a higher
                      priority than INT. NMI is always recognized at the end of the current instruction,
                      independent of the status of the interrupt enable flip-flop, and automatically forces the
                      CPU to restart at location 0066h.
                    */

    output ZX_HALT, /* HALT State (output, active Low). HALT indicates that the CPU has executed a
                       HALT instruction and is waiting for either a nonmaskable or a maskable interrupt (with
                       the mask enabled) before operation can resume. During HALT, the CPU executes NOPs to
                       maintain memory refreshes.
                     */

    output ZX_WAIT, /* WAIT (input, active Low). WAIT communicates to the CPU that the addressed
                       memory or I/O devices are not ready for a data transfer. The CPU continues to enter a
                       WAIT state as long as this signal is active. Extended WAIT periods can prevent the CPU
                       from properly refreshing dynamic memory.
                     */

    output ZX_RESET, /* Reset (input, active Low). RESET initializes the CPU as follows: it resets the
                        interrupt enable flip-flop, clears the Program Counter and registers I and R, and sets the
                        interrupt status to Mode 0. During reset time, the address and data bus enter a
                        high-impedance state, and all control output signals enter an inactive state. RESET must be
                        active for a minimum of three full clock cycles before a reset operation is complete.
                      */

    output ZX_BUSRQ, /* Bus Request (input, active Low). Bus Request contains a higher priority than
                        NMI and is always recognized at the end of the current machine cycle. BUSREQ forces
                        the CPU address bus, data bus, and control signals MREQ, IORQ, RD, and WR to enter a
                        high-impedance state so that other devices can control these lines. BUSREQ is normally
                        wired OR and requires an external pull-up for these applications. Extended BUSREQ peri-
                        ods due to extensive DMA operations can prevent the CPU from properly refreshing
                        dynamic RAM.
                      */

    input ZX_BUSACK, /* Bus Acknowledge (output, active Low). Bus Acknowledge indicates to the
                        requesting device that the CPU address bus, data bus, and control signals MREQ, IORQ,
                        RD, and WR have entered their high-impedance states. The external circuitry can now
                        control these lines.
                      */

    // 16K/48K/128K specific
    output ZX_ROMCS, /* The ZX Spectrum 16K/48K, ZX Spectrum 128, and ZX Spectrum +2 provide ROMCS on lower pin 25.
                        By holding this pin high an external peripheral can prevent the Spectrum's ROM from driving the data bus,
                        and place its own ROM or RAM within the first 16K of the 64K memory space.
                      */

    // +2A/2B, +3/3B specific
    output ZX_ROMCS1, // All the previous models of ZX Spectrum have a single ROM chip which could be disabled to facilitate paging
    output ZX_ROMCS2, /* in external memory by pulling the ROMCS line high. The +2A/+3 and +3B however have two ROM chips and brings
                         them out to independent pins on the expansion port. The old ROMCS pin (Lower pin 25) is not used, and instead
                         Upper pin 4 and Lower pin 15 are used. These pins were both unused on the 128K, however Lower pin 15 was used
                         for composite video out on the 16K/48K.
                       */


    input ZX_DRD, // Unlike the +3, the +2A and +2B have no floppy disc controller. Amstrad's original intention was to produce an
    input ZX_DWR, // external floppy controller addon which would have connected to the expansion port on these computers.
    input ZX_MTR, /* Since the gate array is the same on all three machines, all the decoding logic is already present to generate
                     the disk read/write and motor control signals. These three signals are therefore connected through to
                     the expansion port. These signals occupy the pins which were originally used for the component video
                     signals on the 16k/48k expansion port.
                   */


    // RPi0
    input PI_SPI_CK,
    input PI_SPI_CE0,
    input PI_SPI_MOSI,
    output PI_SPI_MISO,

    inout PI_GPIO1,
    inout PI_GPIO2,
    inout PI_GPIO3,
    inout PI_GPIO4
    );

assign ZX_ROMCS = 0'bZ;

endmodule