/* -*- Mode: C; c-basic-offset: 8; indent-tabs-mode: nil -*- */
/* vim: set filetype=c tabstop=8 shiftwidth=4 expandtab: */

#include <sys/times.h>
#include <sys/resource.h>

#ifdef __ZTC__
#define HZ 100
#endif

times(struct tms *x)
{ int hz;
  struct rusage ru;
  getrusage(RUSAGE_SELF,&ru);
  hz =  ru.ru_utime.tv_sec * HZ +
    (ru.ru_utime.tv_usec * HZ)/1000000;
  x->tms_utime = hz;
  x->tms_stime = hz;
  return 0;
}

