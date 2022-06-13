/*
    Copyright (c) 2022, BogDan Vatra <bogdan@kde.org>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

`timescale 1ns / 1ns

`include "Interface0_defs.v"

`define MR_CLK  (1000/50)  //MHz
`define HMR_CLK  (500/50)  //MHz

`define SPI_CLK (1000/5)    //MHz
`define HSPI_CLK (500/5)    //MHz

`define ZX_CLK  (1000/3.5)  //MHz
`define HZX_CLK  (500/3.5)  //MHz

`define assert(val1, val2) \
        if (val1 !== val2) begin \
            $display("ASSERTION FAILED in %m: %b != %b", val1, val2); \
            $finish; \
        end

module Interface0_sim;

  // Inputs
  reg ZX_CLK;
  reg ZX_M1_n;
  reg ZX_MREQ_n;
  reg ZX_IORQ_n;
  reg ZX_RD_n;
  reg ZX_WR_n;
  reg [15:0] ZX_ADDR;
//  reg ZX_BUSACK_n;
//  reg ZX_DRD;
//  reg ZX_DWR;
//  reg ZX_MTR;
  reg PI_MASTER_CLK;
  reg SPI_CLK;
  reg SPI_MOSI;

  // Outputs
//  wire ZX_INT_n;
  wire ZX_NMI;
  wire ZX_WAIT_n;
  wire ZX_RESET_n;
//  wire ZX_BUSRQ_n;
  wire ZX_ROMCS;
//  wire ZX_ROMCS1;
//  wire ZX_ROMCS2;
  wire SPI_MISO;
  reg SPI_CS_n;

  // Bidirs
  wire [7:0] ZX_DATA;
//  wire PI_GPIO1;
//  wire PI_GPIO2;
//  wire PI_GPIO3;
//  wire PI_GPIO4;
  reg PI_RESET;


  // Instantiate the Unit Under Test (UUT)
  Interface0 uut (
    .ZX_CLK(ZX_CLK),
    .ZX_M1_n(ZX_M1_n),
    .ZX_MREQ_n(ZX_MREQ_n),
    .ZX_IORQ_n(ZX_IORQ_n),
    .ZX_RD_n(ZX_RD_n),
    .ZX_WR_n(ZX_WR_n),
    .ZX_ADDR(ZX_ADDR),
    .ZX_DATA(ZX_DATA),
//    .ZX_INT_n(ZX_INT_n),
    .ZX_NMI(ZX_NMI),
    .ZX_WAIT_n(ZX_WAIT_n),
    .ZX_RESET_n(ZX_RESET_n),
//    .ZX_BUSRQ_n(ZX_BUSRQ_n),
//    .ZX_BUSACK_n(ZX_BUSACK_n),
    .ZX_ROMCS(ZX_ROMCS),
//    .ZX_ROMCS1(ZX_ROMCS1),
//    .ZX_ROMCS2(ZX_ROMCS2),
//    .ZX_DRD(ZX_DRD),
//    .ZX_DWR(ZX_DWR),
//    .ZX_MTR(ZX_MTR),
    .PI_MASTER_CLK(PI_MASTER_CLK),
    .SPI_CLK(SPI_CLK),
    .SPI_CS_n(SPI_CS_n),
    .SPI_MOSI(SPI_MOSI),
    .SPI_MISO(SPI_MISO),
    .PI_RESET(PI_RESET)
//    .PI_GPIO1(PI_GPIO1),
//    .PI_GPIO2(PI_GPIO2),
//    .PI_GPIO3(PI_GPIO3),
//    .PI_GPIO4(PI_GPIO4)
  );

  reg [7:0] ZX_DATA_reg = 8'd0;
  reg [15:0] ioData = 16'd0;
  reg [7:0] rndVal = 0;

  reg [15:0] spiData = 16'h0000;
  reg setSpiData = 0;

  assign ZX_DATA = (!ZX_ROMCS && !ZX_WR_n && ZX_RD_n) ? ZX_DATA_reg : 8'bzzzzzzzz;
//  assign ZX_WAIT_n = setWait ? waitData : 1'bz;

  always #`HMR_CLK PI_MASTER_CLK = !PI_MASTER_CLK;
//  always #`ZX_CLK ZX_CLK = !ZX_CLK;

  reg waitTriggered = 0;
  always @(posedge ZX_WAIT_n) begin
    ZX_DATA_reg = ZX_DATA;
    waitTriggered = 1;
  end

  task z80ResetState;
  begin
      if (ZX_ADDR == `NMI_ADDR)
        nmiTriggered <= 0;
      ZX_M1_n <= 1;
      ZX_MREQ_n <= 1;
      ZX_IORQ_n <= 1;
      ZX_RD_n <= 1;
      ZX_WR_n <= 1;
  end
  endtask

  always @(negedge ZX_CLK) begin
    if (waitTriggered) begin
      waitTriggered = 0;
      z80ResetState();
    end
  end

  reg nmiTriggered = 0;
  always @(negedge ZX_NMI) nmiTriggered = 1;

  task doSpi(input reg[15:0] sendData, output reg[15:0] recvData);
  begin
    $display("Sending %b", sendData);
    while(!SPI_CS_n) #`HMR_CLK;
    SPI_CS_n = 0;
    repeat(16) begin
      SPI_MOSI = sendData[15];
      sendData = {sendData[14:0], 1'b0};
      #`HSPI_CLK SPI_CLK = 1;
      #`HSPI_CLK SPI_CLK = 0;
      recvData = {recvData[14:0], SPI_MISO};
    end
		SPI_CS_n = 1;
    $display("Received %b", recvData);
  end
  endtask

  task spiSendByte(input reg[7:0] data);
  begin
    doSpi(data | `BYTE_CMD, ioData);
    while (!ZX_WAIT_n) #`MR_CLK;
    `assert(ZX_DATA, data);
    while (!ZX_RD_n) #`MR_CLK;
  end
  endtask

  task z80M1(input reg[15:0] address);
  begin
    ZX_ADDR <= address;
    ZX_M1_n <= 0;
    ZX_MREQ_n <= 0;
    ZX_RD_n <= 0;
  end
  endtask

  task z80RdData(input reg[7:0] data);
  begin
    ZX_DATA_reg = data;
  end
  endtask;

  reg [7:0] z80Step = 0;
  task doZ80NextNegEdge();
    if (ZX_WAIT_n) begin
      if (nmiTriggered) begin
        z80M1(16'h0066);
      end else begin
        case (z80Step)
          08'h00: z80M1(16'h0000);
          08'h01: z80M1(16'h0001);
          08'h02: z80M1(16'h0002);
          08'h03: z80M1(16'h0003);
          08'h04: z80M1(16'h0004);
          08'h05: z80M1(16'h0005);
          08'h06: z80M1(16'h0006);
          08'h07: z80M1(16'h0007);
        endcase
      end
    end
  endtask

  task doZ80NextPosEdge();
  begin
    if (!ZX_ROMCS) begin
      case (z80Step)
        08'h00: z80RdData(8'hf3);
        08'h01: z80RdData(8'h11);
        08'h02: z80RdData(8'hff);
        08'h03: z80RdData(8'hff);
        08'h04: z80RdData(8'hc3);
        08'h05: z80RdData(8'hcb);
        08'h06: z80RdData(8'h11);
        08'h07: z80RdData(8'h00);
        08'h66: z80RdData(8'hf5);
      endcase
    end

    if (ZX_WAIT_n) begin
      if (z80Step < 08'h07)
        z80Step = z80Step + 1;
      else
        z80Step =  08'h00;
      z80ResetState;
    end
  end
  endtask

  reg spiBusy = 0;
  task sendSpiCmd(input reg [15:0] cmd);
  begin
    while(spiBusy) #`HMR_CLK;
    $display("%0t sending spi cmd %b", $time, cmd);
    spiData = cmd;
    setSpiData = 1;
    while (setSpiData) #`SPI_CLK;
    $display("%0t done sending spi cmd %b", $time, cmd);
  end
  endtask

  initial begin
    forever begin
    #`HZX_CLK ZX_CLK <= 1;
    doZ80NextNegEdge();
    #`HZX_CLK ZX_CLK <= 0;
    doZ80NextPosEdge();
    end
  end

  reg [15:0] zxCmd;
  initial begin
    forever begin
      #(2 * `SPI_CLK) ;
      spiBusy = 1;
      doSpi(setSpiData ? spiData : 16'h0000, zxCmd);
      if (~|zxCmd[15:14]) begin
        case (zxCmd)
          16'h0000: spiSendByte(8'hf3);
          16'h0001: spiSendByte(8'haf);
          16'h0002: spiSendByte(8'h11);
          16'h0003: spiSendByte(8'hff);
          16'h0004: spiSendByte(8'hff);
          16'h0005: spiSendByte(8'hc3);
          16'h0006: spiSendByte(8'hcb);
          16'h0007: spiSendByte(8'h11);
          16'h0066: spiSendByte(8'hbd);
        endcase
      end
      setSpiData <= 0;
      spiBusy = 0;
    end
  end

  initial begin
    // Initialize Inputs
    ZX_CLK = 0;
    ZX_M1_n = 1;
    ZX_MREQ_n = 1;
    ZX_IORQ_n = 1;
    ZX_RD_n = 1;
    ZX_WR_n = 1;
//    ZX_RFSH = 1;
//    ZX_HALT = 1;
    ZX_ADDR = 0;
//    ZX_BUSACK_n = 1;
//    ZX_DRD = 0;
//    ZX_DWR = 0;
//    ZX_MTR = 0;

    PI_MASTER_CLK = 0;
    SPI_CLK = 0;
    SPI_MOSI = 0;
    PI_RESET = 0;
    ZX_DATA_reg = 0;
    nmiTriggered = 0;

    // get ready to rumble !!!
    $stop;
    #100 sendSpiCmd(`ROMCS_CMD | `NMI_CMD);// pi sends romcs & nmi commands
    `assert(nmiTriggered, 1'b1);
    `assert(ZX_ROMCS, 1'b1);
    #(2 * `ZX_CLK)
    `assert(ZX_NMI, 1'bz);

    sendSpiCmd(`EMPTY_CMD);// reset romcs
    #(2 * `ZX_CLK) `assert(ZX_ROMCS, 1'bz);

    sendSpiCmd(`ROMCS_CMD);
    #`ZX_CLK  `assert(ZX_ROMCS, 1'b1);
    #(2 * `ZX_CLK)
    sendSpiCmd(`EMPTY_CMD);// reset romcs
    #(`ZX_CLK) `assert(ZX_ROMCS, 1'bz);

    #(2 * `ZX_CLK) sendSpiCmd(`NMI_CMD);// pi sends romcs & nmi commands
    #(2 * `ZX_CLK) `assert(ZX_ROMCS, 1'b1);
    #(2 * `ZX_CLK) sendSpiCmd(`EMPTY_CMD);// reset romcs
    #(2 * `ZX_CLK) `assert(ZX_ROMCS, 1'bz);
    $finish;
  end


endmodule
