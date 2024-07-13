#ifndef __PS_H__
#define __PS_H__

typedef enum {
  PS_OK,
  PS_ERR,
} ps_status_t;

void print_process_info(const char *pid);
ps_status_t ps();

#endif
