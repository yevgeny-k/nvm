class CNVM_Serverout {
  private:
    GstElement *mainpipeline;    
    GstPad *srcpad, *sinkpad;    
    GstCaps *venccaps, *aenccaps, *logocaps;   
   
    GstElement *intervideosrc, *videointercaps, *videoqueue, *intercapsidentity, *ffmpegcolorspace, *mixcapsin, *mixinidentity;  
    GstElement *multifilesrc, *pngdec, *alphacolor, *logoscale, *logoinidentity;
    GstElement *videomixer;  
    GstElement *interaudiosrc, *audiointercaps, *audioqueue, *audiointercapsidentity, *audioconvertENC, *audioresampleENC, *faac;
    GstElement *ffmpegcolorspaceENC, *videorateENC, *videoscaleENC, *x264enc;  
    GstElement *mpegtsmux, *rtpmp2tpay, *udpsink;
   
   
  public:
    CNVM_Serverout (Scfg *cfg);
    ~CNVM_Serverout ();
    void play ();
};
