#include "wc.h"
#include <stdio.h>

int count_lines(char *src) {
  FILE *file = fopen(src, "r");

  if (file == NULL) {
    return -1;
  }

  int lines = 0;
  char c;
  while ((c = fgetc(file)) != EOF) {
    if (c == '\n') {
      lines++;
    }
  }
  fclose(file);
  return lines;
}
