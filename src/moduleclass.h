class CNVM_Module {
  protected:
    char *name;    
  public:
    CNVM_Module ();
    ~CNVM_Module ();
    char  *getname() { return name; }
    virtual void play() {}
    virtual void pause() {}  
};
