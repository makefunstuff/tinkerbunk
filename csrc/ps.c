#include "ps.h"
#include <ctype.h>
#include <dirent.h>
#include <stdio.h>
#include <string.h>

void print_process_info(const char *pid) {
  char path[256], line[256];
  FILE *status_file;

  snprintf(path, sizeof(path), "/proc/%s/status", pid);
  status_file = fopen(path, "r");
  if (!status_file) {
    return;
  }

  printf("Process ID: %s\n", pid);
  while (fgets(line, sizeof(line), status_file)) {
    if (strncmp(line, "Name:", 5) == 0 || strncmp(line, "State:", 6) == 0 ||
        strncmp(line, "PPid:", 5) == 0) {
      printf("%s", line);
    }
  }
  fclose(status_file);
  printf("\n");
}

ps_status_t ps() {
  DIR *proc_dir = opendir("/proc");
  struct dirent *entry;

  if (!proc_dir) {
    perror("opendir");
    return PS_ERR;
  }

  while ((entry = readdir(proc_dir))) {
    if (entry->d_type == DT_DIR && isdigit(entry->d_name[0])) {
      print_process_info(entry->d_name);
    }
  }

  closedir(proc_dir);
  return PS_OK;
}
