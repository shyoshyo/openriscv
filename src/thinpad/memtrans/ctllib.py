#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: ctllib.py
# $Date: Tue Nov 26 09:52:17 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import sys
import os

CMD_FLASH_WRITE	= chr(0b01110000)
CMD_FLASH_READ	= chr(0b00001111)
CMD_FLASH_ERASE	= chr(0b00111000)
CMD_RAM_WRITE	= chr(0b11110011)
CMD_RAM_READ	= chr(0b10010011)
CMD_ERASE_IN_PROGRESS	= chr(0b11001100)
CMD_ERASE_FINISHED		= chr(0b00110011)
CMD_JMP_TO_ADDR = chr(0b11111111)

FLASH_ADDR_SIZE = 22
CHEKSUM_INIT = 0x23

class ChecksumVerifyError(Exception):
    pass


class MemtransController(object):
    ser = None
    checksum = 0

    def __init__(self, ser):
        self.ser = ser

    if os.getenv('SINGLESTEP'):
        def _do_write_data(self, data):
            for i in data:
                raw_input('write {}'.format(hex(ord(i))))
                self.ser.write(i)
    else:
        def _do_write_data(self, data):
            self.ser.write(data)

    def _raw_write(self, data):
        assert type(data) is str
        self._do_write_data(data)
        self._update_checksum(data)

    def _update_checksum(self, data):
        for i in data:
            self.checksum ^= ord(i)

    def _write_addr(self, addr):
        assert addr < (1 << FLASH_ADDR_SIZE)
        assert ((addr >> 16) & (~0xFF)) == 0, hex(addr)
        data = chr(addr & 0xFF) + chr((addr >> 8) & 0xFF) + chr(addr >> 16)
        self._raw_write(data)

    def _reset_checksum(self):
        self.checksum = CHEKSUM_INIT

    def _verify(self):
        get = self.ser.read(1)
        if get != chr(self.checksum):
            print>>sys.stderr, \
                    'checksum validation failed: expect={} got={}'.format(
                        hex(self.checksum), hex(ord(get)))
            raise ChecksumVerifyError()

    def _cmd(self, cmd, start_addr, end_addr):
        assert start_addr < end_addr or (
                cmd in (CMD_FLASH_ERASE, CMD_JMP_TO_ADDR)
                and start_addr == end_addr)
        self._raw_write(cmd)
        self._reset_checksum()
        self._write_addr(start_addr)
        self._write_addr(end_addr)
        self._verify()
        self._reset_checksum()

    def _perform_write(self, cmd, data, start_addr, addr_align):
        assert type(data) is str and type(start_addr) is int and \
                type(addr_align) is int and start_addr >= 0 and addr_align > 0
        data += '\xff' * ((addr_align - len(data) % addr_align) % addr_align)
        if start_addr % addr_align:
            print >> sys.stderr, 'address {} truncated'.format(hex(start_addr))
        start_addr /= addr_align
        self._cmd(cmd, start_addr, start_addr + len(data) / addr_align)
        self._raw_write(data)
        self._verify()

    def _perform_read(self, cmd, start_addr, size, addr_align):
        assert type(start_addr) is int and \
                type(size) is int and start_addr >= 0 and size > 0 and \
                addr_align > 0
        size += (addr_align - size % addr_align) % addr_align
        size /= addr_align
        if start_addr % addr_align:
            print >> sys.stderr, 'address {} truncated'.format(hex(start_addr))
        start_addr /= addr_align
        self._cmd(cmd, start_addr, start_addr + size)
        data = self.ser.read(size * addr_align)
        self._update_checksum(data)
        self._verify()
        return data

    def write_flash(self, data, start_addr):
        self._perform_write(CMD_FLASH_WRITE, data, start_addr, 2)

    def read_flash(self, start_addr, size):
        return self._perform_read(CMD_FLASH_READ, start_addr, size, 2)

    def erase_flash(self, addr):
        addr /= 2
        self._cmd(CMD_FLASH_ERASE, addr, addr)
        while True:
            rst = self.ser.read(1)
            if rst == CMD_ERASE_FINISHED:
                return
            if rst != CMD_ERASE_IN_PROGRESS:
                print >>sys.stderr, \
                    'unknown signal during erase: {:!r}'.format(rst)
                raise ChecksumVerifyError()

    def write_ram(self, data, start_addr):
        self._perform_write(CMD_RAM_WRITE, data, start_addr, 4)

    def read_ram(self, start_addr, size):
        return self._perform_read(CMD_RAM_READ, start_addr, size, 4)

    def jmp(self, addr):
        assert addr % 4 == 0
        addr /= 4
        self._cmd(CMD_JMP_TO_ADDR,  addr, addr)

