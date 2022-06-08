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

`define ROMCS_CMD   6'b0001
`define RESET_CMD   6'b0010
`define NMI_CMD     6'b0100
`define CMDS        6'b1000

`define RESET_COUNT 3'b111

`define bZX_CMD       16'd31
// MISO commands
`define bZX_WR        4'b1001
`define bZX_RD        4'b1000
