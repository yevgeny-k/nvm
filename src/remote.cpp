#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <pcrecpp.h>
#include <gst/gst.h>
#include <log4cpp/Category.hh>
#include "core.hpp"
#include "contentmodules/moduleclass.hpp"
#include "serverout.hpp"
#include "remote.hpp"

rmtdata *md = NULL;

bool wrk (httpcmd *cmd, char *reply)
{
  memset(reply, 0, sizeof(reply));
  
  md->log->debug("CMD: %s -> OBJ: %s", cmd->command, cmd->object);
  
  if        (!strcmp(cmd->command, "shutdown")) {
    g_main_loop_quit (md->mainloop);
    strcpy (reply, "{\"result\": \"ok\"}\n");
  } else if (!strcmp(cmd->command, "play")) {
    if        (!strcmp(cmd->object, "encodepipeline")) {
      md->enc->play ();
    } else if (!strcmp(cmd->object, "techpipeline")) {
      md->tech->play ();
    } else if (!strcmp(cmd->object, "videoplayer")) {
      md->player->play ();
    }
    strcpy (reply, "{\"result\": \"ok\"}\n");
  } else if (!strcmp(cmd->command, "pause")) {
    if        (!strcmp(cmd->object, "techpipeline")) {
      md->tech->pause ();
    } else if (!strcmp(cmd->object, "videoplayer")) {
      md->player->pause ();
    }
    strcpy (reply, "{\"result\": \"ok\"}\n");  
  } else if (!strcmp(cmd->command, "stop")) {
  
  
  }
  return true;
}

void * remoteserver (void *ptr)
{
  md = (rmtdata *) ptr;
  int sockfd;
  struct sockaddr_in addr;
  int client;
  char buffer[1024];
  char reply[1024];  
  bool loopw = true;
  httpcmd cmd;
  
  sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd < 0) {
    md->log->error("ERROR opening socket!");
    exit (EXIT_FAILURE);
  }
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons (md->cfg->socketport);
//  addr.sin_addr.s_addr = INADDR_ANY;
  
  if (inet_aton("127.0.0.1", &addr.sin_addr) == 0) {
    md->log->error("Address error!");
    exit (EXIT_FAILURE);
  }
  
  if (bind(sockfd, (const struct sockaddr *)&addr, sizeof(addr)) != 0) {
     md->log->error("Bind socket failed!");
     exit (EXIT_FAILURE);
  }
  
  listen(sockfd, 5);
  
  while (loopw)
  {
    socklen_t size = sizeof(addr);
    
    client = accept(sockfd, (struct sockaddr *)&addr, &size);
    if (client > 0)
    {
      memset(buffer, 0, sizeof(buffer));
      
      recv (client, buffer, sizeof(buffer), 0);
      if (parsecmd (&cmd, buffer)) {
        if (!strcmp(cmd.command, "shutdown") && !strcmp(cmd.object, "server") ) { loopw = false; }
        wrk(&cmd, reply);
      } else {
        strcpy (reply, "{\"result\": \"error\"}\n");
      }
      send (client, reply, strlen(reply), 0);
      md->log->debug("Close connection to client.");
      close(client);
    }
  }
  md->log->debug("Close socket.");
  close(sockfd);
}

bool parsecmd (httpcmd *cmd, char *buff)
{
	char pcmd[1024];
	char pobj[1024];
	char pdata[1024];
	
	memset(cmd->command,  0, sizeof(cmd->command));
	memset(cmd->object,   0, sizeof(cmd->object));
	memset(cmd->data,     0, sizeof(cmd->command));
  	
  if (!getRegExValue ("NVM-Command:\\s?(.*)\\s?", buff, pcmd))  return false;    
  strcpy (cmd->command, pcmd);
  if (!getRegExValue ("NVM-Object:\\s?(.*)\\s?", buff, pobj))  return false; 
  strcpy (cmd->object, pobj);
  if (!getRegExValue ("NVM-Data:\\s?(.*)\\s?", buff, pdata))  return false; 
  strcpy (cmd->data, pdata);
  return true;
}

bool getRegExValue(const char *pattern, const char *buff, char *val)
{
	pcre *re;
	pcre_extra *re_ext;
	const char *errstr;
	int errchar;
	int vector[1000];
	int vecsize = 1000;
	int pairs;
	const char *pcre_buff;
	
	memset(val, 0, sizeof (val));
	
	if((re = pcre_compile (pattern, PCRE_CASELESS | PCRE_UTF8, &errstr, &errchar, NULL)) == NULL)
	{
		md->log->error("PCRE-error: %s\nSymbol #%i\nPattern: %s", errstr, errchar, pattern);
		return false;
	} else {
		re_ext = pcre_study (re, 0, &errstr);
		pairs = pcre_exec(re, re_ext, buff, strlen(buff), 0, PCRE_NOTEMPTY, vector, vecsize);
		if (pairs <= 0) {
			pcre_free(re_ext);
			pcre_free(re);	
			return false;
		} 
		pcre_get_substring (buff, vector, pairs, 1, &pcre_buff);
		strcpy (val, pcre_buff);
		val[strlen(val)-1] = '\0';	
		pcre_free_substring(pcre_buff);
		pcre_free(re_ext);
		pcre_free(re);	
	  return true;
	}
}
