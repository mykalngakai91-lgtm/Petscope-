#include <orbis/libkernel.h>
#include <orbis/SystemService.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define PORT 1000
#define PAGE "/app0/assets/game/index.html"

static void send_all(int fd, const char *b, long n){
  long off = 0, r;
  while (off < n){ r = send(fd, b + off, n - off, 0); if (r <= 0) return; off += r; }
}

static void serve(int fd){
  char req[1024];
  int n = recv(fd, req, sizeof(req) - 1, 0);
  if (n <= 0) return;
  req[n] = 0;

  if (strstr(req, "favicon")){
    const char *h = "HTTP/1.1 204 No Content\r\nConnection: close\r\n\r\n";
    send_all(fd, h, strlen(h)); return;
  }

  FILE *f = fopen(PAGE, "rb");
  if (!f){
    const char *m = "HTTP/1.1 404 Not Found\r\nConnection: close\r\n\r\nmissing page";
    send_all(fd, m, strlen(m)); return;
  }

  fseek(f, 0, SEEK_END); long len = ftell(f); fseek(f, 0, SEEK_SET);
  char *buf = malloc(len);
  if (!buf){ fclose(f); return; }
  fread(buf, 1, len, f); fclose(f);

  char hdr[256];
  int hl = sprintf(hdr,
    "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n"
    "Content-Length: %ld\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n", len);
  send_all(fd, hdr, hl);
  send_all(fd, buf, len);
  free(buf);
}

int main(void){
  int s = socket(AF_INET, SOCK_STREAM, 0);
  if (s < 0) return 1;
  int one = 1;
  setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));

  struct sockaddr_in a;
  memset(&a, 0, sizeof(a));
  a.sin_family = AF_INET;
  a.sin_port = htons(PORT);
  a.sin_addr.s_addr = htonl(INADDR_LOOPBACK);

  if (bind(s, (struct sockaddr *)&a, sizeof(a)) < 0) return 1;
  if (listen(s, 8) < 0) return 1;

  sceSystemServiceLaunchWebBrowser("http://127.0.0.1:1000/", NULL);

  for (;;){
    int c = accept(s, NULL, NULL);
    if (c < 0) continue;
    serve(c);
    close(c);
  }
  return 0;
}
