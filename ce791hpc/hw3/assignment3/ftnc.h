#if IBM || CONVEX
#define FTN(name) name
#else
#define FTN(name) name ## _
#endif
