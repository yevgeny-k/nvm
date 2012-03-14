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
  
  Scodep production;
  Scodep streamingLOW;
};
