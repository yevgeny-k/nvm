TARGET=nvm
ROOT=`pwd`
OBJDIR=obj
BINDIR=bin
CC=g++
CFLAGS=-O3 `pkg-config --cflags gstreamer-0.10`
LDFLAGS=`pkg-config --libs gstreamer-0.10` `pkg-config --libs libxml++-2.6` `pkg-config --libs gthread-2.0` `pkg-config --libs libpcrecpp`


$(TARGET) : createdirs moduleclass serverout techsplash videoplayer manager core
	$(CC) $(LDFLAGS) -o $(ROOT)/bin/$(TARGET) \
	$(ROOT)/obj/moduleclass.o \
	$(ROOT)/obj/videoplayer.o \
	$(ROOT)/obj/techsplash.o \
	$(ROOT)/obj/serverout.o \
	$(ROOT)/obj/manager.o \
	$(ROOT)/obj/main.o

core : 
	$(CC) $(CFLAGS) `pkg-config --cflags libxml++-2.6` `pkg-config --cflags gthread-2.0` -c $(ROOT)/src/main.cpp -o $(ROOT)/obj/main.o

techsplash :
	$(CC) $(CFLAGS) -c $(ROOT)/src/techsplash.cpp -o $(ROOT)/obj/techsplash.o

serverout :
	$(CC) $(CFLAGS) -c $(ROOT)/src/serverout.cpp -o $(ROOT)/obj/serverout.o
	
manager :
	$(CC) $(CFLAGS) `pkg-config --cflags libpcrecpp` -c $(ROOT)/src/manager.cpp -o $(ROOT)/obj/manager.o
			
videoplayer : 
	$(CC) $(CFLAGS) -c $(ROOT)/src/videoplayer.cpp -o $(ROOT)/obj/videoplayer.o  
	
moduleclass :
	$(CC) $(CFLAGS) -c $(ROOT)/src/moduleclass.cpp -o $(ROOT)/obj/moduleclass.o

createdirs :
	if [ ! -d $(ROOT)/$(OBJDIR) ]; then mkdir $(ROOT)/$(OBJDIR); fi
	if [ ! -d $(ROOT)/$(BINDIR) ]; then mkdir $(ROOT)/$(BINDIR); fi
	
clean :
	rm -rf $(ROOT)/obj/*.o
