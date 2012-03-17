/* NewVideoMixer
 *
 * Copyright (C) <2012> Communist Party of the Russian Federation <adm@kprf.ru>
 *
 * Version: 1.2 (17/03/2012)
 *
 * Video player module
 */
 
#include <string.h>
#include <stdio.h>
#include <gst/gst.h>
#include "core.h"
#include "moduleclass.h"
#include "videoplayer.h"

CNVM_Videoplayer::CNVM_Videoplayer (Scfg *cfg)
{
  char tmpbuffer [600];
  
  if (name) {
    delete name;
  }
  name = new char (strlen("Videoplayer module") + 1);
  strcpy (name, "Videoplayer module");
  
  videoplayerpipeline = gst_pipeline_new ("videoplayer");
  gst_pipeline_set_auto_flush_bus (GST_PIPELINE (videoplayerpipeline), FALSE);
  
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
    
  filesrc           = gst_element_factory_make ("filesrc", "videoplayer_filesrc"); 
  sprintf (tmpbuffer, "%s/%s", cfg->wfilepath, "video5.webm");
    g_object_set (G_OBJECT (filesrc), "location", tmpbuffer, NULL);   
  decodebin         = gst_element_factory_make ("decodebin", "videoplayer_decodebin");
  seg_video         = gst_element_factory_make ("identity", "videoplayer_seg_video"); 
  seg_audio         = gst_element_factory_make ("identity", "videoplayer_seg_audio"); 
    av.a = seg_audio;
    av.v = seg_video;
    g_signal_connect (G_OBJECT (decodebin), "new-decoded-pad", G_CALLBACK (cb_newpad), &av);    
  videoqueue        = gst_element_factory_make ("queue", "videoplayer_videoqueue");
  audioqueue        = gst_element_factory_make ("queue", "videoplayer_audioqueue");
  ffmpegcolorspace  = gst_element_factory_make ("ffmpegcolorspace", "videoplayer_ffmpegcolorspace");
  videorate         = gst_element_factory_make ("videorate", "videoplayer_videorate");
  videoscale        = gst_element_factory_make ("videoscale", "videoplayer_videoscale");
  audioconvert      = gst_element_factory_make ("audioconvert", "videoplayer_audioconvert");
  audioresample     = gst_element_factory_make ("audioresample", "videoplayer_audioresample");
  intervideosink    = gst_element_factory_make ("intervideosink", "videoplayer_intervideosink");	
	  g_object_set (G_OBJECT (intervideosink), "sync", TRUE, NULL);
  interaudiosink    = gst_element_factory_make ("interaudiosink", "videoplayer_interaudiosink");	
	  g_object_set (G_OBJECT (interaudiosink), "sync", TRUE, NULL);
	  	
	// Добавляем
  gst_bin_add_many (GST_BIN (videoplayerpipeline), filesrc, decodebin, seg_video, videoqueue, ffmpegcolorspace, videorate, videoscale, intervideosink, NULL);
  gst_bin_add_many (GST_BIN (videoplayerpipeline), seg_audio, audioqueue, audioconvert, audioresample, interaudiosink, NULL);
  
  // Содиняем элементы
  gst_element_link (filesrc, decodebin);
  gst_element_link_many (seg_video, videoqueue, ffmpegcolorspace, videorate, videoscale, NULL);
  gst_element_link_filtered (videoscale, intervideosink, vcaps);

  gst_element_link_many (seg_audio, audioqueue, audioconvert, audioresample, NULL);
  gst_element_link_filtered (audioresample, interaudiosink, acaps);
  
  // Удаляем капсы
  gst_caps_unref (vcaps);  
  gst_caps_unref (acaps);
}

void CNVM_Videoplayer::cb_newpad (GstElement * decodebin, GstPad * pad, gboolean last, gpointer data)
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
  
  
  /* check media type */
  caps = gst_pad_get_caps (pad);
  str = gst_caps_get_structure (caps, 0);

  name = gst_structure_get_name (str);
  g_print ("name: %s", name);

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
    g_print (" link.\n", name);
  }
}

CNVM_Videoplayer::~CNVM_Videoplayer ()
{
  gst_element_set_state (GST_ELEMENT (videoplayerpipeline), GST_STATE_NULL);
  gst_object_unref (GST_OBJECT (videoplayerpipeline));
  fprintf(stdout, "Videoplayer module destroy.\n");
  fflush (stdout);
}

void CNVM_Videoplayer::play ()
{
  gst_element_set_state (GST_ELEMENT (videoplayerpipeline), GST_STATE_PLAYING);
  fprintf(stdout, "Videoplayer module is played.\n");
  fflush (stdout);
}

void CNVM_Videoplayer::pause ()
{
  gst_element_set_state (GST_ELEMENT (videoplayerpipeline), GST_STATE_READY);
  fprintf(stdout, "Videoplayer module paused.\n");
  fflush (stdout);
}
