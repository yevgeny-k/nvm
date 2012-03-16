struct httpcmd {
  char command[1024];
  char object[1024];
  char data[1024];  
};

struct mngdata {
  GMainLoop *mainloop;
  Scfg *cfg;
};

void * managerserver (void *ptr);
bool parsecmd (httpcmd *cmd, char *buff);
bool wrk (httpcmd *cmd, char *reply);
bool getRegExValue(const char *pattern, const char *buff, char *val);
