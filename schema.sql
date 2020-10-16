--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4 (Debian 12.4-1.pgdg100+1)
-- Dumped by pg_dump version 12.4 (Debian 12.4-1.pgdg100+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: compound; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compound (
    compound_id integer NOT NULL,
    organisms text,
    smid_id character varying(100) NOT NULL,
    curation_status character varying(100),
    dbuser_id bigint,
    curator_id bigint,
    last_curated_time timestamp without time zone,
    create_date timestamp without time zone,
    last_modified_date timestamp without time zone,
    iupac_name text NOT NULL,
    synonyms text,
    description text,
    smiles text,
    formula text,
    molecular_weight real
);


ALTER TABLE public.compound OWNER TO postgres;

--
-- Name: compound_compound_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.compound_compound_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.compound_compound_id_seq OWNER TO postgres;

--
-- Name: compound_compound_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compound_compound_id_seq OWNED BY public.compound.compound_id;


--
-- Name: compound_dbxref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compound_dbxref (
    compound_dbxref_id integer NOT NULL,
    compound_id bigint,
    dbxref_id bigint,
    dbuser_id bigint,
    curation_status character varying(100),
    curator_id bigint,
    last_curatated_time timestamp without time zone
);


ALTER TABLE public.compound_dbxref OWNER TO postgres;

--
-- Name: compound_dbxref_compound_dbxref_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.compound_dbxref_compound_dbxref_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.compound_dbxref_compound_dbxref_id_seq OWNER TO postgres;

--
-- Name: compound_dbxref_compound_dbxref_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compound_dbxref_compound_dbxref_id_seq OWNED BY public.compound_dbxref.compound_dbxref_id;


--
-- Name: compound_image; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compound_image (
    compound_image_id integer NOT NULL,
    compound_id bigint,
    image_id bigint,
    curator_id bigint,
    last_curated_time timestamp without time zone,
    curation_status character varying(100)
);


ALTER TABLE public.compound_image OWNER TO postgres;

--
-- Name: compound_image_compound_image_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.compound_image_compound_image_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.compound_image_compound_image_id_seq OWNER TO postgres;

--
-- Name: compound_image_compound_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compound_image_compound_image_id_seq OWNED BY public.compound_image.compound_image_id;


--
-- Name: db; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.db (
    db_id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    urlprefix character varying(255),
    url character varying(255)
);


ALTER TABLE public.db OWNER TO postgres;

--
-- Name: db_db_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.db_db_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.db_db_id_seq OWNER TO postgres;

--
-- Name: db_db_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.db_db_id_seq OWNED BY public.db.db_id;


--
-- Name: dbuser; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dbuser (
    dbuser_id integer NOT NULL,
    username character varying(100),
    password text,
    first_name character varying(100),
    last_name character varying(100),
    organization character varying(100),
    address text,
    phone_number character varying(100),
    email character varying(100),
    registration_email character varying(100),
    cookie_string text,
    disabled character varying(100),
    last_access_time timestamp without time zone,
    user_type character varying(100),
    creation_date timestamp without time zone,
    last_modified_date timestamp without time zone,
    user_prefs character varying(255)
);


ALTER TABLE public.dbuser OWNER TO postgres;

--
-- Name: dbuser_dbuser_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dbuser_dbuser_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dbuser_dbuser_id_seq OWNER TO postgres;

--
-- Name: dbuser_dbuser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dbuser_dbuser_id_seq OWNED BY public.dbuser.dbuser_id;


--
-- Name: dbxref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dbxref (
    dbxref_id integer NOT NULL,
    db_id bigint,
    accession character varying(255),
    version character varying(255),
    description text,
    dbuser_id bigint
);


ALTER TABLE public.dbxref OWNER TO postgres;

--
-- Name: dbxref_dbxref_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dbxref_dbxref_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dbxref_dbxref_id_seq OWNER TO postgres;

--
-- Name: dbxref_dbxref_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dbxref_dbxref_id_seq OWNED BY public.dbxref.dbxref_id;


--
-- Name: experiment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.experiment (
    experiment_id integer NOT NULL,
    name character varying(100),
    description text,
    notes text,
    experiment_type character varying(100),
    run_date timestamp without time zone,
    create_date timestamp without time zone,
    dbuser_id bigint,
    operator character varying(100),
    data jsonb,
    compound_id bigint NOT NULL,
    curation_status character varying(100),
    curator_id bigint,
    last_curatated_time timestamp without time zone
);


ALTER TABLE public.experiment OWNER TO postgres;

--
-- Name: experiment_experiment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.experiment_experiment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.experiment_experiment_id_seq OWNER TO postgres;

--
-- Name: experiment_experiment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.experiment_experiment_id_seq OWNED BY public.experiment.experiment_id;


--
-- Name: image; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.image (
    image_id integer NOT NULL,
    image_location character varying(200),
    name character varying(100),
    description text,
    type character varying(20),
    dbuser_id bigint,
    copyright text,
    obsolete boolean DEFAULT false,
    file_ext character varying(20),
    original_filename character varying(255),
    md5sum character varying(100),
    image_taken_timestamp timestamp without time zone,
    create_date timestamp without time zone,
    modified_date timestamp without time zone DEFAULT now(),
    curation_status character varying(20) DEFAULT 'unverified'::character varying,
    last_curated_time timestamp without time zone,
    curator_id bigint
);


ALTER TABLE public.image OWNER TO postgres;

--
-- Name: image_image_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.image_image_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.image_image_id_seq OWNER TO postgres;

--
-- Name: image_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.image_image_id_seq OWNED BY public.image.image_id;


--
-- Name: result; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.result (
    result_id integer NOT NULL,
    name character varying(100),
    description text,
    notes text,
    data jsonb NOT NULL,
    dbuser_id bigint,
    create_date timestamp without time zone,
    modified_date timestamp without time zone,
    method_type character varying(100) NOT NULL
);


ALTER TABLE public.result OWNER TO postgres;

--
-- Name: result_result_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.result_result_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.result_result_id_seq OWNER TO postgres;

--
-- Name: result_result_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.result_result_id_seq OWNED BY public.result.result_id;


--
-- Name: compound compound_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound ALTER COLUMN compound_id SET DEFAULT nextval('public.compound_compound_id_seq'::regclass);


--
-- Name: compound_dbxref compound_dbxref_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound_dbxref ALTER COLUMN compound_dbxref_id SET DEFAULT nextval('public.compound_dbxref_compound_dbxref_id_seq'::regclass);


--
-- Name: compound_image compound_image_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound_image ALTER COLUMN compound_image_id SET DEFAULT nextval('public.compound_image_compound_image_id_seq'::regclass);


--
-- Name: db db_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db ALTER COLUMN db_id SET DEFAULT nextval('public.db_db_id_seq'::regclass);


--
-- Name: dbuser dbuser_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dbuser ALTER COLUMN dbuser_id SET DEFAULT nextval('public.dbuser_dbuser_id_seq'::regclass);


--
-- Name: dbxref dbxref_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dbxref ALTER COLUMN dbxref_id SET DEFAULT nextval('public.dbxref_dbxref_id_seq'::regclass);


--
-- Name: experiment experiment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiment ALTER COLUMN experiment_id SET DEFAULT nextval('public.experiment_experiment_id_seq'::regclass);


--
-- Name: image image_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image ALTER COLUMN image_id SET DEFAULT nextval('public.image_image_id_seq'::regclass);


--
-- Name: result result_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result ALTER COLUMN result_id SET DEFAULT nextval('public.result_result_id_seq'::regclass);


--
-- Name: compound_dbxref compound_dbxref_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound_dbxref
    ADD CONSTRAINT compound_dbxref_pkey PRIMARY KEY (compound_dbxref_id);


--
-- Name: compound_image compound_image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound_image
    ADD CONSTRAINT compound_image_pkey PRIMARY KEY (compound_image_id);


--
-- Name: compound compound_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound
    ADD CONSTRAINT compound_pkey PRIMARY KEY (compound_id);


--
-- Name: compound compound_smid_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound
    ADD CONSTRAINT compound_smid_id_key UNIQUE (smid_id);


--
-- Name: db db_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db
    ADD CONSTRAINT db_pkey PRIMARY KEY (db_id);


--
-- Name: dbuser dbuser_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dbuser
    ADD CONSTRAINT dbuser_pkey PRIMARY KEY (dbuser_id);


--
-- Name: dbxref dbxref_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dbxref
    ADD CONSTRAINT dbxref_pkey PRIMARY KEY (dbxref_id);


--
-- Name: experiment experiment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT experiment_pkey PRIMARY KEY (experiment_id);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (image_id);


--
-- Name: result result_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_pkey PRIMARY KEY (result_id);


--
-- Name: compound compound_curator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound
    ADD CONSTRAINT compound_curator_id_fkey FOREIGN KEY (curator_id) REFERENCES public.dbuser(dbuser_id);


--
-- Name: compound compound_dbuser_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound
    ADD CONSTRAINT compound_dbuser_id_fkey FOREIGN KEY (dbuser_id) REFERENCES public.dbuser(dbuser_id);


--
-- Name: compound_dbxref compound_dbxref_compound_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound_dbxref
    ADD CONSTRAINT compound_dbxref_compound_id_fkey FOREIGN KEY (compound_id) REFERENCES public.compound(compound_id);


--
-- Name: compound_dbxref compound_dbxref_curator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound_dbxref
    ADD CONSTRAINT compound_dbxref_curator_id_fkey FOREIGN KEY (curator_id) REFERENCES public.dbuser(dbuser_id);


--
-- Name: compound_dbxref compound_dbxref_dbuser_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound_dbxref
    ADD CONSTRAINT compound_dbxref_dbuser_id_fkey FOREIGN KEY (dbuser_id) REFERENCES public.dbuser(dbuser_id);


--
-- Name: compound_dbxref compound_dbxref_dbxref_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound_dbxref
    ADD CONSTRAINT compound_dbxref_dbxref_id_fkey FOREIGN KEY (dbxref_id) REFERENCES public.dbxref(dbxref_id);


--
-- Name: compound_image compound_image_compound_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound_image
    ADD CONSTRAINT compound_image_compound_id_fkey FOREIGN KEY (compound_id) REFERENCES public.compound(compound_id);


--
-- Name: compound_image compound_image_curator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound_image
    ADD CONSTRAINT compound_image_curator_id_fkey FOREIGN KEY (curator_id) REFERENCES public.dbuser(dbuser_id);


--
-- Name: compound_image compound_image_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compound_image
    ADD CONSTRAINT compound_image_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.image(image_id);


--
-- Name: dbxref dbxref_db_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dbxref
    ADD CONSTRAINT dbxref_db_id_fkey FOREIGN KEY (db_id) REFERENCES public.db(db_id);


--
-- Name: dbxref dbxref_dbuser_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dbxref
    ADD CONSTRAINT dbxref_dbuser_id_fkey FOREIGN KEY (dbuser_id) REFERENCES public.dbuser(dbuser_id);


--
-- Name: experiment experiment_compound_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT experiment_compound_id_fkey FOREIGN KEY (compound_id) REFERENCES public.compound(compound_id);


--
-- Name: experiment experiment_curator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT experiment_curator_id_fkey FOREIGN KEY (curator_id) REFERENCES public.dbuser(dbuser_id);


--
-- Name: experiment experiment_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT experiment_user_id_fkey FOREIGN KEY (dbuser_id) REFERENCES public.dbuser(dbuser_id);


--
-- Name: image image_curator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_curator_id_fkey FOREIGN KEY (curator_id) REFERENCES public.dbuser(dbuser_id);


--
-- Name: image image_dbuser_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_dbuser_id_fkey FOREIGN KEY (dbuser_id) REFERENCES public.dbuser(dbuser_id);


--
-- Name: result result_dbuser_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_dbuser_id_fkey FOREIGN KEY (dbuser_id) REFERENCES public.dbuser(dbuser_id);


--
-- PostgreSQL database dump complete
--

