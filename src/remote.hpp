struct httpcmd {
  char command[1024];
  char object[1024];
  char data[1024];  
};

struct rmtdata {
  GMainLoop *mainloop;
  Scfg *cfg;
  log4cpp::Category *log;
  
  CNVM_Serverout  *enc;
  CContentModule  *tech;
  CContentModule  *player;
};

void * remoteserver (void *ptr);
bool parsecmd (httpcmd *cmd, char *buff);
bool wrk (httpcmd *cmd, char *reply);
bool getRegExValue(const char *pattern, const char *buff, char *val);
