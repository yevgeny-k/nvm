class CContentModule {
  protected:
    char *name;
    char *info;
  public:
    CContentModule () {}
    ~CContentModule () {}
    char  *getname() { return name; }
    char  *getinfo() { return info; }
    virtual void play() {}
    virtual void pause() {}
};
