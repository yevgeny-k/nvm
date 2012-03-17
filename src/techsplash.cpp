/* NewVideoMixer
 *
 * Copyright (C) <2012> Communist Party of the Russian Federation <adm@kprf.ru>
 *
 * Version: 1.2 (14/03/2012)
 *
 * Tech splash module
 */
 
#include <string.h>
#include <stdio.h>
#include <gst/gst.h>
#include "core.h"
#include "moduleclass.h"
#include "techsplash.h"

CNVM_Techsplash::CNVM_Techsplash (Scfg *cfg)
{
  GstBus *bus;
  if (name) {
    delete name;
  }
  name = new char (strlen("Tech splash module") + 1);
  strcpy (name, "Tech splash module");
  
  techsplashpipeline = gst_pipeline_new ("techsplash");
  gst_pipeline_set_auto_flush_bus (GST_PIPELINE (techsplashpipeline), FALSE);
  
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
  
  // Создаем элементы
  videotestsrc = gst_element_factory_make ("videotestsrc", "videotestsrc"); 
	clocktext = gst_element_factory_make ("clockoverlay", "clocktext");
  g_object_set (G_OBJECT (clocktext), "halign", "right", "valign", "top", "deltax", 0, "deltay", 40, "time-format", "%d %B %Y\n%H:%M:%S", NULL);
	textmesg = gst_element_factory_make ("textoverlay", "textmesg"); 
	g_object_set (G_OBJECT (textmesg), "text", "Технический перерыв на канале.\nСамое время отдохнуть...", "deltay", -70, "font-desc", "Sans 21", NULL);

  ffmpegcolorspace = gst_element_factory_make ("ffmpegcolorspace", "ffmpegcolorspace");
  videorate = gst_element_factory_make ("videorate", "videorate");
  videoscale = gst_element_factory_make ("videoscale", "videoscale");
  	 
	intervideosink = gst_element_factory_make ("intervideosink", "intervideosink");	
	  g_object_set (G_OBJECT (intervideosink), "sync", TRUE, NULL); 
	 
  audiotestsrc = gst_element_factory_make ("audiotestsrc", "audiotestsrc");  
  testvolume = gst_element_factory_make ("volume", "volume"); 
    g_object_set (G_OBJECT (testvolume), "volume", 0.2, NULL);
  audioconvert = gst_element_factory_make ("audioconvert", "audioconvert");
  audioresample = gst_element_factory_make ("audioresample", "audioresample");
  interaudiosink       = gst_element_factory_make ("interaudiosink", "interaudiosink");
    g_object_set (G_OBJECT (interaudiosink), "sync", TRUE, NULL);
  
  

  // Добавляем
  gst_bin_add_many (GST_BIN (techsplashpipeline), videotestsrc, clocktext, textmesg, ffmpegcolorspace, videorate, videoscale, intervideosink, NULL);
  gst_bin_add_many (GST_BIN (techsplashpipeline), audiotestsrc, testvolume, audioconvert, audioresample, interaudiosink, NULL);
  
  
  // Содиняем элементы
  gst_element_link_many (videotestsrc, clocktext, textmesg, ffmpegcolorspace, videorate, videoscale, NULL);
  gst_element_link_filtered (videoscale, intervideosink, vcaps);
  gst_element_link_many (audiotestsrc, testvolume, audioconvert, audioresample, NULL);
  gst_element_link_filtered (audioresample, interaudiosink, acaps);
  
  // Удаляем капсы
  gst_caps_unref (acaps);
  gst_caps_unref (vcaps);  
}

CNVM_Techsplash::~CNVM_Techsplash ()
{
  gst_element_set_state (GST_ELEMENT (techsplashpipeline), GST_STATE_NULL);
  gst_object_unref (GST_OBJECT (techsplashpipeline));
  fprintf(stdout, "Tesh splash module destroy.\n");
  fflush (stdout);
}

void CNVM_Techsplash::play ()
{
  gst_element_set_state (GST_ELEMENT (techsplashpipeline), GST_STATE_PLAYING);
  fprintf(stdout, "Tesh splash module is played.\n");
  fflush (stdout);
}

void CNVM_Techsplash::pause ()
{
  gst_element_set_state (GST_ELEMENT (techsplashpipeline), GST_STATE_READY);
  fprintf(stdout, "Tesh splash module paused.\n");
  fflush (stdout);
}
