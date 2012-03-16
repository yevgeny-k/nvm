#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "core.h"
#include "manager.h"

void * managerserver (void *ptr)
{
  Scfg *cfg;
  cfg = (Scfg *) ptr;
  int sockfd;
  struct sockaddr_in addr;
  int client;
  char buffer[1024];
  char *reply = "{\"result\": \"ok\"}\n";  
  
  sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd < 0) {
    fprintf(stderr, "ERROR opening socket!\n");
    exit (EXIT_FAILURE);
  }
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons (cfg->socketport);
//  addr.sin_addr.s_addr = INADDR_ANY;
  
  if (inet_aton("127.0.0.1", &addr.sin_addr) == 0) {
    fprintf(stderr, "Address error!\n");
    exit (EXIT_FAILURE);
  }
  
  if (bind(sockfd, (const struct sockaddr *)&addr, sizeof(addr)) != 0) {
     fprintf(stderr, "Bind socket failed!\n");
     exit (EXIT_FAILURE);
  }
  
  listen(sockfd, 5);
  
  while (1)
  {
    socklen_t size = sizeof(addr);
    
    client = accept(sockfd, (struct sockaddr *)&addr, &size);
    if (client > 0)
    {
      memset(buffer, 0, sizeof(buffer));
      
      recv (client, buffer, sizeof(buffer), 0);
      send (client, reply, strlen(reply), 0);
      
      fprintf(stdout, "%s", buffer);
      close(client);
    }
  }
  close(sockfd);
}
