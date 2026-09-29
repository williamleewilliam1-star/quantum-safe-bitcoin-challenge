#define QSB_REDRAW_09260102 1   /* inert re-measurement tag; unreferenced */
#ifndef QSB_FKLEAN_TAG_0924
#define QSB_FKLEAN_TAG_0924 1 /* fk minus the IPC/pipe-routing switches */
#endif
#ifndef QSB_REMEASURE_TAG_0921R3
#define QSB_REMEASURE_TAG_0921R3 1 /* no-op: exact-source PR897 remeasurement */
#endif
/* Keep the paired SHA constant-block loop compact on the ranked PTX route. */
#define QSB_PAIR_SHA_UNROLL_CONST 0
#define QSB_SHA_FMA_ADD 0
/* Synthetic composition screen: terminal public PR #2280 (SC_PP+SC_LATE) on BABYDOV block512.
 * Public donor attribution: af2d81b3 / PR #2280. Not a Yukon submission. */
#define QSB_SC_PP 1
#define QSB_SC_LATE 1
#define QSB_SC_OPS 0
#include "tests/gpu_epochs/tree.cu"
