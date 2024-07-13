typedef enum { READ_ERROR, WRITE_ERROR, WRITE_OK } FileStatus;
FileStatus copy_file(char *src, char *dst);
