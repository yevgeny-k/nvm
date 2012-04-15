/* NewVideoMixer
 *
 * Copyright (C) <2012> Communist Party of the Russian Federation <adm@kprf.ru>
 *
 * Parent class
 */
 
#include <string.h>
#include <stdio.h>
#include "moduleclass.hpp"

CNVM_Module::CNVM_Module ()
{
  name = new char (strlen("default module") + 1);
  strcpy (name, "default module");
}

CNVM_Module::~CNVM_Module()
{
  if (name) {
    delete name;
  }
}


