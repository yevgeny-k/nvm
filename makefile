TARGET=nvm
ROOT=`pwd`
OBJDIR=obj
BINDIR=bin
LOGDIR=log
CC=g++
CFLAGS=-O3  `pkg-config --cflags gstreamer-0.10` \
            `pkg-config --cflags log4cpp`
LDFLAGS=`pkg-config --libs gstreamer-0.10` \
        `pkg-config --libs libxml++-2.6` \
        `pkg-config --libs gthread-2.0` \
        `pkg-config --libs libpcrecpp` \
        `pkg-config --libs log4cpp`


$(TARGET) : createdirs moduleclass serverout techsplash videoplayer remote randplay core
	$(CC) $(LDFLAGS) -o $(ROOT)/$(BINDIR)/$(TARGET) \
	$(ROOT)/$(OBJDIR)/moduleclass.o \
	$(ROOT)/$(OBJDIR)/videoplayer.o \
	$(ROOT)/$(OBJDIR)/techsplash.o \
	$(ROOT)/$(OBJDIR)/serverout.o \
	$(ROOT)/$(OBJDIR)/remote.o \
	$(ROOT)/$(OBJDIR)/randplay.o \
	$(ROOT)/$(OBJDIR)/main.o

core : 
	$(CC) $(CFLAGS) `pkg-config --cflags libxml++-2.6` `pkg-config --cflags gthread-2.0` -c $(ROOT)/src/main.cpp -o $(ROOT)/obj/main.o

techsplash :
	$(CC) $(CFLAGS) -c $(ROOT)/src/techsplash.cpp -o $(ROOT)/$(OBJDIR)/techsplash.o

serverout :
	$(CC) $(CFLAGS) -c $(ROOT)/src/serverout.cpp -o $(ROOT)/$(OBJDIR)/serverout.o
	
remote :
	$(CC) $(CFLAGS) `pkg-config --cflags libpcrecpp` -c $(ROOT)/src/remote.cpp -o $(ROOT)/$(OBJDIR)/remote.o
			
videoplayer : 
	$(CC) $(CFLAGS) -c $(ROOT)/src/videoplayer.cpp -o $(ROOT)/$(OBJDIR)/videoplayer.o  

randplay : 
	$(CC) $(CFLAGS) -c $(ROOT)/src/randplay.cpp -o $(ROOT)/$(OBJDIR)/randplay.o  
	
moduleclass :
	$(CC) $(CFLAGS) -c $(ROOT)/src/moduleclass.cpp -o $(ROOT)/$(OBJDIR)/moduleclass.o

createdirs :
	if [ ! -d $(ROOT)/$(OBJDIR) ]; then mkdir $(ROOT)/$(OBJDIR); fi
	if [ ! -d $(ROOT)/$(BINDIR) ]; then mkdir $(ROOT)/$(BINDIR); fi
	if [ ! -d $(ROOT)/$(LOGDIR) ]; then mkdir $(ROOT)/$(LOGDIR); fi
	
clean :
	rm -rf $(ROOT)/$(OBJDIR)/*.o
