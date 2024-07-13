#ifndef __STATH_
#define __STATH_

#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

typedef enum { STAT_OK, STAT_ERR } stat_res_t;

stat_res_t mstat(char *file);

#endif
