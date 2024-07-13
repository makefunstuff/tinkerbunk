#include "http.h"
#include <arpa/inet.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAX_QUEUE 3

void *handle_client(void *client_socket) {
  int sock = *(int *)client_socket;

  free(client_socket);

  char buffer[1024];
  int n;

  n = read(sock, buffer, sizeof(buffer) - 1);
  if (n < 0) {
    perror("read");
    close(sock);
    exit(1);
    return NULL;
  }

  buffer[n] = '\0';
  printf("Request: %s\n", buffer);

  const char *response = "HTTP/1.1 200 OK\r\n\r\nHello, World!";
  write(sock, response, strlen(response));
  close(sock);

  return NULL;
}

void start_server(int port) {
  int server_sock, client_sock, *new_sock;
  struct sockaddr_in server, client;

  socklen_t client_len = sizeof(client);
  pthread_t thread_id;

  server_sock = socket(AF_INET, SOCK_STREAM, 0);
  if (server_sock < 0) {
    perror("socket");
    exit(1);
  }

  server.sin_family = AF_INET;
  server.sin_port = htons(port);
  server.sin_addr.s_addr = htonl(INADDR_ANY);

  if (bind(server_sock, (struct sockaddr *)&server, sizeof(server)) < 0) {
    perror("bind");
    close(server_sock);
    exit(1);
  }

  listen(server_sock, MAX_QUEUE);

  printf("Server listening on port %d\n", port);

  while ((client_sock =
              accept(server_sock, (struct sockaddr *)&client, &client_len))) {
    new_sock = malloc(sizeof(int));
    *new_sock = client_sock;

    if (pthread_create(&thread_id, NULL, handle_client, (void *)new_sock) < 0) {
      perror("pthread_create");
      exit(1);
    }
  }

  if (client_sock < 0) {
    perror("accept");
    exit(1);
  }

  close(server_sock);
}
