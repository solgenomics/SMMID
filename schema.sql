
create table dbuser (
       dbuser_id serial primary key,
       username varchar(100),
       password text,
       first_name varchar(100),
       last_name varchar(100),
       organization varchar(100),
       address text,
       phone_number varchar(100),
       email varchar(100),
       registration_email varchar(100),
       cookie_string text,
       disabled varchar(100),
       last_access_time timestamp without time zone,
       user_type varchar(100),
       creation_date timestamp without time zone,
       last_modified_date timestamp without time zone
       );


create table compound (
       compound_id serial primary key,
       smid_id varchar(100) unique not null,		
       formula text unique not null,
       iupac_name text not null,
       organisms text,
       smiles text  unique not null,
       curation_status varchar(100),
       dbuser_id bigint references dbuser,
       curator_id bigint references dbuser,
       last_curated_time timestamp without time zone,
       create_date timestamp without time zone,
       last_modified_date timestamp without time zone
       );

create table compound_dbxref (
       compound_dbxref_id serial primary key,
       compound_id bigint references compound,
       dbxref_id bigint references dbxref,
       dbuser_id bigint references dbuser
       );


create table dbxref (
       dbxref_id serial primary key,
       db_id   bigint references db,
       accession varchar(255),
       version varchar(255),
       description text
       );

create table db (
       db_id serial primary key,
       name varchar(255),
       description varchar(255),
       urlprefix varchar(255),
       url varchar(255)
       );

create table experiment (
       experiment_id serial primary key,
       name varchar(100),
       description text,
       notes text,
       experiment_type varchar(100),
       run_date timestamp without time zone,
       create_date timestamp without time zone,
       dbuser_id bigint references dbuser,
       operator varchar(100),
       compound_id bigint references compound not null
       );

-- create table result (
--        result_id serial primary key,
--        method_type varchar(100) not null,
--        name varchar(100),
--        description text,
--        notes text,
--        data jsonb not null,
--        dbuser_id bigint references dbuser,
--        create_date timestamp without time zone,
--        modified_date timestamp without time zone
--        );

