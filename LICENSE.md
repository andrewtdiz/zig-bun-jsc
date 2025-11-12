MIT License

Copyright (c) 2024 Zig ↔ JSC Bridge contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice (including the next
section) shall be included in all copies or substantial portions of the
Software.

## Third-Party Notices

This repository was forked from Bun and still contains code that interfaces
with WebKit’s JavaScriptCore (LGPL-2.0) and WTF layers. If you statically link
against JavaScriptCore you must comply with the LGPL: provide relinkable
object files for your application or otherwise satisfy the license terms.

Some directories still reference code derived from other open-source
projects (boringssl, mimalloc, zstd, zlib, etc.) even though most of those
systems have been deleted from the active build. Please consult the respective
project licenses before redistributing binaries that include those components.

## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
