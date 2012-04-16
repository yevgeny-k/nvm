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
    GstBus *bus;
    
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
    void next();
    bool initConnectToDB();
};

static void cb_newpad (GstElement * decodebin, GstPad * pad, gboolean last, gpointer data);
static void eos_cb (GstBus * bus, GstMessage * msg, CRandPlayer * c);
