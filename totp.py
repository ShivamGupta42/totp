#!/usr/bin/env python

# The MIT License (MIT)
# =====================
#
# Copyright (c) 2019 Susam Pal https://github.com/susam/mintotp
# Copyright (c) 2022 Jak Wings https://github.com/jakwings/totp
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import base64, hmac, hashlib, struct, sys, time

def hotp(key, counter, digits=6, digest='sha1'):
    key = base64.b32decode(key.upper() + '=' * ((8 - len(key)) % 8))
    counter = struct.pack('>Q', counter)
    mac = hmac.new(key, counter, hashlib.__dict__[digest]).digest()
    if type(mac[-1]) == int:
        offset = mac[-1] & 0x0F
    else:
        offset = struct.unpack('>B', mac[-1])[0] & 0x0F
    binary = struct.unpack('>L', mac[offset:offset+4])[0] & 0x7FFFFFFF
    return str(binary)[-digits:].zfill(digits)

def totp(key, interval=30, now=time.time()):
    return hotp(key, int(now / interval), 6, 'sha1')

def main():
    args = [int(x) if x.isdigit() else x for x in sys.argv[1:]]
    for key in sys.stdin:
        print(totp(key.strip(), *args))

if __name__ == '__main__':
    main()
