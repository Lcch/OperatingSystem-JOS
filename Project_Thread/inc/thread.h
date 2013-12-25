#ifndef JOS_INC_THREAD_H
#define JOS_INC_THREAD_H

#include <inc/types.h>

typedef struct __pthread_mutex_t {
	uint32_t lock;
} pthread_mutex_t;

typedef struct __pthread_cond_t {
	uint32_t cond;
} pthread_cond_t;

#endif