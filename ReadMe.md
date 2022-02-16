[![tested with sh, bash, dash, yash, ksh, mksh, oksh, zsh](https://github.com/jakwings/totp/actions/workflows/test.yml/badge.svg)](https://github.com/jakwings/totp/actions/workflows/test.yml)

The only dependencies are `cat`, `date` and `openssl`.

You are recommended to use it with `pass` from https://www.passwordstore.org/

For example, to get the token for two-factor authentication:

    # Usage: totp [server] [interval] [timestamp] < secret
    pass show otp/GitHub | totp GitHub

    # Run this at Fri Jan 1 00:00:00 UTC 2038 you'd get 846121.
    printf "%s" "base32-decoded secret" | base32 | totp GitHub 30 #2145916800

In the first example above, the second parameter "GitHub" is optional, and
defaults to "Google", since the Google Authenticator app has become the de
facto standard for such usage.

---

License:

*   totp : at the top of the source code (WTF)

*   totp.py : at the top of the source code (MIT)

*   other :

        This is free and unencumbered software released into the public domain.

        Anyone is free to copy, modify, publish, use, compile, sell, or
        distribute this software, either in source code form or as a compiled
        binary, for any purpose, commercial or non-commercial, and by any
        means.

        In jurisdictions that recognize copyright laws, the author or authors
        of this software dedicate any and all copyright interest in the
        software to the public domain. We make this dedication for the benefit
        of the public at large and to the detriment of our heirs and
        successors. We intend this dedication to be an overt act of
        relinquishment in perpetuity of all present and future rights to this
        software under copyright law.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
        EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
        MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
        IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
        OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
        ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
        OTHER DEALINGS IN THE SOFTWARE.

        For more information, please refer to http://unlicense.org/
