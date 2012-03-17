/* NewVideoMixer
 *
 * Copyright (C) <2012> Communist Party of the Russian Federation <adm@kprf.ru>
 *
 * Version: 1.2 (15/03/2012)
 *
 * Модуль выходной кодировки
 */
 
#include <gst/gst.h>
#include "core.h"
#include "serverout.h"

CNVM_Serverout::CNVM_Serverout (Scfg *cfg)
{
  char tmpbuffer [600];
  
  mainpipeline = gst_pipeline_new ("mainpipeline");
  gst_pipeline_set_auto_flush_bus (GST_PIPELINE (mainpipeline), FALSE);

  // Создаем элементы
  intervideosrc           = gst_element_factory_make ("intervideosrc", "intervideosrc");
  videointercaps          = gst_element_factory_make ("capsfilter", "videointercaps");
    g_object_set (G_OBJECT (videointercaps), "caps",  
                                              gst_caps_new_simple ("video/x-raw-yuv",                                              
                                              "format", GST_TYPE_FOURCC, GST_MAKE_FOURCC ('I', '4', '2', '0'),                                              
                                              "framerate", GST_TYPE_FRACTION, cfg->production.framerate, 1,                                              
                                              "pixel-aspect-ratio", GST_TYPE_FRACTION, 1, 1,
                                              "width", G_TYPE_INT, cfg->production.width,
                                              "height", G_TYPE_INT, cfg->production.height,
                                              NULL), NULL);
  videoqueue              = gst_element_factory_make ("queue", "videoqueue");
  intercapsidentity       = gst_element_factory_make ("identity", "intercapsidentity");
    g_object_set (G_OBJECT (intercapsidentity), "sync", TRUE, NULL);
  ffmpegcolorspace        = gst_element_factory_make ("ffmpegcolorspace", "ffmpegcolorspace");
  mixcapsin               = gst_element_factory_make ("capsfilter", "mixcapsin");

    g_object_set (G_OBJECT (mixcapsin), "caps",  
                                              gst_caps_new_simple ("video/x-raw-yuv",
                                              "width", G_TYPE_INT, cfg->production.width,
                                              "height", G_TYPE_INT, cfg->production.height,	
                                            "pixel-aspect-ratio", GST_TYPE_FRACTION, 1, 1,
                                              "format", GST_TYPE_FOURCC, GST_MAKE_FOURCC ('A', 'Y', 'U', 'V'),
                                              "framerate", GST_TYPE_FRACTION, cfg->production.framerate, 1,                                          
                                              NULL), NULL);
  mixinidentity           = gst_element_factory_make ("identity", "mixinidentity");
    //g_object_set (G_OBJECT (mixinidentity), "sync", TRUE, NULL);
  multifilesrc          = gst_element_factory_make ("multifilesrc", "multifilesrc"); 
  sprintf (tmpbuffer, "%s/%s", cfg->wfilepath, "logo_for_stream.png");
  g_object_set (G_OBJECT (multifilesrc), "location", tmpbuffer, "caps", gst_caps_new_simple ("image/png", "framerate", GST_TYPE_FRACTION,cfg->production.framerate,1, NULL), NULL);                            
  pngdec                = gst_element_factory_make ("pngdec", "pngdec");  
  alphacolor            = gst_element_factory_make ("alphacolor", "alphacolor");
  logoscale             = gst_element_factory_make ("videoscale", "logoscale");
  logoinidentity        = gst_element_factory_make ("identity", "logoinidentity");
  videomixer            = gst_element_factory_make ("videomixer", "videomixer");
  interaudiosrc         = gst_element_factory_make ("interaudiosrc", "interaudiosrc");
  audiointercaps        = gst_element_factory_make ("capsfilter", "audiointercaps");
    g_object_set (G_OBJECT (audiointercaps), "caps",  
                                                gst_caps_new_simple ("audio/x-raw-int",
                                                "width",G_TYPE_INT, 16,
                                                "rate", G_TYPE_INT, cfg->production.audiorate,
                                                "channels", G_TYPE_INT, cfg->production.audiochannels,
                                               "depth", G_TYPE_INT, 16,
                                                NULL), NULL);
  audioqueue = gst_element_factory_make ("queue", "audioqueue");
  audiointercapsidentity       = gst_element_factory_make ("identity", "audiointercapsidentity");
    g_object_set (G_OBJECT (audiointercapsidentity), "sync", TRUE, NULL);
  audioconvertENC      = gst_element_factory_make ("audioconvert", "audioconvertENC");
  audioresampleENC      = gst_element_factory_make ("audioresample", "audioresampleENC");
  faac                  = gst_element_factory_make ("lame", "lame");
    g_object_set (G_OBJECT (faac), "bitrate", cfg->streamingLOW.audioencbitrate, NULL);
  ffmpegcolorspaceENC  = gst_element_factory_make ("ffmpegcolorspace", "ffmpegcolorspaceENC");
  videorateENC         = gst_element_factory_make ("videorate", "videorateENC");
  videoscaleENC        = gst_element_factory_make ("videoscale", "videoscaleENC");
  x264enc               = gst_element_factory_make ("x264enc", "x264enc"); 
    g_object_set (G_OBJECT (x264enc), "byte-stream", TRUE, "bitrate", cfg->streamingLOW.videoencbitrate, "tune", 0x00000004, NULL);    
  mpegtsmux             = gst_element_factory_make ("mpegtsmux", "mpegtsmux");  
  rtpmp2tpay            = gst_element_factory_make ("rtpmp2tpay", "rtpmp2tpay");
  udpsink               = gst_element_factory_make ("udpsink", "udpsink");
    g_object_set (G_OBJECT (udpsink), "host", cfg->CDNserverIP, "port", cfg->CDNserverPort, "sync", TRUE, NULL);   
 
     
  // Добавляем элементы на "трубу"
  gst_bin_add_many (GST_BIN (mainpipeline), intervideosrc, videointercaps, videoqueue, intercapsidentity, ffmpegcolorspace, mixcapsin, mixinidentity, NULL);  
  gst_bin_add_many (GST_BIN (mainpipeline), multifilesrc, pngdec, alphacolor, logoscale, logoinidentity, NULL); 
  gst_bin_add (GST_BIN (mainpipeline), videomixer);  
  
  gst_bin_add_many (GST_BIN (mainpipeline), interaudiosrc, audiointercaps, audioqueue, audiointercapsidentity, audioconvertENC, audioresampleENC, faac, NULL);
  gst_bin_add_many (GST_BIN (mainpipeline), ffmpegcolorspaceENC, videorateENC, videoscaleENC, x264enc, NULL);
  
  gst_bin_add_many (GST_BIN (mainpipeline), mpegtsmux, rtpmp2tpay, udpsink, NULL);
  
    
  //Соединяем входной видеосигнал и видеомикшер
  gst_element_link_many (intervideosrc, videointercaps, videoqueue, intercapsidentity, ffmpegcolorspace, mixcapsin, mixinidentity, NULL);
  gst_element_link_pads (mixinidentity, "src", videomixer, "sink_%d");
  
  // капс для лого
  logocaps = gst_caps_new_simple ("video/x-raw-yuv",
  //"format", GST_TYPE_FOURCC, GST_MAKE_FOURCC ('A', 'Y', 'U', 'V'),
  "width", G_TYPE_INT, 40,
  "height", G_TYPE_INT, 40, NULL);
  
  // Соединяем лого и видеомикшер
  gst_element_link_many (multifilesrc, pngdec, alphacolor, logoscale, NULL);
  gst_element_link_filtered (logoscale, logoinidentity, logocaps); 
  srcpad = gst_element_get_static_pad (logoinidentity, "src");
  sinkpad = gst_element_get_request_pad (videomixer, "sink_%d");
  g_object_set (G_OBJECT (sinkpad), "xpos", (cfg->production.width - 44), NULL);
  g_object_set (G_OBJECT (sinkpad), "ypos", 4, NULL);
  gst_pad_link (srcpad, sinkpad);
  gst_object_unref (srcpad);
  gst_object_unref (sinkpad);


  // Капс для кодирование выходного видео
  venccaps = gst_caps_new_simple ("video/x-raw-yuv",
  "width", G_TYPE_INT, cfg->streamingLOW.width,
  "height", G_TYPE_INT, cfg->streamingLOW.height,	
  "pixel-aspect-ratio", GST_TYPE_FRACTION, 1, 1,
  "format", GST_TYPE_FOURCC, GST_MAKE_FOURCC ('I', '4', '2', '0'),
  "framerate", GST_TYPE_FRACTION, cfg->streamingLOW.framerate, 1,
  NULL);
  // Капс для кодирование выходного аудио
  aenccaps = gst_caps_new_simple ("audio/x-raw-int",
  "width",G_TYPE_INT, 16,
  "rate", G_TYPE_INT, cfg->streamingLOW.audiorate,
  "channels", G_TYPE_INT, cfg->streamingLOW.audiochannels,
  "depth", G_TYPE_INT, 16,
  NULL);
    
  // Соединяем кодирование видео и MPEG микшер
  gst_element_link_many (videomixer, ffmpegcolorspaceENC, videorateENC, videoscaleENC, NULL);
  gst_element_link_filtered (videoscaleENC, x264enc, venccaps);
  gst_element_link_pads (x264enc, "src", mpegtsmux, "sink_%d");
  
  // Соединяем кодирование звука и MPEG микшер
  gst_element_link_many (interaudiosrc, audiointercaps, audioqueue, audiointercapsidentity, audioconvertENC, audioresampleENC, NULL);
  gst_element_link_filtered (audioresampleENC, faac, aenccaps);
  gst_element_link_pads (faac, "src", mpegtsmux, "sink_%d");
  
  // Соединяем выходной
  gst_element_link_many (mpegtsmux, rtpmp2tpay, udpsink, NULL);
       
  gst_caps_unref (logocaps);
  gst_caps_unref (venccaps);
  gst_caps_unref (aenccaps);
}

CNVM_Serverout::~CNVM_Serverout()
{
  gst_element_set_state (GST_ELEMENT (mainpipeline), GST_STATE_NULL);
  gst_object_unref (GST_BIN (mainpipeline));
  fprintf(stdout, "Encoding server destroy.\n");
  fflush (stdout);
}

void CNVM_Serverout::play ()
{
  gst_element_set_state (GST_ELEMENT (mainpipeline), GST_STATE_PLAYING);
  fprintf(stdout, "Encoding server is played.\n");
  fflush (stdout);
}
