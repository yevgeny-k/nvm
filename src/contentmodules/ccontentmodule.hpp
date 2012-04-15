class CContentModule {
  protected:
    char *name;    
  public:
    CContentModule ();
    ~CContentModule ();
    char  *getname() { return name; }
    virtual void play() {}
    virtual void pause() {}  
};
