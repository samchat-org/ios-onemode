//
//  SAMCDataBaseMacro.h
//  SamChat
//
//  Created by HJ on 8/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#ifndef SAMCDataBaseMacro_h
#define SAMCDataBaseMacro_h


#define SAMC_CREATE_USERINFO_TABLE_SQL_2016082201 @"CREATE TABLE IF NOT EXISTS userinfo(serial INTEGER PRIMARY KEY AUTOINCREMENT, \
unique_id TEXT UNIQUE, username TEXT NOT NULL, samchat_id TEXT, usertype INTEGER, lastupdate INTEGER, \
avatar TEXT, avatar_original TEXT, countrycode TEXT, cellphone TEXT, \
email TEXT, address TEXT, sp_company_name TEXT, sp_service_category TEXT, \
sp_service_description TEXT, sp_countrycode TEXT, sp_phone TEXT, sp_address TEXT, sp_email TEXT)"
#define SAMC_CREATE_USERINFO_TABLE_UNIQUE_ID_INDEX_SQL_2016082201 @"CREATE INDEX IF NOT EXISTS unique_id_index ON userinfo(unique_id)"
#define SAMC_CREATE_USERINFO_TABLE_USERNAME_INDEX_SQL_2016082201 @"CREATE index IF NOT EXISTS username_index ON userinfo(username)"

#define SAMC_CREATE_CONTACT_LIST_TABLE_SQL_2016082201 @"CREATE TABLE IF NOT EXISTS contact_list(\
serial INTEGER PRIMARY KEY AUTOINCREMENT, unique_id TEXT, tag text)"

#define SAMC_CREATE_CONTACT_LIST_VERSION_TABLE_SQL_2016082201 @"CREATE TABLE IF NOT EXISTS contact_list_version(\
type INTEGER, version TEXT, UNIQUE(type))"

#define SAMC_CREATE_FOLLOW_LIST_TABLE_SQL_2016082201 @"CREATE TABLE IF NOT EXISTS follow_list(serial INTEGER PRIMARY KEY AUTOINCREMENT, \
unique_id TEXT UNIQUE, username TEXT NOT NULL, avatar TEXT, block_tag INTEGER, \
favourite_tag INTEGER, sp_service_category TEXT)"

#define SAMC_CREATE_FOLLOW_LIST_VERSION_TABLE_SQL_2016082201 @"CREATE TABLE IF NOT EXISTS follow_list_version(\
type INTEGER, version TEXT, UNIQUE(type))"


#endif /* SAMCDataBaseMacro_h */
