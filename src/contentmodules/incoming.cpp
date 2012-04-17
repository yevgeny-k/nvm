/* 
 * Copyright (C) <2012> Communist Party of the Russian Federation <adm@kprf.ru>
 *
 */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <gst/gst.h>
#include <log4cpp/Category.hh>
#include "../core.hpp"
#include "ccontentmodule.hpp"
#include "incoming.hpp"

extern log4cpp::Category *log;
extern Scfg *cfg;

CIncomingConnection::CIncomingConnection()
{
  log->debug ("Construct incoming connection module");

  log->debug ("Incoming connection module constructed");
}

CIncomingConnection::~CIncomingConnection()
{


}

void icmanager ()
{


}
