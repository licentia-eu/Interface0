----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    11:35:16 04/01/2022
-- Design Name:
-- Module Name:    Interface0 - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Interface0 is
Port (
    ZX_CK : in  STD_LOGIC;  -- The CK signal, sometimes referred to as PHICPU or ΦCPU is available on Lower Pin 8.
                            -- This clock signal is generated by the ULA and is interrupted during contended memory access.
                            -- On the UK 128 the ULA clock pin is connected directly to the edge connector and is inverted by TR3 to drive the Z80.
                            -- On the +2 the ULA clock pin is inverted by a NOT gate to generate the clock for the Z80.
                            -- It is then inverted again by a second NOT gate to generate the edge connector CK.
                            -- The CK signal is NOT connected on the Investrónica ZX Spectrum 128.

    ZX_M1 : in  STD_LOGIC;  -- Machine Cycle One (output, active Low). M1, together with MREQ, indicates that the
                            -- current machine cycle is the op code fetch cycle of an instruction execution. M1, when
                            -- operating together with IORQ, indicates an interrupt acknowledge cycle.

    ZX_MREQ : in  STD_LOGIC;    -- Memory Request (output, active Low, tristate). MREQ indicates that the address
                                -- bus holds a valid address for a memory read or a memory write operation.

    ZX_IORQ : in  STD_LOGIC;    -- Input/Output Request (output, active Low, tristate). IORQ indicates that the lower
                                -- half of the address bus holds a valid I/O address for an I/O read or write operation. IORQ
                                -- is also generated concurrently with M1 during an interrupt acknowledge cycle to indicate
                                -- that an interrupt response vector can be placed on the data bus.

    ZX_RD : in  STD_LOGIC;  -- Read (output, active Low, tristate). RD indicates that the CPU wants to read data from
                            -- memory or an I/O device. The addressed I/O device or memory should use this signal to
                            -- gate data onto the CPU data bus.

    ZX_WR : in  STD_LOGIC;  -- Write (output, active Low, tristate). WR indicates that the CPU data bus contains
                            -- valid data to be stored at the addressed memory or I/O location

    ZX_RFSH : in  STD_LOGIC;    --  Refresh (output, active Low). RFSH, together with MREQ, indicates that the lower
                                -- seven bits of the system’s address bus can be used as a refresh address to the system’s
                                -- dynamic memories.

    ZX_ADDR : in  STD_LOGIC_VECTOR (15 downto 0);   -- Address Bus (output, active High, tristate). A15–A0 form a 16-bit Address Bus,
                                                    -- which provides the addresses for memory data bus exchanges (up to 64KB) and for I/O
                                                    -- device exchanges.

    ZX_DATA : inout  STD_LOGIC_VECTOR (7 downto 0); -- Data Bus (input/output, active High, tristate). D7–D0 constitute an 8-bit
                                                    -- bidirectional data bus, used for data exchanges with memory and I/O

    ZX_INT : out  STD_LOGIC;    -- Interrupt Request (input, active Low). An Interrupt Request is generated by I/O
                                -- devices. The CPU honors a request at the end of the current instruction if the internal soft-
                                -- ware-controlled interrupt enable flip-flop (IFF) is enabled. INT is normally wired-OR and
                                -- requires an external pull-up for these applications.

    ZX_NMI : out  STD_LOGIC;    -- Nonmaskable Interrupt (input, negative edge-triggered). NMI contains a higher
                                -- priority than INT. NMI is always recognized at the end of the current instruction,
                                -- independent of the status of the interrupt enable flip-flop, and automatically forces the
                                -- CPU to restart at location 0066h.

    ZX_HALT : out  STD_LOGIC;   -- HALT State (output, active Low). HALT indicates that the CPU has executed a
                                -- HALT instruction and is waiting for either a nonmaskable or a maskable interrupt (with
                                -- the mask enabled) before operation can resume. During HALT, the CPU executes NOPs to
                                -- maintain memory refreshes.

    ZX_WAIT : out  STD_LOGIC;   --  WAIT (input, active Low). WAIT communicates to the CPU that the addressed
                                -- memory or I/O devices are not ready for a data transfer. The CPU continues to enter a
                                -- WAIT state as long as this signal is active. Extended WAIT periods can prevent the CPU
                                -- from properly refreshing dynamic memory.

    ZX_RESET : out  STD_LOGIC;  -- Reset (input, active Low). RESET initializes the CPU as follows: it resets the
                                -- interrupt enable flip-flop, clears the Program Counter and registers I and R, and sets the
                                -- interrupt status to Mode 0. During reset time, the address and data bus enter a
                                -- high-impedance state, and all control output signals enter an inactive state. RESET must be
                                -- active for a minimum of three full clock cycles before a reset operation is complete.

    ZX_BUSRQ : out  STD_LOGIC;  --  Bus Request (input, active Low). Bus Request contains a higher priority than
                                --  NMI and is always recognized at the end of the current machine cycle. BUSREQ forces
                                --  the CPU address bus, data bus, and control signals MREQ, IORQ, RD, and WR to enter a
                                --  high-impedance state so that other devices can control these lines. BUSREQ is normally
                                --  wired OR and requires an external pull-up for these applications. Extended BUSREQ peri-
                                --  ods due to extensive DMA operations can prevent the CPU from properly refreshing
                                --  dynamic RAM

    ZX_BUSACK : in  STD_LOGIC;  --  Bus Acknowledge (output, active Low). Bus Acknowledge indicates to the
                                --  requesting device that the CPU address bus, data bus, and control signals MREQ, IORQ,
                                --  RD, and WR have entered their high-impedance states. The external circuitry can now
                                -- control these lines.

    -- 16K/48K/128K specific
    ZX_ROMCS : out  STD_LOGIC;  -- The ZX Spectrum 16K/48K, ZX Spectrum 128, and ZX Spectrum +2 provide ROMCS on lower pin 25.
                                -- By holding this pin high an external peripheral can prevent the Spectrum's ROM from driving the data bus,
                                -- and place its own ROM or RAM within the first 16K of the 64K memory space.

    -- +2A/2B, +3/3B specific
    ZX_ROMCS1 : out  STD_LOGIC; -- All the previous models of ZX Spectrum have a single ROM chip which could be disabled to facilitate paging
    ZX_ROMCS2 : out  STD_LOGIC; -- in external memory by pulling the ROMCS line high. The +2A/+3 and +3B however have two ROM chips and brings
                                -- them out to independent pins on the expansion port. The old ROMCS pin (Lower pin 25) is not used, and instead
                                -- Upper pin 4 and Lower pin 15 are used. These pins were both unused on the 128K, however Lower pin 15 was used
                                -- for composite video out on the 16K/48K.


    ZX_DRD : in  STD_LOGIC; -- Unlike the +3, the +2A and +2B have no floppy disc controller. Amstrad's original intention was to produce an
    ZX_DWR : in  STD_LOGIC; -- external floppy controller addon which would have connected to the expansion port on these computers.
    ZX_MTR : in  STD_LOGIC; -- Since the gate array is the same on all three machines, all the decoding logic is already present to generate
                            -- the disk read/write and motor control signals. These three signals are therefore connected through to
                            -- the expansion port. These signals occupy the pins which were originally used for the component video
                            -- signals on the 16k/48k expansion port.


    -- RPi0
    PI_CK: in  STD_LOGIC;
    PI_CE0: in  STD_LOGIC;
    PI_MOSI: in  STD_LOGIC;
    PI_MISO: out  STD_LOGIC;

    PI_GPIO1: inout  STD_LOGIC;
    PI_GPIO2: inout  STD_LOGIC;
    PI_GPIO3: inout  STD_LOGIC;
    PI_GPIO4: inout  STD_LOGIC
);
end Interface0;

architecture Behavioral of Interface0 is

begin

    ZX_ROMCS <= ZX_M1;
    
end Behavioral;