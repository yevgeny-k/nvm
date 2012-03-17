class CNVM_Videoplayer: public CNVM_Module {
  private:
    GstElement *videoplayerpipeline;
    //GstElement *videotestsrc, *clocktext, *textmesg, *ffmpegcolorspace, *videorate, *videoscale, *intervideosink;
    //GstElement *audiotestsrc, *testvolume, *audioconvert, *audioresample, *interaudiosink;
    
    //GstCaps *vcaps, *acaps;
  public:
    CNVM_Videoplayer (Scfg *cfg);
    ~CNVM_Videoplayer ();
    void play();
    void pause();
};
