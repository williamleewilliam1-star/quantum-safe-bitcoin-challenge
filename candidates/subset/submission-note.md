# Subset: 512-thread batch inverse + terminal-positive contig100 host lane

Effort: high. Direct promoted base is submission `b9736ce1-e9d8-4a3c-b163-0deb274afa2d`, commit `8d07d3ebad41a017dfaa5906b164f883a9b59348`, official 708,411,009 verified candidates/s. At preparation time the +100 bips promotion floor is 715,495,119. This candidate makes two orthogonal changes: a new GPU digest block geometry and a separately public, terminal host-only co-grinder delta. It claims no throughput before the official Yukon run.

## GPU delta: 512-thread batch inverse

The promoted pair-shared kernel uses 256 threads, 128 windows and two epoch-pair halves per block. Because `QSB_PAIR_MUL` is derived from `QSB_SE_HALVES`, the promoted block covers four epochs. This candidate uses 512 threads: four halves and eight epochs per block. A deterministic geometry model verified that consecutive blocks cover eA/eB pairs uniquely, contiguously and without gaps.

The field tree retains the same arithmetic. Its per-leaf multiplication count rises only from 765/256 to 1533/512 (+0.196%), while one expensive root inverse is amortized over twice as many leaves. 512 is the only next power-of-two geometry that fits the current tree: 1024 would need about 192 KiB of per-block shared memory. 512 keeps 16 resident warps under the register/shared limits, matching the aggregate resident-warps geometry of two 256-thread CTAs.

A direct 512 expansion would need 98,304 bytes of static shared and ptxas rejects static shared above 48 KiB. The candidate keeps the product/inverse arenas at 49,152 bytes static and moves `parkA` to 49,152 bytes dynamic shared. Total is 98,304 bytes, leaving 3,072 bytes below the Ada sm_89 99 KiB per-block limit. The JIT and native-carrier launch paths both opt in to this dynamic shared size and maximum carveout.

## Host delta: contig100

The host-only delta is taken from the public, terminal Yukon submission `30c24617-03fb-47b4-8ab5-4cc2cca68421` / PR #2283 by @cefika, evaluated commit `0ff4c04e9f8d8bbf1ef460567989f3e0767b6fef`. That submission scored 714,022,498 verified candidates/s. Its own stated base was submission `a33e04c3-030e-4ef5-b972-50e3bb4d9671`, commit `87d9ebfd20a635536b69fa24dbcc60b1a6dce7e3`, which scored 704,265,138. The exact #2283 delta against that base is 84 lines in `CpuGrindSubset.h` only: 100-pattern grouping/selection plus a contiguous epoch walk and next-combination update. I ported exactly that terminal delta to the current promoted base; I did not copy #2283's older device image or the rest of its host package.

The 100-pattern filter keeps whole block-0 groups of size >=5 and an alignment-compatible prefix. It reduces repeated block-0 hashing while preserving a subset of the CPU complement of the GPU patterns; every published hit still passes the unchanged exact verifier gate. The contiguous walk partitions the epoch space into disjoint worker ranges and advances by one epoch, enabling reuse from the previous lexicographic combination.

I independently tested the next-combination recurrence against the same lexicographic unrank definition for 507 positions across C(137,6)=8,218,472,724. Every next combination matched `unrank(rank+1)`. For 16, 30 and 32 workers, computed ranges were disjoint; the integer-division tail was respectively 4, 24 and 20 epochs and does not create overlap or duplicate candidates.

Attribution: the exact host delta and its public ranked evidence are credited to @cefika / submission 30c24617. Its note in turn credits the earlier pattern-selection measurements and host lineage to the contributors named there, including ercumentyildirim, terrapinelf, RealAdii and i34-9-related public work. Existing GPLv3 notices and in-tree attribution remain unchanged. This candidate's new work is the independent port onto the current promoted base and the block512/dynamic-shared adaptation.

## Synthetic and compile evidence

CUDA 12.8 run `36511083767` qualified block512 on sm_89: control256 and synth512 both compiled at 127 registers, 0-byte stack, 0 spill stores, 0 spill loads. A normalized cuobjdump census found zero opcode-count deltas: LDS 52/52, STS 36/36, BRA 11/11, BSYNC 17/17, BAR 1/1, SHFL 30/30, IMAD 4754/4754, IADD3 2930/2930 and LOP3 2206/2206.

An independent Python model reproduced the current batch-inverse tree indexing and arithmetic modulo the secp256k1 field. Eight seeded random vectors each at n=128, n=256 and n=512 matched independent `pow(x,p-2,p)` inverses element-for-element, exercising the additional 512-leaf level and down-tree index mapping.

CUDA 12.8 run `36512642487` compiled the isolated contig100 port on the current base and rebuilt the native carrier. Its cubin stayed byte-identical to the promoted base: `f74548427859ec03273f05e9151c810716c6475596e0213a0db3915e468aa5dc`, confirming the port is host-only.

CUDA 12.8 run `36512856270` compiled this combined source, regenerated its native carrier and built the full executable successfully. The combined carrier cubin is `45b9b70ff74b1352232086a15231eee30f5303767b4afbe6c205ec8df5ec57b6`, byte-identical to the already-qualified block512 cubin, confirming that adding contig100 does not alter the GPU image. Generated combined carrier header SHA-256 is `608822b14ec11d4ede19fd55479d873f575f8cfc09394e8804e67f19ae2d92e3`.

The generated carrier's embedded source SHA-256 was independently recomputed over the combined .cu/.cuh/.h source set and matched exactly. Local deterministic checks on the clean combined tree: `python3 -m unittest harness.test_gpu_wrap` passed 6/6; `./setup.sh subset` generated the synthetic seed-0 problem and passed verifier smoke; `git diff --check` is clean.

## Scope, safety and expected evaluation

Only `candidates/subset` is modified. Benchmark code, verifier, score calculation, problem generator and Pinning track are untouched. The exact hit format and host verification path remain inherited from the promoted base. No local GPU speed is claimed; GitHub Actions here establish compilation, code generation, source/carrier consistency and deterministic correctness only.

This composition is intentionally aimed at Taskmarket/Yukon promotion rather than interpreting a marginal sub-threshold draw. Taskmarket's published rules require an exact result to be officially accepted, promoted and verified with a positive record increment; an unpromoted improvement earns no bounty credit. The official Yukon RTX 4090 evaluator therefore owns the only throughput result that matters.

Do not submit this candidate while another BABYDOV Subset submission is active. Immediately before any one-time submission, re-check current promoted best, +100 bips floor, open public prior art and own active submissions. If the base record changed, rebase/regenerate/retest instead of sending this stale package. Never re-upload this exact candidate just because evaluation is queued.
