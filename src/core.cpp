/* NewVideoMixer
 *
 * Copyright (C) <2012> Communist Party of the Russian Federation <adm@kprf.ru>
 *
 * Main module
 */

#include <stdio.h>
#include <string.h>
#include <gst/gst.h>
#include <getopt.h>
#include <unistd.h>
#include <libxml++/libxml++.h>
#include <libxml++/parsers/textreader.h>
#include <iostream>
#include <pthread.h>
#include <log4cpp/Category.hh>
#include <log4cpp/FileAppender.hh> 
#include <log4cpp/PatternLayout.hh>
#include <mysql/mysql.h>
#include "core.hpp"
#include "serverout.hpp"
#include "contentmodules/ccontentmodule.hpp"
#include "contentmodules/randplay.hpp"


///////////////////////////////////////////////////////////////////
char ver[] = "Version: 1.0.5-fake (16/04/2012)";
///////////////////////////////////////////////////////////////////  

///////////////////////////////////////////////////////////////////
//              Объявление глобальных переменных                 //
log4cpp::Category *log =  NULL;
Scfg *cfg = NULL;
///////////////////////////////////////////////////////////////////


Scfg * loadConfig(char *p)
{
  const char *nodename, *attributename, *codename;
  xmlpp::TextReader reader(p);
  
  Scfg *cfg;  
  cfg = new Scfg;
  
  strcpy(cfg->CDNserverIP, "localhost");
  cfg->CDNserverPort = 9001;
  
  strcpy(cfg->videodir, "video");
  strcpy(cfg->logofile, "logo_for_stream.png");
  cfg->logok = 0.1;  
  strcpy(cfg->logfile, "/var/log/nvm.log");
  cfg->logpriority = 400;
  strcpy(cfg->socketpath, "/tmp/nvm");
  cfg->socketport = 22700;
  
  strcpy(cfg->dbserver, "localhost");
  cfg->dbport = 3306;
  strcpy(cfg->dbuser, "user");
  strcpy(cfg->dbpassword, "pass");
  strcpy(cfg->database, "kprf_tv");
      
  while(reader.read())
  {  
      nodename = reader.get_name().c_str();

      if (!strcmp ("filesystem", nodename)) { if(reader.has_attributes()) { reader.move_to_first_attribute();
          do { attributename = reader.get_name().c_str();
            if (!strcmp ("videodir", attributename)) { strcpy (cfg->videodir, reader.get_value().c_str()); }
          } while(reader.move_to_next_attribute());
      reader.move_to_element(); }  }
      
      if (!strcmp ("logo", nodename)) { if(reader.has_attributes()) { reader.move_to_first_attribute();
          do { attributename = reader.get_name().c_str();
            if (!strcmp ("file", attributename)) { strcpy (cfg->logofile, reader.get_value().c_str()); }
            if (!strcmp ("k", attributename)) { cfg->logok = atof(reader.get_value().c_str()); }
          } while(reader.move_to_next_attribute());
      reader.move_to_element(); }  }

      if (!strcmp ("log", nodename)) { if(reader.has_attributes()) { reader.move_to_first_attribute();
          do { attributename = reader.get_name().c_str();
            if (!strcmp ("path", attributename)) { strcpy (cfg->logfile, reader.get_value().c_str()); }
            if (!strcmp ("priority", attributename)) { cfg->logpriority = atoi(reader.get_value().c_str()); }
          } while(reader.move_to_next_attribute());
      reader.move_to_element(); }  }
      
      if (!strcmp ("socket", nodename)) { if(reader.has_attributes()) { reader.move_to_first_attribute();
          do { attributename = reader.get_name().c_str();
            if (!strcmp ("path", attributename)) { strcpy (cfg->socketpath, reader.get_value().c_str()); }
            if (!strcmp ("port", attributename)) { cfg->socketport = atoi(reader.get_value().c_str()); }
          } while(reader.move_to_next_attribute());
      reader.move_to_element(); }  }      

      if (!strcmp ("database", nodename)) { if(reader.has_attributes()) { reader.move_to_first_attribute();
          do { attributename = reader.get_name().c_str();
            if (!strcmp ("server", attributename)) { strcpy (cfg->dbserver, reader.get_value().c_str()); }
            if (!strcmp ("port", attributename)) { cfg->dbport = atoi(reader.get_value().c_str()); }
            if (!strcmp ("user", attributename)) { strcpy (cfg->dbuser, reader.get_value().c_str()); }
            if (!strcmp ("password", attributename)) { strcpy (cfg->dbpassword, reader.get_value().c_str()); }
            if (!strcmp ("databasename", attributename)) { strcpy (cfg->database, reader.get_value().c_str()); }
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

void printConfig()
{
  log->debug("******************** Configure ********************");
  log->info("Video directory: \t%s", cfg->videodir);
  log->info("Log file: \t%s", cfg->logfile);
  log->debug("Log priority: \t%d", cfg->logpriority);
  log->debug("(EMERG = 0, FATAL = 0, ALERT = 100, CRIT = 200, ERROR = 300,");
  log->debug("WARN = 400, NOTICE = 500, INFO = 600, DEBUG = 700, NOTSET = 800)");
  log->debug("CDN Server paramerts");
  log->info("  IP: \t\t%s", cfg->CDNserverIP);
  log->info("  Port: \t%d", cfg->CDNserverPort);
  log->info("Logo path: \t%s", cfg->logofile);
  log->debug("Production encoding paramerts");
  log->debug("  Width: \t%d", cfg->production.width);
  log->debug("  Height: \t%d", cfg->production.height);
  log->debug("  Framerate: \t%d", cfg->production.framerate);
  log->debug("  Audio rate: \t%d", cfg->production.audiorate);
  log->debug("  Audio channels: \t%d", cfg->production.audiochannels);
  log->debug("  Vbitrate: \t%d", cfg->production.videoencbitrate);
  log->debug("  Abitrate: \t%d", cfg->production.audioencbitrate);             
  log->debug("Low quality streaming encoding paramerts");
  log->debug("  Width: \t%d", cfg->streamingLOW.width);
  log->debug("  Height: \t%d", cfg->streamingLOW.height);
  log->debug("  Framerate: \t%d", cfg->streamingLOW.framerate);
  log->debug("  Audio rate: \t%d", cfg->streamingLOW.audiorate);
  log->debug("  Audio channels: \t%d", cfg->streamingLOW.audiochannels);
  log->debug("  Vbitrate: \t%d", cfg->streamingLOW.videoencbitrate);
  log->debug("  Abitrate: \t%d", cfg->streamingLOW.audioencbitrate); 
  log->debug("***************************************************");
}

int main (int argc, char **argv)
{
	pid_t	pid;
  GMainLoop *mainloop = NULL;
  CServerout *encserver;
  CRandPlayer *rndplayer;
  
  char cfgfile[400];
  const char* short_options = "h:c:";
  const struct option long_options[] = {
    {"help",no_argument,NULL,'h'},
    {"configfile",optional_argument,NULL,'c'},
    {NULL,0,NULL,0}
  };
  int rez;
  int option_index = -1;
            

  fprintf (stderr, "NewVideoMixer ");
  fprintf (stderr, "%s\n", ver);
  fflush  (stderr);
  
  strcpy (cfgfile, "config.xml");  

  while ( (rez=getopt_long(argc,argv,short_options,long_options,&option_index)) != -1) {
    switch (rez){
      case 'h':
        fprintf( stdout, "Usage: nvm --configfile=cfgfile\n");
        fflush ( stdout );
        exit(EXIT_SUCCESS);
        break;
      case 'c':
        strcpy (cfgfile, optarg);
        break;
    };
    option_index = -1;
  };

  fprintf( stdout, "Loading configure file: %s\n", cfgfile);
  fflush ( stdout );
  
  cfg = loadConfig (cfgfile);
  
  pid = fork();
  if (pid == -1) {
    exit(EXIT_FAILURE);
  } else {
  if (pid != 0)
    exit(EXIT_SUCCESS);
  }

  if (setsid() == -1)
    exit(EXIT_FAILURE);

  if (chdir("/") == -1)
    exit(EXIT_FAILURE);

  for (int i = getdtablesize(); i >= 0; --i)
    close(i);

  gst_init (NULL, NULL);
  		
  // Инициируем лог файл
  log4cpp::Appender* app = new  log4cpp::FileAppender ("FileAppender", cfg->logfile);
  log4cpp::PatternLayout* layout =  new log4cpp::PatternLayout ();
  layout->setConversionPattern("[%d{%Y-%m-%d %H:%M:%S}] %p: %m%n");
  app->setLayout (layout);
  log = &log4cpp::Category::getRoot();
  log->setAdditivity (false);
  log->setAppender(app);
  log->setPriority(cfg->logpriority);
  
  log->notice("Start program");
  
  //Печатаем конфигурационный файл
  printConfig ();
  mainloop = g_main_loop_new (NULL, TRUE);
    
  encserver = new CServerout ();
  encserver->play ();
  
  rndplayer = new CRandPlayer ();
  if (rndplayer->initConnectToDB ()) {
    rndplayer->play ();
    g_main_loop_run (mainloop);
  }
  
  log->debug("Completion of the program and free memory...");
    delete rndplayer;
    delete encserver;
    delete cfg;
    g_main_loop_unref (mainloop);
  log->notice("End program; Exit.");
  log4cpp::Category::shutdown();
  exit (EXIT_SUCCESS);
}
