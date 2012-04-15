class CRandPlayer: public CContentModule {
  private:
    GstElement *techsplashpipeline;
    GstElement *videotestsrc, *clocktext, *textmesg, *ffmpegcolorspace, *videorate, *videoscale, *intervideosink;
    GstElement *audiotestsrc, *testvolume, *audioconvert, *audioresample, *interaudiosink;
    
    GstCaps *vcaps, *acaps;
    
    int maxitems;
    int fileamount;
    char **filelist;
    MYSQL *dblink;
    
    char lastpath[300];
    
    bool refreshList();
    void randSelect();
  public:
    CRandPlayer ();
    ~CRandPlayer ();
    void play();
    void pause();
    bool initConnectToDB();
};
