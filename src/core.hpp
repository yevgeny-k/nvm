struct Scodep {
  int width;
  int height;
  int framerate;
  int audiorate;
  int audiochannels;
  int videoencbitrate;
  int audioencbitrate;
};

struct Scfg {
  char CDNserverIP[50];
  int CDNserverPort;
  
  char wfilepath[400];
  char logfile[400];
  int logpriority;
  char socketpath[400];
  int socketport;
  
  Scodep production;
  Scodep streamingLOW;
  log4cpp::Category *log;
};
