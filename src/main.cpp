/* NewVideoMixer
 *
 * Copyright (C) <2012> Communist Party of the Russian Federation <adm@kprf.ru>
 *
 * Version: 1.2 (15/03/2012)
 *
 * Main module
 */

#include <stdio.h>
#include <string.h>
#include <gst/gst.h>
#include <libxml++/libxml++.h>
#include <libxml++/parsers/textreader.h>
#include <iostream>
#include <pthread.h>
#include "core.hpp"
#include "moduleclass.hpp"
#include "serverout.hpp"
#include "videoplayer.hpp"
#include "techsplash.hpp"
#include "manager.hpp"

Scfg * loadConfig (char *p);
void printConfig (Scfg *cfg);

int main (int argc, char * argv[])
{
  GMainLoop *mainloop = NULL;
  Scfg *cfg;
  pthread_t mngserver;
  int  mngserverret;
  
  CNVM_Techsplash *techsplash;
  CNVM_Videoplayer *player;
  CNVM_Serverout *server;
  
  mngdata md;
  
  fprintf (stdout, "Start...");  
  fflush (stdout);
  gst_init (&argc, &argv);  
  mainloop = g_main_loop_new (NULL, TRUE);
  cfg = loadConfig("/home/kozin/dev/nvm/bin/config.xml");
  
  if (!cfg) {
     fprintf(stderr, "Error: Can not loading configure file! Exit.\n");
     fflush (stderr);
     exit (EXIT_FAILURE);
  }
  
  
  server = new CNVM_Serverout (cfg);
  techsplash = new CNVM_Techsplash (cfg);
  player = new CNVM_Videoplayer (cfg);
  
  fprintf (stdout, "OK\n");
  fflush (stdout);
  printConfig (cfg);   
  
  md.mainloop = mainloop;
  md.cfg = cfg;
  md.enc = server;
  md.tech = techsplash;
  md.player = player;
  fprintf (stdout, "Start manager server...");
  fflush (stdout);
  mngserverret = pthread_create (&mngserver, NULL, managerserver, &md);
  /*fprintf(stdout, "%d", mngserverret);
  if (!mngserverret) {
     fprintf(stderr, "Error: Can not start manager server! Exit.\n");
     exit(1);
  }*/
  fprintf (stdout, "OK\n");
  fflush (stdout);
  
  /*fprintf(stdout, "Play\n");
  server->play ();
  techsplash->play ();*/
  
  g_main_loop_run (mainloop);
  
  
  fprintf (stdout, "Free...\n");
  fflush (stdout);
    delete player;
    delete techsplash;
    delete server;
    delete cfg;
  fprintf (stdout, "OK\n");
  fprintf (stdout, "End.\n");
  fflush (stdout);
  exit (EXIT_SUCCESS);
}

Scfg * loadConfig(char *p)
{
  const char *nodename, *attributename, *codename;
  xmlpp::TextReader reader(p);
  
  Scfg *cfg;  
  cfg = new Scfg;
  
  while(reader.read())
  {  
      nodename = reader.get_name().c_str();
      if (!strcmp ("wfile", nodename)) { if(reader.has_attributes()) { reader.move_to_first_attribute();
          do { attributename = reader.get_name().c_str();
            if (!strcmp ("path", attributename)) { strcpy (cfg->wfilepath, reader.get_value().c_str()); }
          } while(reader.move_to_next_attribute());
      reader.move_to_element(); }  }

      if (!strcmp ("socket", nodename)) { if(reader.has_attributes()) { reader.move_to_first_attribute();
          do { attributename = reader.get_name().c_str();
            if (!strcmp ("path", attributename)) { strcpy (cfg->socketpath, reader.get_value().c_str()); }
            if (!strcmp ("port", attributename)) { cfg->socketport = atoi(reader.get_value().c_str()); }
          } while(reader.move_to_next_attribute());
      reader.move_to_element(); }  }      
      
      if (!strcmp ("cdnserver", nodename)) { if(reader.has_attributes()) { reader.move_to_first_attribute();
          do { attributename = reader.get_name().c_str();
            if (!strcmp ("ip", attributename)) { strcpy (cfg->CDNserverIP, reader.get_value().c_str()); }
            if (!strcmp ("port", attributename)) { cfg->CDNserverPort = atoi(reader.get_value().c_str()); }
          } while(reader.move_to_next_attribute());
      reader.move_to_element(); }  }

      if (!strcmp ("codeparam", nodename)) { if(reader.has_attributes()) { reader.move_to_first_attribute();
          do { attributename = reader.get_name().c_str();
            if (!strcmp ("usefor", attributename)) {
              codename = reader.get_value().c_str();
              reader.move_to_first_attribute();
              if (!strcmp ("production", codename)) {
                do { attributename = reader.get_name().c_str();
                 if (!strcmp ("width", attributename)) { cfg->production.width = atoi(reader.get_value().c_str()); }
                 if (!strcmp ("height", attributename)) { cfg->production.height = atoi(reader.get_value().c_str()); }  
                 if (!strcmp ("framerate", attributename)) { cfg->production.framerate = atoi(reader.get_value().c_str()); }  
                 if (!strcmp ("audiorate", attributename)) { cfg->production.audiorate = atoi(reader.get_value().c_str()); }
                 if (!strcmp ("audiochannels", attributename)) { cfg->production.audiochannels = atoi(reader.get_value().c_str()); }
                 if (!strcmp ("videoencbitrate", attributename)) { cfg->production.videoencbitrate = atoi(reader.get_value().c_str()); }
                 if (!strcmp ("audioencbitrate", attributename)) { cfg->production.audioencbitrate = atoi(reader.get_value().c_str()); }         
                } while(reader.move_to_next_attribute());
              }

              if (!strcmp ("streamingLOW", codename)) {
                do { attributename = reader.get_name().c_str();
                 if (!strcmp ("width", attributename)) { cfg->streamingLOW.width = atoi(reader.get_value().c_str()); }
                 if (!strcmp ("height", attributename)) { cfg->streamingLOW.height = atoi(reader.get_value().c_str()); }  
                 if (!strcmp ("framerate", attributename)) { cfg->streamingLOW.framerate = atoi(reader.get_value().c_str()); }           
                 if (!strcmp ("audiorate", attributename)) { cfg->streamingLOW.audiorate = atoi(reader.get_value().c_str()); }
                 if (!strcmp ("audiochannels", attributename)) { cfg->streamingLOW.audiochannels = atoi(reader.get_value().c_str()); }
                 if (!strcmp ("videoencbitrate", attributename)) { cfg->streamingLOW.videoencbitrate = atoi(reader.get_value().c_str()); }
                 if (!strcmp ("audioencbitrate", attributename)) { cfg->streamingLOW.audioencbitrate = atoi(reader.get_value().c_str()); }   
                } while(reader.move_to_next_attribute());
              }

             break;
            }
          } while(reader.move_to_next_attribute());
      reader.move_to_element(); }  }      
  }
  return cfg;
}

void printConfig(Scfg *cfg)
{
  fprintf (stdout, "******************** Configure ********************\n");
  fprintf (stdout, "WFiles path: \t%s\n", cfg->wfilepath);
  fprintf (stdout, "CDN Server paramerts\n");
  fprintf (stdout, "  IP: \t\t%s\n", cfg->CDNserverIP);
  fprintf (stdout, "  Port: \t%d\n", cfg->CDNserverPort);
  fprintf (stdout, "Production encoding paramerts\n");
  fprintf (stdout, "  Width: \t%d\n", cfg->production.width);
  fprintf (stdout, "  Height: \t%d\n", cfg->production.height);
  fprintf (stdout, "  Framerate: \t%d\n", cfg->production.framerate);
  fprintf (stdout, "  Audio rate: \t%d\n", cfg->production.audiorate);
  fprintf (stdout, "  Audio channels: \t%d\n", cfg->production.audiochannels);
  fprintf (stdout, "  Vbitrate: \t%d\n", cfg->production.videoencbitrate);
  fprintf (stdout, "  Abitrate: \t%d\n", cfg->production.audioencbitrate);             
  fprintf (stdout, "Low quality streaming encoding paramerts\n");
  fprintf (stdout, "  Width: \t%d\n", cfg->streamingLOW.width);
  fprintf (stdout, "  Height: \t%d\n", cfg->streamingLOW.height);
  fprintf (stdout, "  Framerate: \t%d\n", cfg->streamingLOW.framerate);
  fprintf (stdout, "  Audio rate: \t%d\n", cfg->streamingLOW.audiorate);
  fprintf (stdout, "  Audio channels: \t%d\n", cfg->streamingLOW.audiochannels);
  fprintf (stdout, "  Vbitrate: \t%d\n", cfg->streamingLOW.videoencbitrate);
  fprintf (stdout, "  Abitrate: \t%d\n", cfg->streamingLOW.audioencbitrate); 
  fprintf (stdout, "***************************************************\n");
  fflush (stdout);
}

