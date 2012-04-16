struct newpads {
  GstElement *v, *a;  
};

class CRandPlayer: public CContentModule {
  private:
    GstElement *pipeline;
    GstElement *filesrc, *decodebin, *seg_video, *videoqueue, *ffmpegcolorspace, *videorate, *videoscale, *intervideosink;
    GstElement *seg_audio, *audioqueue, *audioconvert, *audioresample, *interaudiosink;
    
    newpads av;
    GstCaps *vcaps, *acaps;
    
    int maxitems;
    int fileamount;
    char **filelist;
    MYSQL *dblink;
    
    char lastpath[300];
    
    bool refreshList();
    void randSelect();
    
    static void cb_newpad (GstElement * decodebin, GstPad * pad, gboolean last, gpointer data);
  public:
    CRandPlayer ();
    ~CRandPlayer ();
    void play();
    void pause();
    void next();
    bool initConnectToDB();
};
