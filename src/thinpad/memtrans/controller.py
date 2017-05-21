#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: controller.py
# $Date: Fri Dec 13 18:11:25 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

from ctllib import MemtransController

DEVICE = 'COM4'

import serial
import sys
import os
import time

if os.getenv('DEVICE'):
    DEVICE = os.getenv('DEVICE')

CHUNKSIZE = 4096
FLASH_BLOCK_SIZE = 128 * 1024

class SpeedCalc(object):
    tot_len = None
    start_time = None
    done = 0

    def __init__(self, tot_len):
        self.tot_len = tot_len
        self.start_time = time.time()

    def trigger(self, delta):
        self.done += delta
        t = time.time() - self.start_time
        sys.stdout.write('{:.3f} KiB/sec; {:.2f}%; ETA: {:.3f}sec; passed: {:.3f}sec  \r'.format(
            self.done / t / 1024,
            float(self.done) / self.tot_len * 100,
            t * (self.tot_len - self.done) / self.done,
            t))
        sys.stdout.flush()

    def finish(self):
        sys.stdout.write('\n')

def parse_addr(addr):
    mul = 1
    addr = addr.lower()
    if addr.endswith('k'):
        mul = 1024
        addr = addr[:-1]
    elif addr.endswith('m'):
        mul = 1024 * 1024
        addr = addr[:-1]
    if addr.startswith('0x'):
        return int(addr[2:], 16) * mul
    if addr.startswith('0x'):
        addr = int(addr[2:], 16)
    else:
        addr = int(addr)
    return addr * mul

if __name__ == '__main__':
    if len(sys.argv) == 1:
        sys.exit('usage: {} [flash|ram read|write|erase] | [jmp <addr>]\n'.
                format(sys.argv[0]) +
                '  read: <start addr> <length> <output file>\n' +
                '  write: <start addr> <input file>\n' +
                '  erase: <start addr> <length>\n' +
                ' all addresses and lengths are measured in bytes')

    ser = serial.Serial(DEVICE, 115201,
            stopbits=2, parity=serial.PARITY_NONE, timeout=1)
    ctl = MemtransController(ser)

    if sys.argv[1] == 'jmp':
        addr = parse_addr(sys.argv[2])
        ctl.jmp(addr)
        sys.exit()

    module = sys.argv[1]
    assert module in ('flash', 'ram'), module

    function = sys.argv[2]
    assert function in ('read', 'write', 'erase'), function
    if module == 'ram':
        assert function != 'erase'

    args = sys.argv[3:]

    if module == 'flash':
        reader = ctl.read_flash
        writer = ctl.write_flash
    else:
        reader = ctl.read_ram
        writer = ctl.write_ram

    if function == 'read':
        offset, size = map(parse_addr, args[0:2])
        fout_path = args[2]
        speed = SpeedCalc(size)
        with open(fout_path, 'wb') as fout:
            for i in range(0, size, CHUNKSIZE):
                cur_size = min(CHUNKSIZE, size - i)
                fout.write(reader(offset, cur_size))
                offset += cur_size
                speed.trigger(cur_size)
        speed.finish()
    elif function == 'write':
        offset, fpath = parse_addr(args[0]), args[1]
        speed = SpeedCalc(os.stat(fpath).st_size)
        cnt = 0
        with open(fpath, 'rb') as fin:
            while True:
                data = fin.read(CHUNKSIZE)
                if not data:
                    break
                cnt += len(data)
                writer(data, offset)
                offset += len(data)
                speed.trigger(len(data))
        speed.finish()
        print '{} bytes written'.format(cnt)
    elif function == 'erase':
        start = parse_addr(args[0]) / FLASH_BLOCK_SIZE * FLASH_BLOCK_SIZE
        stop = start + \
            parse_addr(args[1]) / FLASH_BLOCK_SIZE * FLASH_BLOCK_SIZE
        for i in range(start, stop + 1, FLASH_BLOCK_SIZE):
            ctl.erase_flash(i)
            print 'erase {} finished'.format(hex(i))

