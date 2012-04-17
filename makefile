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
        -L/usr/lib64/mysql/ -lmysqlclient

$(TARGET) : createdirs serverout randplay incoming core
	$(CC) $(LDFLAGS) -o $(BINDIR)/$(TARGET) \
	$(OBJDIR)/serverout.o \
	$(OBJDIR)/randplay.o \
	$(OBJDIR)/incoming.o \
	$(OBJDIR)/core.o

core : 
	$(CC) $(CFLAGS) `pkg-config --cflags libxml++-2.6` \
	`pkg-config --cflags gthread-2.0` -c $(SRCDIR)/core.cpp -o $(OBJDIR)/core.o

serverout :
	$(CC) $(CFLAGS) -c $(SRCDIR)/serverout.cpp -o $(OBJDIR)/serverout.o

randplay : 
	$(CC) $(CFLAGS) -c $(CMOD)/randplay.cpp -o $(OBJDIR)/randplay.o  

incoming : 
	$(CC) $(CFLAGS) -c $(CMOD)/incoming.cpp -o $(OBJDIR)/incoming.o  	
	
createdirs :
	if [ ! -d $(OBJDIR) ]; then mkdir $(OBJDIR); fi
	if [ ! -d $(BINDIR) ]; then mkdir $(BINDIR); fi
	if [ ! -d $(LOGDIR) ]; then mkdir $(LOGDIR); fi
	
clean :
	rm -rf $(OBJDIR)/*.o
