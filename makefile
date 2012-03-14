TARGET=nvm
ROOT=/root/dev/nvm
OBJDIR=obj
BINDIR=bin
CC=g++
CFLAGS=-O3 `pkg-config --cflags gstreamer-0.10`
LDFLAGS=`pkg-config --libs gstreamer-0.10` `pkg-config --libs libxml++-2.6`


$(TARGET) : createdirs serverout techsplash core
	$(CC) $(LDFLAGS) -o $(ROOT)/bin/$(TARGET) $(ROOT)/obj/moduleclass.o $(ROOT)/obj/techsplash.o $(ROOT)/obj/serverout.o $(ROOT)/obj/main.o

core : 
	$(CC) $(CFLAGS) `pkg-config --cflags libxml++-2.6` -c $(ROOT)/src/main.cpp -o $(ROOT)/obj/main.o

techsplash : moduleclass
	$(CC) $(CFLAGS) -c $(ROOT)/src/techsplash.cpp -o $(ROOT)/obj/techsplash.o

serverout :
	$(CC) $(CFLAGS) -c $(ROOT)/src/serverout.cpp -o $(ROOT)/obj/serverout.o
		     
moduleclass :
	$(CC) $(CFLAGS) -c $(ROOT)/src/moduleclass.cpp -o $(ROOT)/obj/moduleclass.o

createdirs :
	if [ ! -d $(ROOT)/$(OBJDIR) ]; then mkdir $(ROOT)/$(OBJDIR); fi
	if [ ! -d $(ROOT)/$(BINDIR) ]; then mkdir $(ROOT)/$(BINDIR); fi
	
clean :
	rm -rf $(ROOT)/obj/*.o
