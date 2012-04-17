FLEX=mxmlc
ROOT=`pwd`
BINDIR=$(ROOT)/bin
SRCDIR=$(ROOT)/src
FLAGS=-static-link-runtime-shared-libraries=true
PATH:=${PATH}:/opt/flex/bin
export PATH
	
player : debug
	$(FLEX) $(FLAGS) $(SRCDIR)/kprftvlive.as -output=$(BINDIR)/kprftvlive.swf
	
debug :
	$(FLEX) $(FLAGS) $(SRCDIR)/kprftvlivec.as -output=$(BINDIR)/kprftvlivec.swf
	
clean :
	rm -f $(BINDIR)/kprftvlivec.swf
