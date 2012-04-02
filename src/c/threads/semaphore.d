/* -*- mode: c; c-basic-offset: 8 -*- */
/*
    semaphore.d -- POSIX-like semaphores
*/
/*
    Copyright (c) 2011, Juan Jose Garcia Ripoll.

    ECL is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    See file '../Copyright' for full details.
*/

#define AO_ASSUME_WINDOWS98 /* We need this for CAS */
#include <ecl/ecl.h>
#include <ecl/internal.h>

#if !defined(AO_HAVE_fetch_and_add_full)
#error "Cannot implement semaphores without AO_fetch_and_add_full"
#endif

static ECL_INLINE void
FEerror_not_a_semaphore(cl_object semaphore)
{
        FEwrong_type_argument(@'mp::semaphore', semaphore);
}

cl_object
ecl_make_semaphore(cl_object name, cl_fixnum count)
{
	cl_object output = ecl_alloc_object(t_semaphore);
	output->semaphore.name = name;
	output->semaphore.counter = count;
	output->semaphore.queue_list = Cnil;
	output->semaphore.queue_spinlock = Cnil;
        return output;
}

@(defun mp::make-semaphore (&key name (count MAKE_FIXNUM(0)))
@
{
	@(return ecl_make_semaphore(name, fixnnint(count)))
}
@)

cl_object
mp_semaphore_name(cl_object semaphore)
{
	cl_env_ptr env = ecl_process_env();
	unlikely_if (type_of(semaphore) != t_semaphore) {
		FEerror_not_a_semaphore(semaphore);
	}
        ecl_return1(env, semaphore->semaphore.name);
}

cl_object
mp_semaphore_count(cl_object semaphore)
{
	cl_env_ptr env = ecl_process_env();
	unlikely_if (type_of(semaphore) != t_semaphore) {
		FEerror_not_a_semaphore(semaphore);
	}
	ecl_return1(env, MAKE_FIXNUM(semaphore->semaphore.counter));
}

cl_object
mp_semaphore_wait_count(cl_object semaphore)
{
	cl_env_ptr env = ecl_process_env();
	unlikely_if (type_of(semaphore) != t_semaphore) {
		FEerror_not_a_semaphore(semaphore);
	}
	ecl_return1(env, cl_length(semaphore->semaphore.queue_list));
}

@(defun mp::signal-semaphore (semaphore &optional (count MAKE_FIXNUM(1)))
@
{
	cl_fixnum n = fixnnint(count);
        cl_env_ptr env = ecl_process_env();
	cl_object own_process = env->own_process;
	unlikely_if (type_of(semaphore) != t_semaphore) {
		FEerror_not_a_semaphore(semaphore);
	}
	AO_fetch_and_add((AO_t*)&semaphore->semaphore.counter, 1);
	while (n-- && semaphore->semaphore.queue_list != Cnil) {
		ecl_wakeup_waiters(env, semaphore, ECL_WAKEUP_ONE);
	}
        @(return)
}
@)

static cl_object
get_semaphore_inner(cl_env_ptr env, cl_object semaphore)
{
	cl_fixnum counter;
	cl_object output;
	ecl_disable_interrupts_env(env);
	if ((counter = semaphore->semaphore.counter) &&
	    AO_compare_and_swap_full((AO_t*)&(semaphore->semaphore.counter),
				     (AO_t)counter, (AO_t)(counter-1))) {
		output = Ct;
	} else {
		output = Cnil;
	}
	ecl_enable_interrupts_env(env);
	return output;
}

cl_object
mp_wait_on_semaphore(cl_object semaphore)
{
        cl_env_ptr env = ecl_process_env();
	unlikely_if (type_of(semaphore) != t_semaphore) {
		FEerror_not_a_semaphore(semaphore);
	}
	if (get_semaphore_inner(env, semaphore) == Cnil) {
		ecl_wait_on(env, get_semaphore_inner, semaphore);
	}
	@(return Ct)
}
