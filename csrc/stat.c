#include "stat.h"

stat_res_t mstat(char *file) {
  struct stat fileStat;

  if (stat(file, &fileStat) < 0) {
    return STAT_ERR;
  }

  printf("File Size: %ld bytes\n", fileStat.st_size);
  printf("Number of Links %ld\n", fileStat.st_nlink);
  printf("File inode: %ld\n", fileStat.st_ino);

  return STAT_OK;
}
