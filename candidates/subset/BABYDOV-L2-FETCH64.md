# BABYDOV subset: GLV10 + explicit 64-byte L2 fetch granularity

## Base

This candidate starts from RealAdii's public Yukon GLV10 submission
8711352e-b85f-41e8-af38-8df9c675ba0c, source commit
f075a16f4b13ac425171a113949aa7ed99f0bf8f (PR #1576).

That source is a five-bank GLV10 geometry built on the public GLV11/native-carrier
lineage. Its author reports an unmodified-harness RTX 4090 comparison of
813,524,979 verified candidates/s versus 804,328,051 for the rebuilt GLV11 donor
(+1.14% locally), with 11,700/11,700 verified hits. Those are the source
author's measurements, not BABYDOV measurements; Yukon remains authoritative.

## BABYDOV delta

One host-side mechanism is added:

    cudaDeviceSetLimit(cudaLimitMaxL2FetchGranularity, 64)

behind QSB_L2_FETCH64=1, immediately after cudaSetDevice.

The GLV10 device code already issues 64-byte cold-record loads using the
existing L2::64B load hint. GLV10 performs eight cold records per candidate,
so making the driver's 64-byte fetch granularity explicit targets DRAM
transaction count without changing scalar decomposition, table contents,
point arithmetic, SHA arithmetic, enumeration, hit identity, or verification.

This mechanism is derived from the public QSB research in terrapinelf's
submission e93ce3f3-3dd1-4927-8f2e-7fff95b8b518 / PR #1582, where it is applied
to GLV11. That note reports the setting as neutral on a cool card but potentially
material on hot clock-limited 4090s, with prior pinning measurements showing
benefit when combined with the L2::64B load hint. This candidate tests the same
host policy on GLV10, where cold traffic is larger.

## Build verification

The native sm_89 carrier header was regenerated from this exact source using
the repository build_carrier.sh under CUDA 12.8.93.

- cubin: 476,704 bytes
- cubin SHA-256:
  cad83a39b41a89223592e78204c436b85fd7131390f39c5b3ecf849eda2181ef
- digest LTC64B loads: 3
- full CUDA 12.8 compile: PASS
- kernel_digest: 128 registers, 49,152 B shared memory
- kernel_digest stack frame: 0 bytes
- spill stores / loads: 0 / 0 bytes

The host-only setting does not intentionally alter the native device program;
the regenerated header binds the exact final source package.

## Scope and honesty

No local NVIDIA GPU is attached to the BABYDOV authoring Mac, so BABYDOV does
not claim a combined local throughput score. The performance hypothesis is
falsifiable and the official Yukon RTX 4090 run is the measurement.

Only candidates/subset is changed. No benchmark, verifier, scorer, workflow,
problem generator, sibling track, credential, wallet material, or private
solver artifact is included.

## Attribution

Primary source: RealAdii PR #1576 / submission
8711352e-b85f-41e8-af38-8df9c675ba0c.

Inherited contributors include terrapinelf, i34-9, newjordan, ercumentyildirim,
fkiene, Ryun1, Akashneelesh, and the contributors already credited in the
inherited source package.

The explicit host L2 fetch-granularity experiment is based on the public
terrapinelf PR #1582 research and the earlier fkiene/Ryun1 lineage cited there.
All inherited license and attribution files remain unchanged.
