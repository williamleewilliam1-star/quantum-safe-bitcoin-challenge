# Subset: 512-thread batch-inverse block with dynamic A-tail parking

Effort: high. Base is promoted Subset commit 8d07d3ebad41a017dfaa5906b164f883a9b59348, submission b9736ce1-e9d8-4a3c-b163-0deb274afa2d, official best 708,411,009 verified candidates/s at preparation time. This candidate changes only digest block geometry, shared-memory placement required by that geometry, native-carrier launch plumbing, and the regenerated sm_89 carrier. No official throughput is claimed before Yukon measures it.

## Mechanism

The promoted pair-shared kernel uses 256 threads, 128 windows and two epoch-pair halves per block. QSB_PAIR_MUL is derived from QSB_SE_HALVES, so the promoted block covers four epochs. This candidate uses 512 threads: four halves and therefore eight epochs per block. A deterministic geometry check over consecutive blocks confirms the eA/eB mapping remains contiguous, unique and gap-free.

The batch-inverse tree keeps the same field arithmetic per candidate. Going from two resident 256-thread CTAs to one 512-thread CTA keeps 16 resident warps per SM under the shared-memory limit while amortizing the expensive root inversion over twice as many leaves. The trade-off is one additional tree level and wider block synchronization; only the official RTX 4090 run can determine the net effect.

## Shared-memory layout and launch

A direct 512-thread expansion would require 98,304 bytes of static shared memory and ptxas rejects it because the static per-block limit is 48 KiB. The candidate keeps product/inverse arenas at 49,152 bytes static and moves parkA to 49,152 bytes dynamic shared memory. Combined use is 98,304 bytes, below Ada sm_89's 99 KiB per-block shared-memory ceiling.

The host sets cudaFuncAttributeMaxDynamicSharedMemorySize and maximum shared-memory carveout for both the JIT digest kernel and native carrier. The carrier launch helper accepts a dynamic-shared byte count and passes it to cudaLaunchKernel; the direct CUDA fallback launches with the same byte count. All digest launch sites reserve the same dynamic arena.

## Synthetic evidence

GitHub Actions run 36511083767 used nvidia/cuda:12.8.1-devel-ubuntu22.04 / nvcc 12.8.93. Both promoted 256-thread control and 512-thread candidate compiled at 127 registers, 0-byte stack, 0 spill stores, 0 spill loads, and 14,480 digest SASS instructions. Candidate resource report shows 49,152 bytes static shared memory.

The same run regenerated the native sm_89 carrier and compiled the complete host executable successfully. Carrier cubin SHA-256: 45b9b70ff74b1352232086a15231eee30f5303767b4afbe6c205ec8df5ec57b6. Generated header SHA-256: 9f670ed9a9358142acc86eb7f1f649cabab6a02c8b22fa7f55eb0532620a8c44. The generated header's source SHA-256 was independently recomputed from current .cu/.cuh/.h inputs and matched exactly.

Local deterministic checks: python3 -m unittest harness.test_gpu_wrap passed 6/6; ./setup.sh subset generated the synthetic seed-0 problem and passed the verifier smoke test; git diff --check is clean. No local GPU throughput claim is made.

An independent Python model reproduced the current batch-inverse tree indexing and arithmetic modulo the secp256k1 field for power-of-two leaf counts. Eight seeded random vectors each at n=128, n=256 and n=512 matched independent pow(x,p-2,p) inverses element-for-element. This specifically exercises the additional 512-leaf tree level and the down-tree index mapping; it is an exactness test, not a throughput simulation.

## Scope and attribution

Only candidates/subset is intended for submission. Protected benchmark, verifier, score calculation, problem generator and Pinning files are unchanged. Exact host verification, hit format and acceptance logic remain inherited from the promoted source. Existing native-carrier/search implementation retains its original licenses and contributor attribution; this candidate adds only the 512-thread/dynamic-shared adaptation described above.

The candidate must not be submitted while another BABYDOV Subset submission is active. If the active submission becomes terminal, this package is eligible for one Yukon submission and must never be duplicated unchanged. The official evaluator owns validity, verified score and promotion decision.
