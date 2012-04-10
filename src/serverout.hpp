class CNVM_Serverout {
  private:
    GstElement *mainpipeline;    
    GstPad *srcpad, *sinkpad;    
    GstCaps *venccaps, *aenccaps, *logocaps, *faaccaps;   
   
    GstElement *intervideosrc, *videointercaps, *videoqueue, *intercapsidentity, *ffmpegcolorspace, *mixcapsin, *mixidentity;  
    GstElement *logofilesrc, *pngdec, *alphacolor, *imagefreeze, *logoscale, *logoidentity;
    GstElement *videomixer;  
    GstElement *interaudiosrc, *audiointercaps, *audioqueue, *audiointercapsidentity, *audioconvertENC, *audioresampleENC, *faac;
    GstElement *ffmpegcolorspaceENC, *videorateENC, *videoscaleENC, *x264enc;  
    GstElement *mpegtsmux, *rtpmp2tpay, *udpsink;
    
    Scfg *cfg;
  public:
    CNVM_Serverout (Scfg *lcfg);
    ~CNVM_Serverout ();
    void play ();
};
