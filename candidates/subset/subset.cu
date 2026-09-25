#define QSB_REDRAW_09241557 1   /* inert re-measurement tag; unreferenced */
#ifndef QSB_FKLEAN_TAG_0924
#define QSB_FKLEAN_TAG_0924 1 /* fk minus the IPC/pipe-routing switches */
#endif
#ifndef QSB_REMEASURE_TAG_0921R3
#define QSB_REMEASURE_TAG_0921R3 1 /* no-op: exact-source PR897 remeasurement */
#endif
/* Keep the paired SHA constant-block loop compact on the ranked PTX route. */
#define QSB_PAIR_SHA_UNROLL_CONST 0
#define QSB_SHA_FMA_ADD 1
#ifndef QSB_BABYDOV_REDRAW_20260925
#define QSB_BABYDOV_REDRAW_20260925 1 /* provenance-only; not referenced by candidate code */
#endif
/* BABYDOV: adapt the public shared-LUT root-inverse idea to the active
 * 32-lane QSB_INVERSE_LIMBS path.  Unlike PR #1560's 4-lane path, this
 * switch feeds zi_divstep30_column from block-shared memory. */
#ifndef QSB_LIMBS_LDS_LUT
#define QSB_LIMBS_LDS_LUT 1
#endif
#ifndef QSB_LIMBS_LDS_SYNC
#define QSB_LIMBS_LDS_SYNC 1
#endif
#include "tests/gpu_epochs/tree.cu"
