/*
    ecl.h -- Main headers for development of ECL
*/
/*
    Copyright (c) 1984, Taiichi Yuasa and Masami Hagiya.
    Copyright (c) 1990, Giuseppe Attardi.

    ECoLisp is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    See file '../Copyright' for full details.
*/

#ifndef _MSC_VER
#include <sys/param.h>		/* includes <sys/signal.h> and <sys/types.h> */
#else
#include <limits.h>
#endif
#include <sys/types.h>		/* for EMX */
#include <stddef.h>
#include <stdio.h>
#include <stdarg.h>
#include <setjmp.h>
#if !defined(cygwin) && !defined(_MSC_VER)
#include <inttypes.h>
#endif
#ifdef _MSC_VER
typedef char int8_t;
typedef short int16_t;
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
#endif

#ifndef FIXNUM_BITS
#include <config.h>
#endif

#ifdef ECL_THREADS
# if defined(_MSC_VER) || defined(mingw32)
#  include <windows.h>
   typedef HANDLE pthread_t;
   typedef HANDLE pthread_mutex_t;
#  undef ERROR
#  ifdef GBC_BOEHM
#   define CreateThread GC_CreateThread
#  endif
# else
#  include <pthread.h>
# endif
# define start_critical_section()
# define end_critical_section()
#else
# define start_critical_section()
# define end_critical_section()
#endif

#ifdef WITH_GMP
#include <gmp.h>
#endif /* WITH_GMP */
#include <object.h>
#include <stacks.h>
#ifndef _ARGS
# define _ARGS(x) x
#endif
#ifdef GBC_BOEHM
# include <gc.h>
#endif
#include <external.h>
/*#include "ecl-inl.h"*/
#include <eval.h>
#include <number.h>
#ifdef LOCATIVE
#include <unify.h>
#endif

typedef void (*ecl_init_function_t)(cl_object block);
