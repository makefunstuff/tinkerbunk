#include "cp.h"
#include "http.h"
#include "sh.h"
#include "stat.h"
#include "wc.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
  if (argc < 3) {
    return 1;
  }

  char *command = argv[1];

  if (command == NULL) {
    return 1;
  }

  if (strcmp(command, "cp") == 0) {
    char *src = argv[2];
    char *dst = argv[3];
    FileStatus status = copy_file(src, dst);
    if (status == READ_ERROR) {
      fprintf(stderr, "Error reading file: %s\n", src);
    } else if (status == WRITE_ERROR) {
      fprintf(stderr, "Error writing file: %s\n", dst);
    }
  } else if (strncmp(command, "wc", 2) == 0) {
    char *src = argv[2];
    int lines = count_lines(src);
    printf("%d\n", lines);
  } else if (strncmp(command, "sh", 2) == 0) {
    shell();
  } else if (strncmp(command, "stat", 4) == 0) {
    char *filename = argv[2];
    if (mstat(filename) == STAT_ERR) {
      return 1;
    }
  } else if (strncmp(command, "http", 4) == 0) {
    int port = atoi(argv[2]);
    start_server(port);
  }
}
