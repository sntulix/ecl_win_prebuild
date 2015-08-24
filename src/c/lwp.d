/* -*- mode: c; c-basic-offset: 8 -*- */
/*
    lwp.d -- Light weight processes.
*/
/*
    Copyright (c) 1990, Giuseppe Attardi.
    Copyright (c) 2001, Juan Jose Garcia Ripoll.
    Copyright (c) 2015, Daniel Kochmański.

    ECL is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    See file '../Copyright' for full details.
*/

#include <ecl/ecl.h>

thread_desc *
make_thread_desc (cl_object thread) {
        thread_desc *desc;

        desc = (thread_desc *)malloc(sizeof(thread_desc));
        desc->thread = thread;
        desc->status = ECL_THREAD_SUSPENDED;
        desc->base = NULL;
        /* desc->env = ??; */
        desc->slice = 0;
        desc->input = NULL;
        desc->lpd = NULL;
        desc->next = NULL;
}

cl_object
si_make_thread (cl_object fun) {
        cl_object x;

        if (cl_functionp(fun) == ECL_NIL)
                FEwrong_type_argument(@'function', fun);

        x = ecl_alloc_object(t_thread);
        x->thread.entry = fun;
        x->thread.cont = ECL_NIL;
        x->thread.data = make_thread_desc(x);
        return x;
}

cl_object
si_make_continuation (cl_object thread) {
        cl_object x;

        if (type_of(thread) != t_thread)
                FEwrong_type_argument(@'ext::thread', thread);

        x = ecl_alloc_object(t_cont);
        x->cont.thread = thread;
        x->cont.resumed = FALSE;
        x->cont.timed_out = FALSE;

        thread->thread.cont = x;
        return x;
}
