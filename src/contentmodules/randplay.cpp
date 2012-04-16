/* 
 * Copyright (C) <2012> Communist Party of the Russian Federation <adm@kprf.ru>
 *
 */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <gst/gst.h>
#include <log4cpp/Category.hh>
#include <mysql/mysql.h>
#include "../core.hpp"
#include "ccontentmodule.hpp"
#include "randplay.hpp"

extern log4cpp::Category *log;
extern Scfg *cfg;

CRandPlayer::CRandPlayer(): maxitems(50)
{
  char elementname [100];
  
  log->debug("Construct randome player module");
  name = new char [strlen("randplayer") + 1];
  strcpy (name, "randplayer");
  info = new char [strlen("Randome player module") + 1];
  strcpy (info, "Randome player module");  
  
  dblink = mysql_init(NULL);
  mysql_options(dblink, MYSQL_SET_CHARSET_NAME, "utf8");
  my_bool reconnect = 1;
  mysql_options(dblink, MYSQL_OPT_RECONNECT, &reconnect);
  
  strcpy (lastpath, "");
  
  pipeline = gst_pipeline_new (name);
  gst_pipeline_set_auto_flush_bus (GST_PIPELINE (pipeline), FALSE);
  
   vcaps = gst_caps_new_simple ("video/x-raw-yuv",
  "width", G_TYPE_INT, cfg->production.width,
  "height", G_TYPE_INT, cfg->production.height,	
  "pixel-aspect-ratio", GST_TYPE_FRACTION, 1, 1,
  "format", GST_TYPE_FOURCC, GST_MAKE_FOURCC ('I', '4', '2', '0'),
  "framerate", GST_TYPE_FRACTION, cfg->production.framerate, 1,
  NULL);

  acaps = gst_caps_new_simple ("audio/x-raw-int",
  "width",G_TYPE_INT, 16,
  "rate", G_TYPE_INT, cfg->production.audiorate,
  "channels", G_TYPE_INT, cfg->production.audiochannels,
  "depth", G_TYPE_INT, 16,
  NULL);
                          sprintf (elementname, "%s_%s", name, "filesrc");
  filesrc           = gst_element_factory_make ("filesrc", elementname);  
    g_object_set (G_OBJECT (filesrc), "location", lastpath, NULL);   
                          sprintf (elementname, "%s_%s", name, "decodebin");
  decodebin         = gst_element_factory_make ("decodebin", elementname);
                          sprintf (elementname, "%s_%s", name, "seg_video");
  seg_video         = gst_element_factory_make ("identity", elementname); 
                          sprintf (elementname, "%s_%s", name, "seg_audio");
  seg_audio         = gst_element_factory_make ("identity", elementname); 
    av.a = seg_audio;
    av.v = seg_video;
    g_signal_connect (G_OBJECT (decodebin), "new-decoded-pad", G_CALLBACK (cb_newpad), &av);    
                          sprintf (elementname, "%s_%s", name, "videoqueue");
  videoqueue        = gst_element_factory_make ("queue", elementname);
                          sprintf (elementname, "%s_%s", name, "audioqueue");
  audioqueue        = gst_element_factory_make ("queue", elementname);
                          sprintf (elementname, "%s_%s", name, "ffmpegcolorspace"); 
  ffmpegcolorspace  = gst_element_factory_make ("ffmpegcolorspace", elementname);
                          sprintf (elementname, "%s_%s", name, "videorate"); 
  videorate         = gst_element_factory_make ("videorate", elementname);
                          sprintf (elementname, "%s_%s", name, "videoscale");
  videoscale        = gst_element_factory_make ("videoscale", elementname);
                          sprintf (elementname, "%s_%s", name, "audioconvert");
  audioconvert      = gst_element_factory_make ("audioconvert", elementname);
                          sprintf (elementname, "%s_%s", name, "audioresample");
  audioresample     = gst_element_factory_make ("audioresample", elementname);
                          sprintf (elementname, "%s_%s", name, "intervideosink");
  intervideosink    = gst_element_factory_make ("intervideosink", elementname);	
	  g_object_set (G_OBJECT (intervideosink), "sync", TRUE, NULL);
                          sprintf (elementname, "%s_%s", name, "interaudiosink");
  interaudiosink    = gst_element_factory_make ("interaudiosink", elementname);	
	  g_object_set (G_OBJECT (interaudiosink), "sync", TRUE, NULL);
	  	
	// Добавляем
  gst_bin_add_many (GST_BIN (pipeline), filesrc, decodebin, seg_video, videoqueue, ffmpegcolorspace, videorate, videoscale, intervideosink, NULL);
  gst_bin_add_many (GST_BIN (pipeline), seg_audio, audioqueue, audioconvert, audioresample, interaudiosink, NULL);
  
  // Содиняем элементы
  gst_element_link (filesrc, decodebin);
  gst_element_link_many (seg_video, videoqueue, ffmpegcolorspace, videorate, videoscale, NULL);
  gst_element_link_filtered (videoscale, intervideosink, vcaps);

  gst_element_link_many (seg_audio, audioqueue, audioconvert, audioresample, NULL);
  gst_element_link_filtered (audioresample, interaudiosink, acaps);
  
  // Удаляем капсы
  gst_caps_unref (vcaps);  
  gst_caps_unref (acaps);
  
  log->debug("Videoplayer module constructed");
}

CRandPlayer::~CRandPlayer()
{
  delete [] name;
  delete [] info;
  mysql_close (dblink);
  gst_element_set_state (GST_ELEMENT (pipeline), GST_STATE_NULL);
  gst_object_unref (GST_OBJECT (pipeline));
  log->debug("Randome player module destroy");
}

bool CRandPlayer::initConnectToDB()
{  
  if (!mysql_real_connect(dblink, cfg->dbserver, cfg->dbuser, cfg->dbpassword, cfg->database, cfg->dbport, NULL, 0)) {
		log->error ("Error connect to database. (%d): %s", mysql_errno(dblink), mysql_error(dblink));
		return false;
	} else {
		log->info ("Connect to database establish");
		return true;
	}
}

bool CRandPlayer::refreshList()
{
  char querytmp[300];
  char q[] = "SELECT fm.uri FROM node as n LEFT JOIN field_data_field_videoclip as v ON (n.nid = v.entity_id) LEFT JOIN file_managed as fm ON (v.field_videoclip_fid = fm.fid) WHERE fm.uri IS NOT NULL ORDER BY created DESC limit %d";  
 	MYSQL_RES *result;
	MYSQL_ROW row;
	int i;
	 
  log->debug("Refresh video list");  
  mysql_ping (dblink);
  
  for (i=0; i < fileamount; i++)
    delete [] filelist[i];
  if (fileamount)
    delete [] filelist;
  fileamount = 0;

  sprintf (querytmp, q, maxitems);
  
  if (mysql_query(dblink, querytmp)) {
    log->error ("Error query: %s", mysql_error(dblink));
    return false;
  }
  result = mysql_store_result(dblink);
  
  fileamount = mysql_num_rows(result);
  filelist = new char* [fileamount];
  
  i = 0;
  char buff[300];
  char tmp [300];
  char *pch;
  
  while ((row = mysql_fetch_row(result)))
  {
    strcpy (buff, row[0]);
    pch = strstr (buff, "public://");
    if (pch != NULL)
    {
      pch += strlen ("public://");
      sprintf (tmp, "%s/%s", cfg->videopath, pch);
      filelist[i] = new char [strlen(tmp) + 1];
      strcpy (filelist[i], tmp);
      i++;
    }
  }
  fileamount = i;
  mysql_free_result(result);
}

void CRandPlayer::randSelect()
{
  int cur, i = 0;
  srand (time (NULL));
  log->debug("Rand select");

  while (true)
  {
    i++;
    cur = rand() % fileamount + 1;
    if (strcmp (filelist[cur], lastpath))
    {
      strcpy (lastpath, filelist[cur]);
      break;
    } else {
      continue;
    }
    if (i >= 20)
    {
      break;
    }
  }
}

void CRandPlayer::cb_newpad (GstElement * decodebin, GstPad * pad, gboolean last, gpointer data)
{
  GstCaps *caps;
  GstStructure *str;
  GstPad *sinkpad;
  GstElement *sink;
  const gchar *name;
  GstStateChangeReturn ret;
  GstPadLinkReturn lret;
  newpads *av;
  GstElement *sa, *sv;
  
  av = (newpads *) data;
  sa = av->a;
  sv = av->v;  

  caps = gst_pad_get_caps (pad);
  str = gst_caps_get_structure (caps, 0);

  name = gst_structure_get_name (str);

  if (g_strrstr (name, "audio")) {
    sink = sa;
  } else if (g_strrstr (name, "video")) {
    sink = sv;
  } else {
    sink = NULL;
  }
  gst_caps_unref (caps);

  if (sink) {
    sinkpad = gst_element_get_static_pad (sink, "sink");
    gst_pad_link (pad, sinkpad);
    gst_object_unref (sinkpad);
  }
}

void CRandPlayer::play()
{
  log->debug("Randome player module is played");
  next();  
}

void CRandPlayer::pause()
{
  log->debug("Randome player module paused");
  gst_element_set_state (GST_ELEMENT (pipeline), GST_STATE_READY);
}

void CRandPlayer::next()
{
  refreshList();
  randSelect();
  g_object_set (G_OBJECT (filesrc), "location", lastpath, NULL);
  gst_element_set_state (GST_ELEMENT (pipeline), GST_STATE_READY);
  gst_element_set_state (GST_ELEMENT (pipeline), GST_STATE_PLAYING);
  log->info("Playing file: %s", lastpath);
}
