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

`define IDLE        16'hffff

`define EMPTY_CMD   16'h0200
`define ROMCS_CMD   16'h8200
`define NMI_CMD     16'h4200
`define BYTE_CMD    16'h0100

`define bZX_CMD     16'd31
`define NMI_ADDR    16'h0066

