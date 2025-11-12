ffi
The 'bun:ffi' module enables high-performance calls to native libraries from JavaScript. It works with languages that support the C ABI (Zig, Rust, C/C++, C#, Nim, Kotlin, etc).

Bun generates and just-in-time compiles C bindings that efficiently convert values between JavaScript types and native types, using embedded TinyCC (a small and fast C compiler). According to benchmarks, bun:ffi is roughly 2-6x faster than Node.js FFI via Node-API.

⚠️ Experimental — bun:ffi has known bugs and limitations, and should not be relied on in production. The most stable way to interact with native code from Bun is to write a Node-API module.

The bun:ffi module is defined across several files and directories in the Bun codebase:

## Core Implementation Files

### Primary Implementation:

- src/bun.js/api/ffi.zig - This is the main FFI implementation in Zig, containing the core logic for dlopen, symbol compilation, TinyCC integration, and callback handling ffi.zig:1-100
- src/js/bun/ffi.ts - The JavaScript/TypeScript wrapper layer that provides the user-facing API including FFI type mappings, dlopen, JSCallback, CString, ptr, and other utilities ffi.ts:1-50
- src/bun.js/api/FFI.h - C header file with type definitions and declarations used by the FFI system for JIT code generation FFI.h:1-50

### Module Registration:

- src/bun.js/HardcodedModule.zig - Registers bun:ffi as a hardcoded module in Bun's module system HardcodedModule.zig:6-7 HardcodedModule.zig:94-95

### Bindings Layer:

- src/bun.js/bindings/JSFFIFunction.cpp - C++ bindings for creating and managing FFI function objects in JavaScriptCore JSFFIFunction.cpp:1-50
- src/bun.js/bindings/ffi.cpp - Provides JSC offset calculations needed for FFI operations ffi.cpp:1-17
- src/bun.js/bindings/FFI.zig - Zig bindings translated from FFI.h for fast value conversions FFI.zig:1-3
- src/bun.js/api/ffi.classes.ts - Class definition for the FFI object exposed to JavaScript ffi.classes.ts:1-23

## Supporting Files

### Standard Library Headers for TinyCC:

The src/bun.js/api/ directory contains several ffi-std*.h header files that provide standard C library definitions used during JIT compilation.

### Type Definitions

- src/bun.js/api/ffi.d.ts - TypeScript type definitions for the bun:ffi module API ffi.d.ts:1-19

### Test Files

- test/js/bun/ffi/ directory - Contains test files including ffi.test.js, cc.test.ts, ffi-error-messages.test.ts, and various C fixtures

## Notes

The implementation follows a layered architecture:

- Zig core (ffi.zig) handles the low-level FFI logic and TinyCC integration
- C++ bindings bridge JavaScriptCore with the Zig implementation
- JavaScript/TypeScript wrapper (ffi.ts) provides the high-level API that users interact with
- TinyCC is used to JIT-compile C wrapper functions that convert between JavaScript and native types
