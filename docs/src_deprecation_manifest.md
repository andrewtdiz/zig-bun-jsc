# src Deprecation Manifest

| Path | Status | Rationale |
| --- | --- | --- |
| `src/.clang-format` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/ConfigVersion.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/Global.zig` | INVESTIGATE | Global exit/error helpers referenced throughout bun:ffi and host runtime. |
| `src/OutputFile.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/Progress.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/SignalCode.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/StaticHashMap.zig` | INVESTIGATE | Template used by bun hash maps referenced by ffi. |
| `src/Watcher.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/allocators` | INVESTIGATE | Allocator helpers may be reused when wiring bun.String + ffi. |
| `src/allocators.zig` | INVESTIGATE | Allocator entry-points for bun module; likely needed for ffi memory mgmt. |
| `src/asan-config.c` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/asan.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/ast.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/async` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/base64` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/bits.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/btjs.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/bun.js` | KEEP | JSC bindings + bun:ffi implementation; bridge depends on it. |
| `src/bun.js.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/bun.zig` | INVESTIGATE | Legacy bun namespace with String/Hash map types referenced by ffi.zig; needs auditing. |
| `src/c-headers-for-zig.h` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/cache.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/ci_info.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/collections` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/collections.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/compile_target.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/comptime_string_map.zig` | INVESTIGATE | CT string map utility used by bun.String tables. |
| `src/copy_file.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/crash_handler.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/csrf.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/darwin.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/defines-table.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/defines.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/deprecated.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/dir.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/dns.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/env.zig` | INVESTIGATE | Environment detection used by bun:ffi for pthread_jit toggles etc. |
| `src/env_loader.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/env_var.zig` | INVESTIGATE | Backing for Environment/feature flags referenced from ffi. |
| `src/errno` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/fd.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/feature_flags.zig` | INVESTIGATE | Feature flag plumbing still referenced via bun.Environment. |
| `src/generated_perf_trace_events.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/glob.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/handle_oom.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/heap_breakdown.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/highway.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/hmac.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/identity_context.zig` | INVESTIGATE | Hasher context for String maps used by ffi. |
| `src/import_record.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/ini.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/interchange.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/io` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/jsc_stub.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/linear_fifo.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/linker.lds` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/linker.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/linux.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/logger.zig` | INVESTIGATE | Low-level logging used by Output; required before pruning more. |
| `src/macho.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/memory.zig` | INVESTIGATE | Memory helpers used by allocator + future ffi bridging. |
| `src/meta` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/meta.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/open.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/output.zig` | INVESTIGATE | Original Output implementation; need to mine for logging semantics. |
| `src/patch.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/paths` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/paths.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/pe.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/perf.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/pool.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/ptr` | INVESTIGATE | Pointer helpers for bun.String/FFI conversions. |
| `src/ptr.zig` | INVESTIGATE | Pointer helpers for bun.String/FFI conversions. |
| `src/renamer.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/result.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/runtime.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/safety` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/safety.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/semver` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/semver.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/sha.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/sourcemap` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/string` | INVESTIGATE | Backing implementations for bun.String.* used throughout ffi. |
| `src/string.zig` | INVESTIGATE | Defines bun.String + helpers required by bun:ffi. |
| `src/symbols.def` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/symbols.dyn` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/symbols.txt` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/sys` | INVESTIGATE | OS shims (fcntl, signals) needed for dlopen/tinycc eventually. |
| `src/sys.zig` | INVESTIGATE | OS shims (fcntl, signals) needed for dlopen/tinycc eventually. |
| `src/sys_uv.zig` | INVESTIGATE | Libuv glue potentially reused for dynamic loading; needs review. |
| `src/system_timer.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/threading` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/threading.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/tmp.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/tracy.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/trait.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/tsconfig.json` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/unit_test.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/url.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/util.zig` | INVESTIGATE | Generic helpers referenced from bun.zig/ffi; audit before removal. |
| `src/vm` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/walker_skippable.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/watcher` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/which.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/which_npm_client.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/windows` | INVESTIGATE | Win32 shims required for bun:ffi dynamic library handling. |
| `src/windows.zig` | INVESTIGATE | Win32 shims required for bun:ffi dynamic library handling. |
| `src/work_pool.zig` | INVESTIGATE | Thread pool primitives referenced by bun.String/resident infra; audit later. |
| `src/workaround_missing_symbols.zig` | INVESTIGATE | Hacks for missing libc symbols; may resurface when bringing up ffi. |
| `src/wyhash.zig` | INVESTIGATE | Hash helper used by Bun maps consumed inside ffi. |
| `src/zlib.test.gz` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/zlib.test.txt` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |
| `src/zlib.zig` | REMOVE | Legacy Bun runtime feature (Node/Web/CLI) not needed for the minimal JSC↔Zig FFI layer. |