class CNVM_Techsplash: public CContentModule {
  private:
    GstElement *techsplashpipeline;
    GstElement *videotestsrc, *clocktext, *textmesg, *ffmpegcolorspace, *videorate, *videoscale, *intervideosink;
    GstElement *audiotestsrc, *testvolume, *audioconvert, *audioresample, *interaudiosink;
    
    GstCaps *vcaps, *acaps;
    
    Scfg *cfg;
  public:
    CNVM_Techsplash (Scfg *lcfg);
    ~CNVM_Techsplash ();
    void play();
    void pause();
};
