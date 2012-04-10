struct newpads {
  GstElement *v, *a;  
};

class CNVM_Videoplayer: public CNVM_Module {
  private:
    GstElement *videoplayerpipeline;
    GstElement *filesrc, *decodebin, *seg_video, *videoqueue, *ffmpegcolorspace, *videorate, *videoscale, *intervideosink;
    GstElement *seg_audio, *audioqueue, *audioconvert, *audioresample, *interaudiosink;
    
    newpads av;
    GstCaps *vcaps, *acaps;
    Scfg *cfg;
    static void cb_newpad (GstElement * decodebin, GstPad * pad, gboolean last, gpointer data);
  public:
    CNVM_Videoplayer (Scfg *lcfg);
    ~CNVM_Videoplayer ();
    void play();
    void pause();
};
