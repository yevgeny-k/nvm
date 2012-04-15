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
#include <mysql/mysql.h>
#include "../core.hpp"
#include "ccontentmodule.hpp"
#include "randplay.hpp"

extern log4cpp::Category *log;
extern Scfg *cfg;

CRandPlayer::CRandPlayer(): maxitems(50)
{
  log->debug("Construct randome player module");
  name = new char [strlen("randplayer") + 1];
  strcpy (name, "randplayer");
  info = new char [strlen("Randome player module") + 1];
  strcpy (info, "Randome player module");  
  
  dblink = mysql_init(NULL);
  mysql_options(dblink, MYSQL_SET_CHARSET_NAME, "utf8");
  my_bool reconnect = 1;
  mysql_options(dblink, MYSQL_OPT_RECONNECT, &reconnect);
  
  strcpy (lastpath, "");
}

CRandPlayer::~CRandPlayer()
{
  delete [] name;
  delete [] info;
  mysql_close (dblink);
  log->debug("Randome player module destroy");
}

bool CRandPlayer::initConnectToDB()
{  
  if (!mysql_real_connect(dblink, cfg->dbserver, cfg->dbuser, cfg->dbpassword, cfg->database, cfg->dbport, NULL, 0)) {
		log->error ("Error connect to database. (%d): %s", mysql_errno(dblink), mysql_error(dblink));
		return false;
	} else {
		log->info ("Connect to database establish");
		return true;
	}
}

bool CRandPlayer::refreshList()
{
  char querytmp[300];
  char q[] = "SELECT fm.uri FROM node as n LEFT JOIN field_data_field_videoclip as v ON (n.nid = v.entity_id) LEFT JOIN file_managed as fm ON (v.field_videoclip_fid = fm.fid) WHERE fm.uri IS NOT NULL ORDER BY created DESC limit %d";  
 	MYSQL_RES *result;
	MYSQL_ROW row;
	int i;
	 
  log->debug("Refresh video list");  
  mysql_ping (dblink);
  
  for (i=0; i < fileamount; i++)
    delete [] filelist[i];
  if (fileamount)
    delete [] filelist;
  fileamount = 0;

  sprintf (querytmp, q, maxitems);
  
  if (mysql_query(dblink, querytmp)) {
    log->error ("Error query: %s", mysql_error(dblink));
    return false;
  }
  result = mysql_store_result(dblink);
  
  fileamount = mysql_num_rows(result);
  filelist = new char* [fileamount];
  
  i = 0;
  char buff[300];
  char tmp [300];
  char *pch;
  
  while ((row = mysql_fetch_row(result)))
  {
    strcpy (buff, row[0]);
    pch = strstr (buff, "public://");
    if (pch != NULL)
    {
      pch += strlen ("public://");
      sprintf (tmp, "%s/%s", cfg->videopath, pch);
      filelist[i] = new char [strlen(tmp) + 1];
      strcpy (filelist[i], tmp);
      i++;
    }
  }
  fileamount = i;
  mysql_free_result(result);
}

void CRandPlayer::randSelect()
{
  int cur, i = 0;
  srand (time (NULL));
  log->debug("Rand select");

  while (true)
  {
    i++;
    cur = rand() % fileamount + 1;
    if (strcmp (filelist[cur], lastpath))
    {
      strcpy (lastpath, filelist[cur]);
      break;
    } else {
      continue;
    }
    if (i >= 20)
    {
      break;
    }
  }
}

void CRandPlayer::play()
{
  log->debug("Randome player module is played");
  refreshList();
  randSelect();
  log->debug("lastpath: %s", lastpath);
}

void CRandPlayer::pause()
{
  log->debug("Randome player module paused");
}
