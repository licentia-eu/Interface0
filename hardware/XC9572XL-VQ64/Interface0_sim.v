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

module Interface0_sim;

  // Inputs
  reg ZX_CLK;
  reg ZX_M1;
  reg ZX_MREQ;
  reg ZX_IORQ;
  reg ZX_RD;
  reg ZX_WR;
  reg [15:0] ZX_ADDR;
//  reg ZX_BUSACK;
//  reg ZX_DRD;
//  reg ZX_DWR;
//  reg ZX_MTR;
  reg PI_MASTER_CLK;
  reg PI_IO_CLK;
  reg PI_MOSI;

  // Outputs
//  wire ZX_INT;
  wire ZX_NMI;
  wire ZX_WAIT;
  wire ZX_RESET;
//  wire ZX_BUSRQ;
  wire ZX_ROMCS;
//  wire ZX_ROMCS1;
//  wire ZX_ROMCS2;
  wire PI_MISO;
  wire PI_IO;

  // Bidirs
  wire [7:0] ZX_DATA;
//  wire PI_GPIO1;
//  wire PI_GPIO2;
//  wire PI_GPIO3;
//  wire PI_GPIO4;
//  wire PI_GPIO5;


  reg [7:0] ZX_DATA_reg = 8'd0;
  reg io = 1'b0;
  reg [15:0] io_data = 16'd0;
  reg [2:0] waitTime = 3'd0;
  integer misoLen = 0;

  // Instantiate the Unit Under Test (UUT)
  Interface0 uut (
    .ZX_CLK(ZX_CLK),
    .ZX_M1(ZX_M1),
    .ZX_MREQ(ZX_MREQ),
    .ZX_IORQ(ZX_IORQ),
    .ZX_RD(ZX_RD),
    .ZX_WR(ZX_WR),
    .ZX_ADDR(ZX_ADDR),
    .ZX_DATA(ZX_DATA),
//    .ZX_INT(ZX_INT),
    .ZX_NMI(ZX_NMI),
    .ZX_WAIT(ZX_WAIT),
    .ZX_RESET(ZX_RESET),
//    .ZX_BUSRQ(ZX_BUSRQ),
//    .ZX_BUSACK(ZX_BUSACK),
    .ZX_ROMCS(ZX_ROMCS),
//    .ZX_ROMCS1(ZX_ROMCS1),
//    .ZX_ROMCS2(ZX_ROMCS2),
//    .ZX_DRD(ZX_DRD),
//    .ZX_DWR(ZX_DWR),
//    .ZX_MTR(ZX_MTR),
    .PI_MASTER_CLK(PI_MASTER_CLK),
    .PI_IO_CLK(PI_IO_CLK),
    .PI_IO(PI_IO),
    .PI_MOSI(PI_MOSI),
    .PI_MISO(PI_MISO)
//    .PI_GPIO1(PI_GPIO1),
//    .PI_GPIO2(PI_GPIO2),
//    .PI_GPIO3(PI_GPIO3),
//    .PI_GPIO3(PI_GPIO4),
//    .PI_GPIO3(PI_GPIO5)
  );

  assign PI_IO = (PI_MOSI && !PI_MISO) ? io : 1'bz;
  assign ZX_DATA = (!ZX_WR && ZX_RD) ? ZX_DATA_reg : 8'bzzzzzzzz;

  always #437.5 PI_MASTER_CLK = !PI_MASTER_CLK;
  always #3500 ZX_CLK = !ZX_CLK;

  always @(negedge ZX_CLK) begin
    if (ZX_WAIT) begin
      if (waitTime != 3'd0) begin
        waitTime = waitTime - 1;
      end else begin
        ZX_M1 <= 1;
        ZX_MREQ <= 1;
        ZX_IORQ <= 1;
        ZX_RD <= 1;
        ZX_WR <= 1;
      end
    end
  end

  task mosiData(input integer data, input integer count);
  begin
    PI_MOSI <= 1;
    #1750;
    while(count) begin
        count = count - 1;
        io = data[count];
        #875 PI_IO_CLK = 1;
        #875 PI_IO_CLK = 0;
    end
    #875 PI_MOSI = 0;
  end
  endtask

  task misoData(output reg[15:0] readData, output integer misoLen);
  begin
    #1750
    readData <= 16'd0;
    misoLen <= 0;
    while (PI_MISO) begin
      PI_IO_CLK = 1;
      #875 PI_IO_CLK = 0;
      #875
      misoLen <= misoLen + 1;
      readData <= {readData[14:0], PI_IO};
    end
  end
  endtask

  task readFromAddress(input reg[15:0] address);
  begin
    waitTime <= 3'b001;
    ZX_ADDR <= address;
    ZX_M1 <= 0;
    ZX_MREQ <= 0;
    ZX_RD <= 0;
    #3500
    misoData(io_data, misoLen);
  end
  endtask


  initial begin
    // Initialize Inputs
    ZX_CLK = 0;
    ZX_M1 = 1;
    ZX_MREQ = 1;
    ZX_IORQ = 1;
    ZX_RD = 1;
    ZX_WR = 1;
//    ZX_RFSH = 1;
//    ZX_HALT = 1;
    ZX_ADDR = 0;
//    ZX_BUSACK = 1;
//    ZX_DRD = 0;
//    ZX_DWR = 0;
//    ZX_MTR = 0;

    PI_MASTER_CLK = 0;
    PI_IO_CLK = 0;
    PI_MOSI = 0;
    ZX_DATA_reg = 0;

    // get ready to rumble !!!
    #100 $stop;
    mosiData(`ROMCS_CMD | `RESET_CMD, 4);// send reset & romcs commands
    readFromAddress(16'd0);
    mosiData(8'b11001101, 8);
    #35000

    $display("t=%3d, %b %b",$time, io_data, ZX_ADDR);

    #100 $finish;
  end

endmodule
