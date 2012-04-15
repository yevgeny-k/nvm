TARGET=nvm
ROOT=`pwd`
OBJDIR=$(ROOT)/obj
BINDIR=$(ROOT)/bin
LOGDIR=$(ROOT)/log
SRCDIR=$(ROOT)/src
CMOD=$(SRCDIR)/contentmodules
CC=g++
CFLAGS=-O3  `pkg-config --cflags gstreamer-0.10` \
            `pkg-config --cflags log4cpp`
LDFLAGS=`pkg-config --libs gstreamer-0.10` \
        `pkg-config --libs libxml++-2.6` \
        `pkg-config --libs gthread-2.0` \
        `pkg-config --libs libpcrecpp` \
        `pkg-config --libs log4cpp` \
        -L/usr/lib64/mysql/

$(TARGET) : createdirs cmoduleclass serverout techsplash videoplayer remote randplay core
	$(CC) $(LDFLAGS) -o $(BINDIR)/$(TARGET) \
	$(OBJDIR)/moduleclass.o \
	$(OBJDIR)/videoplayer.o \
	$(OBJDIR)/techsplash.o \
	$(OBJDIR)/serverout.o \
	$(OBJDIR)/remote.o \
	$(OBJDIR)/randplay.o \
	$(OBJDIR)/main.o

core : 
	$(CC) $(CFLAGS) `pkg-config --cflags libxml++-2.6` \
	`pkg-config --cflags gthread-2.0` -c $(SRCDIR)/main.cpp -o $(OBJDIR)/main.o

techsplash :
	$(CC) $(CFLAGS) -c $(CMOD)/techsplash.cpp -o $(OBJDIR)/techsplash.o

serverout :
	$(CC) $(CFLAGS) -c $(SRCDIR)/serverout.cpp -o $(OBJDIR)/serverout.o
	
remote :
	$(CC) $(CFLAGS) `pkg-config --cflags libpcrecpp` -c $(SRCDIR)/remote.cpp -o $(OBJDIR)/remote.o
			
videoplayer : 
	$(CC) $(CFLAGS) -c $(CMOD)/videoplayer.cpp -o $(OBJDIR)/videoplayer.o  

randplay : 
	$(CC) $(CFLAGS) -c $(SRCDIR)/randplay.cpp -o $(OBJDIR)/randplay.o  
	
cmoduleclass :
	$(CC) $(CFLAGS) -c $(CMOD)/moduleclass.cpp -o $(OBJDIR)/moduleclass.o

createdirs :
	if [ ! -d $(OBJDIR) ]; then mkdir $(OBJDIR); fi
	if [ ! -d $(BINDIR) ]; then mkdir $(BINDIR); fi
	if [ ! -d $(LOGDIR) ]; then mkdir $(LOGDIR); fi
	
clean :
	rm -rf $(OBJDIR)/*.o
