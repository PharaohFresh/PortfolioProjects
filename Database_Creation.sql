Create Database SlickDeals

use slickdeals

desc slickdeals

SHOW TABLES
from slickdeals

create table site_engagement(
	ID  serial,
    DS_FORUM_EXPERIENCE_KEY INT NOT NULL,
    ACTIVITY_DATE DATE NOT NULL,
    ACTIVITY_TIME DATETIME NOT NULL,
    CLIENT_ID VARCHAR(36),
    SESSION_ID VARCHAR(36),
    DIM_PAGE_KEY INT,
    IS_NEW_CLIENT_VISIT INT NOT NULL,
    IS_VALID BOOLEAN NOT NULL,
    IS_BOT BOOLEAN NOT NULL,
    DS_FORUM_DEVICETYPE_KEY INT NOT NULL,
    USER_AGENT_ID INT NOT NULL,
    DS_FORUM_USER_KEY INT,
    ATTRIBUTION_KEY BIGINT
    );
    
    CREATE TABLE site_engagement_urls(
		DIM_PAGE_KEY INT PRIMARY KEY,
        NORMALIZED_URL VARCHAR(2048) NOT NULL,
        SITE VARCHAR(128) NOT NULL,
        DOMAIN VARCHAR(50) NOT NULL,
        SUBDOMAIN VARCHAR(50),
        CANONICAL_1 BOOLEAN,
        IS_THREAD BOOLEAN NOT NULL,
        THREAD_ID INT);
        
	show tables
    from slickdeals;
    
create table experiences(
	DS_FORUM_EXPERIENCE_KEY INT PRIMARY KEY,
    EXPERIENCEID SERIAL,
    EXPERIENCE VARCHAR(128) UNIQUE);

desc site_engagement

alter table site_engagement
add UNIQUE(activity_time);

desc site_engagement_urls

alter table site_engagement_urls
add unique(normalized_url);

show tables
from slickdeals;

create table devicetypes(
	DS_FORUM_DEVICETYPE_KEY INT PRIMARY KEY NOT NULL,
    DEVICETYPEID INT UNIQUE NOT NULL,
    DEVICETYPE VARCHAR(50) UNIQUE NOT NULL);

DESC devicetypes

create table site_users(
	DS_FORUM_USER_KEY bigint PRIMARY KEY,
    JOINDATE DATETIME NOT NULL,
    JOIN_DATE_INT INT NOT NULL,
    USERNAME VARCHAR(512) NOT NULL,
    DS_FORUM_DEVICETYPE_KEY INT NOT NULL,
    DS_FORUM_EXPERIENCE_KEY INT NOT NULL,
    DIM_ACQUISITION_UTM_KEY BIGINT ,
    GS_ATTRUUID_KEY BIGINT,
    ACTION_SOURCEiD INT);
    
CREATE TABLE site_users_action_source(
	ACTION_SOURCEID SERIAL,
    SOURCE VARCHAR(2048) NOT NULL);
    
    
create table attribution(
	ID SERIAL,
    ATTRIBUTION_DATE DATETIME UNIQUE NOT NULL,
    ATTRIBUTION_DATE_INT INT NOT NULL,
    ATTRIBUTION_KEY BIGINT UNIQUE NOT NULL,
    CLIENT_ID VARCHAR(36) UNIQUE,
    SESSION_ID VARCHAR(36),
    DS_FORUM_DEVICETYPE_KEY INT,
    DS_FORUM_EXPERIENCE_KEY INT,
    DIM_UTM_KEY BIGINT,
    DS_FORUM_USER_KEY INT,
    UTM_SOURCE VARCHAR(255),
    UTM_MEDIUM VARCHAR(255),
    UTM_CAMPAIGN VARCHAR(255),
    UTM_CONTENT VARCHAR(255),
    UTM_TERM VARCHAR(255),
    REFERRING_DOMAIN VARCHAR(255),
    REFERRING_SUBDOMAIN VARCHAR(255),
    REFERRING_TLD VARCHAR(255));
    
-- need to add foreign keys to all the tables

desc site_engagement;

desc site_users;

alter table site_engagement
add foreign key (DS_FORUM_USER_KEY) REFERENCES site_users(DS_FORUM_USER_KEY);

alter table site_users
add foreign key (DS_FORUM_USER_KEY) REFERENCES site_users(DS_FORUM_USER_KEY);

alter table attribution
add foreign key(DS_FORUM_USER_KEY) REFERENCES site_users(DS_FORUM_USER_KEY);

-- data type in site users incompatible because big int != to in
-- going to change bigint to int

alter table site_users
modify DS_FORUM_USER_KEY int;

-- need to create foreign keys for attribution key which references the attribution table

alter table site_engagement
add foreign key (DIM_PAGE_KEY) REFERENCES site_engagement_urls(DIM_PAGE_KEY);

alter table site_users
add foreign key (ATTRIBUTION_KEY) REFERENCES attribution(ATTRIBUTION_KEY);

alter table attribution
add foreign key(ATTRIBUTION_KEY) REFERENCES attribution(ATTRIBUTION_KEY);

-- need to create foreign keys for dim_page_key 

alter table site_engagement
add foreign key (DIM_PAGE_KEY) REFERENCES site_engagement_urls(DIM_PAGE_KEY);


-- need to create foreign key for action_sourceid 

alter table site_users
add foreign key (ACTION_SOURCEID) REFERENCES site_users_action_source(ACTION_SOURCEID);   

desc site_users;
desc site_users_action_source;

alter table site_users
modify action_sourceid bigint unsigned


        
