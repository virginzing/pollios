--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: access_webs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE access_webs (
    id integer NOT NULL,
    member_id integer,
    accessable_id integer,
    accessable_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: access_webs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE access_webs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_webs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE access_webs_id_seq OWNED BY access_webs.id;


--
-- Name: activity_feeds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE activity_feeds (
    id integer NOT NULL,
    member_id integer,
    action character varying(255),
    trackable_id integer,
    trackable_type character varying(255),
    group_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: activity_feeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activity_feeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_feeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activity_feeds_id_seq OWNED BY activity_feeds.id;


--
-- Name: admins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admins (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admins_id_seq OWNED BY admins.id;


--
-- Name: apn_apps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE apn_apps (
    id integer NOT NULL,
    apn_dev_cert text,
    apn_prod_cert text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: apn_apps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE apn_apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apn_apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE apn_apps_id_seq OWNED BY apn_apps.id;


--
-- Name: apn_device_groupings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE apn_device_groupings (
    id integer NOT NULL,
    group_id integer,
    device_id integer
);


--
-- Name: apn_device_groupings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE apn_device_groupings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apn_device_groupings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE apn_device_groupings_id_seq OWNED BY apn_device_groupings.id;


--
-- Name: apn_devices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE apn_devices (
    id integer NOT NULL,
    token character varying(255) NOT NULL,
    member_id integer,
    api_token character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    last_registered_at timestamp without time zone,
    app_id integer
);


--
-- Name: apn_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE apn_devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apn_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE apn_devices_id_seq OWNED BY apn_devices.id;


--
-- Name: apn_group_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE apn_group_notifications (
    id integer NOT NULL,
    group_id integer NOT NULL,
    device_language character varying(255),
    sound character varying(255),
    alert character varying(255),
    badge integer,
    custom_properties text,
    sent_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: apn_group_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE apn_group_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apn_group_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE apn_group_notifications_id_seq OWNED BY apn_group_notifications.id;


--
-- Name: apn_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE apn_groups (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    app_id integer
);


--
-- Name: apn_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE apn_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apn_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE apn_groups_id_seq OWNED BY apn_groups.id;


--
-- Name: apn_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE apn_notifications (
    id integer NOT NULL,
    device_id integer NOT NULL,
    errors_nb integer DEFAULT 0,
    device_language character varying(255),
    sound character varying(255),
    alert character varying(255),
    badge integer,
    sent_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    custom_properties text
);


--
-- Name: apn_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE apn_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apn_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE apn_notifications_id_seq OWNED BY apn_notifications.id;


--
-- Name: apn_pull_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE apn_pull_notifications (
    id integer NOT NULL,
    app_id integer,
    title character varying(255),
    content character varying(255),
    link character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    launch_notification boolean
);


--
-- Name: apn_pull_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE apn_pull_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apn_pull_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE apn_pull_notifications_id_seq OWNED BY apn_pull_notifications.id;


--
-- Name: bookmarks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bookmarks (
    id integer NOT NULL,
    member_id integer,
    bookmarkable_id integer,
    bookmarkable_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: bookmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bookmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bookmarks_id_seq OWNED BY bookmarks.id;


--
-- Name: branch_poll_series; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE branch_poll_series (
    id integer NOT NULL,
    branch_id integer,
    poll_series_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: branch_poll_series_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE branch_poll_series_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branch_poll_series_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE branch_poll_series_id_seq OWNED BY branch_poll_series.id;


--
-- Name: branch_polls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE branch_polls (
    id integer NOT NULL,
    poll_id integer,
    branch_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: branch_polls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE branch_polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branch_polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE branch_polls_id_seq OWNED BY branch_polls.id;


--
-- Name: branches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE branches (
    id integer NOT NULL,
    name character varying(255),
    address text,
    company_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    slug character varying(255),
    note text
);


--
-- Name: branches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE branches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE branches_id_seq OWNED BY branches.id;


--
-- Name: campaign_guests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE campaign_guests (
    id integer NOT NULL,
    campaign_id integer,
    guest_id integer,
    luck boolean,
    serail_code character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: campaign_guests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE campaign_guests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaign_guests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE campaign_guests_id_seq OWNED BY campaign_guests.id;


--
-- Name: campaign_members; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE campaign_members (
    id integer NOT NULL,
    campaign_id integer,
    member_id integer,
    luck boolean,
    serial_code character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    redeem boolean DEFAULT false,
    redeem_at timestamp without time zone,
    poll_id integer
);


--
-- Name: campaign_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE campaign_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaign_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE campaign_members_id_seq OWNED BY campaign_members.id;


--
-- Name: campaigns; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE campaigns (
    id integer NOT NULL,
    name character varying(255),
    photo_campaign character varying(255),
    used integer DEFAULT 0,
    "limit" integer DEFAULT 0,
    member_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    begin_sample integer DEFAULT 1,
    end_sample integer,
    expire timestamp without time zone,
    description text,
    how_to_redeem text,
    company_id integer
);


--
-- Name: campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE campaigns_id_seq OWNED BY campaigns.id;


--
-- Name: choices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE choices (
    id integer NOT NULL,
    poll_id integer,
    answer character varying(255),
    vote integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    vote_guest integer DEFAULT 0,
    correct boolean DEFAULT false
);


--
-- Name: choices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE choices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: choices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE choices_id_seq OWNED BY choices.id;


--
-- Name: collection_poll_branches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collection_poll_branches (
    id integer NOT NULL,
    branch_id integer,
    collection_poll_id integer,
    poll_series_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: collection_poll_branches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collection_poll_branches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_poll_branches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collection_poll_branches_id_seq OWNED BY collection_poll_branches.id;


--
-- Name: collection_poll_series; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collection_poll_series (
    id integer NOT NULL,
    title character varying(255),
    company_id integer,
    sum_view_all integer DEFAULT 0,
    sum_vote_all integer DEFAULT 0,
    questions character varying(255)[] DEFAULT '{}'::character varying[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: collection_poll_series_branches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collection_poll_series_branches (
    id integer NOT NULL,
    collection_poll_series_id integer,
    branch_id integer,
    poll_series_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: collection_poll_series_branches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collection_poll_series_branches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_poll_series_branches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collection_poll_series_branches_id_seq OWNED BY collection_poll_series_branches.id;


--
-- Name: collection_poll_series_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collection_poll_series_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_poll_series_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collection_poll_series_id_seq OWNED BY collection_poll_series.id;


--
-- Name: collection_polls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collection_polls (
    id integer NOT NULL,
    title character varying(255),
    company_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    sum_view_all integer DEFAULT 0,
    sum_vote_all integer DEFAULT 0,
    questions character varying(255)[] DEFAULT '{}'::character varying[]
);


--
-- Name: collection_polls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collection_polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collection_polls_id_seq OWNED BY collection_polls.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    poll_id integer,
    member_id integer,
    message character varying(255),
    delete_status boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE companies (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    short_name character varying(255) DEFAULT 'CA'::character varying,
    member_id integer,
    address character varying(255),
    telephone_number character varying(255),
    max_invite_code integer DEFAULT 0,
    internal_poll integer DEFAULT 0,
    using_service character varying(255)[] DEFAULT '{}'::character varying[]
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE companies_id_seq OWNED BY companies.id;


--
-- Name: company_members; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE company_members (
    id integer NOT NULL,
    company_id integer,
    member_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: company_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE company_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: company_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE company_members_id_seq OWNED BY company_members.id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE devices (
    id integer NOT NULL,
    member_id integer,
    token text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    api_token character varying(255)
);


--
-- Name: devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE devices_id_seq OWNED BY devices.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE friendly_id_slugs (
    id integer NOT NULL,
    slug character varying(255) NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying(255),
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friendly_id_slugs_id_seq OWNED BY friendly_id_slugs.id;


--
-- Name: friends; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE friends (
    id integer NOT NULL,
    follower_id integer,
    followed_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT true,
    block boolean DEFAULT false,
    mute boolean DEFAULT false,
    visible_poll boolean DEFAULT true,
    status integer,
    following boolean DEFAULT false,
    close_friend boolean DEFAULT false
);


--
-- Name: friends_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friends_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friends_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friends_id_seq OWNED BY friends.id;


--
-- Name: group_companies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_companies (
    id integer NOT NULL,
    group_id integer,
    company_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    main_group boolean DEFAULT false
);


--
-- Name: group_companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_companies_id_seq OWNED BY group_companies.id;


--
-- Name: group_members; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_members (
    id integer NOT NULL,
    member_id integer,
    group_id integer,
    is_master boolean DEFAULT true,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT false,
    invite_id integer,
    notification boolean DEFAULT true
);


--
-- Name: group_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_members_id_seq OWNED BY group_members.id;


--
-- Name: group_surveyors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_surveyors (
    id integer NOT NULL,
    group_id integer,
    member_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: group_surveyors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_surveyors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_surveyors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_surveyors_id_seq OWNED BY group_surveyors.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    id integer NOT NULL,
    name character varying(255),
    public boolean DEFAULT false,
    photo_group character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    member_count integer DEFAULT 0,
    poll_count integer DEFAULT 0,
    authorize_invite integer,
    description text,
    leave_group boolean DEFAULT true,
    group_type integer,
    properties hstore,
    cover character varying(255),
    admin_post_only boolean DEFAULT false,
    slug character varying(255),
    need_approve boolean DEFAULT true
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: guests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE guests (
    id integer NOT NULL,
    udid character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: guests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE guests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: guests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE guests_id_seq OWNED BY guests.id;


--
-- Name: hidden_polls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE hidden_polls (
    id integer NOT NULL,
    member_id integer,
    poll_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: hidden_polls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hidden_polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hidden_polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hidden_polls_id_seq OWNED BY hidden_polls.id;


--
-- Name: history_purchases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_purchases (
    id integer NOT NULL,
    member_id integer,
    product_id character varying(255),
    transaction_id character varying(255),
    purchase_date timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: history_purchases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_purchases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_purchases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_purchases_id_seq OWNED BY history_purchases.id;


--
-- Name: history_view_guests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_view_guests (
    id integer NOT NULL,
    guest_id integer,
    poll_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: history_view_guests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_view_guests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_view_guests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_view_guests_id_seq OWNED BY history_view_guests.id;


--
-- Name: history_view_questionnaires; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_view_questionnaires (
    id integer NOT NULL,
    member_id integer,
    poll_series_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: history_view_questionnaires_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_view_questionnaires_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_view_questionnaires_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_view_questionnaires_id_seq OWNED BY history_view_questionnaires.id;


--
-- Name: history_views; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_views (
    id integer NOT NULL,
    member_id integer,
    poll_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: history_views_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_views_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_views_id_seq OWNED BY history_views.id;


--
-- Name: history_vote_guests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_vote_guests (
    id integer NOT NULL,
    guest_id integer,
    poll_id integer,
    choice_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: history_vote_guests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_vote_guests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_vote_guests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_vote_guests_id_seq OWNED BY history_vote_guests.id;


--
-- Name: history_votes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_votes (
    id integer NOT NULL,
    member_id integer,
    poll_id integer,
    choice_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    poll_series_id integer DEFAULT 0,
    data_analysis hstore,
    surveyor_id integer
);


--
-- Name: history_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_votes_id_seq OWNED BY history_votes.id;


--
-- Name: invite_codes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE invite_codes (
    id integer NOT NULL,
    code character varying(255),
    used boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    company_id integer,
    group_id integer
);


--
-- Name: invite_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE invite_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invite_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE invite_codes_id_seq OWNED BY invite_codes.id;


--
-- Name: member_invite_codes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE member_invite_codes (
    id integer NOT NULL,
    member_id integer,
    invite_code_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: member_invite_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE member_invite_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: member_invite_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE member_invite_codes_id_seq OWNED BY member_invite_codes.id;


--
-- Name: member_report_members; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE member_report_members (
    id integer NOT NULL,
    reporter_id integer,
    reportee_id integer,
    message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: member_report_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE member_report_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: member_report_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE member_report_members_id_seq OWNED BY member_report_members.id;


--
-- Name: member_report_polls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE member_report_polls (
    id integer NOT NULL,
    member_id integer,
    poll_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    message text
);


--
-- Name: member_report_polls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE member_report_polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: member_report_polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE member_report_polls_id_seq OWNED BY member_report_polls.id;


--
-- Name: member_un_recomments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE member_un_recomments (
    id integer NOT NULL,
    member_id integer,
    unrecomment_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: member_un_recomments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE member_un_recomments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: member_un_recomments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE member_un_recomments_id_seq OWNED BY member_un_recomments.id;


--
-- Name: members; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE members (
    id integer NOT NULL,
    fullname character varying(255),
    username character varying(255),
    avatar character varying(255),
    email character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    group_active boolean DEFAULT false,
    friend_limit integer,
    friend_count integer DEFAULT 0,
    member_type integer DEFAULT 0,
    key_color character varying(255),
    poll_public_req_at timestamp without time zone DEFAULT '2014-05-12 07:38:10.352978'::timestamp without time zone,
    poll_overall_req_at timestamp without time zone DEFAULT '2014-05-12 11:39:19.214358'::timestamp without time zone,
    cover character varying(255),
    description text,
    apn_add_friend boolean DEFAULT true,
    apn_invite_group boolean DEFAULT true,
    apn_poll_friend boolean DEFAULT true,
    sync_facebook boolean DEFAULT false,
    report_power integer DEFAULT 1,
    anonymous boolean DEFAULT false,
    anonymous_public boolean DEFAULT false,
    anonymous_friend_following boolean DEFAULT false,
    anonymous_group boolean DEFAULT false,
    report_count integer DEFAULT 0,
    status_account integer DEFAULT 1,
    first_signup boolean DEFAULT true,
    point integer DEFAULT 0,
    subscription boolean DEFAULT false,
    subscribe_last timestamp without time zone,
    subscribe_expire timestamp without time zone,
    bypass_invite boolean DEFAULT false,
    auth_token character varying(255),
    approve_brand boolean DEFAULT false,
    approve_company boolean DEFAULT false,
    gender integer,
    province integer,
    birthday date,
    interests text,
    salary integer,
    setting hstore,
    update_personal boolean DEFAULT false,
    notification_count integer DEFAULT 0,
    request_count integer DEFAULT 0,
    cover_preset character varying(255) DEFAULT '0'::character varying,
    register integer DEFAULT 0,
    slug character varying(255)
);


--
-- Name: members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE members_id_seq OWNED BY members.id;


--
-- Name: members_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE members_roles (
    member_id integer,
    role_id integer
);


--
-- Name: mentions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mentions (
    id integer NOT NULL,
    comment_id integer,
    mentioner_id integer,
    mentioner_name character varying(255),
    mentionable_id integer,
    mentionable_name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: mentions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mentions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mentions_id_seq OWNED BY mentions.id;


--
-- Name: notify_logs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notify_logs (
    id integer NOT NULL,
    sender_id integer,
    recipient_id integer,
    message character varying(255),
    custom_properties text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: notify_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notify_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notify_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notify_logs_id_seq OWNED BY notify_logs.id;


--
-- Name: pg_search_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pg_search_documents (
    id integer NOT NULL,
    content text,
    searchable_id integer,
    searchable_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pg_search_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pg_search_documents_id_seq OWNED BY pg_search_documents.id;


--
-- Name: poll_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE poll_groups (
    id integer NOT NULL,
    poll_id integer,
    group_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    share_poll_of_id integer DEFAULT 0,
    member_id integer
);


--
-- Name: poll_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE poll_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: poll_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE poll_groups_id_seq OWNED BY poll_groups.id;


--
-- Name: poll_members; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE poll_members (
    id integer NOT NULL,
    member_id integer,
    poll_id integer,
    share_poll_of_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    public boolean,
    series boolean,
    expire_date timestamp without time zone,
    in_group boolean DEFAULT false,
    poll_series_id integer DEFAULT 0
);


--
-- Name: poll_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE poll_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: poll_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE poll_members_id_seq OWNED BY poll_members.id;


--
-- Name: poll_series; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE poll_series (
    id integer NOT NULL,
    member_id integer,
    description text,
    number_of_poll integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    vote_all integer DEFAULT 0,
    view_all integer DEFAULT 0,
    expire_date timestamp without time zone,
    start_date timestamp without time zone DEFAULT '2014-02-03 15:36:16.856868'::timestamp without time zone,
    campaign_id integer,
    vote_all_guest integer DEFAULT 0,
    view_all_guest integer DEFAULT 0,
    share_count integer DEFAULT 0,
    type_series integer DEFAULT 0,
    type_poll integer,
    public boolean DEFAULT true,
    in_group_ids character varying(255) DEFAULT '0'::character varying,
    allow_comment boolean DEFAULT true,
    comment_count integer DEFAULT 0,
    qr_only boolean,
    qrcode_key character varying(255),
    require_info boolean,
    in_group boolean DEFAULT false,
    recurring_id integer,
    feedback boolean DEFAULT false
);


--
-- Name: poll_series_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE poll_series_groups (
    id integer NOT NULL,
    poll_series_id integer,
    group_id integer,
    member_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: poll_series_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE poll_series_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: poll_series_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE poll_series_groups_id_seq OWNED BY poll_series_groups.id;


--
-- Name: poll_series_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE poll_series_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: poll_series_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE poll_series_id_seq OWNED BY poll_series.id;


--
-- Name: poll_series_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE poll_series_tags (
    id integer NOT NULL,
    poll_series_id integer,
    tag_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: poll_series_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE poll_series_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: poll_series_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE poll_series_tags_id_seq OWNED BY poll_series_tags.id;


--
-- Name: polls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE polls (
    id integer NOT NULL,
    member_id integer,
    title character varying(255),
    public boolean DEFAULT false,
    vote_all integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    photo_poll character varying(255),
    expire_date timestamp without time zone,
    view_all integer DEFAULT 0,
    start_date timestamp without time zone DEFAULT '2014-02-03 15:36:16.519109'::timestamp without time zone,
    series boolean DEFAULT false,
    poll_series_id integer,
    choice_count integer,
    campaign_id integer,
    vote_all_guest integer DEFAULT 0,
    view_all_guest integer DEFAULT 0,
    favorite_count integer DEFAULT 0,
    share_count integer DEFAULT 0,
    recurring_id integer DEFAULT 0,
    in_group_ids character varying(255),
    qrcode_key character varying(255),
    type_poll integer,
    report_count integer DEFAULT 0,
    status_poll integer DEFAULT 0,
    allow_comment boolean DEFAULT true,
    comment_count integer DEFAULT 0,
    member_type character varying(255),
    loadedfeed_count integer DEFAULT 0,
    qr_only boolean,
    require_info boolean,
    expire_status boolean DEFAULT false,
    creator_must_vote boolean DEFAULT true,
    in_group boolean DEFAULT false,
    show_result boolean DEFAULT true,
    order_poll integer DEFAULT 1,
    quiz boolean DEFAULT false,
    notify_state integer DEFAULT 0,
    notify_state_at timestamp without time zone,
    slug character varying(255)
);


--
-- Name: polls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE polls_id_seq OWNED BY polls.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE profiles (
    id integer NOT NULL,
    member_id integer,
    birthday date,
    gender integer,
    interests text,
    salary character varying(255),
    province integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profiles_id_seq OWNED BY profiles.id;


--
-- Name: providers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE providers (
    id integer NOT NULL,
    name character varying(255),
    pid character varying(255),
    token character varying(255),
    member_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE providers_id_seq OWNED BY providers.id;


--
-- Name: provinces; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE provinces (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: provinces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE provinces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: provinces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE provinces_id_seq OWNED BY provinces.id;


--
-- Name: recurrings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE recurrings (
    id integer NOT NULL,
    period time without time zone,
    status integer,
    member_id integer,
    end_recur timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description character varying(255),
    company_id integer
);


--
-- Name: recurrings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE recurrings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recurrings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE recurrings_id_seq OWNED BY recurrings.id;


--
-- Name: request_codes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE request_codes (
    id integer NOT NULL,
    member_id integer,
    custom_properties text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: request_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: request_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE request_codes_id_seq OWNED BY request_codes.id;


--
-- Name: request_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE request_groups (
    id integer NOT NULL,
    member_id integer,
    group_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    accepter_id integer,
    accepted boolean DEFAULT false
);


--
-- Name: request_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: request_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE request_groups_id_seq OWNED BY request_groups.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(255),
    resource_id integer,
    resource_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: save_poll_laters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE save_poll_laters (
    id integer NOT NULL,
    member_id integer,
    savable_id integer,
    savable_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: save_poll_laters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE save_poll_laters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: save_poll_laters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE save_poll_laters_id_seq OWNED BY save_poll_laters.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: share_polls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE share_polls (
    id integer NOT NULL,
    member_id integer,
    poll_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    shared_group_id integer DEFAULT 0
);


--
-- Name: share_polls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE share_polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: share_polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE share_polls_id_seq OWNED BY share_polls.id;


--
-- Name: suggests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE suggests (
    id integer NOT NULL,
    poll_series_id integer,
    member_id integer,
    message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: suggests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE suggests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: suggests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE suggests_id_seq OWNED BY suggests.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer,
    poll_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: un_see_polls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE un_see_polls (
    id integer NOT NULL,
    member_id integer,
    unseeable_id integer,
    unseeable_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: un_see_polls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE un_see_polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: un_see_polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE un_see_polls_id_seq OWNED BY un_see_polls.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: watcheds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE watcheds (
    id integer NOT NULL,
    member_id integer,
    poll_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    poll_notify boolean DEFAULT true,
    comment_notify boolean DEFAULT true
);


--
-- Name: watcheds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE watcheds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: watcheds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE watcheds_id_seq OWNED BY watcheds.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY access_webs ALTER COLUMN id SET DEFAULT nextval('access_webs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activity_feeds ALTER COLUMN id SET DEFAULT nextval('activity_feeds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admins ALTER COLUMN id SET DEFAULT nextval('admins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY apn_apps ALTER COLUMN id SET DEFAULT nextval('apn_apps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY apn_device_groupings ALTER COLUMN id SET DEFAULT nextval('apn_device_groupings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY apn_devices ALTER COLUMN id SET DEFAULT nextval('apn_devices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY apn_group_notifications ALTER COLUMN id SET DEFAULT nextval('apn_group_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY apn_groups ALTER COLUMN id SET DEFAULT nextval('apn_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY apn_notifications ALTER COLUMN id SET DEFAULT nextval('apn_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY apn_pull_notifications ALTER COLUMN id SET DEFAULT nextval('apn_pull_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bookmarks ALTER COLUMN id SET DEFAULT nextval('bookmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY branch_poll_series ALTER COLUMN id SET DEFAULT nextval('branch_poll_series_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY branch_polls ALTER COLUMN id SET DEFAULT nextval('branch_polls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY branches ALTER COLUMN id SET DEFAULT nextval('branches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaign_guests ALTER COLUMN id SET DEFAULT nextval('campaign_guests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaign_members ALTER COLUMN id SET DEFAULT nextval('campaign_members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaigns ALTER COLUMN id SET DEFAULT nextval('campaigns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY choices ALTER COLUMN id SET DEFAULT nextval('choices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_poll_branches ALTER COLUMN id SET DEFAULT nextval('collection_poll_branches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_poll_series ALTER COLUMN id SET DEFAULT nextval('collection_poll_series_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_poll_series_branches ALTER COLUMN id SET DEFAULT nextval('collection_poll_series_branches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_polls ALTER COLUMN id SET DEFAULT nextval('collection_polls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY companies ALTER COLUMN id SET DEFAULT nextval('companies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY company_members ALTER COLUMN id SET DEFAULT nextval('company_members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY devices ALTER COLUMN id SET DEFAULT nextval('devices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('friendly_id_slugs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friends ALTER COLUMN id SET DEFAULT nextval('friends_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_companies ALTER COLUMN id SET DEFAULT nextval('group_companies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_members ALTER COLUMN id SET DEFAULT nextval('group_members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_surveyors ALTER COLUMN id SET DEFAULT nextval('group_surveyors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY guests ALTER COLUMN id SET DEFAULT nextval('guests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hidden_polls ALTER COLUMN id SET DEFAULT nextval('hidden_polls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_purchases ALTER COLUMN id SET DEFAULT nextval('history_purchases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_view_guests ALTER COLUMN id SET DEFAULT nextval('history_view_guests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_view_questionnaires ALTER COLUMN id SET DEFAULT nextval('history_view_questionnaires_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_views ALTER COLUMN id SET DEFAULT nextval('history_views_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_vote_guests ALTER COLUMN id SET DEFAULT nextval('history_vote_guests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_votes ALTER COLUMN id SET DEFAULT nextval('history_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invite_codes ALTER COLUMN id SET DEFAULT nextval('invite_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_invite_codes ALTER COLUMN id SET DEFAULT nextval('member_invite_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_report_members ALTER COLUMN id SET DEFAULT nextval('member_report_members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_report_polls ALTER COLUMN id SET DEFAULT nextval('member_report_polls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_un_recomments ALTER COLUMN id SET DEFAULT nextval('member_un_recomments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY members ALTER COLUMN id SET DEFAULT nextval('members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mentions ALTER COLUMN id SET DEFAULT nextval('mentions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notify_logs ALTER COLUMN id SET DEFAULT nextval('notify_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pg_search_documents ALTER COLUMN id SET DEFAULT nextval('pg_search_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY poll_groups ALTER COLUMN id SET DEFAULT nextval('poll_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY poll_members ALTER COLUMN id SET DEFAULT nextval('poll_members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY poll_series ALTER COLUMN id SET DEFAULT nextval('poll_series_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY poll_series_groups ALTER COLUMN id SET DEFAULT nextval('poll_series_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY poll_series_tags ALTER COLUMN id SET DEFAULT nextval('poll_series_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY polls ALTER COLUMN id SET DEFAULT nextval('polls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY providers ALTER COLUMN id SET DEFAULT nextval('providers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY provinces ALTER COLUMN id SET DEFAULT nextval('provinces_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recurrings ALTER COLUMN id SET DEFAULT nextval('recurrings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_codes ALTER COLUMN id SET DEFAULT nextval('request_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_groups ALTER COLUMN id SET DEFAULT nextval('request_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY save_poll_laters ALTER COLUMN id SET DEFAULT nextval('save_poll_laters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY share_polls ALTER COLUMN id SET DEFAULT nextval('share_polls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggests ALTER COLUMN id SET DEFAULT nextval('suggests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY un_see_polls ALTER COLUMN id SET DEFAULT nextval('un_see_polls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY watcheds ALTER COLUMN id SET DEFAULT nextval('watcheds_id_seq'::regclass);


--
-- Name: access_webs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY access_webs
    ADD CONSTRAINT access_webs_pkey PRIMARY KEY (id);


--
-- Name: activity_feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activity_feeds
    ADD CONSTRAINT activity_feeds_pkey PRIMARY KEY (id);


--
-- Name: admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: apn_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY apn_apps
    ADD CONSTRAINT apn_apps_pkey PRIMARY KEY (id);


--
-- Name: apn_device_groupings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY apn_device_groupings
    ADD CONSTRAINT apn_device_groupings_pkey PRIMARY KEY (id);


--
-- Name: apn_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY apn_devices
    ADD CONSTRAINT apn_devices_pkey PRIMARY KEY (id);


--
-- Name: apn_group_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY apn_group_notifications
    ADD CONSTRAINT apn_group_notifications_pkey PRIMARY KEY (id);


--
-- Name: apn_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY apn_groups
    ADD CONSTRAINT apn_groups_pkey PRIMARY KEY (id);


--
-- Name: apn_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY apn_notifications
    ADD CONSTRAINT apn_notifications_pkey PRIMARY KEY (id);


--
-- Name: apn_pull_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY apn_pull_notifications
    ADD CONSTRAINT apn_pull_notifications_pkey PRIMARY KEY (id);


--
-- Name: bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: branch_poll_series_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY branch_poll_series
    ADD CONSTRAINT branch_poll_series_pkey PRIMARY KEY (id);


--
-- Name: branch_polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY branch_polls
    ADD CONSTRAINT branch_polls_pkey PRIMARY KEY (id);


--
-- Name: branches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);


--
-- Name: campaign_guests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY campaign_guests
    ADD CONSTRAINT campaign_guests_pkey PRIMARY KEY (id);


--
-- Name: campaign_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY campaign_members
    ADD CONSTRAINT campaign_members_pkey PRIMARY KEY (id);


--
-- Name: campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);


--
-- Name: choices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY choices
    ADD CONSTRAINT choices_pkey PRIMARY KEY (id);


--
-- Name: collection_poll_branches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collection_poll_branches
    ADD CONSTRAINT collection_poll_branches_pkey PRIMARY KEY (id);


--
-- Name: collection_poll_series_branches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collection_poll_series_branches
    ADD CONSTRAINT collection_poll_series_branches_pkey PRIMARY KEY (id);


--
-- Name: collection_poll_series_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collection_poll_series
    ADD CONSTRAINT collection_poll_series_pkey PRIMARY KEY (id);


--
-- Name: collection_polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collection_polls
    ADD CONSTRAINT collection_polls_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: company_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY company_members
    ADD CONSTRAINT company_members_pkey PRIMARY KEY (id);


--
-- Name: devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: friends_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY friends
    ADD CONSTRAINT friends_pkey PRIMARY KEY (id);


--
-- Name: group_companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_companies
    ADD CONSTRAINT group_companies_pkey PRIMARY KEY (id);


--
-- Name: group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (id);


--
-- Name: group_surveyors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_surveyors
    ADD CONSTRAINT group_surveyors_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: guests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY guests
    ADD CONSTRAINT guests_pkey PRIMARY KEY (id);


--
-- Name: hidden_polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY hidden_polls
    ADD CONSTRAINT hidden_polls_pkey PRIMARY KEY (id);


--
-- Name: history_purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_purchases
    ADD CONSTRAINT history_purchases_pkey PRIMARY KEY (id);


--
-- Name: history_view_guests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_view_guests
    ADD CONSTRAINT history_view_guests_pkey PRIMARY KEY (id);


--
-- Name: history_view_questionnaires_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_view_questionnaires
    ADD CONSTRAINT history_view_questionnaires_pkey PRIMARY KEY (id);


--
-- Name: history_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_views
    ADD CONSTRAINT history_views_pkey PRIMARY KEY (id);


--
-- Name: history_vote_guests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_vote_guests
    ADD CONSTRAINT history_vote_guests_pkey PRIMARY KEY (id);


--
-- Name: history_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_votes
    ADD CONSTRAINT history_votes_pkey PRIMARY KEY (id);


--
-- Name: invite_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invite_codes
    ADD CONSTRAINT invite_codes_pkey PRIMARY KEY (id);


--
-- Name: member_invite_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY member_invite_codes
    ADD CONSTRAINT member_invite_codes_pkey PRIMARY KEY (id);


--
-- Name: member_report_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY member_report_members
    ADD CONSTRAINT member_report_members_pkey PRIMARY KEY (id);


--
-- Name: member_report_polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY member_report_polls
    ADD CONSTRAINT member_report_polls_pkey PRIMARY KEY (id);


--
-- Name: member_un_recomments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY member_un_recomments
    ADD CONSTRAINT member_un_recomments_pkey PRIMARY KEY (id);


--
-- Name: members_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mentions
    ADD CONSTRAINT mentions_pkey PRIMARY KEY (id);


--
-- Name: notify_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notify_logs
    ADD CONSTRAINT notify_logs_pkey PRIMARY KEY (id);


--
-- Name: pg_search_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pg_search_documents
    ADD CONSTRAINT pg_search_documents_pkey PRIMARY KEY (id);


--
-- Name: poll_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY poll_groups
    ADD CONSTRAINT poll_groups_pkey PRIMARY KEY (id);


--
-- Name: poll_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY poll_members
    ADD CONSTRAINT poll_members_pkey PRIMARY KEY (id);


--
-- Name: poll_series_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY poll_series_groups
    ADD CONSTRAINT poll_series_groups_pkey PRIMARY KEY (id);


--
-- Name: poll_series_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY poll_series
    ADD CONSTRAINT poll_series_pkey PRIMARY KEY (id);


--
-- Name: poll_series_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY poll_series_tags
    ADD CONSTRAINT poll_series_tags_pkey PRIMARY KEY (id);


--
-- Name: polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY polls
    ADD CONSTRAINT polls_pkey PRIMARY KEY (id);


--
-- Name: profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- Name: provinces_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY provinces
    ADD CONSTRAINT provinces_pkey PRIMARY KEY (id);


--
-- Name: recurrings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY recurrings
    ADD CONSTRAINT recurrings_pkey PRIMARY KEY (id);


--
-- Name: request_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY request_codes
    ADD CONSTRAINT request_codes_pkey PRIMARY KEY (id);


--
-- Name: request_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY request_groups
    ADD CONSTRAINT request_groups_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: save_poll_laters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY save_poll_laters
    ADD CONSTRAINT save_poll_laters_pkey PRIMARY KEY (id);


--
-- Name: share_polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY share_polls
    ADD CONSTRAINT share_polls_pkey PRIMARY KEY (id);


--
-- Name: suggests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY suggests
    ADD CONSTRAINT suggests_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: un_see_polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY un_see_polls
    ADD CONSTRAINT un_see_polls_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: watcheds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY watcheds
    ADD CONSTRAINT watcheds_pkey PRIMARY KEY (id);


--
-- Name: by_member_and_poll_series; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX by_member_and_poll_series ON history_view_questionnaires USING btree (member_id, poll_series_id);


--
-- Name: by_series_and_branch; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_series_and_branch ON collection_poll_series_branches USING btree (collection_poll_series_id);


--
-- Name: index_access_webs_on_accessable_id_and_accessable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_access_webs_on_accessable_id_and_accessable_type ON access_webs USING btree (accessable_id, accessable_type);


--
-- Name: index_access_webs_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_access_webs_on_member_id ON access_webs USING btree (member_id);


--
-- Name: index_activity_feeds_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activity_feeds_on_group_id ON activity_feeds USING btree (group_id);


--
-- Name: index_activity_feeds_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activity_feeds_on_member_id ON activity_feeds USING btree (member_id);


--
-- Name: index_activity_feeds_on_trackable_id_and_trackable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activity_feeds_on_trackable_id_and_trackable_type ON activity_feeds USING btree (trackable_id, trackable_type);


--
-- Name: index_admins_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_email ON admins USING btree (email);


--
-- Name: index_admins_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_reset_password_token ON admins USING btree (reset_password_token);


--
-- Name: index_apn_device_groupings_on_device_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_apn_device_groupings_on_device_id ON apn_device_groupings USING btree (device_id);


--
-- Name: index_apn_device_groupings_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_apn_device_groupings_on_group_id ON apn_device_groupings USING btree (group_id);


--
-- Name: index_apn_device_groupings_on_group_id_and_device_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_apn_device_groupings_on_group_id_and_device_id ON apn_device_groupings USING btree (group_id, device_id);


--
-- Name: index_apn_devices_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_apn_devices_on_member_id ON apn_devices USING btree (member_id);


--
-- Name: index_apn_devices_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_apn_devices_on_token ON apn_devices USING btree (token);


--
-- Name: index_apn_devices_on_token_and_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_apn_devices_on_token_and_member_id ON apn_devices USING btree (token, member_id);


--
-- Name: index_apn_group_notifications_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_apn_group_notifications_on_group_id ON apn_group_notifications USING btree (group_id);


--
-- Name: index_apn_notifications_on_device_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_apn_notifications_on_device_id ON apn_notifications USING btree (device_id);


--
-- Name: index_bookmarks_on_bookmarkable_id_and_bookmarkable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bookmarks_on_bookmarkable_id_and_bookmarkable_type ON bookmarks USING btree (bookmarkable_id, bookmarkable_type);


--
-- Name: index_bookmarks_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bookmarks_on_member_id ON bookmarks USING btree (member_id);


--
-- Name: index_branch_poll_series_on_branch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_branch_poll_series_on_branch_id ON branch_poll_series USING btree (branch_id);


--
-- Name: index_branch_poll_series_on_poll_series_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_branch_poll_series_on_poll_series_id ON branch_poll_series USING btree (poll_series_id);


--
-- Name: index_branch_polls_on_branch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_branch_polls_on_branch_id ON branch_polls USING btree (branch_id);


--
-- Name: index_branch_polls_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_branch_polls_on_poll_id ON branch_polls USING btree (poll_id);


--
-- Name: index_branches_on_company_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_branches_on_company_id ON branches USING btree (company_id);


--
-- Name: index_branches_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_branches_on_slug ON branches USING btree (slug);


--
-- Name: index_campaign_guests_on_campaign_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_campaign_guests_on_campaign_id ON campaign_guests USING btree (campaign_id);


--
-- Name: index_campaign_guests_on_guest_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_campaign_guests_on_guest_id ON campaign_guests USING btree (guest_id);


--
-- Name: index_campaign_members_on_campaign_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_campaign_members_on_campaign_id ON campaign_members USING btree (campaign_id);


--
-- Name: index_campaign_members_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_campaign_members_on_member_id ON campaign_members USING btree (member_id);


--
-- Name: index_campaigns_on_company_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_campaigns_on_company_id ON campaigns USING btree (company_id);


--
-- Name: index_campaigns_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_campaigns_on_member_id ON campaigns USING btree (member_id);


--
-- Name: index_choices_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_choices_on_poll_id ON choices USING btree (poll_id);


--
-- Name: index_collection_poll_branches_on_branch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_poll_branches_on_branch_id ON collection_poll_branches USING btree (branch_id);


--
-- Name: index_collection_poll_branches_on_collection_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_poll_branches_on_collection_poll_id ON collection_poll_branches USING btree (collection_poll_id);


--
-- Name: index_collection_poll_branches_on_poll_series_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_poll_branches_on_poll_series_id ON collection_poll_branches USING btree (poll_series_id);


--
-- Name: index_collection_poll_series_branches_on_branch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_poll_series_branches_on_branch_id ON collection_poll_series_branches USING btree (branch_id);


--
-- Name: index_collection_poll_series_branches_on_poll_series_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_poll_series_branches_on_poll_series_id ON collection_poll_series_branches USING btree (poll_series_id);


--
-- Name: index_collection_poll_series_on_company_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_poll_series_on_company_id ON collection_poll_series USING btree (company_id);


--
-- Name: index_collection_polls_on_company_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_polls_on_company_id ON collection_polls USING btree (company_id);


--
-- Name: index_comments_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_member_id ON comments USING btree (member_id);


--
-- Name: index_comments_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_poll_id ON comments USING btree (poll_id);


--
-- Name: index_companies_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_companies_on_member_id ON companies USING btree (member_id);


--
-- Name: index_companies_on_using_service; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_companies_on_using_service ON companies USING gin (using_service);


--
-- Name: index_company_members_on_company_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_company_members_on_company_id ON company_members USING btree (company_id);


--
-- Name: index_company_members_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_company_members_on_member_id ON company_members USING btree (member_id);


--
-- Name: index_devices_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_devices_on_member_id ON devices USING btree (member_id);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_friends_on_followed_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_friends_on_followed_id ON friends USING btree (followed_id);


--
-- Name: index_friends_on_follower_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_friends_on_follower_id ON friends USING btree (follower_id);


--
-- Name: index_friends_on_follower_id_and_followed_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_friends_on_follower_id_and_followed_id ON friends USING btree (follower_id, followed_id);


--
-- Name: index_group_companies_on_company_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_companies_on_company_id ON group_companies USING btree (company_id);


--
-- Name: index_group_companies_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_companies_on_group_id ON group_companies USING btree (group_id);


--
-- Name: index_group_members_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_members_on_group_id ON group_members USING btree (group_id);


--
-- Name: index_group_members_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_members_on_member_id ON group_members USING btree (member_id);


--
-- Name: index_group_members_on_member_id_and_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_group_members_on_member_id_and_group_id ON group_members USING btree (member_id, group_id);


--
-- Name: index_group_surveyors_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_surveyors_on_group_id ON group_surveyors USING btree (group_id);


--
-- Name: index_group_surveyors_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_surveyors_on_member_id ON group_surveyors USING btree (member_id);


--
-- Name: index_groups_on_properties; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_properties ON groups USING gist (properties);


--
-- Name: index_groups_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_groups_on_slug ON groups USING btree (slug);


--
-- Name: index_hidden_polls_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_hidden_polls_on_member_id ON hidden_polls USING btree (member_id);


--
-- Name: index_hidden_polls_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_hidden_polls_on_poll_id ON hidden_polls USING btree (poll_id);


--
-- Name: index_history_purchases_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_purchases_on_member_id ON history_purchases USING btree (member_id);


--
-- Name: index_history_purchases_on_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_purchases_on_transaction_id ON history_purchases USING btree (transaction_id);


--
-- Name: index_history_view_guests_on_guest_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_view_guests_on_guest_id ON history_view_guests USING btree (guest_id);


--
-- Name: index_history_view_guests_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_view_guests_on_poll_id ON history_view_guests USING btree (poll_id);


--
-- Name: index_history_view_questionnaires_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_view_questionnaires_on_member_id ON history_view_questionnaires USING btree (member_id);


--
-- Name: index_history_view_questionnaires_on_poll_series_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_view_questionnaires_on_poll_series_id ON history_view_questionnaires USING btree (poll_series_id);


--
-- Name: index_history_views_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_views_on_member_id ON history_views USING btree (member_id);


--
-- Name: index_history_views_on_member_id_and_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_views_on_member_id_and_poll_id ON history_views USING btree (member_id, poll_id);


--
-- Name: index_history_views_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_views_on_poll_id ON history_views USING btree (poll_id);


--
-- Name: index_history_vote_guests_on_guest_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_vote_guests_on_guest_id ON history_vote_guests USING btree (guest_id);


--
-- Name: index_history_vote_guests_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_vote_guests_on_poll_id ON history_vote_guests USING btree (poll_id);


--
-- Name: index_history_votes_on_data_analysis; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_votes_on_data_analysis ON history_votes USING gist (data_analysis);


--
-- Name: index_history_votes_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_votes_on_member_id ON history_votes USING btree (member_id);


--
-- Name: index_history_votes_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_votes_on_poll_id ON history_votes USING btree (poll_id);


--
-- Name: index_invite_codes_on_company_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invite_codes_on_company_id ON invite_codes USING btree (company_id);


--
-- Name: index_invite_codes_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invite_codes_on_group_id ON invite_codes USING btree (group_id);


--
-- Name: index_member_invite_codes_on_invite_code_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_member_invite_codes_on_invite_code_id ON member_invite_codes USING btree (invite_code_id);


--
-- Name: index_member_invite_codes_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_member_invite_codes_on_member_id ON member_invite_codes USING btree (member_id);


--
-- Name: index_member_report_members_on_reportee_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_member_report_members_on_reportee_id ON member_report_members USING btree (reportee_id);


--
-- Name: index_member_report_members_on_reporter_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_member_report_members_on_reporter_id ON member_report_members USING btree (reporter_id);


--
-- Name: index_member_report_polls_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_member_report_polls_on_member_id ON member_report_polls USING btree (member_id);


--
-- Name: index_member_report_polls_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_member_report_polls_on_poll_id ON member_report_polls USING btree (poll_id);


--
-- Name: index_member_un_recomments_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_member_un_recomments_on_member_id ON member_un_recomments USING btree (member_id);


--
-- Name: index_members_on_poll_overall_req_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_members_on_poll_overall_req_at ON members USING btree (poll_overall_req_at);


--
-- Name: index_members_on_poll_public_req_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_members_on_poll_public_req_at ON members USING btree (poll_public_req_at);


--
-- Name: index_members_on_setting; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_members_on_setting ON members USING gist (setting);


--
-- Name: index_members_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_members_on_slug ON members USING btree (slug);


--
-- Name: index_members_on_username; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_members_on_username ON members USING btree (username);


--
-- Name: index_members_roles_on_member_id_and_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_members_roles_on_member_id_and_role_id ON members_roles USING btree (member_id, role_id);


--
-- Name: index_mentions_on_comment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mentions_on_comment_id ON mentions USING btree (comment_id);


--
-- Name: index_mentions_on_mentioner_id_and_mentionable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mentions_on_mentioner_id_and_mentionable_id ON mentions USING btree (mentioner_id, mentionable_id);


--
-- Name: index_notify_logs_on_recipient_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notify_logs_on_recipient_id ON notify_logs USING btree (recipient_id);


--
-- Name: index_notify_logs_on_sender_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notify_logs_on_sender_id ON notify_logs USING btree (sender_id);


--
-- Name: index_poll_groups_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_poll_groups_on_group_id ON poll_groups USING btree (group_id);


--
-- Name: index_poll_groups_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_poll_groups_on_member_id ON poll_groups USING btree (member_id);


--
-- Name: index_poll_groups_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_poll_groups_on_poll_id ON poll_groups USING btree (poll_id);


--
-- Name: index_poll_groups_on_share_poll_of_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_poll_groups_on_share_poll_of_id ON poll_groups USING btree (share_poll_of_id);


--
-- Name: index_poll_members_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_poll_members_on_member_id ON poll_members USING btree (member_id);


--
-- Name: index_poll_members_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_poll_members_on_poll_id ON poll_members USING btree (poll_id);


--
-- Name: index_poll_series_groups_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_poll_series_groups_on_group_id ON poll_series_groups USING btree (group_id);


--
-- Name: index_poll_series_groups_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_poll_series_groups_on_member_id ON poll_series_groups USING btree (member_id);


--
-- Name: index_poll_series_groups_on_poll_series_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_poll_series_groups_on_poll_series_id ON poll_series_groups USING btree (poll_series_id);


--
-- Name: index_poll_series_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_poll_series_on_member_id ON poll_series USING btree (member_id);


--
-- Name: index_poll_series_tags_on_poll_series_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_poll_series_tags_on_poll_series_id ON poll_series_tags USING btree (poll_series_id);


--
-- Name: index_poll_series_tags_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_poll_series_tags_on_tag_id ON poll_series_tags USING btree (tag_id);


--
-- Name: index_polls_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_polls_on_member_id ON polls USING btree (member_id);


--
-- Name: index_polls_on_poll_series_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_polls_on_poll_series_id ON polls USING btree (poll_series_id);


--
-- Name: index_polls_on_recurring_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_polls_on_recurring_id ON polls USING btree (recurring_id);


--
-- Name: index_polls_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_polls_on_slug ON polls USING btree (slug);


--
-- Name: index_profiles_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_profiles_on_member_id ON profiles USING btree (member_id);


--
-- Name: index_providers_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_providers_on_member_id ON providers USING btree (member_id);


--
-- Name: index_providers_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_providers_on_token ON providers USING btree (token);


--
-- Name: index_recurrings_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_recurrings_on_member_id ON recurrings USING btree (member_id);


--
-- Name: index_request_codes_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_request_codes_on_member_id ON request_codes USING btree (member_id);


--
-- Name: index_request_groups_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_request_groups_on_group_id ON request_groups USING btree (group_id);


--
-- Name: index_request_groups_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_request_groups_on_member_id ON request_groups USING btree (member_id);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_on_name ON roles USING btree (name);


--
-- Name: index_roles_on_name_and_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_on_name_and_resource_type_and_resource_id ON roles USING btree (name, resource_type, resource_id);


--
-- Name: index_save_poll_laters_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_save_poll_laters_on_member_id ON save_poll_laters USING btree (member_id);


--
-- Name: index_save_poll_laters_on_member_id_and_savable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_save_poll_laters_on_member_id_and_savable_id ON save_poll_laters USING btree (member_id, savable_id);


--
-- Name: index_save_poll_laters_on_savable_id_and_savable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_save_poll_laters_on_savable_id_and_savable_type ON save_poll_laters USING btree (savable_id, savable_type);


--
-- Name: index_share_polls_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_share_polls_on_member_id ON share_polls USING btree (member_id);


--
-- Name: index_share_polls_on_member_id_and_poll_id_and_shared_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_share_polls_on_member_id_and_poll_id_and_shared_group_id ON share_polls USING btree (member_id, poll_id, shared_group_id);


--
-- Name: index_share_polls_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_share_polls_on_poll_id ON share_polls USING btree (poll_id);


--
-- Name: index_share_polls_on_shared_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_share_polls_on_shared_group_id ON share_polls USING btree (shared_group_id);


--
-- Name: index_suggests_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_suggests_on_member_id ON suggests USING btree (member_id);


--
-- Name: index_suggests_on_poll_series_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_suggests_on_poll_series_id ON suggests USING btree (poll_series_id);


--
-- Name: index_taggings_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_poll_id ON taggings USING btree (poll_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_un_see_polls_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_un_see_polls_on_member_id ON un_see_polls USING btree (member_id);


--
-- Name: index_un_see_polls_on_member_id_and_unseeable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_un_see_polls_on_member_id_and_unseeable_id ON un_see_polls USING btree (member_id, unseeable_id);


--
-- Name: index_un_see_polls_on_unseeable_id_and_unseeable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_un_see_polls_on_unseeable_id_and_unseeable_type ON un_see_polls USING btree (unseeable_id, unseeable_type);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: index_watcheds_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_watcheds_on_member_id ON watcheds USING btree (member_id);


--
-- Name: index_watcheds_on_member_id_and_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_watcheds_on_member_id_and_poll_id ON watcheds USING btree (member_id, poll_id);


--
-- Name: index_watcheds_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_watcheds_on_poll_id ON watcheds USING btree (poll_id);


--
-- Name: members_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX members_email ON members USING gin (to_tsvector('english'::regconfig, (email)::text));


--
-- Name: members_fullname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX members_fullname ON members USING gin (to_tsvector('english'::regconfig, (fullname)::text));


--
-- Name: members_username; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX members_username ON members USING gin (to_tsvector('english'::regconfig, (username)::text));


--
-- Name: tags_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tags_name ON tags USING gin (to_tsvector('english'::regconfig, (name)::text));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140122031506');

INSERT INTO schema_migrations (version) VALUES ('20140122033535');

INSERT INTO schema_migrations (version) VALUES ('20140122033655');

INSERT INTO schema_migrations (version) VALUES ('20140122040551');

INSERT INTO schema_migrations (version) VALUES ('20140122040749');

INSERT INTO schema_migrations (version) VALUES ('20140122043523');

INSERT INTO schema_migrations (version) VALUES ('20140123034129');

INSERT INTO schema_migrations (version) VALUES ('20140123034832');

INSERT INTO schema_migrations (version) VALUES ('20140123041040');

INSERT INTO schema_migrations (version) VALUES ('20140123044917');

INSERT INTO schema_migrations (version) VALUES ('20140123073142');

INSERT INTO schema_migrations (version) VALUES ('20140123094619');

INSERT INTO schema_migrations (version) VALUES ('20140123102318');

INSERT INTO schema_migrations (version) VALUES ('20140127085514');

INSERT INTO schema_migrations (version) VALUES ('20140127085626');

INSERT INTO schema_migrations (version) VALUES ('20140128032407');

INSERT INTO schema_migrations (version) VALUES ('20140128032721');

INSERT INTO schema_migrations (version) VALUES ('20140128033608');

INSERT INTO schema_migrations (version) VALUES ('20140128033743');

INSERT INTO schema_migrations (version) VALUES ('20140128063009');

INSERT INTO schema_migrations (version) VALUES ('20140128071523');

INSERT INTO schema_migrations (version) VALUES ('20140128082659');

INSERT INTO schema_migrations (version) VALUES ('20140128085155');

INSERT INTO schema_migrations (version) VALUES ('20140128085242');

INSERT INTO schema_migrations (version) VALUES ('20140129061819');

INSERT INTO schema_migrations (version) VALUES ('20140131075845');

INSERT INTO schema_migrations (version) VALUES ('20140131191616');

INSERT INTO schema_migrations (version) VALUES ('20140203040831');

INSERT INTO schema_migrations (version) VALUES ('20140203041007');

INSERT INTO schema_migrations (version) VALUES ('20140203064511');

INSERT INTO schema_migrations (version) VALUES ('20140206034640');

INSERT INTO schema_migrations (version) VALUES ('20140212045223');

INSERT INTO schema_migrations (version) VALUES ('20140212045224');

INSERT INTO schema_migrations (version) VALUES ('20140212045225');

INSERT INTO schema_migrations (version) VALUES ('20140212045226');

INSERT INTO schema_migrations (version) VALUES ('20140212045227');

INSERT INTO schema_migrations (version) VALUES ('20140212045228');

INSERT INTO schema_migrations (version) VALUES ('20140212045229');

INSERT INTO schema_migrations (version) VALUES ('20140212045230');

INSERT INTO schema_migrations (version) VALUES ('20140212045231');

INSERT INTO schema_migrations (version) VALUES ('20140212045232');

INSERT INTO schema_migrations (version) VALUES ('20140212045233');

INSERT INTO schema_migrations (version) VALUES ('20140212045234');

INSERT INTO schema_migrations (version) VALUES ('20140217053636');

INSERT INTO schema_migrations (version) VALUES ('20140217120727');

INSERT INTO schema_migrations (version) VALUES ('20140217122144');

INSERT INTO schema_migrations (version) VALUES ('20140217123749');

INSERT INTO schema_migrations (version) VALUES ('20140218033602');

INSERT INTO schema_migrations (version) VALUES ('20140218033727');

INSERT INTO schema_migrations (version) VALUES ('20140218033819');

INSERT INTO schema_migrations (version) VALUES ('20140218034148');

INSERT INTO schema_migrations (version) VALUES ('20140218043357');

INSERT INTO schema_migrations (version) VALUES ('20140219164742');

INSERT INTO schema_migrations (version) VALUES ('20140219164830');

INSERT INTO schema_migrations (version) VALUES ('20140219164942');

INSERT INTO schema_migrations (version) VALUES ('20140225033653');

INSERT INTO schema_migrations (version) VALUES ('20140225053159');

INSERT INTO schema_migrations (version) VALUES ('20140225095203');

INSERT INTO schema_migrations (version) VALUES ('20140226091341');

INSERT INTO schema_migrations (version) VALUES ('20140226091705');

INSERT INTO schema_migrations (version) VALUES ('20140227072612');

INSERT INTO schema_migrations (version) VALUES ('20140227072746');

INSERT INTO schema_migrations (version) VALUES ('20140227174405');

INSERT INTO schema_migrations (version) VALUES ('20140228042825');

INSERT INTO schema_migrations (version) VALUES ('20140228085650');

INSERT INTO schema_migrations (version) VALUES ('20140303042335');

INSERT INTO schema_migrations (version) VALUES ('20140304074359');

INSERT INTO schema_migrations (version) VALUES ('20140304074735');

INSERT INTO schema_migrations (version) VALUES ('20140304075213');

INSERT INTO schema_migrations (version) VALUES ('20140304092657');

INSERT INTO schema_migrations (version) VALUES ('20140304152907');

INSERT INTO schema_migrations (version) VALUES ('20140312043633');

INSERT INTO schema_migrations (version) VALUES ('20140312061415');

INSERT INTO schema_migrations (version) VALUES ('20140312095502');

INSERT INTO schema_migrations (version) VALUES ('20140317072155');

INSERT INTO schema_migrations (version) VALUES ('20140324064202');

INSERT INTO schema_migrations (version) VALUES ('20140325040117');

INSERT INTO schema_migrations (version) VALUES ('20140327034439');

INSERT INTO schema_migrations (version) VALUES ('20140401042245');

INSERT INTO schema_migrations (version) VALUES ('20140401060158');

INSERT INTO schema_migrations (version) VALUES ('20140401071820');

INSERT INTO schema_migrations (version) VALUES ('20140401083756');

INSERT INTO schema_migrations (version) VALUES ('20140402043425');

INSERT INTO schema_migrations (version) VALUES ('20140410113620');

INSERT INTO schema_migrations (version) VALUES ('20140429150204');

INSERT INTO schema_migrations (version) VALUES ('20140430102537');

INSERT INTO schema_migrations (version) VALUES ('20140506061857');

INSERT INTO schema_migrations (version) VALUES ('20140506080303');

INSERT INTO schema_migrations (version) VALUES ('20140506082814');

INSERT INTO schema_migrations (version) VALUES ('20140508033549');

INSERT INTO schema_migrations (version) VALUES ('20140508033647');

INSERT INTO schema_migrations (version) VALUES ('20140508033648');

INSERT INTO schema_migrations (version) VALUES ('20140508033649');

INSERT INTO schema_migrations (version) VALUES ('20140508033650');

INSERT INTO schema_migrations (version) VALUES ('20140508033651');

INSERT INTO schema_migrations (version) VALUES ('20140508033652');

INSERT INTO schema_migrations (version) VALUES ('20140508033653');

INSERT INTO schema_migrations (version) VALUES ('20140508033654');

INSERT INTO schema_migrations (version) VALUES ('20140508033655');

INSERT INTO schema_migrations (version) VALUES ('20140508033656');

INSERT INTO schema_migrations (version) VALUES ('20140508033657');

INSERT INTO schema_migrations (version) VALUES ('20140508033658');

INSERT INTO schema_migrations (version) VALUES ('20140508041945');

INSERT INTO schema_migrations (version) VALUES ('20140508061910');

INSERT INTO schema_migrations (version) VALUES ('20140512050526');

INSERT INTO schema_migrations (version) VALUES ('20140512104547');

INSERT INTO schema_migrations (version) VALUES ('20140516035301');

INSERT INTO schema_migrations (version) VALUES ('20140516061257');

INSERT INTO schema_migrations (version) VALUES ('20140516075031');

INSERT INTO schema_migrations (version) VALUES ('20140520055414');

INSERT INTO schema_migrations (version) VALUES ('20140520081418');

INSERT INTO schema_migrations (version) VALUES ('20140529130034');

INSERT INTO schema_migrations (version) VALUES ('20140529130313');

INSERT INTO schema_migrations (version) VALUES ('20140530030100');

INSERT INTO schema_migrations (version) VALUES ('20140602062259');

INSERT INTO schema_migrations (version) VALUES ('20140603082829');

INSERT INTO schema_migrations (version) VALUES ('20140609040949');

INSERT INTO schema_migrations (version) VALUES ('20140609041002');

INSERT INTO schema_migrations (version) VALUES ('20140611071235');

INSERT INTO schema_migrations (version) VALUES ('20140616055648');

INSERT INTO schema_migrations (version) VALUES ('20140616055716');

INSERT INTO schema_migrations (version) VALUES ('20140625063550');

INSERT INTO schema_migrations (version) VALUES ('20140625063750');

INSERT INTO schema_migrations (version) VALUES ('20140625064258');

INSERT INTO schema_migrations (version) VALUES ('20140626064855');

INSERT INTO schema_migrations (version) VALUES ('20140626191900');

INSERT INTO schema_migrations (version) VALUES ('20140627042243');

INSERT INTO schema_migrations (version) VALUES ('20140627074530');

INSERT INTO schema_migrations (version) VALUES ('20140630080908');

INSERT INTO schema_migrations (version) VALUES ('20140703063837');

INSERT INTO schema_migrations (version) VALUES ('20140703084232');

INSERT INTO schema_migrations (version) VALUES ('20140703135359');

INSERT INTO schema_migrations (version) VALUES ('20140704073110');

INSERT INTO schema_migrations (version) VALUES ('20140704075708');

INSERT INTO schema_migrations (version) VALUES ('20140707041725');

INSERT INTO schema_migrations (version) VALUES ('20140708034932');

INSERT INTO schema_migrations (version) VALUES ('20140708101246');

INSERT INTO schema_migrations (version) VALUES ('20140708154843');

INSERT INTO schema_migrations (version) VALUES ('20140708155056');

INSERT INTO schema_migrations (version) VALUES ('20140709073541');

INSERT INTO schema_migrations (version) VALUES ('20140709081009');

INSERT INTO schema_migrations (version) VALUES ('20140710071416');

INSERT INTO schema_migrations (version) VALUES ('20140710102941');

INSERT INTO schema_migrations (version) VALUES ('20140715111649');

INSERT INTO schema_migrations (version) VALUES ('20140715151432');

INSERT INTO schema_migrations (version) VALUES ('20140718041649');

INSERT INTO schema_migrations (version) VALUES ('20140728042841');

INSERT INTO schema_migrations (version) VALUES ('20140729102129');

INSERT INTO schema_migrations (version) VALUES ('20140731042549');

INSERT INTO schema_migrations (version) VALUES ('20140731074244');

INSERT INTO schema_migrations (version) VALUES ('20140731082938');

INSERT INTO schema_migrations (version) VALUES ('20140731084611');

INSERT INTO schema_migrations (version) VALUES ('20140731131958');

INSERT INTO schema_migrations (version) VALUES ('20140804123037');

INSERT INTO schema_migrations (version) VALUES ('20140805104001');

INSERT INTO schema_migrations (version) VALUES ('20140814041954');

INSERT INTO schema_migrations (version) VALUES ('20140814073646');

INSERT INTO schema_migrations (version) VALUES ('20140815055359');

INSERT INTO schema_migrations (version) VALUES ('20140819024707');

INSERT INTO schema_migrations (version) VALUES ('20140819073713');

INSERT INTO schema_migrations (version) VALUES ('20140819094253');

INSERT INTO schema_migrations (version) VALUES ('20140819110242');

INSERT INTO schema_migrations (version) VALUES ('20140821032332');

INSERT INTO schema_migrations (version) VALUES ('20140828070652');

INSERT INTO schema_migrations (version) VALUES ('20140829050312');

INSERT INTO schema_migrations (version) VALUES ('20140901061006');

INSERT INTO schema_migrations (version) VALUES ('20140901103319');

INSERT INTO schema_migrations (version) VALUES ('20140901103634');

INSERT INTO schema_migrations (version) VALUES ('20140909095809');

INSERT INTO schema_migrations (version) VALUES ('20140912031610');

INSERT INTO schema_migrations (version) VALUES ('20140916042132');

INSERT INTO schema_migrations (version) VALUES ('20140916125303');

INSERT INTO schema_migrations (version) VALUES ('20140918140041');

INSERT INTO schema_migrations (version) VALUES ('20140919152656');

INSERT INTO schema_migrations (version) VALUES ('20140923105842');

INSERT INTO schema_migrations (version) VALUES ('20140928133052');

INSERT INTO schema_migrations (version) VALUES ('20141002073347');

INSERT INTO schema_migrations (version) VALUES ('20141003060015');

INSERT INTO schema_migrations (version) VALUES ('20141003063911');

INSERT INTO schema_migrations (version) VALUES ('20141003065150');

INSERT INTO schema_migrations (version) VALUES ('20141006082040');

INSERT INTO schema_migrations (version) VALUES ('20141008051532');

INSERT INTO schema_migrations (version) VALUES ('20141009030211');

INSERT INTO schema_migrations (version) VALUES ('20141014032142');

INSERT INTO schema_migrations (version) VALUES ('20141014041603');

INSERT INTO schema_migrations (version) VALUES ('20141015132936');

INSERT INTO schema_migrations (version) VALUES ('20141016085500');

INSERT INTO schema_migrations (version) VALUES ('20141016155622');

INSERT INTO schema_migrations (version) VALUES ('20141028072811');

INSERT INTO schema_migrations (version) VALUES ('20141030073323');

INSERT INTO schema_migrations (version) VALUES ('20141030075116');

INSERT INTO schema_migrations (version) VALUES ('20141031041353');

INSERT INTO schema_migrations (version) VALUES ('20141125031754');

INSERT INTO schema_migrations (version) VALUES ('20141127063504');

INSERT INTO schema_migrations (version) VALUES ('20141204062207');

INSERT INTO schema_migrations (version) VALUES ('20141209081854');

INSERT INTO schema_migrations (version) VALUES ('20141210125039');

INSERT INTO schema_migrations (version) VALUES ('20141216034741');

INSERT INTO schema_migrations (version) VALUES ('20141216074943');

INSERT INTO schema_migrations (version) VALUES ('20141224034549');

INSERT INTO schema_migrations (version) VALUES ('20141224040545');

INSERT INTO schema_migrations (version) VALUES ('20141226061227');

INSERT INTO schema_migrations (version) VALUES ('20141226062021');

INSERT INTO schema_migrations (version) VALUES ('20141226062642');

INSERT INTO schema_migrations (version) VALUES ('20141226064134');

INSERT INTO schema_migrations (version) VALUES ('20141226072039');

INSERT INTO schema_migrations (version) VALUES ('20141228105648');

INSERT INTO schema_migrations (version) VALUES ('20141229081535');

INSERT INTO schema_migrations (version) VALUES ('20141229122846');

INSERT INTO schema_migrations (version) VALUES ('20141230034312');

INSERT INTO schema_migrations (version) VALUES ('20141230043246');

INSERT INTO schema_migrations (version) VALUES ('20141230053055');

INSERT INTO schema_migrations (version) VALUES ('20141230053324');

INSERT INTO schema_migrations (version) VALUES ('20141230083207');

INSERT INTO schema_migrations (version) VALUES ('20150106060416');

INSERT INTO schema_migrations (version) VALUES ('20150107081906');

INSERT INTO schema_migrations (version) VALUES ('20150107100111');

INSERT INTO schema_migrations (version) VALUES ('20150107100824');

INSERT INTO schema_migrations (version) VALUES ('20150112073146');

INSERT INTO schema_migrations (version) VALUES ('20150113083959');

INSERT INTO schema_migrations (version) VALUES ('20150113102529');

INSERT INTO schema_migrations (version) VALUES ('20150113103600');

INSERT INTO schema_migrations (version) VALUES ('20150113104253');

