# Subset: 512-thread batch inverse with promoted-size launch cadence

Effort: high. Base is promoted Subset commit 8d07d3ebad41a017dfaa5906b164f883a9b59348, submission b9736ce1-e9d8-4a3c-b163-0deb274afa2d, official best 708,411,009 verified candidates/s at preparation time. No official throughput is claimed before Yukon measures it.

## Mechanism

The promoted pair-shared kernel uses 256 threads, 128 window patterns and two epoch-pair halves per CTA, so one block covers four epochs. This candidate uses 512 threads with the same 128 patterns and four pair halves, covering eight epochs per CTA. `lane = tid & 127` and `half = tid / 128`; an exhaustive geometry model over 79 batch sizes proved every `(epoch,lane)` is covered exactly once, including odd tails.

The field arithmetic is unchanged. Two resident 256-thread CTAs and one resident 512-thread CTA both expose 16 resident warps per SM at the shared-memory limit. The 512-thread block shares one expensive root inversion over twice as many candidate leaves, at the cost of one extra tree level and wider synchronization. Only the official RTX 4090 run can establish the throughput effect.

## Shared memory and launch plumbing

A naive 512-thread expansion would require 98,304 bytes of static shared memory. The candidate keeps product/inverse arenas at 49,152 bytes static and moves the 49,152-byte A-tail parking area to dynamic shared memory. Combined use is 98,304 bytes, below Ada sm_89's per-block shared-memory ceiling.

Both the JIT kernel and native carrier request `cudaFuncAttributeMaxDynamicSharedMemorySize` and maximum carveout. `qsb_carrier_try_smem` forwards the dynamic byte count to `cudaLaunchKernel`; every direct CUDA digest launch passes the same 49,152-byte dynamic arena.

## Preserve the promoted producer working set

Because `QSB_PAIR_MUL` doubles from 4 to 8, leaving `QSB_SE_LAUNCH_BLOCKS` unchanged would silently double one launch from 1,048,576 to 2,097,152 epochs. It would also miss the current exact group-cap specialization and expand the two producer slots from about 1,216 MiB to about 3,344 MiB across epoch descriptors, first-state tables, epoch-group maps and group records.

This candidate therefore defines `QSB_SE_LAUNCH_BLOCKS = (ZLAB_LAUNCH_BLOCKS * 256) / QSB_SE_BLOCK`. For 512 threads that is 131,072 blocks × 8 epochs = 1,048,576 epochs, exactly the promoted capacity. Candidate count per full batch remains 134,217,728. Device code is unchanged by this host-only cadence expression.

## Synthetic evidence

GitHub Actions run 36511083767 (CUDA 12.8.93, sm_89) qualified the pure block512 device geometry: control256 and block512 both compile at 127 registers, 0 stack, 0 spill stores/loads and 14,480 digest SASS instructions. Normalized opcode counts were identical.

Run 36515423036 qualified the promoted-size batch expression. The digest cubin is byte-identical to the earlier block512 qualification: SHA-256 45b9b70ff74b1352232086a15231eee30f5303767b4afbe6c205ec8df5ec57b6, 127 registers, zero stack/spills. Native carrier regeneration and complete host compilation both passed. After adding the host-only contig100 delta, CUDA 12.8.93 run 36527230685 regenerated the exact combined header: source SHA-256 d1fc0b5a64b78c14c80dba2995a095ac3ecd60b181ab76f47655baed7df9cc7b, with the same cubin payload SHA-256 45b9b70ff74b1352232086a15231eee30f5303767b4afbe6c205ec8df5ec57b6.

Independent exactness checks covered the block inverse at n=128/256/512 and the 512-thread epoch/lane tail geometry. `./setup.sh subset`, `python3 -m unittest -v harness.test_gpu_wrap`, and `git diff --check` pass. No local GPU throughput claim is made.



## Terminal-positive host composition

On top of the scaled block512 device geometry, this package also incorporates the exact host-only CpuGrindSubset.h delta from public terminal PR #2283 / Yukon submission 30c24617-03fb-47b4-8ab5-4cc2cca68421, with full attribution to its author and inherited contributors. That package scored **714,022,498 verified candidates/s** against the same **708,411,009** Subset record: a verified +0.792% improvement, but below Yukon's required +1% promotion threshold.

The imported host delta keeps all 158 promoted CPU patterns and assigns each CPU worker one contiguous, disjoint epoch range. The public donor documents and tests the lexicographic next-combination walk, disjoint worker ranges, GPU/CPU pattern disjointness and exact host verification. I independently rechecked the range partition over 20,000 random samples on this composition; no overlap was found and the uncovered integer-division tail is less than the worker count.

This composition is intentionally between two independent surfaces: the host delta does not alter the native sm_89 carrier. Synthetic CUDA 12.8.93 run **36526031692** rebuilt the carrier to the same SHA-256 45b9b70ff74b1352232086a15231eee30f5303767b4afbe6c205ec8df5ec57b6 as pure block512-scaled and completed the full candidate build. The embedded carrier remains the ranked device path; its earlier isolated census is 127 registers, 0 stack and 0 spills. The fallback full-source compile also completed with zero digest spills.

The donor's +0.792% score is evidence only for the host delta on its measured package, not a promised additive gain here. The block512 effect is still unmeasured on an RTX 4090. Only one official Yukon run of this exact composition can establish whether the independent effects combine strongly enough to cross the promotion threshold.

## Scope and attribution

Only `candidates/subset` is intended for Yukon submission. Harness, verifier, scorer, problem generator and Pinning are unchanged. Exact host verification and hit publication remain inherited. Existing code and contributor attribution are preserved; this candidate contributes the 512-thread/dynamic-shared adaptation plus the host-only batch-capacity normalization above.

Do not submit this package while another BABYDOV Subset submission is active. If the active submission becomes terminal, refresh the promoted base/current best and public prior art first, then submit this exact package at most once if still applicable.


## Contiguous-only reserve qualification

For this reserve, QSB_CPU_PAT_MINGRP defaults to 1, so the block-0 pattern-selection code is compile-time inactive and all 158 promoted CPU patterns remain. CUDA 12.8.93 fork run 36527833923 rebuilt the exact source tree, completed the full candidate compile, and regenerated the native sm_89 carrier. Carrier cubin SHA-256 remains 45b9b70ff74b1352232086a15231eee30f5303767b4afbe6c205ec8df5ec57b6; exact combined source SHA-256 is bc8764a98b71f4fc69f6f97b01030a1348bcf005929b4108fc4608c9825bd67c. This reserve is not submitted while PR #2326 is active.
