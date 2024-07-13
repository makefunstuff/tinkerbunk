#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define MAXLINE 80

int shell() {
  char line[MAXLINE];
  char *args[MAXLINE / 2 + 1];
  int should_run = 1;

  while (should_run) {
    printf(">");
    fflush(stdout);

    if (!fgets(line, MAXLINE, stdin)) {
      break;
    }

    line[strlen(line) - 1] = '\0';

    int i = 0;
    args[i] = strtok(line, " ");
    while (args[i] != NULL) {
      i++;
      args[i] = strtok(NULL, " ");
    }

    if (args[0] == NULL) {
      continue;
    }

    if (strncmp(args[0], "exit", 4) == 0) {
      break;
    }

    pid_t pid = fork();
    if (pid < 0) {
      perror("fork");
      return 1;
    } else if (pid == 0) {
      if (execvp(args[0], args) == -1) {
        perror("execvp");
      }
      return 1;
    } else {
      wait(NULL);
    }
  }
}
