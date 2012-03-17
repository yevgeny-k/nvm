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
  if (name) {
    delete name;
  }
  name = new char (strlen("Videoplayer module") + 1);
  strcpy (name, "Videoplayer module");
  
  videoplayerpipeline = gst_pipeline_new ("videoplayer");
  gst_pipeline_set_auto_flush_bus (GST_PIPELINE (videoplayerpipeline), FALSE);
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
