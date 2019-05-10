-- COMP9311 18s2 Assignment 1
-- Schema for the myPhotos.net photo-sharing site
--
-- Written by:
--    Name:  <<PAN LUO>>
--    Student ID:  <<Z5192086>>
--    Date:  30/08/2018
--
-- Conventions:
-- * all entity table names are plural
-- * most entities have an artifical primary key called "id"
-- * foreign keys are named after either:
--   * the relationship they represent
--   * the table being referenced

-- Domains (you may add more)

create domain URLValue as
	varchar(100) check (value like 'http://%');

create domain EmailValue as
	varchar(100) check (value like '%@%.%');

create domain GenderValue as
	varchar(6) check (value in ('male','female'));

create domain GroupModeValue as
	varchar(15) check (value in ('private','by-invitation','by-request'));

create domain ContactListTypeValue as
	varchar(10) check (value in ('friends','family'));

create domain NameValue as varchar(50);

create domain LongNameValue as varchar(100);

create domain PhotoSizeValue as varchar(8)
check (value ~ '^[0-9]{1,6}%KB$');

create domain VisibilityValue as varchar(15)
check (value in ('private', 'friends', 'family', 'friends+family', 'public'));

create domain SafetyLevel as varchar(10)
check (value in ('safe', 'moderate', 'restricted'));

create domain ContactListType as varchar(7)
check (value in ('friends','family',NULL));


create domain RatingValue as integer
check (value in (1,2,3,4,5));

create domain OrderValue as integer
check (value > 0);



-- Tables (you must add more)

create table People (
	id          serial,
	family_name NameValue,
	given_name NameValue NOT NULL,
	displayed_name LongNameValue,
	email_address EmailValue NOT NULL,
	primary key (id)
);


create table Users (
	id integer references People(id),
	website URLValue,
	date_registered date,
	gender GenderValue,
	birthday date,
	password text NOT NULL,
	portrait integer,
	primary key (id)
);

create table Groups (
	id serial,
	owner integer not null references Users(id),
	title text,
	mode GroupModeValue,
	primary key (id)
);

create table Contact_lists (
	id serial,
	user_id integer references Users(id),
	title text not null,
	type contactlisttype,
	primary key (id)
);

create table People_Members_Contact_lists(
	people_id integer references People(id),
	contact_list_id integer references Contact_lists(id),
	primary key (people_id,contact_list_id)
);

create table Users_Members_Group(
	user_id integer references Users(id),
	group_id integer references Groups(id),
	owner_member integer references Groups(id) NOT NULL,
	primary key (user_id,group_id)
);


create table Photos (
	id serial,
	owner integer references Users(id),
	discussion_id integer,
	title varchar(50),
	date_taken timestamp,
	date_uploaded timestamp,
	file_size PhotoSizeValue,
	visibility VisibilityValue,
	safety_level SafetyLevel,
	description text,
	technical_details text,
	primary key (id)
);


alter table Users add constraint AddReferences foreign key (portrait) references Photos(id);


create table Tags(
	id serial,
	name varchar(50) unique not null,
	had_freq integer,
	primary key (id)
);


create table Photos_have_Tags(
	have_id integer references Photos(id),
	tag_id integer references Tags(id),
	when_tagged timestamp,
	primary key (have_id,tag_id)
);

create table Users_Rates_Photos (
	user_id integer references Users(id),
	photo_id integer references Photos(id),
	rating RatingValue,
	when_rated timestamp,
	who_reted integer references Users(id),
	primary key (user_id,photo_id)
);

create table Collections(
	id serial,
	title varchar(50) not null,
	description text,
	photo_id integer references Photos(id),
	is_user_collection boolean,
	is_group_collection boolean,
	primary key (id)
);

create table User_Collections(
	id integer references Collections(id),
	user_id integer references Users(id),
	primary key (id)
);

create table Group_Collections(
	id integer references Collections(id),
	group_id integer references Groups(id),
	primary key (id)
);

create table Photos_in_Collections(
	photo_id integer references Photos(id),
	collection_id integer references Collections(id),
	"order" OrderValue,
	primary key (photo_id,collection_id)
);


create table Discussions(
	id serial,
	title varchar(50),
	primary key (id)
);


alter table Photos add constraint AddReferences foreign key (discussion_id) references Discussions(id);


create table Discussions_under_groups(
	group_id integer references Groups(id),	
	discussion_id integer references Discussions(id),
	title varchar(50),
	primary key (group_id,discussion_id)
);

create table Comments(
	id serial,
	discussion_id integer references Discussions(id),
	author integer references Users(id),
	when_posted timestamp,
	content text,
	comment_comment integer references Comments(id),
	primary key (id)
);



