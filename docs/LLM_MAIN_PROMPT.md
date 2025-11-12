# Main Prompt: Deprecate Unneeded Files for a Minimal JSC-Zig Bridge

## Objective

Analyze the Bun codebase, specifically the `/src` directory and its subdirectories, to identify and deprecate all files and modules that are not essential for the core `bun:ffi` functionality and the JavaScriptCore (JSC) <-> Zig bidirectional bridge. The final goal is to create a minimal, cross-platform library for JSC and Zig interoperability.

## Context

Based on the analysis in `DISCUSSION.md` and `FFI.md`, the core components to **preserve** are:

1.  **JSC-Zig Bridge:**
    *   **Core Zig Bindings:** `jsc.zig`, `JSValue.zig`, `JSGlobalObject.zig`, `CallFrame.zig`, `JSObject.zig`, and other fundamental type wrappers in `src/bun.js/`.
    *   **C++ Bridge Layer:** The `extern "C"` functions, headers (`headers.h`), and C++ implementations (`bindings.cpp`) that connect Zig to JSC's C++ API.
    *   **JSC Initialization:** The minimal C++ code required to initialize the JSC VM.

2.  **FFI (`bun:ffi`) Functionality:**
    *   **Zig Implementation:** `src/bun.js/api/ffi.zig` (core logic).
    *   **C++ Bindings:** `src/bun.js/bindings/JSFFIFunction.cpp` and `src/bun.js/bindings/ffi.cpp`.
    *   **Headers & Type Definitions:** `src/bun.js/api/FFI.h` and related standard library headers for TinyCC.
    *   **TinyCC Integration:** The mechanism for JIT-compiling C bindings.

## Files and Modules to Deprecate

You must thoroughly investigate the `/src` directory and identify all files that can be removed. This includes, but is not limited to, functionality related to:

*   **Node.js Compatibility APIs:** All modules implementing Node.js built-ins (e.g., `fs`, `path`, `http`, `https`, `os`, `events`, etc.).
*   **Web APIs:** `fetch`, `Request`, `Response`, `URL`, `URLSearchParams`, `WebSocket`, etc.
*   **Runtimes and CLIs:** Bun's command-line interface, script runner, package manager (`bun install`), and test runner.
*   **Transpilers & Bundlers:** The TypeScript/JSX transpiler and the JavaScript bundler.
*   **SQL:** The `bun:sqlite` module and its dependencies.
*   **HTML/CSS Parsing:** The LoFi parser.
*   **High-Level Abstractions:** Any Bun-specific APIs that are not fundamental to the JSC-Zig interop layer.

## Incremental Task List

Follow this iterative process to achieve the deprecation goal:

1.  **Full Codebase Scan:** Recursively scan the entire `/src` directory and its subdirectories.
2.  **Categorize Files:** Create a manifest of all files, categorizing each as:
    *   `KEEP`: Essential for the JSC-Zig bridge or FFI.
    *   `REMOVE`: Clearly part of a deprecated feature (e.g., `src/bun.js/api/http.zig`).
    *   `INVESTIGATE`: Unsure of its dependencies or role; requires further analysis.
3.  **Initial Deprecation:** Begin by removing obvious, low-dependency files and modules categorized as `REMOVE`.
4.  **Build System Update:** For each set of removed files, update the `build.zig` files to exclude them from the compilation process. This is a critical step.
5.  **Dependency Analysis:** For files marked `INVESTIGATE`, trace their dependencies. If they are only required by files marked `REMOVE`, they can also be removed.
6.  **Iterative Refinement:** Continue removing files and updating the build system in small, verifiable steps. Focus on untangling dependencies to isolate the core bridge and FFI.
7.  **Final Cleanup:** Once only the `KEEP` files remain, perform a final review to ensure no dead code or dangling references exist. The build should be clean and produce a minimal library.

## Final Output

The process should result in a significantly smaller codebase and a `build.zig` configuration that compiles only the essential components for a lean, high-performance JSC-Zig FFI library.
