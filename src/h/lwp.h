/* -*- mode: c; c-basic-offset: 8 -*- */
/*
    lwp.h  -- Light weight processes.
*/
/*
    Copyright (c) 1990, Giuseppe Attardi.
    Copyright (c) 2015, Daniel Kochmański.

    ECoLisp is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    See file '../Copyright' for full details.
*/

#ifdef __cplusplus
extern "C" {
#endif

typedef struct lpd {
        /* this is basically env (right?) – compare sources */
} lpd;

enum {
        ECL_THREAD_RUNNING = 0,
        ECL_THREAD_SUSPENDED,
        ECL_THREAD_STOPPED,
        ECL_THREAD_DEAD,
        ECL_THREAD_WAITING,
        ECL_THREAD_DELAYED
};

typedef struct thread_desc {
        cl_object   thread;     /* point back to its thread */
        cl_index    status;     /* RUNNING or STOPPED or DEAD */
        int        *base;	/* Stack Base */
        sigjmp_buf  env;	/* Stack Environment */
        int         slice;      /* time out */
        FILE	   *input;      /* File pointer waiting input on */
        lpd        *lpd;        /* lisp process descriptor */
        struct thread_desc *next;
} thread_desc;

#ifdef __cplusplus
}
#endif
