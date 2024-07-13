#include "cp.h"
#include <stdio.h>

FileStatus copy_file(char *src, char *dst) {

  FILE *source = fopen(src, "rb");
  if (!source) {
    return READ_ERROR;
  }

  FILE *destination = fopen(dst, "wb");
  if (!destination) {
    fclose(source);
    return WRITE_ERROR;
  }

  char buffer[1024];
  size_t bytes;

  while ((bytes = fread(buffer, 1, sizeof(buffer), source)) > 0) {
    fwrite(buffer, 1, bytes, destination);
  }

  fclose(source);
  fclose(destination);

  return WRITE_OK;
}
