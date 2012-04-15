/* NewVideoMixer
 *
 * Copyright (C) <2012> Communist Party of the Russian Federation <adm@kprf.ru>
 *
 * Parent class for content modules
 */
 
#include <string.h>
#include <stdio.h>
#include "ccontentmodule.hpp"

CContentModule::CContentModule ()
{
  name = new char (strlen("default module") + 1);
  strcpy (name, "default module");
}

CContentModule::~CContentModule()
{
  if (name) {
    delete name;
  }
}


