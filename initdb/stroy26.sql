--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.0

-- Started on 2026-07-04 14:26:39

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 37 (class 2615 OID 4885993)
-- Name: stroy; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA stroy;


--
-- TOC entry 5935 (class 0 OID 0)
-- Dependencies: 37
-- Name: SCHEMA stroy; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA stroy IS 'standard public schema';


--
-- TOC entry 1478 (class 1247 OID 4885995)
-- Name: payment_type; Type: TYPE; Schema: stroy; Owner: -
--

CREATE TYPE stroy.payment_type AS ENUM (
    'Авансовый',
    'Промежуточный',
    'Финальный',
    'Гарантийное удержание',
    'Корректировка'
);


--
-- TOC entry 1481 (class 1247 OID 4886006)
-- Name: project_status; Type: TYPE; Schema: stroy; Owner: -
--

CREATE TYPE stroy.project_status AS ENUM (
    'На подписании',
    'В работе',
    'Завершен',
    'Отменен'
);


--
-- TOC entry 638 (class 1255 OID 4886473)
-- Name: project_search_vector_update(); Type: FUNCTION; Schema: stroy; Owner: -
--

CREATE FUNCTION stroy.project_search_vector_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('russian', COALESCE(NEW.project_name, '')), 'A') ||
        setweight(to_tsvector('russian', COALESCE(NEW.description, '')), 'B') ||
        setweight(to_tsvector('russian', COALESCE(
            (SELECT string_agg(value, ' ') FROM jsonb_each_text(NEW.project_details)),
            ''
        )), 'C');
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 490 (class 1259 OID 4886015)
-- Name: address; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.address (
    address_id integer NOT NULL,
    address character varying(150) NOT NULL,
    city_id smallint NOT NULL
);


--
-- TOC entry 491 (class 1259 OID 4886018)
-- Name: address_address_id_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.address_address_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5936 (class 0 OID 0)
-- Dependencies: 491
-- Name: address_address_id_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.address_address_id_seq OWNED BY stroy.address.address_id;


--
-- TOC entry 492 (class 1259 OID 4886019)
-- Name: city; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.city (
    city_id integer NOT NULL,
    city_name character varying(75) NOT NULL,
    country_id smallint NOT NULL
);


--
-- TOC entry 493 (class 1259 OID 4886022)
-- Name: city_city_id_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.city_city_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5937 (class 0 OID 0)
-- Dependencies: 493
-- Name: city_city_id_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.city_city_id_seq OWNED BY stroy.city.city_id;


--
-- TOC entry 494 (class 1259 OID 4886023)
-- Name: company_structure; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.company_structure (
    unit_id smallint NOT NULL,
    parent_id smallint NOT NULL,
    unit_name character varying(100) NOT NULL,
    unit_type smallint NOT NULL
);


--
-- TOC entry 495 (class 1259 OID 4886026)
-- Name: company_structure_unit_id_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.company_structure_unit_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5938 (class 0 OID 0)
-- Dependencies: 495
-- Name: company_structure_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.company_structure_unit_id_seq OWNED BY stroy.company_structure.unit_id;


--
-- TOC entry 496 (class 1259 OID 4886027)
-- Name: country; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.country (
    country_id integer NOT NULL,
    country_name character varying(75) NOT NULL
);


--
-- TOC entry 497 (class 1259 OID 4886030)
-- Name: country_country_id_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.country_country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5939 (class 0 OID 0)
-- Dependencies: 497
-- Name: country_country_id_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.country_country_id_seq OWNED BY stroy.country.country_id;


--
-- TOC entry 498 (class 1259 OID 4886031)
-- Name: customer; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.customer (
    customer_id integer NOT NULL,
    customer_name character varying(150) NOT NULL,
    phone_number character varying(20) NOT NULL,
    email character varying(50) NOT NULL,
    address_id integer NOT NULL,
    CONSTRAINT customer_email_check CHECK ((array_length(regexp_split_to_array((email)::text, '@'::text), 1) = 2))
);


--
-- TOC entry 499 (class 1259 OID 4886035)
-- Name: customer_customer_id_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.customer_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5940 (class 0 OID 0)
-- Dependencies: 499
-- Name: customer_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.customer_customer_id_seq OWNED BY stroy.customer.customer_id;


--
-- TOC entry 500 (class 1259 OID 4886036)
-- Name: customer_type_of_work; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.customer_type_of_work (
    customer_id integer NOT NULL,
    type_of_work_id smallint NOT NULL
);


--
-- TOC entry 501 (class 1259 OID 4886039)
-- Name: employee; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.employee (
    employee_id integer NOT NULL,
    person_id integer NOT NULL,
    hire_date date NOT NULL,
    dismissal_date date,
    description text,
    CONSTRAINT employee_dismissal_date_check CHECK ((dismissal_date <= CURRENT_DATE)),
    CONSTRAINT employee_hire_date_check CHECK ((hire_date <= CURRENT_DATE))
);


--
-- TOC entry 502 (class 1259 OID 4886046)
-- Name: employee_employee_id_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.employee_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5941 (class 0 OID 0)
-- Dependencies: 502
-- Name: employee_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.employee_employee_id_seq OWNED BY stroy.employee.employee_id;


--
-- TOC entry 503 (class 1259 OID 4886047)
-- Name: employee_position; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.employee_position (
    employee_id integer NOT NULL,
    position_id smallint NOT NULL,
    salary numeric NOT NULL,
    rate numeric NOT NULL,
    start_date date,
    CONSTRAINT employee_position_salary_check CHECK ((salary >= (0)::numeric)),
    CONSTRAINT employee_position_start_date_check CHECK ((start_date <= CURRENT_DATE))
);


--
-- TOC entry 504 (class 1259 OID 4886054)
-- Name: employee_salary_history; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.employee_salary_history (
    employee_salary_history_id integer NOT NULL,
    employee_id integer NOT NULL,
    position_id smallint NOT NULL,
    salary_old numeric NOT NULL,
    start_date date,
    end_date date,
    CONSTRAINT employee_salary_history_end_date_check CHECK ((end_date <= CURRENT_DATE)),
    CONSTRAINT employee_salary_history_salary_old_check CHECK ((salary_old >= (0)::numeric)),
    CONSTRAINT employee_salary_history_start_date_check CHECK ((start_date <= CURRENT_DATE))
);


--
-- TOC entry 505 (class 1259 OID 4886062)
-- Name: employee_salary_history_employee_salary_history_id_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.employee_salary_history_employee_salary_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5942 (class 0 OID 0)
-- Dependencies: 505
-- Name: employee_salary_history_employee_salary_history_id_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.employee_salary_history_employee_salary_history_id_seq OWNED BY stroy.employee_salary_history.employee_salary_history_id;


--
-- TOC entry 506 (class 1259 OID 4886063)
-- Name: grade_salary; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.grade_salary (
    grade smallint NOT NULL,
    min_salary numeric NOT NULL,
    max_salary numeric NOT NULL,
    CONSTRAINT grade_salary_max_salary_check CHECK ((max_salary >= (0)::numeric)),
    CONSTRAINT grade_salary_min_salary_check CHECK ((min_salary >= (0)::numeric))
);


--
-- TOC entry 507 (class 1259 OID 4886070)
-- Name: grade_salary_grade_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.grade_salary_grade_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5943 (class 0 OID 0)
-- Dependencies: 507
-- Name: grade_salary_grade_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.grade_salary_grade_seq OWNED BY stroy.grade_salary.grade;


--
-- TOC entry 508 (class 1259 OID 4886071)
-- Name: person; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.person (
    person_id integer NOT NULL,
    last_name character varying(30) NOT NULL,
    first_name character varying(30) NOT NULL,
    middle_name character varying(30) NOT NULL,
    full_fio character varying(90) GENERATED ALWAYS AS (initcap((((((last_name)::text || ' '::text) || (first_name)::text) || ' '::text) || (middle_name)::text))) STORED NOT NULL,
    birthdate date NOT NULL,
    phone_number character varying(20) NOT NULL,
    email character varying(50) NOT NULL,
    address_id integer NOT NULL,
    CONSTRAINT person_birthdate_check CHECK ((date_part('year'::text, age((birthdate)::timestamp with time zone)) >= (18)::double precision)),
    CONSTRAINT person_email_check CHECK ((array_length(regexp_split_to_array((email)::text, '@'::text), 1) = 2))
);


--
-- TOC entry 509 (class 1259 OID 4886077)
-- Name: person_person_id_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.person_person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5944 (class 0 OID 0)
-- Dependencies: 509
-- Name: person_person_id_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.person_person_id_seq OWNED BY stroy.person.person_id;


--
-- TOC entry 510 (class 1259 OID 4886078)
-- Name: position; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy."position" (
    position_id smallint NOT NULL,
    position_name character varying(100) NOT NULL,
    manager_position_id integer NOT NULL,
    unit_id smallint NOT NULL,
    grade smallint,
    is_vacant boolean NOT NULL
);


--
-- TOC entry 511 (class 1259 OID 4886081)
-- Name: position_position_id_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.position_position_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5945 (class 0 OID 0)
-- Dependencies: 511
-- Name: position_position_id_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.position_position_id_seq OWNED BY stroy."position".position_id;


--
-- TOC entry 512 (class 1259 OID 4886082)
-- Name: project; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.project (
    project_id integer NOT NULL,
    project_name character varying(100) NOT NULL,
    customer_id integer NOT NULL,
    project_manager_id integer NOT NULL,
    employees_id integer[],
    project_cost numeric NOT NULL,
    sign_date date NOT NULL,
    status stroy.project_status DEFAULT 'На подписании'::stroy.project_status NOT NULL,
    description text,
    project_details jsonb,
    search_vector tsvector,
    CONSTRAINT project_project_cost_check CHECK ((project_cost >= (0)::numeric))
);


--
-- TOC entry 513 (class 1259 OID 4886089)
-- Name: project_payment; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.project_payment (
    project_payment_id integer NOT NULL,
    project_id integer NOT NULL,
    amount numeric NOT NULL,
    payment_type stroy.payment_type NOT NULL,
    plan_payment_date date NOT NULL,
    fact_transaction_timestamp timestamp without time zone,
    CONSTRAINT project_payment_amount_check CHECK ((amount >= (0)::numeric)),
    CONSTRAINT project_payment_fact_transaction_timestamp_check CHECK ((fact_transaction_timestamp <= CURRENT_TIMESTAMP))
);


--
-- TOC entry 514 (class 1259 OID 4886096)
-- Name: project_payment_project_payment_id_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.project_payment_project_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5946 (class 0 OID 0)
-- Dependencies: 514
-- Name: project_payment_project_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.project_payment_project_payment_id_seq OWNED BY stroy.project_payment.project_payment_id;


--
-- TOC entry 515 (class 1259 OID 4886097)
-- Name: project_project_id_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.project_project_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5947 (class 0 OID 0)
-- Dependencies: 515
-- Name: project_project_id_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.project_project_id_seq OWNED BY stroy.project.project_id;


--
-- TOC entry 516 (class 1259 OID 4886098)
-- Name: type_of_work; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.type_of_work (
    type_of_work_id smallint NOT NULL,
    type_of_work_name character varying(50) NOT NULL
);


--
-- TOC entry 517 (class 1259 OID 4886101)
-- Name: type_of_work_type_of_work_id_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.type_of_work_type_of_work_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5948 (class 0 OID 0)
-- Dependencies: 517
-- Name: type_of_work_type_of_work_id_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.type_of_work_type_of_work_id_seq OWNED BY stroy.type_of_work.type_of_work_id;


--
-- TOC entry 518 (class 1259 OID 4886102)
-- Name: unit_type; Type: TABLE; Schema: stroy; Owner: -
--

CREATE TABLE stroy.unit_type (
    unit_type_id smallint NOT NULL,
    unit_type_name character varying(100) NOT NULL
);


--
-- TOC entry 519 (class 1259 OID 4886105)
-- Name: unit_type_unit_type_id_seq; Type: SEQUENCE; Schema: stroy; Owner: -
--

CREATE SEQUENCE stroy.unit_type_unit_type_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5949 (class 0 OID 0)
-- Dependencies: 519
-- Name: unit_type_unit_type_id_seq; Type: SEQUENCE OWNED BY; Schema: stroy; Owner: -
--

ALTER SEQUENCE stroy.unit_type_unit_type_id_seq OWNED BY stroy.unit_type.unit_type_id;


--
-- TOC entry 5640 (class 2604 OID 4886106)
-- Name: address address_id; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.address ALTER COLUMN address_id SET DEFAULT nextval('stroy.address_address_id_seq'::regclass);


--
-- TOC entry 5641 (class 2604 OID 4886107)
-- Name: city city_id; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.city ALTER COLUMN city_id SET DEFAULT nextval('stroy.city_city_id_seq'::regclass);


--
-- TOC entry 5642 (class 2604 OID 4886108)
-- Name: company_structure unit_id; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.company_structure ALTER COLUMN unit_id SET DEFAULT nextval('stroy.company_structure_unit_id_seq'::regclass);


--
-- TOC entry 5643 (class 2604 OID 4886109)
-- Name: country country_id; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.country ALTER COLUMN country_id SET DEFAULT nextval('stroy.country_country_id_seq'::regclass);


--
-- TOC entry 5644 (class 2604 OID 4886110)
-- Name: customer customer_id; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.customer ALTER COLUMN customer_id SET DEFAULT nextval('stroy.customer_customer_id_seq'::regclass);


--
-- TOC entry 5645 (class 2604 OID 4886111)
-- Name: employee employee_id; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.employee ALTER COLUMN employee_id SET DEFAULT nextval('stroy.employee_employee_id_seq'::regclass);


--
-- TOC entry 5646 (class 2604 OID 4886112)
-- Name: employee_salary_history employee_salary_history_id; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.employee_salary_history ALTER COLUMN employee_salary_history_id SET DEFAULT nextval('stroy.employee_salary_history_employee_salary_history_id_seq'::regclass);


--
-- TOC entry 5647 (class 2604 OID 4886113)
-- Name: grade_salary grade; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.grade_salary ALTER COLUMN grade SET DEFAULT nextval('stroy.grade_salary_grade_seq'::regclass);


--
-- TOC entry 5648 (class 2604 OID 4886114)
-- Name: person person_id; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.person ALTER COLUMN person_id SET DEFAULT nextval('stroy.person_person_id_seq'::regclass);


--
-- TOC entry 5650 (class 2604 OID 4886115)
-- Name: position position_id; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy."position" ALTER COLUMN position_id SET DEFAULT nextval('stroy.position_position_id_seq'::regclass);


--
-- TOC entry 5651 (class 2604 OID 4886116)
-- Name: project project_id; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.project ALTER COLUMN project_id SET DEFAULT nextval('stroy.project_project_id_seq'::regclass);


--
-- TOC entry 5653 (class 2604 OID 4886117)
-- Name: project_payment project_payment_id; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.project_payment ALTER COLUMN project_payment_id SET DEFAULT nextval('stroy.project_payment_project_payment_id_seq'::regclass);


--
-- TOC entry 5654 (class 2604 OID 4886118)
-- Name: type_of_work type_of_work_id; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.type_of_work ALTER COLUMN type_of_work_id SET DEFAULT nextval('stroy.type_of_work_type_of_work_id_seq'::regclass);


--
-- TOC entry 5655 (class 2604 OID 4886119)
-- Name: unit_type unit_type_id; Type: DEFAULT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.unit_type ALTER COLUMN unit_type_id SET DEFAULT nextval('stroy.unit_type_unit_type_id_seq'::regclass);


--
-- TOC entry 5900 (class 0 OID 4886015)
-- Dependencies: 490
-- Data for Name: address; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.address VALUES (1, 'Генерала Дорохова, 26', 40);
INSERT INTO stroy.address VALUES (2, 'Рошаля, 19', 2);
INSERT INTO stroy.address VALUES (3, 'Весёлая, 43', 26);
INSERT INTO stroy.address VALUES (4, 'Советская  На Дон, 58', 18);
INSERT INTO stroy.address VALUES (5, 'Автодоровская, 1', 39);
INSERT INTO stroy.address VALUES (6, 'Северная, 45', 5);
INSERT INTO stroy.address VALUES (7, 'Осипенко, 36', 4);
INSERT INTO stroy.address VALUES (8, 'Ромодановские Дворики, 55', 47);
INSERT INTO stroy.address VALUES (9, 'Панфилова, 81', 18);
INSERT INTO stroy.address VALUES (10, 'Обручева, 48', 41);
INSERT INTO stroy.address VALUES (11, 'Перфильева, 85', 33);
INSERT INTO stroy.address VALUES (12, 'Праволинейная, 96', 40);
INSERT INTO stroy.address VALUES (13, 'Знаменка, 3', 16);
INSERT INTO stroy.address VALUES (14, 'Высоковольтная, 37', 38);
INSERT INTO stroy.address VALUES (15, 'Ольговская, 4', 31);
INSERT INTO stroy.address VALUES (16, 'Гранатная, 68', 34);
INSERT INTO stroy.address VALUES (17, 'Старо-Московская, 16', 3);
INSERT INTO stroy.address VALUES (18, 'Черневская, 35', 16);
INSERT INTO stroy.address VALUES (19, 'Рощинская, 69', 41);
INSERT INTO stroy.address VALUES (20, 'Петра Смидовича, 2', 21);
INSERT INTO stroy.address VALUES (21, 'Новая Калиновка, 31', 8);
INSERT INTO stroy.address VALUES (22, 'Ситниковская, 50', 14);
INSERT INTO stroy.address VALUES (23, 'Тарасова, 90', 1);
INSERT INTO stroy.address VALUES (24, '25 Сентября, 99', 15);
INSERT INTO stroy.address VALUES (25, 'Молдагуловой, 34', 12);
INSERT INTO stroy.address VALUES (26, 'Майора Алексеева, 22', 6);
INSERT INTO stroy.address VALUES (27, 'Войстроченко А.Ф., 32', 40);
INSERT INTO stroy.address VALUES (28, 'Большая Норская, 39', 10);
INSERT INTO stroy.address VALUES (29, 'Новая, 88', 38);
INSERT INTO stroy.address VALUES (30, 'Трубникова, 68', 6);
INSERT INTO stroy.address VALUES (31, 'Ольговская, 39', 27);
INSERT INTO stroy.address VALUES (32, 'Ольминского, 96', 3);
INSERT INTO stroy.address VALUES (33, 'Ильича, 35', 7);
INSERT INTO stroy.address VALUES (34, '26-Ти Бакинских Комиссаров, 100', 11);
INSERT INTO stroy.address VALUES (35, 'Советов, 31', 11);
INSERT INTO stroy.address VALUES (36, 'Вертолётчиков, 10', 17);
INSERT INTO stroy.address VALUES (37, 'Полежаева, 64', 12);
INSERT INTO stroy.address VALUES (38, 'Поэта Лебедева, 7', 44);
INSERT INTO stroy.address VALUES (39, 'Суздальская, 63', 32);
INSERT INTO stroy.address VALUES (40, 'Куйбышева, 89', 26);
INSERT INTO stroy.address VALUES (41, 'Придорожная, 43', 30);
INSERT INTO stroy.address VALUES (42, 'Мясникова, 5', 5);
INSERT INTO stroy.address VALUES (43, 'Яна Берзина, 72', 21);
INSERT INTO stroy.address VALUES (44, 'Возмище, 83', 22);
INSERT INTO stroy.address VALUES (45, 'Еременко, 76', 36);
INSERT INTO stroy.address VALUES (46, 'Приборостроителей, 15', 34);
INSERT INTO stroy.address VALUES (47, 'Захарченко, 83', 30);
INSERT INTO stroy.address VALUES (48, 'Культурная, 11', 39);
INSERT INTO stroy.address VALUES (49, 'Итальянская, 15', 32);
INSERT INTO stroy.address VALUES (50, 'Цветочная, 25', 11);
INSERT INTO stroy.address VALUES (51, 'Пмк-6, 13', 16);
INSERT INTO stroy.address VALUES (52, 'Конная, 39', 15);
INSERT INTO stroy.address VALUES (53, 'Ливенская, 35', 18);
INSERT INTO stroy.address VALUES (54, 'Красная Пресня, 74', 36);
INSERT INTO stroy.address VALUES (55, 'Леонтия Кривенкова, 72', 32);
INSERT INTO stroy.address VALUES (56, 'Льговский Шлях, 92', 20);
INSERT INTO stroy.address VALUES (57, 'Пайтерова, 59', 41);
INSERT INTO stroy.address VALUES (58, 'Ижорская, 23', 37);
INSERT INTO stroy.address VALUES (59, 'Урицкого, 26', 18);
INSERT INTO stroy.address VALUES (60, 'Новая Курская, 93', 4);
INSERT INTO stroy.address VALUES (61, 'Шкрылёва, 24', 45);
INSERT INTO stroy.address VALUES (62, 'Пугачёва, 97', 42);
INSERT INTO stroy.address VALUES (63, 'Долматова, 46', 27);
INSERT INTO stroy.address VALUES (64, 'Клушинская, 91', 13);
INSERT INTO stroy.address VALUES (65, 'Лебедянская, 83', 8);
INSERT INTO stroy.address VALUES (66, 'Петра I, 15', 23);
INSERT INTO stroy.address VALUES (67, 'Люсиновская, 6', 38);
INSERT INTO stroy.address VALUES (68, 'Ленинградская, 6', 8);
INSERT INTO stroy.address VALUES (69, 'Им. М.Горького, 63', 19);
INSERT INTO stroy.address VALUES (70, 'Горбатова, 5', 18);
INSERT INTO stroy.address VALUES (71, 'Переславская, 90', 25);
INSERT INTO stroy.address VALUES (72, 'Погодина, 29', 39);
INSERT INTO stroy.address VALUES (73, 'Калужская, 30', 2);
INSERT INTO stroy.address VALUES (74, 'Декабристов, 79', 26);
INSERT INTO stroy.address VALUES (75, 'Барыбинская, 93', 35);
INSERT INTO stroy.address VALUES (76, 'Новая Слобода, 47', 14);
INSERT INTO stroy.address VALUES (77, 'Беломорская, 84', 24);
INSERT INTO stroy.address VALUES (78, 'Весенняя, 98', 42);
INSERT INTO stroy.address VALUES (79, '10-Й Армии, 43', 24);
INSERT INTO stroy.address VALUES (80, 'Фокина, 3', 13);
INSERT INTO stroy.address VALUES (81, 'Салтыковская, 44', 29);
INSERT INTO stroy.address VALUES (82, '20 Лет Победы, 58', 11);
INSERT INTO stroy.address VALUES (83, 'Кустарная, 73', 11);
INSERT INTO stroy.address VALUES (84, 'Валентины Терешковой, 29', 16);
INSERT INTO stroy.address VALUES (85, 'Живописная, 24', 12);
INSERT INTO stroy.address VALUES (86, 'Чкалова, 27', 18);
INSERT INTO stroy.address VALUES (87, 'Нахимова, 47', 35);
INSERT INTO stroy.address VALUES (88, 'Димитрова, 14', 27);
INSERT INTO stroy.address VALUES (89, '9 Января, 15', 43);
INSERT INTO stroy.address VALUES (90, 'Наумова, 32', 32);
INSERT INTO stroy.address VALUES (91, '1-Е Пушкари, 3', 39);
INSERT INTO stroy.address VALUES (92, '25 Сентября, 76', 19);
INSERT INTO stroy.address VALUES (93, 'Бабенко, 65', 11);
INSERT INTO stroy.address VALUES (94, 'Красный Бор, 23', 12);
INSERT INTO stroy.address VALUES (95, 'Большак, 57', 15);
INSERT INTO stroy.address VALUES (96, 'Белоусова, 86', 30);
INSERT INTO stroy.address VALUES (97, 'Яузская, 86', 24);
INSERT INTO stroy.address VALUES (98, 'Торопецкая, 80', 26);
INSERT INTO stroy.address VALUES (99, 'Александры Монаховой, 88', 21);
INSERT INTO stroy.address VALUES (100, '1-Я Минеевская, 59', 37);
INSERT INTO stroy.address VALUES (101, 'Арбатецкая, 29', 43);
INSERT INTO stroy.address VALUES (102, 'Рогова, 23', 15);
INSERT INTO stroy.address VALUES (103, 'Аксёнова, 47', 27);
INSERT INTO stroy.address VALUES (104, 'Внуковская, 12', 16);
INSERT INTO stroy.address VALUES (105, 'Пески Набережные, 26', 3);
INSERT INTO stroy.address VALUES (106, 'Садовая-Спасская, 62', 4);
INSERT INTO stroy.address VALUES (107, '249-Й Стрелковой Дивизии, 82', 34);
INSERT INTO stroy.address VALUES (108, '9-Я Парковая, 50', 14);
INSERT INTO stroy.address VALUES (109, 'Академика Доллежаля, 89', 40);
INSERT INTO stroy.address VALUES (110, 'Тихонравова, 90', 12);
INSERT INTO stroy.address VALUES (111, 'Рыльский Шлях, 15', 44);
INSERT INTO stroy.address VALUES (112, 'Гремяченская, 24', 39);
INSERT INTO stroy.address VALUES (113, 'Фурманова, 76', 43);
INSERT INTO stroy.address VALUES (114, 'Академика Пилюгина, 52', 10);
INSERT INTO stroy.address VALUES (115, 'Полка Нормандия-Неман, 25', 27);
INSERT INTO stroy.address VALUES (116, 'Кабаново, 44', 14);
INSERT INTO stroy.address VALUES (117, 'Воронцовская, 74', 24);
INSERT INTO stroy.address VALUES (118, 'Лызлова, 80', 26);
INSERT INTO stroy.address VALUES (119, 'Патриаршая, 17', 42);
INSERT INTO stroy.address VALUES (120, 'Панина, 70', 33);
INSERT INTO stroy.address VALUES (121, 'Эрденко, 5', 45);
INSERT INTO stroy.address VALUES (122, 'Шереметовка, 88', 2);
INSERT INTO stroy.address VALUES (123, 'Внуковская, 3', 36);
INSERT INTO stroy.address VALUES (124, 'Ватутина, 95', 10);
INSERT INTO stroy.address VALUES (125, 'Берникова, 89', 44);
INSERT INTO stroy.address VALUES (126, 'Донская, 52', 40);
INSERT INTO stroy.address VALUES (127, 'Садовая-Триумфальная, 32', 23);
INSERT INTO stroy.address VALUES (128, 'Коломенская, 16', 24);
INSERT INTO stroy.address VALUES (129, 'Макаренко, 39', 26);
INSERT INTO stroy.address VALUES (130, 'Гоголя, 71', 45);
INSERT INTO stroy.address VALUES (131, 'Павшинская, 4', 24);
INSERT INTO stroy.address VALUES (132, 'Революционная, 59', 20);
INSERT INTO stroy.address VALUES (133, 'Сталелитейная, 52', 15);
INSERT INTO stroy.address VALUES (134, 'Круговая, 18', 36);
INSERT INTO stroy.address VALUES (135, 'Череповецкая, 12', 6);
INSERT INTO stroy.address VALUES (136, 'Машиностроителей, 31', 47);
INSERT INTO stroy.address VALUES (137, 'Промышленная, 13', 47);
INSERT INTO stroy.address VALUES (138, 'Михаила Заботина, 100', 6);
INSERT INTO stroy.address VALUES (139, 'Старые Кремёнки, 84', 34);
INSERT INTO stroy.address VALUES (140, 'Подазовская, 76', 42);
INSERT INTO stroy.address VALUES (141, 'Понятовская, 92', 9);
INSERT INTO stroy.address VALUES (142, 'Кожевнический Вражек, 80', 8);
INSERT INTO stroy.address VALUES (143, 'Кимрская, 74', 16);
INSERT INTO stroy.address VALUES (144, 'Мусоргского, 19', 6);
INSERT INTO stroy.address VALUES (145, '2-Я Агрономическая, 18', 34);
INSERT INTO stroy.address VALUES (146, 'Халтурина, 21', 25);
INSERT INTO stroy.address VALUES (147, 'Академика Жукова, 52', 5);
INSERT INTO stroy.address VALUES (148, 'Леонтия Кривенкова, 7', 8);
INSERT INTO stroy.address VALUES (149, 'Литвинова, 4', 2);
INSERT INTO stroy.address VALUES (150, 'Озёрная, 100', 3);
INSERT INTO stroy.address VALUES (151, 'Большая Полянка, 4', 42);
INSERT INTO stroy.address VALUES (152, 'Шевченко, 43', 40);
INSERT INTO stroy.address VALUES (153, 'Плещеева, 97', 45);
INSERT INTO stroy.address VALUES (154, 'Моршанская, 38', 39);
INSERT INTO stroy.address VALUES (155, 'Россошанская, 90', 6);
INSERT INTO stroy.address VALUES (156, '1-Я  Вагонников, 57', 32);
INSERT INTO stroy.address VALUES (157, 'Абельмановская, 45', 39);
INSERT INTO stroy.address VALUES (158, 'Молодогвардейская, 9', 27);
INSERT INTO stroy.address VALUES (159, 'Стаханова, 60', 26);
INSERT INTO stroy.address VALUES (160, 'Кетчерская, 11', 24);
INSERT INTO stroy.address VALUES (161, 'Тюрина, 24', 38);
INSERT INTO stroy.address VALUES (162, 'Иловайская, 64', 44);
INSERT INTO stroy.address VALUES (163, 'Урицкого, 51', 14);
INSERT INTO stroy.address VALUES (164, 'Грибоедова, 86', 18);
INSERT INTO stroy.address VALUES (165, 'Менжинского, 33', 35);
INSERT INTO stroy.address VALUES (166, 'Рудинская, 83', 1);
INSERT INTO stroy.address VALUES (167, 'Новосёловка, 89', 31);
INSERT INTO stroy.address VALUES (168, 'Комарова, 2', 8);
INSERT INTO stroy.address VALUES (169, 'Расторгуева, 24', 29);
INSERT INTO stroy.address VALUES (170, 'Валентиновская, 16', 21);
INSERT INTO stroy.address VALUES (171, 'Красных Зорь, 26', 13);
INSERT INTO stroy.address VALUES (172, 'Сахарова, 36', 43);
INSERT INTO stroy.address VALUES (173, 'Рябиновая, 18', 26);
INSERT INTO stroy.address VALUES (174, 'Иванова, 40', 46);
INSERT INTO stroy.address VALUES (175, 'Большая Филёвская, 93', 34);
INSERT INTO stroy.address VALUES (176, 'М.Горького, 42', 32);
INSERT INTO stroy.address VALUES (177, 'Максима Горького, 90', 23);
INSERT INTO stroy.address VALUES (178, 'Кусковская, 8', 28);
INSERT INTO stroy.address VALUES (179, 'Макарова, 69', 20);
INSERT INTO stroy.address VALUES (180, 'Старомосковская, 24', 16);
INSERT INTO stroy.address VALUES (181, 'Шарикоподшипниковская, 31', 36);
INSERT INTO stroy.address VALUES (182, 'Артёмовская, 25', 5);
INSERT INTO stroy.address VALUES (183, 'Лебеденко, 26', 45);
INSERT INTO stroy.address VALUES (184, 'Головлева, 24', 17);
INSERT INTO stroy.address VALUES (185, 'Новосёлки, 59', 44);
INSERT INTO stroy.address VALUES (186, 'Большая Нижегородская, 70', 43);
INSERT INTO stroy.address VALUES (187, 'Крупешина, 84', 38);
INSERT INTO stroy.address VALUES (188, 'Большая Полянка, 42', 9);
INSERT INTO stroy.address VALUES (189, 'Фурманова, 40', 4);
INSERT INTO stroy.address VALUES (190, 'Лескова, 58', 30);
INSERT INTO stroy.address VALUES (191, 'Пантелеевская, 87', 38);
INSERT INTO stroy.address VALUES (192, 'Беленовка, 44', 40);
INSERT INTO stroy.address VALUES (193, 'Энтузиастов, 100', 13);
INSERT INTO stroy.address VALUES (194, 'Холодово, 74', 14);
INSERT INTO stroy.address VALUES (195, 'Нижняя Масловка, 100', 33);
INSERT INTO stroy.address VALUES (196, 'Старообрядческая, 45', 3);
INSERT INTO stroy.address VALUES (197, 'Рабфаковская, 57', 36);
INSERT INTO stroy.address VALUES (198, 'Телевизионная, 21', 3);
INSERT INTO stroy.address VALUES (199, 'Лебеденко, 21', 6);
INSERT INTO stroy.address VALUES (200, 'Артековская, 88', 44);
INSERT INTO stroy.address VALUES (201, 'Скобелевская, 93', 47);
INSERT INTO stroy.address VALUES (202, 'Изыскателей, 82', 13);
INSERT INTO stroy.address VALUES (203, 'Островитянова, 21', 7);
INSERT INTO stroy.address VALUES (204, 'Ливенская, 82', 10);
INSERT INTO stroy.address VALUES (205, 'Ленина, 9', 31);
INSERT INTO stroy.address VALUES (206, 'Пристанционная, 81', 9);
INSERT INTO stroy.address VALUES (207, 'Нижняя Слободка, 82', 10);
INSERT INTO stroy.address VALUES (208, 'Жерновецкая, 57', 37);
INSERT INTO stroy.address VALUES (209, 'Хользунова, 38', 11);
INSERT INTO stroy.address VALUES (210, 'Госпитальный Вал, 54', 36);
INSERT INTO stroy.address VALUES (211, 'Бубнова, 34', 21);
INSERT INTO stroy.address VALUES (212, 'Воротынская, 26', 9);
INSERT INTO stroy.address VALUES (213, '3 Интернационала, 0', 33);
INSERT INTO stroy.address VALUES (214, 'Куконковых, 54', 3);
INSERT INTO stroy.address VALUES (215, 'Краснознамённая, 23', 37);
INSERT INTO stroy.address VALUES (216, 'Успенская, 50', 9);
INSERT INTO stroy.address VALUES (217, 'Туполева, 81', 33);
INSERT INTO stroy.address VALUES (218, 'Спирина, 34', 29);
INSERT INTO stroy.address VALUES (219, 'Потылиха, 90', 21);
INSERT INTO stroy.address VALUES (220, '100-Й Свирской Дивизии, 85', 23);
INSERT INTO stroy.address VALUES (221, 'Петра Смидовича, 8', 2);
INSERT INTO stroy.address VALUES (222, 'Звёздная, 88', 5);
INSERT INTO stroy.address VALUES (223, 'Байдарская, 94', 11);
INSERT INTO stroy.address VALUES (224, '1-Й Конной Армии, 90', 2);
INSERT INTO stroy.address VALUES (225, 'Наумова, 48', 12);
INSERT INTO stroy.address VALUES (226, 'Яшенина, 26', 16);
INSERT INTO stroy.address VALUES (227, 'Богдановича, 74', 45);
INSERT INTO stroy.address VALUES (228, 'Саранская, 13', 14);
INSERT INTO stroy.address VALUES (229, 'Большая Норская, 27', 5);
INSERT INTO stroy.address VALUES (230, 'Подъячева, 45', 41);
INSERT INTO stroy.address VALUES (231, 'Бирюзова, 92', 15);
INSERT INTO stroy.address VALUES (232, '9-Го Мая, 39', 15);
INSERT INTO stroy.address VALUES (233, 'Электрофикации, 10', 15);
INSERT INTO stroy.address VALUES (234, 'Городской Вал, 38', 29);
INSERT INTO stroy.address VALUES (235, 'Ерошенко, 34', 20);
INSERT INTO stroy.address VALUES (236, '20-Летия Октября, 77', 21);
INSERT INTO stroy.address VALUES (237, 'Новогиреевская, 93', 17);
INSERT INTO stroy.address VALUES (238, 'Освобождения, 59', 4);
INSERT INTO stroy.address VALUES (239, 'Ермака, 14', 16);
INSERT INTO stroy.address VALUES (240, 'Старо-Московская, 30', 34);
INSERT INTO stroy.address VALUES (241, 'Дуниловская, 80', 13);
INSERT INTO stroy.address VALUES (242, 'Красногвардейская, 99', 44);
INSERT INTO stroy.address VALUES (243, 'Рождественская, 38', 43);
INSERT INTO stroy.address VALUES (244, 'Центральная, 72', 44);
INSERT INTO stroy.address VALUES (245, '1-Я Владимирская, 94', 30);
INSERT INTO stroy.address VALUES (246, 'Толстого, 47', 2);
INSERT INTO stroy.address VALUES (247, 'Безыменского, 44', 46);
INSERT INTO stroy.address VALUES (248, 'Бибиревская, 37', 20);
INSERT INTO stroy.address VALUES (249, 'Пятницкая, 2', 14);
INSERT INTO stroy.address VALUES (250, 'Поликарпова, 35', 2);
INSERT INTO stroy.address VALUES (251, 'Тестовская, 49', 17);
INSERT INTO stroy.address VALUES (252, 'Орджоникидзе, 94', 15);
INSERT INTO stroy.address VALUES (253, 'Большая Якиманка, 10', 28);
INSERT INTO stroy.address VALUES (254, 'Полянской, 15', 23);
INSERT INTO stroy.address VALUES (255, 'Фокина, 71', 4);
INSERT INTO stroy.address VALUES (256, 'Королёва, 40', 7);
INSERT INTO stroy.address VALUES (257, '2-Я  Машиностроения, 36', 29);
INSERT INTO stroy.address VALUES (258, 'Полиграфская, 27', 24);
INSERT INTO stroy.address VALUES (259, 'Советская, 82', 38);
INSERT INTO stroy.address VALUES (260, 'Папивина, 24', 40);
INSERT INTO stroy.address VALUES (261, 'Дмитриева; Карла Маркса, 31', 41);
INSERT INTO stroy.address VALUES (262, 'Зимёнковская, 15', 8);
INSERT INTO stroy.address VALUES (263, 'Ялагина, 62', 37);
INSERT INTO stroy.address VALUES (264, 'Загорская, 37', 28);
INSERT INTO stroy.address VALUES (265, 'Рошаля, 13', 4);
INSERT INTO stroy.address VALUES (266, 'Шацкая, 44', 19);
INSERT INTO stroy.address VALUES (267, 'Дубиновка, 19', 44);
INSERT INTO stroy.address VALUES (268, 'Западная, 92', 12);
INSERT INTO stroy.address VALUES (269, 'Шкрылёва, 89', 31);
INSERT INTO stroy.address VALUES (270, '40 Лет Влксм, 6', 12);
INSERT INTO stroy.address VALUES (271, 'Серёгина, 92', 31);
INSERT INTO stroy.address VALUES (272, 'Суджанский Шлях, 25', 1);
INSERT INTO stroy.address VALUES (273, 'Тимирязева, 46', 15);
INSERT INTO stroy.address VALUES (274, 'Покрышкина, 83', 33);
INSERT INTO stroy.address VALUES (275, 'Станционная, 52', 24);
INSERT INTO stroy.address VALUES (276, '8 Марта, 56', 5);
INSERT INTO stroy.address VALUES (277, 'Маши Порываевой, 90', 20);
INSERT INTO stroy.address VALUES (278, 'Неделинская, 24', 28);
INSERT INTO stroy.address VALUES (279, 'Строительная, 57', 24);
INSERT INTO stroy.address VALUES (280, 'Текстильщиков, 29', 42);
INSERT INTO stroy.address VALUES (281, 'Лётчика Бабушкина, 28', 5);
INSERT INTO stroy.address VALUES (282, 'Журавлёва, 81', 7);
INSERT INTO stroy.address VALUES (283, 'Амет-Хан Султана, 49', 46);
INSERT INTO stroy.address VALUES (284, 'Павла Большевикова, 9', 30);
INSERT INTO stroy.address VALUES (285, 'Киквидзе, 22', 10);
INSERT INTO stroy.address VALUES (286, 'Круговая, 83', 5);
INSERT INTO stroy.address VALUES (287, 'Паши Савельевой, 57', 41);
INSERT INTO stroy.address VALUES (288, 'Эрденко, 85', 4);
INSERT INTO stroy.address VALUES (289, 'Левобережная, 79', 16);
INSERT INTO stroy.address VALUES (290, 'Октябрьская Площадь, 10', 28);
INSERT INTO stroy.address VALUES (291, 'Лётчицы Тарасовой, 20', 24);
INSERT INTO stroy.address VALUES (292, 'Садовая-Триумфальная  (Дублёр), 8', 38);
INSERT INTO stroy.address VALUES (293, 'Звёздная, 78', 31);
INSERT INTO stroy.address VALUES (294, 'Бессолова, 83', 39);
INSERT INTO stroy.address VALUES (295, 'Туристская, 68', 12);
INSERT INTO stroy.address VALUES (296, 'Новоторжская, 33', 47);
INSERT INTO stroy.address VALUES (297, 'Клушинская, 88', 21);
INSERT INTO stroy.address VALUES (298, 'Дзержинского, 61', 20);
INSERT INTO stroy.address VALUES (299, 'Крюкова, 21', 40);
INSERT INTO stroy.address VALUES (300, 'Внуковская, 77', 8);
INSERT INTO stroy.address VALUES (301, 'Братская Площадь, 30', 20);
INSERT INTO stroy.address VALUES (302, 'Ньютона, 73', 31);
INSERT INTO stroy.address VALUES (303, 'Российская, 15', 27);
INSERT INTO stroy.address VALUES (304, 'Блинова, 68', 42);
INSERT INTO stroy.address VALUES (305, 'Моторостроителей, 68', 43);
INSERT INTO stroy.address VALUES (306, 'Ильюшина, 93', 7);
INSERT INTO stroy.address VALUES (307, 'Подъячева, 47', 1);
INSERT INTO stroy.address VALUES (308, 'Большая Покровская, 81', 15);
INSERT INTO stroy.address VALUES (309, 'Верхние Поля, 83', 14);
INSERT INTO stroy.address VALUES (310, 'Новоостаповская, 11', 24);
INSERT INTO stroy.address VALUES (311, 'Ижорская, 59', 44);
INSERT INTO stroy.address VALUES (312, 'Совхозная, 34', 36);
INSERT INTO stroy.address VALUES (313, 'Павлова, 89', 4);
INSERT INTO stroy.address VALUES (314, '2-Я  Мичурина, 59', 41);
INSERT INTO stroy.address VALUES (315, 'Старомихневская, 63', 38);
INSERT INTO stroy.address VALUES (316, 'Колосова, 92', 6);
INSERT INTO stroy.address VALUES (317, 'Строительная, 25', 36);
INSERT INTO stroy.address VALUES (318, 'Садовая-Спасская, 80', 46);
INSERT INTO stroy.address VALUES (319, 'Просторная, 83', 14);
INSERT INTO stroy.address VALUES (320, 'Ртс, 26', 17);
INSERT INTO stroy.address VALUES (321, 'Большая Учительская, 6', 43);
INSERT INTO stroy.address VALUES (322, 'Вологодская, 98', 47);
INSERT INTO stroy.address VALUES (323, 'Куженкинское Шоссе, 5', 34);
INSERT INTO stroy.address VALUES (324, 'Круговая, 31', 41);
INSERT INTO stroy.address VALUES (325, 'Палехская, 37', 6);
INSERT INTO stroy.address VALUES (326, 'Салтыкова-Щедрина, 47', 33);
INSERT INTO stroy.address VALUES (327, 'Хлебная, 80', 20);
INSERT INTO stroy.address VALUES (328, 'Маршала Воробьёва, 51', 47);
INSERT INTO stroy.address VALUES (329, 'Подъячева, 76', 4);
INSERT INTO stroy.address VALUES (330, 'Северный Посёлок, 66', 46);
INSERT INTO stroy.address VALUES (331, 'Трёхгорный Вал, 23', 16);
INSERT INTO stroy.address VALUES (332, 'Белгородская, 29', 32);
INSERT INTO stroy.address VALUES (333, 'Севрюкова, 12', 43);
INSERT INTO stroy.address VALUES (334, 'Кожедуба, 34', 35);
INSERT INTO stroy.address VALUES (335, 'Владимирская, 75', 29);
INSERT INTO stroy.address VALUES (336, 'Подгорная, 58', 12);
INSERT INTO stroy.address VALUES (337, 'Новобутовская, 19', 28);
INSERT INTO stroy.address VALUES (338, 'Дмитриевская, 26', 33);
INSERT INTO stroy.address VALUES (339, 'Гарская, 57', 11);
INSERT INTO stroy.address VALUES (340, 'Северная Советская, 28', 23);
INSERT INTO stroy.address VALUES (341, '26-Ти Бакинских Комиссаров, 23', 35);
INSERT INTO stroy.address VALUES (342, 'Клушинская, 22', 5);
INSERT INTO stroy.address VALUES (343, 'Старо-Московская, 19', 32);
INSERT INTO stroy.address VALUES (344, 'Благоева, 4', 1);
INSERT INTO stroy.address VALUES (345, 'Ново-Белинского, 56', 1);
INSERT INTO stroy.address VALUES (346, 'Партизанская, 95', 42);
INSERT INTO stroy.address VALUES (347, 'Героев Стратосферы, 82', 43);
INSERT INTO stroy.address VALUES (348, 'Деревягина, 32', 5);
INSERT INTO stroy.address VALUES (349, 'Симоновский Вал, 14', 26);
INSERT INTO stroy.address VALUES (350, 'Малаховского, 99', 16);
INSERT INTO stroy.address VALUES (351, 'Тополёвая, 81', 3);
INSERT INTO stroy.address VALUES (352, 'Пески Набережные, 61', 26);
INSERT INTO stroy.address VALUES (353, 'Им. М.Горького, 98', 45);
INSERT INTO stroy.address VALUES (354, 'Кузнецова, 72', 1);
INSERT INTO stroy.address VALUES (355, 'Мадонская, 86', 35);
INSERT INTO stroy.address VALUES (356, 'Огородная, 28', 44);
INSERT INTO stroy.address VALUES (357, 'Изыскателей, 36', 40);
INSERT INTO stroy.address VALUES (358, 'Любимова, 96', 8);
INSERT INTO stroy.address VALUES (359, 'Рябикова, 17', 9);
INSERT INTO stroy.address VALUES (360, 'Вострухина, 77', 26);
INSERT INTO stroy.address VALUES (361, 'Генерала Ермолова, 15', 13);
INSERT INTO stroy.address VALUES (362, 'Генерала Костенко, 61', 35);
INSERT INTO stroy.address VALUES (363, 'Ананченко, 73', 30);
INSERT INTO stroy.address VALUES (364, '50 Лет Октября, 78', 9);
INSERT INTO stroy.address VALUES (365, 'Прядченко, 55', 20);
INSERT INTO stroy.address VALUES (366, 'Марфы Белоглядовой, 79', 20);
INSERT INTO stroy.address VALUES (367, 'Носова, 22', 2);
INSERT INTO stroy.address VALUES (368, 'Панфилова, 0', 5);
INSERT INTO stroy.address VALUES (369, '1-Я Радиальная, 42', 13);
INSERT INTO stroy.address VALUES (370, 'Щёлокова, 90', 2);
INSERT INTO stroy.address VALUES (371, 'Дыбенко, 67', 19);
INSERT INTO stroy.address VALUES (372, 'Семинарская, 92', 40);
INSERT INTO stroy.address VALUES (373, '60-Й Армии, 1', 12);
INSERT INTO stroy.address VALUES (374, 'Нефтяников, 22', 22);
INSERT INTO stroy.address VALUES (375, 'Урожайная, 58', 40);
INSERT INTO stroy.address VALUES (376, 'Марченко, 62', 42);
INSERT INTO stroy.address VALUES (377, 'Школьная, 44', 44);
INSERT INTO stroy.address VALUES (378, 'Фрунзе, 39', 8);
INSERT INTO stroy.address VALUES (379, 'Базарная, 5', 2);
INSERT INTO stroy.address VALUES (380, '1-Я Центральная, 57', 25);
INSERT INTO stroy.address VALUES (381, 'Никифоровская, 48', 37);
INSERT INTO stroy.address VALUES (382, 'Германо, 0', 37);
INSERT INTO stroy.address VALUES (383, 'Чичканова, 94', 43);
INSERT INTO stroy.address VALUES (384, 'Красноармейская, 4', 41);
INSERT INTO stroy.address VALUES (385, 'Клубная, 76', 14);
INSERT INTO stroy.address VALUES (386, 'Тарана, 64', 13);
INSERT INTO stroy.address VALUES (387, 'Фридриха Энгельса, 86', 43);
INSERT INTO stroy.address VALUES (388, 'Проезжая, 80', 39);
INSERT INTO stroy.address VALUES (389, 'Федеративная, 61', 16);
INSERT INTO stroy.address VALUES (390, 'Громобоя, 49', 18);
INSERT INTO stroy.address VALUES (391, 'Трубчевская, 37', 13);
INSERT INTO stroy.address VALUES (392, '1-Я Кожевенная, 21', 41);
INSERT INTO stroy.address VALUES (393, 'Российская, 5', 28);
INSERT INTO stroy.address VALUES (394, 'Дорожный Дом, 100', 25);
INSERT INTO stroy.address VALUES (395, 'Дубиновка, 96', 42);
INSERT INTO stroy.address VALUES (396, 'Веретенникова, 88', 21);
INSERT INTO stroy.address VALUES (397, 'Советская, 43', 9);
INSERT INTO stroy.address VALUES (398, 'Карачевская, 19', 6);
INSERT INTO stroy.address VALUES (399, 'Бориса Галушкина, 82', 30);
INSERT INTO stroy.address VALUES (400, 'Соболева, 28', 39);
INSERT INTO stroy.address VALUES (401, 'Снежная, 94', 15);
INSERT INTO stroy.address VALUES (402, 'Заокольная, 66', 32);
INSERT INTO stroy.address VALUES (403, 'Лобачевского, 21', 38);
INSERT INTO stroy.address VALUES (404, 'Машинистов, 58', 44);
INSERT INTO stroy.address VALUES (405, 'Тагильская, 11', 13);
INSERT INTO stroy.address VALUES (406, 'Белова, 53', 45);
INSERT INTO stroy.address VALUES (407, 'Ленинского Юбилея, 88', 12);
INSERT INTO stroy.address VALUES (408, 'Жолудева, 67', 12);
INSERT INTO stroy.address VALUES (409, 'Низовая, 29', 8);
INSERT INTO stroy.address VALUES (410, 'Иловайская, 1', 8);
INSERT INTO stroy.address VALUES (411, 'Советской Армии, 72', 5);
INSERT INTO stroy.address VALUES (412, 'Ситниковская, 69', 11);
INSERT INTO stroy.address VALUES (413, 'Т, 46', 34);
INSERT INTO stroy.address VALUES (414, 'Складочная, 33', 33);
INSERT INTO stroy.address VALUES (415, 'Чичканова, 88', 7);
INSERT INTO stroy.address VALUES (416, 'Транспортная, 56', 19);
INSERT INTO stroy.address VALUES (417, 'Романа Брянского, 57', 10);
INSERT INTO stroy.address VALUES (418, 'Измайлова, 36', 7);
INSERT INTO stroy.address VALUES (419, 'Батова, 84', 17);
INSERT INTO stroy.address VALUES (420, 'Сергея Макеева, 88', 28);
INSERT INTO stroy.address VALUES (421, 'Болдина, 89', 45);
INSERT INTO stroy.address VALUES (422, 'Университетская, 92', 17);
INSERT INTO stroy.address VALUES (423, 'Куконковых, 48', 15);
INSERT INTO stroy.address VALUES (424, 'Бестужевых, 78', 15);
INSERT INTO stroy.address VALUES (425, 'Валентины Терешковой, 85', 43);
INSERT INTO stroy.address VALUES (426, 'Щенина, 59', 3);
INSERT INTO stroy.address VALUES (427, 'Профессиональная, 8', 39);
INSERT INTO stroy.address VALUES (428, 'Астраханская, 23', 25);
INSERT INTO stroy.address VALUES (429, 'Сельскохозяйственная, 97', 45);
INSERT INTO stroy.address VALUES (430, 'Киреева, 19', 42);
INSERT INTO stroy.address VALUES (431, '1-Я Волоколамская, 5', 8);
INSERT INTO stroy.address VALUES (432, '50 Лет Ссср, 16', 40);
INSERT INTO stroy.address VALUES (433, 'Рыленкова, 73', 10);
INSERT INTO stroy.address VALUES (434, 'Садовая-Спасская, 98', 30);
INSERT INTO stroy.address VALUES (435, 'Баумана, 96', 39);
INSERT INTO stroy.address VALUES (436, 'Студёная Гора, 12', 44);
INSERT INTO stroy.address VALUES (437, '1-Я  За Линией Октябрьской Ж/Д, 43', 13);
INSERT INTO stroy.address VALUES (438, 'Завокзальная, 79', 42);
INSERT INTO stroy.address VALUES (439, 'Наумова, 10', 44);
INSERT INTO stroy.address VALUES (440, 'Большевистская, 65', 6);
INSERT INTO stroy.address VALUES (441, 'Угличская, 53', 40);
INSERT INTO stroy.address VALUES (442, 'Германо, 53', 24);
INSERT INTO stroy.address VALUES (443, 'Коваленко, 63', 43);
INSERT INTO stroy.address VALUES (444, 'Воротынская, 16', 39);
INSERT INTO stroy.address VALUES (445, 'Дегтярёва, 82', 47);
INSERT INTO stroy.address VALUES (446, 'Осташковская, 69', 39);
INSERT INTO stroy.address VALUES (447, '6-Я Радиальная, 26', 2);
INSERT INTO stroy.address VALUES (448, 'Болотова, 15', 14);
INSERT INTO stroy.address VALUES (449, 'Лядинская, 52', 10);
INSERT INTO stroy.address VALUES (450, 'Новая Калиновка, 81', 27);
INSERT INTO stroy.address VALUES (451, 'Ватутина, 88', 10);
INSERT INTO stroy.address VALUES (452, 'Новопесчаная, 21', 45);
INSERT INTO stroy.address VALUES (453, 'Салтыковская, 47', 38);
INSERT INTO stroy.address VALUES (454, 'Малых, 67', 27);
INSERT INTO stroy.address VALUES (455, 'Сергея Макеева, 90', 44);
INSERT INTO stroy.address VALUES (456, 'Сущёвский Вал, 1', 45);
INSERT INTO stroy.address VALUES (457, 'Суркова, 8', 23);
INSERT INTO stroy.address VALUES (458, 'Мнёвники, 79', 21);
INSERT INTO stroy.address VALUES (459, 'Ногинская, 73', 41);
INSERT INTO stroy.address VALUES (460, 'Чижова, 63', 35);
INSERT INTO stroy.address VALUES (461, 'Тёплый Стан, 47', 21);
INSERT INTO stroy.address VALUES (462, 'Сонина, 50', 24);
INSERT INTO stroy.address VALUES (463, 'Новосёлки, 36', 40);
INSERT INTO stroy.address VALUES (464, 'Новогиреевская, 6', 41);
INSERT INTO stroy.address VALUES (465, 'Залегощенская, 40', 2);
INSERT INTO stroy.address VALUES (466, 'Пронина, 87', 14);
INSERT INTO stroy.address VALUES (467, 'Дмитриевская, 23', 7);
INSERT INTO stroy.address VALUES (468, 'Большая Пролетарская, 54', 46);
INSERT INTO stroy.address VALUES (469, 'Почепская, 30', 9);
INSERT INTO stroy.address VALUES (470, 'Ярославская, 44', 9);
INSERT INTO stroy.address VALUES (471, 'Заречная, 55', 39);
INSERT INTO stroy.address VALUES (472, 'Росинка, 49', 29);
INSERT INTO stroy.address VALUES (473, 'Васильевский Тракт, 1', 30);
INSERT INTO stroy.address VALUES (474, 'Дубиновка, 73', 11);
INSERT INTO stroy.address VALUES (475, 'Серова, 46', 20);
INSERT INTO stroy.address VALUES (476, 'Бежецкая, 18', 16);
INSERT INTO stroy.address VALUES (477, 'Торопецкая, 68', 25);
INSERT INTO stroy.address VALUES (478, 'Огородная, 53', 27);
INSERT INTO stroy.address VALUES (479, 'Карачижская, 79', 33);
INSERT INTO stroy.address VALUES (480, 'Липецкая  (Дублёр), 18', 34);
INSERT INTO stroy.address VALUES (481, 'Новая Калиновка, 16', 39);
INSERT INTO stroy.address VALUES (482, 'Озеро, 56', 10);
INSERT INTO stroy.address VALUES (483, 'Алабушевская, 47', 28);
INSERT INTO stroy.address VALUES (484, 'Шишунова, 22', 23);
INSERT INTO stroy.address VALUES (485, 'Зернова, 47', 29);
INSERT INTO stroy.address VALUES (486, '206-Й Стрелковой Дивизии, 87', 33);
INSERT INTO stroy.address VALUES (487, 'Толбухина, 21', 12);
INSERT INTO stroy.address VALUES (488, 'Лесная, 90', 46);
INSERT INTO stroy.address VALUES (489, 'Анны Горностаевой, 3', 43);
INSERT INTO stroy.address VALUES (490, 'Семенюка, 75', 44);
INSERT INTO stroy.address VALUES (491, 'Коллективизации, 3', 26);
INSERT INTO stroy.address VALUES (492, 'Щёголевых, 83', 8);
INSERT INTO stroy.address VALUES (493, 'Обручева, 53', 1);
INSERT INTO stroy.address VALUES (494, 'Раменки, 24', 27);
INSERT INTO stroy.address VALUES (495, 'Новопесчаная, 39', 32);
INSERT INTO stroy.address VALUES (496, 'Комарова, 73', 26);
INSERT INTO stroy.address VALUES (497, 'Климовская, 67', 20);
INSERT INTO stroy.address VALUES (498, 'Бакинская, 13', 37);
INSERT INTO stroy.address VALUES (499, 'Станкостроителей, 35', 47);
INSERT INTO stroy.address VALUES (500, 'Моховая, 84', 25);
INSERT INTO stroy.address VALUES (501, 'Рыленкова, 28', 19);
INSERT INTO stroy.address VALUES (502, 'Почаевская, 46', 39);
INSERT INTO stroy.address VALUES (503, 'Пмк-6, 26', 34);
INSERT INTO stroy.address VALUES (504, 'Шахтёра, 36', 25);
INSERT INTO stroy.address VALUES (505, 'Березняка, 22', 27);
INSERT INTO stroy.address VALUES (506, 'Тамбовская, 87', 23);
INSERT INTO stroy.address VALUES (507, 'Малаховского, 83', 3);
INSERT INTO stroy.address VALUES (508, 'Подазовская, 74', 43);
INSERT INTO stroy.address VALUES (509, 'Руставели, 14', 36);
INSERT INTO stroy.address VALUES (510, 'Телевизионная, 80', 19);
INSERT INTO stroy.address VALUES (511, '11 Сапёров, 24', 36);
INSERT INTO stroy.address VALUES (512, 'Генерала Трубникова, 51', 30);
INSERT INTO stroy.address VALUES (513, 'Орловская, 56', 26);
INSERT INTO stroy.address VALUES (514, '60-Летия Октября, 97', 12);
INSERT INTO stroy.address VALUES (515, '2-Я Глуховская, 35', 46);
INSERT INTO stroy.address VALUES (516, 'Учительская, 36', 2);
INSERT INTO stroy.address VALUES (517, 'Брянская, 15', 32);
INSERT INTO stroy.address VALUES (518, 'Фабричная, 34', 15);
INSERT INTO stroy.address VALUES (519, 'Коровий Вал, 66', 4);
INSERT INTO stroy.address VALUES (520, 'Малеча, 61', 25);
INSERT INTO stroy.address VALUES (521, 'Придорожная, 46', 7);
INSERT INTO stroy.address VALUES (522, 'Ярцевская, 57', 35);
INSERT INTO stroy.address VALUES (523, 'Заломова, 81', 2);
INSERT INTO stroy.address VALUES (524, 'Малая Тульская, 36', 19);
INSERT INTO stroy.address VALUES (525, 'Минская, 62', 25);
INSERT INTO stroy.address VALUES (526, 'Вавилова, 35', 42);
INSERT INTO stroy.address VALUES (527, 'Нижняя Краснохолмская, 84', 39);
INSERT INTO stroy.address VALUES (528, '5-Я  Лазенки, 20', 17);
INSERT INTO stroy.address VALUES (529, 'Промышленная, 56', 36);
INSERT INTO stroy.address VALUES (530, 'Попкова, 12', 30);
INSERT INTO stroy.address VALUES (531, '1-Я Вокзальная, 73', 15);
INSERT INTO stroy.address VALUES (532, 'Ногина, 30', 15);
INSERT INTO stroy.address VALUES (533, 'Большеволжская, 43', 41);
INSERT INTO stroy.address VALUES (534, 'Белореченская, 77', 27);
INSERT INTO stroy.address VALUES (535, '25 Лет Победы, 24', 5);
INSERT INTO stroy.address VALUES (536, 'Дмитриева, 95', 14);
INSERT INTO stroy.address VALUES (537, 'Семёна Середы, 57', 15);
INSERT INTO stroy.address VALUES (538, 'Опаринская, 21', 34);
INSERT INTO stroy.address VALUES (539, '1-Я Московская, 27', 44);
INSERT INTO stroy.address VALUES (540, 'Станиславского, 25', 22);
INSERT INTO stroy.address VALUES (541, 'Молдагуловой, 21', 33);
INSERT INTO stroy.address VALUES (542, 'Новая, 6', 21);
INSERT INTO stroy.address VALUES (543, 'Дзержинского, 3', 10);
INSERT INTO stroy.address VALUES (544, 'Ямская, 44', 21);
INSERT INTO stroy.address VALUES (545, 'Тёплый Стан, 21', 30);
INSERT INTO stroy.address VALUES (546, 'Техническая, 74', 11);
INSERT INTO stroy.address VALUES (547, 'Тургенева, 81', 35);
INSERT INTO stroy.address VALUES (548, 'Планерная, 90', 17);
INSERT INTO stroy.address VALUES (549, 'Большая Семёновская, 48', 46);
INSERT INTO stroy.address VALUES (550, 'Краснооктябрьская, 29', 40);
INSERT INTO stroy.address VALUES (551, 'Новосёлки-Слободка, 55', 22);
INSERT INTO stroy.address VALUES (552, 'Фёдора Смирнова, 41', 27);
INSERT INTO stroy.address VALUES (553, 'Гражданская, 90', 45);
INSERT INTO stroy.address VALUES (554, 'Газина, 65', 36);
INSERT INTO stroy.address VALUES (555, 'Полбина, 47', 11);
INSERT INTO stroy.address VALUES (556, 'Тульская, 97', 2);
INSERT INTO stroy.address VALUES (557, '6-Я Радиальная, 63', 37);
INSERT INTO stroy.address VALUES (558, 'Нормандия-Неман, 63', 20);
INSERT INTO stroy.address VALUES (559, 'Эрнста Тельмана, 88', 22);
INSERT INTO stroy.address VALUES (560, 'Рудакова, 40', 3);
INSERT INTO stroy.address VALUES (561, '1-Я Больничная, 46', 37);
INSERT INTO stroy.address VALUES (562, 'Донецкая, 96', 32);
INSERT INTO stroy.address VALUES (563, 'Железнодорожная, 99', 27);
INSERT INTO stroy.address VALUES (564, 'Кавалерийская, 20', 30);
INSERT INTO stroy.address VALUES (565, '1-Я Кожевенная, 64', 22);
INSERT INTO stroy.address VALUES (566, 'Перфильева, 15', 4);
INSERT INTO stroy.address VALUES (567, 'Путейская, 51', 14);
INSERT INTO stroy.address VALUES (568, 'Волга, 82', 23);
INSERT INTO stroy.address VALUES (569, 'Ялтинская, 66', 35);
INSERT INTO stroy.address VALUES (570, 'Реформатского, 92', 47);
INSERT INTO stroy.address VALUES (571, 'Льнозаводская, 3', 43);
INSERT INTO stroy.address VALUES (572, 'Декабристов, 54', 37);
INSERT INTO stroy.address VALUES (573, 'Чистякова, 89', 23);
INSERT INTO stroy.address VALUES (574, '5-Я Южная, 26', 8);
INSERT INTO stroy.address VALUES (575, 'Тайнинская, 95', 26);
INSERT INTO stroy.address VALUES (576, 'Велозаводская, 53', 5);
INSERT INTO stroy.address VALUES (577, 'Лермонтовская, 34', 16);
INSERT INTO stroy.address VALUES (578, 'Клубная, 22', 45);
INSERT INTO stroy.address VALUES (579, 'Рошаля, 75', 10);
INSERT INTO stroy.address VALUES (580, '1905 Года, 83', 31);
INSERT INTO stroy.address VALUES (581, 'Васильевский Тракт, 54', 13);
INSERT INTO stroy.address VALUES (582, 'Игнатьевская, 71', 30);
INSERT INTO stroy.address VALUES (583, 'Парковая, 3', 27);
INSERT INTO stroy.address VALUES (584, 'Ивана Сусанина, 67', 14);
INSERT INTO stroy.address VALUES (585, 'Шишунова, 7', 6);
INSERT INTO stroy.address VALUES (586, 'Российских Газовиков, 37', 35);
INSERT INTO stroy.address VALUES (587, 'Промстроевская, 47', 5);
INSERT INTO stroy.address VALUES (588, 'Маргелова, 61', 15);
INSERT INTO stroy.address VALUES (589, 'Большая Воробьёвская, 41', 43);
INSERT INTO stroy.address VALUES (590, 'Летовского Ополчения, 32', 23);
INSERT INTO stroy.address VALUES (591, 'Главная, 89', 47);
INSERT INTO stroy.address VALUES (592, '1-Я Железнодорожная, 56', 6);
INSERT INTO stroy.address VALUES (593, 'Рылеева, 9', 3);
INSERT INTO stroy.address VALUES (594, 'Каретный Ряд, 97', 38);
INSERT INTO stroy.address VALUES (595, '25 Сентября, 18', 39);
INSERT INTO stroy.address VALUES (596, 'Журавлёва, 56', 33);
INSERT INTO stroy.address VALUES (597, '1-Я Пушкарная, 52', 6);
INSERT INTO stroy.address VALUES (598, 'Чоботовская, 95', 4);
INSERT INTO stroy.address VALUES (599, 'Доктора Гумилевской, 21', 2);
INSERT INTO stroy.address VALUES (600, 'Тагильская, 68', 5);
INSERT INTO stroy.address VALUES (601, 'Ксении Константиновой, 82', 43);
INSERT INTO stroy.address VALUES (602, 'Белгородского Полка, 32', 18);
INSERT INTO stroy.address VALUES (603, 'Вешняковская, 42', 47);
INSERT INTO stroy.address VALUES (604, '1-Я Путевая, 92', 11);
INSERT INTO stroy.address VALUES (605, 'Маргелова, 0', 41);
INSERT INTO stroy.address VALUES (606, 'Песочная, 96', 34);
INSERT INTO stroy.address VALUES (607, 'Судейская, 44', 10);
INSERT INTO stroy.address VALUES (608, 'Тарутинская, 53', 12);
INSERT INTO stroy.address VALUES (609, 'Токарёвская, 22', 19);
INSERT INTO stroy.address VALUES (610, 'Заокольная, 64', 1);
INSERT INTO stroy.address VALUES (611, 'Нахаевская, 26', 27);
INSERT INTO stroy.address VALUES (612, 'Киевская, 9', 33);
INSERT INTO stroy.address VALUES (613, 'Новощукинская, 66', 14);
INSERT INTO stroy.address VALUES (614, 'Вернисажная, 85', 25);
INSERT INTO stroy.address VALUES (615, 'Ленинского Юбилея, 26', 46);
INSERT INTO stroy.address VALUES (616, 'Стрелецкая, 13', 7);
INSERT INTO stroy.address VALUES (617, 'Тульская, 72', 7);
INSERT INTO stroy.address VALUES (618, 'Заволжская, 65', 4);
INSERT INTO stroy.address VALUES (619, 'Волоколамская, 30', 34);
INSERT INTO stroy.address VALUES (620, 'Высоковольтная, 74', 45);
INSERT INTO stroy.address VALUES (621, 'Малиновый Овраг, 54', 20);
INSERT INTO stroy.address VALUES (622, 'Коллективизации, 23', 2);
INSERT INTO stroy.address VALUES (623, 'Подольских Курсантов, 100', 16);
INSERT INTO stroy.address VALUES (624, 'Большая, 52', 29);
INSERT INTO stroy.address VALUES (625, 'Урожайная, 69', 20);
INSERT INTO stroy.address VALUES (626, 'Брянская, 89', 36);
INSERT INTO stroy.address VALUES (627, 'Дубининская, 76', 11);
INSERT INTO stroy.address VALUES (628, 'Жукова, 58', 26);
INSERT INTO stroy.address VALUES (629, 'Оборонная, 55', 12);
INSERT INTO stroy.address VALUES (630, 'Ялтинская, 20', 27);
INSERT INTO stroy.address VALUES (631, 'Ельнинская, 95', 29);
INSERT INTO stroy.address VALUES (632, '1-Я Сосновая, 97', 21);
INSERT INTO stroy.address VALUES (633, 'Ольги Степановой, 41', 5);
INSERT INTO stroy.address VALUES (634, 'Варшавская, 0', 27);
INSERT INTO stroy.address VALUES (635, 'Калинникова, 11', 20);
INSERT INTO stroy.address VALUES (636, 'Ивана Шатрова, 68', 20);
INSERT INTO stroy.address VALUES (637, 'Промстроевская, 63', 8);
INSERT INTO stroy.address VALUES (638, 'Садовая-Черногрязская, 22', 27);
INSERT INTO stroy.address VALUES (639, 'Коншиных, 50', 10);
INSERT INTO stroy.address VALUES (640, '1-Я Тверская-Ямская, 82', 36);
INSERT INTO stroy.address VALUES (641, 'Усиевича, 16', 9);
INSERT INTO stroy.address VALUES (642, 'Теряевская, 19', 18);
INSERT INTO stroy.address VALUES (643, 'Щорса, 25', 42);
INSERT INTO stroy.address VALUES (644, 'Истья, 97', 17);
INSERT INTO stroy.address VALUES (645, 'Новоленинская, 72', 16);
INSERT INTO stroy.address VALUES (646, 'Рыбинская, 94', 16);
INSERT INTO stroy.address VALUES (647, 'Крылатская, 84', 16);
INSERT INTO stroy.address VALUES (648, 'Займищенская, 22', 9);
INSERT INTO stroy.address VALUES (649, 'Гаврилова, 91', 36);
INSERT INTO stroy.address VALUES (650, 'Свободы, 19', 1);
INSERT INTO stroy.address VALUES (651, 'Итальянская, 60', 44);
INSERT INTO stroy.address VALUES (652, 'Богунского Полка, 77', 37);
INSERT INTO stroy.address VALUES (653, '2-Я Рейсовая, 5', 41);
INSERT INTO stroy.address VALUES (654, 'Автодоровская, 64', 11);
INSERT INTO stroy.address VALUES (655, 'Новая Слобода, 9', 42);
INSERT INTO stroy.address VALUES (656, 'Журавлёва, 92', 32);
INSERT INTO stroy.address VALUES (657, 'Центрльная, 38', 22);
INSERT INTO stroy.address VALUES (658, 'Полянской, 28', 3);
INSERT INTO stroy.address VALUES (659, 'Академика Петровского, 61', 40);
INSERT INTO stroy.address VALUES (660, 'Гуреевская, 36', 46);
INSERT INTO stroy.address VALUES (661, 'Тарасовская, 16', 32);
INSERT INTO stroy.address VALUES (662, 'Раменская, 21', 17);
INSERT INTO stroy.address VALUES (663, 'Заброденская, 29', 1);
INSERT INTO stroy.address VALUES (664, 'Жолудева, 92', 34);
INSERT INTO stroy.address VALUES (665, 'Молдагуловой, 5', 25);
INSERT INTO stroy.address VALUES (666, '1-Я Советская, 7', 36);
INSERT INTO stroy.address VALUES (667, 'Безыменского, 73', 22);
INSERT INTO stroy.address VALUES (668, 'Сутормина, 38', 14);
INSERT INTO stroy.address VALUES (669, '40 Лет Влксм, 85', 19);
INSERT INTO stroy.address VALUES (670, 'Новая Курская, 47', 40);
INSERT INTO stroy.address VALUES (671, 'Валентины Терешковой, 89', 30);
INSERT INTO stroy.address VALUES (672, '40 Лет Влксм, 69', 43);
INSERT INTO stroy.address VALUES (673, 'Николая Старостина, 79', 4);
INSERT INTO stroy.address VALUES (674, 'Ульянова, 25', 38);
INSERT INTO stroy.address VALUES (675, 'Жданова, 25', 38);
INSERT INTO stroy.address VALUES (676, '1-Я Дубровская, 49', 20);
INSERT INTO stroy.address VALUES (677, '9-Й Гвардейской Дивизии, 6', 38);
INSERT INTO stroy.address VALUES (678, 'Соборная Гора, 86', 36);
INSERT INTO stroy.address VALUES (679, 'Новопесчаная, 11', 39);
INSERT INTO stroy.address VALUES (680, 'Татаринова, 68', 40);
INSERT INTO stroy.address VALUES (681, '14 Декабря, 48', 14);
INSERT INTO stroy.address VALUES (682, 'Бочманово, 32', 38);
INSERT INTO stroy.address VALUES (683, 'Рокоссовского, 41', 20);
INSERT INTO stroy.address VALUES (684, 'Савина, 36', 34);
INSERT INTO stroy.address VALUES (685, 'Макарьевская, 16', 47);
INSERT INTO stroy.address VALUES (686, 'Партизанская, 43', 22);
INSERT INTO stroy.address VALUES (687, 'Старокурьяновская, 49', 18);
INSERT INTO stroy.address VALUES (688, 'Угличская, 41', 38);
INSERT INTO stroy.address VALUES (689, 'Большая Садовая, 86', 31);
INSERT INTO stroy.address VALUES (690, 'Погодина, 94', 43);
INSERT INTO stroy.address VALUES (691, 'Иванцова, 63', 1);
INSERT INTO stroy.address VALUES (692, 'Пансионатовская, 57', 23);
INSERT INTO stroy.address VALUES (693, 'Горки Киовские, 64', 2);
INSERT INTO stroy.address VALUES (694, 'Димитрова, 99', 44);
INSERT INTO stroy.address VALUES (695, 'Антипова, 38', 38);
INSERT INTO stroy.address VALUES (696, '43-Й Армии, 14', 32);
INSERT INTO stroy.address VALUES (697, 'Хлебная, 35', 38);
INSERT INTO stroy.address VALUES (698, 'Уссурийская, 64', 38);
INSERT INTO stroy.address VALUES (699, 'Сергея Прокофьева, 84', 45);
INSERT INTO stroy.address VALUES (700, 'Краснянская, 66', 22);
INSERT INTO stroy.address VALUES (701, 'Пашанина, 27', 25);
INSERT INTO stroy.address VALUES (702, 'Суздальская, 60', 20);
INSERT INTO stroy.address VALUES (703, '1-Я Мишутинская, 26', 3);
INSERT INTO stroy.address VALUES (704, 'Варшавская, 20', 3);
INSERT INTO stroy.address VALUES (705, 'Щуровская, 95', 38);
INSERT INTO stroy.address VALUES (706, 'Калиновская, 41', 18);
INSERT INTO stroy.address VALUES (707, 'Волочаевская, 24', 22);
INSERT INTO stroy.address VALUES (708, 'Суджанский Шлях, 62', 39);
INSERT INTO stroy.address VALUES (709, 'Старые Ватутинки, 21', 25);
INSERT INTO stroy.address VALUES (710, '1-Я Брестская, 54', 22);
INSERT INTO stroy.address VALUES (711, 'Дорошенко, 100', 21);
INSERT INTO stroy.address VALUES (712, 'Старые Ватутинки, 92', 40);
INSERT INTO stroy.address VALUES (713, 'Фабрициуса, 81', 33);
INSERT INTO stroy.address VALUES (714, 'Завокзальная, 14', 44);
INSERT INTO stroy.address VALUES (715, 'Резиновая, 31', 43);
INSERT INTO stroy.address VALUES (716, 'Пристанционная, 38', 34);
INSERT INTO stroy.address VALUES (717, 'Телевизионная, 34', 14);
INSERT INTO stroy.address VALUES (718, '1-Я Владимирская, 25', 29);
INSERT INTO stroy.address VALUES (719, 'Ипподромная, 84', 17);
INSERT INTO stroy.address VALUES (720, 'Планетная, 55', 15);
INSERT INTO stroy.address VALUES (721, '5-Я Южная, 73', 35);
INSERT INTO stroy.address VALUES (722, 'Шестагинская, 65', 39);
INSERT INTO stroy.address VALUES (723, 'Обуховская, 87', 26);
INSERT INTO stroy.address VALUES (724, 'Таллинская, 17', 5);
INSERT INTO stroy.address VALUES (725, 'Маяковского, 29', 5);
INSERT INTO stroy.address VALUES (726, 'Кочетовой, 52', 16);
INSERT INTO stroy.address VALUES (727, 'Радищева, 12', 21);
INSERT INTO stroy.address VALUES (728, 'Оборонная, 25', 41);
INSERT INTO stroy.address VALUES (729, 'Милашенкова, 89', 33);
INSERT INTO stroy.address VALUES (730, 'Проезжая, 95', 28);
INSERT INTO stroy.address VALUES (731, 'Партизанская, 32', 15);
INSERT INTO stroy.address VALUES (732, 'Варшавская, 86', 22);
INSERT INTO stroy.address VALUES (733, 'Дыбенко, 13', 12);
INSERT INTO stroy.address VALUES (734, 'Митинская, 67', 46);
INSERT INTO stroy.address VALUES (735, 'Генерала Белова, 31', 33);
INSERT INTO stroy.address VALUES (736, 'Большие Каменщики, 83', 12);
INSERT INTO stroy.address VALUES (737, 'Ткацкая, 28', 43);
INSERT INTO stroy.address VALUES (738, 'Ивана Сутырина, 53', 9);
INSERT INTO stroy.address VALUES (739, 'Автострадная, 5', 25);
INSERT INTO stroy.address VALUES (740, 'Возрождения, 66', 22);
INSERT INTO stroy.address VALUES (741, 'Изыскателей, 92', 36);
INSERT INTO stroy.address VALUES (742, 'Троицкая, 21', 25);
INSERT INTO stroy.address VALUES (743, 'Юности, 8', 31);
INSERT INTO stroy.address VALUES (744, 'Васильевская, 11', 28);
INSERT INTO stroy.address VALUES (745, 'Ирины Рубцовой, 23', 11);
INSERT INTO stroy.address VALUES (746, 'Вялковская, 24', 20);
INSERT INTO stroy.address VALUES (747, 'Красных Зорь, 95', 42);
INSERT INTO stroy.address VALUES (748, 'Воровского, 63', 20);
INSERT INTO stroy.address VALUES (749, 'Киёвка, 5', 5);
INSERT INTO stroy.address VALUES (750, '26-Ти Бакинских Комиссаров, 70', 22);
INSERT INTO stroy.address VALUES (751, 'Осташковская, 32', 44);
INSERT INTO stroy.address VALUES (752, 'Славнова, 20', 26);
INSERT INTO stroy.address VALUES (753, 'Городской Вал, 17', 30);
INSERT INTO stroy.address VALUES (754, 'Большая Грузинская, 25', 25);
INSERT INTO stroy.address VALUES (755, 'Волковская, 41', 32);
INSERT INTO stroy.address VALUES (756, 'Мичуринская, 48', 37);
INSERT INTO stroy.address VALUES (757, '2-Я  Чапаева, 93', 28);
INSERT INTO stroy.address VALUES (758, 'Кабаново, 76', 38);
INSERT INTO stroy.address VALUES (759, 'Малая Лубянка, 48', 28);
INSERT INTO stroy.address VALUES (760, 'Рабфаковская, 50', 24);
INSERT INTO stroy.address VALUES (761, 'Хуторская, 93', 31);
INSERT INTO stroy.address VALUES (762, 'Москворечье, 81', 6);
INSERT INTO stroy.address VALUES (763, 'Богородский Вал, 69', 29);
INSERT INTO stroy.address VALUES (764, 'Стародубская, 67', 37);
INSERT INTO stroy.address VALUES (765, 'Соболева, 40', 38);
INSERT INTO stroy.address VALUES (766, '706-Го Продотряда, 58', 10);
INSERT INTO stroy.address VALUES (767, 'Дорожный Дом, 25', 38);
INSERT INTO stroy.address VALUES (768, 'Трёхгорный Вал, 5', 47);
INSERT INTO stroy.address VALUES (769, '1-Я Посадская, 17', 20);
INSERT INTO stroy.address VALUES (770, 'Трубецкая, 3', 44);
INSERT INTO stroy.address VALUES (771, 'Петровка, 53', 24);
INSERT INTO stroy.address VALUES (772, 'Ивана Сутырина, 97', 11);
INSERT INTO stroy.address VALUES (773, 'Текстильная, 58', 2);
INSERT INTO stroy.address VALUES (774, 'Харьковская, 49', 17);
INSERT INTO stroy.address VALUES (775, 'Кардашова, 75', 17);
INSERT INTO stroy.address VALUES (776, 'Карла Либкнехта, 59', 29);
INSERT INTO stroy.address VALUES (777, 'Руставели, 39', 15);
INSERT INTO stroy.address VALUES (778, 'Болотова, 85', 18);
INSERT INTO stroy.address VALUES (779, 'Маковского, 39', 16);
INSERT INTO stroy.address VALUES (780, 'Строителей, 56', 39);
INSERT INTO stroy.address VALUES (781, 'Станкостроителей, 74', 9);
INSERT INTO stroy.address VALUES (782, 'Тополёвая, 41', 3);
INSERT INTO stroy.address VALUES (783, 'Боровская, 100', 2);
INSERT INTO stroy.address VALUES (784, '2-Я Заводская, 28', 26);
INSERT INTO stroy.address VALUES (785, '1905 Года, 84', 15);
INSERT INTO stroy.address VALUES (786, 'Стрелецкий Спуск, 71', 16);
INSERT INTO stroy.address VALUES (787, 'Песчаная, 15', 4);
INSERT INTO stroy.address VALUES (788, 'Бориса Галушкина, 1', 4);
INSERT INTO stroy.address VALUES (789, 'Большая Краснофлотская, 8', 18);
INSERT INTO stroy.address VALUES (790, '1-Я Агрегатная, 69', 23);
INSERT INTO stroy.address VALUES (791, 'Новогиреевская, 81', 31);
INSERT INTO stroy.address VALUES (792, '2-Я Новошоссейная, 45', 8);
INSERT INTO stroy.address VALUES (793, 'Павла Большевикова, 80', 32);
INSERT INTO stroy.address VALUES (794, 'Волоколамская, 57', 3);
INSERT INTO stroy.address VALUES (795, '2-Я Вольская, 82', 31);
INSERT INTO stroy.address VALUES (796, 'Матросовская, 13', 11);
INSERT INTO stroy.address VALUES (797, 'Румянцева, 86', 12);
INSERT INTO stroy.address VALUES (798, 'Кимрская, 48', 22);
INSERT INTO stroy.address VALUES (799, '1-Й Конной Армии, 69', 14);
INSERT INTO stroy.address VALUES (800, 'Большая Советская, 67', 9);
INSERT INTO stroy.address VALUES (801, 'Трубецкая, 29', 38);
INSERT INTO stroy.address VALUES (802, 'Михайловка, 15', 12);
INSERT INTO stroy.address VALUES (803, 'Карла Маркса, 64', 7);
INSERT INTO stroy.address VALUES (804, 'Нижняя Слободка, 14', 2);
INSERT INTO stroy.address VALUES (805, 'Островского, 52', 43);
INSERT INTO stroy.address VALUES (806, 'Мостостроевская, 21', 17);
INSERT INTO stroy.address VALUES (807, 'Краснооктябрьская, 94', 3);
INSERT INTO stroy.address VALUES (808, 'Бориса Галушкина, 26', 8);
INSERT INTO stroy.address VALUES (809, 'Краснооктябрьская, 89', 20);
INSERT INTO stroy.address VALUES (810, 'Ладыженского, 88', 1);
INSERT INTO stroy.address VALUES (811, 'Покровская, 23', 3);
INSERT INTO stroy.address VALUES (812, 'Полянской, 44', 27);
INSERT INTO stroy.address VALUES (813, 'Поречная, 16', 27);
INSERT INTO stroy.address VALUES (814, 'Городнянского, 84', 13);
INSERT INTO stroy.address VALUES (815, 'Щербаковская, 54', 9);
INSERT INTO stroy.address VALUES (816, 'Поселковая, 66', 24);
INSERT INTO stroy.address VALUES (817, '50 Лет Ссср, 21', 31);
INSERT INTO stroy.address VALUES (818, 'Зелёная, 64', 41);
INSERT INTO stroy.address VALUES (819, 'Барклая, 14', 3);
INSERT INTO stroy.address VALUES (820, 'Машинистов, 85', 17);
INSERT INTO stroy.address VALUES (821, 'Алабушевская, 33', 10);
INSERT INTO stroy.address VALUES (822, 'Волчанская, 76', 2);
INSERT INTO stroy.address VALUES (823, 'Веретенникова, 81', 1);
INSERT INTO stroy.address VALUES (824, '2-Я Межевая, 100', 38);
INSERT INTO stroy.address VALUES (825, 'Рылеева, 86', 1);
INSERT INTO stroy.address VALUES (826, 'Шереметовка, 78', 30);
INSERT INTO stroy.address VALUES (827, 'Дмитрия Донского, 82', 44);
INSERT INTO stroy.address VALUES (828, 'Олений Вал, 60', 40);
INSERT INTO stroy.address VALUES (829, 'Ундол, 63', 22);
INSERT INTO stroy.address VALUES (830, 'Мосфильмовская, 93', 27);
INSERT INTO stroy.address VALUES (831, 'Шухова, 62', 43);
INSERT INTO stroy.address VALUES (832, 'Поляны, 5', 26);
INSERT INTO stroy.address VALUES (833, 'Люсиновская, 63', 25);
INSERT INTO stroy.address VALUES (834, 'Леволинейная, 68', 10);
INSERT INTO stroy.address VALUES (835, 'Стахановская, 91', 15);
INSERT INTO stroy.address VALUES (836, 'Инициативная, 95', 26);
INSERT INTO stroy.address VALUES (837, 'Заводская, 1', 23);
INSERT INTO stroy.address VALUES (838, '9 Мая, 23', 1);
INSERT INTO stroy.address VALUES (839, 'Дубровина, 58', 30);
INSERT INTO stroy.address VALUES (840, 'Маршала Катукова, 4', 3);
INSERT INTO stroy.address VALUES (841, 'Никитская, 0', 38);
INSERT INTO stroy.address VALUES (842, 'Малая Колхозная, 24', 42);
INSERT INTO stroy.address VALUES (843, 'Салтыковская, 41', 26);
INSERT INTO stroy.address VALUES (844, 'Раздольная, 60', 7);
INSERT INTO stroy.address VALUES (845, 'Кулакова, 88', 45);
INSERT INTO stroy.address VALUES (846, 'Дыбенко, 23', 38);
INSERT INTO stroy.address VALUES (847, 'Красная Москва, 92', 26);
INSERT INTO stroy.address VALUES (848, 'Онежская, 46', 8);
INSERT INTO stroy.address VALUES (849, 'Гаврикова, 70', 25);
INSERT INTO stroy.address VALUES (850, 'Старицкая, 4', 33);
INSERT INTO stroy.address VALUES (851, 'Голубинская, 12', 2);
INSERT INTO stroy.address VALUES (852, 'Лермонтовская, 100', 10);
INSERT INTO stroy.address VALUES (853, 'Курская, 96', 8);
INSERT INTO stroy.address VALUES (854, 'Мичурина, 39', 40);
INSERT INTO stroy.address VALUES (855, 'Орловская, 84', 39);
INSERT INTO stroy.address VALUES (856, '3-Я Пятилетка, 25', 28);
INSERT INTO stroy.address VALUES (857, '2-Я  Новосёловка, 54', 2);
INSERT INTO stroy.address VALUES (858, 'Рабфаковская, 11', 47);
INSERT INTO stroy.address VALUES (859, 'Новая Калиновка, 89', 9);
INSERT INTO stroy.address VALUES (860, 'Ялагина, 17', 2);
INSERT INTO stroy.address VALUES (861, 'Пронина, 39', 47);
INSERT INTO stroy.address VALUES (862, 'Красноветкинская, 62', 31);
INSERT INTO stroy.address VALUES (863, 'Вагжанова, 65', 12);
INSERT INTO stroy.address VALUES (864, 'Даниловский Вал, 79', 17);
INSERT INTO stroy.address VALUES (865, 'Касимовская, 78', 19);
INSERT INTO stroy.address VALUES (866, 'Сарментовой, 23', 7);
INSERT INTO stroy.address VALUES (867, 'Потылиха, 33', 23);
INSERT INTO stroy.address VALUES (868, 'Полесская, 9', 25);
INSERT INTO stroy.address VALUES (869, 'Автомобильная, 50', 7);
INSERT INTO stroy.address VALUES (870, 'Смоленский Большак, 77', 17);
INSERT INTO stroy.address VALUES (871, 'Чмутова, 96', 3);
INSERT INTO stroy.address VALUES (872, 'Астахова, 35', 45);
INSERT INTO stroy.address VALUES (873, 'Большая Смоленская, 45', 28);
INSERT INTO stroy.address VALUES (874, 'Имени Генерала Астанина, 32', 18);
INSERT INTO stroy.address VALUES (875, 'Генерала Кузнецова, 37', 14);
INSERT INTO stroy.address VALUES (876, 'Преображенский Вал, 49', 16);
INSERT INTO stroy.address VALUES (877, 'Большевистская, 87', 34);
INSERT INTO stroy.address VALUES (878, 'Леволинейная, 82', 32);
INSERT INTO stroy.address VALUES (879, 'Попова, 98', 27);
INSERT INTO stroy.address VALUES (880, 'Маршала Жукова, 74', 7);
INSERT INTO stroy.address VALUES (881, 'Шмидта, 51', 42);
INSERT INTO stroy.address VALUES (882, 'Прибрежная, 100', 3);
INSERT INTO stroy.address VALUES (883, '1 Мая, 53', 39);
INSERT INTO stroy.address VALUES (884, 'Благова, 66', 23);
INSERT INTO stroy.address VALUES (885, 'Старые Ватутинки, 89', 20);
INSERT INTO stroy.address VALUES (886, 'Полушкина Роща, 22', 36);
INSERT INTO stroy.address VALUES (887, 'Григория Соколова, 11', 41);
INSERT INTO stroy.address VALUES (888, 'Свободы, 98', 3);
INSERT INTO stroy.address VALUES (889, 'Курская, 0', 33);
INSERT INTO stroy.address VALUES (890, 'Старонагорная, 85', 43);
INSERT INTO stroy.address VALUES (891, 'Большая Спасская, 55', 19);
INSERT INTO stroy.address VALUES (892, '40 Лет Октября, 71', 41);
INSERT INTO stroy.address VALUES (893, 'Марксистская, 46', 34);
INSERT INTO stroy.address VALUES (894, 'Студёновская, 14', 15);
INSERT INTO stroy.address VALUES (895, 'Суворова, 15', 11);
INSERT INTO stroy.address VALUES (896, 'Учительская, 86', 21);
INSERT INTO stroy.address VALUES (897, 'Нижняя, 92', 22);
INSERT INTO stroy.address VALUES (898, 'Холмистая, 36', 11);
INSERT INTO stroy.address VALUES (899, 'Свободы, 97', 31);
INSERT INTO stroy.address VALUES (900, 'Лебедева, 56', 4);
INSERT INTO stroy.address VALUES (901, 'Северная Советская, 9', 31);
INSERT INTO stroy.address VALUES (902, 'Зайцева, 86', 16);
INSERT INTO stroy.address VALUES (903, 'Приборостроительная, 0', 3);
INSERT INTO stroy.address VALUES (904, 'Пески Набережные, 18', 21);
INSERT INTO stroy.address VALUES (905, 'Галкина, 28', 29);
INSERT INTO stroy.address VALUES (906, 'Пенькозаводская, 14', 43);
INSERT INTO stroy.address VALUES (907, 'Маршала Бирюзова, 74', 41);
INSERT INTO stroy.address VALUES (908, 'Автозаводская, 61', 40);
INSERT INTO stroy.address VALUES (909, 'Люсиновская, 91', 21);
INSERT INTO stroy.address VALUES (910, 'Новоалександровская, 40', 3);
INSERT INTO stroy.address VALUES (911, 'Ленина, 68', 33);
INSERT INTO stroy.address VALUES (912, '60 Лет Октября, 5', 32);
INSERT INTO stroy.address VALUES (913, 'Воейковская, 92', 41);
INSERT INTO stroy.address VALUES (914, 'Черняховского, 21', 46);
INSERT INTO stroy.address VALUES (915, 'Верхняя Луговая, 35', 31);
INSERT INTO stroy.address VALUES (916, 'Луханина, 10', 14);
INSERT INTO stroy.address VALUES (917, 'Суздальская, 99', 24);
INSERT INTO stroy.address VALUES (918, 'Речная, 57', 2);
INSERT INTO stroy.address VALUES (919, '60-Летия Октября, 67', 10);
INSERT INTO stroy.address VALUES (920, 'Дьяконова, 52', 21);
INSERT INTO stroy.address VALUES (921, 'Луначарского, 8', 16);
INSERT INTO stroy.address VALUES (922, 'Нагорная, 77', 42);
INSERT INTO stroy.address VALUES (923, 'Егорьевская, 12', 29);
INSERT INTO stroy.address VALUES (924, 'Запольная, 79', 11);
INSERT INTO stroy.address VALUES (925, 'Луганская, 32', 5);
INSERT INTO stroy.address VALUES (926, '3 Интернационала, 96', 42);
INSERT INTO stroy.address VALUES (927, 'Васильевская, 24', 28);
INSERT INTO stroy.address VALUES (928, 'Карачевская, 43', 36);
INSERT INTO stroy.address VALUES (929, 'Незымаева, 47', 30);
INSERT INTO stroy.address VALUES (930, 'Полежаева, 7', 27);
INSERT INTO stroy.address VALUES (931, 'Бориса Полевого, 76', 32);
INSERT INTO stroy.address VALUES (932, 'Высоковольтная, 49', 15);
INSERT INTO stroy.address VALUES (933, 'Тихонравова, 67', 24);
INSERT INTO stroy.address VALUES (934, 'Кузьминская, 31', 39);
INSERT INTO stroy.address VALUES (935, 'Полушкина Роща, 42', 14);
INSERT INTO stroy.address VALUES (936, 'Обуховская, 37', 10);
INSERT INTO stroy.address VALUES (937, '1-Я Минеевская, 93', 10);
INSERT INTO stroy.address VALUES (938, 'Смоленский Большак, 55', 18);
INSERT INTO stroy.address VALUES (939, 'Новаторская, 48', 23);
INSERT INTO stroy.address VALUES (940, 'Песковатская, 56', 32);
INSERT INTO stroy.address VALUES (941, 'Пятилетки, 47', 35);
INSERT INTO stroy.address VALUES (942, 'Братьев Федоровых, 5', 3);
INSERT INTO stroy.address VALUES (943, 'Заокольная, 29', 8);
INSERT INTO stroy.address VALUES (944, 'Маршала Конева, 17', 6);
INSERT INTO stroy.address VALUES (945, 'Киёвка, 36', 7);
INSERT INTO stroy.address VALUES (946, 'Выездная, 66', 27);
INSERT INTO stroy.address VALUES (947, 'Большая Спасская, 9', 44);
INSERT INTO stroy.address VALUES (948, 'Громобоя, 41', 9);
INSERT INTO stroy.address VALUES (949, 'Лесная, 69', 38);
INSERT INTO stroy.address VALUES (950, 'Солдатская, 35', 17);
INSERT INTO stroy.address VALUES (951, 'Костромская, 24', 37);
INSERT INTO stroy.address VALUES (952, 'Маршала Ерёменко, 64', 31);
INSERT INTO stroy.address VALUES (953, 'Ленинская, 62', 10);
INSERT INTO stroy.address VALUES (954, 'Ганны Шостак, 15', 33);
INSERT INTO stroy.address VALUES (955, 'Лётчика Бабушкина, 81', 29);
INSERT INTO stroy.address VALUES (956, 'Новоторжская, 35', 14);
INSERT INTO stroy.address VALUES (957, 'Гражданская, 99', 39);
INSERT INTO stroy.address VALUES (958, 'Манежная, 78', 14);
INSERT INTO stroy.address VALUES (959, 'Акри, 45', 47);
INSERT INTO stroy.address VALUES (960, '1-Е Пушкари, 71', 21);
INSERT INTO stroy.address VALUES (961, 'Садовая-Каретная, 68', 32);
INSERT INTO stroy.address VALUES (962, 'Новозыбковская, 26', 44);
INSERT INTO stroy.address VALUES (963, 'Белоусова, 61', 7);
INSERT INTO stroy.address VALUES (964, 'Радищева, 16', 33);
INSERT INTO stroy.address VALUES (965, 'Российская, 86', 24);
INSERT INTO stroy.address VALUES (966, 'Семёна Середы, 67', 18);
INSERT INTO stroy.address VALUES (967, 'Айвазовского, 21', 19);
INSERT INTO stroy.address VALUES (968, 'Городской Вал, 93', 18);
INSERT INTO stroy.address VALUES (969, 'Воронежская, 28', 5);
INSERT INTO stroy.address VALUES (970, 'Валовая, 67', 41);
INSERT INTO stroy.address VALUES (971, 'Калиновская, 7', 18);
INSERT INTO stroy.address VALUES (972, 'Михалицына, 30', 21);
INSERT INTO stroy.address VALUES (973, 'Алабушевская, 79', 35);
INSERT INTO stroy.address VALUES (974, 'Тоновка, 1', 21);
INSERT INTO stroy.address VALUES (975, 'И. Е. Стырина, 100', 45);
INSERT INTO stroy.address VALUES (976, 'Ульянова, 77', 21);
INSERT INTO stroy.address VALUES (977, 'Ново-Рогачевская, 46', 41);
INSERT INTO stroy.address VALUES (978, 'Большая Грузинская, 74', 20);
INSERT INTO stroy.address VALUES (979, 'Лютинская, 12', 15);
INSERT INTO stroy.address VALUES (980, 'Ворошилова, 56', 9);
INSERT INTO stroy.address VALUES (981, 'Южная, 88', 31);
INSERT INTO stroy.address VALUES (982, 'Красная Пресня, 52', 3);
INSERT INTO stroy.address VALUES (983, 'Найдова-Железова, 87', 43);
INSERT INTO stroy.address VALUES (984, '25 Лет Октября, 47', 12);
INSERT INTO stroy.address VALUES (985, 'Белорусская, 68', 20);
INSERT INTO stroy.address VALUES (986, 'Попутная, 65', 8);
INSERT INTO stroy.address VALUES (987, 'Валентиновская, 12', 37);
INSERT INTO stroy.address VALUES (988, 'Оборонная, 77', 27);
INSERT INTO stroy.address VALUES (989, 'Захарченко, 100', 1);
INSERT INTO stroy.address VALUES (990, 'Киквидзе, 47', 30);
INSERT INTO stroy.address VALUES (991, 'Дорожная, 22', 4);
INSERT INTO stroy.address VALUES (992, 'Программистов, 7', 32);
INSERT INTO stroy.address VALUES (993, 'Надежды, 74', 45);
INSERT INTO stroy.address VALUES (994, 'Программистов, 19', 6);
INSERT INTO stroy.address VALUES (995, 'Старобежецкая, 74', 25);
INSERT INTO stroy.address VALUES (996, 'Степана Шутова, 88', 22);
INSERT INTO stroy.address VALUES (997, 'Дмитриева; Карла Маркса, 6', 18);
INSERT INTO stroy.address VALUES (998, 'Ленинская, 71', 45);
INSERT INTO stroy.address VALUES (999, 'Добрынина, 95', 14);
INSERT INTO stroy.address VALUES (1000, 'Имени М.И. Калинина, 99', 17);
INSERT INTO stroy.address VALUES (1001, '9 Декабря, 88', 38);
INSERT INTO stroy.address VALUES (1002, 'Хавская, 1', 7);
INSERT INTO stroy.address VALUES (1003, 'Михаила Калинина, 4', 1);
INSERT INTO stroy.address VALUES (1004, 'Поляковка, 37', 9);
INSERT INTO stroy.address VALUES (1005, '70 Лет Октября, 18', 12);
INSERT INTO stroy.address VALUES (1006, 'Пронина, 97', 7);
INSERT INTO stroy.address VALUES (1007, 'Симферопольская, 37', 28);
INSERT INTO stroy.address VALUES (1008, 'Курчатова, 96', 33);
INSERT INTO stroy.address VALUES (1009, 'Энергетическая, 3', 11);
INSERT INTO stroy.address VALUES (1010, 'Новозыбковская, 27', 43);
INSERT INTO stroy.address VALUES (1011, '40 Лет Победы, 68', 5);
INSERT INTO stroy.address VALUES (1012, 'Клементьевская, 59', 24);
INSERT INTO stroy.address VALUES (1013, 'Киёвка, 31', 12);
INSERT INTO stroy.address VALUES (1014, 'Еременко, 29', 21);
INSERT INTO stroy.address VALUES (1015, 'Шмидта, 53', 26);
INSERT INTO stroy.address VALUES (1016, 'Архитектора Бутовой, 23', 37);
INSERT INTO stroy.address VALUES (1017, 'Марьинский Парк, 85', 38);
INSERT INTO stroy.address VALUES (1018, 'Красный Маяк, 27', 32);
INSERT INTO stroy.address VALUES (1019, 'Бежецкая, 36', 37);
INSERT INTO stroy.address VALUES (1020, 'Весёлая, 32', 34);
INSERT INTO stroy.address VALUES (1021, 'Водопьянова, 45', 25);
INSERT INTO stroy.address VALUES (1022, 'Декабристов, 22', 47);
INSERT INTO stroy.address VALUES (1023, 'Жолио-Кюри, 47', 1);
INSERT INTO stroy.address VALUES (1024, 'Хмелёва, 42', 45);
INSERT INTO stroy.address VALUES (1025, 'Зимёнковская, 49', 3);
INSERT INTO stroy.address VALUES (1026, 'Центральная, 13', 10);
INSERT INTO stroy.address VALUES (1027, 'Семенюка, 34', 32);
INSERT INTO stroy.address VALUES (1028, 'Рыльский Шлях, 47', 33);
INSERT INTO stroy.address VALUES (1029, 'Газина, 6', 18);
INSERT INTO stroy.address VALUES (1030, 'Чернышевского, 50', 21);
INSERT INTO stroy.address VALUES (1031, 'Кузьминская, 18', 24);
INSERT INTO stroy.address VALUES (1032, 'Авангардная, 42', 1);
INSERT INTO stroy.address VALUES (1033, 'Вознесенская, 1', 21);
INSERT INTO stroy.address VALUES (1034, 'Академическая, 76', 24);
INSERT INTO stroy.address VALUES (1035, 'Академика Флёрова, 100', 29);
INSERT INTO stroy.address VALUES (1036, 'Велозаводская, 15', 19);
INSERT INTO stroy.address VALUES (1037, 'Шоссейная, 79', 43);
INSERT INTO stroy.address VALUES (1038, 'Садовая-Каретная, 23', 4);
INSERT INTO stroy.address VALUES (1039, 'Северный Посёлок, 56', 4);
INSERT INTO stroy.address VALUES (1040, 'Старые Ватутинки, 46', 32);
INSERT INTO stroy.address VALUES (1041, 'Любимская, 1', 1);
INSERT INTO stroy.address VALUES (1042, 'Дорошенко, 77', 10);
INSERT INTO stroy.address VALUES (1043, 'Новоалександровская, 36', 27);
INSERT INTO stroy.address VALUES (1044, 'Профсоюзов, 39', 46);
INSERT INTO stroy.address VALUES (1045, 'Попутная, 68', 25);
INSERT INTO stroy.address VALUES (1046, 'Куусинена, 74', 30);
INSERT INTO stroy.address VALUES (1047, 'Сахарова, 41', 30);
INSERT INTO stroy.address VALUES (1048, 'Новоспортивная, 3', 26);
INSERT INTO stroy.address VALUES (1049, 'Красина, 62', 36);
INSERT INTO stroy.address VALUES (1050, 'Талдомская, 24', 32);
INSERT INTO stroy.address VALUES (1051, 'Волчанская, 87', 2);
INSERT INTO stroy.address VALUES (1052, 'Бориса Полевого, 53', 25);
INSERT INTO stroy.address VALUES (1053, '1-Я Посадская, 42', 5);
INSERT INTO stroy.address VALUES (1054, 'Трёхгорный Вал, 71', 15);
INSERT INTO stroy.address VALUES (1055, 'Лакина, 26', 39);
INSERT INTO stroy.address VALUES (1056, 'Фёдорова, 12', 24);
INSERT INTO stroy.address VALUES (1057, 'Уральская, 29', 12);
INSERT INTO stroy.address VALUES (1058, 'Студёновская, 9', 40);
INSERT INTO stroy.address VALUES (1059, 'Бежецкая, 65', 31);
INSERT INTO stroy.address VALUES (1060, 'Степана Шутова, 99', 15);
INSERT INTO stroy.address VALUES (1061, 'Радио, 77', 26);
INSERT INTO stroy.address VALUES (1062, '1-Я Радиальная, 86', 28);
INSERT INTO stroy.address VALUES (1063, 'Народная, 82', 4);
INSERT INTO stroy.address VALUES (1064, 'Ворошилова, 100', 37);
INSERT INTO stroy.address VALUES (1065, 'Вернова, 54', 29);
INSERT INTO stroy.address VALUES (1066, 'Шмелькова, 78', 11);
INSERT INTO stroy.address VALUES (1067, 'Малое Васильево, 91', 22);
INSERT INTO stroy.address VALUES (1068, 'Никулинская, 86', 23);
INSERT INTO stroy.address VALUES (1069, 'Пречистенка, 50', 21);
INSERT INTO stroy.address VALUES (1070, 'Маресьева, 30', 34);
INSERT INTO stroy.address VALUES (1071, 'Суздальская, 59', 8);
INSERT INTO stroy.address VALUES (1072, 'Сонина, 64', 46);
INSERT INTO stroy.address VALUES (1073, 'Игнатьевская, 20', 26);
INSERT INTO stroy.address VALUES (1074, 'Куйбышева, 88', 5);
INSERT INTO stroy.address VALUES (1075, 'Степная, 67', 44);
INSERT INTO stroy.address VALUES (1076, 'Большие Городенцы, 9', 32);
INSERT INTO stroy.address VALUES (1077, 'Большак, 35', 20);
INSERT INTO stroy.address VALUES (1078, 'Кардашова, 26', 5);
INSERT INTO stroy.address VALUES (1079, 'Севастопольская, 62', 7);
INSERT INTO stroy.address VALUES (1080, 'Талдомская, 15', 9);
INSERT INTO stroy.address VALUES (1081, 'Беломорская, 1', 20);
INSERT INTO stroy.address VALUES (1082, 'Веденеева, 9', 22);
INSERT INTO stroy.address VALUES (1083, 'Прибрежная, 29', 36);
INSERT INTO stroy.address VALUES (1084, 'Шахтная, 31', 37);
INSERT INTO stroy.address VALUES (1085, 'Большая Тульская, 49', 4);
INSERT INTO stroy.address VALUES (1086, 'Соколова, 6', 12);
INSERT INTO stroy.address VALUES (1087, '43-Й Армии, 60', 34);
INSERT INTO stroy.address VALUES (1088, 'Фокина, 11', 16);
INSERT INTO stroy.address VALUES (1089, 'Гензика, 44', 18);
INSERT INTO stroy.address VALUES (1090, 'Ивановская, 23', 4);
INSERT INTO stroy.address VALUES (1091, 'Беловежская, 25', 2);
INSERT INTO stroy.address VALUES (1092, 'Брянской Пролетарской Дивизии, 41', 38);
INSERT INTO stroy.address VALUES (1093, 'Кардашова, 92', 27);
INSERT INTO stroy.address VALUES (1094, 'Патриаршая, 66', 35);
INSERT INTO stroy.address VALUES (1095, 'Новицкого, 87', 20);
INSERT INTO stroy.address VALUES (1096, 'Старыгиной, 93', 4);
INSERT INTO stroy.address VALUES (1097, 'Рудакова, 95', 39);
INSERT INTO stroy.address VALUES (1098, 'Комиссарова, 28', 4);
INSERT INTO stroy.address VALUES (1099, 'Пушкинское Поле, 69', 40);
INSERT INTO stroy.address VALUES (1100, 'Саянская, 65', 23);
INSERT INTO stroy.address VALUES (1101, 'Преображенская, 7', 30);
INSERT INTO stroy.address VALUES (1102, 'Билибина, 68', 8);
INSERT INTO stroy.address VALUES (1103, 'Путейская, 20', 5);
INSERT INTO stroy.address VALUES (1104, 'Большая Полянка, 50', 17);
INSERT INTO stroy.address VALUES (1105, 'Боженко, 40', 8);
INSERT INTO stroy.address VALUES (1106, 'Лавицкого, 56', 43);
INSERT INTO stroy.address VALUES (1107, 'Ленинская, 20', 43);
INSERT INTO stroy.address VALUES (1108, 'Промстроевская, 57', 47);
INSERT INTO stroy.address VALUES (1109, 'Генерала Дорохова, 10', 27);
INSERT INTO stroy.address VALUES (1110, 'Тарасовская, 0', 3);
INSERT INTO stroy.address VALUES (1111, '45-Й Стрелковой Дивизии, 97', 20);
INSERT INTO stroy.address VALUES (1112, 'Больничная, 38', 10);
INSERT INTO stroy.address VALUES (1113, 'Садовая-Самотёчная, 70', 24);
INSERT INTO stroy.address VALUES (1114, 'Перфильева, 72', 39);
INSERT INTO stroy.address VALUES (1115, 'Моршанская, 76', 26);
INSERT INTO stroy.address VALUES (1116, 'Халтурина, 47', 16);
INSERT INTO stroy.address VALUES (1117, 'Волга, 21', 32);
INSERT INTO stroy.address VALUES (1118, 'Черневская, 60', 1);
INSERT INTO stroy.address VALUES (1119, 'Костромская, 61', 36);
INSERT INTO stroy.address VALUES (1120, 'Трофимова, 9', 40);
INSERT INTO stroy.address VALUES (1121, 'М.Горького, 11', 11);
INSERT INTO stroy.address VALUES (1122, 'Степана Разина, 56', 7);
INSERT INTO stroy.address VALUES (1123, 'Успенская, 87', 34);
INSERT INTO stroy.address VALUES (1124, 'Маршала Катукова, 20', 37);
INSERT INTO stroy.address VALUES (1125, 'Рябикова, 83', 25);
INSERT INTO stroy.address VALUES (1126, 'Академика Опарина, 53', 46);
INSERT INTO stroy.address VALUES (1127, 'Непиющего, 43', 12);
INSERT INTO stroy.address VALUES (1128, 'Вялковская, 44', 12);
INSERT INTO stroy.address VALUES (1129, 'Таллинская, 73', 28);
INSERT INTO stroy.address VALUES (1130, 'Крымская, 53', 20);
INSERT INTO stroy.address VALUES (1131, 'Орджоникидзе, 1', 17);
INSERT INTO stroy.address VALUES (1132, 'Университетская, 23', 42);
INSERT INTO stroy.address VALUES (1133, 'Фокинская, 40', 28);
INSERT INTO stroy.address VALUES (1134, 'Свободная, 95', 44);
INSERT INTO stroy.address VALUES (1135, 'Менделеева, 54', 31);
INSERT INTO stroy.address VALUES (1136, 'Крахмалёва, 43', 42);
INSERT INTO stroy.address VALUES (1137, 'Горбуновская, 60', 25);
INSERT INTO stroy.address VALUES (1138, 'Дзержинского, 84', 38);
INSERT INTO stroy.address VALUES (1139, 'Ромашина, 91', 34);
INSERT INTO stroy.address VALUES (1140, 'Германо, 83', 6);
INSERT INTO stroy.address VALUES (1141, 'Малая Посадская, 96', 21);
INSERT INTO stroy.address VALUES (1142, 'Неделина, 71', 12);
INSERT INTO stroy.address VALUES (1143, 'Поварская, 57', 16);
INSERT INTO stroy.address VALUES (1144, 'Маршала Василевского, 48', 22);
INSERT INTO stroy.address VALUES (1145, 'Муромская, 30', 31);
INSERT INTO stroy.address VALUES (1146, 'Волга, 65', 22);
INSERT INTO stroy.address VALUES (1147, 'Липаткина, 30', 10);
INSERT INTO stroy.address VALUES (1148, 'Симферопольская, 12', 46);
INSERT INTO stroy.address VALUES (1149, 'Попова, 0', 33);
INSERT INTO stroy.address VALUES (1150, 'Верхние Поля, 33', 18);
INSERT INTO stroy.address VALUES (1151, 'Левашова, 32', 6);
INSERT INTO stroy.address VALUES (1152, 'Самойловой, 34', 11);
INSERT INTO stroy.address VALUES (1153, 'Сталелитейная, 37', 45);
INSERT INTO stroy.address VALUES (1154, 'Благова, 63', 8);
INSERT INTO stroy.address VALUES (1155, 'Садовая-Черногрязская, 2', 14);
INSERT INTO stroy.address VALUES (1156, 'Мусы Джалиля, 90', 18);
INSERT INTO stroy.address VALUES (1157, 'Кожевников, 23', 31);
INSERT INTO stroy.address VALUES (1158, 'Берёзовая, 23', 12);
INSERT INTO stroy.address VALUES (1159, 'Новобутовская, 35', 36);
INSERT INTO stroy.address VALUES (1160, 'Растопчина, 57', 46);
INSERT INTO stroy.address VALUES (1161, 'Марии Рябининой, 30', 8);
INSERT INTO stroy.address VALUES (1162, 'Большая Смоленская, 88', 12);
INSERT INTO stroy.address VALUES (1163, 'Обуховская, 1', 17);
INSERT INTO stroy.address VALUES (1164, 'Профессиональная, 13', 36);
INSERT INTO stroy.address VALUES (1165, 'Мясникова, 15', 8);
INSERT INTO stroy.address VALUES (1166, '25 Октября, 23', 4);
INSERT INTO stroy.address VALUES (1167, 'Рождественская, 89', 20);
INSERT INTO stroy.address VALUES (1168, 'Академика Волгина, 22', 34);
INSERT INTO stroy.address VALUES (1169, 'Разина, 35', 23);
INSERT INTO stroy.address VALUES (1170, '1-Я Кожевенная, 34', 1);
INSERT INTO stroy.address VALUES (1171, '1-Я Владимирская, 6', 26);
INSERT INTO stroy.address VALUES (1172, 'Постышева, 27', 17);
INSERT INTO stroy.address VALUES (1173, 'Геологов, 56', 41);
INSERT INTO stroy.address VALUES (1174, 'Ольшанская, 20', 42);
INSERT INTO stroy.address VALUES (1175, 'Предбазарная, 80', 16);
INSERT INTO stroy.address VALUES (1176, 'Андропова, 27', 17);
INSERT INTO stroy.address VALUES (1177, 'Фурманова, 36', 21);
INSERT INTO stroy.address VALUES (1178, 'Софьи Перовской, 67', 4);
INSERT INTO stroy.address VALUES (1179, 'Сухоборская, 30', 13);
INSERT INTO stroy.address VALUES (1180, 'Тарана, 26', 25);
INSERT INTO stroy.address VALUES (1181, 'Ивантеевская Ветка, 14', 4);
INSERT INTO stroy.address VALUES (1182, 'Шевченко, 27', 1);
INSERT INTO stroy.address VALUES (1183, 'Комиссарова, 36', 27);
INSERT INTO stroy.address VALUES (1184, 'Благоева, 7', 27);
INSERT INTO stroy.address VALUES (1185, 'Новокрюковская, 31', 5);
INSERT INTO stroy.address VALUES (1186, 'Мнёвники, 66', 37);
INSERT INTO stroy.address VALUES (1187, 'Привольная, 25', 14);
INSERT INTO stroy.address VALUES (1188, 'Правды, 60', 46);
INSERT INTO stroy.address VALUES (1189, 'Добролюбова, 48', 26);
INSERT INTO stroy.address VALUES (1190, 'Маршала Бирюзова, 41', 3);
INSERT INTO stroy.address VALUES (1191, 'Валовая, 0', 16);
INSERT INTO stroy.address VALUES (1192, 'Соловцова, 60', 38);
INSERT INTO stroy.address VALUES (1193, 'Парижской Коммуны, 1', 3);
INSERT INTO stroy.address VALUES (1194, 'Белоусова, 80', 20);
INSERT INTO stroy.address VALUES (1195, 'Ново-Елатомская, 46', 11);
INSERT INTO stroy.address VALUES (1196, 'Катукова, 90', 33);
INSERT INTO stroy.address VALUES (1197, 'Береговая, 89', 24);
INSERT INTO stroy.address VALUES (1198, 'Подольских Курсантов, 67', 15);
INSERT INTO stroy.address VALUES (1199, 'Дубовская, 18', 47);
INSERT INTO stroy.address VALUES (1200, '1-Я Отрадная, 26', 41);
INSERT INTO stroy.address VALUES (1201, '25 Лет Победы, 95', 44);
INSERT INTO stroy.address VALUES (1202, 'Велижская, 64', 1);
INSERT INTO stroy.address VALUES (1203, '2-Я Инженерная, 38', 37);
INSERT INTO stroy.address VALUES (1204, 'Сарментовой, 11', 33);
INSERT INTO stroy.address VALUES (1205, 'Знаменка, 19', 33);
INSERT INTO stroy.address VALUES (1206, 'Спивака, 58', 3);
INSERT INTO stroy.address VALUES (1207, 'Карла Либкнехта, 57', 7);
INSERT INTO stroy.address VALUES (1208, 'Большая Советская, 78', 42);
INSERT INTO stroy.address VALUES (1209, 'Лукинская, 24', 39);
INSERT INTO stroy.address VALUES (1210, 'Жолудева, 83', 22);
INSERT INTO stroy.address VALUES (1211, 'Оборонная, 91', 39);
INSERT INTO stroy.address VALUES (1212, 'Гурьева, 39', 21);
INSERT INTO stroy.address VALUES (1213, 'Привокзальная, 84', 44);
INSERT INTO stroy.address VALUES (1214, 'Павловского, 53', 31);
INSERT INTO stroy.address VALUES (1215, 'Карачевская, 37', 3);
INSERT INTO stroy.address VALUES (1216, 'Куженкинское Шоссе, 7', 37);
INSERT INTO stroy.address VALUES (1217, 'Почтовая, 70', 16);
INSERT INTO stroy.address VALUES (1218, 'Арбатская, 35', 13);
INSERT INTO stroy.address VALUES (1219, 'Прудовая, 69', 44);
INSERT INTO stroy.address VALUES (1220, 'Радио, 88', 46);
INSERT INTO stroy.address VALUES (1221, '10 Августа, 47', 9);
INSERT INTO stroy.address VALUES (1222, 'Тайнинская, 24', 42);
INSERT INTO stroy.address VALUES (1223, '10 Августа, 61', 6);
INSERT INTO stroy.address VALUES (1224, 'Раменки, 32', 24);
INSERT INTO stroy.address VALUES (1225, 'Менделеева, 36', 32);
INSERT INTO stroy.address VALUES (1226, 'Монтажников, 57', 11);
INSERT INTO stroy.address VALUES (1227, '1-Я  Ленстрой, 44', 21);
INSERT INTO stroy.address VALUES (1228, 'Летниковская, 75', 25);
INSERT INTO stroy.address VALUES (1229, 'Ромашина, 100', 33);
INSERT INTO stroy.address VALUES (1230, 'Сосновая, 83', 16);
INSERT INTO stroy.address VALUES (1231, 'Куйбышева, 55', 1);
INSERT INTO stroy.address VALUES (1232, 'Переяслав-Хмельницкого, 88', 43);
INSERT INTO stroy.address VALUES (1233, 'Цветочная, 80', 33);
INSERT INTO stroy.address VALUES (1234, 'Воротынская, 62', 28);
INSERT INTO stroy.address VALUES (1235, 'Родниковская, 78', 13);
INSERT INTO stroy.address VALUES (1236, 'Шишкова, 12', 15);
INSERT INTO stroy.address VALUES (1237, 'Краснослободская, 5', 38);
INSERT INTO stroy.address VALUES (1238, 'Воинов-Интернационалистов, 1', 11);
INSERT INTO stroy.address VALUES (1239, 'Понятовская, 69', 5);
INSERT INTO stroy.address VALUES (1240, 'Парковая, 46', 40);
INSERT INTO stroy.address VALUES (1241, 'Незымаева, 38', 39);
INSERT INTO stroy.address VALUES (1242, '3-Я Пятилетка, 7', 9);
INSERT INTO stroy.address VALUES (1243, 'Веретенникова, 47', 47);
INSERT INTO stroy.address VALUES (1244, 'Льговский Шлях, 45', 36);
INSERT INTO stroy.address VALUES (1245, 'Стадионная, 72', 28);
INSERT INTO stroy.address VALUES (1246, 'Будённого, 75', 30);
INSERT INTO stroy.address VALUES (1247, 'Новая Заря, 58', 7);
INSERT INTO stroy.address VALUES (1248, 'Анненки, 90', 26);
INSERT INTO stroy.address VALUES (1249, 'Чапаева, 70', 28);
INSERT INTO stroy.address VALUES (1250, 'Дуниловская, 70', 36);
INSERT INTO stroy.address VALUES (1251, 'Текстильщиков, 50', 26);
INSERT INTO stroy.address VALUES (1252, 'Степана Шутова, 70', 6);
INSERT INTO stroy.address VALUES (1253, '800-Летия Москвы, 19', 19);
INSERT INTO stroy.address VALUES (1254, 'Городнянского, 38', 13);
INSERT INTO stroy.address VALUES (1255, 'Потылиха, 54', 4);
INSERT INTO stroy.address VALUES (1256, 'Большая Чернавская, 61', 11);
INSERT INTO stroy.address VALUES (1257, 'Больничная, 94', 7);
INSERT INTO stroy.address VALUES (1258, 'Красный Октябрь, 13', 2);
INSERT INTO stroy.address VALUES (1259, 'Титова, 6', 46);
INSERT INTO stroy.address VALUES (1260, 'Куженкинское Шоссе, 11', 5);
INSERT INTO stroy.address VALUES (1261, 'Карла Либкнехта, 1', 28);
INSERT INTO stroy.address VALUES (1262, 'Дуки, 76', 20);
INSERT INTO stroy.address VALUES (1263, 'Олонецкая, 29', 38);
INSERT INTO stroy.address VALUES (1264, 'Академика Петровского, 63', 29);
INSERT INTO stroy.address VALUES (1265, 'Лызлова, 100', 15);
INSERT INTO stroy.address VALUES (1266, 'Крахмалёва, 3', 7);
INSERT INTO stroy.address VALUES (1267, 'Бякова, 84', 35);
INSERT INTO stroy.address VALUES (1268, 'Лукашина, 86', 30);
INSERT INTO stroy.address VALUES (1269, 'Загорского, 4', 16);
INSERT INTO stroy.address VALUES (1270, 'Николоямская, 89', 4);
INSERT INTO stroy.address VALUES (1271, 'Воейковская, 76', 37);
INSERT INTO stroy.address VALUES (1272, 'Румянцева, 13', 2);
INSERT INTO stroy.address VALUES (1273, 'Раменская, 29', 17);
INSERT INTO stroy.address VALUES (1274, 'Усыскина, 31', 18);
INSERT INTO stroy.address VALUES (1275, 'Летовского Ополчения, 20', 31);
INSERT INTO stroy.address VALUES (1276, 'Николоямская, 23', 9);
INSERT INTO stroy.address VALUES (1277, 'Пушкина, 58', 1);
INSERT INTO stroy.address VALUES (1278, 'Толбухина, 56', 3);
INSERT INTO stroy.address VALUES (1279, 'Малахово, 3', 9);
INSERT INTO stroy.address VALUES (1280, 'Росинка, 57', 39);
INSERT INTO stroy.address VALUES (1281, 'Дорожная, 31', 2);
INSERT INTO stroy.address VALUES (1282, '22 Января, 51', 27);
INSERT INTO stroy.address VALUES (1283, 'Пугачёва, 11', 5);
INSERT INTO stroy.address VALUES (1284, 'Луначарского, 36', 1);
INSERT INTO stroy.address VALUES (1285, 'Арбатская, 56', 31);
INSERT INTO stroy.address VALUES (1286, 'Украинская, 37', 25);
INSERT INTO stroy.address VALUES (1287, 'Андропова, 43', 18);
INSERT INTO stroy.address VALUES (1288, 'Солянка, 30', 27);
INSERT INTO stroy.address VALUES (1289, 'Комиссара Московского, 16', 16);
INSERT INTO stroy.address VALUES (1290, 'Ивана Шатрова, 67', 35);
INSERT INTO stroy.address VALUES (1291, 'Перовской, 52', 26);
INSERT INTO stroy.address VALUES (1292, 'Зои Космодемьянской, 95', 43);
INSERT INTO stroy.address VALUES (1293, 'Ново-Белинского, 41', 32);
INSERT INTO stroy.address VALUES (1294, '1-Я Комсомольская, 62', 15);
INSERT INTO stroy.address VALUES (1295, 'Мнёвники, 28', 38);
INSERT INTO stroy.address VALUES (1296, 'Ани Гайтеровой, 59', 39);
INSERT INTO stroy.address VALUES (1297, 'Селезнёвская, 86', 45);
INSERT INTO stroy.address VALUES (1298, 'Академика Жукова, 92', 28);
INSERT INTO stroy.address VALUES (1299, 'Большая Семёновская, 69', 26);
INSERT INTO stroy.address VALUES (1300, 'Ватутина, 13', 9);
INSERT INTO stroy.address VALUES (1301, 'Пушкарная, 69', 21);
INSERT INTO stroy.address VALUES (1302, 'Желябова, 38', 16);
INSERT INTO stroy.address VALUES (1303, 'Сеченова, 84', 37);
INSERT INTO stroy.address VALUES (1304, 'Понятовская, 78', 32);
INSERT INTO stroy.address VALUES (1305, 'Академическая, 81', 6);
INSERT INTO stroy.address VALUES (1306, 'Академика Волгина, 10', 14);
INSERT INTO stroy.address VALUES (1307, 'Бронницкая, 2', 8);
INSERT INTO stroy.address VALUES (1308, 'Дыбенко, 90', 29);
INSERT INTO stroy.address VALUES (1309, 'Юрьевецкая, 97', 40);
INSERT INTO stroy.address VALUES (1310, 'Большая Тульская, 4', 18);
INSERT INTO stroy.address VALUES (1311, 'Бурова, 0', 27);
INSERT INTO stroy.address VALUES (1312, '1-Го Мая, 12', 45);
INSERT INTO stroy.address VALUES (1313, '206-Й Стрелковой Дивизии, 65', 5);
INSERT INTO stroy.address VALUES (1314, 'Вокзальная, 26', 19);
INSERT INTO stroy.address VALUES (1315, 'Ялтинская, 82', 8);
INSERT INTO stroy.address VALUES (1316, 'Академика Скрябина, 46', 15);
INSERT INTO stroy.address VALUES (1317, 'Взлётная, 76', 27);
INSERT INTO stroy.address VALUES (1318, 'Мархлевского, 96', 9);
INSERT INTO stroy.address VALUES (1319, 'Голикова, 84', 4);
INSERT INTO stroy.address VALUES (1320, 'Украинская, 23', 19);
INSERT INTO stroy.address VALUES (1321, 'Ярцевская, 16', 5);
INSERT INTO stroy.address VALUES (1322, 'Большая Краснофлотская, 19', 33);
INSERT INTO stroy.address VALUES (1323, 'Восточная, 52', 12);
INSERT INTO stroy.address VALUES (1324, 'Воротынская, 17', 16);
INSERT INTO stroy.address VALUES (1325, '50 Лет Ссср, 49', 41);
INSERT INTO stroy.address VALUES (1326, 'Семашко, 77', 43);
INSERT INTO stroy.address VALUES (1327, 'Ногинская, 91', 2);
INSERT INTO stroy.address VALUES (1328, 'Орудовская, 59', 22);
INSERT INTO stroy.address VALUES (1329, 'Шуйская, 92', 22);
INSERT INTO stroy.address VALUES (1330, 'Добросельская, 59', 24);
INSERT INTO stroy.address VALUES (1331, 'Смоленский Большак, 99', 11);
INSERT INTO stroy.address VALUES (1332, '2-Я Межевая, 96', 34);
INSERT INTO stroy.address VALUES (1333, 'Самотёчная, 20', 41);
INSERT INTO stroy.address VALUES (1334, 'Милашенкова, 66', 19);
INSERT INTO stroy.address VALUES (1335, 'Ленинградская, 39', 38);
INSERT INTO stroy.address VALUES (1336, 'Суздальская, 91', 47);
INSERT INTO stroy.address VALUES (1337, 'Мостовая, 79', 44);
INSERT INTO stroy.address VALUES (1338, 'Куйбышева, 75', 10);
INSERT INTO stroy.address VALUES (1339, 'Пантелеевская, 36', 18);
INSERT INTO stroy.address VALUES (1340, 'Попутная, 1', 2);
INSERT INTO stroy.address VALUES (1341, 'Рождественская, 42', 3);
INSERT INTO stroy.address VALUES (1342, 'Большая Октябрьская, 18', 13);
INSERT INTO stroy.address VALUES (1343, 'Шаболовка, 74', 31);
INSERT INTO stroy.address VALUES (1344, 'Академика Семёнова, 79', 33);
INSERT INTO stroy.address VALUES (1345, 'Красный Бор, 14', 47);
INSERT INTO stroy.address VALUES (1346, 'Ташкентская, 29', 31);
INSERT INTO stroy.address VALUES (1347, 'Трудовая, 65', 2);
INSERT INTO stroy.address VALUES (1348, 'Новосибирская, 49', 17);
INSERT INTO stroy.address VALUES (1349, 'Дорожная, 99', 21);
INSERT INTO stroy.address VALUES (1350, 'Калининградская, 76', 6);
INSERT INTO stroy.address VALUES (1351, 'Лесная, 98', 35);
INSERT INTO stroy.address VALUES (1352, 'Рославльская, 10', 12);
INSERT INTO stroy.address VALUES (1353, 'Плещеева, 34', 17);
INSERT INTO stroy.address VALUES (1354, 'Кетчерская, 96', 10);
INSERT INTO stroy.address VALUES (1355, 'Курятникова, 15', 27);
INSERT INTO stroy.address VALUES (1356, 'Маршала Василевского, 14', 6);
INSERT INTO stroy.address VALUES (1357, 'Стрелецкая, 87', 34);
INSERT INTO stroy.address VALUES (1358, '2-Я  Чапаева, 85', 6);
INSERT INTO stroy.address VALUES (1359, 'Лермонтова, 94', 1);
INSERT INTO stroy.address VALUES (1360, 'Молодёжная, 24', 5);
INSERT INTO stroy.address VALUES (1361, 'Космонавтов, 57', 6);
INSERT INTO stroy.address VALUES (1362, 'Подстанция, 74', 36);
INSERT INTO stroy.address VALUES (1363, 'Попова, 29', 41);
INSERT INTO stroy.address VALUES (1364, 'Совхозная Слобода, 78', 47);
INSERT INTO stroy.address VALUES (1365, 'Литвинова, 46', 27);
INSERT INTO stroy.address VALUES (1366, 'Северная, 22', 41);
INSERT INTO stroy.address VALUES (1367, 'Садовая-Триумфальная  (Дублёр), 82', 26);
INSERT INTO stroy.address VALUES (1368, 'Генерала Хлебникова, 24', 2);
INSERT INTO stroy.address VALUES (1369, 'Союзная, 53', 8);
INSERT INTO stroy.address VALUES (1370, 'Титова, 9', 22);
INSERT INTO stroy.address VALUES (1371, 'Корочанская, 10', 2);
INSERT INTO stroy.address VALUES (1372, 'Генерала Васильева, 39', 43);
INSERT INTO stroy.address VALUES (1373, 'Шестагинская, 67', 21);
INSERT INTO stroy.address VALUES (1374, 'Кольская, 62', 20);
INSERT INTO stroy.address VALUES (1375, '2-Я  Красина, 35', 22);
INSERT INTO stroy.address VALUES (1376, 'Юлиана Семёнова, 6', 23);
INSERT INTO stroy.address VALUES (1377, 'Маршала Конева, 64', 41);
INSERT INTO stroy.address VALUES (1378, 'Фёдора Смирнова, 78', 46);
INSERT INTO stroy.address VALUES (1379, 'Фокинская, 19', 46);
INSERT INTO stroy.address VALUES (1380, 'Академика Янгеля, 3', 40);
INSERT INTO stroy.address VALUES (1381, 'Ляшенко, 87', 19);
INSERT INTO stroy.address VALUES (1382, '1-Я Рейсовая, 76', 40);
INSERT INTO stroy.address VALUES (1383, 'Воровского, 14', 22);
INSERT INTO stroy.address VALUES (1384, 'Красная Пресня, 55', 20);
INSERT INTO stroy.address VALUES (1385, 'Шахтная, 75', 41);
INSERT INTO stroy.address VALUES (1386, 'Серебрякова, 18', 8);
INSERT INTO stroy.address VALUES (1387, 'Рябикова, 98', 29);
INSERT INTO stroy.address VALUES (1388, 'Пучковка, 8', 5);
INSERT INTO stroy.address VALUES (1389, 'Юрия Беленогова, 24', 37);
INSERT INTO stroy.address VALUES (1390, 'Красноказарменная, 72', 20);
INSERT INTO stroy.address VALUES (1391, 'Надежды, 35', 32);
INSERT INTO stroy.address VALUES (1392, 'Ельнинская, 50', 32);
INSERT INTO stroy.address VALUES (1393, 'Городская, 35', 46);
INSERT INTO stroy.address VALUES (1394, 'Генерала Попова, 11', 35);
INSERT INTO stroy.address VALUES (1395, 'Летниковская, 72', 2);
INSERT INTO stroy.address VALUES (1396, 'Попкова, 42', 1);
INSERT INTO stroy.address VALUES (1397, 'Обручева, 12', 17);
INSERT INTO stroy.address VALUES (1398, 'Зацепский Вал, 57', 2);
INSERT INTO stroy.address VALUES (1399, 'Садовая, 13', 26);
INSERT INTO stroy.address VALUES (1400, 'Ракитянская, 67', 45);
INSERT INTO stroy.address VALUES (1401, 'Зацепский Вал, 67', 29);
INSERT INTO stroy.address VALUES (1402, 'Глебовская, 24', 44);
INSERT INTO stroy.address VALUES (1403, 'Волхонка, 24', 1);
INSERT INTO stroy.address VALUES (1404, '2-Я Пролетарская, 85', 44);
INSERT INTO stroy.address VALUES (1405, 'Федеративная, 87', 31);
INSERT INTO stroy.address VALUES (1406, 'Бебеля, 82', 42);
INSERT INTO stroy.address VALUES (1407, 'Заборье, 7', 14);
INSERT INTO stroy.address VALUES (1408, 'Малое Васильево, 48', 11);
INSERT INTO stroy.address VALUES (1409, 'Пушкинская, 93', 5);
INSERT INTO stroy.address VALUES (1410, 'Крупской, 85', 29);
INSERT INTO stroy.address VALUES (1411, 'Усиевича, 51', 44);
INSERT INTO stroy.address VALUES (1412, 'Каракозова, 58', 15);
INSERT INTO stroy.address VALUES (1413, 'Сущёвский Вал, 18', 6);
INSERT INTO stroy.address VALUES (1414, 'Садовая-Черногрязская, 57', 40);
INSERT INTO stroy.address VALUES (1415, 'Озёрная, 74', 44);
INSERT INTO stroy.address VALUES (1416, 'Доктора Гумилевской, 90', 28);
INSERT INTO stroy.address VALUES (1417, 'Кировская, 65', 11);
INSERT INTO stroy.address VALUES (1418, 'Белинского, 86', 2);
INSERT INTO stroy.address VALUES (1419, '40 Лет Октября, 47', 35);
INSERT INTO stroy.address VALUES (1420, 'Ох Волна Революции, 54', 40);
INSERT INTO stroy.address VALUES (1421, 'Госпитальный Вал, 89', 34);
INSERT INTO stroy.address VALUES (1422, 'Муромская, 16', 13);
INSERT INTO stroy.address VALUES (1423, 'Зареченская, 10', 6);
INSERT INTO stroy.address VALUES (1424, 'Секиотовская, 77', 17);
INSERT INTO stroy.address VALUES (1425, 'Вилиса Лациса, 64', 21);
INSERT INTO stroy.address VALUES (1426, 'Клубная, 25', 1);
INSERT INTO stroy.address VALUES (1427, 'Ново-Никольская, 0', 31);
INSERT INTO stroy.address VALUES (1428, '3-Я Нарвская, 63', 38);
INSERT INTO stroy.address VALUES (1429, 'Коммуны, 90', 20);
INSERT INTO stroy.address VALUES (1430, 'Девичье Поле, 55', 10);
INSERT INTO stroy.address VALUES (1431, 'Ямская, 65', 43);
INSERT INTO stroy.address VALUES (1432, 'Энергетиков, 40', 12);
INSERT INTO stroy.address VALUES (1433, 'Клишина, 1', 3);
INSERT INTO stroy.address VALUES (1434, 'Симоновский Вал, 90', 30);
INSERT INTO stroy.address VALUES (1435, 'Большая Садовая, 40', 17);
INSERT INTO stroy.address VALUES (1436, '25 Октября, 77', 27);
INSERT INTO stroy.address VALUES (1437, 'Южно-Моравская, 33', 43);
INSERT INTO stroy.address VALUES (1438, 'Ладыженского, 41', 19);
INSERT INTO stroy.address VALUES (1439, 'Макарова, 86', 8);
INSERT INTO stroy.address VALUES (1440, 'Займищенская, 73', 21);
INSERT INTO stroy.address VALUES (1441, 'Нижняя, 38', 42);
INSERT INTO stroy.address VALUES (1442, '50 Лет Нлмк, 100', 36);
INSERT INTO stroy.address VALUES (1443, 'Беклемищева, 51', 3);
INSERT INTO stroy.address VALUES (1444, 'Кантемировская, 69', 28);
INSERT INTO stroy.address VALUES (1445, 'Весенняя, 87', 39);
INSERT INTO stroy.address VALUES (1446, 'Нахимова, 74', 44);
INSERT INTO stroy.address VALUES (1447, 'Стадионная, 81', 8);
INSERT INTO stroy.address VALUES (1448, 'Кошкина, 85', 11);
INSERT INTO stroy.address VALUES (1449, 'Сарментовой, 67', 5);
INSERT INTO stroy.address VALUES (1450, '1-Я Вокзальная, 54', 45);
INSERT INTO stroy.address VALUES (1451, 'Плеханова, 47', 38);
INSERT INTO stroy.address VALUES (1452, '5-Я Южная, 60', 15);
INSERT INTO stroy.address VALUES (1453, 'Большак, 1', 2);
INSERT INTO stroy.address VALUES (1454, 'Подазовская, 94', 10);
INSERT INTO stroy.address VALUES (1455, 'Степана Разина, 8', 12);
INSERT INTO stroy.address VALUES (1456, 'Базаева, 73', 37);
INSERT INTO stroy.address VALUES (1457, 'Саломеи Нерис, 12', 24);
INSERT INTO stroy.address VALUES (1458, 'Сутормина, 23', 30);
INSERT INTO stroy.address VALUES (1459, 'Снежная, 39', 46);
INSERT INTO stroy.address VALUES (1460, '100-Й Свирской Дивизии, 77', 42);
INSERT INTO stroy.address VALUES (1461, 'Панфёрова, 51', 15);
INSERT INTO stroy.address VALUES (1462, 'Кузнецова, 15', 31);
INSERT INTO stroy.address VALUES (1463, '206-Й Стрелковой Дивизии, 35', 6);
INSERT INTO stroy.address VALUES (1464, 'Мытная, 77', 38);
INSERT INTO stroy.address VALUES (1465, 'Дорогобужский Большак, 93', 15);
INSERT INTO stroy.address VALUES (1466, 'Грязинская, 5', 34);
INSERT INTO stroy.address VALUES (1467, '2-Я  Крупской, 34', 28);
INSERT INTO stroy.address VALUES (1468, 'Муромская, 78', 8);
INSERT INTO stroy.address VALUES (1469, 'Макарьевская, 53', 7);
INSERT INTO stroy.address VALUES (1470, '50 Лет Победы, 89', 25);
INSERT INTO stroy.address VALUES (1471, 'Лилякова, 9', 27);
INSERT INTO stroy.address VALUES (1472, 'Горбуновская, 54', 29);
INSERT INTO stroy.address VALUES (1473, 'Первомайская, 2', 18);
INSERT INTO stroy.address VALUES (1474, 'Большая Краснофлотская, 88', 5);
INSERT INTO stroy.address VALUES (1475, 'Бойцов 9-Й Дивизии, 69', 14);
INSERT INTO stroy.address VALUES (1476, 'Ульяновская, 33', 1);
INSERT INTO stroy.address VALUES (1477, 'Северная, 54', 11);
INSERT INTO stroy.address VALUES (1478, 'Николаевская, 76', 24);
INSERT INTO stroy.address VALUES (1479, 'Сторожевая, 98', 4);
INSERT INTO stroy.address VALUES (1480, 'Русаковская, 82', 42);
INSERT INTO stroy.address VALUES (1481, 'Петрова, 92', 28);
INSERT INTO stroy.address VALUES (1482, 'Курятникова, 89', 14);
INSERT INTO stroy.address VALUES (1483, 'Клубная, 54', 47);
INSERT INTO stroy.address VALUES (1484, 'Спартака, 5', 23);
INSERT INTO stroy.address VALUES (1485, 'Академика Сахарова, 24', 17);
INSERT INTO stroy.address VALUES (1486, 'Белёвская, 2', 38);
INSERT INTO stroy.address VALUES (1487, 'Большая Дорога, 68', 40);
INSERT INTO stroy.address VALUES (1488, 'Парижской Коммуны, 50', 17);
INSERT INTO stroy.address VALUES (1489, 'Нестерова, 1', 42);
INSERT INTO stroy.address VALUES (1490, 'Войстроченко А.Ф., 88', 7);
INSERT INTO stroy.address VALUES (1491, 'Губкина, 68', 4);
INSERT INTO stroy.address VALUES (1492, 'Рудничная, 58', 40);
INSERT INTO stroy.address VALUES (1493, 'Ф.Энгельса, 48', 7);
INSERT INTO stroy.address VALUES (1494, '9 Мая, 7', 27);
INSERT INTO stroy.address VALUES (1495, 'Богдановича, 33', 21);
INSERT INTO stroy.address VALUES (1496, 'Комдива Орлова, 51', 29);
INSERT INTO stroy.address VALUES (1497, 'Юрия Беленогова, 95', 1);
INSERT INTO stroy.address VALUES (1498, 'Ясеневая, 22', 2);
INSERT INTO stroy.address VALUES (1499, 'Удальцова, 13', 47);
INSERT INTO stroy.address VALUES (1500, 'Благовещенская, 79', 35);
INSERT INTO stroy.address VALUES (1501, 'Брянского Фронта, 37', 45);
INSERT INTO stroy.address VALUES (1502, 'Алмазная, 77', 33);
INSERT INTO stroy.address VALUES (1503, 'Яна Фабрициуса, 89', 18);
INSERT INTO stroy.address VALUES (1504, 'Ольховская, 55', 35);
INSERT INTO stroy.address VALUES (1505, 'Мирная, 62', 16);
INSERT INTO stroy.address VALUES (1506, 'Розы Люксембург, 13', 17);
INSERT INTO stroy.address VALUES (1507, 'Ганны Шостак, 55', 17);
INSERT INTO stroy.address VALUES (1508, 'Ольховка, 9', 32);
INSERT INTO stroy.address VALUES (1509, 'Александра Невского, 84', 38);
INSERT INTO stroy.address VALUES (1510, 'Артековская, 12', 41);
INSERT INTO stroy.address VALUES (1511, 'Мещёрская, 18', 40);
INSERT INTO stroy.address VALUES (1512, 'Соборная, 9', 38);
INSERT INTO stroy.address VALUES (1513, 'Голубкова, 85', 26);
INSERT INTO stroy.address VALUES (1514, 'Благова, 4', 15);
INSERT INTO stroy.address VALUES (1515, 'Безыменского, 62', 15);
INSERT INTO stroy.address VALUES (1516, 'Генерала Лукина, 45', 46);
INSERT INTO stroy.address VALUES (1517, '2-Я Владимирская, 56', 8);
INSERT INTO stroy.address VALUES (1518, '26-Ти Бакинских Комиссаров, 90', 22);
INSERT INTO stroy.address VALUES (1519, 'Малая Колхозная, 8', 35);
INSERT INTO stroy.address VALUES (1520, 'Красный Бор, 35', 45);
INSERT INTO stroy.address VALUES (1521, 'Черепанова, 98', 12);
INSERT INTO stroy.address VALUES (1522, 'Лебеденко, 44', 11);
INSERT INTO stroy.address VALUES (1523, 'Уссурийская, 11', 33);
INSERT INTO stroy.address VALUES (1524, 'Ерошенко, 6', 10);
INSERT INTO stroy.address VALUES (1525, 'Большая Пролетарская, 69', 44);
INSERT INTO stroy.address VALUES (1526, 'Маяковского, 11', 33);
INSERT INTO stroy.address VALUES (1527, 'Вильгельма Пика, 12', 17);
INSERT INTO stroy.address VALUES (1528, 'Малая Тульская, 15', 1);
INSERT INTO stroy.address VALUES (1529, 'Менжинского, 38, 32', 36);
INSERT INTO stroy.address VALUES (1530, 'Наволокская, 83', 1);
INSERT INTO stroy.address VALUES (1531, 'Большая Дорога, 63', 8);
INSERT INTO stroy.address VALUES (1532, 'Большая Чернавская, 27', 29);
INSERT INTO stroy.address VALUES (1533, 'Болдырева, 83', 15);
INSERT INTO stroy.address VALUES (1534, 'Возмище, 41', 14);
INSERT INTO stroy.address VALUES (1535, 'Богдана Хмельницкого, 15', 13);
INSERT INTO stroy.address VALUES (1536, 'Тихая, 22', 19);
INSERT INTO stroy.address VALUES (1537, 'Советская, 23', 29);
INSERT INTO stroy.address VALUES (1538, 'Бирюсинка, 84', 43);
INSERT INTO stroy.address VALUES (1539, 'Яшенина, 80', 36);
INSERT INTO stroy.address VALUES (1540, 'Лопатинская, 61', 22);
INSERT INTO stroy.address VALUES (1541, 'Большая Семёновская, 84', 47);
INSERT INTO stroy.address VALUES (1542, 'Госпитальный Вал, 44', 47);
INSERT INTO stroy.address VALUES (1543, 'Ватутина, 38', 42);
INSERT INTO stroy.address VALUES (1544, 'Нормандия-Неман, 68', 14);
INSERT INTO stroy.address VALUES (1545, 'Ленина, 47', 41);
INSERT INTO stroy.address VALUES (1546, 'Космонавтов, 6', 30);
INSERT INTO stroy.address VALUES (1547, '9 Января, 64', 33);
INSERT INTO stroy.address VALUES (1548, 'Автострадная, 73', 32);
INSERT INTO stroy.address VALUES (1549, 'Большая Чернавская, 41', 4);
INSERT INTO stroy.address VALUES (1550, 'Поварская, 97', 5);
INSERT INTO stroy.address VALUES (1551, 'Транзитная, 58', 29);
INSERT INTO stroy.address VALUES (1552, 'Мебельная, 75', 9);
INSERT INTO stroy.address VALUES (1553, 'Живописная, 69', 15);
INSERT INTO stroy.address VALUES (1554, 'Бородинская, 22', 42);
INSERT INTO stroy.address VALUES (1555, 'Энергетическая, 43', 4);
INSERT INTO stroy.address VALUES (1556, 'Яна Берзина, 61', 46);
INSERT INTO stroy.address VALUES (1557, '3-Я Курская, 48', 37);
INSERT INTO stroy.address VALUES (1558, 'Пресненский Вал, 92', 19);
INSERT INTO stroy.address VALUES (1559, 'Ботаническая, 31', 8);
INSERT INTO stroy.address VALUES (1560, 'Братьев Федоровых, 78', 35);
INSERT INTO stroy.address VALUES (1561, 'Будённого, 97', 23);
INSERT INTO stroy.address VALUES (1562, 'Рошаля, 4', 20);
INSERT INTO stroy.address VALUES (1563, 'Плющенко, 17', 19);
INSERT INTO stroy.address VALUES (1564, 'Достоевского, 85', 11);
INSERT INTO stroy.address VALUES (1565, 'Народного Ополчения, 53', 10);
INSERT INTO stroy.address VALUES (1566, '2-Я Новошоссейная, 67', 38);
INSERT INTO stroy.address VALUES (1567, '2-Я Магистральная, 96', 11);
INSERT INTO stroy.address VALUES (1568, 'Бебеля, 49', 39);
INSERT INTO stroy.address VALUES (1569, 'Косачёва, 91', 11);
INSERT INTO stroy.address VALUES (1570, 'Пригородная, 30', 17);
INSERT INTO stroy.address VALUES (1571, 'Петрова, 55', 13);
INSERT INTO stroy.address VALUES (1572, 'Маяковского, 7', 30);
INSERT INTO stroy.address VALUES (1573, 'Попутная, 54', 24);
INSERT INTO stroy.address VALUES (1574, 'Просторная, 29', 19);
INSERT INTO stroy.address VALUES (1575, 'Погодина, 36', 26);
INSERT INTO stroy.address VALUES (1576, 'Прудовая, 75', 37);
INSERT INTO stroy.address VALUES (1577, 'Лебеденко, 47', 18);
INSERT INTO stroy.address VALUES (1578, 'Германо, 77', 35);
INSERT INTO stroy.address VALUES (1579, 'Кузнецова, 23', 29);
INSERT INTO stroy.address VALUES (1580, '2-Я  Верхний Волок, 46', 38);
INSERT INTO stroy.address VALUES (1581, 'Ломоносова, 14', 26);
INSERT INTO stroy.address VALUES (1582, 'Песчаная, 80', 43);
INSERT INTO stroy.address VALUES (1583, 'Туристская, 76', 26);
INSERT INTO stroy.address VALUES (1584, 'Житная, 55', 19);
INSERT INTO stroy.address VALUES (1585, 'Большая Фёдоровская, 41', 33);
INSERT INTO stroy.address VALUES (1586, 'Ноябрьская, 82', 11);
INSERT INTO stroy.address VALUES (1587, 'Мареевская, 16', 40);
INSERT INTO stroy.address VALUES (1588, 'Косачёва, 84', 21);
INSERT INTO stroy.address VALUES (1589, 'Гуреевская, 7', 38);
INSERT INTO stroy.address VALUES (1590, 'Профессиональная, 80', 25);
INSERT INTO stroy.address VALUES (1591, 'Амет-Хан Султана, 62', 36);
INSERT INTO stroy.address VALUES (1592, 'Пантелеевская, 78', 1);
INSERT INTO stroy.address VALUES (1593, 'Тропинка, 78', 46);
INSERT INTO stroy.address VALUES (1594, '9-Й Гвардейской Дивизии, 32', 41);
INSERT INTO stroy.address VALUES (1595, 'Бабенко, 58', 40);
INSERT INTO stroy.address VALUES (1596, 'Фокинская, 15', 38);
INSERT INTO stroy.address VALUES (1597, 'Пароходная, 3', 30);
INSERT INTO stroy.address VALUES (1598, 'Тамбовская, 48', 44);
INSERT INTO stroy.address VALUES (1599, '1-Я Елецкая, 27', 24);
INSERT INTO stroy.address VALUES (1600, 'Богатырский Мост, 4', 14);
INSERT INTO stroy.address VALUES (1601, 'Фёдора Смирнова, 59', 29);
INSERT INTO stroy.address VALUES (1602, 'Мичуринская, 73', 9);
INSERT INTO stroy.address VALUES (1603, 'Гаршина, 37', 25);
INSERT INTO stroy.address VALUES (1604, 'Нижняя Дебря, 53', 19);
INSERT INTO stroy.address VALUES (1605, '1-Е Пушкари, 73', 42);
INSERT INTO stroy.address VALUES (1606, 'Генерала Трубникова, 69', 23);
INSERT INTO stroy.address VALUES (1607, 'Поречная, 40', 47);
INSERT INTO stroy.address VALUES (1608, 'Городянка, 53', 42);
INSERT INTO stroy.address VALUES (1609, 'Шевченко, 63', 44);
INSERT INTO stroy.address VALUES (1610, 'Соловьиная, 62', 43);
INSERT INTO stroy.address VALUES (1611, 'Урочская, 13', 13);
INSERT INTO stroy.address VALUES (1612, 'Аргуновская, 2', 1);
INSERT INTO stroy.address VALUES (1613, 'Приборостроителей, 54', 33);
INSERT INTO stroy.address VALUES (1614, '1-Й Ударной Армии, 64', 24);
INSERT INTO stroy.address VALUES (1615, 'Рощинская, 100', 39);
INSERT INTO stroy.address VALUES (1616, 'В.В.Терешковой, 80', 5);
INSERT INTO stroy.address VALUES (1617, 'Тарасова, 24', 37);
INSERT INTO stroy.address VALUES (1618, '11-Я Парковая, 75', 30);
INSERT INTO stroy.address VALUES (1619, 'Касимовская, 91', 45);
INSERT INTO stroy.address VALUES (1620, 'Носкова, 70', 44);
INSERT INTO stroy.address VALUES (1621, 'Ново-Белинского, 73', 43);
INSERT INTO stroy.address VALUES (1622, 'Главная, 29', 7);
INSERT INTO stroy.address VALUES (1623, 'Войстроченко А.Ф., 59', 23);
INSERT INTO stroy.address VALUES (1624, 'Добровольцев Урала, 90', 9);
INSERT INTO stroy.address VALUES (1625, 'Менделеева, 80', 29);
INSERT INTO stroy.address VALUES (1626, 'Гагарина, 4', 40);
INSERT INTO stroy.address VALUES (1627, 'Просвещения, 46', 15);
INSERT INTO stroy.address VALUES (1628, 'Шмелёва, 29', 25);
INSERT INTO stroy.address VALUES (1629, 'Холмистая, 87', 45);
INSERT INTO stroy.address VALUES (1630, 'Маршала Катукова, 17', 11);
INSERT INTO stroy.address VALUES (1631, 'Сталеваров, 38', 18);
INSERT INTO stroy.address VALUES (1632, 'Лукашина, 85', 10);
INSERT INTO stroy.address VALUES (1633, 'Лукашина, 8', 10);
INSERT INTO stroy.address VALUES (1634, 'Кимовская, 50', 23);
INSERT INTO stroy.address VALUES (1635, 'Смоленская, 78', 25);
INSERT INTO stroy.address VALUES (1636, 'Поэта Лебедева, 14', 5);
INSERT INTO stroy.address VALUES (1637, 'Итальянская, 80', 25);
INSERT INTO stroy.address VALUES (1638, 'Леонтия Кривенкова, 25', 14);
INSERT INTO stroy.address VALUES (1639, 'Стрелецкий Спуск, 16', 11);
INSERT INTO stroy.address VALUES (1640, '25 Лет Октября, 63', 31);
INSERT INTO stroy.address VALUES (1641, 'Автомобильная, 60', 27);
INSERT INTO stroy.address VALUES (1642, 'Чкалова, 57', 10);
INSERT INTO stroy.address VALUES (1643, 'Бахаровка, 23', 23);
INSERT INTO stroy.address VALUES (1644, 'Наседкина, 89', 34);
INSERT INTO stroy.address VALUES (1645, 'Революции, 30', 15);
INSERT INTO stroy.address VALUES (1646, 'Кольская, 55', 22);
INSERT INTO stroy.address VALUES (1647, 'Салтыковская, 9', 47);
INSERT INTO stroy.address VALUES (1648, 'Расторгуева, 82', 22);
INSERT INTO stroy.address VALUES (1649, 'Баха, 19', 11);
INSERT INTO stroy.address VALUES (1650, 'Губкина, 54', 37);
INSERT INTO stroy.address VALUES (1651, 'Чистякова, 88', 43);
INSERT INTO stroy.address VALUES (1652, 'Краснооктябрьская, 17', 2);
INSERT INTO stroy.address VALUES (1653, 'Тихвинская, 58', 30);
INSERT INTO stroy.address VALUES (1654, 'Верхняя Сыромятническая, 95', 24);
INSERT INTO stroy.address VALUES (1655, 'Баташевская, 49', 1);
INSERT INTO stroy.address VALUES (1656, '2-Я Рейсовая, 34', 37);
INSERT INTO stroy.address VALUES (1657, '2-Я Заречная, 66', 11);
INSERT INTO stroy.address VALUES (1658, 'Зеленина, 44', 4);
INSERT INTO stroy.address VALUES (1659, 'Большая Покровская, 5', 12);
INSERT INTO stroy.address VALUES (1660, 'Хамовнический Вал, 6', 44);
INSERT INTO stroy.address VALUES (1661, 'Партизанская, 94', 24);
INSERT INTO stroy.address VALUES (1662, 'Халтурина, 74', 41);
INSERT INTO stroy.address VALUES (1663, 'Уссурийская, 35', 4);
INSERT INTO stroy.address VALUES (1664, 'Волгоградская, 22', 11);
INSERT INTO stroy.address VALUES (1665, 'Рябиновая, 86', 4);
INSERT INTO stroy.address VALUES (1666, 'Арсеньевка, 92', 42);
INSERT INTO stroy.address VALUES (1667, 'Раздольная, 99', 9);
INSERT INTO stroy.address VALUES (1668, '2-Я Орловская, 9', 11);
INSERT INTO stroy.address VALUES (1669, 'Рославльская, 95', 7);
INSERT INTO stroy.address VALUES (1670, 'Новосёлки, 79', 26);
INSERT INTO stroy.address VALUES (1671, 'Вологодская, 90', 22);
INSERT INTO stroy.address VALUES (1672, 'Горняков, 65', 43);
INSERT INTO stroy.address VALUES (1673, '1-Я Станционная, 54', 40);
INSERT INTO stroy.address VALUES (1674, 'Ленинского Юбилея, 8', 21);
INSERT INTO stroy.address VALUES (1675, 'Каховского, 30', 26);
INSERT INTO stroy.address VALUES (1676, 'Озеро, 19', 33);
INSERT INTO stroy.address VALUES (1677, '1-Я Кожевенная, 81', 42);
INSERT INTO stroy.address VALUES (1678, 'Ушакова, 43', 7);
INSERT INTO stroy.address VALUES (1679, 'Алабушевская, 2', 9);
INSERT INTO stroy.address VALUES (1680, 'Терпигорева, 80', 31);
INSERT INTO stroy.address VALUES (1681, 'Грамши, 87', 29);
INSERT INTO stroy.address VALUES (1682, 'Лавицкого, 21', 37);
INSERT INTO stroy.address VALUES (1683, '1-Я Пушкинская, 82', 28);
INSERT INTO stroy.address VALUES (1684, 'Просвещения, 56', 19);
INSERT INTO stroy.address VALUES (1685, 'Можайского, 19', 17);
INSERT INTO stroy.address VALUES (1686, 'Баканова, 24', 12);
INSERT INTO stroy.address VALUES (1687, 'Моховая, 31', 18);
INSERT INTO stroy.address VALUES (1688, 'Галкина, 90', 24);
INSERT INTO stroy.address VALUES (1689, 'Бессарабова, 80', 6);
INSERT INTO stroy.address VALUES (1690, 'Рудинская, 48', 37);
INSERT INTO stroy.address VALUES (1691, 'Большая Покровская, 71', 23);
INSERT INTO stroy.address VALUES (1692, 'Механизаторов, 78', 10);
INSERT INTO stroy.address VALUES (1693, 'Новобутовская, 75', 2);
INSERT INTO stroy.address VALUES (1694, 'Жулябина, 15', 12);
INSERT INTO stroy.address VALUES (1695, 'Стрелецкий Спуск, 25', 14);
INSERT INTO stroy.address VALUES (1696, 'Краснопролетарская, 48', 23);
INSERT INTO stroy.address VALUES (1697, 'Новаторская, 96', 19);
INSERT INTO stroy.address VALUES (1698, 'Салтыкова-Щедрина, 22', 43);
INSERT INTO stroy.address VALUES (1699, 'Брусилова, 71', 24);
INSERT INTO stroy.address VALUES (1700, 'Красина, 9', 13);
INSERT INTO stroy.address VALUES (1701, 'Скотопрогонная, 30', 46);
INSERT INTO stroy.address VALUES (1702, '1-Й Конной Армии, 64', 12);
INSERT INTO stroy.address VALUES (1703, '1-Я Минеевская, 28', 46);
INSERT INTO stroy.address VALUES (1704, 'Радио, 24', 32);
INSERT INTO stroy.address VALUES (1705, 'Новоленинская, 92', 5);
INSERT INTO stroy.address VALUES (1706, 'Землячки, 62', 39);
INSERT INTO stroy.address VALUES (1707, 'Покровка, 68', 34);
INSERT INTO stroy.address VALUES (1708, 'Приборостроителей, 67', 2);
INSERT INTO stroy.address VALUES (1709, 'Большая Фурмановская, 41', 28);
INSERT INTO stroy.address VALUES (1710, 'Туристская, 62', 38);
INSERT INTO stroy.address VALUES (1711, 'Главная, 97', 28);
INSERT INTO stroy.address VALUES (1712, 'Маршала Конева, 60', 4);
INSERT INTO stroy.address VALUES (1713, 'Академика Опарина, 100', 7);
INSERT INTO stroy.address VALUES (1714, 'Барыбинская, 75', 17);
INSERT INTO stroy.address VALUES (1715, 'Константина Заслонова, 62', 44);
INSERT INTO stroy.address VALUES (1716, 'Тропинка, 12', 1);
INSERT INTO stroy.address VALUES (1717, 'Таллинская, 60', 1);
INSERT INTO stroy.address VALUES (1718, 'Вяземская, 22', 28);
INSERT INTO stroy.address VALUES (1719, 'Некрасова, 11', 34);
INSERT INTO stroy.address VALUES (1720, 'Лакина, 2', 15);
INSERT INTO stroy.address VALUES (1721, 'Германо, 69', 2);
INSERT INTO stroy.address VALUES (1722, 'Стахановская, 58', 24);
INSERT INTO stroy.address VALUES (1723, 'Фролова, 74', 24);
INSERT INTO stroy.address VALUES (1724, 'Глебовская, 39', 33);
INSERT INTO stroy.address VALUES (1725, 'Калуга-Бор, 57', 39);
INSERT INTO stroy.address VALUES (1726, 'Кимовская, 72', 33);
INSERT INTO stroy.address VALUES (1727, 'Боровское Шоссе, Шоссейная, 19', 45);
INSERT INTO stroy.address VALUES (1728, '9 Декабря, 10', 29);
INSERT INTO stroy.address VALUES (1729, 'Татаринова, 16', 1);
INSERT INTO stroy.address VALUES (1730, 'Садовая-Триумфальная, 24', 35);
INSERT INTO stroy.address VALUES (1731, 'Октября, 52', 16);
INSERT INTO stroy.address VALUES (1732, 'Бурденко, 62', 10);
INSERT INTO stroy.address VALUES (1733, 'Садовая-Самотёчная, 40', 1);
INSERT INTO stroy.address VALUES (1734, 'Бестужевых, 40', 28);
INSERT INTO stroy.address VALUES (1735, 'Михаила Заботина, 46', 5);
INSERT INTO stroy.address VALUES (1736, 'Фролова, 78', 7);
INSERT INTO stroy.address VALUES (1737, 'Малиновый Овраг, 14', 2);
INSERT INTO stroy.address VALUES (1738, 'Верхняя Радищевская, 99', 40);
INSERT INTO stroy.address VALUES (1739, 'Покрышкина, 15', 33);
INSERT INTO stroy.address VALUES (1740, 'Черняховского, 56', 38);
INSERT INTO stroy.address VALUES (1741, 'Кухмистерова, 17', 29);
INSERT INTO stroy.address VALUES (1742, 'Шпалорезка, 38', 26);
INSERT INTO stroy.address VALUES (1743, 'Котовского, 92', 40);
INSERT INTO stroy.address VALUES (1744, '2-Я Межевая, 91', 37);
INSERT INTO stroy.address VALUES (1745, 'Шереметьевская, 65', 20);
INSERT INTO stroy.address VALUES (1746, 'Пролетарская, 32', 28);
INSERT INTO stroy.address VALUES (1747, 'Ох Волна Революции, 72', 44);
INSERT INTO stroy.address VALUES (1748, 'Текстильная, 9', 8);
INSERT INTO stroy.address VALUES (1749, 'Фабричная, 63', 34);
INSERT INTO stroy.address VALUES (1750, 'Садовая-Сухаревская, 15', 42);
INSERT INTO stroy.address VALUES (1751, 'Зои И Александра Космодемьянских, 89', 10);
INSERT INTO stroy.address VALUES (1752, 'Машинистов, 6', 46);
INSERT INTO stroy.address VALUES (1753, 'Ефремова, 98', 30);
INSERT INTO stroy.address VALUES (1754, 'Торговая, 43', 46);
INSERT INTO stroy.address VALUES (1755, 'Городской Вал, 40', 17);
INSERT INTO stroy.address VALUES (1756, 'Анны Горностаевой, 36', 19);
INSERT INTO stroy.address VALUES (1757, 'Сторожевая, 49', 26);
INSERT INTO stroy.address VALUES (1758, 'Скачковская, 6', 29);
INSERT INTO stroy.address VALUES (1759, 'Дубовой Рощи, 88', 46);
INSERT INTO stroy.address VALUES (1760, '9-Го Мая, 64', 20);
INSERT INTO stroy.address VALUES (1761, 'Истья, 46', 21);
INSERT INTO stroy.address VALUES (1762, 'Балчуг, 60', 17);
INSERT INTO stroy.address VALUES (1763, '1-Я Рыбинская, 93', 22);
INSERT INTO stroy.address VALUES (1764, 'Чапаева, 53', 16);
INSERT INTO stroy.address VALUES (1765, 'Ольги Степановой, 22', 30);
INSERT INTO stroy.address VALUES (1766, 'Стародубская, 95', 18);
INSERT INTO stroy.address VALUES (1767, 'Флотская, 94', 36);
INSERT INTO stroy.address VALUES (1768, 'Октябрьская, 68', 41);
INSERT INTO stroy.address VALUES (1769, '2-Я  Машиностроения, 46', 2);
INSERT INTO stroy.address VALUES (1770, 'Тимирязева, 20', 6);
INSERT INTO stroy.address VALUES (1771, 'Головнина, 17', 9);
INSERT INTO stroy.address VALUES (1772, 'Ладыженского, 45', 15);
INSERT INTO stroy.address VALUES (1773, 'Госпитальный Вал, 23', 3);
INSERT INTO stroy.address VALUES (1774, '1-Я Мишутинская, 70', 41);
INSERT INTO stroy.address VALUES (1775, 'Байдарская, 31', 4);
INSERT INTO stroy.address VALUES (1776, 'Лётчика Бабушкина, 4', 15);
INSERT INTO stroy.address VALUES (1777, 'Малая Красноармейская, 81', 32);
INSERT INTO stroy.address VALUES (1778, 'Кудряшова, 63', 17);
INSERT INTO stroy.address VALUES (1779, 'Малахово, 83', 44);
INSERT INTO stroy.address VALUES (1780, 'Веретенникова, 49', 5);
INSERT INTO stroy.address VALUES (1781, 'Сущёвский Вал, 31', 27);
INSERT INTO stroy.address VALUES (1782, 'Яузская, 63', 29);
INSERT INTO stroy.address VALUES (1783, 'Николаева, 11', 7);
INSERT INTO stroy.address VALUES (1784, 'Хуторская, 27', 8);
INSERT INTO stroy.address VALUES (1785, 'Осипенко, 68', 24);
INSERT INTO stroy.address VALUES (1786, 'Ефремова, 54', 10);
INSERT INTO stroy.address VALUES (1787, 'Шишкова, 43', 20);
INSERT INTO stroy.address VALUES (1788, 'Шишкина, 37', 18);
INSERT INTO stroy.address VALUES (1789, 'Тесакова, 80', 10);
INSERT INTO stroy.address VALUES (1790, 'Энергетическая, 57', 47);
INSERT INTO stroy.address VALUES (1791, 'Пограничника Рыжикова, 38', 19);
INSERT INTO stroy.address VALUES (1792, 'Береговая, 48', 32);
INSERT INTO stroy.address VALUES (1793, 'Автодорожная, 81', 11);
INSERT INTO stroy.address VALUES (1794, 'Красный Маяк, 53', 23);
INSERT INTO stroy.address VALUES (1795, 'Донецкая, 63', 39);
INSERT INTO stroy.address VALUES (1796, 'Братская Площадь, 56', 18);
INSERT INTO stroy.address VALUES (1797, '1-Го Мая, 23', 3);
INSERT INTO stroy.address VALUES (1798, 'Марфы Белоглядовой, 69', 36);
INSERT INTO stroy.address VALUES (1799, 'Петрова, 86', 34);
INSERT INTO stroy.address VALUES (1800, 'Совхозная, 15', 30);
INSERT INTO stroy.address VALUES (1801, 'Октября, 2', 44);
INSERT INTO stroy.address VALUES (1802, '50 Лет Влксм, 37', 47);
INSERT INTO stroy.address VALUES (1803, 'Неглинная, 30', 16);
INSERT INTO stroy.address VALUES (1804, 'Марии Рябининой, 29', 45);
INSERT INTO stroy.address VALUES (1805, 'Кировская, 95', 29);
INSERT INTO stroy.address VALUES (1806, 'Студёновская, 55', 46);
INSERT INTO stroy.address VALUES (1807, 'Рудничная, 98', 28);
INSERT INTO stroy.address VALUES (1808, 'Кропоткина, 63', 18);
INSERT INTO stroy.address VALUES (1809, '11-Я Парковая, 98', 42);
INSERT INTO stroy.address VALUES (1810, 'Гутина, 55', 38);
INSERT INTO stroy.address VALUES (1811, '1-Я Железнодорожная, 80', 25);
INSERT INTO stroy.address VALUES (1812, 'Цюрупы, 48', 38);
INSERT INTO stroy.address VALUES (1813, '1-Я Хотьковская, 60', 22);
INSERT INTO stroy.address VALUES (1814, 'Косачёва, 47', 36);
INSERT INTO stroy.address VALUES (1815, 'Большая Семёновская, 71', 12);
INSERT INTO stroy.address VALUES (1816, 'Гладышева, 48', 14);
INSERT INTO stroy.address VALUES (1817, 'Русаковская, 5', 6);
INSERT INTO stroy.address VALUES (1818, 'Академика Белова, 15', 5);
INSERT INTO stroy.address VALUES (1819, 'Толбухина, 16', 30);
INSERT INTO stroy.address VALUES (1820, 'Щукинская, 81', 44);
INSERT INTO stroy.address VALUES (1821, 'Клементьевская, 24', 25);
INSERT INTO stroy.address VALUES (1822, 'Новопесчаная, 35', 27);
INSERT INTO stroy.address VALUES (1823, 'Никитина, 98', 29);
INSERT INTO stroy.address VALUES (1824, 'Ставропольская, 83', 4);
INSERT INTO stroy.address VALUES (1825, 'Веденеева, 86', 2);
INSERT INTO stroy.address VALUES (1826, 'Малиновый Овраг, 37', 23);
INSERT INTO stroy.address VALUES (1827, 'Дзержинская, 52', 6);
INSERT INTO stroy.address VALUES (1828, 'Марьинская, 94', 18);
INSERT INTO stroy.address VALUES (1829, 'Старицкая, 61', 24);
INSERT INTO stroy.address VALUES (1830, 'Им. Островского, 35', 37);
INSERT INTO stroy.address VALUES (1831, 'Генерала Белова, 28', 8);
INSERT INTO stroy.address VALUES (1832, 'Ямская, 66', 17);
INSERT INTO stroy.address VALUES (1833, '2-Я Пролетарская, 96', 27);
INSERT INTO stroy.address VALUES (1834, 'Михалевича, 90', 8);
INSERT INTO stroy.address VALUES (1835, 'Межевая, 85', 11);
INSERT INTO stroy.address VALUES (1836, 'Февральская, 23', 7);
INSERT INTO stroy.address VALUES (1837, 'Кардашова, 59', 13);
INSERT INTO stroy.address VALUES (1838, 'Тоновка, 82', 12);
INSERT INTO stroy.address VALUES (1839, 'Дорожная, 20', 7);
INSERT INTO stroy.address VALUES (1840, 'Нововерховенская, 21', 12);
INSERT INTO stroy.address VALUES (1841, 'Придорожная, 72', 19);
INSERT INTO stroy.address VALUES (1842, 'Генерала Калинина, 26', 28);
INSERT INTO stroy.address VALUES (1843, 'Освобождения, 1', 32);
INSERT INTO stroy.address VALUES (1844, '1-Я Советская, 57', 25);
INSERT INTO stroy.address VALUES (1845, '22-Го Съезда Кпсс, 3', 8);
INSERT INTO stroy.address VALUES (1846, 'Москворецкая, 18', 37);
INSERT INTO stroy.address VALUES (1847, 'Сельскохозяйственная, 75', 25);
INSERT INTO stroy.address VALUES (1848, 'Будённого, 74', 29);
INSERT INTO stroy.address VALUES (1849, '2-Я Вольская, 28', 25);
INSERT INTO stroy.address VALUES (1850, 'Бартеневская, 9', 28);
INSERT INTO stroy.address VALUES (1851, 'Труда, 10', 44);
INSERT INTO stroy.address VALUES (1852, 'Ивана Шатрова, 10', 12);
INSERT INTO stroy.address VALUES (1853, 'Северной Правды, 75', 27);
INSERT INTO stroy.address VALUES (1854, 'Смоленский Большак, 7', 32);
INSERT INTO stroy.address VALUES (1855, 'Еловая, 57', 30);
INSERT INTO stroy.address VALUES (1856, 'Патриаршая, 44', 26);
INSERT INTO stroy.address VALUES (1857, 'Волгоградская, 100', 16);
INSERT INTO stroy.address VALUES (1858, 'Братская Площадь, 48', 13);
INSERT INTO stroy.address VALUES (1859, 'Лётчицы Тарасовой, 92', 43);
INSERT INTO stroy.address VALUES (1860, 'Лежневская, 7', 13);
INSERT INTO stroy.address VALUES (1861, '3-Го Интернационала, 93', 4);
INSERT INTO stroy.address VALUES (1862, 'Черняховского, 74', 16);
INSERT INTO stroy.address VALUES (1863, 'Никитская, 99', 38);
INSERT INTO stroy.address VALUES (1864, 'Павлова, 74', 10);
INSERT INTO stroy.address VALUES (1865, 'Кустарная, 25', 28);
INSERT INTO stroy.address VALUES (1866, 'Лукашина, 83', 25);
INSERT INTO stroy.address VALUES (1867, '1-Я Станционная, 49', 32);
INSERT INTO stroy.address VALUES (1868, 'Большая Переяславская, 59', 45);
INSERT INTO stroy.address VALUES (1869, 'Буровая, 50', 46);
INSERT INTO stroy.address VALUES (1870, 'Долгоруковская, 12', 40);
INSERT INTO stroy.address VALUES (1871, 'Балчуг, 19', 25);
INSERT INTO stroy.address VALUES (1872, 'Стахановская, 30', 4);
INSERT INTO stroy.address VALUES (1873, 'Поречная, 81', 42);
INSERT INTO stroy.address VALUES (1874, 'Гаврикова, 2', 1);
INSERT INTO stroy.address VALUES (1875, 'Железнодорожная, 27', 9);
INSERT INTO stroy.address VALUES (1876, 'Красный Бор, 51', 34);
INSERT INTO stroy.address VALUES (1877, 'Студёновская, 77', 44);
INSERT INTO stroy.address VALUES (1878, '2-Я  За Линией Октябрьской Ж/Д, 3', 27);
INSERT INTO stroy.address VALUES (1879, 'Большая Лубянка, 70', 19);
INSERT INTO stroy.address VALUES (1880, 'Носкова, 30', 22);
INSERT INTO stroy.address VALUES (1881, 'Алексея Бутенко, 37', 43);
INSERT INTO stroy.address VALUES (1882, 'Санаторная, 44', 24);
INSERT INTO stroy.address VALUES (1883, 'Челюскинцев, 59', 31);
INSERT INTO stroy.address VALUES (1884, 'Горбуновская, 81', 8);
INSERT INTO stroy.address VALUES (1885, 'Солдатская, 6', 12);
INSERT INTO stroy.address VALUES (1886, 'Баумана, 23', 13);
INSERT INTO stroy.address VALUES (1887, 'Посадская, 11', 4);
INSERT INTO stroy.address VALUES (1888, 'Планетная, 26', 39);
INSERT INTO stroy.address VALUES (1889, 'Ильинская, 64', 35);
INSERT INTO stroy.address VALUES (1890, 'Артёмовская, 85', 24);
INSERT INTO stroy.address VALUES (1891, 'Клинский Родник, 63', 43);
INSERT INTO stroy.address VALUES (1892, 'Олений Вал, 35', 1);
INSERT INTO stroy.address VALUES (1893, 'Бежецкая, 80', 28);
INSERT INTO stroy.address VALUES (1894, 'Виноградова, 15', 3);
INSERT INTO stroy.address VALUES (1895, 'Семашко, 25', 25);
INSERT INTO stroy.address VALUES (1896, 'Кимовская, 16', 44);
INSERT INTO stroy.address VALUES (1897, 'Институтская, 13', 28);
INSERT INTO stroy.address VALUES (1898, 'Урожайная, 6', 18);
INSERT INTO stroy.address VALUES (1899, 'Ветстанция, 85', 39);
INSERT INTO stroy.address VALUES (1900, 'Коншиных, 6', 15);
INSERT INTO stroy.address VALUES (1901, 'Февральская, 53', 16);
INSERT INTO stroy.address VALUES (1902, 'Бабенко, 42', 30);
INSERT INTO stroy.address VALUES (1903, 'Еловая, 1', 19);
INSERT INTO stroy.address VALUES (1904, '2-Я Пролетарская, 81', 3);
INSERT INTO stroy.address VALUES (1905, '2-Я Брестская, 5', 19);
INSERT INTO stroy.address VALUES (1906, 'Неверовского, 72', 26);
INSERT INTO stroy.address VALUES (1907, 'Токарёвская, 40', 13);
INSERT INTO stroy.address VALUES (1908, 'Малая Красноармейская, 73', 12);
INSERT INTO stroy.address VALUES (1909, 'Тульская, 45', 22);
INSERT INTO stroy.address VALUES (1910, 'Скотопрогонная, 12', 12);
INSERT INTO stroy.address VALUES (1911, '9-Й Гвардейской Дивизии, 19', 6);
INSERT INTO stroy.address VALUES (1912, 'Обручева, 64', 45);
INSERT INTO stroy.address VALUES (1913, 'Пайтерова, 18', 15);
INSERT INTO stroy.address VALUES (1914, 'Грайвороновская, 29', 41);
INSERT INTO stroy.address VALUES (1915, 'Нариманова, 49', 23);
INSERT INTO stroy.address VALUES (1916, 'Дейнеки, 46', 20);
INSERT INTO stroy.address VALUES (1917, 'Аузина, 57', 26);
INSERT INTO stroy.address VALUES (1918, 'Измайлова, 52', 8);
INSERT INTO stroy.address VALUES (1919, 'Старомихневская, 12', 3);
INSERT INTO stroy.address VALUES (1920, 'Солянка, 28', 8);
INSERT INTO stroy.address VALUES (1921, 'Потылиха, 67', 28);
INSERT INTO stroy.address VALUES (1922, 'Калиновская, 68', 28);
INSERT INTO stroy.address VALUES (1923, 'Ким, 24', 19);
INSERT INTO stroy.address VALUES (1924, 'Девичье Поле, 20', 29);
INSERT INTO stroy.address VALUES (1925, 'Лобачевского, 67', 32);
INSERT INTO stroy.address VALUES (1926, 'Лермонтовская, 57', 37);
INSERT INTO stroy.address VALUES (1927, 'Дубовая Роща, 20', 24);
INSERT INTO stroy.address VALUES (1928, '22 Января, 75', 18);
INSERT INTO stroy.address VALUES (1929, 'Валовая, 39', 2);
INSERT INTO stroy.address VALUES (1930, 'Плотникова, 98', 22);
INSERT INTO stroy.address VALUES (1931, '1-Я Волоколамская, 24', 29);
INSERT INTO stroy.address VALUES (1932, '1-Я Кожевенная, 10', 14);
INSERT INTO stroy.address VALUES (1933, 'Салтыковская, 83', 14);
INSERT INTO stroy.address VALUES (1934, '3-Я Южная, 36', 5);
INSERT INTO stroy.address VALUES (1935, 'Пансионатовская, 24', 21);
INSERT INTO stroy.address VALUES (1936, 'Брянская, 82', 16);
INSERT INTO stroy.address VALUES (1937, 'Ломоносова, 95', 39);
INSERT INTO stroy.address VALUES (1938, 'Славнова, 47', 18);
INSERT INTO stroy.address VALUES (1939, 'Ефремова, 24', 45);
INSERT INTO stroy.address VALUES (1940, 'Ошмарина, 64', 15);
INSERT INTO stroy.address VALUES (1941, 'Матросовская, 71', 10);
INSERT INTO stroy.address VALUES (1942, 'Щуровская, 49', 45);
INSERT INTO stroy.address VALUES (1943, 'Расковой, 84', 10);
INSERT INTO stroy.address VALUES (1944, 'Дегтярёва, 79', 27);
INSERT INTO stroy.address VALUES (1945, 'Соколово-Мещерская, 43', 31);
INSERT INTO stroy.address VALUES (1946, 'Кожевников, 65', 21);
INSERT INTO stroy.address VALUES (1947, 'Фестивальная, 98', 1);
INSERT INTO stroy.address VALUES (1948, 'Незымаева, 17', 44);
INSERT INTO stroy.address VALUES (1949, 'Калининградская, 89', 25);
INSERT INTO stroy.address VALUES (1950, '1-Я Путевая, 99', 28);
INSERT INTO stroy.address VALUES (1951, '25 Лет Октября, 66', 47);
INSERT INTO stroy.address VALUES (1952, 'Лютинская, 8', 36);
INSERT INTO stroy.address VALUES (1953, 'Шереметовка, 41', 35);
INSERT INTO stroy.address VALUES (1954, 'Сонина, 92', 16);
INSERT INTO stroy.address VALUES (1955, 'Добросельская, 15', 9);
INSERT INTO stroy.address VALUES (1956, 'Ромашина, 44', 20);
INSERT INTO stroy.address VALUES (1957, 'Новая, 17', 33);
INSERT INTO stroy.address VALUES (1958, 'Арбатецкая, 89', 44);
INSERT INTO stroy.address VALUES (1959, 'Неглинная, 90', 9);
INSERT INTO stroy.address VALUES (1960, 'Ольховая, 47', 26);
INSERT INTO stroy.address VALUES (1961, 'Беломорская, 75', 3);
INSERT INTO stroy.address VALUES (1962, 'Бебеля, 62', 20);
INSERT INTO stroy.address VALUES (1963, 'Гладышева, 26', 19);
INSERT INTO stroy.address VALUES (1964, 'Загорская, 91', 33);
INSERT INTO stroy.address VALUES (1965, 'Радбужская, 12', 27);
INSERT INTO stroy.address VALUES (1966, 'Карпова, 83', 13);
INSERT INTO stroy.address VALUES (1967, 'Верейская, 94', 35);
INSERT INTO stroy.address VALUES (1968, 'Героев Панфиловцев, 42', 25);
INSERT INTO stroy.address VALUES (1969, 'Железнякова, 11', 13);
INSERT INTO stroy.address VALUES (1970, 'Головнина, 80', 31);
INSERT INTO stroy.address VALUES (1971, '1-Я Красная, 69', 18);
INSERT INTO stroy.address VALUES (1972, 'Подстанция, 99', 13);
INSERT INTO stroy.address VALUES (1973, 'Ковровская, 67', 47);
INSERT INTO stroy.address VALUES (1974, 'Костюкова, 35', 29);
INSERT INTO stroy.address VALUES (1975, 'Палехская, 51', 18);
INSERT INTO stroy.address VALUES (1976, 'Красная Горка, 22', 24);
INSERT INTO stroy.address VALUES (1977, 'Индустриальная, 90', 13);
INSERT INTO stroy.address VALUES (1978, 'Покровская, 52', 21);
INSERT INTO stroy.address VALUES (1979, 'Садовая-Самотёчная, 61', 29);
INSERT INTO stroy.address VALUES (1980, 'Разина, 75', 30);
INSERT INTO stroy.address VALUES (1981, 'Кубинка, 58', 10);
INSERT INTO stroy.address VALUES (1982, 'В.В.Терешковой, 34', 14);
INSERT INTO stroy.address VALUES (1983, 'Софийская, 98', 7);
INSERT INTO stroy.address VALUES (1984, 'Рязанская, 10', 33);
INSERT INTO stroy.address VALUES (1985, 'Судейская, 21', 35);
INSERT INTO stroy.address VALUES (1986, 'Ярцевская, 84', 17);
INSERT INTO stroy.address VALUES (1987, '1-Й Ударной Армии, 17', 28);
INSERT INTO stroy.address VALUES (1988, 'Ветстанция, 23', 13);
INSERT INTO stroy.address VALUES (1989, 'Солдатская, 10', 2);
INSERT INTO stroy.address VALUES (1990, 'Воскресенская, 100', 45);
INSERT INTO stroy.address VALUES (1991, 'Полянской, 71', 10);
INSERT INTO stroy.address VALUES (1992, '3-Я Пятилетка, 69', 31);
INSERT INTO stroy.address VALUES (1993, 'Смирнова, 41', 3);
INSERT INTO stroy.address VALUES (1994, 'Ломоносова, 76', 41);
INSERT INTO stroy.address VALUES (1995, 'Железнодорожный Городок, 98', 26);
INSERT INTO stroy.address VALUES (1996, 'Алексеевская, 53', 41);
INSERT INTO stroy.address VALUES (1997, 'Опаринская, 35', 32);
INSERT INTO stroy.address VALUES (1998, 'Старомосковская, 96', 35);
INSERT INTO stroy.address VALUES (1999, 'Ногина, 72', 5);
INSERT INTO stroy.address VALUES (2000, 'Большая Фёдоровская, 94', 1);
INSERT INTO stroy.address VALUES (2001, 'Малая Тульская, 51', 24);
INSERT INTO stroy.address VALUES (2002, 'Сергия Радонежского, 31', 8);
INSERT INTO stroy.address VALUES (2003, 'Старо-Московская, 91', 30);
INSERT INTO stroy.address VALUES (2004, 'Воротынская, 14', 46);
INSERT INTO stroy.address VALUES (2005, 'Пивзаводская, 25', 31);
INSERT INTO stroy.address VALUES (2006, 'Конструктора Гуськова, 88', 34);
INSERT INTO stroy.address VALUES (2007, 'Нижняя Масловка, 6', 18);
INSERT INTO stroy.address VALUES (2008, 'Литейная, 68', 31);
INSERT INTO stroy.address VALUES (2009, 'Чмутова, 17', 12);
INSERT INTO stroy.address VALUES (2010, 'Колхозная, 36', 39);
INSERT INTO stroy.address VALUES (2011, '5-Я Завокзальная, 58', 24);
INSERT INTO stroy.address VALUES (2012, 'Байдарская, 77', 8);
INSERT INTO stroy.address VALUES (2013, '10-Й Армии, 61', 36);
INSERT INTO stroy.address VALUES (2014, 'Большая Ордынка, 78', 8);
INSERT INTO stroy.address VALUES (2015, 'Саломеи Нерис, 99', 16);
INSERT INTO stroy.address VALUES (2016, 'Петрозаводская, 57', 30);
INSERT INTO stroy.address VALUES (2017, '9 Декабря, 8', 45);
INSERT INTO stroy.address VALUES (2018, 'Маршала Ерёменко, 37', 47);
INSERT INTO stroy.address VALUES (2019, 'Лётчика Осканова, 3', 6);
INSERT INTO stroy.address VALUES (2020, 'Тропинка, 74', 38);
INSERT INTO stroy.address VALUES (2021, 'Весёлая, 7', 5);
INSERT INTO stroy.address VALUES (2022, 'Кардовского, 35', 7);
INSERT INTO stroy.address VALUES (2023, 'Больничная, 17', 46);
INSERT INTO stroy.address VALUES (2024, 'Ольминского, 40', 1);
INSERT INTO stroy.address VALUES (2025, 'Бакунинская, 55', 12);
INSERT INTO stroy.address VALUES (2026, 'Тесакова, 51', 4);
INSERT INTO stroy.address VALUES (2027, 'Городищенская, 40', 19);
INSERT INTO stroy.address VALUES (2028, 'Еременко, 79', 43);
INSERT INTO stroy.address VALUES (2029, 'Князева, 22', 40);
INSERT INTO stroy.address VALUES (2030, 'Белгородская, 76', 1);
INSERT INTO stroy.address VALUES (2031, 'Юрьевецкая, 25', 6);
INSERT INTO stroy.address VALUES (2032, 'Обуховская, 89', 25);
INSERT INTO stroy.address VALUES (2033, 'Ильинская, 97', 6);
INSERT INTO stroy.address VALUES (2034, 'Большая-Штабская, 1', 1);
INSERT INTO stroy.address VALUES (2035, '9-Я Парковая, 44', 11);
INSERT INTO stroy.address VALUES (2036, 'Центрльная, 72', 35);
INSERT INTO stroy.address VALUES (2037, 'Матросовская, 38', 45);
INSERT INTO stroy.address VALUES (2038, 'Болдырева, 58', 28);
INSERT INTO stroy.address VALUES (2039, 'Кузнецова, 40', 44);
INSERT INTO stroy.address VALUES (2040, 'Каспийская, 36', 22);
INSERT INTO stroy.address VALUES (2041, 'Садовая-Черногрязская, 47', 14);
INSERT INTO stroy.address VALUES (2042, 'Ерошенко, 30', 17);
INSERT INTO stroy.address VALUES (2043, '14 Декабря, 72', 37);
INSERT INTO stroy.address VALUES (2044, 'Арсеньевка, 26', 28);
INSERT INTO stroy.address VALUES (2045, 'Курловская, 91', 43);
INSERT INTO stroy.address VALUES (2046, 'Кольчугинская, 56', 16);
INSERT INTO stroy.address VALUES (2047, 'Почтовая, 69', 46);
INSERT INTO stroy.address VALUES (2048, 'Ломакина, 70', 36);
INSERT INTO stroy.address VALUES (2049, 'Объездная, 31', 45);
INSERT INTO stroy.address VALUES (2050, '1-Я Совхозная, 15', 13);
INSERT INTO stroy.address VALUES (2051, '1-Я Порецкая, 65', 7);
INSERT INTO stroy.address VALUES (2052, 'Академика Сахарова, 94', 29);
INSERT INTO stroy.address VALUES (2053, 'Окская, 9', 16);
INSERT INTO stroy.address VALUES (2054, 'Кожедуба, 19', 15);
INSERT INTO stroy.address VALUES (2055, 'Губкина, 95', 24);
INSERT INTO stroy.address VALUES (2056, 'Кутузова, 0', 18);
INSERT INTO stroy.address VALUES (2057, 'Ох Волна Революции, 11', 35);
INSERT INTO stroy.address VALUES (2058, 'Генерала Васильева, 40', 6);
INSERT INTO stroy.address VALUES (2059, 'Большая Дорогомиловская, 38', 17);
INSERT INTO stroy.address VALUES (2060, 'Барышиха, 67', 46);
INSERT INTO stroy.address VALUES (2061, 'Александра Невского, 68', 35);
INSERT INTO stroy.address VALUES (2062, 'Большая Воробьёвская, 13', 41);
INSERT INTO stroy.address VALUES (2063, 'Малая Красноармейская, 45', 27);
INSERT INTO stroy.address VALUES (2064, 'Загородняя, 72', 45);
INSERT INTO stroy.address VALUES (2065, '1-Я Советская, 61', 7);
INSERT INTO stroy.address VALUES (2066, 'Пугачёва, 76', 23);
INSERT INTO stroy.address VALUES (2067, 'Стройкова, 35', 21);
INSERT INTO stroy.address VALUES (2068, 'Измайловский Вал, 6', 21);
INSERT INTO stroy.address VALUES (2069, 'Соловьиная, 18', 35);
INSERT INTO stroy.address VALUES (2070, '2-Я Парковая, 17', 37);
INSERT INTO stroy.address VALUES (2071, 'Елецкая, 90', 33);
INSERT INTO stroy.address VALUES (2072, 'Митрофанова, 65', 18);
INSERT INTO stroy.address VALUES (2073, 'Москворецкая, 95', 28);
INSERT INTO stroy.address VALUES (2074, 'Мира, 31', 13);
INSERT INTO stroy.address VALUES (2075, 'Бундурина, 72', 10);
INSERT INTO stroy.address VALUES (2076, 'Грязинская, 66', 45);
INSERT INTO stroy.address VALUES (2077, 'Петровка, 61', 29);
INSERT INTO stroy.address VALUES (2078, 'Вильнюсская, 18', 14);
INSERT INTO stroy.address VALUES (2079, 'Ковровская, 26', 3);
INSERT INTO stroy.address VALUES (2080, 'Росинка, 17', 26);
INSERT INTO stroy.address VALUES (2081, 'Плещеева, 96', 18);
INSERT INTO stroy.address VALUES (2082, 'Большая Якиманка, 14', 11);
INSERT INTO stroy.address VALUES (2083, 'Аксёнова, 7', 28);
INSERT INTO stroy.address VALUES (2084, 'Красноармейская, 21', 23);
INSERT INTO stroy.address VALUES (2085, 'Бирюсинка, 80', 46);
INSERT INTO stroy.address VALUES (2086, 'Бандикова, 85', 2);
INSERT INTO stroy.address VALUES (2087, 'Грайворонская, 9', 23);
INSERT INTO stroy.address VALUES (2088, 'Пригородная, 94', 19);
INSERT INTO stroy.address VALUES (2089, 'Твардовского, 99', 21);
INSERT INTO stroy.address VALUES (2090, 'Миклухо-Маклая, 43', 29);
INSERT INTO stroy.address VALUES (2091, '30 Лет Победы, 32', 32);
INSERT INTO stroy.address VALUES (2092, 'Яшенина, 73', 32);
INSERT INTO stroy.address VALUES (2093, '5-Я Завокзальная, 28', 18);
INSERT INTO stroy.address VALUES (2094, 'Пионерская, 38', 7);
INSERT INTO stroy.address VALUES (2095, 'Мостостроевская, 74', 21);
INSERT INTO stroy.address VALUES (2096, 'Кубинка, 79', 45);
INSERT INTO stroy.address VALUES (2097, 'Лебеденко, 1', 30);
INSERT INTO stroy.address VALUES (2098, 'Моховая, 96', 19);
INSERT INTO stroy.address VALUES (2099, 'Гоголева, 30', 20);
INSERT INTO stroy.address VALUES (2100, 'Люлина, 8', 47);
INSERT INTO stroy.address VALUES (2101, 'Северный Посёлок, 77', 31);
INSERT INTO stroy.address VALUES (2102, 'Весёлая, 8', 21);
INSERT INTO stroy.address VALUES (2103, 'Электрификации, 99', 23);
INSERT INTO stroy.address VALUES (2104, 'Барышиха, 55', 26);
INSERT INTO stroy.address VALUES (2105, 'Гранатная, 84', 41);
INSERT INTO stroy.address VALUES (2106, '1-Я Хотьковская, 70', 39);
INSERT INTO stroy.address VALUES (2107, 'Красная Печать, 87', 3);
INSERT INTO stroy.address VALUES (2108, 'Лескова, 31', 26);
INSERT INTO stroy.address VALUES (2109, 'Юрия Сергеева, 81', 20);
INSERT INTO stroy.address VALUES (2110, 'Ногина, 46', 39);
INSERT INTO stroy.address VALUES (2111, 'Серебрякова, 61', 19);
INSERT INTO stroy.address VALUES (2112, 'Долгоруковская, 51', 44);
INSERT INTO stroy.address VALUES (2113, 'Антонова-Овсеенко, 90', 17);
INSERT INTO stroy.address VALUES (2114, 'Демидовская Плотина, 85', 8);
INSERT INTO stroy.address VALUES (2115, 'Логвиненко, 29', 14);
INSERT INTO stroy.address VALUES (2116, 'Симферопольская, 22', 28);
INSERT INTO stroy.address VALUES (2117, 'Вострухина, 87', 4);
INSERT INTO stroy.address VALUES (2118, 'Сергея Эйзенштейна, 32', 19);
INSERT INTO stroy.address VALUES (2119, '10 Августа, 81', 40);
INSERT INTO stroy.address VALUES (2120, 'Подъячевская, 86', 22);
INSERT INTO stroy.address VALUES (2121, '22-Го Партсъезда, 64', 47);
INSERT INTO stroy.address VALUES (2122, 'Балковская, 60', 34);
INSERT INTO stroy.address VALUES (2123, 'Ленинского Комсомола, 1', 10);
INSERT INTO stroy.address VALUES (2124, 'Большая Ордынка, 69', 21);
INSERT INTO stroy.address VALUES (2125, 'Александры Монаховой, 83', 7);
INSERT INTO stroy.address VALUES (2126, 'Реформатского, 12', 27);
INSERT INTO stroy.address VALUES (2127, 'Киреева, 52', 38);
INSERT INTO stroy.address VALUES (2128, 'Большая Спасская, 64', 17);
INSERT INTO stroy.address VALUES (2129, '2-Я Рейсовая, 84', 44);
INSERT INTO stroy.address VALUES (2130, 'Глебовская, 46', 18);
INSERT INTO stroy.address VALUES (2131, 'Поляны, 3', 38);
INSERT INTO stroy.address VALUES (2132, 'Нагорная, 29', 3);
INSERT INTO stroy.address VALUES (2133, 'Железнодорожная, 13', 24);
INSERT INTO stroy.address VALUES (2134, 'Нелидова, 59', 20);
INSERT INTO stroy.address VALUES (2135, '40 Лет Октября, 39', 17);
INSERT INTO stroy.address VALUES (2136, 'Перовская, 69', 21);
INSERT INTO stroy.address VALUES (2137, 'Юбилейная, 98', 31);
INSERT INTO stroy.address VALUES (2138, 'Локомотивная, 11', 43);
INSERT INTO stroy.address VALUES (2139, 'Махалина, 62', 38);
INSERT INTO stroy.address VALUES (2140, 'Богунского Полка, 88', 2);
INSERT INTO stroy.address VALUES (2141, 'Воскресенская, 9', 31);
INSERT INTO stroy.address VALUES (2142, '2-Я Новошоссейная, 58', 22);
INSERT INTO stroy.address VALUES (2143, 'Боженко, 81', 16);
INSERT INTO stroy.address VALUES (2144, 'Серова, 83', 19);
INSERT INTO stroy.address VALUES (2145, 'Зарецкая, 13', 36);
INSERT INTO stroy.address VALUES (2146, 'Мясницкая, 11', 28);
INSERT INTO stroy.address VALUES (2147, 'Пантелеевская, 24', 10);
INSERT INTO stroy.address VALUES (2148, 'Липаткина, 94', 6);
INSERT INTO stroy.address VALUES (2149, 'Архитектора Власова, 19', 40);
INSERT INTO stroy.address VALUES (2150, 'Клинский Родник, 5', 35);
INSERT INTO stroy.address VALUES (2151, 'Электрификации, 39', 13);
INSERT INTO stroy.address VALUES (2152, 'Киреева, 67', 39);
INSERT INTO stroy.address VALUES (2153, '43-Й Армии, 5', 20);
INSERT INTO stroy.address VALUES (2154, 'Вертолётчиков, 29', 38);
INSERT INTO stroy.address VALUES (2155, 'Нагорная, 83', 18);
INSERT INTO stroy.address VALUES (2156, 'Адмирала Корнилова, 68', 28);
INSERT INTO stroy.address VALUES (2157, 'Новая Калиновка, 94', 5);
INSERT INTO stroy.address VALUES (2158, 'Осенняя, 41', 27);
INSERT INTO stroy.address VALUES (2159, 'Софьи Перовской, 87', 45);
INSERT INTO stroy.address VALUES (2160, 'Кочетовой, 90', 15);
INSERT INTO stroy.address VALUES (2161, 'Юлиана Семёнова, 51', 1);
INSERT INTO stroy.address VALUES (2162, 'Саввинская, 12', 3);
INSERT INTO stroy.address VALUES (2163, '1-Я Пушкарная, 81', 15);
INSERT INTO stroy.address VALUES (2164, 'Жданова, 20', 28);
INSERT INTO stroy.address VALUES (2165, 'Селижаровская, 45', 27);
INSERT INTO stroy.address VALUES (2166, 'Жуковского, 94', 15);
INSERT INTO stroy.address VALUES (2167, 'Дорожная, 2', 5);
INSERT INTO stroy.address VALUES (2168, 'Литейная, 21', 6);
INSERT INTO stroy.address VALUES (2169, '25 Октября, 67', 28);
INSERT INTO stroy.address VALUES (2170, 'Оранжерейная, 2', 25);
INSERT INTO stroy.address VALUES (2171, 'Троицкая, 22', 39);
INSERT INTO stroy.address VALUES (2172, 'Академика Сахарова, 4', 1);
INSERT INTO stroy.address VALUES (2173, 'Блинова, 28', 2);
INSERT INTO stroy.address VALUES (2174, 'Нефёдова, 23', 14);
INSERT INTO stroy.address VALUES (2175, 'Вавилова, 62', 47);
INSERT INTO stroy.address VALUES (2176, 'Бусловского, 24', 13);
INSERT INTO stroy.address VALUES (2177, 'Автострадная, 15', 6);
INSERT INTO stroy.address VALUES (2178, 'Генерала Родина, 80', 25);
INSERT INTO stroy.address VALUES (2179, 'Ильи Хегая, 58', 15);
INSERT INTO stroy.address VALUES (2180, 'Зегеля, 51', 21);
INSERT INTO stroy.address VALUES (2181, 'Коваленко, 5', 25);
INSERT INTO stroy.address VALUES (2182, 'Вятская, 82', 8);
INSERT INTO stroy.address VALUES (2183, 'Самотёчная, 48', 5);
INSERT INTO stroy.address VALUES (2184, 'Беговая, 61', 28);
INSERT INTO stroy.address VALUES (2185, 'Шацкая, 18', 40);
INSERT INTO stroy.address VALUES (2186, 'Гурьянова, 26', 22);
INSERT INTO stroy.address VALUES (2187, 'Новоспортивная, 2', 38);
INSERT INTO stroy.address VALUES (2188, 'Реформатского, 38', 35);
INSERT INTO stroy.address VALUES (2189, 'Судейская, 73', 35);
INSERT INTO stroy.address VALUES (2190, 'Изыскателей, 2', 7);
INSERT INTO stroy.address VALUES (2191, 'Новослободская, 17', 8);
INSERT INTO stroy.address VALUES (2192, 'Микрорайон, 65', 44);
INSERT INTO stroy.address VALUES (2193, '1-Я Железнодорожная, 49', 32);
INSERT INTO stroy.address VALUES (2194, '50 Лет Октября, 48', 37);
INSERT INTO stroy.address VALUES (2195, 'Станционная, 3', 32);
INSERT INTO stroy.address VALUES (2196, 'Лакина, 92', 24);
INSERT INTO stroy.address VALUES (2197, '3-Я Межевая, 49', 37);
INSERT INTO stroy.address VALUES (2198, 'Новосёлки-Слободка, 4', 47);
INSERT INTO stroy.address VALUES (2199, 'Иванцова, 58', 23);
INSERT INTO stroy.address VALUES (2200, 'Старые Кремёнки, 29', 26);
INSERT INTO stroy.address VALUES (2201, 'Пятницкая, 89', 22);
INSERT INTO stroy.address VALUES (2202, 'Сарментовой, 63', 46);
INSERT INTO stroy.address VALUES (2203, 'Веретенникова, 77', 31);
INSERT INTO stroy.address VALUES (2204, 'Добросельская, 93', 2);
INSERT INTO stroy.address VALUES (2205, 'Маресьева, 59', 17);
INSERT INTO stroy.address VALUES (2206, 'Поэта Лебедева, 15', 46);
INSERT INTO stroy.address VALUES (2207, 'Мирная, 96', 38);
INSERT INTO stroy.address VALUES (2208, 'Можайского, 9', 20);
INSERT INTO stroy.address VALUES (2209, 'Перфильева, 4', 37);
INSERT INTO stroy.address VALUES (2210, 'Складочная, 67', 19);
INSERT INTO stroy.address VALUES (2211, 'Стадионная, 64', 11);
INSERT INTO stroy.address VALUES (2212, 'Электрофикации, 98', 21);
INSERT INTO stroy.address VALUES (2213, 'Сельскохозяйственная, 15', 9);
INSERT INTO stroy.address VALUES (2214, 'Газина, 20', 31);
INSERT INTO stroy.address VALUES (2215, 'Смоленский Большак, 94', 44);
INSERT INTO stroy.address VALUES (2216, 'Леснорядская, 56', 24);
INSERT INTO stroy.address VALUES (2217, 'Вологодская, 96', 28);
INSERT INTO stroy.address VALUES (2218, 'Михайловка, 18', 8);
INSERT INTO stroy.address VALUES (2219, 'Арбатская, 27', 47);
INSERT INTO stroy.address VALUES (2220, 'Леонтия Кривенкова, 27', 17);
INSERT INTO stroy.address VALUES (2221, 'Касимовская, 9', 30);
INSERT INTO stroy.address VALUES (2222, 'Чкалова, 22', 33);
INSERT INTO stroy.address VALUES (2223, 'Новопесчаная, 79', 11);
INSERT INTO stroy.address VALUES (2224, 'Новоспортивная, 27', 40);
INSERT INTO stroy.address VALUES (2225, '1-Я Рабочая, 59', 6);
INSERT INTO stroy.address VALUES (2226, 'Псковская, 99', 1);
INSERT INTO stroy.address VALUES (2227, 'Краснянская, 73', 26);
INSERT INTO stroy.address VALUES (2228, 'Союзная, 73', 36);
INSERT INTO stroy.address VALUES (2229, '3-Я Пятилетка, 27', 24);
INSERT INTO stroy.address VALUES (2230, 'Курловская, 28', 39);
INSERT INTO stroy.address VALUES (2231, 'Есенина, 7', 16);
INSERT INTO stroy.address VALUES (2232, 'Тевосяна, 83', 4);
INSERT INTO stroy.address VALUES (2233, 'Грязинская, 95', 37);
INSERT INTO stroy.address VALUES (2234, 'Полушкина Роща, 61', 14);
INSERT INTO stroy.address VALUES (2235, 'Зиновьева, 91', 12);
INSERT INTO stroy.address VALUES (2236, 'Меленковская, 88', 31);
INSERT INTO stroy.address VALUES (2237, '1-Я Рейсовая, 21', 9);
INSERT INTO stroy.address VALUES (2238, 'Кузьминская, 50', 10);
INSERT INTO stroy.address VALUES (2239, 'Лызлова, 39', 23);
INSERT INTO stroy.address VALUES (2240, '25 Лет Победы, 21', 13);
INSERT INTO stroy.address VALUES (2241, 'Салтыкова-Щедрина, 85', 6);
INSERT INTO stroy.address VALUES (2242, '2-Я Орловская, 39', 25);
INSERT INTO stroy.address VALUES (2243, 'Большая, 2', 25);
INSERT INTO stroy.address VALUES (2244, 'Генерала Лизюкова, 93', 7);
INSERT INTO stroy.address VALUES (2245, 'Коммунарная, 61', 40);
INSERT INTO stroy.address VALUES (2246, 'Коренная, 84', 29);
INSERT INTO stroy.address VALUES (2247, 'Панфилова, 94', 16);
INSERT INTO stroy.address VALUES (2248, '2-Я Межевая, 38', 20);
INSERT INTO stroy.address VALUES (2249, 'Шпалорезка, 8', 34);
INSERT INTO stroy.address VALUES (2250, 'Токарёвская, 55', 5);
INSERT INTO stroy.address VALUES (2251, 'Соболева, 60', 1);
INSERT INTO stroy.address VALUES (2252, 'Лазарева, 24', 42);
INSERT INTO stroy.address VALUES (2253, 'Васильевская, 80', 47);
INSERT INTO stroy.address VALUES (2254, 'Крылатская, 87', 11);
INSERT INTO stroy.address VALUES (2255, '1-Я Вокзальная, 93', 27);
INSERT INTO stroy.address VALUES (2256, 'Кузнечная, 80', 7);
INSERT INTO stroy.address VALUES (2257, 'Будёновская, 2', 46);
INSERT INTO stroy.address VALUES (2258, 'Жилая, 72', 36);
INSERT INTO stroy.address VALUES (2259, 'Зои Космодемьянской, 31', 26);
INSERT INTO stroy.address VALUES (2260, 'Егорьевская, 47', 40);
INSERT INTO stroy.address VALUES (2261, 'Жилая, 29', 21);
INSERT INTO stroy.address VALUES (2262, 'Большая Ордынка, 34', 6);
INSERT INTO stroy.address VALUES (2263, 'Флотская, 0', 43);
INSERT INTO stroy.address VALUES (2264, '3-Го Интернационала, 16', 21);
INSERT INTO stroy.address VALUES (2265, 'Нелидова, 43', 36);
INSERT INTO stroy.address VALUES (2266, '9 Мая, 60', 4);
INSERT INTO stroy.address VALUES (2267, 'Тамбовская, 21', 2);
INSERT INTO stroy.address VALUES (2268, '1-Я  Мира, 36', 9);
INSERT INTO stroy.address VALUES (2269, 'Кузьмина, 85', 40);
INSERT INTO stroy.address VALUES (2270, 'Валентиновская, 81', 9);
INSERT INTO stroy.address VALUES (2271, 'Усыскина, 78', 39);
INSERT INTO stroy.address VALUES (2272, 'Кожевническая, 25', 9);
INSERT INTO stroy.address VALUES (2273, 'Болдина, 28', 3);
INSERT INTO stroy.address VALUES (2274, 'Добросельская, 63', 45);
INSERT INTO stroy.address VALUES (2275, 'Кочетовой, 30', 24);
INSERT INTO stroy.address VALUES (2276, 'Курская, 10', 5);
INSERT INTO stroy.address VALUES (2277, 'Севская, 60', 2);
INSERT INTO stroy.address VALUES (2278, 'Звёздная, 0', 8);
INSERT INTO stroy.address VALUES (2279, 'Шоссейная, 72', 40);
INSERT INTO stroy.address VALUES (2280, 'Большая Пролетарская, 51', 41);
INSERT INTO stroy.address VALUES (2281, 'Докукина, 2', 11);
INSERT INTO stroy.address VALUES (2282, 'Программистов, 9', 46);
INSERT INTO stroy.address VALUES (2283, 'Большевик, 86', 20);
INSERT INTO stroy.address VALUES (2284, 'Октябрьская Площадь, 4', 37);
INSERT INTO stroy.address VALUES (2285, 'Полка Нормандия-Неман, 4', 41);
INSERT INTO stroy.address VALUES (2286, 'Тарасова, 62', 12);
INSERT INTO stroy.address VALUES (2287, 'Панина, 55', 17);
INSERT INTO stroy.address VALUES (2288, '2-Я Глуховская, 54', 26);
INSERT INTO stroy.address VALUES (2289, 'Зареченская, 6', 41);
INSERT INTO stroy.address VALUES (2290, 'Уральская, 44', 41);
INSERT INTO stroy.address VALUES (2291, 'Боженко, 2', 35);
INSERT INTO stroy.address VALUES (2292, 'Боровская, 30', 41);
INSERT INTO stroy.address VALUES (2293, 'Большая Тульская, 42', 2);
INSERT INTO stroy.address VALUES (2294, 'Большие Городенцы, 14', 1);
INSERT INTO stroy.address VALUES (2295, 'Лежневская, 39', 42);
INSERT INTO stroy.address VALUES (2296, 'Лясоцкого, 4', 12);
INSERT INTO stroy.address VALUES (2297, 'Чернышёва, 22', 19);
INSERT INTO stroy.address VALUES (2298, 'Ошмарина, 78', 43);
INSERT INTO stroy.address VALUES (2299, 'Снежная, 53', 32);
INSERT INTO stroy.address VALUES (2300, 'Николаева, 94', 16);
INSERT INTO stroy.address VALUES (2301, 'Пайтерова, 9', 26);
INSERT INTO stroy.address VALUES (2302, 'Юрия Сергеева, 8', 12);
INSERT INTO stroy.address VALUES (2303, 'Батурина, 92', 26);
INSERT INTO stroy.address VALUES (2304, 'Плющенко, 62', 5);
INSERT INTO stroy.address VALUES (2305, 'Дружбы, 46', 34);
INSERT INTO stroy.address VALUES (2306, 'Малая Колхозная, 53', 24);
INSERT INTO stroy.address VALUES (2307, '1-Я  Ленстрой, 9', 40);
INSERT INTO stroy.address VALUES (2308, 'Дорошенко, 23', 12);
INSERT INTO stroy.address VALUES (2309, 'Щукинская, 3', 14);
INSERT INTO stroy.address VALUES (2310, 'Электрозаводская, 0', 16);
INSERT INTO stroy.address VALUES (2311, 'Сакко И Ванцетти, 18', 23);
INSERT INTO stroy.address VALUES (2312, 'Комиссарова, 72', 19);
INSERT INTO stroy.address VALUES (2313, 'Ноябрьская, 68', 6);
INSERT INTO stroy.address VALUES (2314, 'Привольная, 55', 43);
INSERT INTO stroy.address VALUES (2315, 'Измайлова, 42', 27);
INSERT INTO stroy.address VALUES (2316, 'Липецкая  (Дублёр), 100', 6);
INSERT INTO stroy.address VALUES (2317, 'Большая Серпуховская, 39', 22);
INSERT INTO stroy.address VALUES (2318, 'Майора Алексеева, 74', 24);
INSERT INTO stroy.address VALUES (2319, 'Олений Вал, 37', 38);
INSERT INTO stroy.address VALUES (2320, 'Гудкова, 4', 41);
INSERT INTO stroy.address VALUES (2321, 'Антипова, 15', 2);
INSERT INTO stroy.address VALUES (2322, 'Верейская, 98', 27);
INSERT INTO stroy.address VALUES (2323, 'Мясищева, 30', 16);
INSERT INTO stroy.address VALUES (2324, 'Ефремова, 5', 25);
INSERT INTO stroy.address VALUES (2325, 'Анны Горностаевой, 94', 41);
INSERT INTO stroy.address VALUES (2326, 'Тураевская, 85', 20);
INSERT INTO stroy.address VALUES (2327, 'Сталеваров, 40', 28);
INSERT INTO stroy.address VALUES (2328, 'Архитектора Бутовой, 32', 38);
INSERT INTO stroy.address VALUES (2329, 'Зелёная, 55', 10);
INSERT INTO stroy.address VALUES (2330, '45-Й Стрелковой Дивизии, 81', 14);
INSERT INTO stroy.address VALUES (2331, 'Айвазовского, 31', 36);
INSERT INTO stroy.address VALUES (2332, '3-Я Рейсовая, 27', 35);
INSERT INTO stroy.address VALUES (2333, 'Хлебная, 83', 9);
INSERT INTO stroy.address VALUES (2334, 'Станкевича, 91', 40);
INSERT INTO stroy.address VALUES (2335, 'Курортная, 31', 37);
INSERT INTO stroy.address VALUES (2336, 'Нормандия-Неман, 72', 28);
INSERT INTO stroy.address VALUES (2337, 'Вокзальная, 30', 44);
INSERT INTO stroy.address VALUES (2338, 'Мясницкая, 77', 31);
INSERT INTO stroy.address VALUES (2339, 'Ньютона, 75', 33);
INSERT INTO stroy.address VALUES (2340, 'Калиновская, 32', 17);
INSERT INTO stroy.address VALUES (2341, 'Малая Лубянка, 80', 2);
INSERT INTO stroy.address VALUES (2342, '206-Й Стрелковой Дивизии, 61', 47);
INSERT INTO stroy.address VALUES (2343, 'Поэта Лебедева, 88', 24);
INSERT INTO stroy.address VALUES (2344, 'Тюменская, 94', 24);
INSERT INTO stroy.address VALUES (2345, 'Трубчевская, 25', 41);
INSERT INTO stroy.address VALUES (2346, 'Ташкентская, 87', 3);
INSERT INTO stroy.address VALUES (2347, 'Студенческая, 2', 20);
INSERT INTO stroy.address VALUES (2348, 'Хавская, 71', 17);
INSERT INTO stroy.address VALUES (2349, 'Варшавская, 9', 20);
INSERT INTO stroy.address VALUES (2350, 'Доктора Гумилевской, 79', 22);
INSERT INTO stroy.address VALUES (2351, 'Ганны Шостак, 26', 8);
INSERT INTO stroy.address VALUES (2352, 'Горького, 46', 36);
INSERT INTO stroy.address VALUES (2353, 'Белгородская, 67', 10);
INSERT INTO stroy.address VALUES (2354, 'Соловьиная, 63', 13);
INSERT INTO stroy.address VALUES (2355, 'Ермака, 87', 27);
INSERT INTO stroy.address VALUES (2356, '1-Я Тверская-Ямская, 17', 32);
INSERT INTO stroy.address VALUES (2357, 'Большевиков, 74', 12);
INSERT INTO stroy.address VALUES (2358, 'Боженко, 65', 3);
INSERT INTO stroy.address VALUES (2359, 'Машиностроителей, 93', 27);
INSERT INTO stroy.address VALUES (2360, 'Гастелло, 79', 8);
INSERT INTO stroy.address VALUES (2361, 'Крахмалёва, 93', 21);
INSERT INTO stroy.address VALUES (2362, 'Верхняя Сыромятническая, 23', 46);
INSERT INTO stroy.address VALUES (2363, 'Пансионатовская, 6', 9);
INSERT INTO stroy.address VALUES (2364, 'Денисова, 18', 29);
INSERT INTO stroy.address VALUES (2365, 'Растопчина, 18', 23);
INSERT INTO stroy.address VALUES (2366, 'Лотикова, 5', 11);
INSERT INTO stroy.address VALUES (2367, 'Луговая, 73', 2);
INSERT INTO stroy.address VALUES (2368, 'Бубнова, 67', 11);
INSERT INTO stroy.address VALUES (2369, 'Непиющего, 28', 1);
INSERT INTO stroy.address VALUES (2370, 'Тарасовская, 34', 22);
INSERT INTO stroy.address VALUES (2371, 'Имени Генерала Астанина, 98', 6);
INSERT INTO stroy.address VALUES (2372, 'Колганова, 87', 33);
INSERT INTO stroy.address VALUES (2373, 'Гоголева, 41', 39);
INSERT INTO stroy.address VALUES (2374, 'Большеволжская, 56', 16);
INSERT INTO stroy.address VALUES (2375, 'Ленинская, 32', 16);
INSERT INTO stroy.address VALUES (2376, 'Красной Армии, 98', 15);
INSERT INTO stroy.address VALUES (2377, 'Грузовая, 38', 17);
INSERT INTO stroy.address VALUES (2378, 'Ленинградская Дамба, 81', 28);
INSERT INTO stroy.address VALUES (2379, 'Северная Советская, 32', 17);
INSERT INTO stroy.address VALUES (2380, 'Коммунарная, 34', 36);
INSERT INTO stroy.address VALUES (2381, 'Красный Октябрь, 32', 29);
INSERT INTO stroy.address VALUES (2382, 'Героев Панфиловцев, 36', 32);
INSERT INTO stroy.address VALUES (2383, 'Кольская, 100', 23);
INSERT INTO stroy.address VALUES (2384, 'Путилина, 17', 46);
INSERT INTO stroy.address VALUES (2385, '26 Июня, 73', 40);
INSERT INTO stroy.address VALUES (2386, 'Халаева, 26', 1);
INSERT INTO stroy.address VALUES (2387, 'Ублинские Горы, 52', 23);
INSERT INTO stroy.address VALUES (2388, 'Самотёчная, 66', 7);
INSERT INTO stroy.address VALUES (2389, 'Большая Дорогомиловская, 100', 42);
INSERT INTO stroy.address VALUES (2390, 'Наседкина, 53', 18);
INSERT INTO stroy.address VALUES (2391, 'Генерала Калинина, 46', 34);
INSERT INTO stroy.address VALUES (2392, 'Рождественская, 31', 5);
INSERT INTO stroy.address VALUES (2393, 'Коллективизации, 45', 13);
INSERT INTO stroy.address VALUES (2394, 'Воробьёвская, 42', 44);
INSERT INTO stroy.address VALUES (2395, 'Пронина, 38', 28);
INSERT INTO stroy.address VALUES (2396, 'Овражная, 62', 6);
INSERT INTO stroy.address VALUES (2397, 'Советская  На Дон, 61', 8);
INSERT INTO stroy.address VALUES (2398, 'Волчанская, 73', 17);
INSERT INTO stroy.address VALUES (2399, 'Пушкарная, 42', 10);
INSERT INTO stroy.address VALUES (2400, 'Верхняя Радищевская, 77', 31);
INSERT INTO stroy.address VALUES (2401, 'Александры Монаховой, 64', 37);
INSERT INTO stroy.address VALUES (2402, 'Ранняя Заря, 58', 1);
INSERT INTO stroy.address VALUES (2403, 'Жуковского, 42', 31);
INSERT INTO stroy.address VALUES (2404, 'Шмелькова, 80', 34);
INSERT INTO stroy.address VALUES (2405, 'Щёлокова, 68', 47);
INSERT INTO stroy.address VALUES (2406, '26 Июня, 15', 28);
INSERT INTO stroy.address VALUES (2407, 'Шереметовка, 100', 18);
INSERT INTO stroy.address VALUES (2408, '40 Лет Победы, 69', 3);
INSERT INTO stroy.address VALUES (2409, 'Кузьмина, 56', 36);
INSERT INTO stroy.address VALUES (2410, 'Голикова, 45', 42);
INSERT INTO stroy.address VALUES (2411, 'Знаменка, 88', 4);
INSERT INTO stroy.address VALUES (2412, 'Сретенка, 81', 44);
INSERT INTO stroy.address VALUES (2413, 'Крахмалёва, 92', 46);
INSERT INTO stroy.address VALUES (2414, 'Николая Старостина, 20', 23);
INSERT INTO stroy.address VALUES (2415, 'Ермака, 13', 22);
INSERT INTO stroy.address VALUES (2416, 'Николая Птицына, 86', 35);
INSERT INTO stroy.address VALUES (2417, 'Королёва, 52', 10);
INSERT INTO stroy.address VALUES (2418, 'Мытная, 10', 33);
INSERT INTO stroy.address VALUES (2419, 'Малая Красноармейская, 99', 44);
INSERT INTO stroy.address VALUES (2420, 'Старая Басманная, 84', 17);
INSERT INTO stroy.address VALUES (2421, '1-Я  Мира, 73', 45);
INSERT INTO stroy.address VALUES (2422, 'Корнилова, 52', 26);
INSERT INTO stroy.address VALUES (2423, 'Дарвина, 81', 36);
INSERT INTO stroy.address VALUES (2424, 'Порядок, 19', 23);
INSERT INTO stroy.address VALUES (2425, 'Генерала Попова, 24', 37);
INSERT INTO stroy.address VALUES (2426, 'Красных Зорь, 43', 19);
INSERT INTO stroy.address VALUES (2427, 'Скотопрогонная, 9', 24);
INSERT INTO stroy.address VALUES (2428, 'Предбазарная, 4', 24);
INSERT INTO stroy.address VALUES (2429, 'Гоголева, 50', 12);
INSERT INTO stroy.address VALUES (2430, '25 Лет Победы, 50', 37);
INSERT INTO stroy.address VALUES (2431, 'Победы, 9', 24);
INSERT INTO stroy.address VALUES (2432, 'Дубовой Рощи, 36', 10);
INSERT INTO stroy.address VALUES (2433, 'Красногвардейская, 41', 38);
INSERT INTO stroy.address VALUES (2434, 'Генерала Хлебникова, 70', 13);
INSERT INTO stroy.address VALUES (2435, 'Балчуг, 39', 13);
INSERT INTO stroy.address VALUES (2436, 'Долматова, 82', 40);
INSERT INTO stroy.address VALUES (2437, 'Механизаторов, 57', 3);
INSERT INTO stroy.address VALUES (2438, 'Берёзовая, 88', 33);
INSERT INTO stroy.address VALUES (2439, 'Большая Норская, 95', 47);
INSERT INTO stroy.address VALUES (2440, 'Удальцова, 2', 1);
INSERT INTO stroy.address VALUES (2441, 'Правды, 48', 19);
INSERT INTO stroy.address VALUES (2442, 'Ново-Белинского, 97', 30);
INSERT INTO stroy.address VALUES (2443, 'Павла Андреева, 88', 12);
INSERT INTO stroy.address VALUES (2444, 'Мирная, 84', 2);
INSERT INTO stroy.address VALUES (2445, 'Вернисажная, 100', 9);
INSERT INTO stroy.address VALUES (2446, 'Белоусова, 36', 25);
INSERT INTO stroy.address VALUES (2447, 'Фёдора Смирнова, 74', 30);
INSERT INTO stroy.address VALUES (2448, 'Большая Ордынка, 25', 13);
INSERT INTO stroy.address VALUES (2449, 'Задонская, 100', 30);
INSERT INTO stroy.address VALUES (2450, 'Мясницкая, 70', 23);
INSERT INTO stroy.address VALUES (2451, 'Мезенцево, 22', 3);
INSERT INTO stroy.address VALUES (2452, 'Энергетическая, 83', 44);
INSERT INTO stroy.address VALUES (2453, 'Даниловский Вал, 56', 26);
INSERT INTO stroy.address VALUES (2454, 'Воронежская, 50', 9);
INSERT INTO stroy.address VALUES (2455, 'Москворецкая, 66', 6);
INSERT INTO stroy.address VALUES (2456, 'Благоева, 84', 16);
INSERT INTO stroy.address VALUES (2457, 'Шолохова, 54', 6);
INSERT INTO stroy.address VALUES (2458, 'Ясеневая, 76', 4);
INSERT INTO stroy.address VALUES (2459, 'Брянской Пролетарской Дивизии, 47', 15);
INSERT INTO stroy.address VALUES (2460, 'Олонецкая, 42', 40);
INSERT INTO stroy.address VALUES (2461, 'Оранжерейная, 40', 2);
INSERT INTO stroy.address VALUES (2462, 'Хотьковская, 94', 25);
INSERT INTO stroy.address VALUES (2463, 'Ухтомская, 68', 7);
INSERT INTO stroy.address VALUES (2464, 'Лебедянская, 8', 36);
INSERT INTO stroy.address VALUES (2465, 'Ломоносова, 0', 11);
INSERT INTO stroy.address VALUES (2466, 'Ждамировская, 98', 45);
INSERT INTO stroy.address VALUES (2467, '7 Ноября, 39', 15);
INSERT INTO stroy.address VALUES (2468, 'Матросская, 80', 45);
INSERT INTO stroy.address VALUES (2469, 'Глаголева, 42', 37);
INSERT INTO stroy.address VALUES (2470, 'Ново-Солдатская, 23', 34);
INSERT INTO stroy.address VALUES (2471, 'Городищенская, 20', 41);
INSERT INTO stroy.address VALUES (2472, 'Большая Пироговская, 98', 27);
INSERT INTO stroy.address VALUES (2473, 'Больничная, 91', 42);
INSERT INTO stroy.address VALUES (2474, 'Миклухо-Маклая, 20', 26);
INSERT INTO stroy.address VALUES (2475, 'Шевелюха, 94', 23);
INSERT INTO stroy.address VALUES (2476, 'Калуга-Бор, 23', 44);
INSERT INTO stroy.address VALUES (2477, 'Станиславского, 51', 2);
INSERT INTO stroy.address VALUES (2478, 'Пашанина, 93', 9);
INSERT INTO stroy.address VALUES (2479, 'Горки Киовские, 68', 41);
INSERT INTO stroy.address VALUES (2480, 'Красная Пресня, 95', 11);
INSERT INTO stroy.address VALUES (2481, 'Александры Монаховой, 15', 26);
INSERT INTO stroy.address VALUES (2482, 'Запрудная, 66', 47);
INSERT INTO stroy.address VALUES (2483, 'Ямская, 23', 37);
INSERT INTO stroy.address VALUES (2484, 'Киёвка, 7', 8);
INSERT INTO stroy.address VALUES (2485, 'Фрязевская, 89', 46);
INSERT INTO stroy.address VALUES (2486, 'Тамбовская, 64', 36);
INSERT INTO stroy.address VALUES (2487, 'Культурная, 68', 7);
INSERT INTO stroy.address VALUES (2488, 'Черняховского, 57', 33);
INSERT INTO stroy.address VALUES (2489, 'Семёна Середы, 66', 34);
INSERT INTO stroy.address VALUES (2490, 'Нововерховенская, 22', 9);
INSERT INTO stroy.address VALUES (2491, 'Сахарова, 68', 32);
INSERT INTO stroy.address VALUES (2492, 'Красный Бор, 92', 43);
INSERT INTO stroy.address VALUES (2493, 'Алабяна, 88', 12);
INSERT INTO stroy.address VALUES (2494, 'Батурина, 31', 19);
INSERT INTO stroy.address VALUES (2495, 'Рыбинская, 100', 33);
INSERT INTO stroy.address VALUES (2496, 'О.Зеленской, 91', 27);
INSERT INTO stroy.address VALUES (2497, 'Ясногорская, 6', 2);
INSERT INTO stroy.address VALUES (2498, 'Георгия Димитрова, 31', 12);
INSERT INTO stroy.address VALUES (2499, 'Партизанская, 29', 35);
INSERT INTO stroy.address VALUES (2500, 'Талсинская, 81', 3);
INSERT INTO stroy.address VALUES (2501, 'Пятницкого, 1', 6);
INSERT INTO stroy.address VALUES (2502, 'Большая Якиманка, 41', 11);
INSERT INTO stroy.address VALUES (2503, 'Большая Советская, 44', 16);
INSERT INTO stroy.address VALUES (2504, 'Микрорайон, 3', 15);
INSERT INTO stroy.address VALUES (2505, 'Резванская, 71', 21);
INSERT INTO stroy.address VALUES (2506, 'Торговая, 38', 16);
INSERT INTO stroy.address VALUES (2507, 'Нижние Поля, 24', 44);
INSERT INTO stroy.address VALUES (2508, 'Пансионатовская, 14', 14);
INSERT INTO stroy.address VALUES (2509, 'Петропавловская, 61', 8);
INSERT INTO stroy.address VALUES (2510, 'Большая Норская, 21', 31);
INSERT INTO stroy.address VALUES (2637, 'Туполева, 91', 29);
INSERT INTO stroy.address VALUES (2511, 'Полка Нормандия-Неман, 43', 7);
INSERT INTO stroy.address VALUES (2512, 'Большевистская, 34', 28);
INSERT INTO stroy.address VALUES (2513, 'Подольских Курсантов, 63', 9);
INSERT INTO stroy.address VALUES (2514, 'Разина, 60', 13);
INSERT INTO stroy.address VALUES (2515, 'Буровая, 63', 23);
INSERT INTO stroy.address VALUES (2516, 'Малаховского, 67', 42);
INSERT INTO stroy.address VALUES (2517, 'Садовая-Самотёчная, 97', 43);
INSERT INTO stroy.address VALUES (2518, 'Сайкина, 45', 2);
INSERT INTO stroy.address VALUES (2519, 'Имени Комбрига Волосатова, 4', 27);
INSERT INTO stroy.address VALUES (2520, 'Копанка, 40', 34);
INSERT INTO stroy.address VALUES (2521, 'Шестагинская, 26', 29);
INSERT INTO stroy.address VALUES (2522, 'Возрождения, 69', 26);
INSERT INTO stroy.address VALUES (2523, 'Спивака, 30', 26);
INSERT INTO stroy.address VALUES (2524, '1-Я Курская, 30', 26);
INSERT INTO stroy.address VALUES (2525, 'Ново-Елатомская, 17', 9);
INSERT INTO stroy.address VALUES (2526, '1-Я Больничная, 0', 29);
INSERT INTO stroy.address VALUES (2527, 'Ольминского, 22', 24);
INSERT INTO stroy.address VALUES (2528, 'Перовской, 45', 27);
INSERT INTO stroy.address VALUES (2529, 'Энергетиков, 41', 29);
INSERT INTO stroy.address VALUES (2530, 'Боженко, 72', 25);
INSERT INTO stroy.address VALUES (2531, 'Победы, 10', 32);
INSERT INTO stroy.address VALUES (2532, 'Шаболовка, 92', 30);
INSERT INTO stroy.address VALUES (2533, 'Марьинская, 13', 34);
INSERT INTO stroy.address VALUES (2534, 'Спирина, 68', 30);
INSERT INTO stroy.address VALUES (2535, 'Воровского, 97', 40);
INSERT INTO stroy.address VALUES (2536, 'Крутовская, 83', 31);
INSERT INTO stroy.address VALUES (2537, 'Боровская, 32', 12);
INSERT INTO stroy.address VALUES (2538, 'Старые Сосенки, 56', 19);
INSERT INTO stroy.address VALUES (2539, 'Гиляровского, 56', 2);
INSERT INTO stroy.address VALUES (2540, 'Николаева, 55', 23);
INSERT INTO stroy.address VALUES (2541, 'Житная, 24', 5);
INSERT INTO stroy.address VALUES (2542, 'Воронежская, 42', 35);
INSERT INTO stroy.address VALUES (2543, '25 Лет Победы, 93', 30);
INSERT INTO stroy.address VALUES (2544, 'Каретный Ряд, 1', 32);
INSERT INTO stroy.address VALUES (2545, 'Дениса Давыдова, 13', 10);
INSERT INTO stroy.address VALUES (2546, '2-Я  Новосёловка, 83', 36);
INSERT INTO stroy.address VALUES (2547, 'Старомихневская, 59', 24);
INSERT INTO stroy.address VALUES (2548, 'Базарная, 10', 13);
INSERT INTO stroy.address VALUES (2549, 'Средняя, 73', 46);
INSERT INTO stroy.address VALUES (2550, '1-Я Сосновая, 49', 13);
INSERT INTO stroy.address VALUES (2551, '6-Я Радиальная, 28', 1);
INSERT INTO stroy.address VALUES (2552, 'Берёзовая, 57', 12);
INSERT INTO stroy.address VALUES (2553, 'Целинная, 81', 12);
INSERT INTO stroy.address VALUES (2554, 'Транзитная, 27', 25);
INSERT INTO stroy.address VALUES (2555, 'Раевского, 73', 21);
INSERT INTO stroy.address VALUES (2556, 'Подъячева, 56', 31);
INSERT INTO stroy.address VALUES (2557, 'Батова, 23', 18);
INSERT INTO stroy.address VALUES (2558, 'Ново-Белинского, 87', 19);
INSERT INTO stroy.address VALUES (2559, 'Ивана Сутырина, 54', 21);
INSERT INTO stroy.address VALUES (2560, 'Никифоровская, 85', 45);
INSERT INTO stroy.address VALUES (2561, 'Весёлая, 92', 44);
INSERT INTO stroy.address VALUES (2562, '800-Летия Москвы, 12', 42);
INSERT INTO stroy.address VALUES (2563, 'Академика Белова, 62', 26);
INSERT INTO stroy.address VALUES (2564, '17-Й Стрелковой Дивизии, 13', 41);
INSERT INTO stroy.address VALUES (2565, 'Митрофанова, 26', 35);
INSERT INTO stroy.address VALUES (2566, 'Мамаев Проток, 54', 21);
INSERT INTO stroy.address VALUES (2567, 'Университетская, 57', 29);
INSERT INTO stroy.address VALUES (2568, 'Займищенская, 7', 6);
INSERT INTO stroy.address VALUES (2569, 'Долгоруковская, 36', 27);
INSERT INTO stroy.address VALUES (2570, 'Асфальтная, 0', 19);
INSERT INTO stroy.address VALUES (2571, 'Красных Партизан, 96', 30);
INSERT INTO stroy.address VALUES (2572, 'Белоусова, 93', 12);
INSERT INTO stroy.address VALUES (2573, 'Юрия Смирнова, 55', 16);
INSERT INTO stroy.address VALUES (2574, 'Новоряжская, 5', 39);
INSERT INTO stroy.address VALUES (2575, 'Гензика, 17', 38);
INSERT INTO stroy.address VALUES (2576, 'Серёгина, 12', 45);
INSERT INTO stroy.address VALUES (2577, 'Мясищева, 97', 20);
INSERT INTO stroy.address VALUES (2578, 'Мустая Карима, 68', 12);
INSERT INTO stroy.address VALUES (2579, '3-Я Тарнопольская, 31', 23);
INSERT INTO stroy.address VALUES (2580, 'Зерновая, 70', 47);
INSERT INTO stroy.address VALUES (2581, 'Гиляровского, 49', 17);
INSERT INTO stroy.address VALUES (2582, 'Полярная, 74', 30);
INSERT INTO stroy.address VALUES (2583, 'Малая Лубянка, 56', 47);
INSERT INTO stroy.address VALUES (2584, '206-Й Стрелковой Дивизии, 12', 21);
INSERT INTO stroy.address VALUES (2585, 'Революционная, 42', 34);
INSERT INTO stroy.address VALUES (2586, 'Ямская, 72', 12);
INSERT INTO stroy.address VALUES (2587, 'Авиамоторная, 68', 36);
INSERT INTO stroy.address VALUES (2588, 'Мусоргского, 63', 29);
INSERT INTO stroy.address VALUES (2589, 'Барклая, 56', 11);
INSERT INTO stroy.address VALUES (2590, 'Учительская, 82', 6);
INSERT INTO stroy.address VALUES (2591, 'Промстроевская, 48', 40);
INSERT INTO stroy.address VALUES (2592, 'Велозаводская, 1', 45);
INSERT INTO stroy.address VALUES (2593, 'Чехова, 13', 37);
INSERT INTO stroy.address VALUES (2594, 'Каменка, 24', 34);
INSERT INTO stroy.address VALUES (2595, 'Росинка, 56', 18);
INSERT INTO stroy.address VALUES (2596, 'Забырина, 86', 34);
INSERT INTO stroy.address VALUES (2597, 'Докукина, 19', 5);
INSERT INTO stroy.address VALUES (2598, 'В.В.Терешковой, 79', 14);
INSERT INTO stroy.address VALUES (2599, 'Николоямская, 55', 37);
INSERT INTO stroy.address VALUES (2600, 'Костюкова, 38', 13);
INSERT INTO stroy.address VALUES (2601, 'Большая Воскресенская, 47', 32);
INSERT INTO stroy.address VALUES (2602, 'Усти-На-Лабе, 32', 24);
INSERT INTO stroy.address VALUES (2603, 'Ольги Степановой, 27', 12);
INSERT INTO stroy.address VALUES (2604, 'Степана Шутова, 35', 29);
INSERT INTO stroy.address VALUES (2605, 'Головнина, 3', 17);
INSERT INTO stroy.address VALUES (2606, 'Рябка, 26', 12);
INSERT INTO stroy.address VALUES (2607, 'Февральская, 69', 29);
INSERT INTO stroy.address VALUES (2608, 'Красный Бор, 90', 17);
INSERT INTO stroy.address VALUES (2609, 'Белинского, 40', 17);
INSERT INTO stroy.address VALUES (2610, 'Маленковская, 30', 27);
INSERT INTO stroy.address VALUES (2611, 'Горбатова, 50', 46);
INSERT INTO stroy.address VALUES (2612, 'Хромова, 35', 16);
INSERT INTO stroy.address VALUES (2613, 'Ксении Константиновой, 12', 16);
INSERT INTO stroy.address VALUES (2614, '50 Лет Ссср, 84', 7);
INSERT INTO stroy.address VALUES (2615, 'Брусилова, 41', 15);
INSERT INTO stroy.address VALUES (2616, 'Придорожная, 9', 3);
INSERT INTO stroy.address VALUES (2617, 'Большая Учительская, 53', 11);
INSERT INTO stroy.address VALUES (2618, 'Юбилейная, 11', 31);
INSERT INTO stroy.address VALUES (2619, 'Перовская, 73', 23);
INSERT INTO stroy.address VALUES (2620, 'Конная, 68', 9);
INSERT INTO stroy.address VALUES (2621, '11 Сапёров, 6', 25);
INSERT INTO stroy.address VALUES (2622, 'Красная, 85', 8);
INSERT INTO stroy.address VALUES (2623, 'Мезенцево, 11', 36);
INSERT INTO stroy.address VALUES (2624, 'Перспективная, 56', 26);
INSERT INTO stroy.address VALUES (2625, 'Весёлая, 57', 6);
INSERT INTO stroy.address VALUES (2626, 'Можайского, 57', 26);
INSERT INTO stroy.address VALUES (2627, 'Рязанская, 56', 2);
INSERT INTO stroy.address VALUES (2628, 'Новосёловка, 33', 22);
INSERT INTO stroy.address VALUES (2629, 'Менжинского, 38, 100', 37);
INSERT INTO stroy.address VALUES (2630, 'Хользунова, 8', 11);
INSERT INTO stroy.address VALUES (2631, 'Днепровская, 16', 17);
INSERT INTO stroy.address VALUES (2632, 'Усиевича, 63', 11);
INSERT INTO stroy.address VALUES (2633, 'Тропинка, 19', 14);
INSERT INTO stroy.address VALUES (2634, 'Берзарина, 75', 36);
INSERT INTO stroy.address VALUES (2635, 'Хабаровская, 54', 42);
INSERT INTO stroy.address VALUES (2636, 'Карла Маркса, 19', 1);
INSERT INTO stroy.address VALUES (2638, 'Ляшко, 99', 15);
INSERT INTO stroy.address VALUES (2639, '1-Я Транспортная, 3', 38);
INSERT INTO stroy.address VALUES (2640, 'Генерала Родина, 61', 2);
INSERT INTO stroy.address VALUES (2641, 'Нижние Мнёвники, 66', 44);
INSERT INTO stroy.address VALUES (2642, 'Хуторская, 46', 22);
INSERT INTO stroy.address VALUES (2643, 'Барклая, 32', 1);
INSERT INTO stroy.address VALUES (2644, 'Цюрупы, 19', 46);
INSERT INTO stroy.address VALUES (2645, 'Объездная, 49', 27);
INSERT INTO stroy.address VALUES (2646, 'Станиславского, 73', 24);
INSERT INTO stroy.address VALUES (2647, 'Староникитская, 41', 13);
INSERT INTO stroy.address VALUES (2648, 'Ромодановские Дворики, 70', 24);
INSERT INTO stroy.address VALUES (2649, 'Новицкого, 37', 36);
INSERT INTO stroy.address VALUES (2650, 'Калиновская, 62', 9);
INSERT INTO stroy.address VALUES (2651, 'Маленковская, 69', 46);
INSERT INTO stroy.address VALUES (2652, 'Соловьёва, 55', 9);
INSERT INTO stroy.address VALUES (2653, '1-Я  Мира, 32', 25);
INSERT INTO stroy.address VALUES (2654, '2-Я Межевая, 9', 3);
INSERT INTO stroy.address VALUES (2655, 'Им. 50-Летия Ленинского Комсомола, 96', 13);
INSERT INTO stroy.address VALUES (2656, '1-Я Совхозная, 98', 7);
INSERT INTO stroy.address VALUES (2657, 'Строительная, 21', 21);
INSERT INTO stroy.address VALUES (2658, 'Болдина, 45', 40);
INSERT INTO stroy.address VALUES (2659, 'Можайское Шоссе, Бородинская, 41', 11);
INSERT INTO stroy.address VALUES (2660, 'Полежаева, 41', 28);
INSERT INTO stroy.address VALUES (2661, 'Ждамировская, 77', 20);
INSERT INTO stroy.address VALUES (2662, 'Мещёрская, 54', 28);
INSERT INTO stroy.address VALUES (2663, 'Поречная, 66', 36);
INSERT INTO stroy.address VALUES (2664, 'Пайтерова, 62', 25);
INSERT INTO stroy.address VALUES (2665, 'Плющенко, 92', 43);
INSERT INTO stroy.address VALUES (2666, 'Заброденская, 22', 28);
INSERT INTO stroy.address VALUES (2667, 'Беляевская, 10', 40);
INSERT INTO stroy.address VALUES (2668, '1-Я Рабочая, 81', 3);
INSERT INTO stroy.address VALUES (2669, 'Бирюсинка, 28', 35);
INSERT INTO stroy.address VALUES (2670, 'Белавинская, 36', 3);
INSERT INTO stroy.address VALUES (2671, 'Демидовская, 44', 7);
INSERT INTO stroy.address VALUES (2672, '7-Й Дивизии, 90', 12);
INSERT INTO stroy.address VALUES (2673, 'Депутатская, 59', 39);
INSERT INTO stroy.address VALUES (2674, 'Бойцов 9-Й Дивизии, 42', 34);
INSERT INTO stroy.address VALUES (2675, 'Советская, 72', 15);
INSERT INTO stroy.address VALUES (2676, '40 Лет Победы, 82', 16);
INSERT INTO stroy.address VALUES (2677, 'Монтажников, 18', 15);
INSERT INTO stroy.address VALUES (2678, 'Смоленская, 40', 28);
INSERT INTO stroy.address VALUES (2679, 'Талдомская, 4', 1);
INSERT INTO stroy.address VALUES (2680, 'Тихвинская, 85', 26);
INSERT INTO stroy.address VALUES (2681, 'Автомагистраль, 57', 13);
INSERT INTO stroy.address VALUES (2682, 'Блинова, 79', 18);
INSERT INTO stroy.address VALUES (2683, 'Столетова, 32', 43);
INSERT INTO stroy.address VALUES (2684, 'Гурьева, 80', 32);
INSERT INTO stroy.address VALUES (2685, 'Никольская, 32', 3);
INSERT INTO stroy.address VALUES (2686, 'Героев Стратосферы, 93', 42);
INSERT INTO stroy.address VALUES (2687, 'Салтыковская, 2', 21);
INSERT INTO stroy.address VALUES (2688, 'Симанова, 15', 14);
INSERT INTO stroy.address VALUES (2689, 'Липовая, 88', 25);
INSERT INTO stroy.address VALUES (2690, 'Маросейка, 71', 11);
INSERT INTO stroy.address VALUES (2691, 'Селезнёва, 86', 37);
INSERT INTO stroy.address VALUES (2692, 'Большая Садовая, 63', 22);
INSERT INTO stroy.address VALUES (2693, 'Фомушина, 25', 34);
INSERT INTO stroy.address VALUES (2694, 'Достоевского, 81', 15);
INSERT INTO stroy.address VALUES (2695, 'Тракторная, 86', 28);
INSERT INTO stroy.address VALUES (2696, 'Михалковская, 52', 32);
INSERT INTO stroy.address VALUES (2697, 'Лавочкина, 12', 14);
INSERT INTO stroy.address VALUES (2698, 'Васильевский Тракт, 58', 11);
INSERT INTO stroy.address VALUES (2699, 'Губкина, 6', 16);
INSERT INTO stroy.address VALUES (2700, 'Троицкая, 46', 34);
INSERT INTO stroy.address VALUES (2701, 'Хуторская, 76', 2);
INSERT INTO stroy.address VALUES (2702, 'Академика Флёрова, 15', 44);
INSERT INTO stroy.address VALUES (2703, 'Привольная, 32', 20);
INSERT INTO stroy.address VALUES (2704, 'Наумова, 42', 14);
INSERT INTO stroy.address VALUES (2705, 'Аргамаченская, 66', 22);
INSERT INTO stroy.address VALUES (2706, 'Деловая, 20', 21);
INSERT INTO stroy.address VALUES (2707, 'Хлебозаводская, 39', 37);
INSERT INTO stroy.address VALUES (2708, 'Болдина, 29', 39);
INSERT INTO stroy.address VALUES (2709, 'Мясникова, 23', 10);
INSERT INTO stroy.address VALUES (2710, 'Дубровина, 60', 34);
INSERT INTO stroy.address VALUES (2711, 'Талдомская, 72', 41);
INSERT INTO stroy.address VALUES (2712, 'Аузина, 78', 17);
INSERT INTO stroy.address VALUES (2713, 'Милашенкова, 35', 10);
INSERT INTO stroy.address VALUES (2714, 'Дзержинская, 0', 17);
INSERT INTO stroy.address VALUES (2715, 'Кантемировская, 17', 40);
INSERT INTO stroy.address VALUES (2716, 'Маргелова, 87', 39);
INSERT INTO stroy.address VALUES (2717, 'Бирюзова, 72', 30);
INSERT INTO stroy.address VALUES (2718, 'Белореченская, 1', 30);
INSERT INTO stroy.address VALUES (2719, 'Левобережная, 92', 43);
INSERT INTO stroy.address VALUES (2720, 'Лазарева, 62', 16);
INSERT INTO stroy.address VALUES (2721, 'Школьная, 53', 35);
INSERT INTO stroy.address VALUES (2722, 'Промстроевская, 17', 7);
INSERT INTO stroy.address VALUES (2723, 'Рябикова, 46', 28);
INSERT INTO stroy.address VALUES (2724, 'Копанка, 63', 17);
INSERT INTO stroy.address VALUES (2725, 'Новобутовская, 28', 23);
INSERT INTO stroy.address VALUES (2726, 'Плещеева, 80', 15);
INSERT INTO stroy.address VALUES (2727, 'Салтыковская, 70', 10);
INSERT INTO stroy.address VALUES (2728, 'Юрьевецкая, 72', 29);
INSERT INTO stroy.address VALUES (2729, 'Олега Кошевого, 68', 37);
INSERT INTO stroy.address VALUES (2730, 'Костюкова, 8', 26);
INSERT INTO stroy.address VALUES (2731, 'Новощукинская, 74', 15);
INSERT INTO stroy.address VALUES (2732, 'Москворецкая, 12', 32);
INSERT INTO stroy.address VALUES (2733, 'Валовая, 21', 45);
INSERT INTO stroy.address VALUES (2734, 'Николаева, 61', 29);
INSERT INTO stroy.address VALUES (2735, 'Студёная Гора, 45', 21);
INSERT INTO stroy.address VALUES (2736, 'Грязинская, 79', 10);
INSERT INTO stroy.address VALUES (2737, 'Белгородской Сирени, 92', 31);
INSERT INTO stroy.address VALUES (2738, 'Станко, 39', 44);
INSERT INTO stroy.address VALUES (2739, 'Косыгина, 8', 31);
INSERT INTO stroy.address VALUES (2740, '43-Й Армии, 44', 36);
INSERT INTO stroy.address VALUES (2741, 'Олега Романова, 33', 16);
INSERT INTO stroy.address VALUES (2742, 'Красная, 33', 7);
INSERT INTO stroy.address VALUES (2743, 'Коваленко, 14', 22);
INSERT INTO stroy.address VALUES (2744, 'Пименовка, 52', 30);
INSERT INTO stroy.address VALUES (2745, 'Рябиновая, 23', 27);
INSERT INTO stroy.address VALUES (2746, 'Чертановская, 24', 36);
INSERT INTO stroy.address VALUES (2747, 'Сеченова, 16', 38);
INSERT INTO stroy.address VALUES (2748, 'Шарохина, 19', 47);
INSERT INTO stroy.address VALUES (2749, 'Перовская, 75', 4);
INSERT INTO stroy.address VALUES (2750, 'Велозаводская, 37', 13);
INSERT INTO stroy.address VALUES (2751, 'Петра I, 6', 32);
INSERT INTO stroy.address VALUES (2752, 'Городищенская, 100', 17);
INSERT INTO stroy.address VALUES (2753, '2-Я Владимирская, 14', 18);
INSERT INTO stroy.address VALUES (2754, 'Брусилова, 12', 16);
INSERT INTO stroy.address VALUES (2755, 'Паши Савельевой, 79', 42);
INSERT INTO stroy.address VALUES (2756, 'Садовая-Сухаревская, 47', 36);
INSERT INTO stroy.address VALUES (2757, 'Белгородской Сирени, 78', 47);
INSERT INTO stroy.address VALUES (2758, 'Звёздная, 93', 10);
INSERT INTO stroy.address VALUES (2759, 'Николая Химушина, 6', 38);
INSERT INTO stroy.address VALUES (2760, 'Кусковская, 90', 43);
INSERT INTO stroy.address VALUES (2761, '2-Я Новошоссейная, 32', 12);
INSERT INTO stroy.address VALUES (2762, 'Любимская, 62', 24);
INSERT INTO stroy.address VALUES (2763, 'Лихославльская, 31', 27);
INSERT INTO stroy.address VALUES (2764, 'Лескова, 28', 19);
INSERT INTO stroy.address VALUES (2765, 'Высоковольтная, 62', 13);
INSERT INTO stroy.address VALUES (2766, 'Горбуновская, 26', 14);
INSERT INTO stroy.address VALUES (2767, 'Тверская, 4', 44);
INSERT INTO stroy.address VALUES (2768, 'Моховая, 95', 32);
INSERT INTO stroy.address VALUES (2769, 'Хмелёва, 63', 12);
INSERT INTO stroy.address VALUES (2770, 'Соколова, 95', 34);
INSERT INTO stroy.address VALUES (2771, 'Сторожевая, 22', 29);
INSERT INTO stroy.address VALUES (2772, 'Генерала Родина, 86', 6);
INSERT INTO stroy.address VALUES (2773, 'Мясищева, 42', 32);
INSERT INTO stroy.address VALUES (2774, 'Бельская, 57', 30);
INSERT INTO stroy.address VALUES (2775, 'Академика Туполева, 1', 44);
INSERT INTO stroy.address VALUES (2776, 'Летниковская, 7', 5);
INSERT INTO stroy.address VALUES (2777, 'Старые Ватутинки, 94', 30);
INSERT INTO stroy.address VALUES (2778, 'Красная Слобода, 39', 23);
INSERT INTO stroy.address VALUES (2779, 'Сонина, 87', 21);
INSERT INTO stroy.address VALUES (2780, 'Паустовского, 8', 5);
INSERT INTO stroy.address VALUES (2781, 'Автодоровская, 44', 1);
INSERT INTO stroy.address VALUES (2782, 'Российская, 48', 43);
INSERT INTO stroy.address VALUES (2783, 'Большая Чернавская, 90', 6);
INSERT INTO stroy.address VALUES (2784, 'Советской Армии, 23', 14);
INSERT INTO stroy.address VALUES (2785, 'Энгельса, 96', 2);
INSERT INTO stroy.address VALUES (2786, 'Оборонная, 13', 6);
INSERT INTO stroy.address VALUES (2787, 'Им. Островского, 41', 26);
INSERT INTO stroy.address VALUES (2788, 'Стопани, 51', 44);
INSERT INTO stroy.address VALUES (2789, 'Димитрова, 94', 32);
INSERT INTO stroy.address VALUES (2790, 'Бурова, 48', 21);
INSERT INTO stroy.address VALUES (2791, 'Юлиана Семёнова, 52', 34);
INSERT INTO stroy.address VALUES (2792, 'Олонецкая, 22', 22);
INSERT INTO stroy.address VALUES (2793, '22-Го Съезда Кпсс, 37', 12);
INSERT INTO stroy.address VALUES (2794, 'Новоалександровская, 85', 18);
INSERT INTO stroy.address VALUES (2795, 'Кавалерийская, 73', 35);
INSERT INTO stroy.address VALUES (2796, 'Свердлова, 33', 43);
INSERT INTO stroy.address VALUES (2797, 'Семинарская, 0', 41);
INSERT INTO stroy.address VALUES (2798, 'Расторгуева, 75', 13);
INSERT INTO stroy.address VALUES (2799, 'Новогиреевская, 55', 45);
INSERT INTO stroy.address VALUES (2800, 'Арсеньевка, 85', 18);
INSERT INTO stroy.address VALUES (2801, 'Сентюрёва, 3', 4);
INSERT INTO stroy.address VALUES (2802, '50 Лет Победы, 68', 23);
INSERT INTO stroy.address VALUES (2803, 'Щёлокова, 91', 12);
INSERT INTO stroy.address VALUES (2804, 'Тарасова, 61', 4);
INSERT INTO stroy.address VALUES (2805, 'Маросейка, 42', 42);
INSERT INTO stroy.address VALUES (2806, 'Фёдора Полетаева, 39', 14);
INSERT INTO stroy.address VALUES (2807, 'Приборостроительная, 30', 26);
INSERT INTO stroy.address VALUES (2808, 'Ромодановские Дворики, 53', 13);
INSERT INTO stroy.address VALUES (2809, 'Минина, 45', 39);
INSERT INTO stroy.address VALUES (2810, 'Маяковского, 50', 47);
INSERT INTO stroy.address VALUES (2811, 'Пароходная, 33', 34);
INSERT INTO stroy.address VALUES (2812, 'Стрелецкий Спуск, 75', 43);
INSERT INTO stroy.address VALUES (2813, 'Сайкина, 6', 8);
INSERT INTO stroy.address VALUES (2814, 'Бойцов 9-Й Дивизии, 40', 43);
INSERT INTO stroy.address VALUES (2815, 'Полбина, 32', 25);
INSERT INTO stroy.address VALUES (2816, 'Попова, 3', 26);
INSERT INTO stroy.address VALUES (2817, 'Новая Слобода, 33', 41);
INSERT INTO stroy.address VALUES (2818, 'Каретный Ряд, 67', 29);
INSERT INTO stroy.address VALUES (2819, 'Сухоборская, 15', 25);
INSERT INTO stroy.address VALUES (2820, 'Низовая, 92', 18);
INSERT INTO stroy.address VALUES (2821, 'Глебовская, 5', 9);
INSERT INTO stroy.address VALUES (2822, 'Приборостроителей, 7', 6);
INSERT INTO stroy.address VALUES (2823, 'Фрунзе, 96', 17);
INSERT INTO stroy.address VALUES (2824, 'Михалицына, 15', 43);
INSERT INTO stroy.address VALUES (2825, 'Глебовская, 8', 12);
INSERT INTO stroy.address VALUES (2826, 'Антонова, 93', 25);
INSERT INTO stroy.address VALUES (2827, 'Гжатская, 19', 44);
INSERT INTO stroy.address VALUES (2828, 'Антонова-Овсеенко, 23', 40);
INSERT INTO stroy.address VALUES (2829, 'Брестская, 81', 8);
INSERT INTO stroy.address VALUES (2830, 'Бельская, 5', 21);
INSERT INTO stroy.address VALUES (2831, 'Найдова-Железова, 7', 25);
INSERT INTO stroy.address VALUES (2832, 'Фролова, 93', 26);
INSERT INTO stroy.address VALUES (2833, 'Халаева, 36', 12);
INSERT INTO stroy.address VALUES (2834, 'Дубовская, 86', 24);
INSERT INTO stroy.address VALUES (2835, 'Пограничника Рыжикова, 69', 29);
INSERT INTO stroy.address VALUES (2836, 'Сайкина, 49', 36);
INSERT INTO stroy.address VALUES (2837, 'Лебеденко, 83', 42);
INSERT INTO stroy.address VALUES (2838, 'Васильковая, 62', 2);
INSERT INTO stroy.address VALUES (2839, 'Фёдора Полетаева, 26', 31);
INSERT INTO stroy.address VALUES (2840, 'Ижорская, 32', 2);
INSERT INTO stroy.address VALUES (2841, 'Волчанская, 13', 16);
INSERT INTO stroy.address VALUES (2842, '2-Я Дубковская, 61', 16);
INSERT INTO stroy.address VALUES (2843, '10 Августа, 86', 37);
INSERT INTO stroy.address VALUES (2844, 'Забырина, 100', 15);
INSERT INTO stroy.address VALUES (2845, 'Медвежье, 81', 12);
INSERT INTO stroy.address VALUES (2846, 'Ох Волна Революции, 61', 17);
INSERT INTO stroy.address VALUES (2847, 'Фрязевская, 13', 40);
INSERT INTO stroy.address VALUES (2848, 'Коншиных, 84', 44);
INSERT INTO stroy.address VALUES (2849, 'Спивака, 64', 15);
INSERT INTO stroy.address VALUES (2850, 'Рябиновая, 68', 9);
INSERT INTO stroy.address VALUES (2851, 'Маршала Бирюзова, 87', 32);
INSERT INTO stroy.address VALUES (2852, 'Майора Алексеева, 87', 23);
INSERT INTO stroy.address VALUES (2853, 'Белавинская, 99', 44);
INSERT INTO stroy.address VALUES (2854, 'Тевосяна, 97', 43);
INSERT INTO stroy.address VALUES (2855, 'Маршала Шестопалова, 55', 24);
INSERT INTO stroy.address VALUES (2856, 'Неделина, 80', 11);
INSERT INTO stroy.address VALUES (2857, 'Радио, 45', 32);
INSERT INTO stroy.address VALUES (2858, 'Желябова, 16', 47);
INSERT INTO stroy.address VALUES (2859, 'Университетская, 32', 13);
INSERT INTO stroy.address VALUES (2860, 'Макарьевская, 2', 15);
INSERT INTO stroy.address VALUES (2861, 'Петра I, 21', 46);
INSERT INTO stroy.address VALUES (2862, 'Подазовская, 52', 42);
INSERT INTO stroy.address VALUES (2863, 'Днепровская, 14', 17);
INSERT INTO stroy.address VALUES (2864, 'Преображенского, 50', 38);
INSERT INTO stroy.address VALUES (2865, 'Пайтерова, 53', 27);
INSERT INTO stroy.address VALUES (2866, 'Благовещенская, 53', 9);
INSERT INTO stroy.address VALUES (2867, 'Соборная Гора, 79', 32);
INSERT INTO stroy.address VALUES (2868, 'Железнодорожная, 32', 18);
INSERT INTO stroy.address VALUES (2869, 'Паши Савельевой, 48', 7);
INSERT INTO stroy.address VALUES (2870, 'Космонавтов, 88', 44);
INSERT INTO stroy.address VALUES (2871, 'Госпитальная, 92', 3);
INSERT INTO stroy.address VALUES (2872, 'Ольховка, 95', 16);
INSERT INTO stroy.address VALUES (2873, 'Рогова, 42', 28);
INSERT INTO stroy.address VALUES (2874, 'Дзержинского, 88', 42);
INSERT INTO stroy.address VALUES (2875, 'Большая Покровская, 14', 38);
INSERT INTO stroy.address VALUES (2876, 'Лётчика Бабушкина, 98', 47);
INSERT INTO stroy.address VALUES (2877, 'Софийская, 62', 1);
INSERT INTO stroy.address VALUES (2878, 'Ногина, 73', 23);
INSERT INTO stroy.address VALUES (2879, 'Гуреевская, 53', 16);
INSERT INTO stroy.address VALUES (2880, 'Верхняя Луговая, 21', 16);
INSERT INTO stroy.address VALUES (2881, 'Крупской, 58', 17);
INSERT INTO stroy.address VALUES (2882, 'Дмитриева; Карла Маркса, 55', 19);
INSERT INTO stroy.address VALUES (2883, 'Спартаковская, 96', 10);
INSERT INTO stroy.address VALUES (2884, 'Краснооктябрьская, 95', 45);
INSERT INTO stroy.address VALUES (2885, 'Катукова, 33', 11);
INSERT INTO stroy.address VALUES (2886, 'Елецкая, 71', 33);
INSERT INTO stroy.address VALUES (2887, 'Чичканова, 30', 10);
INSERT INTO stroy.address VALUES (2888, 'Заречная, 44', 42);
INSERT INTO stroy.address VALUES (2889, 'Платонова, 47', 37);
INSERT INTO stroy.address VALUES (2890, 'Неделинская, 22', 34);
INSERT INTO stroy.address VALUES (2891, 'Кутузова, 89', 41);
INSERT INTO stroy.address VALUES (2892, 'Белоусова, 75', 41);
INSERT INTO stroy.address VALUES (2893, 'Самойловой, 92', 41);
INSERT INTO stroy.address VALUES (2894, 'Сухоборская, 92', 16);
INSERT INTO stroy.address VALUES (2895, 'Старомихневская, 74', 22);
INSERT INTO stroy.address VALUES (2896, 'Малая Московская, 73', 14);
INSERT INTO stroy.address VALUES (2897, 'Горки Киовские, 66', 5);
INSERT INTO stroy.address VALUES (2898, '2-Я Рабочая, 26', 8);
INSERT INTO stroy.address VALUES (2899, 'Станкостроителей, 23', 44);
INSERT INTO stroy.address VALUES (2900, 'Вострухина, 1', 18);
INSERT INTO stroy.address VALUES (2901, 'Спивака, 17', 45);
INSERT INTO stroy.address VALUES (2902, 'Кольцевая, 70', 46);
INSERT INTO stroy.address VALUES (2903, 'Старые Кремёнки, 10', 33);
INSERT INTO stroy.address VALUES (2904, 'Ленточка, 68', 2);
INSERT INTO stroy.address VALUES (2905, 'Большая Дорогомиловская, 18', 31);
INSERT INTO stroy.address VALUES (2906, 'Большая Еловая, 53', 25);
INSERT INTO stroy.address VALUES (2907, 'Буровая, 25', 27);
INSERT INTO stroy.address VALUES (2908, 'Физическая, 62', 20);
INSERT INTO stroy.address VALUES (2909, 'Колганова, 61', 12);
INSERT INTO stroy.address VALUES (2910, 'Боровская, 14', 36);
INSERT INTO stroy.address VALUES (2911, 'Браварская, 33', 21);
INSERT INTO stroy.address VALUES (2912, 'Стаханова, 7', 25);
INSERT INTO stroy.address VALUES (2913, 'Корешкова, 30', 37);
INSERT INTO stroy.address VALUES (2914, 'Белова, 81', 18);
INSERT INTO stroy.address VALUES (2915, 'Зубковой, 40', 37);
INSERT INTO stroy.address VALUES (2916, 'Новокрюковская, 33', 26);
INSERT INTO stroy.address VALUES (2917, 'Мусоргского, 47', 35);
INSERT INTO stroy.address VALUES (2918, 'Туполева, 87', 19);
INSERT INTO stroy.address VALUES (2919, 'Коммуны, 68', 38);
INSERT INTO stroy.address VALUES (2920, 'Большая Чернавская, 99', 24);
INSERT INTO stroy.address VALUES (2921, '1-Я Совхозная, 31', 26);
INSERT INTO stroy.address VALUES (2922, 'Большая Рупасовская, 71', 38);
INSERT INTO stroy.address VALUES (2923, 'Большая Ордынка, 89', 28);
INSERT INTO stroy.address VALUES (2924, '1-Я Владимирская, 7', 14);
INSERT INTO stroy.address VALUES (2925, 'Полушкина Роща, 63', 9);
INSERT INTO stroy.address VALUES (2926, 'Садовая-Кудринская, 100', 24);
INSERT INTO stroy.address VALUES (2927, 'Корольковой, 27', 1);
INSERT INTO stroy.address VALUES (2928, 'Бурденко, 72', 41);
INSERT INTO stroy.address VALUES (2929, 'Красногвардейская, 24', 18);
INSERT INTO stroy.address VALUES (2930, 'Новосёлки-Слободка, 96', 37);
INSERT INTO stroy.address VALUES (2931, 'Академика Скрябина, 96', 14);
INSERT INTO stroy.address VALUES (2932, 'Запольная, 40', 39);
INSERT INTO stroy.address VALUES (2933, 'Соболева, 66', 22);
INSERT INTO stroy.address VALUES (2934, 'Загородная, 34', 31);
INSERT INTO stroy.address VALUES (2935, 'Марченко, 14', 8);
INSERT INTO stroy.address VALUES (2936, 'Карачевская, 61', 40);
INSERT INTO stroy.address VALUES (2937, 'Журавлёва, 63', 19);
INSERT INTO stroy.address VALUES (2938, 'Декабристов, 23', 23);
INSERT INTO stroy.address VALUES (2939, 'Тестовская, 80', 12);
INSERT INTO stroy.address VALUES (2940, 'Петрозаводская, 3', 47);
INSERT INTO stroy.address VALUES (2941, 'Геническая, 55', 41);
INSERT INTO stroy.address VALUES (2942, 'Малаховского, 41', 17);
INSERT INTO stroy.address VALUES (2943, 'Лётчика Осканова, 84', 3);
INSERT INTO stroy.address VALUES (2944, 'Люсиновская, 29', 1);
INSERT INTO stroy.address VALUES (2945, 'Князева, 10', 38);
INSERT INTO stroy.address VALUES (2946, 'Ямская, 54', 2);
INSERT INTO stroy.address VALUES (2947, 'Степная, 40', 11);
INSERT INTO stroy.address VALUES (2948, 'Лихарево, 78', 35);
INSERT INTO stroy.address VALUES (2949, 'Кавказская, 49', 18);
INSERT INTO stroy.address VALUES (2950, 'Татаринова, 32', 22);
INSERT INTO stroy.address VALUES (2951, 'Екатерины Зеленко, 23', 7);
INSERT INTO stroy.address VALUES (2952, '5-Я Завокзальная, 92', 38);
INSERT INTO stroy.address VALUES (2953, 'Марьинская, 21', 21);
INSERT INTO stroy.address VALUES (2954, 'Новаторская, 80', 19);
INSERT INTO stroy.address VALUES (2955, 'Конная, 95', 1);
INSERT INTO stroy.address VALUES (2956, 'Гладышева, 0', 40);
INSERT INTO stroy.address VALUES (2957, 'Складочная, 58', 17);
INSERT INTO stroy.address VALUES (2958, 'Курортная, 51', 32);
INSERT INTO stroy.address VALUES (2959, 'Интернациональная, 8', 7);
INSERT INTO stroy.address VALUES (2960, 'Новосёлки, 95', 47);
INSERT INTO stroy.address VALUES (2961, 'Миклухо-Маклая, 69', 47);
INSERT INTO stroy.address VALUES (2962, 'Игнатьевская, 11', 17);
INSERT INTO stroy.address VALUES (2963, 'Дьяконова, 37', 15);
INSERT INTO stroy.address VALUES (2964, 'Большая Рупасовская, 44', 8);
INSERT INTO stroy.address VALUES (2965, 'Тропинка, 37', 3);
INSERT INTO stroy.address VALUES (2966, 'Хмелёва, 3', 44);
INSERT INTO stroy.address VALUES (2967, '10 Августа, 20', 10);
INSERT INTO stroy.address VALUES (2968, 'Скобелевская, 39', 39);
INSERT INTO stroy.address VALUES (2969, '11-Я Парковая, 82', 33);
INSERT INTO stroy.address VALUES (2970, 'Болотова, 47', 14);
INSERT INTO stroy.address VALUES (2971, 'Наседкина, 95', 6);
INSERT INTO stroy.address VALUES (2972, 'Красный Маяк, 19', 3);
INSERT INTO stroy.address VALUES (2973, 'Мосфильмовская, 50', 43);
INSERT INTO stroy.address VALUES (2974, 'Тихая, 9', 24);
INSERT INTO stroy.address VALUES (2975, 'Грязинская, 78', 47);
INSERT INTO stroy.address VALUES (2976, 'Больничная, 92', 41);
INSERT INTO stroy.address VALUES (2977, 'Соловьёва, 98', 36);
INSERT INTO stroy.address VALUES (2978, 'Садовая-Сухаревская, 27', 25);
INSERT INTO stroy.address VALUES (2979, 'Центральная, 1', 35);
INSERT INTO stroy.address VALUES (2980, 'Имени Комбрига Волосатова, 9', 27);
INSERT INTO stroy.address VALUES (2981, '2-Я Рабочая, 4', 24);
INSERT INTO stroy.address VALUES (2982, '9-Й Гвардейской Дивизии, 16', 18);
INSERT INTO stroy.address VALUES (2983, 'Чугунова, 29', 22);
INSERT INTO stroy.address VALUES (2984, 'Щербаковская, 88', 12);
INSERT INTO stroy.address VALUES (2985, 'Шишунова, 18', 33);
INSERT INTO stroy.address VALUES (2986, 'Перовская, 0', 14);
INSERT INTO stroy.address VALUES (2987, 'Беловой, 43', 20);
INSERT INTO stroy.address VALUES (2988, 'Белоусова, 12', 36);
INSERT INTO stroy.address VALUES (2989, 'Нормандия-Неман, 64', 2);
INSERT INTO stroy.address VALUES (2990, 'Садовая, 74', 15);
INSERT INTO stroy.address VALUES (2991, 'Хользунова, 81', 27);
INSERT INTO stroy.address VALUES (2992, 'Меленковская, 59', 9);
INSERT INTO stroy.address VALUES (2993, '25 Сентября, 2', 37);
INSERT INTO stroy.address VALUES (2994, 'Краснинская, 96', 5);
INSERT INTO stroy.address VALUES (2995, 'Яна Берзина, 2', 14);
INSERT INTO stroy.address VALUES (2996, 'Гладышева, 65', 39);
INSERT INTO stroy.address VALUES (2997, 'Боровская, 74', 8);
INSERT INTO stroy.address VALUES (2998, 'Леснорядская, 32', 47);
INSERT INTO stroy.address VALUES (2999, 'Палехская, 94', 14);
INSERT INTO stroy.address VALUES (3000, 'Вахрушева, 30', 17);
INSERT INTO stroy.address VALUES (3001, 'Подстанция, 25', 23);
INSERT INTO stroy.address VALUES (3002, 'Крюкова, 18', 26);
INSERT INTO stroy.address VALUES (3003, 'Резиновая, 52', 45);
INSERT INTO stroy.address VALUES (3004, 'Староникитская, 3', 13);
INSERT INTO stroy.address VALUES (3005, 'Орудовская, 60', 31);
INSERT INTO stroy.address VALUES (3006, 'Песковатская, 73', 33);
INSERT INTO stroy.address VALUES (3007, 'Административная, 9', 13);
INSERT INTO stroy.address VALUES (3008, 'Урожайная, 77', 17);
INSERT INTO stroy.address VALUES (3009, 'Электрификации, 66', 6);
INSERT INTO stroy.address VALUES (3010, 'Волжская, 64', 17);
INSERT INTO stroy.address VALUES (3011, 'Шпалорезка, 66', 20);
INSERT INTO stroy.address VALUES (3012, 'Рабочая, 23', 44);
INSERT INTO stroy.address VALUES (3013, 'Лескова, 20', 21);
INSERT INTO stroy.address VALUES (3014, 'Зои И Александра Космодемьянских, 37', 9);
INSERT INTO stroy.address VALUES (3015, 'Горняков, 94', 25);
INSERT INTO stroy.address VALUES (3016, 'Генерала Трубникова, 63', 20);
INSERT INTO stroy.address VALUES (3017, 'Пмк-10, 66', 37);
INSERT INTO stroy.address VALUES (3018, 'Микрорайон, 46', 16);
INSERT INTO stroy.address VALUES (3019, 'Черневская, 2', 3);
INSERT INTO stroy.address VALUES (3020, '1-Я Интернациональная, 94', 23);
INSERT INTO stroy.address VALUES (3021, 'Сосновая, 78', 36);
INSERT INTO stroy.address VALUES (3022, 'Дирижабельная, 55', 7);
INSERT INTO stroy.address VALUES (3023, 'Луначарского, 93', 10);
INSERT INTO stroy.address VALUES (3024, 'Селезнёва, 20', 2);
INSERT INTO stroy.address VALUES (3025, 'Гаврилова, 83', 29);
INSERT INTO stroy.address VALUES (3026, 'Князева, 67', 19);
INSERT INTO stroy.address VALUES (3027, 'Магистральная, 36', 36);
INSERT INTO stroy.address VALUES (3028, 'Деревягина, 31', 41);
INSERT INTO stroy.address VALUES (3029, 'Бахаровка, 69', 19);
INSERT INTO stroy.address VALUES (3030, 'Центральная, 74', 45);
INSERT INTO stroy.address VALUES (3031, 'Слепцова, 28', 38);
INSERT INTO stroy.address VALUES (3032, 'Пресненский Вал, 1', 35);
INSERT INTO stroy.address VALUES (3033, 'Таллинская, 30', 27);
INSERT INTO stroy.address VALUES (3034, 'Монтажная, 42', 38);
INSERT INTO stroy.address VALUES (3035, '50 Лет Победы, 98', 24);
INSERT INTO stroy.address VALUES (3036, 'Целинная, 80', 1);
INSERT INTO stroy.address VALUES (3037, 'Молдагуловой, 77', 39);
INSERT INTO stroy.address VALUES (3038, 'Народная, 69', 25);
INSERT INTO stroy.address VALUES (3039, 'Торопецкая, 44', 33);
INSERT INTO stroy.address VALUES (3040, 'Рождественская, 91', 34);
INSERT INTO stroy.address VALUES (3041, 'Дуниловская, 64', 36);
INSERT INTO stroy.address VALUES (3042, 'Летовского Ополчения, 18', 23);
INSERT INTO stroy.address VALUES (3043, 'Сталеваров, 54', 40);
INSERT INTO stroy.address VALUES (3044, 'Пушкарская, 11', 46);
INSERT INTO stroy.address VALUES (3045, 'Волковская, 62', 13);
INSERT INTO stroy.address VALUES (3046, 'Тураевская, 19', 9);
INSERT INTO stroy.address VALUES (3047, 'Энгельса, 6', 25);
INSERT INTO stroy.address VALUES (3048, 'Иванцова, 66', 37);
INSERT INTO stroy.address VALUES (3049, 'Шишкина, 9', 11);
INSERT INTO stroy.address VALUES (3050, 'Набережная, 100', 26);
INSERT INTO stroy.address VALUES (3051, 'Самотёчная, 71', 38);
INSERT INTO stroy.address VALUES (3052, 'Старые Ватутинки, 16', 46);
INSERT INTO stroy.address VALUES (3053, 'Лилякова, 77', 19);
INSERT INTO stroy.address VALUES (3054, 'Ялтинская, 43', 45);
INSERT INTO stroy.address VALUES (3055, 'Юных Ленинцев, 9', 2);
INSERT INTO stroy.address VALUES (3056, 'Гранатная, 54', 15);
INSERT INTO stroy.address VALUES (3057, 'Уральская, 77', 27);
INSERT INTO stroy.address VALUES (3058, 'Физкультурная, 30', 29);
INSERT INTO stroy.address VALUES (3059, 'Стрелецкий Спуск, 22', 42);
INSERT INTO stroy.address VALUES (3060, 'Советской Армии, 16', 26);
INSERT INTO stroy.address VALUES (3061, 'Юбилейная, 94', 45);
INSERT INTO stroy.address VALUES (3062, 'Кардовского, 80', 47);
INSERT INTO stroy.address VALUES (3063, 'Генерала Лукина, 83', 15);
INSERT INTO stroy.address VALUES (3064, 'Секиотовская, 20', 1);
INSERT INTO stroy.address VALUES (3065, 'Героев Стратосферы, 25', 44);
INSERT INTO stroy.address VALUES (3066, 'Воронина, 46', 16);
INSERT INTO stroy.address VALUES (3067, 'Индустриальная, 17', 8);
INSERT INTO stroy.address VALUES (3068, 'Берзарина, 2', 5);
INSERT INTO stroy.address VALUES (3069, 'Новая Слобода, 90', 47);
INSERT INTO stroy.address VALUES (3070, 'Мостостроевская, 4', 40);
INSERT INTO stroy.address VALUES (3071, 'Пересвета, 82', 25);
INSERT INTO stroy.address VALUES (3072, 'Бебеля, 86', 20);
INSERT INTO stroy.address VALUES (3073, 'Звёздная, 23', 32);
INSERT INTO stroy.address VALUES (3074, 'Краснопрудная, 57', 36);
INSERT INTO stroy.address VALUES (3075, 'Бебеля, 40', 21);
INSERT INTO stroy.address VALUES (3076, 'Заброденская, 51', 16);
INSERT INTO stroy.address VALUES (3077, 'Иловайская, 53', 4);
INSERT INTO stroy.address VALUES (3078, 'Поликарпова, 46', 16);
INSERT INTO stroy.address VALUES (3079, 'Ананченко, 71', 6);
INSERT INTO stroy.address VALUES (3080, 'Владимирская, 47', 3);
INSERT INTO stroy.address VALUES (3081, 'Терпигорева, 47', 27);
INSERT INTO stroy.address VALUES (3082, 'Изыскателей, 49', 23);
INSERT INTO stroy.address VALUES (3083, 'Сельхозтехника, 32', 28);
INSERT INTO stroy.address VALUES (3084, 'Гастелло, 83', 6);
INSERT INTO stroy.address VALUES (3085, 'Взлётная, 26', 42);
INSERT INTO stroy.address VALUES (3086, 'Физическая, 75', 7);
INSERT INTO stroy.address VALUES (3087, 'Фридриха Энгельса, 62', 47);
INSERT INTO stroy.address VALUES (3088, 'Ленинского Юбилея, 25', 24);
INSERT INTO stroy.address VALUES (3089, 'Загать, 84', 22);
INSERT INTO stroy.address VALUES (3090, 'Россошанская, 28', 31);
INSERT INTO stroy.address VALUES (3091, 'Покровская, 98', 3);
INSERT INTO stroy.address VALUES (3092, 'Павловского, 60', 12);
INSERT INTO stroy.address VALUES (3093, 'Островского, 64', 40);
INSERT INTO stroy.address VALUES (3094, 'Большая Фёдоровская, 71', 5);
INSERT INTO stroy.address VALUES (3095, 'Бубнова, 46', 36);
INSERT INTO stroy.address VALUES (3096, 'Межевая, 53', 28);
INSERT INTO stroy.address VALUES (3097, 'Войнова, 56', 39);
INSERT INTO stroy.address VALUES (3098, 'Валовая, 59', 28);
INSERT INTO stroy.address VALUES (3099, 'Восточная, 93', 15);
INSERT INTO stroy.address VALUES (3100, 'Тарутинская, 3', 26);
INSERT INTO stroy.address VALUES (3101, '2-Я Заречная, 63', 9);
INSERT INTO stroy.address VALUES (3102, 'Корольковой, 61', 13);
INSERT INTO stroy.address VALUES (3103, 'Ноябрьская, 3', 35);
INSERT INTO stroy.address VALUES (3104, 'Монтажная, 14', 18);
INSERT INTO stroy.address VALUES (3105, 'Северной Правды, 33', 45);
INSERT INTO stroy.address VALUES (3106, 'Ртс, 79', 40);
INSERT INTO stroy.address VALUES (3107, 'Бубнова, 27', 22);
INSERT INTO stroy.address VALUES (3108, 'Фокина, 79', 45);
INSERT INTO stroy.address VALUES (3109, 'Свердлова, 88', 31);
INSERT INTO stroy.address VALUES (3110, 'Академика Сахарова, 84', 5);
INSERT INTO stroy.address VALUES (3111, 'Мясникова, 95', 5);
INSERT INTO stroy.address VALUES (3112, 'Троицкая, 30', 2);
INSERT INTO stroy.address VALUES (3113, 'Николая Птицына, 20', 3);
INSERT INTO stroy.address VALUES (3114, 'Князева, 91', 13);
INSERT INTO stroy.address VALUES (3115, 'Даниловская, 97', 6);
INSERT INTO stroy.address VALUES (3116, 'Георгия Димитрова, 99', 36);
INSERT INTO stroy.address VALUES (3117, 'Дугина, 44', 1);
INSERT INTO stroy.address VALUES (3118, 'Снежетьский Вал, 42', 38);
INSERT INTO stroy.address VALUES (3119, 'Автозаводская, 68', 9);
INSERT INTO stroy.address VALUES (3120, 'Гастелло, 70', 28);
INSERT INTO stroy.address VALUES (3121, 'Игнатьевская, 26', 30);
INSERT INTO stroy.address VALUES (3122, 'Беляева, 80', 2);
INSERT INTO stroy.address VALUES (3123, 'Совхозная Слобода, 86', 16);
INSERT INTO stroy.address VALUES (3124, 'Прудовая, 92', 17);
INSERT INTO stroy.address VALUES (3125, 'Южная, 37', 12);
INSERT INTO stroy.address VALUES (3126, 'Кожевников, 0', 2);
INSERT INTO stroy.address VALUES (3127, 'Стародубская, 80', 31);
INSERT INTO stroy.address VALUES (3128, 'Пятницкого, 30', 44);
INSERT INTO stroy.address VALUES (3129, 'Юрия Беленогова, 8', 24);
INSERT INTO stroy.address VALUES (3130, 'Калининградская, 31', 18);
INSERT INTO stroy.address VALUES (3131, 'Ромодановские Дворики, 54', 7);
INSERT INTO stroy.address VALUES (3132, '50 Лет Влксм, 5', 7);
INSERT INTO stroy.address VALUES (3133, 'Бибиревская, 85', 18);
INSERT INTO stroy.address VALUES (3134, 'Кузьмина, 76', 33);
INSERT INTO stroy.address VALUES (3135, 'Астраханская, 19', 23);
INSERT INTO stroy.address VALUES (3136, 'Верхняя Луговая, 100', 27);
INSERT INTO stroy.address VALUES (3137, 'Высоковольтная, 24', 27);
INSERT INTO stroy.address VALUES (3138, 'Бабушкина, 86', 27);
INSERT INTO stroy.address VALUES (3139, 'Новый Арбат, 7', 32);
INSERT INTO stroy.address VALUES (3140, 'Обручева, 74', 13);
INSERT INTO stroy.address VALUES (3141, 'Парижской Коммуны, 60', 46);
INSERT INTO stroy.address VALUES (3142, 'Павла Большевикова, 23', 35);
INSERT INTO stroy.address VALUES (3143, 'Красный Маяк, 59', 20);
INSERT INTO stroy.address VALUES (3144, '20-Летия Октября, 31', 30);
INSERT INTO stroy.address VALUES (3145, 'Марьинский Парк, 5', 44);
INSERT INTO stroy.address VALUES (3146, 'Дениса Давыдова, 51', 33);
INSERT INTO stroy.address VALUES (3147, 'Курортная, 58', 19);
INSERT INTO stroy.address VALUES (3148, 'Мамаев Проток, 96', 3);
INSERT INTO stroy.address VALUES (3149, 'Тестовская, 35', 38);
INSERT INTO stroy.address VALUES (3150, 'Озёрная, 63', 40);
INSERT INTO stroy.address VALUES (3151, 'Беловой, 29', 4);
INSERT INTO stroy.address VALUES (3152, 'Цюрупы, 25', 40);
INSERT INTO stroy.address VALUES (3153, 'Мареевская, 40', 21);
INSERT INTO stroy.address VALUES (3154, 'Карачевская, 85', 8);
INSERT INTO stroy.address VALUES (3155, 'Тропинка, 100', 1);
INSERT INTO stroy.address VALUES (3156, 'Василия Фабричнова, 95', 26);
INSERT INTO stroy.address VALUES (3157, 'Больничная, 23', 33);
INSERT INTO stroy.address VALUES (3158, 'Постышева, 95', 47);
INSERT INTO stroy.address VALUES (3159, 'Малая Калитниковская, 42', 26);
INSERT INTO stroy.address VALUES (3160, 'Приборостроителей, 52', 2);
INSERT INTO stroy.address VALUES (3161, 'Праволинейная, 89', 42);
INSERT INTO stroy.address VALUES (3162, 'Садовая-Спасская, 0', 47);
INSERT INTO stroy.address VALUES (3163, 'Новосёлковская, 20', 43);
INSERT INTO stroy.address VALUES (3164, 'Геологов, 69', 28);
INSERT INTO stroy.address VALUES (3165, 'Марфы Белоглядовой, 6', 22);
INSERT INTO stroy.address VALUES (3166, 'Старообрядческая, 19', 34);
INSERT INTO stroy.address VALUES (3167, 'Старовокзальная, 74', 30);
INSERT INTO stroy.address VALUES (3168, 'Вялковская, 5', 36);
INSERT INTO stroy.address VALUES (3169, 'Панина, 38', 26);
INSERT INTO stroy.address VALUES (3170, 'Коммуны Герольд, 33', 30);
INSERT INTO stroy.address VALUES (3171, 'Институтская, 96', 20);
INSERT INTO stroy.address VALUES (3172, 'Кухмистерова, 1', 34);
INSERT INTO stroy.address VALUES (3173, 'Волочаевская, 30', 33);
INSERT INTO stroy.address VALUES (3174, 'Восточная, 84', 28);
INSERT INTO stroy.address VALUES (3175, 'Ульянова, 79', 44);
INSERT INTO stroy.address VALUES (3176, 'Бакинская, 4', 41);
INSERT INTO stroy.address VALUES (3177, '3-Я Южная, 27', 4);
INSERT INTO stroy.address VALUES (3178, 'Донская, 32', 7);
INSERT INTO stroy.address VALUES (3179, 'Заречная, 12', 17);
INSERT INTO stroy.address VALUES (3180, 'Первомайская, 80', 21);
INSERT INTO stroy.address VALUES (3181, 'Дубровина, 28', 12);
INSERT INTO stroy.address VALUES (3182, 'Боровское Шоссе, Шоссейная, 89', 14);
INSERT INTO stroy.address VALUES (3183, 'Большая Черкизовская, 70', 30);
INSERT INTO stroy.address VALUES (3184, 'Нижняя Дебря, 4', 46);
INSERT INTO stroy.address VALUES (3185, 'Олега Романова, 11', 42);
INSERT INTO stroy.address VALUES (3186, 'Германо, 47', 47);
INSERT INTO stroy.address VALUES (3187, 'Скобелевская, 24', 32);
INSERT INTO stroy.address VALUES (3188, 'Трубецкая, 22', 35);
INSERT INTO stroy.address VALUES (3189, 'Ошмарина, 2', 16);
INSERT INTO stroy.address VALUES (3190, 'Кетчерская, 23', 3);
INSERT INTO stroy.address VALUES (3191, '2-Я  Чапаева, 32', 45);
INSERT INTO stroy.address VALUES (3192, 'Наволокская, 26', 1);
INSERT INTO stroy.address VALUES (3193, 'Генерала Лукина, 3', 5);
INSERT INTO stroy.address VALUES (3194, 'Болховская, 48', 1);
INSERT INTO stroy.address VALUES (3195, 'Шоссейная, 97', 15);
INSERT INTO stroy.address VALUES (3196, 'Софьи Перовской, 48', 31);
INSERT INTO stroy.address VALUES (3197, 'Кустарная, 42', 40);
INSERT INTO stroy.address VALUES (3198, 'Соболева, 89', 26);
INSERT INTO stroy.address VALUES (3199, 'Рылеева, 87', 17);
INSERT INTO stroy.address VALUES (3200, 'Пайтерова, 77', 43);
INSERT INTO stroy.address VALUES (3201, 'Юрия Смирнова, 46', 38);
INSERT INTO stroy.address VALUES (3202, 'Маши Порываевой, 46', 42);
INSERT INTO stroy.address VALUES (3203, '2-Я  Чапаева, 70', 47);
INSERT INTO stroy.address VALUES (3204, 'Тарутинская, 34', 8);
INSERT INTO stroy.address VALUES (3205, 'Осташковская, 86', 1);
INSERT INTO stroy.address VALUES (3206, 'Ильи Хегая, 73', 30);
INSERT INTO stroy.address VALUES (3207, 'Академика Жукова, 5', 29);
INSERT INTO stroy.address VALUES (3208, 'Урочская, 18', 29);
INSERT INTO stroy.address VALUES (3209, 'Рогова, 54', 29);
INSERT INTO stroy.address VALUES (3210, '8 Марта, 44', 39);
INSERT INTO stroy.address VALUES (3211, 'Ананченко, 35', 20);
INSERT INTO stroy.address VALUES (3212, 'Поварская, 46', 6);
INSERT INTO stroy.address VALUES (3213, 'Передаточная, 16', 31);
INSERT INTO stroy.address VALUES (3214, 'Малых, 51', 1);
INSERT INTO stroy.address VALUES (3215, 'Моргунова, 21', 31);
INSERT INTO stroy.address VALUES (3216, 'Малая Тульская, 76', 14);
INSERT INTO stroy.address VALUES (3217, 'Спортивная, 14', 39);
INSERT INTO stroy.address VALUES (3218, 'Рокоссовского, 30', 30);
INSERT INTO stroy.address VALUES (3219, 'Достоевского, 49', 5);
INSERT INTO stroy.address VALUES (3220, 'Геологов, 88', 13);
INSERT INTO stroy.address VALUES (3221, 'Хуторская, 31', 27);
INSERT INTO stroy.address VALUES (3222, 'Павла Фитина, 42', 9);
INSERT INTO stroy.address VALUES (3223, 'Троицкая, 0', 41);
INSERT INTO stroy.address VALUES (3224, 'Селезнёва, 81', 26);
INSERT INTO stroy.address VALUES (3225, 'Панфилова, 64', 23);
INSERT INTO stroy.address VALUES (3226, 'Складочная, 22', 42);
INSERT INTO stroy.address VALUES (3227, 'Торговая, 76', 37);
INSERT INTO stroy.address VALUES (3228, 'Бессолова, 64', 35);
INSERT INTO stroy.address VALUES (3229, 'Ольховская, 46', 37);
INSERT INTO stroy.address VALUES (3230, 'Кустарная, 77', 46);
INSERT INTO stroy.address VALUES (3231, 'Бориса Галушкина, 14', 20);
INSERT INTO stroy.address VALUES (3232, 'Бровцева, 0', 35);
INSERT INTO stroy.address VALUES (3233, 'Заречная, 30', 34);
INSERT INTO stroy.address VALUES (3234, 'Вологодская, 46', 3);
INSERT INTO stroy.address VALUES (3235, 'Костычева, 75', 46);
INSERT INTO stroy.address VALUES (3236, 'Садовая-Кудринская, 78', 5);
INSERT INTO stroy.address VALUES (3237, 'Марьинская, 71', 23);
INSERT INTO stroy.address VALUES (3238, 'Зеленцовская, 39', 5);
INSERT INTO stroy.address VALUES (3239, '1-Я Лесная, 4', 10);
INSERT INTO stroy.address VALUES (3240, 'Борисовские Пруды, 60', 18);
INSERT INTO stroy.address VALUES (3241, 'Академика Сахарова, 63', 10);
INSERT INTO stroy.address VALUES (3242, 'Красный Маяк, 61', 19);
INSERT INTO stroy.address VALUES (3243, '6-Я Радиальная, 22', 20);
INSERT INTO stroy.address VALUES (3244, 'Еловая, 11', 1);
INSERT INTO stroy.address VALUES (3245, 'Новаторская, 88', 11);
INSERT INTO stroy.address VALUES (3246, 'Черепетская, 36', 15);
INSERT INTO stroy.address VALUES (3247, 'Аксёнова, 79', 37);
INSERT INTO stroy.address VALUES (3248, 'Высоковольтная, 6', 10);
INSERT INTO stroy.address VALUES (3249, 'Студёная Гора, 7', 42);
INSERT INTO stroy.address VALUES (3250, 'Донбасская, 32', 45);
INSERT INTO stroy.address VALUES (3251, 'Скотопрогонная, 72', 38);
INSERT INTO stroy.address VALUES (3252, 'Косухина, 13', 17);
INSERT INTO stroy.address VALUES (3253, 'Короленко, 39', 30);
INSERT INTO stroy.address VALUES (3254, 'Зарецкая, 28', 13);
INSERT INTO stroy.address VALUES (3255, 'Шлях, 79', 32);
INSERT INTO stroy.address VALUES (3256, '3-Я Южная, 71', 38);
INSERT INTO stroy.address VALUES (3257, 'Стройкова, 39', 30);
INSERT INTO stroy.address VALUES (3258, 'Медвежье, 59', 34);
INSERT INTO stroy.address VALUES (3259, 'Новотульская, 22', 31);
INSERT INTO stroy.address VALUES (3260, 'Зарецкая, 23', 30);
INSERT INTO stroy.address VALUES (3261, 'Некрасова, 57', 24);
INSERT INTO stroy.address VALUES (3262, 'Грайворонская, 77', 45);
INSERT INTO stroy.address VALUES (3263, 'Баумана, 95', 28);
INSERT INTO stroy.address VALUES (3264, '22-Го Съезда Кпсс, 29', 10);
INSERT INTO stroy.address VALUES (3265, 'Рябиновая, 98', 29);
INSERT INTO stroy.address VALUES (3266, 'Воротынская, 15', 18);
INSERT INTO stroy.address VALUES (3267, 'Трудовая, 47', 10);
INSERT INTO stroy.address VALUES (3268, '1-Я Рабочая, 37', 24);
INSERT INTO stroy.address VALUES (3269, 'Заборье, 97', 12);
INSERT INTO stroy.address VALUES (3270, 'Нестерова, 20', 5);
INSERT INTO stroy.address VALUES (3271, 'Горская, 14', 42);
INSERT INTO stroy.address VALUES (3272, 'Батова, 48', 21);
INSERT INTO stroy.address VALUES (3273, '22-Го Съезда Кпсс, 83', 20);
INSERT INTO stroy.address VALUES (3274, 'Пограничника Рыжикова, 42', 42);
INSERT INTO stroy.address VALUES (3275, 'Руставели, 62', 1);
INSERT INTO stroy.address VALUES (3276, '2-Я  Машиностроения, 73', 14);
INSERT INTO stroy.address VALUES (3277, 'Пушкарская, 6', 9);
INSERT INTO stroy.address VALUES (3278, 'Октябрьская, 16', 14);
INSERT INTO stroy.address VALUES (3279, 'Брестская, 10', 27);
INSERT INTO stroy.address VALUES (3280, 'Незымаева, 6', 39);
INSERT INTO stroy.address VALUES (3281, 'Карачевская, 89', 29);
INSERT INTO stroy.address VALUES (3282, 'Завокзальная, 28', 42);
INSERT INTO stroy.address VALUES (3283, 'Ремизова, 96', 21);
INSERT INTO stroy.address VALUES (3284, 'Баумана, 20', 2);
INSERT INTO stroy.address VALUES (3285, 'Хользунова, 94', 31);
INSERT INTO stroy.address VALUES (3286, 'Ивантеевская Ветка, 12', 18);
INSERT INTO stroy.address VALUES (3287, '20 Лет Победы, 90', 43);
INSERT INTO stroy.address VALUES (3288, '2-Я Газетная, 66', 37);
INSERT INTO stroy.address VALUES (3289, 'Стромынка, 71', 20);
INSERT INTO stroy.address VALUES (3290, 'Красный Октябрь, 73', 2);
INSERT INTO stroy.address VALUES (3291, 'Большая Дорога, 65', 37);
INSERT INTO stroy.address VALUES (3292, 'Семинарская, 58', 35);
INSERT INTO stroy.address VALUES (3293, 'Нагорная, 30', 8);
INSERT INTO stroy.address VALUES (3294, 'Курочкина, 49', 35);
INSERT INTO stroy.address VALUES (3295, 'Волковская, 38', 25);
INSERT INTO stroy.address VALUES (3296, 'Профсоюзов, 93', 15);
INSERT INTO stroy.address VALUES (3297, 'Юности, 30', 35);
INSERT INTO stroy.address VALUES (3298, 'Газина, 98', 6);
INSERT INTO stroy.address VALUES (3299, 'Ухтомского, 91', 5);
INSERT INTO stroy.address VALUES (3300, 'Главная, 56', 43);
INSERT INTO stroy.address VALUES (3301, 'Валентины Терешковой, 10', 5);
INSERT INTO stroy.address VALUES (3302, 'Скобелевская, 62', 27);
INSERT INTO stroy.address VALUES (3303, 'Антонова-Овсеенко, 48', 17);
INSERT INTO stroy.address VALUES (3304, '1-Я Курская, 48', 17);
INSERT INTO stroy.address VALUES (3305, 'Семашко, 38', 12);
INSERT INTO stroy.address VALUES (3306, 'Стройкова, 52', 5);
INSERT INTO stroy.address VALUES (3307, 'Лихославльская, 10', 38);
INSERT INTO stroy.address VALUES (3308, 'Воровского, 40', 41);
INSERT INTO stroy.address VALUES (3309, 'Красная, 40', 34);
INSERT INTO stroy.address VALUES (3310, 'Комсомольская, 13', 9);
INSERT INTO stroy.address VALUES (3311, 'Некоузская, 6', 35);
INSERT INTO stroy.address VALUES (3312, 'Бундурина, 26', 14);
INSERT INTO stroy.address VALUES (3313, 'Коломийца, 59', 5);
INSERT INTO stroy.address VALUES (3314, 'Ольховая, 77', 14);
INSERT INTO stroy.address VALUES (3315, 'Москворечье, 18', 24);
INSERT INTO stroy.address VALUES (3316, 'Суркова, 49', 34);
INSERT INTO stroy.address VALUES (3317, 'Новопеределкинская, 49', 6);
INSERT INTO stroy.address VALUES (3318, '2-Я Пролетарская, 75', 28);
INSERT INTO stroy.address VALUES (3319, 'Горняков, 3', 29);
INSERT INTO stroy.address VALUES (3320, '5-Я Завокзальная, 32', 15);
INSERT INTO stroy.address VALUES (3321, 'Большая Академическая, 44', 28);
INSERT INTO stroy.address VALUES (3322, 'Крымский Вал, 4', 12);
INSERT INTO stroy.address VALUES (3323, 'Измайлова, 49', 10);
INSERT INTO stroy.address VALUES (3324, 'Владимировка, 88', 12);
INSERT INTO stroy.address VALUES (3325, 'Рябикова, 22', 46);
INSERT INTO stroy.address VALUES (3326, 'Сельскохозяйственная, 16', 10);
INSERT INTO stroy.address VALUES (3327, 'Литвинова, 35', 3);
INSERT INTO stroy.address VALUES (3328, 'Агрохимиков, 35', 32);
INSERT INTO stroy.address VALUES (3329, 'Жаворонкова, 24', 27);
INSERT INTO stroy.address VALUES (3330, 'Юлиана Семёнова, 34', 44);
INSERT INTO stroy.address VALUES (3331, 'Каспийская, 85', 35);
INSERT INTO stroy.address VALUES (3332, 'Заборье, 33', 28);
INSERT INTO stroy.address VALUES (3333, 'Корольковой, 70', 40);
INSERT INTO stroy.address VALUES (3334, 'Малая Красноармейская, 64', 11);
INSERT INTO stroy.address VALUES (3335, 'Бирюсинка, 38', 38);
INSERT INTO stroy.address VALUES (3336, 'Ломакина, 24', 32);
INSERT INTO stroy.address VALUES (3337, 'Базаева, 98', 36);
INSERT INTO stroy.address VALUES (3338, 'Грайвороновская, 12', 12);
INSERT INTO stroy.address VALUES (3339, 'Шмидта, 68', 4);
INSERT INTO stroy.address VALUES (3340, 'Герасимова, 48', 10);
INSERT INTO stroy.address VALUES (3341, '2-Я  Чапаева, 33', 30);
INSERT INTO stroy.address VALUES (3342, 'Донская, 12', 46);
INSERT INTO stroy.address VALUES (3343, 'Баташевская, 73', 37);
INSERT INTO stroy.address VALUES (3344, 'Вахрушева, 17', 42);
INSERT INTO stroy.address VALUES (3345, 'Тимирязева, 79', 1);
INSERT INTO stroy.address VALUES (3346, 'Большая Никитская, 94', 10);
INSERT INTO stroy.address VALUES (3347, 'Сельскохозяйственная, 17', 17);
INSERT INTO stroy.address VALUES (3348, 'Металлургов, 44', 41);
INSERT INTO stroy.address VALUES (3349, 'Академика Скрябина, 34', 31);
INSERT INTO stroy.address VALUES (3350, 'Таллинская, 25', 1);
INSERT INTO stroy.address VALUES (3351, 'Наседкина, 32', 37);
INSERT INTO stroy.address VALUES (3352, 'Госпитальный Вал, 69', 42);
INSERT INTO stroy.address VALUES (3353, 'Шпалорезка, 27', 13);
INSERT INTO stroy.address VALUES (3354, 'Комсомольцев Танкистов, 52', 26);
INSERT INTO stroy.address VALUES (3355, 'Литейная, 72', 14);
INSERT INTO stroy.address VALUES (3356, 'Дубининская, 9', 2);
INSERT INTO stroy.address VALUES (3357, 'Станиславского, 49', 47);
INSERT INTO stroy.address VALUES (3358, 'Тракторная, 58', 34);
INSERT INTO stroy.address VALUES (3359, 'Верхняя Луговая, 95', 32);
INSERT INTO stroy.address VALUES (3360, '1-Я Комсомольская, 5', 46);
INSERT INTO stroy.address VALUES (3361, 'Мебельная, 25', 35);
INSERT INTO stroy.address VALUES (3362, '2-Я  За Линией Октябрьской Ж/Д, 64', 24);
INSERT INTO stroy.address VALUES (3363, 'Изыскателей, 71', 36);
INSERT INTO stroy.address VALUES (3364, '50 Лет Нлмк, 75', 27);
INSERT INTO stroy.address VALUES (3365, 'Кошкина, 11', 28);
INSERT INTO stroy.address VALUES (3366, 'Промышленная, 33', 39);
INSERT INTO stroy.address VALUES (3367, '20 Января, 6', 30);
INSERT INTO stroy.address VALUES (3368, 'Чернышёва, 91', 1);
INSERT INTO stroy.address VALUES (3369, 'Генерала Лизюкова, 66', 1);
INSERT INTO stroy.address VALUES (3370, 'Большая Чернавская, 79', 21);
INSERT INTO stroy.address VALUES (3371, 'Соболева, 6', 16);
INSERT INTO stroy.address VALUES (3372, 'Степная, 48', 10);
INSERT INTO stroy.address VALUES (3373, 'Жилинская, 48', 34);
INSERT INTO stroy.address VALUES (3374, 'Нижняя Радищевская, 13', 34);
INSERT INTO stroy.address VALUES (3375, 'Мопровская, 74', 21);
INSERT INTO stroy.address VALUES (3376, 'Путилина, 23', 6);
INSERT INTO stroy.address VALUES (3377, '3-Я Рейсовая, 75', 14);
INSERT INTO stroy.address VALUES (3378, 'Рязанская, 77', 23);
INSERT INTO stroy.address VALUES (3379, 'Щёголевых, 44', 22);
INSERT INTO stroy.address VALUES (3380, 'Трудовые Резервы, 19', 1);
INSERT INTO stroy.address VALUES (3381, '20 Января, 27', 36);
INSERT INTO stroy.address VALUES (3382, 'Богдановича, 50', 14);
INSERT INTO stroy.address VALUES (3383, 'Кардашова, 86', 22);
INSERT INTO stroy.address VALUES (3384, 'Артёмовская, 80', 45);
INSERT INTO stroy.address VALUES (3385, 'Матвеева, 32', 28);
INSERT INTO stroy.address VALUES (3386, 'Наумова, 8', 28);
INSERT INTO stroy.address VALUES (3387, 'Реформатского, 86', 37);
INSERT INTO stroy.address VALUES (3388, 'Торопецкая, 92', 2);
INSERT INTO stroy.address VALUES (3389, 'Пмк-10, 85', 41);
INSERT INTO stroy.address VALUES (3390, '100-Й Свирской Дивизии, 95', 1);
INSERT INTO stroy.address VALUES (3391, 'Петровка, 63', 22);
INSERT INTO stroy.address VALUES (3392, 'Мостовая, 32', 27);
INSERT INTO stroy.address VALUES (3393, 'Платонова, 85', 10);
INSERT INTO stroy.address VALUES (3394, 'Логвиненко, 59', 8);
INSERT INTO stroy.address VALUES (3395, 'Большая Павловская, 16', 8);
INSERT INTO stroy.address VALUES (3396, 'Грайвороновская, 5', 46);
INSERT INTO stroy.address VALUES (3397, '3-Я Нарвская, 1', 10);
INSERT INTO stroy.address VALUES (3398, 'Рязанская, 0', 7);
INSERT INTO stroy.address VALUES (3399, 'Шолохова, 2', 20);
INSERT INTO stroy.address VALUES (3400, 'Подгорная, 60', 40);
INSERT INTO stroy.address VALUES (3401, 'Флотская, 82', 9);
INSERT INTO stroy.address VALUES (3402, 'Ногинская, 87', 37);
INSERT INTO stroy.address VALUES (3403, 'Бирюзова, 10', 43);
INSERT INTO stroy.address VALUES (3404, 'Барышиха, 38', 39);
INSERT INTO stroy.address VALUES (3405, 'Егорова, 76', 9);
INSERT INTO stroy.address VALUES (3406, 'Люблинская, 87', 35);
INSERT INTO stroy.address VALUES (3407, 'Вертлинская, 61', 17);
INSERT INTO stroy.address VALUES (3408, 'Большая Нижегородская, 49', 28);
INSERT INTO stroy.address VALUES (3409, '2-Я Рабочая, 0', 38);
INSERT INTO stroy.address VALUES (3410, 'Мизерского, 54', 19);
INSERT INTO stroy.address VALUES (3411, 'Носкова, 62', 36);
INSERT INTO stroy.address VALUES (3412, 'Маршала Бирюзова, 45', 47);
INSERT INTO stroy.address VALUES (3413, 'Большевик, 24', 32);
INSERT INTO stroy.address VALUES (3414, 'Курочкина, 45', 20);
INSERT INTO stroy.address VALUES (3415, 'Мостостроевская, 26', 47);
INSERT INTO stroy.address VALUES (3416, 'Крупской, 73', 21);
INSERT INTO stroy.address VALUES (3417, 'Можайское Шоссе, Бородинская, 13', 13);
INSERT INTO stroy.address VALUES (3418, 'Марьинский Парк, 38', 11);
INSERT INTO stroy.address VALUES (3419, 'Новая Заря, 51', 36);
INSERT INTO stroy.address VALUES (3420, 'Ломакина, 67', 31);
INSERT INTO stroy.address VALUES (3421, 'Нормандия-Неман, 62', 15);
INSERT INTO stroy.address VALUES (3422, 'Жулябина, 2', 28);
INSERT INTO stroy.address VALUES (3423, '2-Я  Красина, 67', 29);
INSERT INTO stroy.address VALUES (3424, 'Воронежская, 49', 14);
INSERT INTO stroy.address VALUES (3425, 'Губкина, 13', 46);
INSERT INTO stroy.address VALUES (3426, 'Нариманова, 22', 22);
INSERT INTO stroy.address VALUES (3427, 'Пайтерова, 98', 46);
INSERT INTO stroy.address VALUES (3428, 'Лысенко, 49', 43);
INSERT INTO stroy.address VALUES (3429, 'Шмелькова, 96', 45);
INSERT INTO stroy.address VALUES (3430, '1-Я Елецкая, 97', 41);
INSERT INTO stroy.address VALUES (3431, 'Академика Доллежаля, 40', 38);
INSERT INTO stroy.address VALUES (3432, 'Понизовка, 33', 22);
INSERT INTO stroy.address VALUES (3433, 'Рябикова, 99', 1);
INSERT INTO stroy.address VALUES (3434, 'Зегеля, 22', 18);
INSERT INTO stroy.address VALUES (3435, 'Соловьёва, 80', 30);
INSERT INTO stroy.address VALUES (3436, 'Хлебная, 88', 24);
INSERT INTO stroy.address VALUES (3437, 'Крутовская, 54', 32);
INSERT INTO stroy.address VALUES (3438, 'Береговая, 29', 27);
INSERT INTO stroy.address VALUES (3439, 'Большое Васильево, 32', 38);
INSERT INTO stroy.address VALUES (3440, 'Лавочкина, 63', 46);
INSERT INTO stroy.address VALUES (3441, 'Капотня, 87', 3);
INSERT INTO stroy.address VALUES (3442, 'Бессолова, 56', 15);
INSERT INTO stroy.address VALUES (3443, 'Большая Еловая, 24', 17);
INSERT INTO stroy.address VALUES (3444, 'Подгорная, 66', 29);
INSERT INTO stroy.address VALUES (3445, 'Малахово, 21', 38);
INSERT INTO stroy.address VALUES (3446, 'Суржикова, 37', 10);
INSERT INTO stroy.address VALUES (3447, 'Транспортная, 58', 10);
INSERT INTO stroy.address VALUES (3448, 'Мопровская, 98', 43);
INSERT INTO stroy.address VALUES (3449, 'Клинский Родник, 11', 47);
INSERT INTO stroy.address VALUES (3450, 'Намёткина, 67', 12);
INSERT INTO stroy.address VALUES (3451, 'Желябова, 68', 26);
INSERT INTO stroy.address VALUES (3452, 'Фридриха Энгельса, 76', 16);
INSERT INTO stroy.address VALUES (3453, 'Мичурина, 2', 38);
INSERT INTO stroy.address VALUES (3454, 'Зимёнковская, 10', 36);
INSERT INTO stroy.address VALUES (3455, 'Олений Вал, 90', 23);
INSERT INTO stroy.address VALUES (3456, 'Малая Московская, 40', 13);
INSERT INTO stroy.address VALUES (3457, 'Чапаева, 29', 14);
INSERT INTO stroy.address VALUES (3458, 'Коминтерна, 42', 13);
INSERT INTO stroy.address VALUES (3459, 'Титова, 3', 20);
INSERT INTO stroy.address VALUES (3460, 'Богдана Хмельницкого, 64', 9);
INSERT INTO stroy.address VALUES (3461, '25 Лет Октября, 81', 47);
INSERT INTO stroy.address VALUES (3462, 'Ермака, 18', 36);
INSERT INTO stroy.address VALUES (3463, 'Луганская, 79', 15);
INSERT INTO stroy.address VALUES (3464, 'Звёздная, 28', 11);
INSERT INTO stroy.address VALUES (3465, 'Ломакина, 13', 19);
INSERT INTO stroy.address VALUES (3466, 'Академика Семёнова, 99', 38);
INSERT INTO stroy.address VALUES (3467, 'Карачижская, 46', 21);
INSERT INTO stroy.address VALUES (3468, 'Димитрова, 41', 15);
INSERT INTO stroy.address VALUES (3469, 'Галкина, 33', 28);
INSERT INTO stroy.address VALUES (3470, 'Лобачевского, 2', 3);
INSERT INTO stroy.address VALUES (3471, 'Смоленский Большак, 89', 29);
INSERT INTO stroy.address VALUES (3472, 'Прохоренкова, 94', 30);
INSERT INTO stroy.address VALUES (3473, 'Конструктора Гуськова, 55', 2);
INSERT INTO stroy.address VALUES (3474, 'Белгородская, 10', 22);
INSERT INTO stroy.address VALUES (3475, 'Праволинейная, 35', 6);
INSERT INTO stroy.address VALUES (3476, 'Стрелецкая, 54', 43);
INSERT INTO stroy.address VALUES (3477, 'Андреевка, 87', 40);
INSERT INTO stroy.address VALUES (3478, 'Николаевская, 40', 27);
INSERT INTO stroy.address VALUES (3479, 'Брусилова, 69', 27);
INSERT INTO stroy.address VALUES (3480, 'Лобачевского, 20', 4);
INSERT INTO stroy.address VALUES (3481, 'Мичуринская, 7', 10);
INSERT INTO stroy.address VALUES (3482, 'Нижняя Масловка, 96', 8);
INSERT INTO stroy.address VALUES (3483, 'Лескова, 34', 17);
INSERT INTO stroy.address VALUES (3484, 'Красная Слобода, 20', 14);
INSERT INTO stroy.address VALUES (3485, 'Гаврикова, 55', 39);
INSERT INTO stroy.address VALUES (3486, 'Марьинская, 34', 18);
INSERT INTO stroy.address VALUES (3487, 'Старобежецкая, 56', 31);
INSERT INTO stroy.address VALUES (3488, 'Широкая, 87', 42);
INSERT INTO stroy.address VALUES (3489, 'Талалихина, 66', 43);
INSERT INTO stroy.address VALUES (3490, 'Малая Свердловка, 65', 12);
INSERT INTO stroy.address VALUES (3491, 'Маршала Василевского, 68', 43);
INSERT INTO stroy.address VALUES (3492, 'Пронина, 56', 14);
INSERT INTO stroy.address VALUES (3493, 'Генерала Ермолова, 89', 9);
INSERT INTO stroy.address VALUES (3494, 'Платонова, 81', 20);
INSERT INTO stroy.address VALUES (3495, 'Нестерова, 91', 17);
INSERT INTO stroy.address VALUES (3496, 'Бабенко, 20', 35);
INSERT INTO stroy.address VALUES (3497, 'Южная, 87', 20);
INSERT INTO stroy.address VALUES (3498, 'Украинская, 7', 27);
INSERT INTO stroy.address VALUES (3499, 'Хавская, 84', 24);
INSERT INTO stroy.address VALUES (3500, 'Автомобильная, 47', 39);
INSERT INTO stroy.address VALUES (3501, 'Серова, 41', 24);
INSERT INTO stroy.address VALUES (3502, 'Панфилова, 93', 46);
INSERT INTO stroy.address VALUES (3503, 'Неделина, 79', 1);
INSERT INTO stroy.address VALUES (3504, 'Рябка, 98', 28);
INSERT INTO stroy.address VALUES (3505, 'Лысенко, 73', 2);
INSERT INTO stroy.address VALUES (3506, 'Электрификации, 10', 26);
INSERT INTO stroy.address VALUES (3507, 'Северная Советская, 15', 23);
INSERT INTO stroy.address VALUES (3508, 'Нижняя Слободка, 88', 21);
INSERT INTO stroy.address VALUES (3509, 'Комдива Орлова, 2', 3);
INSERT INTO stroy.address VALUES (3510, '2-Я Инженерная, 98', 36);
INSERT INTO stroy.address VALUES (3511, 'Ватутина, 9', 31);
INSERT INTO stroy.address VALUES (3512, 'Октябрьской Революции, 91', 3);
INSERT INTO stroy.address VALUES (3513, 'Петра Смидовича, 25', 36);
INSERT INTO stroy.address VALUES (3514, 'Осташковская, 12', 13);
INSERT INTO stroy.address VALUES (3515, 'Воронежская, 1', 21);
INSERT INTO stroy.address VALUES (3516, 'Ташкентская, 10', 4);
INSERT INTO stroy.address VALUES (3517, 'Кантемировская, 59', 34);
INSERT INTO stroy.address VALUES (3518, 'Агрохимиков, 30', 34);
INSERT INTO stroy.address VALUES (3519, 'Старомихневская, 100', 36);
INSERT INTO stroy.address VALUES (3520, '20 Лет Победы, 17', 18);
INSERT INTO stroy.address VALUES (3521, 'Мостостроевская, 52', 28);
INSERT INTO stroy.address VALUES (3522, 'Правды, 76', 44);
INSERT INTO stroy.address VALUES (3523, '11-Я Парковая, 0', 29);
INSERT INTO stroy.address VALUES (3524, 'Инициативная, 47', 4);
INSERT INTO stroy.address VALUES (3525, 'Зернова, 71', 30);
INSERT INTO stroy.address VALUES (3526, 'К. Маркса, 41', 14);
INSERT INTO stroy.address VALUES (3527, 'Новый Арбат, 30', 22);
INSERT INTO stroy.address VALUES (3528, 'Большая Садовая, 98', 7);
INSERT INTO stroy.address VALUES (3529, 'Теряевская, 69', 36);
INSERT INTO stroy.address VALUES (3530, 'Малая Тульская, 69', 37);
INSERT INTO stroy.address VALUES (3531, '40 Лет Влксм, 38', 17);
INSERT INTO stroy.address VALUES (3532, 'Шпалорезка, 50', 47);
INSERT INTO stroy.address VALUES (3533, 'Свободная, 53', 9);
INSERT INTO stroy.address VALUES (3534, 'Никиты Головни, 43', 10);
INSERT INTO stroy.address VALUES (3535, 'Гутина, 12', 29);
INSERT INTO stroy.address VALUES (3536, 'Октябрьской Революции, 22', 39);
INSERT INTO stroy.address VALUES (3537, 'Платонова, 75', 14);
INSERT INTO stroy.address VALUES (3538, 'Бундурина, 54', 4);
INSERT INTO stroy.address VALUES (3539, '2-Я  За Линией Октябрьской Ж/Д, 66', 18);
INSERT INTO stroy.address VALUES (3540, 'Островитянова, 85', 5);
INSERT INTO stroy.address VALUES (3541, 'Лавочкина, 61', 18);
INSERT INTO stroy.address VALUES (3542, 'Пансионатовская, 39', 21);
INSERT INTO stroy.address VALUES (3543, '1-Я Центральная, 29', 29);
INSERT INTO stroy.address VALUES (3544, '4-Я Южная, 47', 15);
INSERT INTO stroy.address VALUES (3545, 'Паровозная, 66', 4);
INSERT INTO stroy.address VALUES (3546, 'Октябрьская Площадь, 39', 15);
INSERT INTO stroy.address VALUES (3547, 'Коваленко, 58', 32);
INSERT INTO stroy.address VALUES (3548, 'Свердлова, 4', 43);
INSERT INTO stroy.address VALUES (3549, 'Просторная, 92', 24);
INSERT INTO stroy.address VALUES (3550, 'Большая Семёновская, 21', 10);
INSERT INTO stroy.address VALUES (3551, '26 Июня, 49', 29);
INSERT INTO stroy.address VALUES (3552, 'Новая Басманная, 2', 40);
INSERT INTO stroy.address VALUES (3553, '1-Я Рейсовая, 87', 18);
INSERT INTO stroy.address VALUES (3554, 'Генерала Калинина, 5', 41);
INSERT INTO stroy.address VALUES (3555, 'Крупешина, 77', 33);
INSERT INTO stroy.address VALUES (3556, 'Братская, 79', 31);
INSERT INTO stroy.address VALUES (3557, 'Суджанский Шлях, 86', 35);
INSERT INTO stroy.address VALUES (3558, 'Добровольцев Урала, 19', 44);
INSERT INTO stroy.address VALUES (3559, 'Фридриха Энгельса, 17', 47);
INSERT INTO stroy.address VALUES (3560, 'Краснопрудная, 49', 31);
INSERT INTO stroy.address VALUES (3561, 'Новоряжская, 47', 38);
INSERT INTO stroy.address VALUES (3562, 'Батарейная, 6', 14);
INSERT INTO stroy.address VALUES (3563, '1-Я Транспортная, 58', 42);
INSERT INTO stroy.address VALUES (3564, 'Ярцевская, 21', 26);
INSERT INTO stroy.address VALUES (3565, 'Веденеева, 67', 9);
INSERT INTO stroy.address VALUES (3566, 'Уссурийская, 19', 28);
INSERT INTO stroy.address VALUES (3567, 'Даниловская, 58', 14);
INSERT INTO stroy.address VALUES (3568, 'Большая Нижегородская, 75', 11);
INSERT INTO stroy.address VALUES (3569, 'Селижаровская, 10', 10);
INSERT INTO stroy.address VALUES (3570, 'Шереметовка, 60', 25);
INSERT INTO stroy.address VALUES (3571, 'Комиссарова, 8', 37);
INSERT INTO stroy.address VALUES (3572, 'Ольшанская, 11', 37);
INSERT INTO stroy.address VALUES (3573, 'Калининградская, 23', 13);
INSERT INTO stroy.address VALUES (3574, 'Салтыковская, 4', 45);
INSERT INTO stroy.address VALUES (3575, 'Торопецкая, 50', 26);
INSERT INTO stroy.address VALUES (3576, 'Новотульская, 61', 14);
INSERT INTO stroy.address VALUES (3577, 'Песчаная, 70', 19);
INSERT INTO stroy.address VALUES (3578, 'Комдива Орлова, 92', 40);
INSERT INTO stroy.address VALUES (3579, 'Ильича, 80', 13);
INSERT INTO stroy.address VALUES (3580, 'Минина, 95', 33);
INSERT INTO stroy.address VALUES (3581, 'Сарментовой, 79', 25);
INSERT INTO stroy.address VALUES (3582, 'Жуковская, 17', 30);
INSERT INTO stroy.address VALUES (3583, 'Мясищева, 100', 25);
INSERT INTO stroy.address VALUES (3584, '17-Й Стрелковой Дивизии, 72', 12);
INSERT INTO stroy.address VALUES (3585, 'Покровская, 86', 1);
INSERT INTO stroy.address VALUES (3586, 'Баха, 89', 39);
INSERT INTO stroy.address VALUES (3587, 'Кузьминская, 41', 28);
INSERT INTO stroy.address VALUES (3588, 'Левашова, 79', 16);
INSERT INTO stroy.address VALUES (3589, 'Фабрициуса, 68', 14);
INSERT INTO stroy.address VALUES (3590, 'Конюшковская, 76', 7);
INSERT INTO stroy.address VALUES (3591, 'Михаила Заботина, 26', 13);
INSERT INTO stroy.address VALUES (3592, 'Белгородской Сирени, 97', 40);
INSERT INTO stroy.address VALUES (3593, 'Геологов, 97', 4);
INSERT INTO stroy.address VALUES (3594, 'Программистов, 4', 45);
INSERT INTO stroy.address VALUES (3595, 'Руставели, 60', 35);
INSERT INTO stroy.address VALUES (3596, 'Ошмарина, 56', 35);
INSERT INTO stroy.address VALUES (3597, 'Шкадова, 58', 2);
INSERT INTO stroy.address VALUES (3598, 'Стадионная, 21', 28);
INSERT INTO stroy.address VALUES (3599, 'Большая Семёновская, 32', 41);
INSERT INTO stroy.address VALUES (3600, 'Хуторская, 91', 18);
INSERT INTO stroy.address VALUES (3601, 'Большая Павловская, 98', 17);
INSERT INTO stroy.address VALUES (3602, 'Большая Дорога, 79', 38);
INSERT INTO stroy.address VALUES (3603, 'Кооперативная, 86', 6);
INSERT INTO stroy.address VALUES (3604, 'Льва Толстого, 16', 24);
INSERT INTO stroy.address VALUES (3605, 'Брянская, 19', 11);
INSERT INTO stroy.address VALUES (3606, 'Ельнинская, 24', 4);
INSERT INTO stroy.address VALUES (3607, 'Электрификации, 91', 43);
INSERT INTO stroy.address VALUES (3608, 'Им. М.Горького, 37', 22);
INSERT INTO stroy.address VALUES (3609, 'Ельнинская, 26', 16);
INSERT INTO stroy.address VALUES (3610, 'Дубиновка, 12', 45);
INSERT INTO stroy.address VALUES (3611, 'Пограничника Рыжикова, 62', 42);
INSERT INTO stroy.address VALUES (3612, '1-Я  Фрунзе, 44', 11);
INSERT INTO stroy.address VALUES (3613, 'Марата, 84', 27);
INSERT INTO stroy.address VALUES (3614, 'Фестивальная, 52', 4);
INSERT INTO stroy.address VALUES (3615, 'Брестская, 48', 42);
INSERT INTO stroy.address VALUES (3616, 'Фестивальная, 84', 39);
INSERT INTO stroy.address VALUES (3617, 'Маршала Новикова, 96', 17);
INSERT INTO stroy.address VALUES (3618, 'Капотня, 64', 15);
INSERT INTO stroy.address VALUES (3619, 'Игнатьевская, 92', 5);
INSERT INTO stroy.address VALUES (3620, 'Ново-Солдатская, 51', 15);
INSERT INTO stroy.address VALUES (3621, 'Воинов-Интернационалистов, 81', 16);
INSERT INTO stroy.address VALUES (3622, 'Бусловского, 44', 10);
INSERT INTO stroy.address VALUES (3623, 'Ставропольская, 28', 10);
INSERT INTO stroy.address VALUES (3624, 'Шереметьевская, 66', 3);
INSERT INTO stroy.address VALUES (3625, 'Понизовка, 65', 37);
INSERT INTO stroy.address VALUES (3626, 'Алмазная, 42', 8);
INSERT INTO stroy.address VALUES (3627, 'Поселковая, 13', 38);
INSERT INTO stroy.address VALUES (3628, 'Красный Октябрь, 72', 20);
INSERT INTO stroy.address VALUES (3629, 'Горбуновская, 77', 2);
INSERT INTO stroy.address VALUES (3630, 'Нестерова, 69', 34);
INSERT INTO stroy.address VALUES (3631, 'Фокина, 36', 29);
INSERT INTO stroy.address VALUES (3632, 'Городянка, 44', 45);
INSERT INTO stroy.address VALUES (3633, 'Ильюшина, 88', 17);
INSERT INTO stroy.address VALUES (3634, 'Дейнеки, 28', 35);
INSERT INTO stroy.address VALUES (3635, 'Ляшенко, 86', 45);
INSERT INTO stroy.address VALUES (3636, 'Генерала Хлебникова, 81', 36);
INSERT INTO stroy.address VALUES (3637, 'Бахаровка, 84', 2);
INSERT INTO stroy.address VALUES (3638, 'Тёплый Стан, 0', 33);
INSERT INTO stroy.address VALUES (3639, '12 Лет Октября, 11', 38);
INSERT INTO stroy.address VALUES (3640, 'Лермонтова, 75', 11);
INSERT INTO stroy.address VALUES (3641, 'Огородная, 33', 27);
INSERT INTO stroy.address VALUES (3642, 'Крупешина, 24', 14);
INSERT INTO stroy.address VALUES (3643, 'Петра I, 43', 42);
INSERT INTO stroy.address VALUES (3644, 'Каменка, 27', 1);
INSERT INTO stroy.address VALUES (3645, 'Новосёлки-Слободка, 68', 22);
INSERT INTO stroy.address VALUES (3646, 'Валентиновская, 74', 36);
INSERT INTO stroy.address VALUES (3647, 'Севрюкова, 10', 17);
INSERT INTO stroy.address VALUES (3648, 'Митинская, 34', 14);
INSERT INTO stroy.address VALUES (3649, '1-Я Красная, 58', 8);
INSERT INTO stroy.address VALUES (3650, 'Туполева, 100', 36);
INSERT INTO stroy.address VALUES (3651, 'Николаевская, 84', 41);
INSERT INTO stroy.address VALUES (3652, 'Правды, 68', 42);
INSERT INTO stroy.address VALUES (3653, 'Сергея Эйзенштейна, 25', 40);
INSERT INTO stroy.address VALUES (3654, 'Прянишникова, 77', 46);
INSERT INTO stroy.address VALUES (3655, 'Академика Скрябина, 35', 19);
INSERT INTO stroy.address VALUES (3656, 'Воробьёвка, 73', 34);
INSERT INTO stroy.address VALUES (3657, 'Онежская, 83', 25);
INSERT INTO stroy.address VALUES (3658, 'Программистов, 27', 19);
INSERT INTO stroy.address VALUES (3659, 'Калинникова, 52', 17);
INSERT INTO stroy.address VALUES (3660, 'Озеро, 55', 46);
INSERT INTO stroy.address VALUES (3661, 'Растопчина, 41', 30);
INSERT INTO stroy.address VALUES (3662, 'Знаменка, 96', 17);
INSERT INTO stroy.address VALUES (3663, 'Алексеевская, 91', 34);
INSERT INTO stroy.address VALUES (3664, 'Алексеевская, 64', 35);
INSERT INTO stroy.address VALUES (3665, 'Железнякова, 2', 30);
INSERT INTO stroy.address VALUES (3666, 'Секиотовская, 35', 41);
INSERT INTO stroy.address VALUES (3667, 'Селезнёва, 76', 21);
INSERT INTO stroy.address VALUES (3668, 'Большевиков, 76', 15);
INSERT INTO stroy.address VALUES (3669, 'Малаховского, 5', 29);
INSERT INTO stroy.address VALUES (3670, 'Каменка, 40', 32);
INSERT INTO stroy.address VALUES (3671, 'Звёздная, 43', 44);
INSERT INTO stroy.address VALUES (3672, 'Ф.Энгельса, 73', 45);
INSERT INTO stroy.address VALUES (3673, 'Бебеля, 54', 12);
INSERT INTO stroy.address VALUES (3674, 'Русаковская, 0', 28);
INSERT INTO stroy.address VALUES (3675, 'Центрльная, 61', 41);
INSERT INTO stroy.address VALUES (3676, 'Щенина, 25', 2);
INSERT INTO stroy.address VALUES (3677, 'Тевосяна, 42', 41);
INSERT INTO stroy.address VALUES (3678, 'Энтузиастов, 42', 26);
INSERT INTO stroy.address VALUES (3679, 'Каховского, 26', 27);
INSERT INTO stroy.address VALUES (3680, 'Партизанская, 96', 25);
INSERT INTO stroy.address VALUES (3681, 'В. Большак, 10', 6);
INSERT INTO stroy.address VALUES (3682, 'Тюрина, 86', 42);
INSERT INTO stroy.address VALUES (3683, 'Тёплый Стан, 83', 24);
INSERT INTO stroy.address VALUES (3684, 'Пушкарная, 35', 23);
INSERT INTO stroy.address VALUES (3685, 'Юных Ленинцев, 14', 38);
INSERT INTO stroy.address VALUES (3686, 'Ткацкая, 53', 28);
INSERT INTO stroy.address VALUES (3687, 'Гоголя, 20', 19);
INSERT INTO stroy.address VALUES (3688, 'Бякова, 25', 47);
INSERT INTO stroy.address VALUES (3689, 'Братьев Федоровых, 34', 33);
INSERT INTO stroy.address VALUES (3690, 'Юрия Беленогова, 92', 38);
INSERT INTO stroy.address VALUES (3691, 'Ватутина, 6', 20);
INSERT INTO stroy.address VALUES (3692, 'Новая Башиловка, 92', 32);
INSERT INTO stroy.address VALUES (3693, 'Говорова, 40', 29);
INSERT INTO stroy.address VALUES (3694, 'Пеше-Стрелецкая, 13', 47);
INSERT INTO stroy.address VALUES (3695, 'Александровская, 56', 40);
INSERT INTO stroy.address VALUES (3696, 'Добрынина, 16', 29);
INSERT INTO stroy.address VALUES (3697, 'Тоновка, 40', 31);
INSERT INTO stroy.address VALUES (3698, 'Городская Дорога, 37', 19);
INSERT INTO stroy.address VALUES (3699, '2-Я Заводская, 32', 1);
INSERT INTO stroy.address VALUES (3700, 'Литейная, 64', 34);
INSERT INTO stroy.address VALUES (3701, 'Зиновьева, 7', 21);
INSERT INTO stroy.address VALUES (3702, 'Полка Нормандия-Неман, 62', 4);
INSERT INTO stroy.address VALUES (3703, 'Болдырева, 10', 18);
INSERT INTO stroy.address VALUES (3704, 'Резиновая, 43', 28);
INSERT INTO stroy.address VALUES (3705, 'Академика Пилюгина, 48', 43);
INSERT INTO stroy.address VALUES (3706, 'Бурденко, 95', 41);
INSERT INTO stroy.address VALUES (3707, 'Совхозная, 38', 34);
INSERT INTO stroy.address VALUES (3708, 'Лобачёва, 73', 13);
INSERT INTO stroy.address VALUES (3709, 'Мархлевского, 38', 27);
INSERT INTO stroy.address VALUES (3710, 'Генерала Белобородова, 28', 36);
INSERT INTO stroy.address VALUES (3711, 'Матросовская, 63', 47);
INSERT INTO stroy.address VALUES (3712, 'Чкалова, 85', 14);
INSERT INTO stroy.address VALUES (3713, 'Менжинского, 77', 45);
INSERT INTO stroy.address VALUES (3714, '2-Я  Красина, 79', 33);
INSERT INTO stroy.address VALUES (3715, 'Кузьминская, 98', 3);
INSERT INTO stroy.address VALUES (3716, 'Бежецкая, 33', 32);
INSERT INTO stroy.address VALUES (3717, 'Набережная, 32', 34);
INSERT INTO stroy.address VALUES (3718, 'Локомотивная, 9', 18);
INSERT INTO stroy.address VALUES (3719, 'Трубникова, 89', 36);
INSERT INTO stroy.address VALUES (3720, 'Благоева, 35', 8);
INSERT INTO stroy.address VALUES (3721, '3-Я Нарвская, 64', 28);
INSERT INTO stroy.address VALUES (3722, 'Щёлокова, 7', 35);
INSERT INTO stroy.address VALUES (3723, 'Мичуринская, 5', 47);
INSERT INTO stroy.address VALUES (3724, 'Троицкая, 34', 47);
INSERT INTO stroy.address VALUES (3725, 'Дейнеки, 68', 19);
INSERT INTO stroy.address VALUES (3726, 'Зелёны Шум, 67', 47);
INSERT INTO stroy.address VALUES (3727, 'Грейдерная, 3', 41);
INSERT INTO stroy.address VALUES (3728, 'Дубовой Рощи, 58', 34);
INSERT INTO stroy.address VALUES (3729, 'Боровская, 53', 14);
INSERT INTO stroy.address VALUES (3730, 'Троицкая, 18', 12);
INSERT INTO stroy.address VALUES (3731, 'Нефтяников, 98', 3);
INSERT INTO stroy.address VALUES (3732, 'Старомихневская, 20', 2);
INSERT INTO stroy.address VALUES (3733, 'Комдива Орлова, 70', 2);
INSERT INTO stroy.address VALUES (3734, 'Декабристов, 46', 44);
INSERT INTO stroy.address VALUES (3735, 'Соколово-Мещерская, 84', 41);
INSERT INTO stroy.address VALUES (3736, 'Алмазная, 39', 2);
INSERT INTO stroy.address VALUES (3737, 'Ленинградская Дамба, 70', 37);
INSERT INTO stroy.address VALUES (3738, 'Добролюбова, 52', 24);
INSERT INTO stroy.address VALUES (3739, 'Задонская, 67', 21);
INSERT INTO stroy.address VALUES (3740, 'Оборонная, 2', 10);
INSERT INTO stroy.address VALUES (3741, 'Екатерины Зеленко, 62', 25);
INSERT INTO stroy.address VALUES (3742, 'Можайского, 8', 1);
INSERT INTO stroy.address VALUES (3743, 'К. Маркса, 22', 20);
INSERT INTO stroy.address VALUES (3744, 'Большая Шуйская, 23', 29);
INSERT INTO stroy.address VALUES (3745, 'Олега Кошевого, 41', 12);
INSERT INTO stroy.address VALUES (3746, 'Белгородская, 66', 16);
INSERT INTO stroy.address VALUES (3747, 'Растопчина, 68', 21);
INSERT INTO stroy.address VALUES (3748, 'Липецкая, 86', 10);
INSERT INTO stroy.address VALUES (3749, 'Лебеденко, 51', 14);
INSERT INTO stroy.address VALUES (3750, 'Ани Гайтеровой, 81', 33);
INSERT INTO stroy.address VALUES (3751, 'И. Е. Стырина, 95', 1);
INSERT INTO stroy.address VALUES (3752, 'Зои И Александра Космодемьянских, 94', 9);
INSERT INTO stroy.address VALUES (3753, 'Ляшко, 44', 21);
INSERT INTO stroy.address VALUES (3754, 'Хуторская, 67', 47);
INSERT INTO stroy.address VALUES (3755, 'Нововерховенская, 78', 45);
INSERT INTO stroy.address VALUES (3756, '1-Я Брестская, 43', 23);
INSERT INTO stroy.address VALUES (3757, 'Новосёлки-Слободка, 58', 33);
INSERT INTO stroy.address VALUES (3758, 'Самойловой, 15', 42);
INSERT INTO stroy.address VALUES (3759, 'Сокольнический Вал, 76', 27);
INSERT INTO stroy.address VALUES (3760, 'Коровий Вал, 6', 35);
INSERT INTO stroy.address VALUES (3761, 'Московская, 91', 42);
INSERT INTO stroy.address VALUES (3762, 'Аузина, 51', 37);
INSERT INTO stroy.address VALUES (3763, 'Моторная, 79', 22);
INSERT INTO stroy.address VALUES (3764, 'Петропавловская, 95', 28);
INSERT INTO stroy.address VALUES (3765, 'Бурова, 22', 3);
INSERT INTO stroy.address VALUES (3766, 'Карачевская, 46', 32);
INSERT INTO stroy.address VALUES (3767, 'Берникова, 12', 5);
INSERT INTO stroy.address VALUES (3768, 'Белгородской Сирени, 62', 43);
INSERT INTO stroy.address VALUES (3769, 'Калинина, 35', 7);
INSERT INTO stroy.address VALUES (3770, 'Новомосковская, 100', 37);
INSERT INTO stroy.address VALUES (3771, 'Нижняя Казацкая, 67', 11);
INSERT INTO stroy.address VALUES (3772, 'Таганская, 59', 20);
INSERT INTO stroy.address VALUES (3773, 'Семёна Середы, 13', 34);
INSERT INTO stroy.address VALUES (3774, 'Куконковых, 1', 31);
INSERT INTO stroy.address VALUES (3775, 'Гагарина, 67', 1);
INSERT INTO stroy.address VALUES (3776, 'Академическая, 45', 1);
INSERT INTO stroy.address VALUES (3777, 'Капотня, 88', 27);
INSERT INTO stroy.address VALUES (3778, 'Краснопрудная, 79', 23);
INSERT INTO stroy.address VALUES (3779, '1-Я Тверская-Ямская, 65', 29);
INSERT INTO stroy.address VALUES (3780, 'Поварская, 98', 29);
INSERT INTO stroy.address VALUES (3781, 'Реформатского, 42', 11);
INSERT INTO stroy.address VALUES (3782, 'Шоссейная, 22', 28);
INSERT INTO stroy.address VALUES (3783, 'Ярославская, 55', 3);
INSERT INTO stroy.address VALUES (3784, 'Мастеркова, 99', 8);
INSERT INTO stroy.address VALUES (3785, 'Александровка, 43', 4);
INSERT INTO stroy.address VALUES (3786, 'Ленина, 67', 23);
INSERT INTO stroy.address VALUES (3787, 'Тенишевой, 30', 39);
INSERT INTO stroy.address VALUES (3788, 'Нижняя Дебря, 68', 38);
INSERT INTO stroy.address VALUES (3789, 'Гоголя, 24', 5);
INSERT INTO stroy.address VALUES (3790, 'Брянского Фронта, 56', 36);
INSERT INTO stroy.address VALUES (3791, 'Профсоюзов, 41', 34);
INSERT INTO stroy.address VALUES (3792, 'Верхняя Луговая, 98', 7);
INSERT INTO stroy.address VALUES (3793, 'Ерошенко, 20', 25);
INSERT INTO stroy.address VALUES (3794, 'Тарасовская, 44', 9);
INSERT INTO stroy.address VALUES (3795, 'Красная, 67', 35);
INSERT INTO stroy.address VALUES (3796, 'Рыбинская, 56', 15);
INSERT INTO stroy.address VALUES (3797, 'Федотовская, 67', 19);
INSERT INTO stroy.address VALUES (3798, 'Харьковская, 14', 34);
INSERT INTO stroy.address VALUES (3799, 'Михалковская, 100', 29);
INSERT INTO stroy.address VALUES (3800, 'Секиотовская, 61', 19);
INSERT INTO stroy.address VALUES (3801, '1-Я Центральная, 90', 1);
INSERT INTO stroy.address VALUES (3802, 'Пушкарская, 60', 42);
INSERT INTO stroy.address VALUES (3803, 'Суджанский Шлях, 52', 2);
INSERT INTO stroy.address VALUES (3804, 'Транзитная, 52', 22);
INSERT INTO stroy.address VALUES (3805, 'Мытная, 29', 31);
INSERT INTO stroy.address VALUES (3806, 'Большая Ордынка, 41', 2);
INSERT INTO stroy.address VALUES (3807, 'Зареченская, 38', 4);
INSERT INTO stroy.address VALUES (3808, 'Западная, 17', 12);
INSERT INTO stroy.address VALUES (3809, 'Тамбовская, 59', 42);
INSERT INTO stroy.address VALUES (3810, 'Телевизионная, 75', 19);
INSERT INTO stroy.address VALUES (3811, 'Мичуринская, 8', 22);
INSERT INTO stroy.address VALUES (3812, 'Генерала Ермолова, 32', 34);
INSERT INTO stroy.address VALUES (3813, 'Ясеневая, 93', 11);
INSERT INTO stroy.address VALUES (3814, '2-Я Агрономическая, 72', 36);
INSERT INTO stroy.address VALUES (3815, 'Черепанова, 83', 4);
INSERT INTO stroy.address VALUES (3816, 'Алексея Бутенко, 21', 45);
INSERT INTO stroy.address VALUES (3817, 'Вермишева, 84', 22);
INSERT INTO stroy.address VALUES (3818, 'Дорофеичева, 88', 41);
INSERT INTO stroy.address VALUES (3819, 'Верхняя Луговая, 31', 43);
INSERT INTO stroy.address VALUES (3820, 'Энгельса, 79', 14);
INSERT INTO stroy.address VALUES (3821, 'Некоузская, 0', 10);
INSERT INTO stroy.address VALUES (3822, '45-Й Стрелковой Дивизии, 0', 9);
INSERT INTO stroy.address VALUES (3823, 'Большая Лубянка, 2', 17);
INSERT INTO stroy.address VALUES (3824, 'Дубининская, 51', 26);
INSERT INTO stroy.address VALUES (3825, 'Нижегородская, 10', 14);
INSERT INTO stroy.address VALUES (3826, 'Главная, 76', 1);
INSERT INTO stroy.address VALUES (3827, 'Ливенская, 75', 1);
INSERT INTO stroy.address VALUES (3828, 'Череповецкая, 95', 33);
INSERT INTO stroy.address VALUES (3829, 'Братская, 72', 13);
INSERT INTO stroy.address VALUES (3830, 'Даниловский Вал, 86', 34);
INSERT INTO stroy.address VALUES (3831, '9 Мая, 32', 47);
INSERT INTO stroy.address VALUES (3832, 'Воротынская, 34', 31);
INSERT INTO stroy.address VALUES (3833, 'Садовая-Каретная, 21', 16);
INSERT INTO stroy.address VALUES (3834, 'Малая Свердловка, 13', 21);
INSERT INTO stroy.address VALUES (3835, '1-Я Кожевенная, 65', 8);
INSERT INTO stroy.address VALUES (3836, 'Приборостроительная, 73', 35);
INSERT INTO stroy.address VALUES (3837, 'Звёздная, 65', 3);
INSERT INTO stroy.address VALUES (3838, 'Новицкого, 52', 47);
INSERT INTO stroy.address VALUES (3839, 'Индустриальная, 12', 8);
INSERT INTO stroy.address VALUES (3840, 'Еловая, 73', 17);
INSERT INTO stroy.address VALUES (3841, 'Осташковская, 40', 34);
INSERT INTO stroy.address VALUES (3842, 'Вернисажная, 10', 37);
INSERT INTO stroy.address VALUES (3843, 'Фомушина, 13', 15);
INSERT INTO stroy.address VALUES (3844, 'Серпуховский Вал, 24', 23);
INSERT INTO stroy.address VALUES (3845, 'Шуйская, 74', 19);
INSERT INTO stroy.address VALUES (3846, 'Академика Семёнова, 84', 22);
INSERT INTO stroy.address VALUES (3847, 'Голикова, 75', 10);
INSERT INTO stroy.address VALUES (3848, 'Ртс, 83', 26);
INSERT INTO stroy.address VALUES (3849, 'Верхняя Масловка, 4', 6);
INSERT INTO stroy.address VALUES (3850, 'Рабочих, 46', 3);
INSERT INTO stroy.address VALUES (3851, 'Дуки, 38', 10);
INSERT INTO stroy.address VALUES (3852, 'Советов, 98', 32);
INSERT INTO stroy.address VALUES (3853, 'Маршала Ерёменко, 54', 42);
INSERT INTO stroy.address VALUES (3854, 'Василия Фабричнова, 19', 24);
INSERT INTO stroy.address VALUES (3855, 'Люлина, 1', 29);
INSERT INTO stroy.address VALUES (3856, 'Белёвская, 92', 9);
INSERT INTO stroy.address VALUES (3857, 'Василия Петушкова, 20', 32);
INSERT INTO stroy.address VALUES (3858, 'Им. М.Горького, 67', 19);
INSERT INTO stroy.address VALUES (3859, 'Пристанционная, 88', 31);
INSERT INTO stroy.address VALUES (3860, 'Орловская, 70', 27);
INSERT INTO stroy.address VALUES (3861, 'Куликова, 52', 11);
INSERT INTO stroy.address VALUES (3862, 'Малиновый Овраг, 76', 24);
INSERT INTO stroy.address VALUES (3863, 'Скотопрогонная, 73', 14);
INSERT INTO stroy.address VALUES (3864, 'Большая Еловая, 30', 1);
INSERT INTO stroy.address VALUES (3865, 'Амбулаторная, 67', 29);
INSERT INTO stroy.address VALUES (3866, 'Подстанция, 75', 40);
INSERT INTO stroy.address VALUES (3867, 'Григория Соколова, 57', 34);
INSERT INTO stroy.address VALUES (3868, 'Малая Московская, 34', 29);
INSERT INTO stroy.address VALUES (3869, 'Митинская, 45', 22);
INSERT INTO stroy.address VALUES (3870, 'Королёва, 82', 45);
INSERT INTO stroy.address VALUES (3871, 'Расковой, 43', 26);
INSERT INTO stroy.address VALUES (3872, '1-Я Московская, 94', 6);
INSERT INTO stroy.address VALUES (3873, 'Днепровская, 66', 29);
INSERT INTO stroy.address VALUES (3874, 'Октябрьская, 87', 28);
INSERT INTO stroy.address VALUES (3875, 'Просторная, 21', 43);
INSERT INTO stroy.address VALUES (3876, 'Ждамировская, 72', 10);
INSERT INTO stroy.address VALUES (3877, 'Гурьянова, 75', 9);
INSERT INTO stroy.address VALUES (3878, 'Климовская, 99', 38);
INSERT INTO stroy.address VALUES (3879, '1-Я Рабочая, 23', 7);
INSERT INTO stroy.address VALUES (3880, 'Ганны Шостак, 7', 9);
INSERT INTO stroy.address VALUES (3881, 'Белавинская, 61', 28);
INSERT INTO stroy.address VALUES (3882, '3 Интернационала, 94', 31);
INSERT INTO stroy.address VALUES (3883, 'Большая Серпуховская, 43', 44);
INSERT INTO stroy.address VALUES (3884, '1-Я Больничная, 33', 31);
INSERT INTO stroy.address VALUES (3885, '60 Лет Октября, 29', 42);
INSERT INTO stroy.address VALUES (3886, '1-Я Железнодорожная, 15', 39);
INSERT INTO stroy.address VALUES (3887, 'Сталеваров, 72', 27);
INSERT INTO stroy.address VALUES (3888, 'Садовая-Кудринская, 64', 31);
INSERT INTO stroy.address VALUES (3889, 'Крюковка, 53', 2);
INSERT INTO stroy.address VALUES (3890, 'Богдановича, 95', 15);
INSERT INTO stroy.address VALUES (3891, 'Энгельса, 3', 27);
INSERT INTO stroy.address VALUES (3892, 'Вельяминова, 67', 34);
INSERT INTO stroy.address VALUES (3893, '1-Я Рейсовая, 85', 25);
INSERT INTO stroy.address VALUES (3894, 'Усиевича, 24', 43);
INSERT INTO stroy.address VALUES (3895, 'Белгородского Полка, 88', 24);
INSERT INTO stroy.address VALUES (3896, 'Крюкова, 42', 30);
INSERT INTO stroy.address VALUES (3897, '12 Лет Октября, 75', 29);
INSERT INTO stroy.address VALUES (3898, 'Баха, 74', 43);
INSERT INTO stroy.address VALUES (3899, 'Голикова, 31', 16);
INSERT INTO stroy.address VALUES (3900, 'Пенькозаводская, 15', 30);
INSERT INTO stroy.address VALUES (3901, 'Новомосковская, 97', 43);
INSERT INTO stroy.address VALUES (3902, 'Суздальская, 10', 9);
INSERT INTO stroy.address VALUES (3903, 'Белореченская, 54', 31);
INSERT INTO stroy.address VALUES (3904, 'Поэта Лебедева, 20', 2);
INSERT INTO stroy.address VALUES (3905, 'Чижова, 95', 39);
INSERT INTO stroy.address VALUES (3906, 'Малахово, 22', 21);
INSERT INTO stroy.address VALUES (3907, 'Нижняя Радищевская, 7', 27);
INSERT INTO stroy.address VALUES (3908, 'Большая Переяславская, 40', 5);
INSERT INTO stroy.address VALUES (3909, 'Верховская, 61', 12);
INSERT INTO stroy.address VALUES (3910, 'Россошанская, 16', 24);
INSERT INTO stroy.address VALUES (3911, 'Чоботовская, 6', 10);
INSERT INTO stroy.address VALUES (3912, 'Маресьева, 80', 15);
INSERT INTO stroy.address VALUES (3913, 'Егорьевская, 99', 21);
INSERT INTO stroy.address VALUES (3914, '1-Я Вокзальная, 10', 7);
INSERT INTO stroy.address VALUES (3915, 'Мебельная, 53', 19);
INSERT INTO stroy.address VALUES (3916, 'Хабаровская, 82', 8);
INSERT INTO stroy.address VALUES (3917, 'Ольховая, 91', 1);
INSERT INTO stroy.address VALUES (3918, 'Добрынина, 93', 1);
INSERT INTO stroy.address VALUES (3919, 'Черновицкая, 100', 29);
INSERT INTO stroy.address VALUES (3920, 'Хрустальная, 66', 45);
INSERT INTO stroy.address VALUES (3921, 'Олега Романова, 57', 43);
INSERT INTO stroy.address VALUES (3922, 'Красная Горка, 29', 43);
INSERT INTO stroy.address VALUES (3923, 'Наговицыной-Икрянистовой, 68', 36);
INSERT INTO stroy.address VALUES (3924, '2-Я Железнодорожная, 92', 7);
INSERT INTO stroy.address VALUES (3925, 'Комсомольцев Танкистов, 98', 9);
INSERT INTO stroy.address VALUES (3926, 'Савина, 38', 15);
INSERT INTO stroy.address VALUES (3927, 'К. Маркса, 80', 33);
INSERT INTO stroy.address VALUES (3928, 'Праволинейная, 69', 35);
INSERT INTO stroy.address VALUES (3929, 'Лётчика Осканова, 64', 27);
INSERT INTO stroy.address VALUES (3930, 'Вилиса Лациса, 47', 4);
INSERT INTO stroy.address VALUES (3931, 'Ушинского, 22', 45);
INSERT INTO stroy.address VALUES (3932, 'Стародубская, 73', 11);
INSERT INTO stroy.address VALUES (3933, 'Большая Черёмушкинская, 23', 15);
INSERT INTO stroy.address VALUES (3934, 'Кашинская, 74', 22);
INSERT INTO stroy.address VALUES (3935, 'Гутина, 19', 34);
INSERT INTO stroy.address VALUES (3936, '3-Го Интернационала, 38', 2);
INSERT INTO stroy.address VALUES (3937, 'Маршала Новикова, 80', 13);
INSERT INTO stroy.address VALUES (3938, 'Тарана, 47', 35);
INSERT INTO stroy.address VALUES (3939, 'Суржикова, 89', 38);
INSERT INTO stroy.address VALUES (3940, 'Вертолётчиков, 41', 33);
INSERT INTO stroy.address VALUES (3941, 'Маршала Прошлякова, 61', 2);
INSERT INTO stroy.address VALUES (3942, 'Городковская, 22', 24);
INSERT INTO stroy.address VALUES (3943, 'Марксистская, 55', 46);
INSERT INTO stroy.address VALUES (3944, 'Им. Островского, 33', 30);
INSERT INTO stroy.address VALUES (3945, 'Горняков, 26', 35);
INSERT INTO stroy.address VALUES (3946, 'Чайковского, 36', 9);
INSERT INTO stroy.address VALUES (3947, 'Киово, 25', 16);
INSERT INTO stroy.address VALUES (3948, 'Мамаев Проток, 68', 30);
INSERT INTO stroy.address VALUES (3949, 'Лихарево, 98', 41);
INSERT INTO stroy.address VALUES (3950, 'Лежневская, 68', 26);
INSERT INTO stroy.address VALUES (3951, 'Клары Цеткин, 66', 11);
INSERT INTO stroy.address VALUES (3952, 'Рябка, 43', 9);
INSERT INTO stroy.address VALUES (3953, 'Центрльная, 8', 25);
INSERT INTO stroy.address VALUES (3954, 'Строительная, 61', 26);
INSERT INTO stroy.address VALUES (3955, 'Большая Фурмановская, 70', 6);
INSERT INTO stroy.address VALUES (3956, 'Стопани, 85', 43);
INSERT INTO stroy.address VALUES (3957, 'Дубровинского, 20', 25);
INSERT INTO stroy.address VALUES (3958, 'Шевелюха, 29', 27);
INSERT INTO stroy.address VALUES (3959, 'Осенняя, 35', 14);
INSERT INTO stroy.address VALUES (3960, 'Им. А.И.Калинина, 70', 33);
INSERT INTO stroy.address VALUES (3961, 'Лескова, 45', 27);
INSERT INTO stroy.address VALUES (3962, 'Стадионная, 22', 36);
INSERT INTO stroy.address VALUES (3963, 'Туполева, 4', 7);
INSERT INTO stroy.address VALUES (3964, 'Бякова, 70', 28);
INSERT INTO stroy.address VALUES (3965, 'Маршала Воробьёва, 75', 33);
INSERT INTO stroy.address VALUES (3966, 'Нагорная, 91', 23);
INSERT INTO stroy.address VALUES (3967, 'Бероунская, 20', 40);
INSERT INTO stroy.address VALUES (3968, '1-Я  Ленстрой, 35', 35);
INSERT INTO stroy.address VALUES (3969, 'Симанова, 56', 30);
INSERT INTO stroy.address VALUES (3970, 'Каретный Ряд, 77', 9);
INSERT INTO stroy.address VALUES (3971, 'Пучковка, 98', 12);
INSERT INTO stroy.address VALUES (3972, 'Ломакина, 41', 43);
INSERT INTO stroy.address VALUES (3973, 'Болховская, 52', 20);
INSERT INTO stroy.address VALUES (3974, '1-Е Пушкари, 70', 24);
INSERT INTO stroy.address VALUES (3975, 'Рокоссовского, 38', 21);
INSERT INTO stroy.address VALUES (3976, 'Алексея Ракитина, 2', 17);
INSERT INTO stroy.address VALUES (3977, '1-Я  Вагонников, 75', 33);
INSERT INTO stroy.address VALUES (3978, 'Большак, 68', 14);
INSERT INTO stroy.address VALUES (3979, 'Лютинская, 64', 23);
INSERT INTO stroy.address VALUES (3980, 'Ульяновская, 49', 14);
INSERT INTO stroy.address VALUES (3981, 'Луханина, 97', 28);
INSERT INTO stroy.address VALUES (3982, 'Липецкая, 8', 28);
INSERT INTO stroy.address VALUES (3983, 'Прибрежная, 80', 43);
INSERT INTO stroy.address VALUES (3984, 'Никитина, 82', 22);
INSERT INTO stroy.address VALUES (3985, 'Елецкая, 34', 5);
INSERT INTO stroy.address VALUES (3986, 'Валаамская, 97', 32);
INSERT INTO stroy.address VALUES (3987, 'Ижорская, 49', 14);
INSERT INTO stroy.address VALUES (3988, 'Баррикадная, 68', 1);
INSERT INTO stroy.address VALUES (3989, 'Войстроченко А.Ф., 22', 21);
INSERT INTO stroy.address VALUES (3990, '11 Сапёров, 52', 33);
INSERT INTO stroy.address VALUES (3991, 'Подлесье, 70', 6);
INSERT INTO stroy.address VALUES (3992, 'Заломова, 54', 7);
INSERT INTO stroy.address VALUES (3993, 'Николоямская, 69', 11);
INSERT INTO stroy.address VALUES (3994, 'Тверская, 77', 34);
INSERT INTO stroy.address VALUES (3995, 'Бартеневская, 34', 13);
INSERT INTO stroy.address VALUES (3996, 'Николоямская, 17', 40);
INSERT INTO stroy.address VALUES (3997, '9-Я Парковая, 23', 40);
INSERT INTO stroy.address VALUES (3998, 'Тесакова, 60', 29);
INSERT INTO stroy.address VALUES (3999, 'Осенняя, 20', 1);
INSERT INTO stroy.address VALUES (4000, 'Рощинская, 92', 46);
INSERT INTO stroy.address VALUES (4001, 'Старицкая, 26', 43);
INSERT INTO stroy.address VALUES (4002, '5-Я Южная, 22', 36);
INSERT INTO stroy.address VALUES (4003, 'Нефёдова, 45', 35);
INSERT INTO stroy.address VALUES (4004, '706-Го Продотряда, 34', 6);
INSERT INTO stroy.address VALUES (4005, 'Северной Правды, 56', 21);
INSERT INTO stroy.address VALUES (4006, 'Электрозаводская, 84', 33);
INSERT INTO stroy.address VALUES (4007, 'Мосфильмовская, 99', 25);
INSERT INTO stroy.address VALUES (4008, 'Нахаевская, 97', 9);
INSERT INTO stroy.address VALUES (4009, 'Ракитянская, 100', 1);
INSERT INTO stroy.address VALUES (4010, 'Валентины Терешковой, 28', 8);
INSERT INTO stroy.address VALUES (4011, '1-Я Елецкая, 52', 4);
INSERT INTO stroy.address VALUES (4012, 'Большая, 1', 28);
INSERT INTO stroy.address VALUES (4013, 'Александра Невского, 33', 10);
INSERT INTO stroy.address VALUES (4014, 'Гранатная, 61', 4);
INSERT INTO stroy.address VALUES (4015, '45-Й Стрелковой Дивизии, 13', 24);
INSERT INTO stroy.address VALUES (4016, 'Садовая, 27', 29);
INSERT INTO stroy.address VALUES (4017, 'Шпалорезка, 100', 8);
INSERT INTO stroy.address VALUES (4018, 'Беломорская, 82', 45);
INSERT INTO stroy.address VALUES (4019, '2-Я  Машиностроения, 39', 14);
INSERT INTO stroy.address VALUES (4020, 'Горчакова, 80', 2);
INSERT INTO stroy.address VALUES (4021, 'Зацепский Вал, 81', 38);
INSERT INTO stroy.address VALUES (4022, 'Народная, 41', 46);
INSERT INTO stroy.address VALUES (4023, 'Маршала Катукова, 48', 13);
INSERT INTO stroy.address VALUES (4024, 'Лихославльская, 68', 18);
INSERT INTO stroy.address VALUES (4025, 'Белгородского Полка, 10', 26);
INSERT INTO stroy.address VALUES (4026, '1-Я Садовая, 41', 20);
INSERT INTO stroy.address VALUES (4027, 'Орудовская, 58', 16);
INSERT INTO stroy.address VALUES (4028, 'Южно-Моравская, 54', 25);
INSERT INTO stroy.address VALUES (4029, 'Охотный Ряд, 85', 21);
INSERT INTO stroy.address VALUES (4030, 'Кашинская, 43', 36);
INSERT INTO stroy.address VALUES (4031, 'Сосновая, 76', 32);
INSERT INTO stroy.address VALUES (4032, 'Коммуны Герольд, 42', 4);
INSERT INTO stroy.address VALUES (4033, 'Галкина, 61', 8);
INSERT INTO stroy.address VALUES (4034, 'Старообрядческая, 83', 31);
INSERT INTO stroy.address VALUES (4035, 'Ташкентская, 60', 33);
INSERT INTO stroy.address VALUES (4036, 'Нормандия-Неман, 21', 26);
INSERT INTO stroy.address VALUES (4037, 'Прибрежная, 35', 3);
INSERT INTO stroy.address VALUES (4038, 'Щенина, 83', 46);
INSERT INTO stroy.address VALUES (4039, 'Боровская, 15', 22);
INSERT INTO stroy.address VALUES (4040, 'Неделина, 63', 22);
INSERT INTO stroy.address VALUES (4041, 'Сутормина, 27', 8);
INSERT INTO stroy.address VALUES (4042, 'Ильюшина, 95', 7);
INSERT INTO stroy.address VALUES (4043, 'Горького, 69', 6);
INSERT INTO stroy.address VALUES (4044, 'Свердлова, 96', 41);
INSERT INTO stroy.address VALUES (4045, 'Липаткина, 33', 36);
INSERT INTO stroy.address VALUES (4046, 'Новицкого, 45', 13);
INSERT INTO stroy.address VALUES (4047, 'Ладыженского, 69', 40);
INSERT INTO stroy.address VALUES (4048, 'Ромодановские Дворики, 61', 24);
INSERT INTO stroy.address VALUES (4049, 'Старомихневская, 3', 8);
INSERT INTO stroy.address VALUES (4050, 'Белинского, 13', 23);
INSERT INTO stroy.address VALUES (4051, 'Благоева, 42', 12);
INSERT INTO stroy.address VALUES (4052, 'Голикова, 79', 9);
INSERT INTO stroy.address VALUES (4053, 'Глебовская, 92', 31);
INSERT INTO stroy.address VALUES (4054, 'Солнцева, 48', 7);
INSERT INTO stroy.address VALUES (4055, 'Студенческая, 25', 1);
INSERT INTO stroy.address VALUES (4056, 'Братиславская, 19', 11);
INSERT INTO stroy.address VALUES (4057, 'Юности, 71', 38);
INSERT INTO stroy.address VALUES (4058, 'Кардовского, 68', 6);
INSERT INTO stroy.address VALUES (4059, 'Амет-Хан Султана, 79', 43);
INSERT INTO stroy.address VALUES (4060, 'Горняцкая, 52', 11);
INSERT INTO stroy.address VALUES (4061, 'Крылатская, 31', 21);
INSERT INTO stroy.address VALUES (4062, 'Городянка, 4', 19);
INSERT INTO stroy.address VALUES (4063, 'Складочная, 29', 11);
INSERT INTO stroy.address VALUES (4064, 'Лазарева, 81', 43);
INSERT INTO stroy.address VALUES (4065, 'Лебедева, 37', 29);
INSERT INTO stroy.address VALUES (4066, 'Садовая-Триумфальная  (Дублёр), 92', 5);
INSERT INTO stroy.address VALUES (4067, 'Большая Воскресенская, 41', 33);
INSERT INTO stroy.address VALUES (4068, 'Славнова, 14', 35);
INSERT INTO stroy.address VALUES (4069, 'Салтыкова-Щедрина, 2', 3);
INSERT INTO stroy.address VALUES (4070, 'Республиканская, 80', 40);
INSERT INTO stroy.address VALUES (4071, 'Кожедуба, 54', 18);
INSERT INTO stroy.address VALUES (4072, 'Большая, 50', 24);
INSERT INTO stroy.address VALUES (4073, 'Геологов, 90', 24);
INSERT INTO stroy.address VALUES (4074, 'Кольцовская, 64', 32);
INSERT INTO stroy.address VALUES (4075, 'Некрасова, 17', 11);
INSERT INTO stroy.address VALUES (4076, 'Ляшенко, 18', 42);
INSERT INTO stroy.address VALUES (4077, 'Большеволжская, 28', 40);
INSERT INTO stroy.address VALUES (4078, 'Старые Сосенки, 42', 22);
INSERT INTO stroy.address VALUES (4079, 'Хользунова, 4', 28);
INSERT INTO stroy.address VALUES (4080, '3-Я Магистральная, 6', 33);
INSERT INTO stroy.address VALUES (4081, 'Городковская, 56', 30);
INSERT INTO stroy.address VALUES (4082, 'Мустая Карима, 9', 2);
INSERT INTO stroy.address VALUES (4083, 'Охотный Ряд, 65', 33);
INSERT INTO stroy.address VALUES (4084, 'Жилая, 36', 17);
INSERT INTO stroy.address VALUES (4085, 'Самотёчная, 57', 8);
INSERT INTO stroy.address VALUES (4086, 'Главная, 26', 28);
INSERT INTO stroy.address VALUES (4087, 'Большая Семёновская, 22', 3);
INSERT INTO stroy.address VALUES (4088, 'Костычева, 54', 39);
INSERT INTO stroy.address VALUES (4089, 'Севрюкова, 62', 32);
INSERT INTO stroy.address VALUES (4090, 'Соборная, 34', 16);
INSERT INTO stroy.address VALUES (4091, 'Академическая, 83', 40);
INSERT INTO stroy.address VALUES (4092, 'Иловайская, 45', 36);
INSERT INTO stroy.address VALUES (4093, 'Бакунина, 32', 13);
INSERT INTO stroy.address VALUES (4094, 'Алабушевская, 42', 20);
INSERT INTO stroy.address VALUES (4095, 'Айвазовского, 87', 25);
INSERT INTO stroy.address VALUES (4096, 'Скобелевская, 27', 12);
INSERT INTO stroy.address VALUES (4097, 'Марии Рябининой, 13', 13);
INSERT INTO stroy.address VALUES (4098, 'Севрюкова, 46', 45);
INSERT INTO stroy.address VALUES (4099, 'Пригородная, 99', 35);
INSERT INTO stroy.address VALUES (4100, 'Волгоградская, 72', 1);
INSERT INTO stroy.address VALUES (4101, 'Василия Фабричнова, 62', 3);
INSERT INTO stroy.address VALUES (4102, 'Вялковская, 73', 26);
INSERT INTO stroy.address VALUES (4103, 'Волжская, 59', 45);
INSERT INTO stroy.address VALUES (4104, 'Генерала Трубникова, 46', 13);
INSERT INTO stroy.address VALUES (4105, 'Колганова, 23', 41);
INSERT INTO stroy.address VALUES (4106, 'Загородняя, 77', 4);
INSERT INTO stroy.address VALUES (4107, 'Дмитриевская, 33', 9);
INSERT INTO stroy.address VALUES (4108, 'Воронцово Поле, 36', 5);
INSERT INTO stroy.address VALUES (4109, 'Круговая, 52', 7);
INSERT INTO stroy.address VALUES (4110, '3-Я Рейсовая, 8', 8);
INSERT INTO stroy.address VALUES (4111, 'Стрелецкая, 5', 29);
INSERT INTO stroy.address VALUES (4112, '5-Я Южная, 95', 42);
INSERT INTO stroy.address VALUES (4113, 'Косыгина, 91', 24);
INSERT INTO stroy.address VALUES (4114, 'Незымаева, 58', 5);
INSERT INTO stroy.address VALUES (4115, 'Новоалександровская, 76', 43);
INSERT INTO stroy.address VALUES (4116, '1-Я Отрадная, 55', 47);
INSERT INTO stroy.address VALUES (4117, 'Фокина, 84', 8);
INSERT INTO stroy.address VALUES (4118, 'Раменки, 72', 7);
INSERT INTO stroy.address VALUES (4119, 'Бородинская, 0', 17);
INSERT INTO stroy.address VALUES (4120, 'Петрозаводская, 82', 47);
INSERT INTO stroy.address VALUES (4121, 'Аргамаченская, 24', 37);
INSERT INTO stroy.address VALUES (4122, 'Мадонская, 38', 4);
INSERT INTO stroy.address VALUES (4123, 'Василия Петрова, 34', 13);
INSERT INTO stroy.address VALUES (4124, 'Комиссара Московского, 21', 40);
INSERT INTO stroy.address VALUES (4125, 'Сущёвский Вал (Дублёр), 12', 22);
INSERT INTO stroy.address VALUES (4126, 'Депутатская, 79', 16);
INSERT INTO stroy.address VALUES (4127, 'Курчатова, 93', 21);
INSERT INTO stroy.address VALUES (4128, 'Раевского, 53', 11);
INSERT INTO stroy.address VALUES (4129, 'Взлётная, 83', 1);
INSERT INTO stroy.address VALUES (4130, 'Олега Кошевого, 10', 8);
INSERT INTO stroy.address VALUES (4131, 'Смольная, 87', 30);
INSERT INTO stroy.address VALUES (4132, 'Макарьевская, 7', 8);
INSERT INTO stroy.address VALUES (4133, 'Дубравная, 6', 33);
INSERT INTO stroy.address VALUES (4134, 'Литейная, 33', 19);
INSERT INTO stroy.address VALUES (4135, '2-Я  Новосёловка, 25', 33);
INSERT INTO stroy.address VALUES (4136, 'Гарская, 95', 25);
INSERT INTO stroy.address VALUES (4137, 'Лобачевского, 80', 26);
INSERT INTO stroy.address VALUES (4138, 'Тюменская, 60', 28);
INSERT INTO stroy.address VALUES (4139, 'Зелёный Шум, 93', 26);
INSERT INTO stroy.address VALUES (4140, 'Старицкая, 7', 3);
INSERT INTO stroy.address VALUES (4141, 'Калужская, 55', 29);
INSERT INTO stroy.address VALUES (4142, 'Голубкова, 64', 4);
INSERT INTO stroy.address VALUES (4143, 'Хромова, 27', 41);
INSERT INTO stroy.address VALUES (4144, 'Большая Полянка, 26', 10);
INSERT INTO stroy.address VALUES (4145, 'Нижние Поля, 68', 11);
INSERT INTO stroy.address VALUES (4146, 'Николоямская, 38', 14);
INSERT INTO stroy.address VALUES (4147, '22-Го Съезда Кпсс, 43', 45);
INSERT INTO stroy.address VALUES (4148, '2-Я  Мичурина, 69', 18);
INSERT INTO stroy.address VALUES (4149, 'Березняка, 1', 34);
INSERT INTO stroy.address VALUES (4150, '1-Я  Фрунзе, 3', 13);
INSERT INTO stroy.address VALUES (4151, 'Курловская, 33', 19);
INSERT INTO stroy.address VALUES (4152, 'Героев Панфиловцев, 80', 43);
INSERT INTO stroy.address VALUES (4153, 'Большая Октябрьская, 75', 24);
INSERT INTO stroy.address VALUES (4154, 'Новобутовская, 38', 10);
INSERT INTO stroy.address VALUES (4155, 'Коммунаров, 77', 11);
INSERT INTO stroy.address VALUES (4156, 'Красный Маяк, 100', 8);
INSERT INTO stroy.address VALUES (4157, 'Сельхозтехника, 9', 20);
INSERT INTO stroy.address VALUES (4158, 'Постышева, 24', 10);
INSERT INTO stroy.address VALUES (4159, 'Айвазовского, 67', 8);
INSERT INTO stroy.address VALUES (4160, 'Заволжская, 70', 32);
INSERT INTO stroy.address VALUES (4161, 'Мирная, 73', 7);
INSERT INTO stroy.address VALUES (4162, 'Геническая, 10', 27);
INSERT INTO stroy.address VALUES (4163, 'Пески Набережные, 66', 35);
INSERT INTO stroy.address VALUES (4164, 'Саранская, 14', 38);
INSERT INTO stroy.address VALUES (4165, 'Ртс, 99', 42);
INSERT INTO stroy.address VALUES (4166, 'Шахтёра, 23', 16);
INSERT INTO stroy.address VALUES (4167, 'Пехотная, 64', 16);
INSERT INTO stroy.address VALUES (4168, 'Фурманова, 56', 29);
INSERT INTO stroy.address VALUES (4169, 'Фёдора Полетаева, 17', 47);
INSERT INTO stroy.address VALUES (4170, 'Князева, 49', 32);
INSERT INTO stroy.address VALUES (4171, 'Войнова, 90', 32);
INSERT INTO stroy.address VALUES (4172, 'Обручева, 57', 27);
INSERT INTO stroy.address VALUES (4173, 'Пименовка, 8', 2);
INSERT INTO stroy.address VALUES (4174, 'Пограничника Рыжикова, 88', 46);
INSERT INTO stroy.address VALUES (4175, 'Нахаевская, 59', 10);
INSERT INTO stroy.address VALUES (4176, 'Николая Птицына, 92', 1);
INSERT INTO stroy.address VALUES (4177, 'Приборостроительная, 94', 12);
INSERT INTO stroy.address VALUES (4178, 'Кубинка, 31', 16);
INSERT INTO stroy.address VALUES (4179, 'Краснооктябрьская, 12', 7);
INSERT INTO stroy.address VALUES (4180, '5-Я Завокзальная, 46', 17);
INSERT INTO stroy.address VALUES (4181, 'Пески Набережные, 90', 37);
INSERT INTO stroy.address VALUES (4182, 'Депутатская, 68', 11);
INSERT INTO stroy.address VALUES (4183, '70 Лет Октября, 88', 24);
INSERT INTO stroy.address VALUES (4184, 'Госпитальная, 63', 45);
INSERT INTO stroy.address VALUES (4185, '1-Я Курская, 6', 34);
INSERT INTO stroy.address VALUES (4186, 'Исаева, 9', 40);
INSERT INTO stroy.address VALUES (4187, 'Рябка, 23', 45);
INSERT INTO stroy.address VALUES (4188, '800-Летия Москвы, 27', 36);
INSERT INTO stroy.address VALUES (4189, 'Люблинская, 99', 19);
INSERT INTO stroy.address VALUES (4190, 'Шестагинская, 29', 45);
INSERT INTO stroy.address VALUES (4191, 'Терешковой, 88', 28);
INSERT INTO stroy.address VALUES (4192, 'Стройкова, 68', 28);
INSERT INTO stroy.address VALUES (4193, 'Октябрьской Революции, 99', 2);
INSERT INTO stroy.address VALUES (4194, 'Вернова, 20', 26);
INSERT INTO stroy.address VALUES (4195, 'Степанова, 4', 26);
INSERT INTO stroy.address VALUES (4196, 'Алмазная, 52', 19);
INSERT INTO stroy.address VALUES (4197, 'Мичурина, 74', 36);
INSERT INTO stroy.address VALUES (4198, 'Садовая, 51', 24);
INSERT INTO stroy.address VALUES (4199, 'Спирина, 62', 4);
INSERT INTO stroy.address VALUES (4200, 'Баканова, 57', 27);
INSERT INTO stroy.address VALUES (4201, 'Большая Тульская, 61', 39);
INSERT INTO stroy.address VALUES (4202, 'Скачковская, 73', 41);
INSERT INTO stroy.address VALUES (4203, 'Красных Партизан, 80', 38);
INSERT INTO stroy.address VALUES (4204, '2-Я Рабочая, 86', 24);
INSERT INTO stroy.address VALUES (4205, 'Газина, 11', 13);
INSERT INTO stroy.address VALUES (4206, 'Никитина, 60', 8);
INSERT INTO stroy.address VALUES (4207, 'Высоковольтная, 21', 16);
INSERT INTO stroy.address VALUES (4208, 'Тоновка, 53', 23);
INSERT INTO stroy.address VALUES (4209, 'Лопатинская, 84', 22);
INSERT INTO stroy.address VALUES (4210, 'Реформатского, 18', 38);
INSERT INTO stroy.address VALUES (4211, '1-Е Пушкари, 65', 26);
INSERT INTO stroy.address VALUES (4212, 'Сентюрёва, 52', 43);
INSERT INTO stroy.address VALUES (4213, 'Новая Заря, 38', 35);
INSERT INTO stroy.address VALUES (4214, 'Заброденская, 96', 45);
INSERT INTO stroy.address VALUES (4215, 'Магистральная, 64', 41);
INSERT INTO stroy.address VALUES (4216, 'Академика Скрябина, 51', 5);
INSERT INTO stroy.address VALUES (4217, 'Тесакова, 37', 2);
INSERT INTO stroy.address VALUES (4218, 'Степана Шутова, 38', 29);
INSERT INTO stroy.address VALUES (4219, '9-Й Гвардейской Дивизии, 65', 44);
INSERT INTO stroy.address VALUES (4220, 'Ярцевская, 53', 16);
INSERT INTO stroy.address VALUES (4221, 'Жулябина, 82', 29);
INSERT INTO stroy.address VALUES (4222, 'Станко, 89', 3);
INSERT INTO stroy.address VALUES (4223, 'Луханина, 78', 34);
INSERT INTO stroy.address VALUES (4224, 'Болдина, 60', 43);
INSERT INTO stroy.address VALUES (4225, 'Богатырский Мост, 25', 22);
INSERT INTO stroy.address VALUES (4226, 'Малахово, 99', 8);
INSERT INTO stroy.address VALUES (4227, 'Дирижабельная, 42', 12);
INSERT INTO stroy.address VALUES (4228, 'Севская, 78', 2);
INSERT INTO stroy.address VALUES (4229, 'Шуйская, 3', 5);
INSERT INTO stroy.address VALUES (4230, 'Гагарина, 82', 38);
INSERT INTO stroy.address VALUES (4231, 'Фрязевская, 26', 13);
INSERT INTO stroy.address VALUES (4232, 'Карачижская, 90', 47);
INSERT INTO stroy.address VALUES (4233, 'Большая Филёвская, 50', 26);
INSERT INTO stroy.address VALUES (4234, '1-Я Пролетарская, 31', 37);
INSERT INTO stroy.address VALUES (4235, 'Круговая, 90', 15);
INSERT INTO stroy.address VALUES (4236, 'Белавинская, 60', 31);
INSERT INTO stroy.address VALUES (4237, 'Большая Садовая, 7', 39);
INSERT INTO stroy.address VALUES (4238, 'Инициативная, 61', 15);
INSERT INTO stroy.address VALUES (4239, '2-Я Московская, 41', 2);
INSERT INTO stroy.address VALUES (4240, 'Расторгуева, 34', 21);
INSERT INTO stroy.address VALUES (4241, 'Малая Лубянка, 75', 19);
INSERT INTO stroy.address VALUES (4242, 'Новоленинская, 44', 17);
INSERT INTO stroy.address VALUES (4243, '26-Ти Бакинских Комиссаров, 60', 40);
INSERT INTO stroy.address VALUES (4244, '2-Я  Верхний Волок, 3', 3);
INSERT INTO stroy.address VALUES (4245, 'Олега Романова, 99', 18);
INSERT INTO stroy.address VALUES (4246, 'Сталеваров, 20', 24);
INSERT INTO stroy.address VALUES (4247, 'Новослободская, 12', 12);
INSERT INTO stroy.address VALUES (4248, 'Клинский Родник, 42', 13);
INSERT INTO stroy.address VALUES (4249, 'Ольховская, 97', 43);
INSERT INTO stroy.address VALUES (4250, 'Черепетская, 71', 17);
INSERT INTO stroy.address VALUES (4251, 'Сенная, 51', 41);
INSERT INTO stroy.address VALUES (4252, 'Лавицкого, 23', 4);
INSERT INTO stroy.address VALUES (4253, 'Профессиональная, 75', 14);
INSERT INTO stroy.address VALUES (4254, 'Пайтерова, 65', 25);
INSERT INTO stroy.address VALUES (4255, 'Щербаковская, 25', 23);
INSERT INTO stroy.address VALUES (4256, 'Журавлёва, 60', 13);
INSERT INTO stroy.address VALUES (4257, 'Им. М.Горького, 88', 6);
INSERT INTO stroy.address VALUES (4258, 'Окружная, 32', 16);
INSERT INTO stroy.address VALUES (4259, 'Череповецкая, 71', 3);
INSERT INTO stroy.address VALUES (4260, 'Ботаническая, 73', 35);
INSERT INTO stroy.address VALUES (4261, 'В.В.Терешковой, 57', 19);
INSERT INTO stroy.address VALUES (4262, 'Красная Печать, 16', 31);
INSERT INTO stroy.address VALUES (4263, 'Маршала Василевского, 17', 19);
INSERT INTO stroy.address VALUES (4264, 'Рошаля, 41', 1);
INSERT INTO stroy.address VALUES (4265, 'Зои Космодемьянской, 99', 14);
INSERT INTO stroy.address VALUES (4266, 'Крымская, 58', 14);
INSERT INTO stroy.address VALUES (4267, 'Барышиха, 36', 11);
INSERT INTO stroy.address VALUES (4268, 'Левашова, 62', 19);
INSERT INTO stroy.address VALUES (4269, 'Рязанская, 19', 16);
INSERT INTO stroy.address VALUES (4270, 'Металлургов, 79', 29);
INSERT INTO stroy.address VALUES (4271, 'Подазовская, 58', 26);
INSERT INTO stroy.address VALUES (4272, 'Бякова, 54', 42);
INSERT INTO stroy.address VALUES (4273, 'Рябиновая, 63', 13);
INSERT INTO stroy.address VALUES (4274, 'Авдеева, 24', 30);
INSERT INTO stroy.address VALUES (4275, 'Выездная, 12', 31);
INSERT INTO stroy.address VALUES (4276, '1-Е Пушкари, 38', 43);
INSERT INTO stroy.address VALUES (4277, 'Мещёрская, 33', 22);
INSERT INTO stroy.address VALUES (4278, 'Липчанского, 56', 27);
INSERT INTO stroy.address VALUES (4279, 'Ермака, 1', 21);
INSERT INTO stroy.address VALUES (4280, 'Пайтерова, 58', 16);
INSERT INTO stroy.address VALUES (4281, 'Патриаршая, 73', 29);
INSERT INTO stroy.address VALUES (4282, 'Ани Гайтеровой, 49', 8);
INSERT INTO stroy.address VALUES (4283, 'Автодорожная, 98', 3);
INSERT INTO stroy.address VALUES (4284, 'Матросова, 64', 21);
INSERT INTO stroy.address VALUES (4285, 'Городнянского, 88', 7);
INSERT INTO stroy.address VALUES (4286, 'Зои Космодемьянской, 97', 33);
INSERT INTO stroy.address VALUES (4287, 'Пароходная, 86', 13);
INSERT INTO stroy.address VALUES (4288, 'Учительская, 72', 20);
INSERT INTO stroy.address VALUES (4289, 'Текстильщиков, 20', 10);
INSERT INTO stroy.address VALUES (4290, 'Куусинена, 56', 31);
INSERT INTO stroy.address VALUES (4291, '1-Я Дубровская, 46', 28);
INSERT INTO stroy.address VALUES (4292, 'Коминтерна, 59', 5);
INSERT INTO stroy.address VALUES (4293, 'Абельмановская, 9', 7);
INSERT INTO stroy.address VALUES (4294, 'Большая Стромынка, 14', 31);
INSERT INTO stroy.address VALUES (4295, 'Красноармейская, 70', 35);
INSERT INTO stroy.address VALUES (4296, 'Геологов, 55', 24);
INSERT INTO stroy.address VALUES (4297, 'Лютинская, 28', 35);
INSERT INTO stroy.address VALUES (4298, 'Наседкина, 10', 25);
INSERT INTO stroy.address VALUES (4299, '3-Го Интернационала, 69', 40);
INSERT INTO stroy.address VALUES (4300, 'Тенишевой, 24', 34);
INSERT INTO stroy.address VALUES (4301, 'Т, 49', 30);
INSERT INTO stroy.address VALUES (4302, 'Марины Расковой, 21', 30);
INSERT INTO stroy.address VALUES (4303, 'Ольшанская, 50', 8);
INSERT INTO stroy.address VALUES (4304, 'Сеченова, 34', 32);
INSERT INTO stroy.address VALUES (4305, 'В.В.Терешковой, 70', 13);
INSERT INTO stroy.address VALUES (4306, 'Малая Октябрьская, 56', 41);
INSERT INTO stroy.address VALUES (4307, 'Пушкарская, 58', 33);
INSERT INTO stroy.address VALUES (4308, 'Анненки, 80', 9);
INSERT INTO stroy.address VALUES (4309, 'Возмище, 80', 24);
INSERT INTO stroy.address VALUES (4310, 'Брянского Фронта, 60', 33);
INSERT INTO stroy.address VALUES (4311, 'Академика Сахарова, 11', 10);
INSERT INTO stroy.address VALUES (4312, 'Корнилова, 4', 23);
INSERT INTO stroy.address VALUES (4313, 'Благовещенская, 92', 10);
INSERT INTO stroy.address VALUES (4314, 'Ленинградская Дамба, 47', 38);
INSERT INTO stroy.address VALUES (4315, 'Академика Пилюгина, 19', 41);
INSERT INTO stroy.address VALUES (4316, 'Забырина, 59', 39);
INSERT INTO stroy.address VALUES (4317, 'Комарова, 37', 19);
INSERT INTO stroy.address VALUES (4318, 'Батайская, 49', 31);
INSERT INTO stroy.address VALUES (4319, 'Вильнюсская, 40', 35);
INSERT INTO stroy.address VALUES (4320, 'Луначарского, 62', 15);
INSERT INTO stroy.address VALUES (4321, 'Велижская, 37', 9);
INSERT INTO stroy.address VALUES (4322, 'Пристанционная, 12', 31);
INSERT INTO stroy.address VALUES (4323, 'Зубковой, 22', 2);
INSERT INTO stroy.address VALUES (4324, 'Им. Островского, 39', 45);
INSERT INTO stroy.address VALUES (4325, 'Жукова, 87', 1);
INSERT INTO stroy.address VALUES (4326, 'Каховка, 22', 10);
INSERT INTO stroy.address VALUES (4327, 'Ленинградская Дамба, 91', 37);
INSERT INTO stroy.address VALUES (4328, 'Бякова, 28', 22);
INSERT INTO stroy.address VALUES (4329, 'Маленковская, 7', 13);
INSERT INTO stroy.address VALUES (4330, 'Советская, 58', 8);
INSERT INTO stroy.address VALUES (4331, 'Республиканская, 27', 45);
INSERT INTO stroy.address VALUES (4332, 'Некоузская, 62', 10);
INSERT INTO stroy.address VALUES (4333, 'Тихонравова, 49', 35);
INSERT INTO stroy.address VALUES (4334, 'Белавинская, 7', 47);
INSERT INTO stroy.address VALUES (4335, 'Адмирала Корнилова, 3', 10);
INSERT INTO stroy.address VALUES (4336, 'Главная, 70', 31);
INSERT INTO stroy.address VALUES (4337, 'Серпуховский Вал, 37', 7);
INSERT INTO stroy.address VALUES (4338, 'Краснослободская, 8', 35);
INSERT INTO stroy.address VALUES (4339, 'Льва Толстого, 46', 4);
INSERT INTO stroy.address VALUES (4340, 'Самотёчная, 61', 8);
INSERT INTO stroy.address VALUES (4341, '26-Ти Бакинских Комиссаров, 1', 36);
INSERT INTO stroy.address VALUES (4342, 'Майора Алексеева, 86', 44);
INSERT INTO stroy.address VALUES (4343, 'Просторная, 57', 32);
INSERT INTO stroy.address VALUES (4344, 'Живописная, 86', 17);
INSERT INTO stroy.address VALUES (4345, '1-Я Интернациональная, 92', 37);
INSERT INTO stroy.address VALUES (4346, '3-Я Пятилетка, 0', 20);
INSERT INTO stroy.address VALUES (4347, 'Декабристов, 48', 11);
INSERT INTO stroy.address VALUES (4348, 'Намёткина, 86', 9);
INSERT INTO stroy.address VALUES (4349, 'Электрозаводская, 63', 34);
INSERT INTO stroy.address VALUES (4350, 'Тракторная, 71', 25);
INSERT INTO stroy.address VALUES (4351, 'Ногинская, 39', 43);
INSERT INTO stroy.address VALUES (4352, 'Беговая, 5', 28);
INSERT INTO stroy.address VALUES (4353, 'Школьная, 69', 34);
INSERT INTO stroy.address VALUES (4354, 'Монтажная, 64', 46);
INSERT INTO stroy.address VALUES (4355, 'Погодина, 41', 21);
INSERT INTO stroy.address VALUES (4356, 'Электрозаводская, 90', 45);
INSERT INTO stroy.address VALUES (4357, 'Академика Сахарова, 26', 35);
INSERT INTO stroy.address VALUES (4358, 'Киквидзе, 50', 40);
INSERT INTO stroy.address VALUES (4359, 'Степана Разина, 20', 37);
INSERT INTO stroy.address VALUES (4360, 'Ксении Константиновой, 64', 39);
INSERT INTO stroy.address VALUES (4361, 'Тихвинская, 89', 30);
INSERT INTO stroy.address VALUES (4362, 'Леонтия Кривенкова, 73', 22);
INSERT INTO stroy.address VALUES (4363, 'Вернова, 1', 8);
INSERT INTO stroy.address VALUES (4364, 'Черновицкая, 80', 43);
INSERT INTO stroy.address VALUES (4365, 'Перекальского, 63', 10);
INSERT INTO stroy.address VALUES (4366, 'Мельникова, 79', 37);
INSERT INTO stroy.address VALUES (4367, '1-Я Мишутинская, 17', 24);
INSERT INTO stroy.address VALUES (4368, 'Белореченская, 84', 15);
INSERT INTO stroy.address VALUES (4369, 'Бородинская, 5', 25);
INSERT INTO stroy.address VALUES (4370, 'Большая, 49', 19);
INSERT INTO stroy.address VALUES (4371, 'Полевая, 70', 14);
INSERT INTO stroy.address VALUES (4372, 'Косыгина, 99', 43);
INSERT INTO stroy.address VALUES (4373, 'Ялтинская, 80', 29);
INSERT INTO stroy.address VALUES (4374, 'Беклемищева, 93', 33);
INSERT INTO stroy.address VALUES (4375, '2-Я Инженерная, 32', 18);
INSERT INTO stroy.address VALUES (4376, 'Ялтинская, 50', 40);
INSERT INTO stroy.address VALUES (4377, 'Каширина, 81', 32);
INSERT INTO stroy.address VALUES (4378, 'Милашенкова, 60', 26);
INSERT INTO stroy.address VALUES (4379, '1-Я Балинская, 42', 4);
INSERT INTO stroy.address VALUES (4380, 'Большая, 51', 38);
INSERT INTO stroy.address VALUES (4381, 'Иванцова, 57', 10);
INSERT INTO stroy.address VALUES (4382, 'Марьинская, 12', 2);
INSERT INTO stroy.address VALUES (4383, 'Фабричная, 29', 41);
INSERT INTO stroy.address VALUES (4384, '1-Я Мишутинская, 55', 23);
INSERT INTO stroy.address VALUES (4385, 'Межевая, 2', 10);
INSERT INTO stroy.address VALUES (4386, 'Прудовая, 51', 3);
INSERT INTO stroy.address VALUES (4387, 'Бориса Галушкина, 69', 23);
INSERT INTO stroy.address VALUES (4388, 'Алексея Ракитина, 66', 44);
INSERT INTO stroy.address VALUES (4389, 'Соловьиная, 50', 38);
INSERT INTO stroy.address VALUES (4390, 'Митрофанова, 79', 14);
INSERT INTO stroy.address VALUES (4391, 'Бартеневская, 64', 11);
INSERT INTO stroy.address VALUES (4392, 'Железнодорожная, 23', 18);
INSERT INTO stroy.address VALUES (4393, 'Большак, 50', 7);
INSERT INTO stroy.address VALUES (4394, '10 Августа, 84', 23);
INSERT INTO stroy.address VALUES (4395, 'Площадь Металлургов;  Марины Расковой;  Марины Расковой, 1', 18);
INSERT INTO stroy.address VALUES (4396, 'Гусева, 72', 5);
INSERT INTO stroy.address VALUES (4397, 'Марченко, 39', 34);
INSERT INTO stroy.address VALUES (4398, 'Имени Генерала Астанина, 18', 22);
INSERT INTO stroy.address VALUES (4399, '1905 Года, 11', 14);
INSERT INTO stroy.address VALUES (4400, 'Новаторская, 43', 14);
INSERT INTO stroy.address VALUES (4401, 'Добровольцев Урала, 24', 33);
INSERT INTO stroy.address VALUES (4402, 'Клишина, 78', 28);
INSERT INTO stroy.address VALUES (4403, 'Полесская, 18', 24);
INSERT INTO stroy.address VALUES (4404, 'Мытная, 20', 20);
INSERT INTO stroy.address VALUES (4405, 'Носкова, 44', 29);
INSERT INTO stroy.address VALUES (4406, 'Дорошенко, 86', 46);
INSERT INTO stroy.address VALUES (4407, 'Черепанова, 13', 15);
INSERT INTO stroy.address VALUES (4408, '60-Летия Октября, 80', 8);
INSERT INTO stroy.address VALUES (4409, 'Коломенская, 42', 35);
INSERT INTO stroy.address VALUES (4410, 'Сергея Макеева, 28', 46);
INSERT INTO stroy.address VALUES (4411, 'Карпова, 34', 3);
INSERT INTO stroy.address VALUES (4412, 'Нижняя Дебря, 70', 6);
INSERT INTO stroy.address VALUES (4413, 'Ермака, 67', 22);
INSERT INTO stroy.address VALUES (4414, 'Берникова, 98', 44);
INSERT INTO stroy.address VALUES (4415, 'Северный Посёлок, 79', 22);
INSERT INTO stroy.address VALUES (4416, 'Коровники, 46', 26);
INSERT INTO stroy.address VALUES (4417, 'Летниковская, 1', 37);
INSERT INTO stroy.address VALUES (4418, '1-Я Посадская, 0', 12);
INSERT INTO stroy.address VALUES (4419, 'Борисовские Пруды, 74', 28);
INSERT INTO stroy.address VALUES (4420, '40 Лет Влксм, 75', 14);
INSERT INTO stroy.address VALUES (4421, 'Тюрина, 10', 20);
INSERT INTO stroy.address VALUES (4422, 'Желябова, 100', 11);
INSERT INTO stroy.address VALUES (4423, 'Александровка, 44', 9);
INSERT INTO stroy.address VALUES (4424, 'Подстанция, 41', 47);
INSERT INTO stroy.address VALUES (4425, 'Миклухо-Маклая, 16', 46);
INSERT INTO stroy.address VALUES (4426, 'Шухова, 28', 28);
INSERT INTO stroy.address VALUES (4427, 'Смирнова, 99', 41);
INSERT INTO stroy.address VALUES (4428, 'Парижской Коммуны, 8', 42);
INSERT INTO stroy.address VALUES (4429, '3-Я Рейсовая, 30', 23);
INSERT INTO stroy.address VALUES (4430, 'Майская, 33', 6);
INSERT INTO stroy.address VALUES (4431, 'Прохладная, 41', 7);
INSERT INTO stroy.address VALUES (4432, 'Ольховка, 36', 19);
INSERT INTO stroy.address VALUES (4433, 'Изыскателей, 80', 42);
INSERT INTO stroy.address VALUES (4434, 'Куйбышева, 44', 20);
INSERT INTO stroy.address VALUES (4435, 'Дубнинская, 96', 42);
INSERT INTO stroy.address VALUES (4436, '30 Лет Победы, 41', 43);
INSERT INTO stroy.address VALUES (4437, 'Дубненская, 9', 26);
INSERT INTO stroy.address VALUES (4438, 'Кирова, 54', 39);
INSERT INTO stroy.address VALUES (4439, 'Реформатского, 11', 25);
INSERT INTO stroy.address VALUES (4440, 'Тарусская, 16', 24);
INSERT INTO stroy.address VALUES (4441, 'Бандикова, 20', 25);
INSERT INTO stroy.address VALUES (4442, 'Физическая, 58', 20);
INSERT INTO stroy.address VALUES (4443, 'Зиновьева, 0', 29);
INSERT INTO stroy.address VALUES (4444, '25 Сентября, 21', 41);
INSERT INTO stroy.address VALUES (4445, 'Старая Басманная, 94', 26);
INSERT INTO stroy.address VALUES (4446, 'Пересвета, 28', 24);
INSERT INTO stroy.address VALUES (4447, 'Глаголева, 72', 37);
INSERT INTO stroy.address VALUES (4448, 'Москворечье, 12', 15);
INSERT INTO stroy.address VALUES (4449, 'Возмище, 75', 5);
INSERT INTO stroy.address VALUES (4450, 'Большая Дорога, 32', 11);
INSERT INTO stroy.address VALUES (4451, 'Кожевническая, 8', 36);
INSERT INTO stroy.address VALUES (4452, '1-Я Сосновая, 98', 20);
INSERT INTO stroy.address VALUES (4453, 'Покровка, 65', 42);
INSERT INTO stroy.address VALUES (4454, 'Беляева, 66', 33);
INSERT INTO stroy.address VALUES (4455, 'Автомобильная, 2', 20);
INSERT INTO stroy.address VALUES (4456, '1-Я Пушкинская, 24', 28);
INSERT INTO stroy.address VALUES (4457, 'Сергия Радонежского, 70', 34);
INSERT INTO stroy.address VALUES (4458, 'Любимская, 30', 29);
INSERT INTO stroy.address VALUES (4459, 'Карла Либкнехта, 4', 39);
INSERT INTO stroy.address VALUES (4460, 'Сарментовой, 47', 35);
INSERT INTO stroy.address VALUES (4461, 'Радищева, 17', 27);
INSERT INTO stroy.address VALUES (4462, 'Старосельская, 89', 24);
INSERT INTO stroy.address VALUES (4463, 'Большая Садовая, 26', 19);
INSERT INTO stroy.address VALUES (4464, 'Клишина, 57', 42);
INSERT INTO stroy.address VALUES (4465, 'Баррикадная, 57', 3);
INSERT INTO stroy.address VALUES (4466, '22-Го Съезда Кпсс, 18', 47);
INSERT INTO stroy.address VALUES (4467, '60-Й Армии, 73', 41);
INSERT INTO stroy.address VALUES (4468, 'Северной Правды, 38', 17);
INSERT INTO stroy.address VALUES (4469, 'Воротынская, 48', 46);
INSERT INTO stroy.address VALUES (4470, 'Юных Ленинцев, 33', 47);
INSERT INTO stroy.address VALUES (4471, 'Фридриха Энгельса, 96', 30);
INSERT INTO stroy.address VALUES (4472, 'Центрльная, 86', 42);
INSERT INTO stroy.address VALUES (4473, 'Киевская, 3', 35);
INSERT INTO stroy.address VALUES (4474, 'Комиссарова, 74', 47);
INSERT INTO stroy.address VALUES (4475, 'Восточная, 90', 33);
INSERT INTO stroy.address VALUES (4476, '1-Го Мая, 66', 35);
INSERT INTO stroy.address VALUES (4477, 'Ракитянская, 10', 11);
INSERT INTO stroy.address VALUES (4478, 'Пионерская, 18', 17);
INSERT INTO stroy.address VALUES (4479, '16-Я Парковая, 56', 37);
INSERT INTO stroy.address VALUES (4480, 'Зацепский Вал, 23', 31);
INSERT INTO stroy.address VALUES (4481, 'Обуховская, 71', 1);
INSERT INTO stroy.address VALUES (4482, 'Грайворонская, 94', 15);
INSERT INTO stroy.address VALUES (4483, 'Черняховского, 97', 1);
INSERT INTO stroy.address VALUES (4484, 'Уссурийская, 56', 29);
INSERT INTO stroy.address VALUES (4485, 'Менжинского, 74', 2);
INSERT INTO stroy.address VALUES (4486, '1-Я Радиальная, 53', 45);
INSERT INTO stroy.address VALUES (4487, 'Волхонка, 10', 5);
INSERT INTO stroy.address VALUES (4488, 'Цветочная, 84', 1);
INSERT INTO stroy.address VALUES (4489, 'Дуниловская, 42', 11);
INSERT INTO stroy.address VALUES (4490, 'Новая Курская, 1', 44);
INSERT INTO stroy.address VALUES (4491, '5-Я Южная, 68', 20);
INSERT INTO stroy.address VALUES (4492, 'Ольговская, 93', 14);
INSERT INTO stroy.address VALUES (4493, 'Гензика, 85', 9);
INSERT INTO stroy.address VALUES (4494, 'Кутузова, 39', 9);
INSERT INTO stroy.address VALUES (4495, 'Большая Грузинская, 76', 22);
INSERT INTO stroy.address VALUES (4496, 'Стопани, 44', 14);
INSERT INTO stroy.address VALUES (4497, 'Константина Заслонова, 42', 46);
INSERT INTO stroy.address VALUES (4498, 'Успенская, 53', 12);
INSERT INTO stroy.address VALUES (4499, 'О.Зеленской, 36', 20);
INSERT INTO stroy.address VALUES (4500, 'Холодово, 52', 29);
INSERT INTO stroy.address VALUES (4501, 'Промышленная, 23', 36);
INSERT INTO stroy.address VALUES (4502, 'Автодорожная, 87', 1);
INSERT INTO stroy.address VALUES (4503, 'Шипиловская, 42', 21);
INSERT INTO stroy.address VALUES (4504, 'Окружная, 76', 22);
INSERT INTO stroy.address VALUES (4505, 'Гуреевская, 99', 26);
INSERT INTO stroy.address VALUES (4506, '1-Я Рыбинская, 13', 45);
INSERT INTO stroy.address VALUES (4507, 'Транспортная, 14', 24);
INSERT INTO stroy.address VALUES (4508, 'Радио, 56', 29);
INSERT INTO stroy.address VALUES (4509, 'Локомотивная, 17', 39);
INSERT INTO stroy.address VALUES (4510, 'Лакина, 89', 29);
INSERT INTO stroy.address VALUES (4511, 'Токарёвская, 66', 17);
INSERT INTO stroy.address VALUES (4512, 'Гарская, 60', 23);
INSERT INTO stroy.address VALUES (4513, 'Малая Колхозная, 67', 23);
INSERT INTO stroy.address VALUES (4514, 'Луганская, 59', 31);
INSERT INTO stroy.address VALUES (4515, '2-Я Владимирская, 67', 15);
INSERT INTO stroy.address VALUES (4516, 'Болотова, 77', 43);
INSERT INTO stroy.address VALUES (4517, 'Большая Учительская, 92', 28);
INSERT INTO stroy.address VALUES (4518, 'Измайловский Вал, 45', 42);
INSERT INTO stroy.address VALUES (4519, 'Толстого, 49', 27);
INSERT INTO stroy.address VALUES (4520, 'Краснянская, 9', 2);
INSERT INTO stroy.address VALUES (4521, 'Большая-Штабская, 0', 6);
INSERT INTO stroy.address VALUES (4522, 'Сокольнический Вал, 85', 27);
INSERT INTO stroy.address VALUES (4651, 'Никулинская, 48', 1);
INSERT INTO stroy.address VALUES (4523, 'Алексея Ракитина, 9', 36);
INSERT INTO stroy.address VALUES (4524, 'Кольцовская, 50', 45);
INSERT INTO stroy.address VALUES (4525, 'Белгородской Сирени, 89', 27);
INSERT INTO stroy.address VALUES (4526, 'Велозаводская, 44', 3);
INSERT INTO stroy.address VALUES (4527, 'Трубникова, 58', 26);
INSERT INTO stroy.address VALUES (4528, 'Ново-Елатомская, 50', 29);
INSERT INTO stroy.address VALUES (4529, 'Дуки, 53', 32);
INSERT INTO stroy.address VALUES (4530, 'Арсеньевка, 16', 13);
INSERT INTO stroy.address VALUES (4531, 'Бельская, 56', 16);
INSERT INTO stroy.address VALUES (4532, 'Моховая, 9', 22);
INSERT INTO stroy.address VALUES (4533, 'Трубчевская, 18', 20);
INSERT INTO stroy.address VALUES (4534, 'Варшавская, 61', 21);
INSERT INTO stroy.address VALUES (4535, 'Астраханская, 83', 26);
INSERT INTO stroy.address VALUES (4536, 'Учинская, 98', 44);
INSERT INTO stroy.address VALUES (4537, 'Тюрина, 28', 43);
INSERT INTO stroy.address VALUES (4538, 'В. Большак, 2', 9);
INSERT INTO stroy.address VALUES (4539, 'Лётчика Бабушкина, 71', 28);
INSERT INTO stroy.address VALUES (4540, 'Песочная, 82', 31);
INSERT INTO stroy.address VALUES (4541, 'Ньютона, 55', 17);
INSERT INTO stroy.address VALUES (4542, 'Комдива Орлова, 7', 10);
INSERT INTO stroy.address VALUES (4543, 'Ундол, 25', 42);
INSERT INTO stroy.address VALUES (4544, 'Каланчёвская, 41', 47);
INSERT INTO stroy.address VALUES (4545, 'Матросская, 72', 41);
INSERT INTO stroy.address VALUES (4546, 'Украинская, 5', 44);
INSERT INTO stroy.address VALUES (4547, 'Ермака, 96', 17);
INSERT INTO stroy.address VALUES (4548, 'Левобережная, 15', 26);
INSERT INTO stroy.address VALUES (4549, 'Дарвина, 44', 9);
INSERT INTO stroy.address VALUES (4550, 'Белёвская, 63', 42);
INSERT INTO stroy.address VALUES (4551, 'Абельмановская, 98', 38);
INSERT INTO stroy.address VALUES (4552, '1 Мая, 50', 28);
INSERT INTO stroy.address VALUES (4553, 'Пенькозаводская, 26', 45);
INSERT INTO stroy.address VALUES (4554, 'Автодорожная, 36', 39);
INSERT INTO stroy.address VALUES (4555, 'Зарецкая, 11', 32);
INSERT INTO stroy.address VALUES (4556, 'Агрохимиков, 97', 31);
INSERT INTO stroy.address VALUES (4557, 'Зарецкая, 31', 3);
INSERT INTO stroy.address VALUES (4558, 'Бежицкая, 82', 3);
INSERT INTO stroy.address VALUES (4559, 'Зелёны Шум, 81', 8);
INSERT INTO stroy.address VALUES (4560, 'Путевая, 27', 27);
INSERT INTO stroy.address VALUES (4561, 'Симферопольская, 9', 37);
INSERT INTO stroy.address VALUES (4562, '8-Го Марта, 72', 36);
INSERT INTO stroy.address VALUES (4563, 'Нахимова, 60', 19);
INSERT INTO stroy.address VALUES (4564, 'Ольховка, 86', 42);
INSERT INTO stroy.address VALUES (4565, 'Солянка, 71', 8);
INSERT INTO stroy.address VALUES (4566, 'Верхняя Масловка, 27', 46);
INSERT INTO stroy.address VALUES (4567, '35 Лет Победы, 45', 9);
INSERT INTO stroy.address VALUES (4568, '1-Я  Ленстрой, 85', 26);
INSERT INTO stroy.address VALUES (4569, 'Раменская, 62', 24);
INSERT INTO stroy.address VALUES (4570, 'Добрынина, 58', 10);
INSERT INTO stroy.address VALUES (4571, 'Ломакина, 25', 33);
INSERT INTO stroy.address VALUES (4572, 'Орджоникидзе, 51', 35);
INSERT INTO stroy.address VALUES (4573, 'Федеративная, 38', 1);
INSERT INTO stroy.address VALUES (4574, '1-Я Рейсовая, 0', 43);
INSERT INTO stroy.address VALUES (4575, 'Станиславского, 79', 2);
INSERT INTO stroy.address VALUES (4576, 'Шереметовка, 69', 22);
INSERT INTO stroy.address VALUES (4577, '22-Го Съезда Кпсс, 65', 12);
INSERT INTO stroy.address VALUES (4578, '1-Я Советская, 97', 10);
INSERT INTO stroy.address VALUES (4579, 'Баканова, 97', 34);
INSERT INTO stroy.address VALUES (4580, 'Суворова, 79', 30);
INSERT INTO stroy.address VALUES (4581, 'Осенняя, 21', 38);
INSERT INTO stroy.address VALUES (4582, 'Говорова, 86', 14);
INSERT INTO stroy.address VALUES (4583, 'Володарского, 10', 36);
INSERT INTO stroy.address VALUES (4584, 'Валаамская, 44', 31);
INSERT INTO stroy.address VALUES (4585, 'Воронцовская, 94', 11);
INSERT INTO stroy.address VALUES (4586, 'Люсиновская, 11', 34);
INSERT INTO stroy.address VALUES (4587, 'Коренная, 35', 12);
INSERT INTO stroy.address VALUES (4588, 'Новая, 48', 4);
INSERT INTO stroy.address VALUES (4589, 'Александра Печерского, 34', 11);
INSERT INTO stroy.address VALUES (4590, 'Грузовая, 8', 39);
INSERT INTO stroy.address VALUES (4591, 'Атласова, 62', 20);
INSERT INTO stroy.address VALUES (4592, '1-Я  Фрунзе, 32', 39);
INSERT INTO stroy.address VALUES (4593, 'Спартаковская, 47', 2);
INSERT INTO stroy.address VALUES (4594, 'Флотская, 27', 22);
INSERT INTO stroy.address VALUES (4595, 'Барклая, 75', 26);
INSERT INTO stroy.address VALUES (4596, 'Партизанская, 55', 26);
INSERT INTO stroy.address VALUES (4597, 'Каховского, 92', 42);
INSERT INTO stroy.address VALUES (4598, 'Пайтерова, 78', 17);
INSERT INTO stroy.address VALUES (4599, 'Серпуховский Вал, 56', 12);
INSERT INTO stroy.address VALUES (4600, 'Лысенко, 29', 10);
INSERT INTO stroy.address VALUES (4601, 'Мичурина, 17', 47);
INSERT INTO stroy.address VALUES (4602, '50 Лет Победы, 94', 38);
INSERT INTO stroy.address VALUES (4603, 'Большая Смоленская, 55', 16);
INSERT INTO stroy.address VALUES (4604, 'Рабфаковская, 22', 3);
INSERT INTO stroy.address VALUES (4605, 'Петра I, 51', 47);
INSERT INTO stroy.address VALUES (4606, 'Народного Ополчения (Дублёр), 58', 43);
INSERT INTO stroy.address VALUES (4607, 'Пристанционная, 60', 15);
INSERT INTO stroy.address VALUES (4608, 'Ранняя Заря, 79', 3);
INSERT INTO stroy.address VALUES (4609, 'Орудовская, 93', 17);
INSERT INTO stroy.address VALUES (4610, 'Нововерховенская, 71', 20);
INSERT INTO stroy.address VALUES (4611, 'Станционная, 86', 34);
INSERT INTO stroy.address VALUES (4612, '1-Я Волоколамская, 37', 17);
INSERT INTO stroy.address VALUES (4613, 'Цюрупы, 81', 31);
INSERT INTO stroy.address VALUES (4614, 'Литовская, 91', 39);
INSERT INTO stroy.address VALUES (4615, 'Большевик, 27', 17);
INSERT INTO stroy.address VALUES (4616, 'Планетная, 22', 41);
INSERT INTO stroy.address VALUES (4617, 'Жолио-Кюри, 71', 3);
INSERT INTO stroy.address VALUES (4618, 'Юрия Смирнова, 29', 6);
INSERT INTO stroy.address VALUES (4619, 'Прокопия Добрынина, 88', 5);
INSERT INTO stroy.address VALUES (4620, 'Моховая, 32', 33);
INSERT INTO stroy.address VALUES (4621, 'Рылеева, 42', 11);
INSERT INTO stroy.address VALUES (4622, 'Земляной Вал, 7', 24);
INSERT INTO stroy.address VALUES (4623, 'Нижняя Дебря, 92', 32);
INSERT INTO stroy.address VALUES (4624, 'Батарейная, 56', 20);
INSERT INTO stroy.address VALUES (4625, 'Большая Рупасовская, 41', 4);
INSERT INTO stroy.address VALUES (4626, 'Рославльская, 13', 45);
INSERT INTO stroy.address VALUES (4627, 'Калуга-Бор, 46', 26);
INSERT INTO stroy.address VALUES (4628, 'Маргелова, 82', 37);
INSERT INTO stroy.address VALUES (4629, 'Мадонская, 19', 8);
INSERT INTO stroy.address VALUES (4630, 'Буровая, 19', 6);
INSERT INTO stroy.address VALUES (4631, 'Газина, 45', 26);
INSERT INTO stroy.address VALUES (4632, 'Жолио-Кюри, 46', 17);
INSERT INTO stroy.address VALUES (4633, 'Благовещенская, 90', 9);
INSERT INTO stroy.address VALUES (4634, 'Новая Калиновка, 38', 25);
INSERT INTO stroy.address VALUES (4635, '9 Января, 25', 31);
INSERT INTO stroy.address VALUES (4636, 'Голубкова, 56', 22);
INSERT INTO stroy.address VALUES (4637, 'Большая Черкизовская, 83', 26);
INSERT INTO stroy.address VALUES (4638, 'Малахово, 49', 2);
INSERT INTO stroy.address VALUES (4639, 'Гурьянова, 62', 20);
INSERT INTO stroy.address VALUES (4640, 'Моршанская, 75', 18);
INSERT INTO stroy.address VALUES (4641, 'Бежецкая, 52', 31);
INSERT INTO stroy.address VALUES (4642, 'Тарутинская, 89', 26);
INSERT INTO stroy.address VALUES (4643, 'Свободная, 63', 18);
INSERT INTO stroy.address VALUES (4644, 'Фрязевская, 38', 15);
INSERT INTO stroy.address VALUES (4645, 'Слепцова, 2', 17);
INSERT INTO stroy.address VALUES (4646, 'Прохладная, 64', 37);
INSERT INTO stroy.address VALUES (4647, 'Некоузская, 16', 32);
INSERT INTO stroy.address VALUES (4648, 'Беленовка, 59', 14);
INSERT INTO stroy.address VALUES (4649, 'Мархлевского, 72', 30);
INSERT INTO stroy.address VALUES (4650, 'Донская, 46', 44);
INSERT INTO stroy.address VALUES (4652, 'Хлеборобов, 27', 1);
INSERT INTO stroy.address VALUES (4653, 'Никулинская, 34', 2);
INSERT INTO stroy.address VALUES (4654, 'Бельская, 4', 7);
INSERT INTO stroy.address VALUES (4655, 'Ладыженского, 5', 35);
INSERT INTO stroy.address VALUES (4656, 'Гаршина, 23', 26);
INSERT INTO stroy.address VALUES (4657, '1-Я Порецкая, 17', 26);
INSERT INTO stroy.address VALUES (4658, 'Столетова, 11', 15);
INSERT INTO stroy.address VALUES (4659, 'Большая Пироговская, 82', 30);
INSERT INTO stroy.address VALUES (4660, 'Вифанская, 91', 38);
INSERT INTO stroy.address VALUES (4661, 'Ивана Шатрова, 19', 30);
INSERT INTO stroy.address VALUES (4662, 'Шацкая, 42', 26);
INSERT INTO stroy.address VALUES (4663, 'Иловайская, 68', 37);
INSERT INTO stroy.address VALUES (4664, 'Мамаев Проток, 59', 24);
INSERT INTO stroy.address VALUES (4665, 'Ошмарина, 87', 12);
INSERT INTO stroy.address VALUES (4666, 'Шкадова, 99', 31);
INSERT INTO stroy.address VALUES (4667, 'Крупешина, 22', 33);
INSERT INTO stroy.address VALUES (4668, 'Коломенская, 36', 46);
INSERT INTO stroy.address VALUES (4669, 'Окская, 60', 34);
INSERT INTO stroy.address VALUES (4670, 'Ипподромная, 83', 13);
INSERT INTO stroy.address VALUES (4671, 'Ногинская, 34', 1);
INSERT INTO stroy.address VALUES (4672, 'Большая Серпуховская, 77', 36);
INSERT INTO stroy.address VALUES (4673, 'Сайкина, 50', 29);
INSERT INTO stroy.address VALUES (4674, 'Перовской, 69', 34);
INSERT INTO stroy.address VALUES (4675, 'Ивантеевская Ветка, 68', 23);
INSERT INTO stroy.address VALUES (4676, 'Ивантеевская Ветка, 35', 35);
INSERT INTO stroy.address VALUES (4677, 'Яна Берзина, 12', 11);
INSERT INTO stroy.address VALUES (4678, 'Дубравная, 89', 1);
INSERT INTO stroy.address VALUES (4679, 'Автомагистраль, 55', 28);
INSERT INTO stroy.address VALUES (4680, '706-Го Продотряда, 50', 16);
INSERT INTO stroy.address VALUES (4681, 'Малаховского, 51', 47);
INSERT INTO stroy.address VALUES (4682, 'Плотникова, 3', 37);
INSERT INTO stroy.address VALUES (4683, 'Старомихневская, 92', 39);
INSERT INTO stroy.address VALUES (4684, 'Смирновская, 29', 40);
INSERT INTO stroy.address VALUES (4685, 'Таганская, 43', 47);
INSERT INTO stroy.address VALUES (4686, 'Тесакова, 90', 17);
INSERT INTO stroy.address VALUES (4687, 'Лотикова, 11', 18);
INSERT INTO stroy.address VALUES (4688, 'Будёновская, 92', 9);
INSERT INTO stroy.address VALUES (4689, 'Эрденко, 77', 36);
INSERT INTO stroy.address VALUES (4690, 'Полбина, 5', 47);
INSERT INTO stroy.address VALUES (4691, 'Вавилова, 53', 34);
INSERT INTO stroy.address VALUES (4692, 'Малая Колхозная, 35', 37);
INSERT INTO stroy.address VALUES (4693, '5-Я Южная, 5', 40);
INSERT INTO stroy.address VALUES (4694, 'Щёголевых, 70', 1);
INSERT INTO stroy.address VALUES (4695, 'Горчакова, 89', 24);
INSERT INTO stroy.address VALUES (4696, 'Ушакова, 96', 30);
INSERT INTO stroy.address VALUES (4697, 'Павлова, 96', 34);
INSERT INTO stroy.address VALUES (4698, 'Ломакина, 84', 2);
INSERT INTO stroy.address VALUES (4699, '1-Я Транспортная, 15', 40);
INSERT INTO stroy.address VALUES (4700, 'Раевского, 15', 9);
INSERT INTO stroy.address VALUES (4701, 'В. Большак, 66', 31);
INSERT INTO stroy.address VALUES (4702, 'Переяслав-Хмельницкого, 34', 26);
INSERT INTO stroy.address VALUES (4703, 'Марии Рябининой, 85', 14);
INSERT INTO stroy.address VALUES (4704, 'Голубкова, 1', 38);
INSERT INTO stroy.address VALUES (4705, 'Линейная, 12', 24);
INSERT INTO stroy.address VALUES (4706, 'Толстовская, 34', 4);
INSERT INTO stroy.address VALUES (4707, 'Воровского, 99', 26);
INSERT INTO stroy.address VALUES (4708, 'Ватутина, 69', 19);
INSERT INTO stroy.address VALUES (4709, 'Павлова, 39', 39);
INSERT INTO stroy.address VALUES (4710, 'Валаамская, 4', 27);
INSERT INTO stroy.address VALUES (4711, 'Пансионатовская, 3', 34);
INSERT INTO stroy.address VALUES (4712, 'Ефремова, 87', 20);
INSERT INTO stroy.address VALUES (4713, 'Лебеденко, 22', 11);
INSERT INTO stroy.address VALUES (4714, 'Блинова, 86', 37);
INSERT INTO stroy.address VALUES (4715, 'Ольминского, 21', 30);
INSERT INTO stroy.address VALUES (4716, 'Наримановская, 60', 37);
INSERT INTO stroy.address VALUES (4717, 'Большая Лубянка, 37', 25);
INSERT INTO stroy.address VALUES (4718, 'Окская, 26', 44);
INSERT INTO stroy.address VALUES (4719, '40 Лет Победы, 45', 36);
INSERT INTO stroy.address VALUES (4720, 'Большая Пироговская, 87', 22);
INSERT INTO stroy.address VALUES (4721, 'Миклухо-Маклая, 37', 23);
INSERT INTO stroy.address VALUES (4722, 'Полиграфская, 21', 15);
INSERT INTO stroy.address VALUES (4723, 'Мархлевского, 9', 35);
INSERT INTO stroy.address VALUES (4724, 'Хуторок, 78', 18);
INSERT INTO stroy.address VALUES (4725, 'Возмище, 1', 26);
INSERT INTO stroy.address VALUES (4726, 'Молчанова, 46', 35);
INSERT INTO stroy.address VALUES (4727, 'Переяслав-Хмельницкого, 24', 33);
INSERT INTO stroy.address VALUES (4728, 'Гензика, 49', 7);
INSERT INTO stroy.address VALUES (4729, 'Молодогвардейская, 10', 21);
INSERT INTO stroy.address VALUES (4730, 'Титова, 94', 40);
INSERT INTO stroy.address VALUES (4731, 'Горького, 21', 34);
INSERT INTO stroy.address VALUES (4732, 'Локомотивная, 4', 24);
INSERT INTO stroy.address VALUES (4733, 'Красная, 100', 41);
INSERT INTO stroy.address VALUES (4734, 'Шагова, 23', 10);
INSERT INTO stroy.address VALUES (4735, 'Большая Рупасовская, 37', 38);
INSERT INTO stroy.address VALUES (4736, 'Новослободская, 23', 35);
INSERT INTO stroy.address VALUES (4737, 'Шахтная, 78', 45);
INSERT INTO stroy.address VALUES (4738, 'Раменки, 65', 21);
INSERT INTO stroy.address VALUES (4739, 'Дорогобужский Большак, 73', 20);
INSERT INTO stroy.address VALUES (4740, 'Просторная, 47', 13);
INSERT INTO stroy.address VALUES (4741, 'Руднянская, 17', 45);
INSERT INTO stroy.address VALUES (4742, 'Минская, 8', 47);
INSERT INTO stroy.address VALUES (4743, 'Воронцово Поле, 12', 39);
INSERT INTO stroy.address VALUES (4744, 'Голубинская, 5', 14);
INSERT INTO stroy.address VALUES (4745, 'Новозыбковская, 95', 28);
INSERT INTO stroy.address VALUES (4746, 'Северная Советская, 91', 5);
INSERT INTO stroy.address VALUES (4747, 'Руставели, 5', 38);
INSERT INTO stroy.address VALUES (4748, '1-Я Пролетарская, 1', 36);
INSERT INTO stroy.address VALUES (4749, 'Болховская, 30', 13);
INSERT INTO stroy.address VALUES (4750, 'Передаточная, 44', 41);
INSERT INTO stroy.address VALUES (4751, 'Агрохимиков, 15', 33);
INSERT INTO stroy.address VALUES (4752, 'Большевиков, 43', 3);
INSERT INTO stroy.address VALUES (4753, 'Бакунинская, 34', 16);
INSERT INTO stroy.address VALUES (4754, 'Александры Монаховой, 44', 8);
INSERT INTO stroy.address VALUES (4755, 'Объездная, 98', 21);
INSERT INTO stroy.address VALUES (4756, 'Михалевича, 17', 18);
INSERT INTO stroy.address VALUES (4757, 'Большая Садовая, 25', 43);
INSERT INTO stroy.address VALUES (4758, 'Старо-Московская, 98', 45);
INSERT INTO stroy.address VALUES (4759, 'Невского, 83', 5);
INSERT INTO stroy.address VALUES (4760, '5-Я Южная, 10', 25);
INSERT INTO stroy.address VALUES (4761, 'Нижняя Радищевская, 43', 37);
INSERT INTO stroy.address VALUES (4762, '3 Интернационала, 75', 5);
INSERT INTO stroy.address VALUES (4763, 'Расторгуева, 43', 12);
INSERT INTO stroy.address VALUES (4764, 'Богунского Полка, 80', 38);
INSERT INTO stroy.address VALUES (4765, 'Академика Жукова, 55', 1);
INSERT INTO stroy.address VALUES (4766, 'Кировская, 43', 42);
INSERT INTO stroy.address VALUES (4767, 'Кутузова, 77', 31);
INSERT INTO stroy.address VALUES (4768, 'Георгия Димитрова, 63', 34);
INSERT INTO stroy.address VALUES (4769, 'Благова, 3', 16);
INSERT INTO stroy.address VALUES (4770, 'Охотный Ряд, 17', 30);
INSERT INTO stroy.address VALUES (4771, 'Генерала Костенко, 59', 22);
INSERT INTO stroy.address VALUES (4772, '1-Й Конной Армии, 12', 6);
INSERT INTO stroy.address VALUES (4773, 'Еловая, 4', 27);
INSERT INTO stroy.address VALUES (4774, 'Тихвинская, 78', 3);
INSERT INTO stroy.address VALUES (4775, 'Усманская, 18', 4);
INSERT INTO stroy.address VALUES (4776, 'Пушкарская, 22', 35);
INSERT INTO stroy.address VALUES (4777, 'Пмк-10, 71', 30);
INSERT INTO stroy.address VALUES (4778, 'Коровий Вал, 40', 40);
INSERT INTO stroy.address VALUES (4779, '1-Й Ударной Армии, 77', 10);
INSERT INTO stroy.address VALUES (4780, 'Геническая, 93', 15);
INSERT INTO stroy.address VALUES (4781, 'Александровская, 40', 44);
INSERT INTO stroy.address VALUES (4782, 'Анны Горностаевой, 61', 33);
INSERT INTO stroy.address VALUES (4783, 'Хотьковская, 10', 7);
INSERT INTO stroy.address VALUES (4784, 'Рабочая, 27', 6);
INSERT INTO stroy.address VALUES (4785, 'Электрификации, 78', 36);
INSERT INTO stroy.address VALUES (4786, '45-Й Стрелковой Дивизии, 76', 16);
INSERT INTO stroy.address VALUES (4787, 'Революции, 91', 20);
INSERT INTO stroy.address VALUES (4788, 'Городская Дорога, 51', 37);
INSERT INTO stroy.address VALUES (4789, 'Гладышева, 39', 24);
INSERT INTO stroy.address VALUES (4790, 'Лютинская, 89', 7);
INSERT INTO stroy.address VALUES (4791, 'Рудинская, 0', 10);
INSERT INTO stroy.address VALUES (4792, '1-Я Станционная, 53', 31);
INSERT INTO stroy.address VALUES (4793, 'Лётчика Осканова, 87', 5);
INSERT INTO stroy.address VALUES (4794, 'Есенина, 52', 35);
INSERT INTO stroy.address VALUES (4795, 'Рославльская, 93', 1);
INSERT INTO stroy.address VALUES (4796, 'Ирины Рубцовой, 98', 27);
INSERT INTO stroy.address VALUES (4797, 'Богатырский Мост, 27', 12);
INSERT INTO stroy.address VALUES (4798, 'О.Зеленской, 49', 45);
INSERT INTO stroy.address VALUES (4799, '2-Я Вольская, 3', 16);
INSERT INTO stroy.address VALUES (4800, 'Петра I, 55', 36);
INSERT INTO stroy.address VALUES (4801, 'Литовская, 54', 45);
INSERT INTO stroy.address VALUES (4802, 'Фокина, 17', 1);
INSERT INTO stroy.address VALUES (4803, 'Секиотовская, 75', 19);
INSERT INTO stroy.address VALUES (4804, 'Болховская, 59', 7);
INSERT INTO stroy.address VALUES (4805, 'Атласова, 8', 38);
INSERT INTO stroy.address VALUES (4806, 'Верхняя Луговая, 60', 2);
INSERT INTO stroy.address VALUES (4807, 'Павла Андреева, 87', 35);
INSERT INTO stroy.address VALUES (4808, 'Тракторная, 100', 2);
INSERT INTO stroy.address VALUES (4809, 'Лавицкого, 69', 9);
INSERT INTO stroy.address VALUES (4810, 'Розы Люксембург, 9', 46);
INSERT INTO stroy.address VALUES (4811, 'Жилинская, 30', 24);
INSERT INTO stroy.address VALUES (4812, 'Рудакова, 41', 22);
INSERT INTO stroy.address VALUES (4813, 'Александры Монаховой, 12', 38);
INSERT INTO stroy.address VALUES (4814, 'Ульянова, 30', 23);
INSERT INTO stroy.address VALUES (4815, 'Измайловский Вал, 25', 22);
INSERT INTO stroy.address VALUES (4816, 'Понятовская, 85', 15);
INSERT INTO stroy.address VALUES (4817, 'Симферопольская, 30', 2);
INSERT INTO stroy.address VALUES (4818, 'Грейдерная, 70', 43);
INSERT INTO stroy.address VALUES (4819, 'Бероунская, 10', 30);
INSERT INTO stroy.address VALUES (4820, 'Загородная, 94', 32);
INSERT INTO stroy.address VALUES (4821, 'Шишкина, 28', 18);
INSERT INTO stroy.address VALUES (4822, 'Старые Ватутинки, 51', 10);
INSERT INTO stroy.address VALUES (4823, 'Ефремова, 60', 12);
INSERT INTO stroy.address VALUES (4824, 'Рошаля, 52', 26);
INSERT INTO stroy.address VALUES (4825, 'Тамбовская, 31', 14);
INSERT INTO stroy.address VALUES (4826, 'Фрязевская, 24', 44);
INSERT INTO stroy.address VALUES (4827, 'Малая Колхозная, 84', 45);
INSERT INTO stroy.address VALUES (4828, 'Кетчерская, 54', 22);
INSERT INTO stroy.address VALUES (4829, 'Дорошенко, 3', 12);
INSERT INTO stroy.address VALUES (4830, 'Хамовнический Вал, 80', 27);
INSERT INTO stroy.address VALUES (4831, 'Подстанция, 7', 23);
INSERT INTO stroy.address VALUES (4832, 'Инициативная, 71', 22);
INSERT INTO stroy.address VALUES (4833, 'Вахрушева, 15', 27);
INSERT INTO stroy.address VALUES (4834, 'Руставели, 94', 26);
INSERT INTO stroy.address VALUES (4835, 'Вяземская, 92', 34);
INSERT INTO stroy.address VALUES (4836, 'Петропавловская, 29', 18);
INSERT INTO stroy.address VALUES (4837, 'Белавинская, 15', 42);
INSERT INTO stroy.address VALUES (4838, 'Моховая, 39', 45);
INSERT INTO stroy.address VALUES (4839, 'Бойцов 9-Й Дивизии, 91', 1);
INSERT INTO stroy.address VALUES (4840, 'Фёдора Смирнова, 64', 19);
INSERT INTO stroy.address VALUES (4841, 'Малиновый Овраг, 71', 2);
INSERT INTO stroy.address VALUES (4842, 'Воронежская, 10', 32);
INSERT INTO stroy.address VALUES (4843, 'Волгоградская, 38', 13);
INSERT INTO stroy.address VALUES (4844, '60-Летия Октября, 31', 21);
INSERT INTO stroy.address VALUES (4845, 'Сталелитейная, 46', 39);
INSERT INTO stroy.address VALUES (4846, 'Белова, 80', 40);
INSERT INTO stroy.address VALUES (4847, 'Ушинского, 46', 42);
INSERT INTO stroy.address VALUES (4848, 'Пятилетки, 18', 2);
INSERT INTO stroy.address VALUES (4849, '50-Летия Комсомола, 38', 28);
INSERT INTO stroy.address VALUES (4850, 'Добровольцев Урала, 31', 6);
INSERT INTO stroy.address VALUES (4851, 'Садовая-Черногрязская, 51', 22);
INSERT INTO stroy.address VALUES (4852, 'Большая, 63', 28);
INSERT INTO stroy.address VALUES (4853, 'Ньютона, 29', 36);
INSERT INTO stroy.address VALUES (4854, 'Новоленинская, 97', 3);
INSERT INTO stroy.address VALUES (4855, 'Андропова, 5', 39);
INSERT INTO stroy.address VALUES (4856, 'Маринченко, 36', 12);
INSERT INTO stroy.address VALUES (4857, 'Горская, 56', 4);
INSERT INTO stroy.address VALUES (4858, 'Ляшенко, 85', 36);
INSERT INTO stroy.address VALUES (4859, 'Бутырская, 66', 25);
INSERT INTO stroy.address VALUES (4860, 'Московская, 62', 36);
INSERT INTO stroy.address VALUES (4861, 'Хлеборобов, 95', 46);
INSERT INTO stroy.address VALUES (4862, 'Мусоргского, 9', 13);
INSERT INTO stroy.address VALUES (4863, 'Мичурина, 46', 29);
INSERT INTO stroy.address VALUES (4864, 'Михаила Калинина, 26', 3);
INSERT INTO stroy.address VALUES (4865, 'Зернова, 85', 6);
INSERT INTO stroy.address VALUES (4866, 'Бебеля, 25', 46);
INSERT INTO stroy.address VALUES (4867, 'Механизаторов, 59', 16);
INSERT INTO stroy.address VALUES (4868, 'Геническая, 6', 18);
INSERT INTO stroy.address VALUES (4869, 'Генерала Кузнецова, 94', 17);
INSERT INTO stroy.address VALUES (4870, 'Самотёчная, 18', 45);
INSERT INTO stroy.address VALUES (4871, 'Бородинская, 20', 25);
INSERT INTO stroy.address VALUES (4872, 'Шацкая, 83', 40);
INSERT INTO stroy.address VALUES (4873, 'Железнодорожный Городок, 17', 42);
INSERT INTO stroy.address VALUES (4874, 'Павлова, 76', 21);
INSERT INTO stroy.address VALUES (4875, 'Маши Порываевой, 61', 38);
INSERT INTO stroy.address VALUES (4876, 'Безыменского, 64', 35);
INSERT INTO stroy.address VALUES (4877, 'Тюменская, 62', 23);
INSERT INTO stroy.address VALUES (4878, 'Космонавта Волкова, 32', 42);
INSERT INTO stroy.address VALUES (4879, 'Толстовская, 75', 45);
INSERT INTO stroy.address VALUES (4880, 'Брестская, 3', 45);
INSERT INTO stroy.address VALUES (4881, 'Вешняковская, 21', 19);
INSERT INTO stroy.address VALUES (4882, 'Большая Чернавская, 100', 14);
INSERT INTO stroy.address VALUES (4883, 'Ташкентская, 3', 27);
INSERT INTO stroy.address VALUES (4884, 'Троицкая, 76', 29);
INSERT INTO stroy.address VALUES (4885, 'Кетчерская, 100', 41);
INSERT INTO stroy.address VALUES (4886, 'Горки Киовские, 26', 7);
INSERT INTO stroy.address VALUES (4887, 'Новозыбковская, 94', 35);
INSERT INTO stroy.address VALUES (4888, 'Дружбы, 55', 7);
INSERT INTO stroy.address VALUES (4889, 'Пенькозаводская, 8', 24);
INSERT INTO stroy.address VALUES (4890, 'Комсомольцев Танкистов, 100', 20);
INSERT INTO stroy.address VALUES (4891, 'Героев Сибиряков, 48', 23);
INSERT INTO stroy.address VALUES (4892, 'Снежная, 27', 32);
INSERT INTO stroy.address VALUES (4893, 'Нововерховенская, 23', 6);
INSERT INTO stroy.address VALUES (4894, 'Саввинская, 77', 46);
INSERT INTO stroy.address VALUES (4895, 'Дмитрия Донского, 27', 30);
INSERT INTO stroy.address VALUES (4896, 'Седова, 41', 1);
INSERT INTO stroy.address VALUES (4897, 'Мичурина, 22', 15);
INSERT INTO stroy.address VALUES (4898, 'Шарикоподшипниковская, 71', 8);
INSERT INTO stroy.address VALUES (4899, 'Леволинейная, 2', 40);
INSERT INTO stroy.address VALUES (4900, 'Невского, 97', 2);
INSERT INTO stroy.address VALUES (4901, 'Грайворонская, 32', 36);
INSERT INTO stroy.address VALUES (4902, 'Жуковская, 41', 22);
INSERT INTO stroy.address VALUES (4903, 'Яшенина, 79', 6);
INSERT INTO stroy.address VALUES (4904, 'Киово, 32', 21);
INSERT INTO stroy.address VALUES (4905, 'Воробьёвка, 79', 43);
INSERT INTO stroy.address VALUES (4906, 'Академика Жукова, 58', 7);
INSERT INTO stroy.address VALUES (4907, 'Радбужская, 23', 22);
INSERT INTO stroy.address VALUES (4908, 'Тихонравова, 21', 16);
INSERT INTO stroy.address VALUES (4909, 'Никиты Головни, 32', 5);
INSERT INTO stroy.address VALUES (4910, 'Лютинская, 74', 37);
INSERT INTO stroy.address VALUES (4911, 'Осенняя, 95', 3);
INSERT INTO stroy.address VALUES (4912, 'Говорова, 85', 39);
INSERT INTO stroy.address VALUES (4913, 'Чугунова, 6', 33);
INSERT INTO stroy.address VALUES (4914, 'Черновицкая, 1', 19);
INSERT INTO stroy.address VALUES (4915, 'Большая Покровская, 20', 1);
INSERT INTO stroy.address VALUES (4916, 'Макарова, 53', 4);
INSERT INTO stroy.address VALUES (4917, 'Крюковка, 95', 28);
INSERT INTO stroy.address VALUES (4918, 'Николая Старостина, 8', 47);
INSERT INTO stroy.address VALUES (4919, 'Маросейка, 69', 19);
INSERT INTO stroy.address VALUES (4920, 'Суворова, 2', 1);
INSERT INTO stroy.address VALUES (4921, 'Первомайская, 91', 32);
INSERT INTO stroy.address VALUES (4922, 'Усти-На-Лабе, 77', 8);
INSERT INTO stroy.address VALUES (4923, 'Им. Островского, 98', 5);
INSERT INTO stroy.address VALUES (4924, 'Долгоруковская, 75', 12);
INSERT INTO stroy.address VALUES (4925, 'Текстильная, 13', 19);
INSERT INTO stroy.address VALUES (4926, 'Строителей, 49', 22);
INSERT INTO stroy.address VALUES (4927, '40 Лет Влксм, 94', 5);
INSERT INTO stroy.address VALUES (4928, 'Малая Калитниковская, 77', 45);
INSERT INTO stroy.address VALUES (4929, 'Красных Партизан, 90', 34);
INSERT INTO stroy.address VALUES (4930, 'Малых, 99', 44);
INSERT INTO stroy.address VALUES (4931, 'Петра I, 87', 38);
INSERT INTO stroy.address VALUES (4932, 'Соколово-Мещерская, 32', 30);
INSERT INTO stroy.address VALUES (4933, 'Энтузиастов, 49', 16);
INSERT INTO stroy.address VALUES (4934, 'Автомагистраль, 34', 2);
INSERT INTO stroy.address VALUES (4935, 'Нижняя Дебря, 63', 7);
INSERT INTO stroy.address VALUES (4936, 'Григория Соколова, 9', 37);
INSERT INTO stroy.address VALUES (4937, 'Зеленцовская, 34', 27);
INSERT INTO stroy.address VALUES (4938, 'Автомагистраль, 54', 3);
INSERT INTO stroy.address VALUES (4939, 'Ульяновская, 25', 29);
INSERT INTO stroy.address VALUES (4940, 'Студёновская, 52', 45);
INSERT INTO stroy.address VALUES (4941, 'Автострадная, 57', 10);
INSERT INTO stroy.address VALUES (4942, 'Цветаева, 47', 16);
INSERT INTO stroy.address VALUES (4943, 'Большая Павловская, 20', 10);
INSERT INTO stroy.address VALUES (4944, 'Александры Монаховой, 31', 13);
INSERT INTO stroy.address VALUES (4945, 'Барышиха, 50', 1);
INSERT INTO stroy.address VALUES (4946, 'Савина, 69', 41);
INSERT INTO stroy.address VALUES (4947, 'Малая Октябрьская, 81', 28);
INSERT INTO stroy.address VALUES (4948, 'Нормандия-Неман, 24', 41);
INSERT INTO stroy.address VALUES (4949, 'Фурманова, 29', 1);
INSERT INTO stroy.address VALUES (4950, 'Мещёрская, 14', 33);
INSERT INTO stroy.address VALUES (4951, 'Ананченко, 81', 17);
INSERT INTO stroy.address VALUES (4952, 'Николаева, 29', 11);
INSERT INTO stroy.address VALUES (4953, 'Академика Петровского, 52', 27);
INSERT INTO stroy.address VALUES (4954, 'Урицкого, 79', 47);
INSERT INTO stroy.address VALUES (4955, 'Киквидзе, 86', 44);
INSERT INTO stroy.address VALUES (4956, 'Лесная Поляна, 40', 17);
INSERT INTO stroy.address VALUES (4957, '1-Й Конной Армии, 24', 9);
INSERT INTO stroy.address VALUES (4958, 'Галичская, 75', 41);
INSERT INTO stroy.address VALUES (4959, 'Гоголева, 85', 33);
INSERT INTO stroy.address VALUES (4960, 'Крылатская, 65', 18);
INSERT INTO stroy.address VALUES (4961, 'Ромодановские Дворики, 52', 10);
INSERT INTO stroy.address VALUES (4962, 'Ильинская, 86', 31);
INSERT INTO stroy.address VALUES (4963, 'Балковская, 34', 11);
INSERT INTO stroy.address VALUES (4964, 'Горячева, 73', 41);
INSERT INTO stroy.address VALUES (4965, 'Панина, 53', 9);
INSERT INTO stroy.address VALUES (4966, 'Зарецкая, 46', 9);
INSERT INTO stroy.address VALUES (4967, 'Носкова, 27', 27);
INSERT INTO stroy.address VALUES (4968, 'Погодина, 40', 15);
INSERT INTO stroy.address VALUES (4969, 'Коммуны, 59', 4);
INSERT INTO stroy.address VALUES (4970, 'Костюкова, 96', 4);
INSERT INTO stroy.address VALUES (4971, 'Киёвка, 98', 35);
INSERT INTO stroy.address VALUES (4972, 'Озеро, 100', 8);
INSERT INTO stroy.address VALUES (4973, 'Багратиона, 42', 34);
INSERT INTO stroy.address VALUES (4974, 'Бирюзова, 96', 29);
INSERT INTO stroy.address VALUES (4975, 'Студёная Гора, 30', 26);
INSERT INTO stroy.address VALUES (4976, 'Коммунальная, 26', 20);
INSERT INTO stroy.address VALUES (4977, 'Большая Полянка, 45', 39);
INSERT INTO stroy.address VALUES (4978, 'Бориса Полевого, 40', 17);
INSERT INTO stroy.address VALUES (4979, 'Нижняя Краснохолмская, 81', 35);
INSERT INTO stroy.address VALUES (4980, 'Льнозаводская, 24', 9);
INSERT INTO stroy.address VALUES (4981, 'Кузнечная, 5', 3);
INSERT INTO stroy.address VALUES (4982, 'Большая Спасская, 83', 44);
INSERT INTO stroy.address VALUES (4983, 'Рудакова, 5', 11);
INSERT INTO stroy.address VALUES (4984, 'Верхняя Сыромятническая, 49', 26);
INSERT INTO stroy.address VALUES (4985, 'Халаева, 39', 17);
INSERT INTO stroy.address VALUES (4986, 'Ошмарина, 42', 27);
INSERT INTO stroy.address VALUES (4987, 'Прудовая, 64', 44);
INSERT INTO stroy.address VALUES (4988, '22 Января, 63', 39);
INSERT INTO stroy.address VALUES (4989, 'Терпигорева, 59', 10);
INSERT INTO stroy.address VALUES (4990, 'Александра Печерского, 39', 42);
INSERT INTO stroy.address VALUES (4991, 'Чичерина, 85', 45);
INSERT INTO stroy.address VALUES (4992, 'Станко, 25', 5);
INSERT INTO stroy.address VALUES (4993, 'Архитектора Бутовой, 95', 32);
INSERT INTO stroy.address VALUES (4994, 'Покровская, 21', 22);
INSERT INTO stroy.address VALUES (4995, 'Охотный Ряд, 7', 18);
INSERT INTO stroy.address VALUES (4996, 'Акри, 44', 3);
INSERT INTO stroy.address VALUES (4997, 'Пивзаводская, 67', 16);
INSERT INTO stroy.address VALUES (4998, 'Будёновская, 60', 26);
INSERT INTO stroy.address VALUES (4999, 'Дениса Давыдова, 60', 45);
INSERT INTO stroy.address VALUES (5000, 'Артёмовская, 71', 35);


--
-- TOC entry 5902 (class 0 OID 4886019)
-- Dependencies: 492
-- Data for Name: city; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.city VALUES (1, 'Ковров', 7);
INSERT INTO stroy.city VALUES (2, 'Липецк', 7);
INSERT INTO stroy.city VALUES (3, 'Воскресенск', 7);
INSERT INTO stroy.city VALUES (4, 'Калуга', 7);
INSERT INTO stroy.city VALUES (5, 'Коломна', 7);
INSERT INTO stroy.city VALUES (6, 'Красногорск', 7);
INSERT INTO stroy.city VALUES (7, 'Обнинск', 7);
INSERT INTO stroy.city VALUES (8, 'Химки', 7);
INSERT INTO stroy.city VALUES (9, 'Старый Оскол', 7);
INSERT INTO stroy.city VALUES (10, 'Электросталь', 7);
INSERT INTO stroy.city VALUES (11, 'Тверь', 7);
INSERT INTO stroy.city VALUES (12, 'Раменское', 7);
INSERT INTO stroy.city VALUES (13, 'Муром', 7);
INSERT INTO stroy.city VALUES (14, 'Сергиев Посад', 7);
INSERT INTO stroy.city VALUES (15, 'Балашиха', 7);
INSERT INTO stroy.city VALUES (16, 'Пушкино', 7);
INSERT INTO stroy.city VALUES (17, 'Курск', 7);
INSERT INTO stroy.city VALUES (18, 'Королёв', 7);
INSERT INTO stroy.city VALUES (19, 'Воронеж', 7);
INSERT INTO stroy.city VALUES (20, 'Орехово-Зуево', 7);
INSERT INTO stroy.city VALUES (21, 'Иваново', 7);
INSERT INTO stroy.city VALUES (22, 'Новомосковск', 7);
INSERT INTO stroy.city VALUES (23, 'Тамбов', 7);
INSERT INTO stroy.city VALUES (24, 'Владимир', 7);
INSERT INTO stroy.city VALUES (25, 'Брянск', 7);
INSERT INTO stroy.city VALUES (26, 'Зеленоград', 7);
INSERT INTO stroy.city VALUES (27, 'Рыбинск', 7);
INSERT INTO stroy.city VALUES (28, 'Москва', 7);
INSERT INTO stroy.city VALUES (29, 'Домодедово', 7);
INSERT INTO stroy.city VALUES (30, 'Люберцы', 7);
INSERT INTO stroy.city VALUES (31, 'Щёлково', 7);
INSERT INTO stroy.city VALUES (32, 'Подольск', 7);
INSERT INTO stroy.city VALUES (33, 'Жуковский', 7);
INSERT INTO stroy.city VALUES (34, 'Белгород', 7);
INSERT INTO stroy.city VALUES (35, 'Рязань', 7);
INSERT INTO stroy.city VALUES (36, 'Ногинск', 7);
INSERT INTO stroy.city VALUES (37, 'Мытищи', 7);
INSERT INTO stroy.city VALUES (38, 'Смоленск', 7);
INSERT INTO stroy.city VALUES (39, 'Долгопрудный', 7);
INSERT INTO stroy.city VALUES (40, 'Одинцово', 7);
INSERT INTO stroy.city VALUES (41, 'Ярославль', 7);
INSERT INTO stroy.city VALUES (42, 'Серпухов', 7);
INSERT INTO stroy.city VALUES (43, 'Узловая', 7);
INSERT INTO stroy.city VALUES (44, 'Кострома', 7);
INSERT INTO stroy.city VALUES (45, 'Орёл', 7);
INSERT INTO stroy.city VALUES (46, 'Тула', 7);
INSERT INTO stroy.city VALUES (47, 'Елец', 7);


--
-- TOC entry 5904 (class 0 OID 4886023)
-- Dependencies: 494
-- Data for Name: company_structure; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.company_structure VALUES (2, 0, 'Строительства', 3);
INSERT INTO stroy.company_structure VALUES (3, 0, 'Маркетинга и продаж', 3);
INSERT INTO stroy.company_structure VALUES (4, 0, 'Проектирования', 3);
INSERT INTO stroy.company_structure VALUES (5, 0, 'Административный', 3);
INSERT INTO stroy.company_structure VALUES (6, 0, 'Управления', 3);
INSERT INTO stroy.company_structure VALUES (1, 0, 'Финансов и кадров', 3);
INSERT INTO stroy.company_structure VALUES (7, 1, 'Бухгалтерия', 2);
INSERT INTO stroy.company_structure VALUES (8, 1, 'Финансовой аналитики', 2);
INSERT INTO stroy.company_structure VALUES (9, 1, 'HR и кадрового дела', 2);
INSERT INTO stroy.company_structure VALUES (10, 3, 'Маркетинга', 2);
INSERT INTO stroy.company_structure VALUES (11, 3, 'Продаж', 2);
INSERT INTO stroy.company_structure VALUES (12, 3, 'Связи с общественностью', 2);
INSERT INTO stroy.company_structure VALUES (13, 5, 'Закупок', 2);
INSERT INTO stroy.company_structure VALUES (14, 5, 'Контроль качества', 2);
INSERT INTO stroy.company_structure VALUES (15, 5, 'Охрана труда', 2);
INSERT INTO stroy.company_structure VALUES (16, 5, 'Безопасности', 2);
INSERT INTO stroy.company_structure VALUES (17, 4, 'Дизайна', 2);
INSERT INTO stroy.company_structure VALUES (18, 4, 'Конструкторских решений', 2);
INSERT INTO stroy.company_structure VALUES (19, 4, 'Инженерных сетей', 2);
INSERT INTO stroy.company_structure VALUES (20, 6, 'Управления проектами', 2);
INSERT INTO stroy.company_structure VALUES (21, 6, 'Девелопмента', 2);
INSERT INTO stroy.company_structure VALUES (22, 6, 'Согласования', 2);
INSERT INTO stroy.company_structure VALUES (23, 2, 'Строительный', 2);
INSERT INTO stroy.company_structure VALUES (24, 2, 'Технический', 2);
INSERT INTO stroy.company_structure VALUES (25, 2, 'Безопасности', 2);
INSERT INTO stroy.company_structure VALUES (26, 2, 'Противопожарных мероприятий', 2);
INSERT INTO stroy.company_structure VALUES (27, 2, 'Эксплуатации', 2);
INSERT INTO stroy.company_structure VALUES (83, 17, 'Группа №1', 4);
INSERT INTO stroy.company_structure VALUES (84, 17, 'Группа №2', 4);
INSERT INTO stroy.company_structure VALUES (85, 18, 'Группа №1', 4);
INSERT INTO stroy.company_structure VALUES (86, 18, 'Группа №2', 4);
INSERT INTO stroy.company_structure VALUES (100, 23, 'Группа №1', 4);
INSERT INTO stroy.company_structure VALUES (101, 24, 'Группа №1', 4);
INSERT INTO stroy.company_structure VALUES (102, 24, 'Группа №2', 4);
INSERT INTO stroy.company_structure VALUES (103, 25, 'Группа №1', 4);
INSERT INTO stroy.company_structure VALUES (104, 26, 'Группа №1', 4);
INSERT INTO stroy.company_structure VALUES (105, 27, 'Группа №1', 4);


--
-- TOC entry 5906 (class 0 OID 4886027)
-- Dependencies: 496
-- Data for Name: country; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.country VALUES (1, 'Азербайджан');
INSERT INTO stroy.country VALUES (2, 'Армения');
INSERT INTO stroy.country VALUES (3, 'Белоруссия');
INSERT INTO stroy.country VALUES (4, 'Казахстан');
INSERT INTO stroy.country VALUES (5, 'Киргизия');
INSERT INTO stroy.country VALUES (6, 'Молдавия');
INSERT INTO stroy.country VALUES (7, 'Россия');
INSERT INTO stroy.country VALUES (8, 'Таджикистан');
INSERT INTO stroy.country VALUES (9, 'Украина');


--
-- TOC entry 5908 (class 0 OID 4886031)
-- Dependencies: 498
-- Data for Name: customer; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.customer VALUES (1, 'Mollis Dui In Inc.', '+7 (549) 357-82-02', 'tortor.dictum@mail.com', 4109);
INSERT INTO stroy.customer VALUES (2, 'Non Hendrerit Institute', '+7 (207) 376-56-88', 'sit@rambler.org', 4334);
INSERT INTO stroy.customer VALUES (3, 'Montes Nascetur Incorporated', '+7 (614) 508-75-37', 'eget.massa@hotmail.ru', 3866);
INSERT INTO stroy.customer VALUES (4, 'A Sollicitudin Orci Associates', '+7 (802) 385-30-57', 'at.auctor@mail.org', 4085);
INSERT INTO stroy.customer VALUES (5, 'Vestibulum Neque Ltd', '+7 (587) 561-78-28', 'ut.tincidunt.orci@yahoo.ru', 2409);
INSERT INTO stroy.customer VALUES (6, 'Quis Turpis Associates', '+7 (550) 825-14-64', 'egestas@rambler.ru', 1634);
INSERT INTO stroy.customer VALUES (7, 'Adipiscing Elit Curabitur Corporation', '+7 (876) 786-37-71', 'vulputate.lacus@rambler.ru', 4779);
INSERT INTO stroy.customer VALUES (8, 'Commodo Auctor Velit PC', '+7 (228) 704-89-31', 'molestie.tortor@yandex.net', 3879);
INSERT INTO stroy.customer VALUES (9, 'Iaculis Quis PC', '+7 (556) 843-65-41', 'malesuada.vel@yahoo.com', 637);
INSERT INTO stroy.customer VALUES (10, 'Varius Nam Institute', '+7 (473) 573-57-24', 'fusce@rambler.ru', 4553);
INSERT INTO stroy.customer VALUES (11, 'Eu Ltd', '+7 (565) 514-98-20', 'suspendisse@rambler.ru', 3543);
INSERT INTO stroy.customer VALUES (12, 'Luctus Curabitur Egestas LLP', '+7 (717) 851-86-74', 'at@google.org', 14);
INSERT INTO stroy.customer VALUES (13, 'Nunc Laoreet Lectus Ltd', '+7 (473) 216-31-52', 'tortor.at@yahoo.org', 2854);
INSERT INTO stroy.customer VALUES (14, 'Augue Sed Molestie Corp.', '+7 (212) 415-67-84', 'mauris.non@yandex.ru', 1350);
INSERT INTO stroy.customer VALUES (15, 'Velit Quisque Associates', '+7 (852) 874-76-32', 'morbi.vehicula@rambler.ru', 2210);
INSERT INTO stroy.customer VALUES (16, 'Pede Ac Institute', '+7 (223) 664-73-65', 'cursus@google.net', 1124);
INSERT INTO stroy.customer VALUES (17, 'Elit Pede Industries', '+7 (612) 625-87-86', 'et.rutrum.non@mail.ru', 2650);
INSERT INTO stroy.customer VALUES (18, 'Cras Lorem Institute', '+7 (794) 588-65-77', 'a.ultricies@yahoo.org', 1511);
INSERT INTO stroy.customer VALUES (19, 'Non Consulting', '+7 (768) 308-90-77', 'molestie.tellus@yahoo.org', 3536);
INSERT INTO stroy.customer VALUES (20, 'Gravida Nunc Sed Corporation', '+7 (476) 582-60-09', 'lorem.eu@yandex.org', 3851);
INSERT INTO stroy.customer VALUES (21, 'Semper Dui PC', '+7 (218) 310-02-82', 'at.augue.id@rambler.net', 567);
INSERT INTO stroy.customer VALUES (22, 'In Tincidunt LLP', '+7 (624) 992-84-31', 'mauris.id@mail.com', 2151);
INSERT INTO stroy.customer VALUES (23, 'Aliquam Corporation', '+7 (488) 804-73-23', 'fringilla@google.net', 1685);
INSERT INTO stroy.customer VALUES (24, 'Diam Luctus Lobortis Incorporated', '+7 (967) 323-61-14', 'integer.in@hotmail.org', 3931);
INSERT INTO stroy.customer VALUES (25, 'Pede Nonummy Ut Associates', '+7 (518) 428-07-12', 'vehicula@hotmail.org', 20);
INSERT INTO stroy.customer VALUES (26, 'Nullam Scelerisque Neque Institute', '+7 (702) 388-70-17', 'nulla.eu@yahoo.org', 2339);
INSERT INTO stroy.customer VALUES (27, 'Eu Eleifend Foundation', '+7 (915) 223-15-27', 'vitae.semper@google.com', 4845);
INSERT INTO stroy.customer VALUES (28, 'Magnis Dis Associates', '+7 (249) 512-26-21', 'ornare.facilisis@mail.com', 3492);
INSERT INTO stroy.customer VALUES (29, 'Blandit Mattis Associates', '+7 (842) 252-26-52', 'proin.non@mail.ru', 3368);
INSERT INTO stroy.customer VALUES (30, 'Rhoncus Nullam Ltd', '+7 (239) 871-95-23', 'eget.ipsum.donec@mail.net', 380);
INSERT INTO stroy.customer VALUES (31, 'Natoque Penatibus Et Associates', '+7 (928) 884-56-87', 'luctus.lobortis.class@hotmail.com', 2659);
INSERT INTO stroy.customer VALUES (32, 'Consectetuer Adipiscing Ltd', '+7 (915) 372-15-25', 'vestibulum.nec.euismod@yahoo.org', 1037);
INSERT INTO stroy.customer VALUES (33, 'Accumsan Corp.', '+7 (178) 661-36-86', 'mauris.eu.turpis@hotmail.net', 2850);
INSERT INTO stroy.customer VALUES (34, 'Risus Quisque PC', '+7 (502) 636-53-32', 'justo.eu@hotmail.com', 1044);
INSERT INTO stroy.customer VALUES (35, 'Semper Et LLP', '+7 (872) 865-13-03', 'amet@hotmail.net', 3498);
INSERT INTO stroy.customer VALUES (36, 'Nec Ante Blandit Inc.', '+7 (531) 145-74-57', 'morbi.tristique@google.org', 1129);
INSERT INTO stroy.customer VALUES (37, 'Non Nisi Consulting', '+7 (213) 745-33-21', 'urna.convallis.erat@google.ru', 3807);
INSERT INTO stroy.customer VALUES (38, 'Semper Auctor Incorporated', '+7 (751) 954-65-68', 'arcu.vivamus.sit@mail.org', 1747);
INSERT INTO stroy.customer VALUES (39, 'Magna Ut Corporation', '+7 (914) 546-13-35', 'vel@yandex.ru', 3381);
INSERT INTO stroy.customer VALUES (40, 'Non Lorem Industries', '+7 (688) 247-43-61', 'gravida@rambler.org', 4920);
INSERT INTO stroy.customer VALUES (41, 'Ligula Eu Consulting', '+7 (486) 313-46-22', 'diam.proin@mail.com', 1542);
INSERT INTO stroy.customer VALUES (42, 'Est Vitae Incorporated', '+7 (241) 726-76-48', 'lorem.sit@google.net', 4047);
INSERT INTO stroy.customer VALUES (43, 'Proin Vel Company', '+7 (355) 667-05-92', 'a.dui.cras@google.net', 4405);
INSERT INTO stroy.customer VALUES (44, 'Eu Placerat PC', '+7 (844) 574-81-09', 'amet.consectetuer.adipiscing@google.org', 2418);
INSERT INTO stroy.customer VALUES (45, 'Sed Nulla PC', '+7 (155) 584-20-12', 'mollis.nec@rambler.ru', 1544);
INSERT INTO stroy.customer VALUES (46, 'Nonummy Ipsum Limited', '+7 (862) 732-54-67', 'nunc.ac.mattis@hotmail.com', 4993);
INSERT INTO stroy.customer VALUES (47, 'Eros Turpis Consulting', '+7 (420) 837-55-04', 'consectetuer.rhoncus@rambler.net', 4095);
INSERT INTO stroy.customer VALUES (48, 'Sed Pede Corp.', '+7 (593) 595-91-11', 'nullam@yandex.com', 4777);
INSERT INTO stroy.customer VALUES (49, 'Auctor Velit Limited', '+7 (172) 672-67-33', 'diam.dictum@rambler.com', 1263);
INSERT INTO stroy.customer VALUES (50, 'Eu Associates', '+7 (257) 521-15-52', 'in.molestie@mail.com', 4837);
INSERT INTO stroy.customer VALUES (51, 'Justo Sit LLC', '+7 (423) 946-54-06', 'vel.quam@yandex.ru', 2411);
INSERT INTO stroy.customer VALUES (52, 'Lorem Semper LLC', '+7 (762) 728-09-12', 'velit.justo@yahoo.com', 4703);
INSERT INTO stroy.customer VALUES (53, 'Elit Dictum LLP', '+7 (583) 848-87-71', 'nunc@yahoo.org', 3346);
INSERT INTO stroy.customer VALUES (54, 'Tempor Corp.', '+7 (797) 486-86-06', 'egestas.a@yandex.ru', 3840);
INSERT INTO stroy.customer VALUES (55, 'Arcu Industries', '+7 (317) 330-55-01', 'vel.mauris@yandex.net', 1564);
INSERT INTO stroy.customer VALUES (56, 'Fusce Diam Corp.', '+7 (774) 846-31-67', 'risus.quisque.libero@hotmail.net', 3185);
INSERT INTO stroy.customer VALUES (57, 'Cum Sociis PC', '+7 (381) 260-21-28', 'feugiat.nec@google.com', 4435);
INSERT INTO stroy.customer VALUES (58, 'Elit Associates', '+7 (812) 186-79-11', 'erat.etiam@yahoo.org', 1451);
INSERT INTO stroy.customer VALUES (59, 'Feugiat Lorem Ipsum LLP', '+7 (324) 605-27-41', 'congue.a.aliquet@hotmail.org', 4858);
INSERT INTO stroy.customer VALUES (60, 'Eleifend Ltd', '+7 (484) 387-41-30', 'egestas@yahoo.ru', 4841);
INSERT INTO stroy.customer VALUES (61, 'Aliquam Consulting', '+7 (367) 888-77-27', 'nulla.facilisis@hotmail.org', 2430);
INSERT INTO stroy.customer VALUES (62, 'Quis Diam Institute', '+7 (943) 363-96-87', 'blandit.viverra@hotmail.org', 1249);
INSERT INTO stroy.customer VALUES (63, 'Eget Tincidunt Industries', '+7 (643) 487-53-16', 'enim.sit@mail.org', 367);
INSERT INTO stroy.customer VALUES (64, 'Est Nunc Incorporated', '+7 (319) 126-32-57', 'egestas.nunc@rambler.com', 3254);
INSERT INTO stroy.customer VALUES (65, 'Sit Amet Risus Foundation', '+7 (986) 979-56-74', 'felis.nulla@rambler.ru', 961);
INSERT INTO stroy.customer VALUES (66, 'Suspendisse Dui Institute', '+7 (268) 385-78-27', 'ad@rambler.com', 1065);
INSERT INTO stroy.customer VALUES (67, 'Sagittis Duis Industries', '+7 (940) 458-17-72', 'metus.vitae@yahoo.ru', 3659);
INSERT INTO stroy.customer VALUES (68, 'Vivamus Nibh Institute', '+7 (664) 342-38-36', 'ligula.nullam@google.com', 2786);
INSERT INTO stroy.customer VALUES (69, 'Ac Mattis LLC', '+7 (878) 367-18-58', 'sed.nec.metus@yahoo.net', 2286);
INSERT INTO stroy.customer VALUES (70, 'Aliquam Limited', '+7 (570) 326-52-60', 'ultricies.adipiscing.enim@yandex.ru', 2375);
INSERT INTO stroy.customer VALUES (71, 'Nunc Interdum Corp.', '+7 (279) 542-44-43', 'eu.eleifend.nec@mail.com', 858);
INSERT INTO stroy.customer VALUES (72, 'Parturient Montes Nascetur Incorporated', '+7 (706) 413-21-24', 'aliquet.lobortis.nisi@yahoo.org', 2947);
INSERT INTO stroy.customer VALUES (73, 'Nulla Donec LLC', '+7 (688) 524-74-03', 'semper.cursus@yandex.ru', 2199);
INSERT INTO stroy.customer VALUES (74, 'Augue Scelerisque PC', '+7 (239) 601-56-74', 'placerat@hotmail.net', 1900);
INSERT INTO stroy.customer VALUES (75, 'Nunc LLP', '+7 (145) 789-82-83', 'etiam@rambler.com', 1921);
INSERT INTO stroy.customer VALUES (76, 'Elit Curabitur Industries', '+7 (516) 690-28-63', 'elit.dictum@mail.com', 2845);
INSERT INTO stroy.customer VALUES (77, 'Adipiscing Lobortis Incorporated', '+7 (743) 195-42-84', 'pharetra@mail.org', 2233);
INSERT INTO stroy.customer VALUES (78, 'Pede Sagittis LLC', '+7 (486) 805-34-21', 'ut@mail.net', 4363);
INSERT INTO stroy.customer VALUES (79, 'Arcu Industries', '+7 (717) 302-24-79', 'urna.vivamus@google.org', 1381);
INSERT INTO stroy.customer VALUES (80, 'Donec At Inc.', '+7 (656) 236-99-44', 'sed.et@google.net', 1655);
INSERT INTO stroy.customer VALUES (81, 'Semper Rutrum Inc.', '+7 (577) 211-02-59', 'phasellus@google.net', 3860);
INSERT INTO stroy.customer VALUES (82, 'Justo Nec Ltd', '+7 (153) 638-45-14', 'non@yahoo.com', 1302);
INSERT INTO stroy.customer VALUES (83, 'Ipsum Non Arcu Institute', '+7 (529) 531-65-86', 'pharetra.nibh@google.com', 4926);
INSERT INTO stroy.customer VALUES (84, 'Ultrices Vivamus Corp.', '+7 (832) 549-92-82', 'viverra.maecenas@yahoo.ru', 3327);
INSERT INTO stroy.customer VALUES (85, 'Phasellus Fermentum Convallis Inc.', '+7 (356) 248-21-54', 'ridiculus.mus.proin@yandex.com', 3880);
INSERT INTO stroy.customer VALUES (86, 'Nunc Ac Mattis Institute', '+7 (519) 212-58-00', 'pede.malesuada@yahoo.net', 901);
INSERT INTO stroy.customer VALUES (87, 'Purus Inc.', '+7 (403) 335-15-48', 'facilisis@hotmail.ru', 1101);
INSERT INTO stroy.customer VALUES (88, 'At Risus Nunc Institute', '+7 (747) 618-34-27', 'suscipit.nonummy@yahoo.ru', 2024);
INSERT INTO stroy.customer VALUES (89, 'Sed Hendrerit Inc.', '+7 (714) 265-16-83', 'donec@hotmail.com', 1061);
INSERT INTO stroy.customer VALUES (90, 'Commodo At LLP', '+7 (630) 882-53-83', 'sem@mail.com', 3754);
INSERT INTO stroy.customer VALUES (91, 'Ullamcorper Nisl Limited', '+7 (699) 725-67-36', 'mauris.ut.mi@mail.com', 1682);
INSERT INTO stroy.customer VALUES (92, 'Leo Institute', '+7 (727) 546-75-48', 'pellentesque@yandex.net', 3884);
INSERT INTO stroy.customer VALUES (93, 'Mollis Corporation', '+7 (621) 776-40-94', 'quam.a.felis@google.org', 3955);
INSERT INTO stroy.customer VALUES (94, 'Cras Corp.', '+7 (208) 752-94-23', 'ligula.aenean@google.ru', 1999);
INSERT INTO stroy.customer VALUES (95, 'Turpis Non Corp.', '+7 (553) 251-82-24', 'tellus.imperdiet@mail.net', 4852);
INSERT INTO stroy.customer VALUES (96, 'Justo Foundation', '+7 (953) 121-64-17', 'sagittis.semper.nam@yahoo.com', 3084);
INSERT INTO stroy.customer VALUES (97, 'Nec Associates', '+7 (775) 224-15-56', 'at@mail.com', 876);
INSERT INTO stroy.customer VALUES (98, 'Sed PC', '+7 (348) 204-79-71', 'phasellus.at@hotmail.org', 1868);
INSERT INTO stroy.customer VALUES (99, 'In Corporation', '+7 (887) 325-89-83', 'dis@yahoo.net', 3249);
INSERT INTO stroy.customer VALUES (100, 'Amet PC', '+7 (602) 102-56-61', 'sed.et@google.net', 2685);
INSERT INTO stroy.customer VALUES (101, 'Mattis Incorporated', '+7 (521) 396-47-45', 'amet.orci@mail.net', 588);
INSERT INTO stroy.customer VALUES (102, 'Penatibus Et Incorporated', '+7 (377) 419-20-16', 'sed.neque@rambler.org', 3380);
INSERT INTO stroy.customer VALUES (103, 'Augue PC', '+7 (136) 210-61-60', 'enim.etiam@mail.com', 3735);
INSERT INTO stroy.customer VALUES (104, 'Augue Corp.', '+7 (681) 245-01-84', 'aliquam.gravida@rambler.ru', 4397);
INSERT INTO stroy.customer VALUES (105, 'Scelerisque Neque PC', '+7 (368) 343-58-44', 'non.sollicitudin@google.ru', 889);
INSERT INTO stroy.customer VALUES (106, 'Curabitur Massa Vestibulum Corp.', '+7 (228) 671-33-08', 'aliquet.nec@rambler.org', 4697);
INSERT INTO stroy.customer VALUES (107, 'Vel Mauris Associates', '+7 (344) 233-13-66', 'at.libero@hotmail.ru', 1247);
INSERT INTO stroy.customer VALUES (108, 'Et Netus Corporation', '+7 (563) 451-76-05', 'suspendisse@hotmail.com', 3089);
INSERT INTO stroy.customer VALUES (109, 'Euismod Mauris LLC', '+7 (370) 558-22-91', 'suspendisse.sed@rambler.net', 4111);
INSERT INTO stroy.customer VALUES (110, 'Quam Curabitur Inc.', '+7 (562) 373-34-11', 'molestie.sodales@google.org', 949);
INSERT INTO stroy.customer VALUES (111, 'Penatibus Et Foundation', '+7 (821) 293-71-51', 'sagittis@mail.com', 3190);
INSERT INTO stroy.customer VALUES (112, 'Imperdiet Erat Nonummy LLC', '+7 (203) 142-75-68', 'et.magnis@yandex.ru', 4329);
INSERT INTO stroy.customer VALUES (113, 'Nunc Interdum Foundation', '+7 (422) 496-07-53', 'erat.etiam@google.ru', 1982);
INSERT INTO stroy.customer VALUES (114, 'Nam Nulla LLP', '+7 (462) 877-38-94', 'nullam@google.net', 3998);
INSERT INTO stroy.customer VALUES (115, 'A Nunc Foundation', '+7 (643) 808-93-26', 'quisque.imperdiet@hotmail.ru', 4301);
INSERT INTO stroy.customer VALUES (116, 'Montes Ltd', '+7 (773) 683-43-67', 'mauris.id@yandex.net', 1611);
INSERT INTO stroy.customer VALUES (117, 'Elit Pretium Corporation', '+7 (421) 364-82-45', 'est.mollis@hotmail.org', 3801);
INSERT INTO stroy.customer VALUES (118, 'Penatibus PC', '+7 (375) 624-34-22', 'vivamus.nibh@mail.net', 3134);
INSERT INTO stroy.customer VALUES (119, 'Justo Institute', '+7 (622) 479-29-26', 'id.enim.curabitur@google.net', 501);
INSERT INTO stroy.customer VALUES (120, 'Integer Urna Ltd', '+7 (951) 214-15-32', 'sem.mollis@yandex.org', 3189);
INSERT INTO stroy.customer VALUES (121, 'Odio Vel Corporation', '+7 (425) 685-49-40', 'facilisis.non@yandex.org', 2565);
INSERT INTO stroy.customer VALUES (122, 'Nisi Aenean Ltd', '+7 (756) 546-83-56', 'tristique.neque.venenatis@rambler.ru', 3780);
INSERT INTO stroy.customer VALUES (123, 'Mauris Non Foundation', '+7 (827) 565-54-50', 'dui.nec@hotmail.com', 4198);
INSERT INTO stroy.customer VALUES (124, 'Eget Inc.', '+7 (503) 904-45-42', 'elit.erat.vitae@hotmail.org', 3724);
INSERT INTO stroy.customer VALUES (125, 'Cras LLC', '+7 (422) 374-30-22', 'integer.mollis.integer@yandex.ru', 3872);
INSERT INTO stroy.customer VALUES (126, 'Tellus Faucibus Institute', '+7 (588) 835-66-63', 'dapibus.id@mail.com', 4536);
INSERT INTO stroy.customer VALUES (127, 'Nulla Industries', '+7 (830) 222-34-36', 'nulla.ante.iaculis@mail.net', 1954);
INSERT INTO stroy.customer VALUES (128, 'Ut Inc.', '+7 (344) 256-33-24', 'nibh.vulputate.mauris@rambler.net', 3050);
INSERT INTO stroy.customer VALUES (129, 'Turpis Nulla Aliquet Corp.', '+7 (142) 655-21-52', 'diam.lorem.auctor@rambler.ru', 1725);
INSERT INTO stroy.customer VALUES (130, 'Tellus Suspendisse LLP', '+7 (433) 261-82-32', 'ridiculus.mus.proin@yandex.net', 11);
INSERT INTO stroy.customer VALUES (131, 'Mauris Magna Associates', '+7 (794) 618-87-46', 'consequat.dolor.vitae@rambler.com', 4352);
INSERT INTO stroy.customer VALUES (132, 'Lectus Quis Industries', '+7 (977) 500-81-80', 'laoreet.lectus@rambler.com', 2145);
INSERT INTO stroy.customer VALUES (133, 'Adipiscing Fringilla Corp.', '+7 (768) 215-71-28', 'donec.non@mail.ru', 112);
INSERT INTO stroy.customer VALUES (134, 'Sed Facilisis PC', '+7 (275) 845-31-92', 'ipsum.dolor.sit@yandex.com', 3298);
INSERT INTO stroy.customer VALUES (135, 'Integer Tincidunt LLC', '+7 (712) 984-25-21', 'ultricies.ornare@rambler.ru', 4338);
INSERT INTO stroy.customer VALUES (136, 'Sed Turpis Nec Consulting', '+7 (685) 643-01-25', 'nullam.feugiat@google.net', 1221);
INSERT INTO stroy.customer VALUES (137, 'Tellus Imperdiet Non Corp.', '+7 (751) 751-55-04', 'libero.integer@yandex.org', 291);
INSERT INTO stroy.customer VALUES (138, 'Tristique Aliquet Limited', '+7 (607) 923-27-90', 'eros.turpis@yahoo.ru', 2426);
INSERT INTO stroy.customer VALUES (139, 'Magna Sed Corp.', '+7 (564) 726-13-21', 'augue.malesuada@yandex.net', 1823);
INSERT INTO stroy.customer VALUES (140, 'Risus Quis Diam Corporation', '+7 (772) 249-96-63', 'lorem.fringilla@yahoo.com', 458);
INSERT INTO stroy.customer VALUES (141, 'Proin Eget Industries', '+7 (521) 767-13-54', 'nunc@mail.ru', 2038);
INSERT INTO stroy.customer VALUES (142, 'Metus In Associates', '+7 (257) 223-73-34', 'diam.luctus.lobortis@google.com', 1790);
INSERT INTO stroy.customer VALUES (143, 'A Feugiat Corporation', '+7 (555) 548-25-48', 'id@yahoo.com', 4905);
INSERT INTO stroy.customer VALUES (144, 'Ultrices Duis Foundation', '+7 (590) 861-38-17', 'eleifend.vitae@yahoo.ru', 1560);
INSERT INTO stroy.customer VALUES (145, 'Aenean Eget Consulting', '+7 (839) 805-99-74', 'laoreet.ipsum@mail.org', 1846);
INSERT INTO stroy.customer VALUES (146, 'Est Tempor Bibendum LLP', '+7 (237) 887-17-24', 'vitae.nibh@yahoo.net', 2167);
INSERT INTO stroy.customer VALUES (147, 'Phasellus Dapibus Limited', '+7 (242) 472-28-00', 'quam.elementum@hotmail.org', 1714);
INSERT INTO stroy.customer VALUES (148, 'Venenatis Lacus Foundation', '+7 (645) 374-81-47', 'cursus.in@rambler.org', 2116);
INSERT INTO stroy.customer VALUES (149, 'Pellentesque Tincidunt Corp.', '+7 (638) 179-67-31', 'fermentum.convallis.ligula@rambler.org', 858);
INSERT INTO stroy.customer VALUES (150, 'Semper Dui Inc.', '+7 (516) 359-04-24', 'dignissim.tempor@yahoo.net', 3124);
INSERT INTO stroy.customer VALUES (151, 'Eu Euismod Industries', '+7 (326) 933-17-35', 'rhoncus.proin@hotmail.ru', 2988);
INSERT INTO stroy.customer VALUES (152, 'Magna Incorporated', '+7 (735) 745-47-29', 'cras.vulputate@yahoo.net', 2948);
INSERT INTO stroy.customer VALUES (153, 'Euismod Enim LLP', '+7 (647) 524-77-03', 'ac.tellus@google.ru', 3675);
INSERT INTO stroy.customer VALUES (154, 'At Sem Ltd', '+7 (194) 537-43-57', 'at.lacus@yahoo.com', 2146);
INSERT INTO stroy.customer VALUES (155, 'Aliquet Nec LLP', '+7 (211) 281-42-39', 'quis@yandex.org', 1691);
INSERT INTO stroy.customer VALUES (156, 'At Foundation', '+7 (368) 818-08-19', 'tincidunt.congue.turpis@hotmail.net', 2073);
INSERT INTO stroy.customer VALUES (157, 'At Corporation', '+7 (761) 187-97-16', 'interdum@rambler.org', 1944);
INSERT INTO stroy.customer VALUES (158, 'Adipiscing Fringilla Corporation', '+7 (623) 693-20-27', 'duis.dignissim@rambler.com', 2354);
INSERT INTO stroy.customer VALUES (159, 'Habitant Morbi Tristique Corp.', '+7 (334) 965-02-13', 'convallis@hotmail.ru', 915);
INSERT INTO stroy.customer VALUES (160, 'Curabitur Inc.', '+7 (828) 776-78-45', 'erat.neque@google.net', 4106);
INSERT INTO stroy.customer VALUES (161, 'Sit Amet Massa Institute', '+7 (437) 612-57-82', 'vivamus.molestie.dapibus@google.ru', 1496);
INSERT INTO stroy.customer VALUES (162, 'Vulputate Velit Eu Incorporated', '+7 (438) 287-26-91', 'ac.libero@google.org', 3713);
INSERT INTO stroy.customer VALUES (163, 'Inceptos Inc.', '+7 (547) 743-49-33', 'tellus@rambler.ru', 3126);
INSERT INTO stroy.customer VALUES (164, 'Amet Ornare Lectus Associates', '+7 (586) 264-26-56', 'commodo.ipsum@google.net', 2292);
INSERT INTO stroy.customer VALUES (165, 'At Associates', '+7 (781) 728-68-63', 'aliquet.magna@rambler.ru', 624);
INSERT INTO stroy.customer VALUES (166, 'Sed Company', '+7 (697) 358-62-55', 'in@google.ru', 4514);
INSERT INTO stroy.customer VALUES (167, 'Sed Eget Lacus Company', '+7 (732) 473-56-21', 'porttitor.interdum@rambler.net', 4132);
INSERT INTO stroy.customer VALUES (168, 'Nullam Institute', '+7 (852) 237-40-64', 'eros@mail.org', 4019);
INSERT INTO stroy.customer VALUES (169, 'Interdum Institute', '+7 (104) 492-41-44', 'nibh@yandex.org', 3527);
INSERT INTO stroy.customer VALUES (170, 'Aliquet Lobortis LLC', '+7 (763) 342-63-70', 'eu.nibh@google.com', 128);
INSERT INTO stroy.customer VALUES (171, 'Neque Pellentesque Limited', '+7 (259) 758-14-55', 'lobortis.class.aptent@mail.net', 1189);
INSERT INTO stroy.customer VALUES (172, 'Phasellus Dolor LLC', '+7 (528) 973-89-86', 'eget.mollis@rambler.net', 1574);
INSERT INTO stroy.customer VALUES (173, 'Amet Foundation', '+7 (172) 543-28-48', 'enim.mauris.quis@google.com', 4334);
INSERT INTO stroy.customer VALUES (174, 'Massa Rutrum PC', '+7 (622) 557-08-20', 'fusce.dolor.quam@yandex.net', 3676);
INSERT INTO stroy.customer VALUES (175, 'Enim Foundation', '+7 (359) 977-12-34', 'velit.eu@hotmail.com', 1518);
INSERT INTO stroy.customer VALUES (176, 'Dolor Fusce Feugiat LLP', '+7 (463) 282-48-85', 'ante@hotmail.net', 2283);
INSERT INTO stroy.customer VALUES (177, 'Maecenas Ornare Corp.', '+7 (274) 648-93-36', 'mauris.morbi.non@mail.ru', 1876);
INSERT INTO stroy.customer VALUES (178, 'Euismod Et Limited', '+7 (488) 426-71-18', 'amet.ornare@yandex.org', 1663);
INSERT INTO stroy.customer VALUES (179, 'Auctor Velit Limited', '+7 (623) 267-20-88', 'curabitur.massa@mail.com', 4637);
INSERT INTO stroy.customer VALUES (180, 'Eu Nulla Industries', '+7 (122) 857-42-16', 'eget@google.com', 1314);
INSERT INTO stroy.customer VALUES (181, 'Cubilia Curae Associates', '+7 (755) 442-57-60', 'facilisis.lorem@hotmail.org', 1442);
INSERT INTO stroy.customer VALUES (182, 'Mi Pede PC', '+7 (843) 898-73-90', 'risus.quis@google.ru', 837);
INSERT INTO stroy.customer VALUES (183, 'Id Nunc Institute', '+7 (876) 618-14-35', 'aliquet.lobortis@rambler.com', 4304);
INSERT INTO stroy.customer VALUES (184, 'Id Magna Limited', '+7 (971) 445-24-83', 'nunc@hotmail.ru', 780);
INSERT INTO stroy.customer VALUES (185, 'Pede Malesuada Company', '+7 (466) 902-48-21', 'mauris.eu@yandex.net', 925);
INSERT INTO stroy.customer VALUES (186, 'Natoque Penatibus Inc.', '+7 (517) 837-98-60', 'sem@google.ru', 1817);
INSERT INTO stroy.customer VALUES (187, 'Eros Turpis Non Industries', '+7 (134) 446-20-51', 'orci.in@google.org', 1387);
INSERT INTO stroy.customer VALUES (188, 'Nisi Mauris Incorporated', '+7 (516) 382-42-38', 'lacinia@yahoo.org', 2949);
INSERT INTO stroy.customer VALUES (189, 'Purus Foundation', '+7 (524) 194-32-11', 'mus@yandex.ru', 1768);
INSERT INTO stroy.customer VALUES (190, 'Semper Auctor Institute', '+7 (403) 158-55-44', 'cras@google.com', 3874);
INSERT INTO stroy.customer VALUES (191, 'Ridiculus Mus Associates', '+7 (778) 682-21-78', 'ipsum.sodales@hotmail.org', 4774);
INSERT INTO stroy.customer VALUES (192, 'Sapien Imperdiet Incorporated', '+7 (125) 239-33-02', 'nec.orci@mail.com', 4611);
INSERT INTO stroy.customer VALUES (193, 'Vivamus Nibh Dolor Inc.', '+7 (687) 841-61-26', 'donec.sollicitudin@hotmail.ru', 808);
INSERT INTO stroy.customer VALUES (194, 'Duis Gravida Inc.', '+7 (392) 864-31-80', 'vitae.diam.proin@yandex.net', 3002);
INSERT INTO stroy.customer VALUES (195, 'Nec Euismod Inc.', '+7 (779) 876-21-52', 'vehicula@yandex.org', 3175);
INSERT INTO stroy.customer VALUES (196, 'Eu Erat Associates', '+7 (768) 139-95-46', 'eu@hotmail.org', 2255);
INSERT INTO stroy.customer VALUES (197, 'Odio Auctor Vitae PC', '+7 (413) 758-36-63', 'a@google.org', 4906);
INSERT INTO stroy.customer VALUES (198, 'Mi LLC', '+7 (118) 429-18-58', 'quam.curabitur@hotmail.com', 2931);
INSERT INTO stroy.customer VALUES (199, 'Ut Ltd', '+7 (218) 675-45-72', 'metus@yandex.net', 1805);
INSERT INTO stroy.customer VALUES (200, 'Nisl Sem Ltd', '+7 (274) 318-44-32', 'mi.felis@mail.org', 3648);
INSERT INTO stroy.customer VALUES (201, 'Placerat Institute', '+7 (887) 876-29-42', 'consectetuer.adipiscing.elit@hotmail.com', 208);
INSERT INTO stroy.customer VALUES (202, 'Congue In PC', '+7 (368) 214-90-29', 'nisi.aenean.eget@yahoo.ru', 2518);
INSERT INTO stroy.customer VALUES (203, 'Gravida Sagittis Institute', '+7 (761) 343-53-64', 'tempor.lorem@hotmail.ru', 2464);
INSERT INTO stroy.customer VALUES (204, 'Dui Quis Limited', '+7 (542) 344-62-36', 'odio.semper@rambler.org', 3230);
INSERT INTO stroy.customer VALUES (205, 'Luctus Ut Pellentesque Foundation', '+7 (872) 863-18-86', 'bibendum.fermentum@rambler.org', 2076);
INSERT INTO stroy.customer VALUES (206, 'Magna Duis PC', '+7 (318) 472-87-25', 'parturient.montes@google.com', 976);
INSERT INTO stroy.customer VALUES (207, 'Urna Nunc Quis Associates', '+7 (865) 157-94-82', 'convallis.convallis.dolor@mail.com', 3132);
INSERT INTO stroy.customer VALUES (208, 'Dui Quis Accumsan Limited', '+7 (324) 459-77-19', 'nullam.nisl@hotmail.ru', 278);
INSERT INTO stroy.customer VALUES (209, 'Rhoncus Id Associates', '+7 (717) 556-74-32', 'amet.massa.quisque@rambler.ru', 2097);
INSERT INTO stroy.customer VALUES (210, 'Nulla Facilisi PC', '+7 (602) 789-89-40', 'donec.sollicitudin.adipiscing@rambler.org', 451);
INSERT INTO stroy.customer VALUES (211, 'Consequat Incorporated', '+7 (761) 457-59-66', 'enim.etiam@yahoo.net', 908);
INSERT INTO stroy.customer VALUES (212, 'Facilisi Incorporated', '+7 (836) 645-44-19', 'dis.parturient@yahoo.com', 1166);
INSERT INTO stroy.customer VALUES (213, 'Magnis Dis Foundation', '+7 (776) 255-23-25', 'pede@google.org', 4051);
INSERT INTO stroy.customer VALUES (214, 'Orci Quis Lectus Corporation', '+7 (549) 474-95-30', 'aliquam.vulputate@google.ru', 1237);
INSERT INTO stroy.customer VALUES (215, 'Suspendisse PC', '+7 (762) 491-03-36', 'a.tortor@mail.org', 1442);
INSERT INTO stroy.customer VALUES (216, 'Lorem Associates', '+7 (660) 358-90-27', 'nunc@hotmail.net', 1471);
INSERT INTO stroy.customer VALUES (217, 'Mauris Elit Dictum Ltd', '+7 (758) 958-51-34', 'lacus.nulla@yahoo.ru', 1705);
INSERT INTO stroy.customer VALUES (218, 'Gravida Non Foundation', '+7 (436) 389-94-39', 'porttitor.eros@yahoo.ru', 3082);
INSERT INTO stroy.customer VALUES (219, 'Sed Company', '+7 (513) 666-48-24', 'vestibulum.nec.euismod@yandex.org', 815);
INSERT INTO stroy.customer VALUES (220, 'Aliquam Fringilla Inc.', '+7 (724) 348-77-85', 'dolor.quisque.tincidunt@mail.com', 4800);
INSERT INTO stroy.customer VALUES (221, 'Montes Nascetur Ridiculus Limited', '+7 (999) 127-17-28', 'mus.donec@mail.org', 3580);
INSERT INTO stroy.customer VALUES (222, 'Bibendum Sed Est Associates', '+7 (616) 733-27-80', 'non@hotmail.ru', 2624);
INSERT INTO stroy.customer VALUES (223, 'Mauris A Corporation', '+7 (628) 448-75-92', 'ac@hotmail.org', 3720);
INSERT INTO stroy.customer VALUES (224, 'Diam Vel Limited', '+7 (225) 363-43-68', 'ligula.nullam.feugiat@hotmail.org', 546);
INSERT INTO stroy.customer VALUES (225, 'Semper LLP', '+7 (534) 843-27-14', 'felis.adipiscing@yahoo.org', 2174);
INSERT INTO stroy.customer VALUES (226, 'Neque Sed LLP', '+7 (455) 578-24-18', 'fermentum.vel@yandex.com', 3341);
INSERT INTO stroy.customer VALUES (227, 'Arcu LLP', '+7 (586) 681-12-77', 'erat.in@yandex.ru', 1333);
INSERT INTO stroy.customer VALUES (228, 'Nullam Enim Company', '+7 (527) 130-86-84', 'a.enim@mail.net', 3060);
INSERT INTO stroy.customer VALUES (229, 'Sed Dui Foundation', '+7 (592) 321-76-70', 'mi.felis@yandex.ru', 640);
INSERT INTO stroy.customer VALUES (230, 'Nulla Aliquet Foundation', '+7 (318) 354-18-43', 'mauris.sapien@yahoo.ru', 3515);
INSERT INTO stroy.customer VALUES (231, 'Molestie Orci Corp.', '+7 (260) 155-37-08', 'taciti.sociosqu.ad@yandex.com', 3163);
INSERT INTO stroy.customer VALUES (232, 'Eu Tellus Phasellus PC', '+7 (349) 852-34-56', 'vestibulum.massa@hotmail.net', 1217);
INSERT INTO stroy.customer VALUES (233, 'Congue Elit Sed Ltd', '+7 (669) 381-75-70', 'vulputate.velit@yandex.com', 959);
INSERT INTO stroy.customer VALUES (234, 'Metus Consulting', '+7 (348) 378-61-74', 'nulla.ante.iaculis@yandex.ru', 4242);
INSERT INTO stroy.customer VALUES (235, 'Erat Vitae Risus PC', '+7 (752) 250-59-60', 'elit@yandex.ru', 2963);
INSERT INTO stroy.customer VALUES (236, 'Ac Urna LLP', '+7 (696) 843-30-42', 'urna.justo@yahoo.org', 4956);
INSERT INTO stroy.customer VALUES (237, 'Sit Amet Nulla Industries', '+7 (194) 642-86-79', 'et@yandex.org', 1596);
INSERT INTO stroy.customer VALUES (238, 'Bibendum Donec Industries', '+7 (139) 716-15-19', 'consequat.lectus.sit@hotmail.net', 3435);
INSERT INTO stroy.customer VALUES (239, 'Eros Nam Consequat Consulting', '+7 (657) 223-84-15', 'vel.turpis@google.org', 2201);
INSERT INTO stroy.customer VALUES (240, 'Et Commodo Corporation', '+7 (157) 320-13-16', 'neque@yandex.com', 578);
INSERT INTO stroy.customer VALUES (241, 'Enim Condimentum Ltd', '+7 (657) 611-95-49', 'a.enim.suspendisse@hotmail.com', 699);
INSERT INTO stroy.customer VALUES (242, 'Mi Industries', '+7 (227) 471-86-88', 'sagittis.lobortis.mauris@rambler.com', 3419);
INSERT INTO stroy.customer VALUES (243, 'Cum Corp.', '+7 (823) 285-93-12', 'iaculis.enim@google.com', 4760);
INSERT INTO stroy.customer VALUES (244, 'Duis Mi Industries', '+7 (332) 634-77-15', 'vivamus.nisi@yahoo.com', 4520);
INSERT INTO stroy.customer VALUES (245, 'Elementum Dui Quis Inc.', '+7 (152) 587-46-47', 'egestas.a@google.ru', 1663);
INSERT INTO stroy.customer VALUES (246, 'Purus Mauris Corp.', '+7 (987) 670-37-57', 'amet@yahoo.net', 635);
INSERT INTO stroy.customer VALUES (247, 'Pharetra Felis Corp.', '+7 (185) 445-18-00', 'nam.consequat@yahoo.org', 1555);
INSERT INTO stroy.customer VALUES (248, 'Ipsum Corporation', '+7 (556) 311-77-16', 'morbi@hotmail.net', 4580);
INSERT INTO stroy.customer VALUES (249, 'Non Hendrerit Id Corp.', '+7 (160) 745-42-18', 'interdum.sed@yandex.ru', 1174);
INSERT INTO stroy.customer VALUES (250, 'Fusce Diam Incorporated', '+7 (425) 261-35-65', 'aenean@yahoo.ru', 611);
INSERT INTO stroy.customer VALUES (251, 'Blandit Associates', '+7 (766) 227-44-27', 'semper.cursus@hotmail.com', 1251);
INSERT INTO stroy.customer VALUES (252, 'Mauris Molestie Pharetra LLP', '+7 (112) 304-53-83', 'ut.dolor@yahoo.com', 3782);
INSERT INTO stroy.customer VALUES (253, 'Orci Ut PC', '+7 (866) 220-80-44', 'neque.nullam.ut@hotmail.net', 360);
INSERT INTO stroy.customer VALUES (254, 'Iaculis Odio Company', '+7 (187) 268-44-45', 'orci.ut@google.com', 1602);
INSERT INTO stroy.customer VALUES (255, 'Rutrum Incorporated', '+7 (749) 593-42-70', 'consequat.purus.maecenas@hotmail.com', 3229);
INSERT INTO stroy.customer VALUES (256, 'Eu Euismod Industries', '+7 (278) 342-67-29', 'eget.metus@yandex.ru', 2108);
INSERT INTO stroy.customer VALUES (257, 'Euismod Ac Fermentum Limited', '+7 (157) 782-55-01', 'mauris.elit.dictum@mail.ru', 1294);
INSERT INTO stroy.customer VALUES (258, 'Habitant Morbi Limited', '+7 (931) 684-46-45', 'id.ante@hotmail.com', 1837);
INSERT INTO stroy.customer VALUES (259, 'In Institute', '+7 (611) 210-31-35', 'enim.commodo@yandex.org', 2594);
INSERT INTO stroy.customer VALUES (260, 'Donec PC', '+7 (854) 716-75-41', 'mollis.lectus@yahoo.net', 189);
INSERT INTO stroy.customer VALUES (261, 'Nec Tellus Nunc Limited', '+7 (440) 973-75-22', 'ut.erat@rambler.net', 4657);
INSERT INTO stroy.customer VALUES (262, 'Praesent Interdum Ligula Institute', '+7 (707) 744-21-89', 'non.bibendum.sed@mail.ru', 3898);
INSERT INTO stroy.customer VALUES (263, 'Sociosqu Incorporated', '+7 (611) 711-33-11', 'pharetra.nam.ac@hotmail.org', 1818);
INSERT INTO stroy.customer VALUES (264, 'Ligula Nullam Industries', '+7 (755) 261-53-65', 'erat.volutpat.nulla@mail.com', 3760);
INSERT INTO stroy.customer VALUES (265, 'Non Luctus Incorporated', '+7 (883) 414-92-45', 'non.lobortis.quis@rambler.org', 4342);
INSERT INTO stroy.customer VALUES (266, 'Vel Arcu LLP', '+7 (138) 984-87-46', 'quisque.varius.nam@mail.org', 4164);
INSERT INTO stroy.customer VALUES (267, 'Adipiscing Lobortis Risus Institute', '+7 (846) 881-34-63', 'cursus.nunc.mauris@google.com', 4718);
INSERT INTO stroy.customer VALUES (268, 'Ante Vivamus Ltd', '+7 (480) 520-28-76', 'mauris@yahoo.com', 3438);
INSERT INTO stroy.customer VALUES (269, 'Arcu Ltd', '+7 (384) 643-37-63', 'congue.a.aliquet@yahoo.org', 3213);
INSERT INTO stroy.customer VALUES (270, 'Accumsan Laoreet PC', '+7 (931) 901-52-94', 'libero.donec@hotmail.org', 2877);
INSERT INTO stroy.customer VALUES (271, 'A Ultricies LLP', '+7 (373) 722-57-13', 'tincidunt@mail.net', 2195);
INSERT INTO stroy.customer VALUES (272, 'Eu Odio LLP', '+7 (342) 654-87-51', 'mauris@yahoo.net', 3668);
INSERT INTO stroy.customer VALUES (273, 'Etiam Imperdiet Industries', '+7 (414) 623-87-24', 'morbi.tristique.senectus@mail.ru', 261);
INSERT INTO stroy.customer VALUES (274, 'Velit Eu LLP', '+7 (182) 910-35-50', 'arcu.aliquam.ultrices@rambler.net', 3878);
INSERT INTO stroy.customer VALUES (275, 'Vulputate Limited', '+7 (238) 255-74-66', 'sed.et@hotmail.ru', 1673);
INSERT INTO stroy.customer VALUES (276, 'Aliquet Foundation', '+7 (754) 596-38-93', 'libero.nec@yahoo.org', 1099);
INSERT INTO stroy.customer VALUES (277, 'Sit Amet Lorem Limited', '+7 (470) 848-53-52', 'in@google.net', 163);
INSERT INTO stroy.customer VALUES (278, 'Mollis Nec Institute', '+7 (256) 361-20-64', 'tempus.eu@mail.com', 358);


--
-- TOC entry 5910 (class 0 OID 4886036)
-- Dependencies: 500
-- Data for Name: customer_type_of_work; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.customer_type_of_work VALUES (1, 3);
INSERT INTO stroy.customer_type_of_work VALUES (1, 7);
INSERT INTO stroy.customer_type_of_work VALUES (1, 6);
INSERT INTO stroy.customer_type_of_work VALUES (2, 3);
INSERT INTO stroy.customer_type_of_work VALUES (2, 4);
INSERT INTO stroy.customer_type_of_work VALUES (2, 5);
INSERT INTO stroy.customer_type_of_work VALUES (3, 6);
INSERT INTO stroy.customer_type_of_work VALUES (3, 7);
INSERT INTO stroy.customer_type_of_work VALUES (3, 4);
INSERT INTO stroy.customer_type_of_work VALUES (4, 7);
INSERT INTO stroy.customer_type_of_work VALUES (5, 4);
INSERT INTO stroy.customer_type_of_work VALUES (5, 5);
INSERT INTO stroy.customer_type_of_work VALUES (5, 2);
INSERT INTO stroy.customer_type_of_work VALUES (6, 6);
INSERT INTO stroy.customer_type_of_work VALUES (6, 5);
INSERT INTO stroy.customer_type_of_work VALUES (7, 6);
INSERT INTO stroy.customer_type_of_work VALUES (7, 4);
INSERT INTO stroy.customer_type_of_work VALUES (7, 2);
INSERT INTO stroy.customer_type_of_work VALUES (8, 6);
INSERT INTO stroy.customer_type_of_work VALUES (9, 2);
INSERT INTO stroy.customer_type_of_work VALUES (9, 4);
INSERT INTO stroy.customer_type_of_work VALUES (9, 5);
INSERT INTO stroy.customer_type_of_work VALUES (10, 6);
INSERT INTO stroy.customer_type_of_work VALUES (11, 4);
INSERT INTO stroy.customer_type_of_work VALUES (12, 5);
INSERT INTO stroy.customer_type_of_work VALUES (12, 4);
INSERT INTO stroy.customer_type_of_work VALUES (12, 1);
INSERT INTO stroy.customer_type_of_work VALUES (13, 1);
INSERT INTO stroy.customer_type_of_work VALUES (13, 4);
INSERT INTO stroy.customer_type_of_work VALUES (14, 1);
INSERT INTO stroy.customer_type_of_work VALUES (15, 7);
INSERT INTO stroy.customer_type_of_work VALUES (15, 5);
INSERT INTO stroy.customer_type_of_work VALUES (15, 3);
INSERT INTO stroy.customer_type_of_work VALUES (16, 3);
INSERT INTO stroy.customer_type_of_work VALUES (17, 3);
INSERT INTO stroy.customer_type_of_work VALUES (17, 7);
INSERT INTO stroy.customer_type_of_work VALUES (17, 6);
INSERT INTO stroy.customer_type_of_work VALUES (18, 4);
INSERT INTO stroy.customer_type_of_work VALUES (18, 3);
INSERT INTO stroy.customer_type_of_work VALUES (18, 6);
INSERT INTO stroy.customer_type_of_work VALUES (19, 2);
INSERT INTO stroy.customer_type_of_work VALUES (19, 7);
INSERT INTO stroy.customer_type_of_work VALUES (19, 6);
INSERT INTO stroy.customer_type_of_work VALUES (20, 3);
INSERT INTO stroy.customer_type_of_work VALUES (20, 2);
INSERT INTO stroy.customer_type_of_work VALUES (21, 6);
INSERT INTO stroy.customer_type_of_work VALUES (22, 6);
INSERT INTO stroy.customer_type_of_work VALUES (22, 2);
INSERT INTO stroy.customer_type_of_work VALUES (22, 3);
INSERT INTO stroy.customer_type_of_work VALUES (23, 5);
INSERT INTO stroy.customer_type_of_work VALUES (23, 1);
INSERT INTO stroy.customer_type_of_work VALUES (24, 4);
INSERT INTO stroy.customer_type_of_work VALUES (25, 7);
INSERT INTO stroy.customer_type_of_work VALUES (25, 6);
INSERT INTO stroy.customer_type_of_work VALUES (25, 5);
INSERT INTO stroy.customer_type_of_work VALUES (26, 3);
INSERT INTO stroy.customer_type_of_work VALUES (27, 6);
INSERT INTO stroy.customer_type_of_work VALUES (27, 3);
INSERT INTO stroy.customer_type_of_work VALUES (28, 6);
INSERT INTO stroy.customer_type_of_work VALUES (28, 5);
INSERT INTO stroy.customer_type_of_work VALUES (28, 4);
INSERT INTO stroy.customer_type_of_work VALUES (29, 2);
INSERT INTO stroy.customer_type_of_work VALUES (30, 3);
INSERT INTO stroy.customer_type_of_work VALUES (31, 1);
INSERT INTO stroy.customer_type_of_work VALUES (32, 3);
INSERT INTO stroy.customer_type_of_work VALUES (32, 6);
INSERT INTO stroy.customer_type_of_work VALUES (32, 5);
INSERT INTO stroy.customer_type_of_work VALUES (33, 2);
INSERT INTO stroy.customer_type_of_work VALUES (33, 6);
INSERT INTO stroy.customer_type_of_work VALUES (33, 3);
INSERT INTO stroy.customer_type_of_work VALUES (34, 2);
INSERT INTO stroy.customer_type_of_work VALUES (34, 6);
INSERT INTO stroy.customer_type_of_work VALUES (34, 4);
INSERT INTO stroy.customer_type_of_work VALUES (35, 1);
INSERT INTO stroy.customer_type_of_work VALUES (35, 5);
INSERT INTO stroy.customer_type_of_work VALUES (36, 7);
INSERT INTO stroy.customer_type_of_work VALUES (36, 1);
INSERT INTO stroy.customer_type_of_work VALUES (37, 3);
INSERT INTO stroy.customer_type_of_work VALUES (38, 7);
INSERT INTO stroy.customer_type_of_work VALUES (38, 3);
INSERT INTO stroy.customer_type_of_work VALUES (38, 2);
INSERT INTO stroy.customer_type_of_work VALUES (39, 7);
INSERT INTO stroy.customer_type_of_work VALUES (39, 1);
INSERT INTO stroy.customer_type_of_work VALUES (40, 3);
INSERT INTO stroy.customer_type_of_work VALUES (40, 6);
INSERT INTO stroy.customer_type_of_work VALUES (40, 2);
INSERT INTO stroy.customer_type_of_work VALUES (41, 5);
INSERT INTO stroy.customer_type_of_work VALUES (41, 2);
INSERT INTO stroy.customer_type_of_work VALUES (41, 1);
INSERT INTO stroy.customer_type_of_work VALUES (42, 2);
INSERT INTO stroy.customer_type_of_work VALUES (43, 1);
INSERT INTO stroy.customer_type_of_work VALUES (44, 1);
INSERT INTO stroy.customer_type_of_work VALUES (44, 7);
INSERT INTO stroy.customer_type_of_work VALUES (44, 2);
INSERT INTO stroy.customer_type_of_work VALUES (45, 2);
INSERT INTO stroy.customer_type_of_work VALUES (46, 2);
INSERT INTO stroy.customer_type_of_work VALUES (46, 3);
INSERT INTO stroy.customer_type_of_work VALUES (47, 1);
INSERT INTO stroy.customer_type_of_work VALUES (48, 5);
INSERT INTO stroy.customer_type_of_work VALUES (48, 7);
INSERT INTO stroy.customer_type_of_work VALUES (48, 6);
INSERT INTO stroy.customer_type_of_work VALUES (49, 7);
INSERT INTO stroy.customer_type_of_work VALUES (50, 1);
INSERT INTO stroy.customer_type_of_work VALUES (50, 4);
INSERT INTO stroy.customer_type_of_work VALUES (51, 6);
INSERT INTO stroy.customer_type_of_work VALUES (52, 4);
INSERT INTO stroy.customer_type_of_work VALUES (53, 5);
INSERT INTO stroy.customer_type_of_work VALUES (54, 5);
INSERT INTO stroy.customer_type_of_work VALUES (54, 7);
INSERT INTO stroy.customer_type_of_work VALUES (54, 2);
INSERT INTO stroy.customer_type_of_work VALUES (55, 4);
INSERT INTO stroy.customer_type_of_work VALUES (55, 7);
INSERT INTO stroy.customer_type_of_work VALUES (55, 1);
INSERT INTO stroy.customer_type_of_work VALUES (56, 1);
INSERT INTO stroy.customer_type_of_work VALUES (57, 5);
INSERT INTO stroy.customer_type_of_work VALUES (57, 4);
INSERT INTO stroy.customer_type_of_work VALUES (57, 2);
INSERT INTO stroy.customer_type_of_work VALUES (58, 3);
INSERT INTO stroy.customer_type_of_work VALUES (59, 3);
INSERT INTO stroy.customer_type_of_work VALUES (59, 7);
INSERT INTO stroy.customer_type_of_work VALUES (59, 1);
INSERT INTO stroy.customer_type_of_work VALUES (60, 3);
INSERT INTO stroy.customer_type_of_work VALUES (60, 4);
INSERT INTO stroy.customer_type_of_work VALUES (60, 6);
INSERT INTO stroy.customer_type_of_work VALUES (61, 3);
INSERT INTO stroy.customer_type_of_work VALUES (61, 4);
INSERT INTO stroy.customer_type_of_work VALUES (62, 2);
INSERT INTO stroy.customer_type_of_work VALUES (62, 1);
INSERT INTO stroy.customer_type_of_work VALUES (62, 7);
INSERT INTO stroy.customer_type_of_work VALUES (63, 1);
INSERT INTO stroy.customer_type_of_work VALUES (63, 4);
INSERT INTO stroy.customer_type_of_work VALUES (63, 7);
INSERT INTO stroy.customer_type_of_work VALUES (64, 6);
INSERT INTO stroy.customer_type_of_work VALUES (64, 3);
INSERT INTO stroy.customer_type_of_work VALUES (65, 2);
INSERT INTO stroy.customer_type_of_work VALUES (65, 5);
INSERT INTO stroy.customer_type_of_work VALUES (65, 6);
INSERT INTO stroy.customer_type_of_work VALUES (66, 4);
INSERT INTO stroy.customer_type_of_work VALUES (66, 6);
INSERT INTO stroy.customer_type_of_work VALUES (66, 7);
INSERT INTO stroy.customer_type_of_work VALUES (67, 6);
INSERT INTO stroy.customer_type_of_work VALUES (67, 1);
INSERT INTO stroy.customer_type_of_work VALUES (68, 5);
INSERT INTO stroy.customer_type_of_work VALUES (69, 2);
INSERT INTO stroy.customer_type_of_work VALUES (70, 4);
INSERT INTO stroy.customer_type_of_work VALUES (70, 7);
INSERT INTO stroy.customer_type_of_work VALUES (71, 4);
INSERT INTO stroy.customer_type_of_work VALUES (71, 1);
INSERT INTO stroy.customer_type_of_work VALUES (72, 7);
INSERT INTO stroy.customer_type_of_work VALUES (72, 4);
INSERT INTO stroy.customer_type_of_work VALUES (72, 1);
INSERT INTO stroy.customer_type_of_work VALUES (73, 3);
INSERT INTO stroy.customer_type_of_work VALUES (74, 6);
INSERT INTO stroy.customer_type_of_work VALUES (74, 1);
INSERT INTO stroy.customer_type_of_work VALUES (74, 7);
INSERT INTO stroy.customer_type_of_work VALUES (75, 2);
INSERT INTO stroy.customer_type_of_work VALUES (76, 1);
INSERT INTO stroy.customer_type_of_work VALUES (76, 7);
INSERT INTO stroy.customer_type_of_work VALUES (76, 3);
INSERT INTO stroy.customer_type_of_work VALUES (77, 7);
INSERT INTO stroy.customer_type_of_work VALUES (77, 5);
INSERT INTO stroy.customer_type_of_work VALUES (78, 4);
INSERT INTO stroy.customer_type_of_work VALUES (78, 1);
INSERT INTO stroy.customer_type_of_work VALUES (78, 7);
INSERT INTO stroy.customer_type_of_work VALUES (79, 5);
INSERT INTO stroy.customer_type_of_work VALUES (80, 7);
INSERT INTO stroy.customer_type_of_work VALUES (80, 3);
INSERT INTO stroy.customer_type_of_work VALUES (81, 4);
INSERT INTO stroy.customer_type_of_work VALUES (81, 7);
INSERT INTO stroy.customer_type_of_work VALUES (82, 1);
INSERT INTO stroy.customer_type_of_work VALUES (82, 4);
INSERT INTO stroy.customer_type_of_work VALUES (83, 1);
INSERT INTO stroy.customer_type_of_work VALUES (83, 4);
INSERT INTO stroy.customer_type_of_work VALUES (83, 3);
INSERT INTO stroy.customer_type_of_work VALUES (84, 4);
INSERT INTO stroy.customer_type_of_work VALUES (84, 5);
INSERT INTO stroy.customer_type_of_work VALUES (84, 2);
INSERT INTO stroy.customer_type_of_work VALUES (85, 4);
INSERT INTO stroy.customer_type_of_work VALUES (85, 2);
INSERT INTO stroy.customer_type_of_work VALUES (85, 3);
INSERT INTO stroy.customer_type_of_work VALUES (86, 6);
INSERT INTO stroy.customer_type_of_work VALUES (86, 1);
INSERT INTO stroy.customer_type_of_work VALUES (87, 1);
INSERT INTO stroy.customer_type_of_work VALUES (87, 2);
INSERT INTO stroy.customer_type_of_work VALUES (88, 6);
INSERT INTO stroy.customer_type_of_work VALUES (89, 6);
INSERT INTO stroy.customer_type_of_work VALUES (90, 2);
INSERT INTO stroy.customer_type_of_work VALUES (90, 5);
INSERT INTO stroy.customer_type_of_work VALUES (90, 6);
INSERT INTO stroy.customer_type_of_work VALUES (91, 3);
INSERT INTO stroy.customer_type_of_work VALUES (92, 3);
INSERT INTO stroy.customer_type_of_work VALUES (92, 7);
INSERT INTO stroy.customer_type_of_work VALUES (92, 5);
INSERT INTO stroy.customer_type_of_work VALUES (93, 5);
INSERT INTO stroy.customer_type_of_work VALUES (93, 6);
INSERT INTO stroy.customer_type_of_work VALUES (93, 4);
INSERT INTO stroy.customer_type_of_work VALUES (94, 6);
INSERT INTO stroy.customer_type_of_work VALUES (94, 3);
INSERT INTO stroy.customer_type_of_work VALUES (95, 7);
INSERT INTO stroy.customer_type_of_work VALUES (95, 6);
INSERT INTO stroy.customer_type_of_work VALUES (96, 5);
INSERT INTO stroy.customer_type_of_work VALUES (96, 4);
INSERT INTO stroy.customer_type_of_work VALUES (96, 6);
INSERT INTO stroy.customer_type_of_work VALUES (97, 1);
INSERT INTO stroy.customer_type_of_work VALUES (97, 6);
INSERT INTO stroy.customer_type_of_work VALUES (97, 7);
INSERT INTO stroy.customer_type_of_work VALUES (98, 5);
INSERT INTO stroy.customer_type_of_work VALUES (98, 4);
INSERT INTO stroy.customer_type_of_work VALUES (99, 6);
INSERT INTO stroy.customer_type_of_work VALUES (99, 7);
INSERT INTO stroy.customer_type_of_work VALUES (100, 6);
INSERT INTO stroy.customer_type_of_work VALUES (100, 5);
INSERT INTO stroy.customer_type_of_work VALUES (100, 1);
INSERT INTO stroy.customer_type_of_work VALUES (101, 2);
INSERT INTO stroy.customer_type_of_work VALUES (101, 4);
INSERT INTO stroy.customer_type_of_work VALUES (102, 2);
INSERT INTO stroy.customer_type_of_work VALUES (102, 1);
INSERT INTO stroy.customer_type_of_work VALUES (103, 3);
INSERT INTO stroy.customer_type_of_work VALUES (103, 7);
INSERT INTO stroy.customer_type_of_work VALUES (103, 6);
INSERT INTO stroy.customer_type_of_work VALUES (104, 2);
INSERT INTO stroy.customer_type_of_work VALUES (104, 6);
INSERT INTO stroy.customer_type_of_work VALUES (105, 2);
INSERT INTO stroy.customer_type_of_work VALUES (106, 2);
INSERT INTO stroy.customer_type_of_work VALUES (107, 1);
INSERT INTO stroy.customer_type_of_work VALUES (108, 6);
INSERT INTO stroy.customer_type_of_work VALUES (109, 5);
INSERT INTO stroy.customer_type_of_work VALUES (110, 5);
INSERT INTO stroy.customer_type_of_work VALUES (110, 3);
INSERT INTO stroy.customer_type_of_work VALUES (110, 4);
INSERT INTO stroy.customer_type_of_work VALUES (111, 3);
INSERT INTO stroy.customer_type_of_work VALUES (111, 6);
INSERT INTO stroy.customer_type_of_work VALUES (112, 5);
INSERT INTO stroy.customer_type_of_work VALUES (112, 2);
INSERT INTO stroy.customer_type_of_work VALUES (113, 6);
INSERT INTO stroy.customer_type_of_work VALUES (114, 7);
INSERT INTO stroy.customer_type_of_work VALUES (115, 6);
INSERT INTO stroy.customer_type_of_work VALUES (115, 2);
INSERT INTO stroy.customer_type_of_work VALUES (115, 1);
INSERT INTO stroy.customer_type_of_work VALUES (116, 7);
INSERT INTO stroy.customer_type_of_work VALUES (117, 2);
INSERT INTO stroy.customer_type_of_work VALUES (117, 3);
INSERT INTO stroy.customer_type_of_work VALUES (117, 5);
INSERT INTO stroy.customer_type_of_work VALUES (118, 6);
INSERT INTO stroy.customer_type_of_work VALUES (119, 3);
INSERT INTO stroy.customer_type_of_work VALUES (120, 3);
INSERT INTO stroy.customer_type_of_work VALUES (121, 7);
INSERT INTO stroy.customer_type_of_work VALUES (122, 7);
INSERT INTO stroy.customer_type_of_work VALUES (122, 3);
INSERT INTO stroy.customer_type_of_work VALUES (123, 4);
INSERT INTO stroy.customer_type_of_work VALUES (123, 6);
INSERT INTO stroy.customer_type_of_work VALUES (123, 2);
INSERT INTO stroy.customer_type_of_work VALUES (124, 3);
INSERT INTO stroy.customer_type_of_work VALUES (124, 7);
INSERT INTO stroy.customer_type_of_work VALUES (124, 6);
INSERT INTO stroy.customer_type_of_work VALUES (125, 5);
INSERT INTO stroy.customer_type_of_work VALUES (126, 4);
INSERT INTO stroy.customer_type_of_work VALUES (127, 7);
INSERT INTO stroy.customer_type_of_work VALUES (127, 1);
INSERT INTO stroy.customer_type_of_work VALUES (127, 4);
INSERT INTO stroy.customer_type_of_work VALUES (128, 7);
INSERT INTO stroy.customer_type_of_work VALUES (129, 2);
INSERT INTO stroy.customer_type_of_work VALUES (129, 5);
INSERT INTO stroy.customer_type_of_work VALUES (130, 3);
INSERT INTO stroy.customer_type_of_work VALUES (131, 5);
INSERT INTO stroy.customer_type_of_work VALUES (132, 6);
INSERT INTO stroy.customer_type_of_work VALUES (132, 1);
INSERT INTO stroy.customer_type_of_work VALUES (133, 1);
INSERT INTO stroy.customer_type_of_work VALUES (133, 4);
INSERT INTO stroy.customer_type_of_work VALUES (134, 5);
INSERT INTO stroy.customer_type_of_work VALUES (135, 6);
INSERT INTO stroy.customer_type_of_work VALUES (135, 2);
INSERT INTO stroy.customer_type_of_work VALUES (135, 4);
INSERT INTO stroy.customer_type_of_work VALUES (136, 3);
INSERT INTO stroy.customer_type_of_work VALUES (136, 7);
INSERT INTO stroy.customer_type_of_work VALUES (137, 3);
INSERT INTO stroy.customer_type_of_work VALUES (137, 4);
INSERT INTO stroy.customer_type_of_work VALUES (137, 1);
INSERT INTO stroy.customer_type_of_work VALUES (138, 5);
INSERT INTO stroy.customer_type_of_work VALUES (139, 4);
INSERT INTO stroy.customer_type_of_work VALUES (140, 5);
INSERT INTO stroy.customer_type_of_work VALUES (140, 4);
INSERT INTO stroy.customer_type_of_work VALUES (141, 5);
INSERT INTO stroy.customer_type_of_work VALUES (142, 2);
INSERT INTO stroy.customer_type_of_work VALUES (142, 4);
INSERT INTO stroy.customer_type_of_work VALUES (143, 1);
INSERT INTO stroy.customer_type_of_work VALUES (144, 7);
INSERT INTO stroy.customer_type_of_work VALUES (144, 6);
INSERT INTO stroy.customer_type_of_work VALUES (145, 7);
INSERT INTO stroy.customer_type_of_work VALUES (145, 5);
INSERT INTO stroy.customer_type_of_work VALUES (146, 3);
INSERT INTO stroy.customer_type_of_work VALUES (146, 4);
INSERT INTO stroy.customer_type_of_work VALUES (146, 7);
INSERT INTO stroy.customer_type_of_work VALUES (147, 3);
INSERT INTO stroy.customer_type_of_work VALUES (147, 2);
INSERT INTO stroy.customer_type_of_work VALUES (147, 4);
INSERT INTO stroy.customer_type_of_work VALUES (148, 2);
INSERT INTO stroy.customer_type_of_work VALUES (148, 6);
INSERT INTO stroy.customer_type_of_work VALUES (149, 4);
INSERT INTO stroy.customer_type_of_work VALUES (150, 3);
INSERT INTO stroy.customer_type_of_work VALUES (150, 6);
INSERT INTO stroy.customer_type_of_work VALUES (150, 7);
INSERT INTO stroy.customer_type_of_work VALUES (151, 1);
INSERT INTO stroy.customer_type_of_work VALUES (151, 4);
INSERT INTO stroy.customer_type_of_work VALUES (152, 2);
INSERT INTO stroy.customer_type_of_work VALUES (152, 7);
INSERT INTO stroy.customer_type_of_work VALUES (152, 3);
INSERT INTO stroy.customer_type_of_work VALUES (153, 6);
INSERT INTO stroy.customer_type_of_work VALUES (153, 5);
INSERT INTO stroy.customer_type_of_work VALUES (153, 4);
INSERT INTO stroy.customer_type_of_work VALUES (154, 2);
INSERT INTO stroy.customer_type_of_work VALUES (155, 4);
INSERT INTO stroy.customer_type_of_work VALUES (156, 5);
INSERT INTO stroy.customer_type_of_work VALUES (156, 2);
INSERT INTO stroy.customer_type_of_work VALUES (156, 1);
INSERT INTO stroy.customer_type_of_work VALUES (157, 4);
INSERT INTO stroy.customer_type_of_work VALUES (157, 3);
INSERT INTO stroy.customer_type_of_work VALUES (158, 3);
INSERT INTO stroy.customer_type_of_work VALUES (158, 1);
INSERT INTO stroy.customer_type_of_work VALUES (159, 1);
INSERT INTO stroy.customer_type_of_work VALUES (159, 5);
INSERT INTO stroy.customer_type_of_work VALUES (159, 7);
INSERT INTO stroy.customer_type_of_work VALUES (160, 2);
INSERT INTO stroy.customer_type_of_work VALUES (160, 5);
INSERT INTO stroy.customer_type_of_work VALUES (161, 6);
INSERT INTO stroy.customer_type_of_work VALUES (162, 6);
INSERT INTO stroy.customer_type_of_work VALUES (163, 5);
INSERT INTO stroy.customer_type_of_work VALUES (164, 3);
INSERT INTO stroy.customer_type_of_work VALUES (164, 1);
INSERT INTO stroy.customer_type_of_work VALUES (164, 7);
INSERT INTO stroy.customer_type_of_work VALUES (165, 2);
INSERT INTO stroy.customer_type_of_work VALUES (165, 7);
INSERT INTO stroy.customer_type_of_work VALUES (166, 3);
INSERT INTO stroy.customer_type_of_work VALUES (166, 2);
INSERT INTO stroy.customer_type_of_work VALUES (166, 4);
INSERT INTO stroy.customer_type_of_work VALUES (167, 1);
INSERT INTO stroy.customer_type_of_work VALUES (168, 2);
INSERT INTO stroy.customer_type_of_work VALUES (168, 5);
INSERT INTO stroy.customer_type_of_work VALUES (169, 3);
INSERT INTO stroy.customer_type_of_work VALUES (169, 5);
INSERT INTO stroy.customer_type_of_work VALUES (170, 7);
INSERT INTO stroy.customer_type_of_work VALUES (170, 2);
INSERT INTO stroy.customer_type_of_work VALUES (170, 6);
INSERT INTO stroy.customer_type_of_work VALUES (171, 5);
INSERT INTO stroy.customer_type_of_work VALUES (171, 4);
INSERT INTO stroy.customer_type_of_work VALUES (171, 7);
INSERT INTO stroy.customer_type_of_work VALUES (172, 4);
INSERT INTO stroy.customer_type_of_work VALUES (172, 2);
INSERT INTO stroy.customer_type_of_work VALUES (173, 1);
INSERT INTO stroy.customer_type_of_work VALUES (174, 4);
INSERT INTO stroy.customer_type_of_work VALUES (174, 2);
INSERT INTO stroy.customer_type_of_work VALUES (174, 1);
INSERT INTO stroy.customer_type_of_work VALUES (175, 3);
INSERT INTO stroy.customer_type_of_work VALUES (175, 4);
INSERT INTO stroy.customer_type_of_work VALUES (176, 4);
INSERT INTO stroy.customer_type_of_work VALUES (176, 5);
INSERT INTO stroy.customer_type_of_work VALUES (177, 3);
INSERT INTO stroy.customer_type_of_work VALUES (177, 6);
INSERT INTO stroy.customer_type_of_work VALUES (177, 2);
INSERT INTO stroy.customer_type_of_work VALUES (178, 6);
INSERT INTO stroy.customer_type_of_work VALUES (178, 5);
INSERT INTO stroy.customer_type_of_work VALUES (178, 7);
INSERT INTO stroy.customer_type_of_work VALUES (179, 7);
INSERT INTO stroy.customer_type_of_work VALUES (179, 4);
INSERT INTO stroy.customer_type_of_work VALUES (179, 6);
INSERT INTO stroy.customer_type_of_work VALUES (180, 2);
INSERT INTO stroy.customer_type_of_work VALUES (180, 7);
INSERT INTO stroy.customer_type_of_work VALUES (181, 4);
INSERT INTO stroy.customer_type_of_work VALUES (181, 6);
INSERT INTO stroy.customer_type_of_work VALUES (181, 3);
INSERT INTO stroy.customer_type_of_work VALUES (182, 7);
INSERT INTO stroy.customer_type_of_work VALUES (182, 1);
INSERT INTO stroy.customer_type_of_work VALUES (183, 3);
INSERT INTO stroy.customer_type_of_work VALUES (184, 5);
INSERT INTO stroy.customer_type_of_work VALUES (184, 6);
INSERT INTO stroy.customer_type_of_work VALUES (185, 4);
INSERT INTO stroy.customer_type_of_work VALUES (186, 4);
INSERT INTO stroy.customer_type_of_work VALUES (186, 3);
INSERT INTO stroy.customer_type_of_work VALUES (187, 3);
INSERT INTO stroy.customer_type_of_work VALUES (187, 2);
INSERT INTO stroy.customer_type_of_work VALUES (188, 6);
INSERT INTO stroy.customer_type_of_work VALUES (188, 2);
INSERT INTO stroy.customer_type_of_work VALUES (189, 6);
INSERT INTO stroy.customer_type_of_work VALUES (190, 5);
INSERT INTO stroy.customer_type_of_work VALUES (191, 6);
INSERT INTO stroy.customer_type_of_work VALUES (192, 7);
INSERT INTO stroy.customer_type_of_work VALUES (192, 1);
INSERT INTO stroy.customer_type_of_work VALUES (192, 4);
INSERT INTO stroy.customer_type_of_work VALUES (193, 3);
INSERT INTO stroy.customer_type_of_work VALUES (193, 2);
INSERT INTO stroy.customer_type_of_work VALUES (193, 5);
INSERT INTO stroy.customer_type_of_work VALUES (194, 2);
INSERT INTO stroy.customer_type_of_work VALUES (195, 4);
INSERT INTO stroy.customer_type_of_work VALUES (195, 5);
INSERT INTO stroy.customer_type_of_work VALUES (195, 1);
INSERT INTO stroy.customer_type_of_work VALUES (196, 7);
INSERT INTO stroy.customer_type_of_work VALUES (197, 2);
INSERT INTO stroy.customer_type_of_work VALUES (197, 6);
INSERT INTO stroy.customer_type_of_work VALUES (197, 3);
INSERT INTO stroy.customer_type_of_work VALUES (198, 6);
INSERT INTO stroy.customer_type_of_work VALUES (198, 5);
INSERT INTO stroy.customer_type_of_work VALUES (199, 4);
INSERT INTO stroy.customer_type_of_work VALUES (199, 2);
INSERT INTO stroy.customer_type_of_work VALUES (199, 1);
INSERT INTO stroy.customer_type_of_work VALUES (200, 5);
INSERT INTO stroy.customer_type_of_work VALUES (200, 1);
INSERT INTO stroy.customer_type_of_work VALUES (200, 7);
INSERT INTO stroy.customer_type_of_work VALUES (201, 3);
INSERT INTO stroy.customer_type_of_work VALUES (201, 2);
INSERT INTO stroy.customer_type_of_work VALUES (201, 7);
INSERT INTO stroy.customer_type_of_work VALUES (202, 4);
INSERT INTO stroy.customer_type_of_work VALUES (202, 3);
INSERT INTO stroy.customer_type_of_work VALUES (202, 6);
INSERT INTO stroy.customer_type_of_work VALUES (203, 6);
INSERT INTO stroy.customer_type_of_work VALUES (203, 4);
INSERT INTO stroy.customer_type_of_work VALUES (203, 1);
INSERT INTO stroy.customer_type_of_work VALUES (204, 7);
INSERT INTO stroy.customer_type_of_work VALUES (204, 2);
INSERT INTO stroy.customer_type_of_work VALUES (204, 3);
INSERT INTO stroy.customer_type_of_work VALUES (205, 3);
INSERT INTO stroy.customer_type_of_work VALUES (206, 3);
INSERT INTO stroy.customer_type_of_work VALUES (207, 7);
INSERT INTO stroy.customer_type_of_work VALUES (207, 6);
INSERT INTO stroy.customer_type_of_work VALUES (207, 3);
INSERT INTO stroy.customer_type_of_work VALUES (208, 3);
INSERT INTO stroy.customer_type_of_work VALUES (208, 2);
INSERT INTO stroy.customer_type_of_work VALUES (209, 3);
INSERT INTO stroy.customer_type_of_work VALUES (210, 6);
INSERT INTO stroy.customer_type_of_work VALUES (211, 7);
INSERT INTO stroy.customer_type_of_work VALUES (212, 7);
INSERT INTO stroy.customer_type_of_work VALUES (213, 7);
INSERT INTO stroy.customer_type_of_work VALUES (214, 5);
INSERT INTO stroy.customer_type_of_work VALUES (214, 2);
INSERT INTO stroy.customer_type_of_work VALUES (215, 4);
INSERT INTO stroy.customer_type_of_work VALUES (215, 2);
INSERT INTO stroy.customer_type_of_work VALUES (215, 1);
INSERT INTO stroy.customer_type_of_work VALUES (216, 6);
INSERT INTO stroy.customer_type_of_work VALUES (217, 5);
INSERT INTO stroy.customer_type_of_work VALUES (217, 4);
INSERT INTO stroy.customer_type_of_work VALUES (217, 2);
INSERT INTO stroy.customer_type_of_work VALUES (218, 1);
INSERT INTO stroy.customer_type_of_work VALUES (219, 2);
INSERT INTO stroy.customer_type_of_work VALUES (219, 6);
INSERT INTO stroy.customer_type_of_work VALUES (219, 3);
INSERT INTO stroy.customer_type_of_work VALUES (220, 4);
INSERT INTO stroy.customer_type_of_work VALUES (220, 5);
INSERT INTO stroy.customer_type_of_work VALUES (220, 2);
INSERT INTO stroy.customer_type_of_work VALUES (221, 6);
INSERT INTO stroy.customer_type_of_work VALUES (222, 1);
INSERT INTO stroy.customer_type_of_work VALUES (223, 3);
INSERT INTO stroy.customer_type_of_work VALUES (224, 6);
INSERT INTO stroy.customer_type_of_work VALUES (224, 5);
INSERT INTO stroy.customer_type_of_work VALUES (224, 1);
INSERT INTO stroy.customer_type_of_work VALUES (225, 7);
INSERT INTO stroy.customer_type_of_work VALUES (225, 3);
INSERT INTO stroy.customer_type_of_work VALUES (225, 4);
INSERT INTO stroy.customer_type_of_work VALUES (226, 1);
INSERT INTO stroy.customer_type_of_work VALUES (226, 5);
INSERT INTO stroy.customer_type_of_work VALUES (227, 5);
INSERT INTO stroy.customer_type_of_work VALUES (227, 4);
INSERT INTO stroy.customer_type_of_work VALUES (227, 2);
INSERT INTO stroy.customer_type_of_work VALUES (228, 2);
INSERT INTO stroy.customer_type_of_work VALUES (229, 2);
INSERT INTO stroy.customer_type_of_work VALUES (230, 4);
INSERT INTO stroy.customer_type_of_work VALUES (230, 3);
INSERT INTO stroy.customer_type_of_work VALUES (231, 5);
INSERT INTO stroy.customer_type_of_work VALUES (232, 4);
INSERT INTO stroy.customer_type_of_work VALUES (232, 7);
INSERT INTO stroy.customer_type_of_work VALUES (233, 4);
INSERT INTO stroy.customer_type_of_work VALUES (233, 2);
INSERT INTO stroy.customer_type_of_work VALUES (233, 6);
INSERT INTO stroy.customer_type_of_work VALUES (234, 4);
INSERT INTO stroy.customer_type_of_work VALUES (235, 4);
INSERT INTO stroy.customer_type_of_work VALUES (236, 4);
INSERT INTO stroy.customer_type_of_work VALUES (236, 3);
INSERT INTO stroy.customer_type_of_work VALUES (237, 7);
INSERT INTO stroy.customer_type_of_work VALUES (237, 5);
INSERT INTO stroy.customer_type_of_work VALUES (237, 4);
INSERT INTO stroy.customer_type_of_work VALUES (238, 7);
INSERT INTO stroy.customer_type_of_work VALUES (239, 1);
INSERT INTO stroy.customer_type_of_work VALUES (239, 7);
INSERT INTO stroy.customer_type_of_work VALUES (240, 7);
INSERT INTO stroy.customer_type_of_work VALUES (241, 3);
INSERT INTO stroy.customer_type_of_work VALUES (241, 5);
INSERT INTO stroy.customer_type_of_work VALUES (241, 7);
INSERT INTO stroy.customer_type_of_work VALUES (242, 5);
INSERT INTO stroy.customer_type_of_work VALUES (242, 4);
INSERT INTO stroy.customer_type_of_work VALUES (243, 7);
INSERT INTO stroy.customer_type_of_work VALUES (243, 4);
INSERT INTO stroy.customer_type_of_work VALUES (243, 3);
INSERT INTO stroy.customer_type_of_work VALUES (244, 1);
INSERT INTO stroy.customer_type_of_work VALUES (245, 7);
INSERT INTO stroy.customer_type_of_work VALUES (245, 2);
INSERT INTO stroy.customer_type_of_work VALUES (246, 3);
INSERT INTO stroy.customer_type_of_work VALUES (246, 7);
INSERT INTO stroy.customer_type_of_work VALUES (247, 2);
INSERT INTO stroy.customer_type_of_work VALUES (248, 2);
INSERT INTO stroy.customer_type_of_work VALUES (248, 6);
INSERT INTO stroy.customer_type_of_work VALUES (248, 7);
INSERT INTO stroy.customer_type_of_work VALUES (249, 4);
INSERT INTO stroy.customer_type_of_work VALUES (249, 2);
INSERT INTO stroy.customer_type_of_work VALUES (250, 6);
INSERT INTO stroy.customer_type_of_work VALUES (250, 2);
INSERT INTO stroy.customer_type_of_work VALUES (250, 7);
INSERT INTO stroy.customer_type_of_work VALUES (251, 5);
INSERT INTO stroy.customer_type_of_work VALUES (251, 4);
INSERT INTO stroy.customer_type_of_work VALUES (252, 6);
INSERT INTO stroy.customer_type_of_work VALUES (252, 4);
INSERT INTO stroy.customer_type_of_work VALUES (253, 6);
INSERT INTO stroy.customer_type_of_work VALUES (253, 1);
INSERT INTO stroy.customer_type_of_work VALUES (253, 3);
INSERT INTO stroy.customer_type_of_work VALUES (254, 2);
INSERT INTO stroy.customer_type_of_work VALUES (255, 4);
INSERT INTO stroy.customer_type_of_work VALUES (255, 7);
INSERT INTO stroy.customer_type_of_work VALUES (255, 5);
INSERT INTO stroy.customer_type_of_work VALUES (256, 4);
INSERT INTO stroy.customer_type_of_work VALUES (257, 5);
INSERT INTO stroy.customer_type_of_work VALUES (257, 3);
INSERT INTO stroy.customer_type_of_work VALUES (257, 2);
INSERT INTO stroy.customer_type_of_work VALUES (258, 4);
INSERT INTO stroy.customer_type_of_work VALUES (258, 7);
INSERT INTO stroy.customer_type_of_work VALUES (259, 7);
INSERT INTO stroy.customer_type_of_work VALUES (260, 3);
INSERT INTO stroy.customer_type_of_work VALUES (260, 1);
INSERT INTO stroy.customer_type_of_work VALUES (261, 5);
INSERT INTO stroy.customer_type_of_work VALUES (261, 3);
INSERT INTO stroy.customer_type_of_work VALUES (261, 6);
INSERT INTO stroy.customer_type_of_work VALUES (262, 2);
INSERT INTO stroy.customer_type_of_work VALUES (263, 1);
INSERT INTO stroy.customer_type_of_work VALUES (264, 6);
INSERT INTO stroy.customer_type_of_work VALUES (264, 3);
INSERT INTO stroy.customer_type_of_work VALUES (265, 5);
INSERT INTO stroy.customer_type_of_work VALUES (265, 7);
INSERT INTO stroy.customer_type_of_work VALUES (266, 7);
INSERT INTO stroy.customer_type_of_work VALUES (266, 1);
INSERT INTO stroy.customer_type_of_work VALUES (267, 3);
INSERT INTO stroy.customer_type_of_work VALUES (267, 5);
INSERT INTO stroy.customer_type_of_work VALUES (268, 3);
INSERT INTO stroy.customer_type_of_work VALUES (269, 4);
INSERT INTO stroy.customer_type_of_work VALUES (269, 3);
INSERT INTO stroy.customer_type_of_work VALUES (270, 7);
INSERT INTO stroy.customer_type_of_work VALUES (270, 5);
INSERT INTO stroy.customer_type_of_work VALUES (270, 6);
INSERT INTO stroy.customer_type_of_work VALUES (271, 1);
INSERT INTO stroy.customer_type_of_work VALUES (271, 4);
INSERT INTO stroy.customer_type_of_work VALUES (272, 4);
INSERT INTO stroy.customer_type_of_work VALUES (272, 2);
INSERT INTO stroy.customer_type_of_work VALUES (273, 5);
INSERT INTO stroy.customer_type_of_work VALUES (274, 5);
INSERT INTO stroy.customer_type_of_work VALUES (274, 7);
INSERT INTO stroy.customer_type_of_work VALUES (275, 5);
INSERT INTO stroy.customer_type_of_work VALUES (275, 1);
INSERT INTO stroy.customer_type_of_work VALUES (276, 1);
INSERT INTO stroy.customer_type_of_work VALUES (276, 2);
INSERT INTO stroy.customer_type_of_work VALUES (276, 7);
INSERT INTO stroy.customer_type_of_work VALUES (277, 1);
INSERT INTO stroy.customer_type_of_work VALUES (277, 5);
INSERT INTO stroy.customer_type_of_work VALUES (278, 1);
INSERT INTO stroy.customer_type_of_work VALUES (278, 3);


--
-- TOC entry 5911 (class 0 OID 4886039)
-- Dependencies: 501
-- Data for Name: employee; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.employee VALUES (1, 15, '2022-12-09', NULL, NULL);
INSERT INTO stroy.employee VALUES (2, 57, '2021-05-18', NULL, NULL);
INSERT INTO stroy.employee VALUES (3, 22, '2015-08-13', NULL, NULL);
INSERT INTO stroy.employee VALUES (4, 7, '2017-03-02', NULL, NULL);
INSERT INTO stroy.employee VALUES (5, 58, '2023-09-28', NULL, NULL);
INSERT INTO stroy.employee VALUES (6, 20, '2012-11-25', NULL, NULL);
INSERT INTO stroy.employee VALUES (7, 38, '2020-01-21', NULL, NULL);
INSERT INTO stroy.employee VALUES (8, 49, '2016-08-14', NULL, NULL);
INSERT INTO stroy.employee VALUES (9, 77, '2015-07-01', NULL, NULL);
INSERT INTO stroy.employee VALUES (10, 5, '2020-04-07', NULL, NULL);
INSERT INTO stroy.employee VALUES (11, 42, '2014-05-11', NULL, NULL);
INSERT INTO stroy.employee VALUES (12, 44, '2020-08-21', NULL, NULL);
INSERT INTO stroy.employee VALUES (13, 9, '2015-02-03', '2022-02-05', NULL);
INSERT INTO stroy.employee VALUES (14, 79, '2018-05-15', NULL, NULL);
INSERT INTO stroy.employee VALUES (15, 39, '2015-08-27', NULL, NULL);
INSERT INTO stroy.employee VALUES (16, 74, '2013-03-05', NULL, NULL);
INSERT INTO stroy.employee VALUES (17, 24, '2021-11-07', NULL, NULL);
INSERT INTO stroy.employee VALUES (18, 61, '2020-01-30', NULL, NULL);
INSERT INTO stroy.employee VALUES (19, 13, '2019-11-24', NULL, NULL);
INSERT INTO stroy.employee VALUES (20, 64, '2011-12-22', NULL, NULL);
INSERT INTO stroy.employee VALUES (21, 70, '2012-07-02', NULL, NULL);
INSERT INTO stroy.employee VALUES (22, 75, '2020-12-29', NULL, NULL);
INSERT INTO stroy.employee VALUES (23, 23, '2017-09-30', NULL, NULL);
INSERT INTO stroy.employee VALUES (24, 31, '2013-02-11', NULL, NULL);
INSERT INTO stroy.employee VALUES (25, 4, '2020-12-12', NULL, NULL);
INSERT INTO stroy.employee VALUES (26, 65, '2013-10-11', NULL, NULL);
INSERT INTO stroy.employee VALUES (27, 72, '2021-03-31', NULL, NULL);
INSERT INTO stroy.employee VALUES (28, 76, '2017-12-02', NULL, NULL);
INSERT INTO stroy.employee VALUES (29, 48, '2019-04-24', NULL, NULL);
INSERT INTO stroy.employee VALUES (30, 59, '2018-06-18', NULL, NULL);
INSERT INTO stroy.employee VALUES (31, 69, '2023-10-26', NULL, NULL);
INSERT INTO stroy.employee VALUES (32, 16, '2014-11-01', NULL, NULL);
INSERT INTO stroy.employee VALUES (33, 19, '2018-02-25', NULL, NULL);
INSERT INTO stroy.employee VALUES (34, 34, '2015-01-06', NULL, NULL);
INSERT INTO stroy.employee VALUES (35, 10, '2011-08-23', NULL, NULL);
INSERT INTO stroy.employee VALUES (36, 2, '2016-10-16', NULL, NULL);
INSERT INTO stroy.employee VALUES (37, 27, '2021-11-29', '2022-08-19', NULL);
INSERT INTO stroy.employee VALUES (38, 50, '2015-12-07', NULL, NULL);
INSERT INTO stroy.employee VALUES (39, 11, '2017-06-04', NULL, NULL);
INSERT INTO stroy.employee VALUES (40, 18, '2013-09-01', NULL, NULL);
INSERT INTO stroy.employee VALUES (41, 28, '2012-10-02', NULL, NULL);
INSERT INTO stroy.employee VALUES (42, 43, '2010-11-20', NULL, NULL);
INSERT INTO stroy.employee VALUES (43, 54, '2022-07-13', NULL, NULL);
INSERT INTO stroy.employee VALUES (44, 63, '2011-11-28', NULL, NULL);
INSERT INTO stroy.employee VALUES (45, 40, '2012-03-21', NULL, NULL);
INSERT INTO stroy.employee VALUES (46, 67, '2020-11-22', NULL, NULL);
INSERT INTO stroy.employee VALUES (47, 36, '2016-12-21', NULL, NULL);
INSERT INTO stroy.employee VALUES (48, 12, '2018-02-25', NULL, NULL);
INSERT INTO stroy.employee VALUES (49, 68, '2011-02-26', NULL, NULL);
INSERT INTO stroy.employee VALUES (50, 78, '2023-03-15', NULL, NULL);
INSERT INTO stroy.employee VALUES (51, 62, '2018-12-28', NULL, NULL);
INSERT INTO stroy.employee VALUES (52, 14, '2011-11-27', '2021-07-03', NULL);
INSERT INTO stroy.employee VALUES (53, 52, '2015-09-11', NULL, NULL);
INSERT INTO stroy.employee VALUES (54, 29, '2019-01-02', NULL, NULL);
INSERT INTO stroy.employee VALUES (55, 45, '2024-01-12', NULL, NULL);
INSERT INTO stroy.employee VALUES (56, 55, '2016-08-09', NULL, NULL);
INSERT INTO stroy.employee VALUES (57, 47, '2011-11-06', NULL, NULL);
INSERT INTO stroy.employee VALUES (58, 35, '2013-05-17', NULL, NULL);
INSERT INTO stroy.employee VALUES (59, 51, '2016-09-26', NULL, NULL);
INSERT INTO stroy.employee VALUES (60, 80, '2015-09-17', NULL, NULL);
INSERT INTO stroy.employee VALUES (61, 60, '2015-11-27', NULL, NULL);
INSERT INTO stroy.employee VALUES (62, 17, '2011-08-14', NULL, NULL);
INSERT INTO stroy.employee VALUES (63, 56, '2023-06-27', NULL, NULL);
INSERT INTO stroy.employee VALUES (64, 21, '2017-02-03', NULL, NULL);
INSERT INTO stroy.employee VALUES (65, 73, '2021-10-25', NULL, NULL);
INSERT INTO stroy.employee VALUES (66, 1, '2017-02-21', NULL, NULL);
INSERT INTO stroy.employee VALUES (67, 41, '2014-06-06', '2019-05-29', NULL);
INSERT INTO stroy.employee VALUES (68, 30, '2013-04-05', NULL, NULL);
INSERT INTO stroy.employee VALUES (69, 37, '2018-07-28', NULL, NULL);
INSERT INTO stroy.employee VALUES (70, 3, '2012-04-11', NULL, NULL);
INSERT INTO stroy.employee VALUES (71, 33, '2015-09-29', NULL, NULL);
INSERT INTO stroy.employee VALUES (72, 26, '2020-06-23', NULL, NULL);
INSERT INTO stroy.employee VALUES (73, 6, '2019-07-26', NULL, NULL);
INSERT INTO stroy.employee VALUES (74, 8, '2010-09-04', NULL, NULL);
INSERT INTO stroy.employee VALUES (75, 53, '2022-10-15', NULL, NULL);
INSERT INTO stroy.employee VALUES (76, 25, '2016-08-30', NULL, NULL);
INSERT INTO stroy.employee VALUES (77, 66, '2015-07-14', NULL, NULL);
INSERT INTO stroy.employee VALUES (78, 32, '2019-07-26', NULL, NULL);
INSERT INTO stroy.employee VALUES (79, 71, '2020-11-13', NULL, NULL);
INSERT INTO stroy.employee VALUES (80, 46, '2017-10-06', NULL, NULL);


--
-- TOC entry 5913 (class 0 OID 4886047)
-- Dependencies: 503
-- Data for Name: employee_position; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.employee_position VALUES (23, 176, 180000, 1, '2024-03-03');
INSERT INTO stroy.employee_position VALUES (38, 14, 80000, 1, '2024-03-25');
INSERT INTO stroy.employee_position VALUES (75, 23, 280000, 1, '2024-02-23');
INSERT INTO stroy.employee_position VALUES (31, 179, 330000, 1, '2023-03-08');
INSERT INTO stroy.employee_position VALUES (21, 44, 40000, 1, '2022-08-25');
INSERT INTO stroy.employee_position VALUES (58, 90, 230000, 1, '2023-08-06');
INSERT INTO stroy.employee_position VALUES (68, 167, 190000, 1, '2023-05-05');
INSERT INTO stroy.employee_position VALUES (1, 83, 60000, 1, '2023-06-11');
INSERT INTO stroy.employee_position VALUES (11, 4, 190000, 1, '2023-11-29');
INSERT INTO stroy.employee_position VALUES (17, 63, 80000, 1, '2024-01-11');
INSERT INTO stroy.employee_position VALUES (78, 88, 80000, 1, '2024-03-21');
INSERT INTO stroy.employee_position VALUES (41, 169, 50000, 1, '2023-03-24');
INSERT INTO stroy.employee_position VALUES (60, 20, 330000, 1, '2022-12-24');
INSERT INTO stroy.employee_position VALUES (2, 186, 220000, 1, '2023-02-20');
INSERT INTO stroy.employee_position VALUES (27, 13, 80000, 1, '2022-12-18');
INSERT INTO stroy.employee_position VALUES (29, 30, 50000, 1, '2023-08-05');
INSERT INTO stroy.employee_position VALUES (12, 197, 210000, 1, '2022-05-11');
INSERT INTO stroy.employee_position VALUES (57, 48, 310000, 1, '2024-02-11');
INSERT INTO stroy.employee_position VALUES (55, 136, 170000, 1, '2022-10-18');
INSERT INTO stroy.employee_position VALUES (10, 145, 160000, 1, '2023-12-16');
INSERT INTO stroy.employee_position VALUES (53, 75, 280000, 1, '2022-11-08');
INSERT INTO stroy.employee_position VALUES (79, 95, 210000, 1, '2022-03-22');
INSERT INTO stroy.employee_position VALUES (15, 133, 80000, 1, '2023-05-20');
INSERT INTO stroy.employee_position VALUES (70, 47, 200000, 1, '2023-05-09');
INSERT INTO stroy.employee_position VALUES (4, 29, 50000, 1, '2023-02-25');
INSERT INTO stroy.employee_position VALUES (13, 101, 310000, 1, '2023-03-25');
INSERT INTO stroy.employee_position VALUES (51, 121, 60000, 1, '2023-07-12');
INSERT INTO stroy.employee_position VALUES (54, 130, 70000, 1, '2022-10-24');
INSERT INTO stroy.employee_position VALUES (35, 6, 120000, 1, '2023-07-18');
INSERT INTO stroy.employee_position VALUES (64, 149, 110000, 1, '2023-08-14');
INSERT INTO stroy.employee_position VALUES (63, 45, 220000, 1, '2022-06-09');
INSERT INTO stroy.employee_position VALUES (47, 50, 260000, 1, '2022-07-17');
INSERT INTO stroy.employee_position VALUES (65, 190, 100000, 1, '2024-03-21');
INSERT INTO stroy.employee_position VALUES (26, 79, 100000, 1, '2022-08-13');
INSERT INTO stroy.employee_position VALUES (3, 73, 150000, 1, '2022-08-02');
INSERT INTO stroy.employee_position VALUES (39, 81, 270000, 1, '2022-06-29');
INSERT INTO stroy.employee_position VALUES (76, 86, 290000, 1, '2022-05-08');
INSERT INTO stroy.employee_position VALUES (30, 108, 270000, 1, '2024-01-14');
INSERT INTO stroy.employee_position VALUES (37, 98, 250000, 1, '2022-07-26');
INSERT INTO stroy.employee_position VALUES (14, 156, 180000, 1, '2023-09-02');
INSERT INTO stroy.employee_position VALUES (77, 2, 290000, 1, '2022-04-15');
INSERT INTO stroy.employee_position VALUES (28, 62, 310000, 1, '2024-02-18');
INSERT INTO stroy.employee_position VALUES (48, 161, 330000, 1, '2023-02-27');
INSERT INTO stroy.employee_position VALUES (7, 124, 260000, 1, '2023-02-24');
INSERT INTO stroy.employee_position VALUES (46, 53, 170000, 1, '2022-06-03');
INSERT INTO stroy.employee_position VALUES (72, 68, 50000, 1, '2022-03-29');
INSERT INTO stroy.employee_position VALUES (56, 203, 320000, 1, '2023-06-15');
INSERT INTO stroy.employee_position VALUES (44, 175, 40000, 1, '2022-05-29');
INSERT INTO stroy.employee_position VALUES (9, 8, 330000, 1, '2023-12-18');
INSERT INTO stroy.employee_position VALUES (50, 19, 180000, 1, '2022-06-22');
INSERT INTO stroy.employee_position VALUES (80, 69, 110000, 1, '2023-05-08');
INSERT INTO stroy.employee_position VALUES (66, 157, 140000, 1, '2022-08-13');
INSERT INTO stroy.employee_position VALUES (36, 12, 50000, 1, '2023-09-08');
INSERT INTO stroy.employee_position VALUES (45, 21, 270000, 1, '2023-07-23');
INSERT INTO stroy.employee_position VALUES (6, 15, 230000, 1, '2023-06-13');
INSERT INTO stroy.employee_position VALUES (61, 61, 100000, 1, '2024-03-18');
INSERT INTO stroy.employee_position VALUES (32, 155, 240000, 1, '2023-09-17');
INSERT INTO stroy.employee_position VALUES (33, 192, 80000, 1, '2023-10-23');
INSERT INTO stroy.employee_position VALUES (16, 28, 170000, 1, '2023-09-23');
INSERT INTO stroy.employee_position VALUES (22, 97, 100000, 1, '2023-06-22');
INSERT INTO stroy.employee_position VALUES (5, 9, 70000, 1, '2024-02-14');
INSERT INTO stroy.employee_position VALUES (52, 84, 130000, 1, '2022-10-26');
INSERT INTO stroy.employee_position VALUES (69, 181, 70000, 1, '2023-08-20');
INSERT INTO stroy.employee_position VALUES (74, 24, 220000, 1, '2022-08-22');
INSERT INTO stroy.employee_position VALUES (19, 18, 160000, 1, '2023-04-17');
INSERT INTO stroy.employee_position VALUES (40, 72, 180000, 1, '2022-08-10');
INSERT INTO stroy.employee_position VALUES (34, 57, 320000, 1, '2022-06-28');
INSERT INTO stroy.employee_position VALUES (49, 40, 250000, 1, '2022-08-01');
INSERT INTO stroy.employee_position VALUES (25, 1, 150000, 0.5, '2022-07-11');
INSERT INTO stroy.employee_position VALUES (18, 174, 300000, 0.5, '2024-02-02');
INSERT INTO stroy.employee_position VALUES (71, 70, 120000, 0.5, '2023-12-14');
INSERT INTO stroy.employee_position VALUES (8, 180, 100000, 0.5, '2023-12-16');
INSERT INTO stroy.employee_position VALUES (62, 39, 100000, 0.5, '2023-09-12');
INSERT INTO stroy.employee_position VALUES (24, 54, 150000, 0.5, '2023-05-13');
INSERT INTO stroy.employee_position VALUES (43, 35, 70000, 0.5, '2023-12-10');
INSERT INTO stroy.employee_position VALUES (20, 162, 110000, 0.5, '2023-08-02');
INSERT INTO stroy.employee_position VALUES (42, 11, 230000, 0.5, '2022-09-19');
INSERT INTO stroy.employee_position VALUES (73, 195, 320000, 0.5, '2023-01-31');
INSERT INTO stroy.employee_position VALUES (67, 194, 220000, 0.5, '2023-08-04');
INSERT INTO stroy.employee_position VALUES (59, 116, 300000, 0.5, '2022-04-15');
INSERT INTO stroy.employee_position VALUES (24, 112, 280000, 0.5, '2023-09-27');
INSERT INTO stroy.employee_position VALUES (67, 76, 140000, 0.5, '2024-01-30');
INSERT INTO stroy.employee_position VALUES (59, 150, 240000, 0.5, '2022-04-20');
INSERT INTO stroy.employee_position VALUES (43, 58, 320000, 0.5, '2023-01-14');
INSERT INTO stroy.employee_position VALUES (25, 126, 140000, 0.5, '2023-09-09');
INSERT INTO stroy.employee_position VALUES (71, 32, 310000, 0.5, '2024-01-28');
INSERT INTO stroy.employee_position VALUES (42, 51, 190000, 0.5, '2022-06-20');
INSERT INTO stroy.employee_position VALUES (8, 135, 260000, 0.5, '2022-12-05');
INSERT INTO stroy.employee_position VALUES (20, 184, 170000, 0.5, '2022-12-06');
INSERT INTO stroy.employee_position VALUES (73, 170, 100000, 0.5, '2022-03-23');
INSERT INTO stroy.employee_position VALUES (62, 173, 230000, 0.5, '2022-04-11');
INSERT INTO stroy.employee_position VALUES (18, 168, 320000, 0.5, '2024-01-26');


--
-- TOC entry 5914 (class 0 OID 4886054)
-- Dependencies: 504
-- Data for Name: employee_salary_history; Type: TABLE DATA; Schema: stroy; Owner: -
--



--
-- TOC entry 5916 (class 0 OID 4886063)
-- Dependencies: 506
-- Data for Name: grade_salary; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.grade_salary VALUES (1, 130000, 210000);
INSERT INTO stroy.grade_salary VALUES (2, 130000, 220000);
INSERT INTO stroy.grade_salary VALUES (3, 160000, 240000);
INSERT INTO stroy.grade_salary VALUES (4, 130000, 190000);
INSERT INTO stroy.grade_salary VALUES (5, 30000, 120000);
INSERT INTO stroy.grade_salary VALUES (6, 30000, 90000);
INSERT INTO stroy.grade_salary VALUES (7, 70000, 120000);
INSERT INTO stroy.grade_salary VALUES (8, 220000, 270000);
INSERT INTO stroy.grade_salary VALUES (9, 40000, 100000);
INSERT INTO stroy.grade_salary VALUES (10, 70000, 150000);
INSERT INTO stroy.grade_salary VALUES (11, 30000, 110000);
INSERT INTO stroy.grade_salary VALUES (12, 30000, 100000);
INSERT INTO stroy.grade_salary VALUES (13, 110000, 170000);
INSERT INTO stroy.grade_salary VALUES (14, 180000, 250000);
INSERT INTO stroy.grade_salary VALUES (15, 30000, 100000);
INSERT INTO stroy.grade_salary VALUES (16, 30000, 110000);
INSERT INTO stroy.grade_salary VALUES (17, 220000, 300000);
INSERT INTO stroy.grade_salary VALUES (18, 170000, 270000);
INSERT INTO stroy.grade_salary VALUES (19, 90000, 190000);
INSERT INTO stroy.grade_salary VALUES (20, 190000, 250000);


--
-- TOC entry 5918 (class 0 OID 4886071)
-- Dependencies: 508
-- Data for Name: person; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.person VALUES (1, 'Иванов', 'Иван', 'Иванович', DEFAULT, '1970-07-04', '+7 (920) 136-48-34', 'ivanovii70@yandex.ru', 296);
INSERT INTO stroy.person VALUES (2, 'Петров', 'Петр', 'Петрович', DEFAULT, '2004-03-21', '+7 (147) 993-94-86', 'petrovpp04@pisem.net', 232);
INSERT INTO stroy.person VALUES (3, 'Сидоров', 'Сидор', 'Сидорович', DEFAULT, '1998-10-19', '+7 (191) 168-66-72', 'sidorovss98@yandex.ru', 253);
INSERT INTO stroy.person VALUES (4, 'Кузнецов', 'Кузьма', 'Кузьмич', DEFAULT, '2001-03-09', '+7 (357) 410-31-25', 'kuznecovkk01@mail.ru', 155);
INSERT INTO stroy.person VALUES (5, 'Смирнов', 'Сергей', 'Сергеевич', DEFAULT, '1984-12-05', '+7 (764) 350-70-41', 'smirnovss84@mail.ru', 362);
INSERT INTO stroy.person VALUES (6, 'Лебедев', 'Лев', 'Львович', DEFAULT, '1967-02-28', '+7 (630) 600-34-56', 'lebedevll67@pisem.net', 328);
INSERT INTO stroy.person VALUES (7, 'Козлов', 'Константин', 'Константинович', DEFAULT, '1992-09-07', '+7 (224) 273-89-38', 'kozlovkk92@rambler.ru', 67);
INSERT INTO stroy.person VALUES (8, 'Волков', 'Василий', 'Васильевич', DEFAULT, '1976-11-17', '+7 (812) 769-20-90', 'volkovvv76@yandex.ru', 432);
INSERT INTO stroy.person VALUES (9, 'Новиков', 'Николай', 'Николаевич', DEFAULT, '1984-12-18', '+7 (648) 193-48-57', 'novikovnn84@mail.ru', 71);
INSERT INTO stroy.person VALUES (10, 'Морозов', 'Михаил', 'Михайлович', DEFAULT, '1983-04-09', '+7 (241) 116-45-63', 'morozovmm83@rambler.ru', 24);
INSERT INTO stroy.person VALUES (11, 'Попов', 'Павел', 'Павлович', DEFAULT, '1980-02-14', '+7 (721) 750-48-74', 'popovpp80@yandex.ru', 376);
INSERT INTO stroy.person VALUES (12, 'Соколов', 'Степан', 'Степанович', DEFAULT, '1969-04-05', '+7 (680) 204-35-94', 'sokolovss69@pisem.net', 41);
INSERT INTO stroy.person VALUES (13, 'Лапшин', 'Лев', 'Львович', DEFAULT, '1990-04-06', '+7 (719) 485-22-88', 'lapshinll90@mail.ru', 80);
INSERT INTO stroy.person VALUES (14, 'Соловьев', 'Семён', 'Семёнович', DEFAULT, '1984-06-01', '+7 (743) 526-12-46', 'solovevss84@rambler.ru', 387);
INSERT INTO stroy.person VALUES (15, 'Виноградов', 'Василий', 'Васильевич', DEFAULT, '1984-05-27', '+7 (701) 630-65-23', 'vinogradovvv84@rambler.ru', 375);
INSERT INTO stroy.person VALUES (16, 'Кудрявцев', 'Константин', 'Константинович', DEFAULT, '2000-08-26', '+7 (286) 777-66-35', 'kudryavcevkk00@pisem.net', 285);
INSERT INTO stroy.person VALUES (17, 'Павлов', 'Пётр', 'Петрович', DEFAULT, '2005-03-25', '+7 (422) 398-11-18', 'pavlovpp05@pisem.net', 444);
INSERT INTO stroy.person VALUES (18, 'Горшков', 'Григорий', 'Григорьевич', DEFAULT, '1988-10-01', '+7 (951) 546-10-59', 'gorshkovgg88@rambler.ru', 337);
INSERT INTO stroy.person VALUES (19, 'Зайцев', 'Захар', 'Захарьевич', DEFAULT, '2000-12-19', '+7 (423) 946-35-17', 'zajcevzz00@mail.ru', 33);
INSERT INTO stroy.person VALUES (20, 'Семенов', 'Семён', 'Семёнович', DEFAULT, '1984-03-29', '+7 (707) 659-53-57', 'semenovss84@yandex.ru', 109);
INSERT INTO stroy.person VALUES (21, 'Федоров', 'Федор', 'Федорович', DEFAULT, '1995-11-27', '+7 (481) 328-57-71', 'fedorovff95@rambler.ru', 412);
INSERT INTO stroy.person VALUES (22, 'Кузнецов', 'Кирилл', 'Кириллович', DEFAULT, '1983-09-04', '+7 (892) 823-11-38', 'kuznecovkk83@yandex.ru', 59);
INSERT INTO stroy.person VALUES (23, 'Степанов', 'Степан', 'Степанович', DEFAULT, '2005-05-30', '+7 (365) 225-37-60', 'stepanovss05@yandex.ru', 430);
INSERT INTO stroy.person VALUES (24, 'Белов', 'Борис', 'Борисович', DEFAULT, '1972-12-08', '+7 (553) 168-98-24', 'belovbb72@rambler.ru', 481);
INSERT INTO stroy.person VALUES (25, 'Михайлов', 'Михаил', 'Михайлович', DEFAULT, '1983-07-08', '+7 (410) 184-49-82', 'miхajlovmm83@pisem.net', 113);
INSERT INTO stroy.person VALUES (26, 'Николаев', 'Николай', 'Николаевич', DEFAULT, '1977-01-18', '+7 (478) 313-86-28', 'nikolaevnn77@yandex.ru', 25);
INSERT INTO stroy.person VALUES (27, 'Смирнов', 'Сергей', 'Сергеевич', DEFAULT, '1966-07-22', '+7 (140) 238-33-72', 'smirnovss66@rambler.ru', 44);
INSERT INTO stroy.person VALUES (28, 'Иванов', 'Иван', 'Иванович', DEFAULT, '1971-10-04', '+7 (272) 381-50-20', 'ivanovii71@mail.ru', 371);
INSERT INTO stroy.person VALUES (29, 'Петров', 'Петр', 'Петрович', DEFAULT, '1977-05-06', '+7 (178) 178-51-84', 'petrovpp77@mail.ru', 397);
INSERT INTO stroy.person VALUES (30, 'Сидоров', 'Сидор', 'Сидорович', DEFAULT, '2000-12-22', '+7 (432) 464-65-23', 'sidorovss00@pisem.net', 463);
INSERT INTO stroy.person VALUES (31, 'Кузнецов', 'Кузьма', 'Кузьмич', DEFAULT, '1981-04-13', '+7 (479) 899-67-52', 'kuznecovkk81@pisem.net', 246);
INSERT INTO stroy.person VALUES (32, 'Смирнов', 'Сергей', 'Сергеевич', DEFAULT, '1998-10-31', '+7 (643) 654-19-40', 'smirnovss98@pisem.net', 266);
INSERT INTO stroy.person VALUES (33, 'Лебедев', 'Лев', 'Львович', DEFAULT, '1994-12-05', '+7 (319) 645-79-16', 'lebedevll94@mail.ru', 259);
INSERT INTO stroy.person VALUES (34, 'Козлов', 'Константин', 'Константинович', DEFAULT, '1965-03-16', '+7 (261) 108-96-79', 'kozlovkk65@yandex.ru', 97);
INSERT INTO stroy.person VALUES (35, 'Волков', 'Василий', 'Васильевич', DEFAULT, '1990-07-12', '+7 (195) 485-32-21', 'volkovvv90@yandex.ru', 4);
INSERT INTO stroy.person VALUES (36, 'Новиков', 'Николай', 'Николаевич', DEFAULT, '2002-09-24', '+7 (662) 969-52-49', 'novikovnn02@yandex.ru', 470);
INSERT INTO stroy.person VALUES (37, 'Морозов', 'Михаил', 'Михайлович', DEFAULT, '1968-08-11', '+7 (219) 636-75-66', 'morozovmm68@mail.ru', 164);
INSERT INTO stroy.person VALUES (38, 'Попов', 'Павел', 'Павлович', DEFAULT, '1994-03-11', '+7 (636) 826-26-99', 'popovpp94@mail.ru', 230);
INSERT INTO stroy.person VALUES (39, 'Соколов', 'Степан', 'Степанович', DEFAULT, '2002-11-26', '+7 (177) 130-70-62', 'sokolovss02@mail.ru', 75);
INSERT INTO stroy.person VALUES (40, 'Лапшин', 'Лев', 'Львович', DEFAULT, '1964-09-16', '+7 (308) 734-50-25', 'lapshinll64@rambler.ru', 395);
INSERT INTO stroy.person VALUES (41, 'Соловьев', 'Семён', 'Семёнович', DEFAULT, '1991-05-27', '+7 (589) 191-65-66', 'solovevss91@mail.ru', 493);
INSERT INTO stroy.person VALUES (42, 'Виноградов', 'Василий', 'Васильевич', DEFAULT, '2003-06-22', '+7 (695) 893-18-65', 'vinogradovvv03@mail.ru', 258);
INSERT INTO stroy.person VALUES (43, 'Кудрявцев', 'Константин', 'Константинович', DEFAULT, '1967-09-05', '+7 (150) 206-38-89', 'kudryavcevkk67@rambler.ru', 461);
INSERT INTO stroy.person VALUES (44, 'Павлов', 'Пётр', 'Петрович', DEFAULT, '2000-03-31', '+7 (738) 535-90-68', 'pavlovpp00@mail.ru', 158);
INSERT INTO stroy.person VALUES (45, 'Горшков', 'Григорий', 'Григорьевич', DEFAULT, '1981-01-17', '+7 (577) 420-33-34', 'gorshkovgg81@rambler.ru', 122);
INSERT INTO stroy.person VALUES (46, 'Зайцев', 'Захар', 'Захарьевич', DEFAULT, '1987-02-23', '+7 (634) 897-43-25', 'zajcevzz87@rambler.ru', 36);
INSERT INTO stroy.person VALUES (47, 'Семенов', 'Семён', 'Семёнович', DEFAULT, '1985-02-16', '+7 (878) 278-38-38', 'semenovss85@mail.ru', 130);
INSERT INTO stroy.person VALUES (48, 'Федоров', 'Федор', 'Федорович', DEFAULT, '1969-05-20', '+7 (272) 461-79-98', 'fedorovff69@mail.ru', 59);
INSERT INTO stroy.person VALUES (49, 'Кузнецов', 'Кирилл', 'Кириллович', DEFAULT, '1992-05-26', '+7 (312) 911-78-84', 'kuznecovkk92@mail.ru', 190);
INSERT INTO stroy.person VALUES (50, 'Степанов', 'Степан', 'Степанович', DEFAULT, '1965-01-22', '+7 (942) 945-49-25', 'stepanovss65@rambler.ru', 405);
INSERT INTO stroy.person VALUES (51, 'Белов', 'Борис', 'Борисович', DEFAULT, '2000-09-09', '+7 (603) 573-37-99', 'belovbb00@rambler.ru', 350);
INSERT INTO stroy.person VALUES (52, 'Михайлов', 'Михаил', 'Михайлович', DEFAULT, '1989-08-17', '+7 (276) 642-75-71', 'miхajlovmm89@mail.ru', 47);
INSERT INTO stroy.person VALUES (53, 'Николаев', 'Николай', 'Николаевич', DEFAULT, '1993-08-31', '+7 (378) 154-45-79', 'nikolaevnn93@pisem.net', 411);
INSERT INTO stroy.person VALUES (54, 'Смирнов', 'Сергей', 'Сергеевич', DEFAULT, '1972-10-05', '+7 (175) 647-85-37', 'smirnovss72@rambler.ru', 419);
INSERT INTO stroy.person VALUES (55, 'Иванов', 'Иван', 'Иванович', DEFAULT, '1987-07-01', '+7 (832) 789-53-50', 'ivanovii87@mail.ru', 134);
INSERT INTO stroy.person VALUES (56, 'Петров', 'Петр', 'Петрович', DEFAULT, '1989-11-28', '+7 (540) 143-61-48', 'petrovpp89@mail.ru', 234);
INSERT INTO stroy.person VALUES (57, 'Сидоров', 'Сидор', 'Сидорович', DEFAULT, '1976-03-01', '+7 (524) 230-88-73', 'sidorovss76@rambler.ru', 336);
INSERT INTO stroy.person VALUES (58, 'Кузнецов', 'Кузьма', 'Кузьмич', DEFAULT, '1974-09-19', '+7 (402) 608-95-34', 'kuznecovkk74@mail.ru', 316);
INSERT INTO stroy.person VALUES (59, 'Смирнов', 'Сергей', 'Сергеевич', DEFAULT, '1964-03-27', '+7 (707) 734-25-94', 'smirnovss64@mail.ru', 281);
INSERT INTO stroy.person VALUES (60, 'Лебедев', 'Лев', 'Львович', DEFAULT, '1994-03-23', '+7 (610) 200-43-59', 'lebedevll94@rambler.ru', 211);
INSERT INTO stroy.person VALUES (61, 'Козлов', 'Константин', 'Константинович', DEFAULT, '2006-01-14', '+7 (852) 876-61-19', 'kozlovkk06@pisem.net', 135);
INSERT INTO stroy.person VALUES (62, 'Волков', 'Василий', 'Васильевич', DEFAULT, '1978-03-16', '+7 (966) 423-47-26', 'volkovvv78@mail.ru', 307);
INSERT INTO stroy.person VALUES (63, 'Новиков', 'Николай', 'Николаевич', DEFAULT, '1994-07-15', '+7 (478) 551-36-38', 'novikovnn94@yandex.ru', 485);
INSERT INTO stroy.person VALUES (64, 'Морозов', 'Михаил', 'Михайлович', DEFAULT, '1998-10-26', '+7 (151) 210-66-89', 'morozovmm98@pisem.net', 398);
INSERT INTO stroy.person VALUES (65, 'Попов', 'Павел', 'Павлович', DEFAULT, '1976-10-06', '+7 (845) 473-12-39', 'popovpp76@yandex.ru', 401);
INSERT INTO stroy.person VALUES (66, 'Соколов', 'Степан', 'Степанович', DEFAULT, '1982-03-17', '+7 (237) 589-86-18', 'sokolovss82@mail.ru', 188);
INSERT INTO stroy.person VALUES (67, 'Лапшин', 'Лев', 'Львович', DEFAULT, '1978-09-11', '+7 (205) 780-82-85', 'lapshinll78@rambler.ru', 134);
INSERT INTO stroy.person VALUES (68, 'Соловьев', 'Семён', 'Семёнович', DEFAULT, '1975-07-27', '+7 (276) 257-15-46', 'solovevss75@pisem.net', 341);
INSERT INTO stroy.person VALUES (69, 'Виноградов', 'Василий', 'Васильевич', DEFAULT, '1982-07-06', '+7 (338) 488-62-92', 'vinogradovvv82@pisem.net', 376);
INSERT INTO stroy.person VALUES (70, 'Кудрявцев', 'Константин', 'Константинович', DEFAULT, '1980-12-25', '+7 (193) 257-23-28', 'kudryavcevkk80@rambler.ru', 74);
INSERT INTO stroy.person VALUES (71, 'Павлов', 'Пётр', 'Петрович', DEFAULT, '1979-02-24', '+7 (221) 655-54-22', 'pavlovpp79@rambler.ru', 122);
INSERT INTO stroy.person VALUES (72, 'Горшков', 'Григорий', 'Григорьевич', DEFAULT, '1999-03-12', '+7 (481) 217-93-49', 'gorshkovgg99@pisem.net', 224);
INSERT INTO stroy.person VALUES (73, 'Зайцев', 'Захар', 'Захарьевич', DEFAULT, '1997-12-20', '+7 (877) 713-73-27', 'zajcevzz97@rambler.ru', 159);
INSERT INTO stroy.person VALUES (74, 'Семенов', 'Семён', 'Семёнович', DEFAULT, '1982-07-27', '+7 (160) 976-85-36', 'semenovss82@mail.ru', 28);
INSERT INTO stroy.person VALUES (75, 'Федоров', 'Федор', 'Федорович', DEFAULT, '2001-09-30', '+7 (734) 425-47-95', 'fedorovff01@mail.ru', 82);
INSERT INTO stroy.person VALUES (76, 'Кузнецов', 'Кирилл', 'Кириллович', DEFAULT, '2005-03-01', '+7 (698) 432-85-33', 'kuznecovkk05@yandex.ru', 440);
INSERT INTO stroy.person VALUES (77, 'Степанов', 'Степан', 'Степанович', DEFAULT, '1981-11-22', '+7 (139) 654-39-77', 'stepanovss81@mail.ru', 170);
INSERT INTO stroy.person VALUES (78, 'Белов', 'Борис', 'Борисович', DEFAULT, '1996-01-10', '+7 (293) 857-32-82', 'belovbb96@yandex.ru', 81);
INSERT INTO stroy.person VALUES (79, 'Михайлов', 'Михаил', 'Михайлович', DEFAULT, '1974-02-21', '+7 (954) 533-90-95', 'miхajlovmm74@rambler.ru', 348);
INSERT INTO stroy.person VALUES (80, 'Николаев', 'Николай', 'Николаевич', DEFAULT, '2002-07-28', '+7 (876) 746-55-90', 'nikolaevnn02@rambler.ru', 303);


--
-- TOC entry 5920 (class 0 OID 4886078)
-- Dependencies: 510
-- Data for Name: position; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy."position" VALUES (79, 'Архитектор', 13, 83, 5, false);
INSERT INTO stroy."position" VALUES (81, 'Архитектор', 21, 83, 4, false);
INSERT INTO stroy."position" VALUES (97, 'Архитектор', 21, 84, 2, false);
INSERT INTO stroy."position" VALUES (61, 'Архитектор-визуализатор', 13, 83, 1, false);
INSERT INTO stroy."position" VALUES (62, 'Архитектор-визуализатор', 21, 83, 18, false);
INSERT INTO stroy."position" VALUES (63, 'Архитектор-визуализатор', 24, 84, 16, false);
INSERT INTO stroy."position" VALUES (2, 'Ведущий архитектор', 13, 83, 2, false);
INSERT INTO stroy."position" VALUES (8, 'Ведущий архитектор', 13, 84, 18, false);
INSERT INTO stroy."position" VALUES (11, 'Ведущий архитектор', 28, 83, 9, false);
INSERT INTO stroy."position" VALUES (30, 'Ведущий архитектор', 21, 84, 7, false);
INSERT INTO stroy."position" VALUES (50, 'Ведущий архитектор', 192, 83, 17, false);
INSERT INTO stroy."position" VALUES (53, 'Ведущий архитектор', 192, 84, 3, false);
INSERT INTO stroy."position" VALUES (18, 'Главный инженер. Руководитель блока', 124, 19, 8, false);
INSERT INTO stroy."position" VALUES (88, 'Ведущий инженер по системам ВК', 18, 19, 7, false);
INSERT INTO stroy."position" VALUES (19, 'Ведущий инженер по СС', 18, 19, 18, false);
INSERT INTO stroy."position" VALUES (58, 'Ведущий инженер по СС', 18, 19, 20, false);
INSERT INTO stroy."position" VALUES (40, 'Главный специалист по системам ОВиК', 18, 19, 15, false);
INSERT INTO stroy."position" VALUES (20, 'Главный специалист по системам ЭОМ', 18, 19, 19, false);
INSERT INTO stroy."position" VALUES (6, 'Главный инженер проекта', 98, 101, 2, false);
INSERT INTO stroy."position" VALUES (72, 'Старший юрист', 15, 16, 5, false);
INSERT INTO stroy."position" VALUES (9, 'Главный архитектор проекта', 13, 83, 15, false);
INSERT INTO stroy."position" VALUES (83, 'Главный инженер проекта', 48, 101, 16, false);
INSERT INTO stroy."position" VALUES (90, 'Инженер-проектировщик систем ВК 2-ой категории', 68, 19, 16, false);
INSERT INTO stroy."position" VALUES (181, 'Инженер-конструктор 1-ой категории', 24, 86, 12, false);
INSERT INTO stroy."position" VALUES (203, 'Главный инженер проектов', 98, 105, 7, false);
INSERT INTO stroy."position" VALUES (1, 'Генеральный директор', 1, 5, 3, false);
INSERT INTO stroy."position" VALUES (27, 'Главный архитектор проекта', 13, 84, 4, true);
INSERT INTO stroy."position" VALUES (16, 'Руководитель блока управления проектами', 4, 20, 7, true);
INSERT INTO stroy."position" VALUES (67, 'Главный инженер проекта', 48, 101, 6, true);
INSERT INTO stroy."position" VALUES (4, 'Директор по управлению проектами', 1, 6, 8, false);
INSERT INTO stroy."position" VALUES (95, 'Главный архитектор проекта', 13, 101, 7, false);
INSERT INTO stroy."position" VALUES (15, 'Заместитель генерального директора', 1, 5, 16, false);
INSERT INTO stroy."position" VALUES (68, 'Директор по проектированию', 1, 4, 5, false);
INSERT INTO stroy."position" VALUES (32, 'Финансовый директор', 1, 1, 20, false);
INSERT INTO stroy."position" VALUES (35, 'Директор по продажам', 1, 3, 16, false);
INSERT INTO stroy."position" VALUES (57, 'Финансовый менеджер', 32, 8, 8, false);
INSERT INTO stroy."position" VALUES (86, 'Финансовый менеджер', 32, 8, 16, false);
INSERT INTO stroy."position" VALUES (84, 'Офис-менеджер', 15, 5, 9, false);
INSERT INTO stroy."position" VALUES (29, 'Ведущий инженер по системам ВК', 18, 19, 7, false);
INSERT INTO stroy."position" VALUES (13, 'Руководитель направления архитектурного проектирования', 68, 17, 7, false);
INSERT INTO stroy."position" VALUES (21, 'Руководитель направления 3D визуализации и дизайна', 68, 17, 2, false);
INSERT INTO stroy."position" VALUES (23, 'Руководитель блока управления проектами', 4, 20, 15, false);
INSERT INTO stroy."position" VALUES (24, 'Руководитель направления архитектурно-градостроительных решений', 68, 18, 20, false);
INSERT INTO stroy."position" VALUES (28, 'Руководитель направления BIM проектирования', 68, 18, 13, false);
INSERT INTO stroy."position" VALUES (98, 'Руководитель службы строительного контроля', 124, 23, 4, false);
INSERT INTO stroy."position" VALUES (12, 'Руководитель проектов', 4, 20, 11, false);
INSERT INTO stroy."position" VALUES (54, 'BIM-программист', 28, 85, 11, false);
INSERT INTO stroy."position" VALUES (75, 'Руководитель проектов', 4, 22, 11, false);
INSERT INTO stroy."position" VALUES (39, 'Руководитель строительного контроля', 124, 23, 11, false);
INSERT INTO stroy."position" VALUES (48, 'Руководитель службы строительного контроля', 124, 23, 15, false);
INSERT INTO stroy."position" VALUES (73, 'Руководитель проектов', 4, 21, 14, false);
INSERT INTO stroy."position" VALUES (47, 'IT-инженер', 15, 5, 11, false);
INSERT INTO stroy."position" VALUES (45, 'Администратор', 15, 5, 1, false);
INSERT INTO stroy."position" VALUES (14, 'Архитектор', 13, 83, 16, false);
INSERT INTO stroy."position" VALUES (44, 'Архитектор', 21, 83, 7, false);
INSERT INTO stroy."position" VALUES (51, 'Архитектор', 28, 83, 7, false);
INSERT INTO stroy."position" VALUES (69, 'Архитектор', 24, 83, 18, false);
INSERT INTO stroy."position" VALUES (70, 'Архитектор', 192, 83, 8, false);
INSERT INTO stroy."position" VALUES (76, 'Архитектор', 13, 83, 11, false);
INSERT INTO stroy."position" VALUES (139, 'Менеджер по содержанию офиса (уборщица)', 15, 5, 11, true);
INSERT INTO stroy."position" VALUES (128, 'Руководитель службы строительного контроля', 124, 26, 10, true);
INSERT INTO stroy."position" VALUES (125, 'Архитектор', 28, 84, 5, true);
INSERT INTO stroy."position" VALUES (191, 'Архитектор', 192, 84, 18, true);
INSERT INTO stroy."position" VALUES (119, 'Инженер-конструктор', 24, 86, 13, true);
INSERT INTO stroy."position" VALUES (122, 'Главный инженер-сметчик', 135, 100, 15, true);
INSERT INTO stroy."position" VALUES (132, 'Главный инженер проекта', 98, 100, 17, true);
INSERT INTO stroy."position" VALUES (115, 'Главный инженер проекта', 98, 102, 13, true);
INSERT INTO stroy."position" VALUES (124, 'Директор по строительству', 1, 2, 4, false);
INSERT INTO stroy."position" VALUES (126, 'Главный бухгалтер', 32, 7, 8, false);
INSERT INTO stroy."position" VALUES (145, 'Бухгалтер', 179, 7, 4, false);
INSERT INTO stroy."position" VALUES (179, 'Старший бухгалтер', 32, 7, 1, false);
INSERT INTO stroy."position" VALUES (190, 'Заместитель главного бухгалтера (ПМ + МСН)', 126, 7, 9, false);
INSERT INTO stroy."position" VALUES (130, 'Финансовый менеджер', 32, 8, 4, false);
INSERT INTO stroy."position" VALUES (155, 'Финансовый аналитик', 32, 8, 10, false);
INSERT INTO stroy."position" VALUES (169, 'Руководитель блока HR', 32, 9, 15, false);
INSERT INTO stroy."position" VALUES (194, 'Ведущий менеджер по кадрам', 169, 9, 6, false);
INSERT INTO stroy."position" VALUES (116, 'Менеджер по договорной работе', 35, 11, 14, false);
INSERT INTO stroy."position" VALUES (133, 'Менеджер по договорной работе', 35, 10, 15, false);
INSERT INTO stroy."position" VALUES (174, 'Менеджер по договорам и тендерам', 35, 10, 1, false);
INSERT INTO stroy."position" VALUES (184, 'Менеджер по договорам и тендерам', 35, 11, 4, false);
INSERT INTO stroy."position" VALUES (136, 'Менеджер по подбору и адаптации персонала', 169, 9, 19, false);
INSERT INTO stroy."position" VALUES (101, 'Руководитель службы строительного контроля', 124, 24, 6, false);
INSERT INTO stroy."position" VALUES (121, 'Руководитель службы строительного контроля', 124, 25, 12, false);
INSERT INTO stroy."position" VALUES (135, 'Руководитель службы строительного контроля', 124, 27, 13, false);
INSERT INTO stroy."position" VALUES (192, 'Руководитель проектов (генеральное проектирование)', 68, 18, 10, false);
INSERT INTO stroy."position" VALUES (175, 'Руководитель проектов', 4, 21, 14, false);
INSERT INTO stroy."position" VALUES (197, 'Руководитель проекта', 4, 22, 12, false);
INSERT INTO stroy."position" VALUES (161, 'Администратор', 15, 5, 18, false);
INSERT INTO stroy."position" VALUES (157, 'Архитектор', 28, 84, 7, false);
INSERT INTO stroy."position" VALUES (170, 'Архитектор', 24, 84, 8, false);
INSERT INTO stroy."position" VALUES (176, 'Архитектор', 192, 84, 2, false);
INSERT INTO stroy."position" VALUES (150, 'Архитектор-визуализатор', 192, 84, 8, false);
INSERT INTO stroy."position" VALUES (162, 'Ведущий инженер по системам ЭОМ', 18, 19, 8, false);
INSERT INTO stroy."position" VALUES (168, 'Ведущий инженер-проектировщик ОВиК', 18, 19, 15, false);
INSERT INTO stroy."position" VALUES (149, 'Юрист', 72, 16, 10, false);
INSERT INTO stroy."position" VALUES (167, 'Юрист', 72, 16, 5, false);
INSERT INTO stroy."position" VALUES (108, 'Главный инженер проекта', 121, 102, 19, false);
INSERT INTO stroy."position" VALUES (112, 'Главный инженер проекта', 135, 102, 7, false);
INSERT INTO stroy."position" VALUES (156, 'Главный инженер проекта', 39, 102, 17, false);
INSERT INTO stroy."position" VALUES (180, 'Главный инженер проекта', 128, 103, 6, false);
INSERT INTO stroy."position" VALUES (186, 'Главный инженер проекта', 135, 104, 19, false);
INSERT INTO stroy."position" VALUES (195, 'Главный инженер проекта', 101, 105, 14, false);
INSERT INTO stroy."position" VALUES (173, 'Специалист по качеству', 15, 14, 13, false);


--
-- TOC entry 5922 (class 0 OID 4886082)
-- Dependencies: 512
-- Data for Name: project; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.project VALUES (1, 'Вершина Прогресса', 259, 44, '{67,33,25,73,35}', 19049371, '2022-07-15', 'Завершен', 'Проект "Вершина Прогресса" представляет собой здание класса Комфорт с 10 этажами и общей площадью 176407 кв.м. В проекте предусмотрены следующие удобства: Фуд-корт, пропускная система, игровая зона для детей. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: АР, ОВиК, КР. Стоимость проекта: 19049371, статус: Завершен.', '{"floors": 10, "amenities": ["Фуд-корт", "пропускная система", "игровая зона для детей"], "documents": ["АР", "ОВиК", "КР"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "Комфорт", "total_area_sqm": 176407}', '''10'':12B,52C ''176407'':17B,72C ''19049371'':49B ''220'':41B,70C ''electr'':69C ''fals'':68C ''gas'':65C ''true'':66C ''water'':67C ''ар'':44B,62C ''вершин'':1A,4B ''вод'':38B ''газ'':36B ''дет'':33B,61C ''документац'':43B ''заверш'':51B ''здан'':8B ''зон'':31B,59C ''игров'':30B,58C ''инженерн'':34B ''кв'':18B ''класс'':9B ''комфорт'':10B,71C ''корт'':27B,55C ''кр'':46B,64C ''м'':19B ''общ'':15B ''овик'':45B,63C ''отсутств'':39B ''площад'':16B ''представля'':6B ''предусмотр'':22B ''прогресс'':2A,5B ''проект'':3B,21B,48B ''пропускн'':28B,56C ''систем'':29B,35B,57C ''след'':23B ''соб'':7B ''статус'':50B ''стоимост'':47B ''удобств'':24B ''фуд'':26B,54C ''фуд-корт'':25B,53C ''электричеств'':40B ''этаж'':13B');
INSERT INTO stroy.project VALUES (2, 'СтройЭксперт', 34, 27, '{9,44,3,27,54,25,12,28}', 36333309, '2023-04-20', 'На подписании', 'Проект "СтройЭксперт" представляет собой здание класса C с 12 этажами и общей площадью 1378 кв.м. В проекте предусмотрены следующие удобства: кофейня, переговорные комнаты, спа-центр, отделение банка, банкоматы. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: АР, ГС, ТХ, СОУЭ. Стоимость проекта: 36333309, статус: На подписании.', '{"floors": 12, "amenities": ["кофейня", "переговорные комнаты", "спа-центр", "отделение банка", "банкоматы"], "documents": ["АР", "ГС", "ТХ", "СОУЭ"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "C", "total_area_sqm": 1378}', '''12'':10B,52C ''1378'':15B,73C ''36333309'':48B ''380'':39B,71C ''c'':8B,72C ''electr'':70C ''fals'':69C ''gas'':66C ''true'':67C ''water'':68C ''ар'':42B,62C ''банк'':30B,60C ''банкомат'':31B,61C ''вод'':36B ''газ'':34B ''гс'':43B,63C ''документац'':41B ''здан'':6B ''инженерн'':32B ''кв'':16B ''класс'':7B ''комнат'':25B,55C ''кофейн'':23B,53C ''м'':17B ''общ'':13B ''отделен'':29B,59C ''отсутств'':37B ''переговорн'':24B,54C ''площад'':14B ''подписан'':51B ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,47B ''систем'':33B ''след'':21B ''соб'':5B ''соуэ'':45B,65C ''спа'':27B,57C ''спа-центр'':26B,56C ''статус'':49B ''стоимост'':46B ''стройэксперт'':1A,3B ''тх'':44B,64C ''удобств'':22B ''центр'':28B,58C ''электричеств'':38B ''этаж'':11B');
INSERT INTO stroy.project VALUES (3, 'Город Мечты', 215, 44, '{75,59,65,22,40,6,18,57,27,13}', 23987639, '2024-03-17', 'Отменен', 'Проект "Город Мечты" представляет собой здание класса Премиум с 17 этажами и общей площадью 104567 кв.м. В проекте предусмотрены следующие удобства: бесплатный Wi-Fi, банкоматы, рестораны и кафе, выставочный зал, видеонаблюдение, велопарковка, круглосуточная охрана. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: ОВиК, ГС, КР. Стоимость проекта: 23987639, статус: Отменен.', '{"floors": 17, "amenities": ["бесплатный Wi-Fi", "банкоматы", "рестораны и кафе", "выставочный зал", "видеонаблюдение", "велопарковка", "круглосуточная охрана"], "documents": ["ОВиК", "ГС", "КР"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "Премиум", "total_area_sqm": 104567}', '''104567'':17B,82C ''17'':12B,57C ''220'':46B,80C ''23987639'':54B ''electr'':79C ''fals'':76C ''fi'':28B,61C ''gas'':75C ''true'':78C ''water'':77C ''wi'':27B,60C ''wi-fi'':26B,59C ''банкомат'':29B,62C ''бесплатн'':25B,58C ''велопарковк'':36B,69C ''видеонаблюден'':35B,68C ''вод'':43B ''выставочн'':33B,66C ''газ'':41B ''город'':1A,4B ''гс'':50B,73C ''документац'':48B ''зал'':34B,67C ''здан'':8B ''инженерн'':39B ''каф'':32B,65C ''кв'':18B ''класс'':9B ''кр'':51B,74C ''круглосуточн'':37B,70C ''м'':19B ''мечт'':2A,5B ''общ'':15B ''овик'':49B,72C ''отмен'':56B ''отсутств'':42B ''охра'':38B,71C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''премиум'':10B,81C ''проект'':3B,21B,53B ''рестора'':30B,63C ''систем'':40B ''след'':23B ''соб'':7B ''статус'':55B ''стоимост'':52B ''удобств'':24B ''электричеств'':45B ''этаж'':13B');
INSERT INTO stroy.project VALUES (4, 'Небосвод', 122, 24, '{35,49,27,46,67,38,75,34}', 23987639, '2022-08-03', 'На подписании', 'Проект "Небосвод" представляет собой здание класса B с 25 этажами и общей площадью 59418 кв.м. В проекте предусмотрены следующие удобства: система климат-контроля, спа-центр, детская комната, рестораны и кафе, Фуд-корт, круглосуточная охрана, салоны красоты, паркинг для посетителей. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: КР, ГС, ОВиК, СОУЭ, ТХ, СС, ЭОМ, АР, АПС. Стоимость проекта: 23987639, статус: На подписании.', '{"floors": 25, "amenities": ["система климат-контроля", "спа-центр", "детская комната", "рестораны и кафе", "Фуд-корт", "круглосуточная охрана", "салоны красоты", "паркинг для посетителей"], "documents": ["КР", "ГС", "ОВиК", "СОУЭ", "ТХ", "СС", "ЭОМ", "АР", "АПС"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "B", "total_area_sqm": 59418}', '''220'':52B,107C ''23987639'':66B ''25'':10B,70C ''59418'':15B,109C ''b'':8B,108C ''electr'':106C ''fals'':105C ''gas'':102C ''true'':103C ''water'':104C ''апс'':63B,101C ''ар'':62B,100C ''вод'':49B ''газ'':47B ''гс'':56B,94C ''детск'':30B,78C ''документац'':54B ''здан'':6B ''инженерн'':45B ''каф'':34B,82C ''кв'':16B ''класс'':7B ''климат'':25B,73C ''климат-контрол'':24B,72C ''комнат'':31B,79C ''контрол'':26B,74C ''корт'':37B,85C ''кр'':55B,93C ''красот'':41B,89C ''круглосуточн'':38B,86C ''м'':17B ''небосвод'':1A,3B ''общ'':13B ''овик'':57B,95C ''отсутств'':50B ''охра'':39B,87C ''паркинг'':42B,90C ''площад'':14B ''подписан'':69B ''посетител'':44B,92C ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,65B ''рестора'':32B,80C ''салон'':40B,88C ''систем'':23B,46B,71C ''след'':21B ''соб'':5B ''соуэ'':58B,96C ''спа'':28B,76C ''спа-центр'':27B,75C ''сс'':60B,98C ''статус'':67B ''стоимост'':64B ''тх'':59B,97C ''удобств'':22B ''фуд'':36B,84C ''фуд-корт'':35B,83C ''центр'':29B,77C ''э'':61B,99C ''электричеств'':51B ''этаж'':11B');
INSERT INTO stroy.project VALUES (5, 'Золотой Угол', 170, 2, '{1,63,42,72,62,13,48,7,37,32}', 11641969, '2022-06-07', 'Завершен', 'Проект "Золотой Угол" представляет собой здание класса Премиум с 15 этажами и общей площадью 119088 кв.м. В проекте предусмотрены следующие удобства: прачечная, банкоматы, бизнес-центр, круглосуточная охрана, велопарковка, видеонаблюдение, продуктовый супермаркет. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: ГС, КР, ОВиК, АПС, ПЗ, ЭОМ. Стоимость проекта: 11641969, статус: Завершен.', '{"floors": 15, "amenities": ["прачечная", "банкоматы", "бизнес-центр", "круглосуточная охрана", "велопарковка", "видеонаблюдение", "продуктовый супермаркет"], "documents": ["ГС", "КР", "ОВиК", "АПС", "ПЗ", "ЭОМ"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "Премиум", "total_area_sqm": 119088}', '''11641969'':54B ''119088'':17B,82C ''15'':12B,57C ''380'':43B,80C ''electr'':79C ''fals'':76C,78C ''gas'':75C ''water'':77C ''апс'':49B,72C ''банкомат'':26B,59C ''бизнес'':28B,61C ''бизнес-центр'':27B,60C ''велопарковк'':32B,65C ''видеонаблюден'':33B,66C ''вод'':40B ''газ'':38B ''гс'':46B,69C ''документац'':45B ''заверш'':56B ''здан'':8B ''золот'':1A,4B ''инженерн'':36B ''кв'':18B ''класс'':9B ''кр'':47B,70C ''круглосуточн'':30B,63C ''м'':19B ''общ'':15B ''овик'':48B,71C ''отсутств'':39B,41B ''охра'':31B,64C ''пз'':50B,73C ''площад'':16B ''прачечн'':25B,58C ''представля'':6B ''предусмотр'':22B ''премиум'':10B,81C ''продуктов'':34B,67C ''проект'':3B,21B,53B ''систем'':37B ''след'':23B ''соб'':7B ''статус'':55B ''стоимост'':52B ''супермаркет'':35B,68C ''угол'':2A,5B ''удобств'':24B ''центр'':29B,62C ''э'':51B,74C ''электричеств'':42B ''этаж'':13B');
INSERT INTO stroy.project VALUES (6, 'АрхиСтрой', 136, 75, '{46,17,69,57,21}', 30160474, '2023-01-21', 'Завершен', 'Проект "АрхиСтрой" представляет собой здание класса Премиум с 25 этажами и общей площадью 169454 кв.м. В проекте предусмотрены следующие удобства: круглосуточная охрана, игровая зона для детей, аптека, выставочный зал, банкоматы. Инженерные системы: газ - есть, вода - есть, электричество - 220 В. Документация: СС, ГС, ТХ, ПЗ, ОВиК. Стоимость проекта: 30160474, статус: Завершен.', '{"floors": 25, "amenities": ["круглосуточная охрана", "игровая зона для детей", "аптека", "выставочный зал", "банкоматы"], "documents": ["СС", "ГС", "ТХ", "ПЗ", "ОВиК"], "engineering": {"gas": true, "water": true, "electricity": 220}, "building_class": "Премиум", "total_area_sqm": 169454}', '''169454'':15B,76C ''220'':40B,74C ''25'':10B,53C ''30160474'':50B ''electr'':73C ''gas'':69C ''true'':70C,72C ''water'':71C ''аптек'':29B,60C ''архистр'':1A,3B ''банкомат'':32B,63C ''вод'':37B ''выставочн'':30B,61C ''газ'':35B ''гс'':44B,65C ''дет'':28B,59C ''документац'':42B ''заверш'':52B ''зал'':31B,62C ''здан'':6B ''зон'':26B,57C ''игров'':25B,56C ''инженерн'':33B ''кв'':16B ''класс'':7B ''круглосуточн'':23B,54C ''м'':17B ''общ'':13B ''овик'':47B,68C ''охра'':24B,55C ''пз'':46B,67C ''площад'':14B ''представля'':4B ''предусмотр'':20B ''премиум'':8B,75C ''проект'':2B,19B,49B ''систем'':34B ''след'':21B ''соб'':5B ''сс'':43B,64C ''статус'':51B ''стоимост'':48B ''тх'':45B,66C ''удобств'':22B ''электричеств'':39B ''этаж'':11B');
INSERT INTO stroy.project VALUES (7, 'Бетонный Рай', 208, 16, '{46,18,33,23,57,19,27,61,8,72}', 35098742, '2024-02-25', 'На подписании', 'Проект "Бетонный Рай" представляет собой здание класса D с 9 этажами и общей площадью 60036 кв.м. В проекте предусмотрены следующие удобства: выставочный зал, бизнес-центр, спа-центр, банкоматы, продуктовый супермаркет, салоны красоты, велопарковка. Инженерные системы: газ - есть, вода - есть, электричество - 380 В. Документация: АР, ГС, СОУЭ, СС, ТХ. Стоимость проекта: 35098742, статус: На подписании.', '{"floors": 9, "amenities": ["выставочный зал", "бизнес-центр", "спа-центр", "банкоматы", "продуктовый супермаркет", "салоны красоты", "велопарковка"], "documents": ["АР", "ГС", "СОУЭ", "СС", "ТХ"], "engineering": {"gas": true, "water": true, "electricity": 380}, "building_class": "D", "total_area_sqm": 60036}', '''35098742'':56B ''380'':46B,85C ''60036'':17B,87C ''9'':12B,60C ''d'':10B,86C ''electr'':84C ''gas'':80C ''true'':81C,83C ''water'':82C ''ар'':49B,75C ''банкомат'':33B,69C ''бетон'':1A,4B ''бизнес'':28B,64C ''бизнес-центр'':27B,63C ''велопарковк'':38B,74C ''вод'':43B ''выставочн'':25B,61C ''газ'':41B ''гс'':50B,76C ''документац'':48B ''зал'':26B,62C ''здан'':8B ''инженерн'':39B ''кв'':18B ''класс'':9B ''красот'':37B,73C ''м'':19B ''общ'':15B ''площад'':16B ''подписан'':59B ''представля'':6B ''предусмотр'':22B ''продуктов'':34B,70C ''проект'':3B,21B,55B ''ра'':2A,5B ''салон'':36B,72C ''систем'':40B ''след'':23B ''соб'':7B ''соуэ'':51B,77C ''спа'':31B,67C ''спа-центр'':30B,66C ''сс'':52B,78C ''статус'':57B ''стоимост'':54B ''супермаркет'':35B,71C ''тх'':53B,79C ''удобств'':24B ''центр'':29B,32B,65C,68C ''электричеств'':45B ''этаж'':13B');
INSERT INTO stroy.project VALUES (8, 'ГрандСтрой', 159, 56, '{54,75,6,26,59}', 37567876, '2023-06-16', 'В работе', 'Проект "ГрандСтрой" представляет собой здание класса А+ с 12 этажами и общей площадью 31888 кв.м. В проекте предусмотрены следующие удобства: продуктовый супермаркет, коворкинг, кофейня, химчистка, пропускная система, Фуд-корт, спа-центр. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: ТХ, КР, СС, ГС, АПС, ОВиК. Стоимость проекта: 37567876, статус: В работе.', '{"floors": 12, "amenities": ["продуктовый супермаркет", "коворкинг", "кофейня", "химчистка", "пропускная система", "Фуд-корт", "спа-центр"], "documents": ["ТХ", "КР", "СС", "ГС", "АПС", "ОВиК"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "А+", "total_area_sqm": 31888}', '''12'':10B,58C ''31888'':15B,85C ''37567876'':54B ''380'':43B,83C ''electr'':82C ''fals'':81C ''gas'':78C ''true'':79C ''water'':80C ''апс'':50B,76C ''вод'':40B ''газ'':38B ''грандстр'':1A,3B ''гс'':49B,75C ''документац'':45B ''здан'':6B ''инженерн'':36B ''кв'':16B ''класс'':7B ''коворкинг'':25B,61C ''корт'':32B,68C ''кофейн'':26B,62C ''кр'':47B,73C ''м'':17B ''общ'':13B ''овик'':51B,77C ''отсутств'':41B ''площад'':14B ''представля'':4B ''предусмотр'':20B ''продуктов'':23B,59C ''проект'':2B,19B,53B ''пропускн'':28B,64C ''работ'':57B ''систем'':29B,37B,65C ''след'':21B ''соб'':5B ''спа'':34B,70C ''спа-центр'':33B,69C ''сс'':48B,74C ''статус'':55B ''стоимост'':52B ''супермаркет'':24B,60C ''тх'':46B,72C ''удобств'':22B ''фуд'':31B,67C ''фуд-корт'':30B,66C ''химчистк'':27B,63C ''центр'':35B,71C ''электричеств'':42B ''этаж'':11B');
INSERT INTO stroy.project VALUES (9, 'Стальные Высоты', 63, 75, '{34,11,72,49,33,32,13,64}', 35098742, '2023-05-27', 'На подписании', 'Проект "Стальные Высоты" представляет собой здание класса B с 10 этажами и общей площадью 13738 кв.м. В проекте предусмотрены следующие удобства: переговорные комнаты, коворкинг, салоны красоты. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: ПЗ, ТХ, КР, СОУЭ, ОВиК. Стоимость проекта: 35098742, статус: На подписании.', '{"floors": 10, "amenities": ["переговорные комнаты", "коворкинг", "салоны красоты"], "documents": ["ПЗ", "ТХ", "КР", "СОУЭ", "ОВиК"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "B", "total_area_sqm": 13738}', '''10'':12B,51C ''13738'':17B,69C ''220'':37B,67C ''35098742'':47B ''b'':10B,68C ''electr'':66C ''fals'':63C ''gas'':62C ''true'':65C ''water'':64C ''вод'':34B ''высот'':2A,5B ''газ'':32B ''документац'':39B ''здан'':8B ''инженерн'':30B ''кв'':18B ''класс'':9B ''коворкинг'':27B,54C ''комнат'':26B,53C ''кр'':42B,59C ''красот'':29B,56C ''м'':19B ''общ'':15B ''овик'':44B,61C ''отсутств'':33B ''переговорн'':25B,52C ''пз'':40B,57C ''площад'':16B ''подписан'':50B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,46B ''салон'':28B,55C ''систем'':31B ''след'':23B ''соб'':7B ''соуэ'':43B,60C ''стальн'':1A,4B ''статус'':48B ''стоимост'':45B ''тх'':41B,58C ''удобств'':24B ''электричеств'':36B ''этаж'':13B');
INSERT INTO stroy.project VALUES (10, 'МонолитМастер', 233, 14, '{62,69,53,20,60,26,46,23}', 33864175, '2023-11-15', 'На подписании', 'Проект "МонолитМастер" представляет собой здание класса C с 7 этажами и общей площадью 103534 кв.м. В проекте предусмотрены следующие удобства: кофейня, детская комната, пропускная система, велопарковка, система климат-контроля, отделение банка, магазины одежды и обуви, прачечная, бесплатный Wi-Fi. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: ГС, ТХ, АР, ПЗ. Стоимость проекта: 33864175, статус: На подписании.', '{"floors": 7, "amenities": ["кофейня", "детская комната", "пропускная система", "велопарковка", "система климат-контроля", "отделение банка", "магазины одежды и обуви", "прачечная", "бесплатный Wi-Fi"], "documents": ["ГС", "ТХ", "АР", "ПЗ"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "C", "total_area_sqm": 103534}', '''103534'':15B,97C ''220'':51B,95C ''33864175'':60B ''7'':10B,64C ''c'':8B,96C ''electr'':94C ''fals'':91C,93C ''fi'':43B,85C ''gas'':90C ''water'':92C ''wi'':42B,84C ''wi-fi'':41B,83C ''ар'':56B,88C ''банк'':34B,76C ''бесплатн'':40B,82C ''велопарковк'':28B,70C ''вод'':48B ''газ'':46B ''гс'':54B,86C ''детск'':24B,66C ''документац'':53B ''здан'':6B ''инженерн'':44B ''кв'':16B ''класс'':7B ''климат'':31B,73C ''климат-контрол'':30B,72C ''комнат'':25B,67C ''контрол'':32B,74C ''кофейн'':23B,65C ''м'':17B ''магазин'':35B,77C ''монолитмастер'':1A,3B ''обув'':38B,80C ''общ'':13B ''одежд'':36B,78C ''отделен'':33B,75C ''отсутств'':47B,49B ''пз'':57B,89C ''площад'':14B ''подписан'':63B ''прачечн'':39B,81C ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,59B ''пропускн'':26B,68C ''систем'':27B,29B,45B,69C,71C ''след'':21B ''соб'':5B ''статус'':61B ''стоимост'':58B ''тх'':55B,87C ''удобств'':22B ''электричеств'':50B ''этаж'':11B');
INSERT INTO stroy.project VALUES (11, 'ЭлитСтрой', 201, 24, '{68,9,69,38,4,58,73,13,28,74,36}', 26456773, '2022-07-10', 'Отменен', 'Проект "ЭлитСтрой" представляет собой здание класса C с 24 этажами и общей площадью 5795 кв.м. В проекте предусмотрены следующие удобства: прачечная, переговорные комнаты, продуктовый супермаркет, паркинг для посетителей, детская комната. Инженерные системы: газ - есть, вода - есть, электричество - 380 В. Документация: ГС, СС, ЭОМ, ПЗ, АР, КР, ТХ, АПС. Стоимость проекта: 26456773, статус: Отменен.', '{"floors": 24, "amenities": ["прачечная", "переговорные комнаты", "продуктовый супермаркет", "паркинг для посетителей", "детская комната"], "documents": ["ГС", "СС", "ЭОМ", "ПЗ", "АР", "КР", "ТХ", "АПС"], "engineering": {"gas": true, "water": true, "electricity": 380}, "building_class": "C", "total_area_sqm": 5795}', '''24'':10B,56C ''26456773'':53B ''380'':40B,80C ''5795'':15B,82C ''c'':8B,81C ''electr'':79C ''gas'':75C ''true'':76C,78C ''water'':77C ''апс'':50B,74C ''ар'':47B,71C ''вод'':37B ''газ'':35B ''гс'':43B,67C ''детск'':31B,65C ''документац'':42B ''здан'':6B ''инженерн'':33B ''кв'':16B ''класс'':7B ''комнат'':25B,32B,59C,66C ''кр'':48B,72C ''м'':17B ''общ'':13B ''отмен'':55B ''паркинг'':28B,62C ''переговорн'':24B,58C ''пз'':46B,70C ''площад'':14B ''посетител'':30B,64C ''прачечн'':23B,57C ''представля'':4B ''предусмотр'':20B ''продуктов'':26B,60C ''проект'':2B,19B,52B ''систем'':34B ''след'':21B ''соб'':5B ''сс'':44B,68C ''статус'':54B ''стоимост'':51B ''супермаркет'':27B,61C ''тх'':49B,73C ''удобств'':22B ''э'':45B,69C ''электричеств'':39B ''элитстр'':1A,3B ''этаж'':11B');
INSERT INTO stroy.project VALUES (12, 'Вавилонские Вершины', 7, 18, '{26,59,57,44,54,78,69,43,39}', 14111103, '2024-03-05', 'Завершен', 'Проект "Вавилонские Вершины" представляет собой здание класса А+ с 20 этажами и общей площадью 99107 кв.м. В проекте предусмотрены следующие удобства: коворкинг, салоны красоты, переговорные комнаты, бесплатный Wi-Fi, магазины одежды и обуви, спа-центр, паркинг для посетителей, зона ожидания с мягкой мебелью, отделение банка. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: ПЗ, СС, АПС, КР, ГС. Стоимость проекта: 14111103, статус: Завершен.', '{"floors": 20, "amenities": ["коворкинг", "салоны красоты", "переговорные комнаты", "бесплатный Wi-Fi", "магазины одежды и обуви", "спа-центр", "паркинг для посетителей", "зона ожидания с мягкой мебелью", "отделение банка"], "documents": ["ПЗ", "СС", "АПС", "КР", "ГС"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "А+", "total_area_sqm": 99107}', '''14111103'':68B ''20'':12B,71C ''380'':58B,108C ''99107'':17B,110C ''electr'':107C ''fals'':106C ''fi'':33B,80C ''gas'':103C ''true'':104C ''water'':105C ''wi'':32B,79C ''wi-fi'':31B,78C ''апс'':63B,100C ''банк'':50B,97C ''бесплатн'':30B,77C ''вавилонск'':1A,4B ''вершин'':2A,5B ''вод'':55B ''газ'':53B ''гс'':65B,102C ''документац'':60B ''заверш'':70B ''здан'':8B ''зон'':44B,91C ''инженерн'':51B ''кв'':18B ''класс'':9B ''коворкинг'':25B,72C ''комнат'':29B,76C ''кр'':64B,101C ''красот'':27B,74C ''м'':19B ''магазин'':34B,81C ''мебел'':48B,95C ''мягк'':47B,94C ''обув'':37B,84C ''общ'':15B ''одежд'':35B,82C ''ожидан'':45B,92C ''отделен'':49B,96C ''отсутств'':56B ''паркинг'':41B,88C ''переговорн'':28B,75C ''пз'':61B,98C ''площад'':16B ''посетител'':43B,90C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,67B ''салон'':26B,73C ''систем'':52B ''след'':23B ''соб'':7B ''спа'':39B,86C ''спа-центр'':38B,85C ''сс'':62B,99C ''статус'':69B ''стоимост'':66B ''удобств'':24B ''центр'':40B,87C ''электричеств'':57B ''этаж'':13B');
INSERT INTO stroy.project VALUES (13, 'Кристалл Тауэрс', 199, 14, '{43,77,67,38,3,44}', 12876536, '2022-12-31', 'Отменен', 'Проект "Кристалл Тауэрс" представляет собой здание класса Бизнес с 10 этажами и общей площадью 145377 кв.м. В проекте предусмотрены следующие удобства: отделение банка, паркинг для посетителей, электроника и бытовая техника, бесплатный Wi-Fi. Инженерные системы: газ - есть, вода - есть, электричество - 220 В. Документация: АР, АПС, ТХ. Стоимость проекта: 12876536, статус: Отменен.', '{"floors": 10, "amenities": ["отделение банка", "паркинг для посетителей", "электроника и бытовая техника", "бесплатный Wi-Fi"], "documents": ["АР", "АПС", "ТХ"], "engineering": {"gas": true, "water": true, "electricity": 220}, "building_class": "Бизнес", "total_area_sqm": 145377}', '''10'':12B,56C ''12876536'':53B ''145377'':17B,80C ''220'':45B,78C ''electr'':77C ''fi'':37B,69C ''gas'':73C ''true'':74C,76C ''water'':75C ''wi'':36B,68C ''wi-fi'':35B,67C ''апс'':49B,71C ''ар'':48B,70C ''банк'':26B,58C ''бесплатн'':34B,66C ''бизнес'':10B,79C ''бытов'':32B,64C ''вод'':42B ''газ'':40B ''документац'':47B ''здан'':8B ''инженерн'':38B ''кв'':18B ''класс'':9B ''кристалл'':1A,4B ''м'':19B ''общ'':15B ''отделен'':25B,57C ''отмен'':55B ''паркинг'':27B,59C ''площад'':16B ''посетител'':29B,61C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,52B ''систем'':39B ''след'':23B ''соб'':7B ''статус'':54B ''стоимост'':51B ''тауэрс'':2A,5B ''техник'':33B,65C ''тх'':50B,72C ''удобств'':24B ''электричеств'':44B ''электроник'':30B,62C ''этаж'':13B');
INSERT INTO stroy.project VALUES (14, 'Империя Зодчих', 189, 58, '{16,48,30,70,60,3,56,55,68,42,66,6}', 14111103, '2022-07-11', 'На подписании', 'Проект "Империя Зодчих" представляет собой здание класса Эконом с 14 этажами и общей площадью 114800 кв.м. В проекте предусмотрены следующие удобства: Фуд-корт, спа-центр, конференц-залы, коворкинг, детская комната, магазины одежды и обуви, велопарковка. Инженерные системы: газ - отсутствует, вода - есть, электричество - 380 В. Документация: АР, СС, ТХ. Стоимость проекта: 14111103, статус: На подписании.', '{"floors": 14, "amenities": ["Фуд-корт", "спа-центр", "конференц-залы", "коворкинг", "детская комната", "магазины одежды и обуви", "велопарковка"], "documents": ["АР", "СС", "ТХ"], "engineering": {"gas": false, "water": true, "electricity": 380}, "building_class": "Эконом", "total_area_sqm": 114800}', '''114800'':17B,89C ''14'':12B,61C ''14111103'':57B ''380'':49B,87C ''electr'':86C ''fals'':83C ''gas'':82C ''true'':85C ''water'':84C ''ар'':52B,79C ''велопарковк'':41B,78C ''вод'':46B ''газ'':44B ''детск'':35B,72C ''документац'':51B ''зал'':33B,70C ''здан'':8B ''зодч'':2A,5B ''импер'':1A,4B ''инженерн'':42B ''кв'':18B ''класс'':9B ''коворкинг'':34B,71C ''комнат'':36B,73C ''конференц'':32B,69C ''конференц-зал'':31B,68C ''корт'':27B,64C ''м'':19B ''магазин'':37B,74C ''обув'':40B,77C ''общ'':15B ''одежд'':38B,75C ''отсутств'':45B ''площад'':16B ''подписан'':60B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,56B ''систем'':43B ''след'':23B ''соб'':7B ''спа'':29B,66C ''спа-центр'':28B,65C ''сс'':53B,80C ''статус'':58B ''стоимост'':55B ''тх'':54B,81C ''удобств'':24B ''фуд'':26B,63C ''фуд-корт'':25B,62C ''центр'':30B,67C ''экон'':10B,88C ''электричеств'':48B ''этаж'':13B');
INSERT INTO stroy.project VALUES (15, 'Созвездие Домов', 220, 8, '{74}', 6703701, '2022-04-19', 'Отменен', 'Проект "Созвездие Домов" представляет собой здание класса Бизнес с 11 этажами и общей площадью 72344 кв.м. В проекте предусмотрены следующие удобства: велопарковка, Фуд-корт, банкоматы, детская комната. Инженерные системы: газ - есть, вода - есть, электричество - 220 В. Документация: ГС, ОВиК, ТХ, АПС, СОУЭ, ЭОМ, ПЗ, СС, КР. Стоимость проекта: 6703701, статус: Отменен.', '{"floors": 11, "amenities": ["велопарковка", "Фуд-корт", "банкоматы", "детская комната"], "documents": ["ГС", "ОВиК", "ТХ", "АПС", "СОУЭ", "ЭОМ", "ПЗ", "СС", "КР"], "engineering": {"gas": true, "water": true, "electricity": 220}, "building_class": "Бизнес", "total_area_sqm": 72344}', '''11'':12B,56C ''220'':39B,78C ''6703701'':53B ''72344'':17B,80C ''electr'':77C ''gas'':73C ''true'':74C,76C ''water'':75C ''апс'':45B,67C ''банкомат'':29B,61C ''бизнес'':10B,79C ''велопарковк'':25B,57C ''вод'':36B ''газ'':34B ''гс'':42B,64C ''детск'':30B,62C ''документац'':41B ''дом'':2A,5B ''здан'':8B ''инженерн'':32B ''кв'':18B ''класс'':9B ''комнат'':31B,63C ''корт'':28B,60C ''кр'':50B,72C ''м'':19B ''общ'':15B ''овик'':43B,65C ''отмен'':55B ''пз'':48B,70C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,52B ''систем'':33B ''след'':23B ''соб'':7B ''созвезд'':1A,4B ''соуэ'':46B,68C ''сс'':49B,71C ''статус'':54B ''стоимост'':51B ''тх'':44B,66C ''удобств'':24B ''фуд'':27B,59C ''фуд-корт'':26B,58C ''э'':47B,69C ''электричеств'':38B ''этаж'':13B');
INSERT INTO stroy.project VALUES (16, 'Гармония Пространства', 44, 72, '{17,59,52}', 14111103, '2022-12-21', 'На подписании', 'Проект "Гармония Пространства" представляет собой здание класса B с 14 этажами и общей площадью 15702 кв.м. В проекте предусмотрены следующие удобства: кофейня, бесплатный Wi-Fi, подземный паркинг, велопарковка. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: АПС, ПЗ, ГС, АР, СС, СОУЭ, ОВиК, ТХ, ЭОМ. Стоимость проекта: 14111103, статус: На подписании.', '{"floors": 14, "amenities": ["кофейня", "бесплатный Wi-Fi", "подземный паркинг", "велопарковка"], "documents": ["АПС", "ПЗ", "ГС", "АР", "СС", "СОУЭ", "ОВиК", "ТХ", "ЭОМ"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "B", "total_area_sqm": 15702}', '''14'':12B,58C ''14111103'':54B ''15702'':17B,83C ''220'':40B,81C ''b'':10B,82C ''electr'':80C ''fals'':77C,79C ''fi'':29B,63C ''gas'':76C ''water'':78C ''wi'':28B,62C ''wi-fi'':27B,61C ''апс'':43B,67C ''ар'':46B,70C ''бесплатн'':26B,60C ''велопарковк'':32B,66C ''вод'':37B ''газ'':35B ''гармон'':1A,4B ''гс'':45B,69C ''документац'':42B ''здан'':8B ''инженерн'':33B ''кв'':18B ''класс'':9B ''кофейн'':25B,59C ''м'':19B ''общ'':15B ''овик'':49B,73C ''отсутств'':36B,38B ''паркинг'':31B,65C ''пз'':44B,68C ''площад'':16B ''подземн'':30B,64C ''подписан'':57B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,53B ''пространств'':2A,5B ''систем'':34B ''след'':23B ''соб'':7B ''соуэ'':48B,72C ''сс'':47B,71C ''статус'':55B ''стоимост'':52B ''тх'':50B,74C ''удобств'':24B ''э'':51B,75C ''электричеств'':39B ''этаж'':13B');
INSERT INTO stroy.project VALUES (17, 'Квартал Успеха', 81, 36, '{79,28,64,27,68,46}', 19049371, '2023-07-17', 'На подписании', 'Проект "Квартал Успеха" представляет собой здание класса D с 16 этажами и общей площадью 22224 кв.м. В проекте предусмотрены следующие удобства: банкоматы, круглосуточная охрана, выставочный зал, кофейня, детская комната, аптека, паркинг для посетителей, химчистка, зона ожидания с мягкой мебелью. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: ТХ, ГС, КР, ОВиК. Стоимость проекта: 19049371, статус: На подписании.', '{"floors": 16, "amenities": ["банкоматы", "круглосуточная охрана", "выставочный зал", "кофейня", "детская комната", "аптека", "паркинг для посетителей", "химчистка", "зона ожидания с мягкой мебелью"], "documents": ["ТХ", "ГС", "КР", "ОВиК"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "D", "total_area_sqm": 22224}', '''16'':12B,63C ''19049371'':59B ''22224'':17B,93C ''380'':50B,91C ''d'':10B,92C ''electr'':90C ''fals'':89C ''gas'':86C ''true'':87C ''water'':88C ''аптек'':33B,72C ''банкомат'':25B,64C ''вод'':47B ''выставочн'':28B,67C ''газ'':45B ''гс'':54B,83C ''детск'':31B,70C ''документац'':52B ''зал'':29B,68C ''здан'':8B ''зон'':38B,77C ''инженерн'':43B ''кв'':18B ''кварта'':1A,4B ''класс'':9B ''комнат'':32B,71C ''кофейн'':30B,69C ''кр'':55B,84C ''круглосуточн'':26B,65C ''м'':19B ''мебел'':42B,81C ''мягк'':41B,80C ''общ'':15B ''овик'':56B,85C ''ожидан'':39B,78C ''отсутств'':48B ''охра'':27B,66C ''паркинг'':34B,73C ''площад'':16B ''подписан'':62B ''посетител'':36B,75C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,58B ''систем'':44B ''след'':23B ''соб'':7B ''статус'':60B ''стоимост'':57B ''тх'':53B,82C ''удобств'':24B ''успех'':2A,5B ''химчистк'':37B,76C ''электричеств'':49B ''этаж'':13B');
INSERT INTO stroy.project VALUES (18, 'Мегаполис Фьючер', 183, 8, '{60,78,72,53,51,69,3}', 20283938, '2023-03-28', 'Отменен', 'Проект "Мегаполис Фьючер" представляет собой здание класса C с 13 этажами и общей площадью 125569 кв.м. В проекте предусмотрены следующие удобства: детская комната, отделение банка, бизнес-центр, продуктовый супермаркет. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: ОВиК, СС, АПС, ГС. Стоимость проекта: 20283938, статус: Отменен.', '{"floors": 13, "amenities": ["детская комната", "отделение банка", "бизнес-центр", "продуктовый супермаркет"], "documents": ["ОВиК", "СС", "АПС", "ГС"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "C", "total_area_sqm": 125569}', '''125569'':17B,74C ''13'':12B,53C ''20283938'':50B ''380'':41B,72C ''c'':10B,73C ''electr'':71C ''fals'':68C,70C ''gas'':67C ''water'':69C ''апс'':46B,65C ''банк'':28B,57C ''бизнес'':30B,59C ''бизнес-центр'':29B,58C ''вод'':38B ''газ'':36B ''гс'':47B,66C ''детск'':25B,54C ''документац'':43B ''здан'':8B ''инженерн'':34B ''кв'':18B ''класс'':9B ''комнат'':26B,55C ''м'':19B ''мегаполис'':1A,4B ''общ'':15B ''овик'':44B,63C ''отделен'':27B,56C ''отмен'':52B ''отсутств'':37B,39B ''площад'':16B ''представля'':6B ''предусмотр'':22B ''продуктов'':32B,61C ''проект'':3B,21B,49B ''систем'':35B ''след'':23B ''соб'':7B ''сс'':45B,64C ''статус'':51B ''стоимост'':48B ''супермаркет'':33B,62C ''удобств'':24B ''фьючер'':2A,5B ''центр'':31B,60C ''электричеств'':40B ''этаж'':13B');
INSERT INTO stroy.project VALUES (19, 'Оазис Строй', 164, 33, '{20,65,12,48,34,53}', 7938268, '2022-04-23', 'На подписании', 'Проект "Оазис Строй" представляет собой здание класса B с 24 этажами и общей площадью 89663 кв.м. В проекте предусмотрены следующие удобства: видеонаблюдение, детская комната, велопарковка, круглосуточная охрана, пропускная система, продуктовый супермаркет, конференц-залы. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: ТХ, АР, ГС, ЭОМ, ОВиК, СС, ПЗ. Стоимость проекта: 7938268, статус: На подписании.', '{"floors": 24, "amenities": ["видеонаблюдение", "детская комната", "велопарковка", "круглосуточная охрана", "пропускная система", "продуктовый супермаркет", "конференц-залы"], "documents": ["ТХ", "АР", "ГС", "ЭОМ", "ОВиК", "СС", "ПЗ"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "B", "total_area_sqm": 89663}', '''220'':45B,87C ''24'':12B,61C ''7938268'':57B ''89663'':17B,89C ''b'':10B,88C ''electr'':86C ''fals'':83C ''gas'':82C ''true'':85C ''water'':84C ''ар'':49B,76C ''велопарковк'':28B,65C ''видеонаблюден'':25B,62C ''вод'':42B ''газ'':40B ''гс'':50B,77C ''детск'':26B,63C ''документац'':47B ''зал'':37B,74C ''здан'':8B ''инженерн'':38B ''кв'':18B ''класс'':9B ''комнат'':27B,64C ''конференц'':36B,73C ''конференц-зал'':35B,72C ''круглосуточн'':29B,66C ''м'':19B ''оазис'':1A,4B ''общ'':15B ''овик'':52B,79C ''отсутств'':41B ''охра'':30B,67C ''пз'':54B,81C ''площад'':16B ''подписан'':60B ''представля'':6B ''предусмотр'':22B ''продуктов'':33B,70C ''проект'':3B,21B,56B ''пропускн'':31B,68C ''систем'':32B,39B,69C ''след'':23B ''соб'':7B ''сс'':53B,80C ''статус'':58B ''стоимост'':55B ''стро'':2A,5B ''супермаркет'':34B,71C ''тх'':48B,75C ''удобств'':24B ''э'':51B,78C ''электричеств'':44B ''этаж'':13B');
INSERT INTO stroy.project VALUES (20, 'Панорама Горизонтов', 51, 2, '{55,33,8,38,47,73,50,29,63}', 37567876, '2022-09-30', 'Завершен', 'Проект "Панорама Горизонтов" представляет собой здание класса Эконом с 21 этажами и общей площадью 56034 кв.м. В проекте предусмотрены следующие удобства: бизнес-центр, продуктовый супермаркет, прачечная, аптека, зона ожидания с мягкой мебелью, паркинг для посетителей, спа-центр, кофейня. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: АПС, ГС, СОУЭ, СС. Стоимость проекта: 37567876, статус: Завершен.', '{"floors": 21, "amenities": ["бизнес-центр", "продуктовый супермаркет", "прачечная", "аптека", "зона ожидания с мягкой мебелью", "паркинг для посетителей", "спа-центр", "кофейня"], "documents": ["АПС", "ГС", "СОУЭ", "СС"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "Эконом", "total_area_sqm": 56034}', '''21'':12B,63C ''220'':51B,92C ''37567876'':60B ''56034'':17B,94C ''electr'':91C ''fals'':88C,90C ''gas'':87C ''water'':89C ''апс'':54B,83C ''аптек'':31B,70C ''бизнес'':26B,65C ''бизнес-центр'':25B,64C ''вод'':48B ''газ'':46B ''горизонт'':2A,5B ''гс'':55B,84C ''документац'':53B ''заверш'':62B ''здан'':8B ''зон'':32B,71C ''инженерн'':44B ''кв'':18B ''класс'':9B ''кофейн'':43B,82C ''м'':19B ''мебел'':36B,75C ''мягк'':35B,74C ''общ'':15B ''ожидан'':33B,72C ''отсутств'':47B,49B ''панорам'':1A,4B ''паркинг'':37B,76C ''площад'':16B ''посетител'':39B,78C ''прачечн'':30B,69C ''представля'':6B ''предусмотр'':22B ''продуктов'':28B,67C ''проект'':3B,21B,59B ''систем'':45B ''след'':23B ''соб'':7B ''соуэ'':56B,85C ''спа'':41B,80C ''спа-центр'':40B,79C ''сс'':57B,86C ''статус'':61B ''стоимост'':58B ''супермаркет'':29B,68C ''удобств'':24B ''центр'':27B,42B,66C,81C ''экон'':10B,93C ''электричеств'':50B ''этаж'':13B');
INSERT INTO stroy.project VALUES (21, 'Городской Оазис', 112, 73, '{43,75,45,50,46,53,54,55,32,79,76}', 7938268, '2022-05-28', 'Завершен', 'Проект "Городской Оазис" представляет собой здание класса C с 13 этажами и общей площадью 166253 кв.м. В проекте предусмотрены следующие удобства: химчистка, пропускная система, паркинг для посетителей, аптека, велопарковка. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: ГС, ОВиК, ЭОМ, ПЗ, КР, АР, СОУЭ, ТХ, СС. Стоимость проекта: 7938268, статус: Завершен.', '{"floors": 13, "amenities": ["химчистка", "пропускная система", "паркинг для посетителей", "аптека", "велопарковка"], "documents": ["ГС", "ОВиК", "ЭОМ", "ПЗ", "КР", "АР", "СОУЭ", "ТХ", "СС"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "C", "total_area_sqm": 166253}', '''13'':12B,57C ''166253'':17B,82C ''220'':40B,80C ''7938268'':54B ''c'':10B,81C ''electr'':79C ''fals'':76C,78C ''gas'':75C ''water'':77C ''аптек'':31B,64C ''ар'':48B,71C ''велопарковк'':32B,65C ''вод'':37B ''газ'':35B ''городск'':1A,4B ''гс'':43B,66C ''документац'':42B ''заверш'':56B ''здан'':8B ''инженерн'':33B ''кв'':18B ''класс'':9B ''кр'':47B,70C ''м'':19B ''оазис'':2A,5B ''общ'':15B ''овик'':44B,67C ''отсутств'':36B,38B ''паркинг'':28B,61C ''пз'':46B,69C ''площад'':16B ''посетител'':30B,63C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,53B ''пропускн'':26B,59C ''систем'':27B,34B,60C ''след'':23B ''соб'':7B ''соуэ'':49B,72C ''сс'':51B,74C ''статус'':55B ''стоимост'':52B ''тх'':50B,73C ''удобств'':24B ''химчистк'':25B,58C ''э'':45B,68C ''электричеств'':39B ''этаж'':13B');
INSERT INTO stroy.project VALUES (22, 'АвангардСтрой', 49, 14, '{33,31,10,43,22,58,63,54}', 23987639, '2023-08-10', 'В работе', 'Проект "АвангардСтрой" представляет собой здание класса Бизнес с 17 этажами и общей площадью 31925 кв.м. В проекте предусмотрены следующие удобства: пропускная система, прачечная, электроника и бытовая техника, круглосуточная охрана, магазины одежды и обуви, рестораны и кафе, выставочный зал. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: ТХ, СОУЭ, КР. Стоимость проекта: 23987639, статус: В работе.', '{"floors": 17, "amenities": ["пропускная система", "прачечная", "электроника и бытовая техника", "круглосуточная охрана", "магазины одежды и обуви", "рестораны и кафе", "выставочный зал"], "documents": ["ТХ", "СОУЭ", "КР"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "Бизнес", "total_area_sqm": 31925}', '''17'':10B,60C ''220'':48B,87C ''23987639'':56B ''31925'':15B,89C ''electr'':86C ''fals'':85C ''gas'':82C ''true'':83C ''water'':84C ''авангардстр'':1A,3B ''бизнес'':8B,88C ''бытов'':28B,66C ''вод'':45B ''выставочн'':39B,77C ''газ'':43B ''документац'':50B ''зал'':40B,78C ''здан'':6B ''инженерн'':41B ''каф'':38B,76C ''кв'':16B ''класс'':7B ''кр'':53B,81C ''круглосуточн'':30B,68C ''м'':17B ''магазин'':32B,70C ''обув'':35B,73C ''общ'':13B ''одежд'':33B,71C ''отсутств'':46B ''охра'':31B,69C ''площад'':14B ''прачечн'':25B,63C ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,55B ''пропускн'':23B,61C ''работ'':59B ''рестора'':36B,74C ''систем'':24B,42B,62C ''след'':21B ''соб'':5B ''соуэ'':52B,80C ''статус'':57B ''стоимост'':54B ''техник'':29B,67C ''тх'':51B,79C ''удобств'':22B ''электричеств'':47B ''электроник'':26B,64C ''этаж'':11B');
INSERT INTO stroy.project VALUES (23, 'Бриллиантовые Врата', 206, 58, '{57,72,13,60}', 20283938, '2022-05-09', 'На подписании', 'Проект "Бриллиантовые Врата" представляет собой здание класса D с 12 этажами и общей площадью 55550 кв.м. В проекте предусмотрены следующие удобства: коворкинг, детская комната, бесплатный Wi-Fi, бизнес-центр, спа-центр, круглосуточная охрана. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: СС, ЭОМ, АПС, ГС, ОВиК, ПЗ, АР, КР. Стоимость проекта: 20283938, статус: На подписании.', '{"floors": 12, "amenities": ["коворкинг", "детская комната", "бесплатный Wi-Fi", "бизнес-центр", "спа-центр", "круглосуточная охрана"], "documents": ["СС", "ЭОМ", "АПС", "ГС", "ОВиК", "ПЗ", "АР", "КР"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "D", "total_area_sqm": 55550}', '''12'':12B,64C ''20283938'':60B ''380'':47B,93C ''55550'':17B,95C ''d'':10B,94C ''electr'':92C ''fals'':89C,91C ''fi'':31B,71C ''gas'':88C ''water'':90C ''wi'':30B,70C ''wi-fi'':29B,69C ''апс'':52B,82C ''ар'':56B,86C ''бесплатн'':28B,68C ''бизнес'':33B,73C ''бизнес-центр'':32B,72C ''бриллиантов'':1A,4B ''вод'':44B ''врат'':2A,5B ''газ'':42B ''гс'':53B,83C ''детск'':26B,66C ''документац'':49B ''здан'':8B ''инженерн'':40B ''кв'':18B ''класс'':9B ''коворкинг'':25B,65C ''комнат'':27B,67C ''кр'':57B,87C ''круглосуточн'':38B,78C ''м'':19B ''общ'':15B ''овик'':54B,84C ''отсутств'':43B,45B ''охра'':39B,79C ''пз'':55B,85C ''площад'':16B ''подписан'':63B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,59B ''систем'':41B ''след'':23B ''соб'':7B ''спа'':36B,76C ''спа-центр'':35B,75C ''сс'':50B,80C ''статус'':61B ''стоимост'':58B ''удобств'':24B ''центр'':34B,37B,74C,77C ''э'':51B,81C ''электричеств'':46B ''этаж'':13B');
INSERT INTO stroy.project VALUES (24, 'ФортунаСтрой', 206, 73, '{10,55,2,57,43}', 6703701, '2022-10-21', 'На подписании', 'Проект "ФортунаСтрой" представляет собой здание класса D с 20 этажами и общей площадью 127942 кв.м. В проекте предусмотрены следующие удобства: рестораны и кафе, выставочный зал, кофейня, подземный паркинг, аптека, банкоматы. Инженерные системы: газ - отсутствует, вода - есть, электричество - 380 В. Документация: АПС, СОУЭ, СС, АР. Стоимость проекта: 6703701, статус: На подписании.', '{"floors": 20, "amenities": ["рестораны и кафе", "выставочный зал", "кофейня", "подземный паркинг", "аптека", "банкоматы"], "documents": ["АПС", "СОУЭ", "СС", "АР"], "engineering": {"gas": false, "water": true, "electricity": 380}, "building_class": "D", "total_area_sqm": 127942}', '''127942'':15B,75C ''20'':10B,53C ''380'':40B,73C ''6703701'':49B ''d'':8B,74C ''electr'':72C ''fals'':69C ''gas'':68C ''true'':71C ''water'':70C ''апс'':43B,64C ''аптек'':31B,62C ''ар'':46B,67C ''банкомат'':32B,63C ''вод'':37B ''выставочн'':26B,57C ''газ'':35B ''документац'':42B ''зал'':27B,58C ''здан'':6B ''инженерн'':33B ''каф'':25B,56C ''кв'':16B ''класс'':7B ''кофейн'':28B,59C ''м'':17B ''общ'':13B ''отсутств'':36B ''паркинг'':30B,61C ''площад'':14B ''подземн'':29B,60C ''подписан'':52B ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,48B ''рестора'':23B,54C ''систем'':34B ''след'':21B ''соб'':5B ''соуэ'':44B,65C ''сс'':45B,66C ''статус'':50B ''стоимост'':47B ''удобств'':22B ''фортунастр'':1A,3B ''электричеств'':39B ''этаж'':11B');
INSERT INTO stroy.project VALUES (25, 'МастерГрад', 264, 44, '{50,30,10,26,40,61}', 16580237, '2022-09-02', 'В работе', 'Проект "МастерГрад" представляет собой здание класса C с 15 этажами и общей площадью 64808 кв.м. В проекте предусмотрены следующие удобства: велопарковка, круглосуточная охрана, подземный паркинг, салоны красоты, детская комната, конференц-залы, кофейня. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: АПС, ОВиК, СОУЭ, АР, ТХ, ПЗ, СС, ЭОМ, ГС. Стоимость проекта: 16580237, статус: В работе.', '{"floors": 15, "amenities": ["велопарковка", "круглосуточная охрана", "подземный паркинг", "салоны красоты", "детская комната", "конференц-залы", "кофейня"], "documents": ["АПС", "ОВиК", "СОУЭ", "АР", "ТХ", "ПЗ", "СС", "ЭОМ", "ГС"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "C", "total_area_sqm": 64808}', '''15'':10B,61C ''16580237'':57B ''220'':43B,89C ''64808'':15B,91C ''c'':8B,90C ''electr'':88C ''fals'':87C ''gas'':84C ''true'':85C ''water'':86C ''апс'':46B,75C ''ар'':49B,78C ''велопарковк'':23B,62C ''вод'':40B ''газ'':38B ''гс'':54B,83C ''детск'':30B,69C ''документац'':45B ''зал'':34B,73C ''здан'':6B ''инженерн'':36B ''кв'':16B ''класс'':7B ''комнат'':31B,70C ''конференц'':33B,72C ''конференц-зал'':32B,71C ''кофейн'':35B,74C ''красот'':29B,68C ''круглосуточн'':24B,63C ''м'':17B ''мастерград'':1A,3B ''общ'':13B ''овик'':47B,76C ''отсутств'':41B ''охра'':25B,64C ''паркинг'':27B,66C ''пз'':51B,80C ''площад'':14B ''подземн'':26B,65C ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,56B ''работ'':60B ''салон'':28B,67C ''систем'':37B ''след'':21B ''соб'':5B ''соуэ'':48B,77C ''сс'':52B,81C ''статус'':58B ''стоимост'':55B ''тх'':50B,79C ''удобств'':22B ''э'':53B,82C ''электричеств'':42B ''этаж'':11B');
INSERT INTO stroy.project VALUES (26, 'ПрестижХаус', 270, 72, '{12,78,24,37,19,55,74,52,54,39,42}', 17814804, '2022-07-28', 'На подписании', 'Проект "ПрестижХаус" представляет собой здание класса А с 25 этажами и общей площадью 92898 кв.м. В проекте предусмотрены следующие удобства: паркинг для посетителей, система климат-контроля, детская комната, бесплатный Wi-Fi, пропускная система, переговорные комнаты, коворкинг, прачечная, Фуд-корт. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: АР, ЭОМ, АПС, ОВиК, СС, ГС, ПЗ. Стоимость проекта: 17814804, статус: На подписании.', '{"floors": 25, "amenities": ["паркинг для посетителей", "система климат-контроля", "детская комната", "бесплатный Wi-Fi", "пропускная система", "переговорные комнаты", "коворкинг", "прачечная", "Фуд-корт"], "documents": ["АР", "ЭОМ", "АПС", "ОВиК", "СС", "ГС", "ПЗ"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "А", "total_area_sqm": 92898}', '''17814804'':64B ''220'':52B,103C ''25'':10B,68C ''92898'':15B,105C ''electr'':102C ''fals'':101C ''fi'':35B,81C ''gas'':98C ''true'':99C ''water'':100C ''wi'':34B,80C ''wi-fi'':33B,79C ''апс'':57B,93C ''ар'':55B,91C ''бесплатн'':32B,78C ''вод'':49B ''газ'':47B ''гс'':60B,96C ''детск'':30B,76C ''документац'':54B ''здан'':6B ''инженерн'':45B ''кв'':16B ''класс'':7B ''климат'':28B,74C ''климат-контрол'':27B,73C ''коворкинг'':40B,86C ''комнат'':31B,39B,77C,85C ''контрол'':29B,75C ''корт'':44B,90C ''м'':17B ''общ'':13B ''овик'':58B,94C ''отсутств'':50B ''паркинг'':23B,69C ''переговорн'':38B,84C ''пз'':61B,97C ''площад'':14B ''подписан'':67B ''посетител'':25B,71C ''прачечн'':41B,87C ''представля'':4B ''предусмотр'':20B ''престижхаус'':1A,3B ''проект'':2B,19B,63B ''пропускн'':36B,82C ''систем'':26B,37B,46B,72C,83C ''след'':21B ''соб'':5B ''сс'':59B,95C ''статус'':65B ''стоимост'':62B ''удобств'':22B ''фуд'':43B,89C ''фуд-корт'':42B,88C ''э'':56B,92C ''электричеств'':51B ''этаж'':11B');
INSERT INTO stroy.project VALUES (27, 'Сапфировый Берег', 2, 36, '{61,16,43,77,14,40}', 4234567, '2022-12-27', 'Завершен', 'Проект "Сапфировый Берег" представляет собой здание класса Эконом с 11 этажами и общей площадью 104192 кв.м. В проекте предусмотрены следующие удобства: конференц-залы, магазины одежды и обуви, игровая зона для детей, спа-центр, подземный паркинг, кофейня. Инженерные системы: газ - есть, вода - есть, электричество - 380 В. Документация: ПЗ, КР, СС, ТХ, ОВиК, ЭОМ, СОУЭ, АПС. Стоимость проекта: 4234567, статус: Завершен.', '{"floors": 11, "amenities": ["конференц-залы", "магазины одежды и обуви", "игровая зона для детей", "спа-центр", "подземный паркинг", "кофейня"], "documents": ["ПЗ", "КР", "СС", "ТХ", "ОВиК", "ЭОМ", "СОУЭ", "АПС"], "engineering": {"gas": true, "water": true, "electricity": 380}, "building_class": "Эконом", "total_area_sqm": 104192}', '''104192'':17B,98C ''11'':12B,65C ''380'':49B,96C ''4234567'':62B ''electr'':95C ''gas'':91C ''true'':92C,94C ''water'':93C ''апс'':59B,90C ''берег'':2A,5B ''вод'':46B ''газ'':44B ''дет'':35B,76C ''документац'':51B ''заверш'':64B ''зал'':27B,68C ''здан'':8B ''зон'':33B,74C ''игров'':32B,73C ''инженерн'':42B ''кв'':18B ''класс'':9B ''конференц'':26B,67C ''конференц-зал'':25B,66C ''кофейн'':41B,82C ''кр'':53B,84C ''м'':19B ''магазин'':28B,69C ''обув'':31B,72C ''общ'':15B ''овик'':56B,87C ''одежд'':29B,70C ''паркинг'':40B,81C ''пз'':52B,83C ''площад'':16B ''подземн'':39B,80C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,61B ''сапфиров'':1A,4B ''систем'':43B ''след'':23B ''соб'':7B ''соуэ'':58B,89C ''спа'':37B,78C ''спа-центр'':36B,77C ''сс'':54B,85C ''статус'':63B ''стоимост'':60B ''тх'':55B,86C ''удобств'':24B ''центр'':38B,79C ''э'':57B,88C ''экон'':10B,97C ''электричеств'':48B ''этаж'':13B');
INSERT INTO stroy.project VALUES (29, 'Урбанистик', 27, 24, '{57,79,49,70,61,80}', 31395041, '2023-11-03', 'Отменен', 'Проект "Урбанистик" представляет собой здание класса А с 25 этажами и общей площадью 158332 кв.м. В проекте предусмотрены следующие удобства: паркинг для посетителей, конференц-залы, подземный паркинг. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: ГС, ТХ, ЭОМ, КР, АПС. Стоимость проекта: 31395041, статус: Отменен.', '{"floors": 25, "amenities": ["паркинг для посетителей", "конференц-залы", "подземный паркинг"], "documents": ["ГС", "ТХ", "ЭОМ", "КР", "АПС"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "А", "total_area_sqm": 158332}', '''158332'':15B,72C ''25'':10B,51C ''31395041'':48B ''380'':38B,70C ''electr'':69C ''fals'':66C,68C ''gas'':65C ''water'':67C ''апс'':45B,64C ''вод'':35B ''газ'':33B ''гс'':41B,60C ''документац'':40B ''зал'':28B,57C ''здан'':6B ''инженерн'':31B ''кв'':16B ''класс'':7B ''конференц'':27B,56C ''конференц-зал'':26B,55C ''кр'':44B,63C ''м'':17B ''общ'':13B ''отмен'':50B ''отсутств'':34B,36B ''паркинг'':23B,30B,52C,59C ''площад'':14B ''подземн'':29B,58C ''посетител'':25B,54C ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,47B ''систем'':32B ''след'':21B ''соб'':5B ''статус'':49B ''стоимост'':46B ''тх'':42B,61C ''удобств'':22B ''урбанистик'':1A,3B ''э'':43B,62C ''электричеств'':37B ''этаж'':11B');
INSERT INTO stroy.project VALUES (30, 'ФьюжнСити', 130, 2, '{47,37}', 14111103, '2022-11-21', 'В работе', 'Проект "ФьюжнСити" представляет собой здание класса А с 17 этажами и общей площадью 146169 кв.м. В проекте предусмотрены следующие удобства: спа-центр, велопарковка, конференц-залы, бесплатный Wi-Fi. Инженерные системы: газ - есть, вода - есть, электричество - 220 В. Документация: ПЗ, ЭОМ, ГС, КР, ОВиК. Стоимость проекта: 14111103, статус: В работе.', '{"floors": 17, "amenities": ["спа-центр", "велопарковка", "конференц-залы", "бесплатный Wi-Fi"], "documents": ["ПЗ", "ЭОМ", "ГС", "КР", "ОВиК"], "engineering": {"gas": true, "water": true, "electricity": 220}, "building_class": "А", "total_area_sqm": 146169}', '''14111103'':51B ''146169'':15B,79C ''17'':10B,55C ''220'':41B,77C ''electr'':76C ''fi'':33B,66C ''gas'':72C ''true'':73C,75C ''water'':74C ''wi'':32B,65C ''wi-fi'':31B,64C ''бесплатн'':30B,63C ''велопарковк'':26B,59C ''вод'':38B ''газ'':36B ''гс'':46B,69C ''документац'':43B ''зал'':29B,62C ''здан'':6B ''инженерн'':34B ''кв'':16B ''класс'':7B ''конференц'':28B,61C ''конференц-зал'':27B,60C ''кр'':47B,70C ''м'':17B ''общ'':13B ''овик'':48B,71C ''пз'':44B,67C ''площад'':14B ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,50B ''работ'':54B ''систем'':35B ''след'':21B ''соб'':5B ''спа'':24B,57C ''спа-центр'':23B,56C ''статус'':52B ''стоимост'':49B ''удобств'':22B ''фьюжнсит'':1A,3B ''центр'':25B,58C ''э'':45B,68C ''электричеств'':40B ''этаж'':11B');
INSERT INTO stroy.project VALUES (31, 'Небесный Проект', 211, 72, '{71}', 17814804, '2023-03-15', 'В работе', 'Проект "Небесный Проект" представляет собой здание класса А+ с 9 этажами и общей площадью 151323 кв.м. В проекте предусмотрены следующие удобства: выставочный зал, Фуд-корт, продуктовый супермаркет, круглосуточная охрана, конференц-залы, банкоматы, подземный паркинг, бесплатный Wi-Fi, зона ожидания с мягкой мебелью. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: АПС, СОУЭ, СС, ТХ. Стоимость проекта: 17814804, статус: В работе.', '{"floors": 9, "amenities": ["выставочный зал", "Фуд-корт", "продуктовый супермаркет", "круглосуточная охрана", "конференц-залы", "банкоматы", "подземный паркинг", "бесплатный Wi-Fi", "зона ожидания с мягкой мебелью"], "documents": ["АПС", "СОУЭ", "СС", "ТХ"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "А+", "total_area_sqm": 151323}', '''151323'':17B,105C ''17814804'':65B ''220'':56B,103C ''9'':12B,69C ''electr'':102C ''fals'':99C ''fi'':43B,88C ''gas'':98C ''true'':101C ''water'':100C ''wi'':42B,87C ''wi-fi'':41B,86C ''апс'':59B,94C ''банкомат'':37B,82C ''бесплатн'':40B,85C ''вод'':53B ''выставочн'':25B,70C ''газ'':51B ''документац'':58B ''зал'':26B,36B,71C,81C ''здан'':8B ''зон'':44B,89C ''инженерн'':49B ''кв'':18B ''класс'':9B ''конференц'':35B,80C ''конференц-зал'':34B,79C ''корт'':29B,74C ''круглосуточн'':32B,77C ''м'':19B ''мебел'':48B,93C ''мягк'':47B,92C ''небесн'':1A,4B ''общ'':15B ''ожидан'':45B,90C ''отсутств'':52B ''охра'':33B,78C ''паркинг'':39B,84C ''площад'':16B ''подземн'':38B,83C ''представля'':6B ''предусмотр'':22B ''продуктов'':30B,75C ''проект'':2A,3B,5B,21B,64B ''работ'':68B ''систем'':50B ''след'':23B ''соб'':7B ''соуэ'':60B,95C ''сс'':61B,96C ''статус'':66B ''стоимост'':63B ''супермаркет'':31B,76C ''тх'':62B,97C ''удобств'':24B ''фуд'':28B,73C ''фуд-корт'':27B,72C ''электричеств'':55B ''этаж'':13B');
INSERT INTO stroy.project VALUES (56, 'Центральный Доминант', 84, 1, '{31,62,45}', 33864175, '2022-04-04', 'На подписании', 'Проект "Центральный Доминант" представляет собой здание класса Премиум с 22 этажами и общей площадью 155397 кв.м. В проекте предусмотрены следующие удобства: видеонаблюдение, велопарковка, рестораны и кафе, зарядные станции для электромобилей, спа-центр, переговорные комнаты, аптека. Инженерные системы: газ - есть, вода - есть, электричество - 380 В. Документация: АР, КР, ПЗ. Стоимость проекта: 33864175, статус: На подписании.', '{"floors": 22, "amenities": ["видеонаблюдение", "велопарковка", "рестораны и кафе", "зарядные станции для электромобилей", "спа-центр", "переговорные комнаты", "аптека"], "documents": ["АР", "КР", "ПЗ"], "engineering": {"gas": true, "water": true, "electricity": 380}, "building_class": "Премиум", "total_area_sqm": 155397}', '''155397'':17B,85C ''22'':12B,59C ''33864175'':55B ''380'':47B,83C ''electr'':82C ''gas'':78C ''true'':79C,81C ''water'':80C ''аптек'':39B,74C ''ар'':50B,75C ''велопарковк'':26B,61C ''видеонаблюден'':25B,60C ''вод'':44B ''газ'':42B ''документац'':49B ''доминант'':2A,5B ''зарядн'':30B,65C ''здан'':8B ''инженерн'':40B ''каф'':29B,64C ''кв'':18B ''класс'':9B ''комнат'':38B,73C ''кр'':51B,76C ''м'':19B ''общ'':15B ''переговорн'':37B,72C ''пз'':52B,77C ''площад'':16B ''подписан'':58B ''представля'':6B ''предусмотр'':22B ''премиум'':10B,84C ''проект'':3B,21B,54B ''рестора'':27B,62C ''систем'':41B ''след'':23B ''соб'':7B ''спа'':35B,70C ''спа-центр'':34B,69C ''станц'':31B,66C ''статус'':56B ''стоимост'':53B ''удобств'':24B ''центр'':36B,71C ''центральн'':1A,4B ''электричеств'':46B ''электромобил'':33B,68C ''этаж'':13B');
INSERT INTO stroy.project VALUES (32, 'Архитектоника', 136, 2, '{78,49,57,73}', 26456773, '2022-11-01', 'В работе', 'Проект "Архитектоника" представляет собой здание класса Комфорт с 21 этажами и общей площадью 199924 кв.м. В проекте предусмотрены следующие удобства: бизнес-центр, система климат-контроля, аптека. Инженерные системы: газ - есть, вода - есть, электричество - 380 В. Документация: АР, КР, СС, ЭОМ, ГС. Стоимость проекта: 26456773, статус: В работе.', '{"floors": 21, "amenities": ["бизнес-центр", "система климат-контроля", "аптека"], "documents": ["АР", "КР", "СС", "ЭОМ", "ГС"], "engineering": {"gas": true, "water": true, "electricity": 380}, "building_class": "Комфорт", "total_area_sqm": 199924}', '''199924'':15B,73C ''21'':10B,52C ''26456773'':48B ''380'':38B,71C ''electr'':70C ''gas'':66C ''true'':67C,69C ''water'':68C ''аптек'':30B,60C ''ар'':41B,61C ''архитектоник'':1A,3B ''бизнес'':24B,54C ''бизнес-центр'':23B,53C ''вод'':35B ''газ'':33B ''гс'':45B,65C ''документац'':40B ''здан'':6B ''инженерн'':31B ''кв'':16B ''класс'':7B ''климат'':28B,58C ''климат-контрол'':27B,57C ''комфорт'':8B,72C ''контрол'':29B,59C ''кр'':42B,62C ''м'':17B ''общ'':13B ''площад'':14B ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,47B ''работ'':51B ''систем'':26B,32B,56C ''след'':21B ''соб'':5B ''сс'':43B,63C ''статус'':49B ''стоимост'':46B ''удобств'':22B ''центр'':25B,55C ''э'':44B,64C ''электричеств'':37B ''этаж'':11B');
INSERT INTO stroy.project VALUES (33, 'Доминион', 106, 44, '{52,21,74,49,22,14,47}', 9172835, '2022-06-04', 'Завершен', 'Проект "Доминион" представляет собой здание класса А+ с 17 этажами и общей площадью 66995 кв.м. В проекте предусмотрены следующие удобства: паркинг для посетителей, детская комната, салоны красоты, прачечная, бесплатный Wi-Fi. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: ГС, КР, АПС. Стоимость проекта: 9172835, статус: Завершен.', '{"floors": 17, "amenities": ["паркинг для посетителей", "детская комната", "салоны красоты", "прачечная", "бесплатный Wi-Fi"], "documents": ["ГС", "КР", "АПС"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "А+", "total_area_sqm": 66995}', '''17'':10B,53C ''220'':42B,74C ''66995'':15B,76C ''9172835'':50B ''electr'':73C ''fals'':70C,72C ''fi'':34B,65C ''gas'':69C ''water'':71C ''wi'':33B,64C ''wi-fi'':32B,63C ''апс'':47B,68C ''бесплатн'':31B,62C ''вод'':39B ''газ'':37B ''гс'':45B,66C ''детск'':26B,57C ''документац'':44B ''доминион'':1A,3B ''заверш'':52B ''здан'':6B ''инженерн'':35B ''кв'':16B ''класс'':7B ''комнат'':27B,58C ''кр'':46B,67C ''красот'':29B,60C ''м'':17B ''общ'':13B ''отсутств'':38B,40B ''паркинг'':23B,54C ''площад'':14B ''посетител'':25B,56C ''прачечн'':30B,61C ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,49B ''салон'':28B,59C ''систем'':36B ''след'':21B ''соб'':5B ''статус'':51B ''стоимост'':48B ''удобств'':22B ''электричеств'':41B ''этаж'':11B');
INSERT INTO stroy.project VALUES (34, 'ЭкоГрад', 47, 44, '{14,32,47,34}', 7938268, '2023-01-23', 'Отменен', 'Проект "ЭкоГрад" представляет собой здание класса B с 10 этажами и общей площадью 191630 кв.м. В проекте предусмотрены следующие удобства: электроника и бытовая техника, Фуд-корт, зона ожидания с мягкой мебелью, видеонаблюдение, выставочный зал, подземный паркинг, прачечная, коворкинг, велопарковка. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: СОУЭ, АПС, ЭОМ, ОВиК. Стоимость проекта: 7938268, статус: Отменен.', '{"floors": 10, "amenities": ["электроника и бытовая техника", "Фуд-корт", "зона ожидания с мягкой мебелью", "видеонаблюдение", "выставочный зал", "подземный паркинг", "прачечная", "коворкинг", "велопарковка"], "documents": ["СОУЭ", "АПС", "ЭОМ", "ОВиК"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "B", "total_area_sqm": 191630}', '''10'':10B,62C ''191630'':15B,94C ''380'':50B,92C ''7938268'':59B ''b'':8B,93C ''electr'':91C ''fals'':88C,90C ''gas'':87C ''water'':89C ''апс'':54B,84C ''бытов'':25B,65C ''велопарковк'':42B,82C ''видеонаблюден'':35B,75C ''вод'':47B ''выставочн'':36B,76C ''газ'':45B ''документац'':52B ''зал'':37B,77C ''здан'':6B ''зон'':30B,70C ''инженерн'':43B ''кв'':16B ''класс'':7B ''коворкинг'':41B,81C ''корт'':29B,69C ''м'':17B ''мебел'':34B,74C ''мягк'':33B,73C ''общ'':13B ''овик'':56B,86C ''ожидан'':31B,71C ''отмен'':61B ''отсутств'':46B,48B ''паркинг'':39B,79C ''площад'':14B ''подземн'':38B,78C ''прачечн'':40B,80C ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,58B ''систем'':44B ''след'':21B ''соб'':5B ''соуэ'':53B,83C ''статус'':60B ''стоимост'':57B ''техник'':26B,66C ''удобств'':22B ''фуд'':28B,68C ''фуд-корт'':27B,67C ''э'':55B,85C ''экоград'':1A,3B ''электричеств'':49B ''электроник'':23B,63C ''этаж'':11B');
INSERT INTO stroy.project VALUES (35, 'Инновацентр', 36, 35, '{31,78,9,72,29,45,10}', 12876536, '2023-08-22', 'Отменен', 'Проект "Инновацентр" представляет собой здание класса Бизнес с 25 этажами и общей площадью 86361 кв.м. В проекте предусмотрены следующие удобства: зарядные станции для электромобилей, бизнес-центр, выставочный зал, игровая зона для детей, прачечная. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: ОВиК, ГС, АПС, ЭОМ, СОУЭ. Стоимость проекта: 12876536, статус: Отменен.', '{"floors": 25, "amenities": ["зарядные станции для электромобилей", "бизнес-центр", "выставочный зал", "игровая зона для детей", "прачечная"], "documents": ["ОВиК", "ГС", "АПС", "ЭОМ", "СОУЭ"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "Бизнес", "total_area_sqm": 86361}', '''12876536'':54B ''220'':44B,82C ''25'':10B,57C ''86361'':15B,84C ''electr'':81C ''fals'':80C ''gas'':77C ''true'':78C ''water'':79C ''апс'':49B,74C ''бизнес'':8B,28B,63C,83C ''бизнес-центр'':27B,62C ''вод'':41B ''выставочн'':30B,65C ''газ'':39B ''гс'':48B,73C ''дет'':35B,70C ''документац'':46B ''зал'':31B,66C ''зарядн'':23B,58C ''здан'':6B ''зон'':33B,68C ''игров'':32B,67C ''инженерн'':37B ''инновацентр'':1A,3B ''кв'':16B ''класс'':7B ''м'':17B ''общ'':13B ''овик'':47B,72C ''отмен'':56B ''отсутств'':42B ''площад'':14B ''прачечн'':36B,71C ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,53B ''систем'':38B ''след'':21B ''соб'':5B ''соуэ'':51B,76C ''станц'':24B,59C ''статус'':55B ''стоимост'':52B ''удобств'':22B ''центр'':29B,64C ''э'':50B,75C ''электричеств'':43B ''электромобил'':26B,61C ''этаж'':11B');
INSERT INTO stroy.project VALUES (36, 'КвадроДом', 250, 8, '{67,27,42,38,62,71,68,6,74,1,7,41}', 12876536, '2023-07-22', 'На подписании', 'Проект "КвадроДом" представляет собой здание класса C с 11 этажами и общей площадью 121099 кв.м. В проекте предусмотрены следующие удобства: кофейня, детская комната, бизнес-центр, продуктовый супермаркет, коворкинг, зона ожидания с мягкой мебелью. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: ПЗ, ОВиК, ТХ, ЭОМ. Стоимость проекта: 12876536, статус: На подписании.', '{"floors": 11, "amenities": ["кофейня", "детская комната", "бизнес-центр", "продуктовый супермаркет", "коворкинг", "зона ожидания с мягкой мебелью"], "documents": ["ПЗ", "ОВиК", "ТХ", "ЭОМ"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "C", "total_area_sqm": 121099}', '''11'':10B,57C ''121099'':15B,83C ''12876536'':53B ''380'':44B,81C ''c'':8B,82C ''electr'':80C ''fals'':79C ''gas'':76C ''true'':77C ''water'':78C ''бизнес'':27B,62C ''бизнес-центр'':26B,61C ''вод'':41B ''газ'':39B ''детск'':24B,59C ''документац'':46B ''здан'':6B ''зон'':32B,67C ''инженерн'':37B ''кв'':16B ''квадрод'':1A,3B ''класс'':7B ''коворкинг'':31B,66C ''комнат'':25B,60C ''кофейн'':23B,58C ''м'':17B ''мебел'':36B,71C ''мягк'':35B,70C ''общ'':13B ''овик'':48B,73C ''ожидан'':33B,68C ''отсутств'':42B ''пз'':47B,72C ''площад'':14B ''подписан'':56B ''представля'':4B ''предусмотр'':20B ''продуктов'':29B,64C ''проект'':2B,19B,52B ''систем'':38B ''след'':21B ''соб'':5B ''статус'':54B ''стоимост'':51B ''супермаркет'':30B,65C ''тх'':49B,74C ''удобств'':22B ''центр'':28B,63C ''э'':50B,75C ''электричеств'':43B ''этаж'':11B');
INSERT INTO stroy.project VALUES (37, 'ЛидерПолис', 64, 53, '{77,15,9,39,46,80}', 16580237, '2022-06-02', 'Завершен', 'Проект "ЛидерПолис" представляет собой здание класса C с 14 этажами и общей площадью 100563 кв.м. В проекте предусмотрены следующие удобства: аптека, зарядные станции для электромобилей, Фуд-корт, кофейня, химчистка. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: ГС, ОВиК, АР, АПС, СОУЭ. Стоимость проекта: 16580237, статус: Завершен.', '{"floors": 14, "amenities": ["аптека", "зарядные станции для электромобилей", "Фуд-корт", "кофейня", "химчистка"], "documents": ["ГС", "ОВиК", "АР", "АПС", "СОУЭ"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "C", "total_area_sqm": 100563}', '''100563'':15B,76C ''14'':10B,53C ''16580237'':50B ''220'':40B,74C ''c'':8B,75C ''electr'':73C ''fals'':70C,72C ''gas'':69C ''water'':71C ''апс'':46B,67C ''аптек'':23B,54C ''ар'':45B,66C ''вод'':37B ''газ'':35B ''гс'':43B,64C ''документац'':42B ''заверш'':52B ''зарядн'':24B,55C ''здан'':6B ''инженерн'':33B ''кв'':16B ''класс'':7B ''корт'':30B,61C ''кофейн'':31B,62C ''лидерполис'':1A,3B ''м'':17B ''общ'':13B ''овик'':44B,65C ''отсутств'':36B,38B ''площад'':14B ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,49B ''систем'':34B ''след'':21B ''соб'':5B ''соуэ'':47B,68C ''станц'':25B,56C ''статус'':51B ''стоимост'':48B ''удобств'':22B ''фуд'':29B,60C ''фуд-корт'':28B,59C ''химчистк'':32B,63C ''электричеств'':39B ''электромобил'':27B,58C ''этаж'':11B');
INSERT INTO stroy.project VALUES (38, 'НовацияСтрой', 239, 27, '{11,45,15,68}', 27691340, '2023-03-01', 'Завершен', 'Проект "НовацияСтрой" представляет собой здание класса B+ с 7 этажами и общей площадью 50764 кв.м. В проекте предусмотрены следующие удобства: паркинг для посетителей, подземный паркинг, рестораны и кафе, магазины одежды и обуви, электроника и бытовая техника. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: АР, КР, ОВиК, СОУЭ, ТХ. Стоимость проекта: 27691340, статус: Завершен.', '{"floors": 7, "amenities": ["паркинг для посетителей", "подземный паркинг", "рестораны и кафе", "магазины одежды и обуви", "электроника и бытовая техника"], "documents": ["АР", "КР", "ОВиК", "СОУЭ", "ТХ"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "B+", "total_area_sqm": 50764}', '''27691340'':56B ''380'':46B,86C ''50764'':15B,88C ''7'':10B,59C ''b'':8B,87C ''electr'':85C ''fals'':82C,84C ''gas'':81C ''water'':83C ''ар'':49B,76C ''бытов'':37B,74C ''вод'':43B ''газ'':41B ''документац'':48B ''заверш'':58B ''здан'':6B ''инженерн'':39B ''каф'':30B,67C ''кв'':16B ''класс'':7B ''кр'':50B,77C ''м'':17B ''магазин'':31B,68C ''новациястр'':1A,3B ''обув'':34B,71C ''общ'':13B ''овик'':51B,78C ''одежд'':32B,69C ''отсутств'':42B,44B ''паркинг'':23B,27B,60C,64C ''площад'':14B ''подземн'':26B,63C ''посетител'':25B,62C ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,55B ''рестора'':28B,65C ''систем'':40B ''след'':21B ''соб'':5B ''соуэ'':52B,79C ''статус'':57B ''стоимост'':54B ''техник'':38B,75C ''тх'':53B,80C ''удобств'':22B ''электричеств'':45B ''электроник'':35B,72C ''этаж'':11B');
INSERT INTO stroy.project VALUES (39, 'ВекторСтрой', 111, 33, '{21,7,72,15,48,29,60,59,23,76,63}', 10407402, '2023-12-19', 'Завершен', 'Проект "ВекторСтрой" представляет собой здание класса C с 16 этажами и общей площадью 129498 кв.м. В проекте предусмотрены следующие удобства: система климат-контроля, коворкинг, переговорные комнаты, выставочный зал, зона ожидания с мягкой мебелью, банкоматы. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: ТХ, СС, ПЗ, АР. Стоимость проекта: 10407402, статус: Завершен.', '{"floors": 16, "amenities": ["система климат-контроля", "коворкинг", "переговорные комнаты", "выставочный зал", "зона ожидания с мягкой мебелью", "банкоматы"], "documents": ["ТХ", "СС", "ПЗ", "АР"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "C", "total_area_sqm": 129498}', '''10407402'':54B ''129498'':15B,84C ''16'':10B,57C ''380'':45B,82C ''c'':8B,83C ''electr'':81C ''fals'':80C ''gas'':77C ''true'':78C ''water'':79C ''ар'':51B,76C ''банкомат'':37B,72C ''векторстр'':1A,3B ''вод'':42B ''выставочн'':30B,65C ''газ'':40B ''документац'':47B ''заверш'':56B ''зал'':31B,66C ''здан'':6B ''зон'':32B,67C ''инженерн'':38B ''кв'':16B ''класс'':7B ''климат'':25B,60C ''климат-контрол'':24B,59C ''коворкинг'':27B,62C ''комнат'':29B,64C ''контрол'':26B,61C ''м'':17B ''мебел'':36B,71C ''мягк'':35B,70C ''общ'':13B ''ожидан'':33B,68C ''отсутств'':43B ''переговорн'':28B,63C ''пз'':50B,75C ''площад'':14B ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,53B ''систем'':23B,39B,58C ''след'':21B ''соб'':5B ''сс'':49B,74C ''статус'':55B ''стоимост'':52B ''тх'':48B,73C ''удобств'':22B ''электричеств'':44B ''этаж'':11B');
INSERT INTO stroy.project VALUES (40, 'ГармонияГрад', 223, 58, '{39,34}', 28925907, '2022-06-06', 'Отменен', 'Проект "ГармонияГрад" представляет собой здание класса А с 10 этажами и общей площадью 77992 кв.м. В проекте предусмотрены следующие удобства: детская комната, система климат-контроля, бизнес-центр, круглосуточная охрана, отделение банка, электроника и бытовая техника. Инженерные системы: газ - отсутствует, вода - есть, электричество - 380 В. Документация: АПС, ОВиК, ПЗ, СОУЭ. Стоимость проекта: 28925907, статус: Отменен.', '{"floors": 10, "amenities": ["детская комната", "система климат-контроля", "бизнес-центр", "круглосуточная охрана", "отделение банка", "электроника и бытовая техника"], "documents": ["АПС", "ОВиК", "ПЗ", "СОУЭ"], "engineering": {"gas": false, "water": true, "electricity": 380}, "building_class": "А", "total_area_sqm": 77992}', '''10'':10B,59C ''28925907'':56B ''380'':47B,86C ''77992'':15B,88C ''electr'':85C ''fals'':82C ''gas'':81C ''true'':84C ''water'':83C ''апс'':50B,77C ''банк'':35B,72C ''бизнес'':30B,67C ''бизнес-центр'':29B,66C ''бытов'':38B,75C ''вод'':44B ''газ'':42B ''гармонияград'':1A,3B ''детск'':23B,60C ''документац'':49B ''здан'':6B ''инженерн'':40B ''кв'':16B ''класс'':7B ''климат'':27B,64C ''климат-контрол'':26B,63C ''комнат'':24B,61C ''контрол'':28B,65C ''круглосуточн'':32B,69C ''м'':17B ''общ'':13B ''овик'':51B,78C ''отделен'':34B,71C ''отмен'':58B ''отсутств'':43B ''охра'':33B,70C ''пз'':52B,79C ''площад'':14B ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,55B ''систем'':25B,41B,62C ''след'':21B ''соб'':5B ''соуэ'':53B,80C ''статус'':57B ''стоимост'':54B ''техник'':39B,76C ''удобств'':22B ''центр'':31B,68C ''электричеств'':46B ''электроник'':36B,73C ''этаж'':11B');
INSERT INTO stroy.project VALUES (41, 'ДиалогДом', 197, 12, '{69,23}', 5469134, '2022-10-07', 'На подписании', 'Проект "ДиалогДом" представляет собой здание класса Премиум с 18 этажами и общей площадью 78524 кв.м. В проекте предусмотрены следующие удобства: Фуд-корт, бизнес-центр, круглосуточная охрана, конференц-залы, пропускная система, кофейня, салоны красоты. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: КР, АПС, ГС, АР, ПЗ, ТХ, СОУЭ. Стоимость проекта: 5469134, статус: На подписании.', '{"floors": 18, "amenities": ["Фуд-корт", "бизнес-центр", "круглосуточная охрана", "конференц-залы", "пропускная система", "кофейня", "салоны красоты"], "documents": ["КР", "АПС", "ГС", "АР", "ПЗ", "ТХ", "СОУЭ"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "Премиум", "total_area_sqm": 78524}', '''18'':10B,62C ''220'':46B,91C ''5469134'':58B ''78524'':15B,93C ''electr'':90C ''fals'':89C ''gas'':86C ''true'':87C ''water'':88C ''апс'':50B,80C ''ар'':52B,82C ''бизнес'':27B,67C ''бизнес-центр'':26B,66C ''вод'':43B ''газ'':41B ''гс'':51B,81C ''диалогд'':1A,3B ''документац'':48B ''зал'':33B,73C ''здан'':6B ''инженерн'':39B ''кв'':16B ''класс'':7B ''конференц'':32B,72C ''конференц-зал'':31B,71C ''корт'':25B,65C ''кофейн'':36B,76C ''кр'':49B,79C ''красот'':38B,78C ''круглосуточн'':29B,69C ''м'':17B ''общ'':13B ''отсутств'':44B ''охра'':30B,70C ''пз'':53B,83C ''площад'':14B ''подписан'':61B ''представля'':4B ''предусмотр'':20B ''премиум'':8B,92C ''проект'':2B,19B,57B ''пропускн'':34B,74C ''салон'':37B,77C ''систем'':35B,40B,75C ''след'':21B ''соб'':5B ''соуэ'':55B,85C ''статус'':59B ''стоимост'':56B ''тх'':54B,84C ''удобств'':22B ''фуд'':24B,64C ''фуд-корт'':23B,63C ''центр'':28B,68C ''электричеств'':45B ''этаж'':11B');
INSERT INTO stroy.project VALUES (42, 'Жемчужина Реки', 186, 35, '{40,31,54,35,5,38,80,18,79,57,28,49}', 21518505, '2023-11-19', 'Завершен', 'Проект "Жемчужина Реки" представляет собой здание класса D с 24 этажами и общей площадью 82123 кв.м. В проекте предусмотрены следующие удобства: коворкинг, салоны красоты, система климат-контроля, переговорные комнаты, спа-центр, электроника и бытовая техника, паркинг для посетителей, игровая зона для детей, банкоматы. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: ТХ, ЭОМ, ОВиК, АПС, КР, СОУЭ. Стоимость проекта: 21518505, статус: Завершен.', '{"floors": 24, "amenities": ["коворкинг", "салоны красоты", "система климат-контроля", "переговорные комнаты", "спа-центр", "электроника и бытовая техника", "паркинг для посетителей", "игровая зона для детей", "банкоматы"], "documents": ["ТХ", "ЭОМ", "ОВиК", "АПС", "КР", "СОУЭ"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "D", "total_area_sqm": 82123}', '''21518505'':67B ''24'':12B,70C ''380'':56B,106C ''82123'':17B,108C ''d'':10B,107C ''electr'':105C ''fals'':102C,104C ''gas'':101C ''water'':103C ''апс'':62B,98C ''банкомат'':48B,94C ''бытов'':39B,85C ''вод'':53B ''газ'':51B ''дет'':47B,93C ''документац'':58B ''жемчужин'':1A,4B ''заверш'':69B ''здан'':8B ''зон'':45B,91C ''игров'':44B,90C ''инженерн'':49B ''кв'':18B ''класс'':9B ''климат'':30B,76C ''климат-контрол'':29B,75C ''коворкинг'':25B,71C ''комнат'':33B,79C ''контрол'':31B,77C ''кр'':63B,99C ''красот'':27B,73C ''м'':19B ''общ'':15B ''овик'':61B,97C ''отсутств'':52B,54B ''паркинг'':41B,87C ''переговорн'':32B,78C ''площад'':16B ''посетител'':43B,89C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,66B ''рек'':2A,5B ''салон'':26B,72C ''систем'':28B,50B,74C ''след'':23B ''соб'':7B ''соуэ'':64B,100C ''спа'':35B,81C ''спа-центр'':34B,80C ''статус'':68B ''стоимост'':65B ''техник'':40B,86C ''тх'':59B,95C ''удобств'':24B ''центр'':36B,82C ''э'':60B,96C ''электричеств'':55B ''электроник'':37B,83C ''этаж'':13B');
INSERT INTO stroy.project VALUES (43, 'Золотой Квартал', 142, 73, '{12}', 5469134, '2023-08-06', 'Завершен', 'Проект "Золотой Квартал" представляет собой здание класса Премиум с 21 этажами и общей площадью 29897 кв.м. В проекте предусмотрены следующие удобства: велопарковка, система климат-контроля, круглосуточная охрана, игровая зона для детей, видеонаблюдение. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: ГС, АПС, АР, ОВиК, СС, ТХ. Стоимость проекта: 5469134, статус: Завершен.', '{"floors": 21, "amenities": ["велопарковка", "система климат-контроля", "круглосуточная охрана", "игровая зона для детей", "видеонаблюдение"], "documents": ["ГС", "АПС", "АР", "ОВиК", "СС", "ТХ"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "Премиум", "total_area_sqm": 29897}', '''21'':12B,58C ''220'':44B,82C ''29897'':17B,84C ''5469134'':55B ''electr'':81C ''fals'':78C ''gas'':77C ''true'':80C ''water'':79C ''апс'':48B,72C ''ар'':49B,73C ''велопарковк'':25B,59C ''видеонаблюден'':36B,70C ''вод'':41B ''газ'':39B ''гс'':47B,71C ''дет'':35B,69C ''документац'':46B ''заверш'':57B ''здан'':8B ''золот'':1A,4B ''зон'':33B,67C ''игров'':32B,66C ''инженерн'':37B ''кв'':18B ''кварта'':2A,5B ''класс'':9B ''климат'':28B,62C ''климат-контрол'':27B,61C ''контрол'':29B,63C ''круглосуточн'':30B,64C ''м'':19B ''общ'':15B ''овик'':50B,74C ''отсутств'':40B ''охра'':31B,65C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''премиум'':10B,83C ''проект'':3B,21B,54B ''систем'':26B,38B,60C ''след'':23B ''соб'':7B ''сс'':51B,75C ''статус'':56B ''стоимост'':53B ''тх'':52B,76C ''удобств'':24B ''электричеств'':43B ''этаж'':13B');
INSERT INTO stroy.project VALUES (44, 'Империя Высот', 95, 27, '{57,59,70}', 17814804, '2023-05-11', 'Завершен', 'Проект "Империя Высот" представляет собой здание класса D с 13 этажами и общей площадью 165392 кв.м. В проекте предусмотрены следующие удобства: электроника и бытовая техника, отделение банка, выставочный зал, коворкинг, переговорные комнаты, зарядные станции для электромобилей, велопарковка. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: ЭОМ, ГС, СС, КР, ОВиК, ПЗ, АР. Стоимость проекта: 17814804, статус: Завершен.', '{"floors": 13, "amenities": ["электроника и бытовая техника", "отделение банка", "выставочный зал", "коворкинг", "переговорные комнаты", "зарядные станции для электромобилей", "велопарковка"], "documents": ["ЭОМ", "ГС", "СС", "КР", "ОВиК", "ПЗ", "АР"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "D", "total_area_sqm": 165392}', '''13'':12B,63C ''165392'':17B,94C ''17814804'':60B ''380'':48B,92C ''d'':10B,93C ''electr'':91C ''fals'':88C,90C ''gas'':87C ''water'':89C ''ар'':57B,86C ''банк'':30B,69C ''бытов'':27B,66C ''велопарковк'':40B,79C ''вод'':45B ''высот'':2A,5B ''выставочн'':31B,70C ''газ'':43B ''гс'':52B,81C ''документац'':50B ''заверш'':62B ''зал'':32B,71C ''зарядн'':36B,75C ''здан'':8B ''импер'':1A,4B ''инженерн'':41B ''кв'':18B ''класс'':9B ''коворкинг'':33B,72C ''комнат'':35B,74C ''кр'':54B,83C ''м'':19B ''общ'':15B ''овик'':55B,84C ''отделен'':29B,68C ''отсутств'':44B,46B ''переговорн'':34B,73C ''пз'':56B,85C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,59B ''систем'':42B ''след'':23B ''соб'':7B ''сс'':53B,82C ''станц'':37B,76C ''статус'':61B ''стоимост'':58B ''техник'':28B,67C ''удобств'':24B ''э'':51B,80C ''электричеств'':47B ''электромобил'':39B,78C ''электроник'':25B,64C ''этаж'':13B');
INSERT INTO stroy.project VALUES (45, 'Каскадный Парк', 224, 2, '{46}', 5469134, '2023-02-19', 'Отменен', 'Проект "Каскадный Парк" представляет собой здание класса Эконом с 18 этажами и общей площадью 177219 кв.м. В проекте предусмотрены следующие удобства: велопарковка, салоны красоты, банкоматы, паркинг для посетителей, продуктовый супермаркет, коворкинг, видеонаблюдение, электроника и бытовая техника. Инженерные системы: газ - отсутствует, вода - есть, электричество - 380 В. Документация: ОВиК, АПС, СОУЭ, ПЗ, КР, АР, ЭОМ, СС, ТХ. Стоимость проекта: 5469134, статус: Отменен.', '{"floors": 18, "amenities": ["велопарковка", "салоны красоты", "банкоматы", "паркинг для посетителей", "продуктовый супермаркет", "коворкинг", "видеонаблюдение", "электроника и бытовая техника"], "documents": ["ОВиК", "АПС", "СОУЭ", "ПЗ", "КР", "АР", "ЭОМ", "СС", "ТХ"], "engineering": {"gas": false, "water": true, "electricity": 380}, "building_class": "Эконом", "total_area_sqm": 177219}', '''177219'':17B,96C ''18'':12B,64C ''380'':47B,94C ''5469134'':61B ''electr'':93C ''fals'':90C ''gas'':89C ''true'':92C ''water'':91C ''апс'':51B,81C ''ар'':55B,85C ''банкомат'':28B,68C ''бытов'':38B,78C ''велопарковк'':25B,65C ''видеонаблюден'':35B,75C ''вод'':44B ''газ'':42B ''документац'':49B ''здан'':8B ''инженерн'':40B ''каскадн'':1A,4B ''кв'':18B ''класс'':9B ''коворкинг'':34B,74C ''кр'':54B,84C ''красот'':27B,67C ''м'':19B ''общ'':15B ''овик'':50B,80C ''отмен'':63B ''отсутств'':43B ''парк'':2A,5B ''паркинг'':29B,69C ''пз'':53B,83C ''площад'':16B ''посетител'':31B,71C ''представля'':6B ''предусмотр'':22B ''продуктов'':32B,72C ''проект'':3B,21B,60B ''салон'':26B,66C ''систем'':41B ''след'':23B ''соб'':7B ''соуэ'':52B,82C ''сс'':57B,87C ''статус'':62B ''стоимост'':59B ''супермаркет'':33B,73C ''техник'':39B,79C ''тх'':58B,88C ''удобств'':24B ''э'':56B,86C ''экон'':10B,95C ''электричеств'':46B ''электроник'':36B,76C ''этаж'':13B');
INSERT INTO stroy.project VALUES (46, 'Лазурный Берег', 58, 12, '{63,69,73,15,79,66}', 9172835, '2022-08-04', 'Завершен', 'Проект "Лазурный Берег" представляет собой здание класса Комфорт с 22 этажами и общей площадью 67064 кв.м. В проекте предусмотрены следующие удобства: отделение банка, игровая зона для детей, паркинг для посетителей, круглосуточная охрана, банкоматы, переговорные комнаты, подземный паркинг, видеонаблюдение, зарядные станции для электромобилей. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: КР, АПС, СОУЭ, СС. Стоимость проекта: 9172835, статус: Завершен.', '{"floors": 22, "amenities": ["отделение банка", "игровая зона для детей", "паркинг для посетителей", "круглосуточная охрана", "банкоматы", "переговорные комнаты", "подземный паркинг", "видеонаблюдение", "зарядные станции для электромобилей"], "documents": ["КР", "АПС", "СОУЭ", "СС"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "Комфорт", "total_area_sqm": 67064}', '''22'':12B,65C ''220'':53B,96C ''67064'':17B,98C ''9172835'':62B ''electr'':95C ''fals'':92C ''gas'':91C ''true'':94C ''water'':93C ''апс'':57B,88C ''банк'':26B,67C ''банкомат'':36B,77C ''берег'':2A,5B ''видеонаблюден'':41B,82C ''вод'':50B ''газ'':48B ''дет'':30B,71C ''документац'':55B ''заверш'':64B ''зарядн'':42B,83C ''здан'':8B ''зон'':28B,69C ''игров'':27B,68C ''инженерн'':46B ''кв'':18B ''класс'':9B ''комнат'':38B,79C ''комфорт'':10B,97C ''кр'':56B,87C ''круглосуточн'':34B,75C ''лазурн'':1A,4B ''м'':19B ''общ'':15B ''отделен'':25B,66C ''отсутств'':49B ''охра'':35B,76C ''паркинг'':31B,40B,72C,81C ''переговорн'':37B,78C ''площад'':16B ''подземн'':39B,80C ''посетител'':33B,74C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,61B ''систем'':47B ''след'':23B ''соб'':7B ''соуэ'':58B,89C ''сс'':59B,90C ''станц'':43B,84C ''статус'':63B ''стоимост'':60B ''удобств'':24B ''электричеств'':52B ''электромобил'':45B,86C ''этаж'':13B');
INSERT INTO stroy.project VALUES (28, 'ТитанСтрой', 226, 79, '{4,33,43,32,2,74,27,36,44,20,39,22}', 14111103, '2023-04-12', 'Завершен', 'Проект "ТитанСтрой" представляет собой здание класса А с 22 этажами и общей площадью 67716 кв.м. В проекте предусмотрены следующие удобства: химчистка, детская комната, аптека, бизнес-центр, коворкинг, электроника и бытовая техника, прачечная, подземный паркинг, бесплатный Wi-Fi. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: СОУЭ, ПЗ, ГС, СС, АПС. Стоимость проекта: 14111103, статус: Завершен.', '{"floors": 22, "amenities": ["химчистка", "детская комната", "аптека", "бизнес-центр", "коворкинг", "электроника и бытовая техника", "прачечная", "подземный паркинг", "бесплатный Wi-Fi"], "documents": ["СОУЭ", "ПЗ", "ГС", "СС", "АПС"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "А", "total_area_sqm": 67716}', '''14111103'':59B ''22'':10B,62C ''220'':49B,92C ''67716'':15B,94C ''electr'':91C ''fals'':88C ''fi'':41B,81C ''gas'':87C ''true'':90C ''water'':89C ''wi'':40B,80C ''wi-fi'':39B,79C ''апс'':56B,86C ''аптек'':26B,66C ''бесплатн'':38B,78C ''бизнес'':28B,68C ''бизнес-центр'':27B,67C ''бытов'':33B,73C ''вод'':46B ''газ'':44B ''гс'':54B,84C ''детск'':24B,64C ''документац'':51B ''заверш'':61B ''здан'':6B ''инженерн'':42B ''кв'':16B ''класс'':7B ''коворкинг'':30B,70C ''комнат'':25B,65C ''м'':17B ''общ'':13B ''отсутств'':45B ''паркинг'':37B,77C ''пз'':53B,83C ''площад'':14B ''подземн'':36B,76C ''прачечн'':35B,75C ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,58B ''систем'':43B ''след'':21B ''соб'':5B ''соуэ'':52B,82C ''сс'':55B,85C ''статус'':60B ''стоимост'':57B ''техник'':34B,74C ''титанстр'':1A,3B ''удобств'':22B ''химчистк'':23B,63C ''центр'':29B,69C ''электричеств'':48B ''электроник'':31B,71C ''этаж'':11B');
INSERT INTO stroy.project VALUES (47, 'Магистральный Венец', 249, 75, '{31,6,55,25,53,50,68,12,29,28}', 5469134, '2022-12-11', 'Завершен', 'Проект "Магистральный Венец" представляет собой здание класса А+ с 10 этажами и общей площадью 198499 кв.м. В проекте предусмотрены следующие удобства: салоны красоты, отделение банка, продуктовый супермаркет. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: АПС, ТХ, ЭОМ, СОУЭ, СС, ПЗ, КР, ОВиК. Стоимость проекта: 5469134, статус: Завершен.', '{"floors": 10, "amenities": ["салоны красоты", "отделение банка", "продуктовый супермаркет"], "documents": ["АПС", "ТХ", "ЭОМ", "СОУЭ", "СС", "ПЗ", "КР", "ОВиК"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "А+", "total_area_sqm": 198499}', '''10'':12B,54C ''198499'':17B,76C ''220'':38B,74C ''5469134'':51B ''electr'':73C ''fals'':70C ''gas'':69C ''true'':72C ''water'':71C ''апс'':41B,61C ''банк'':28B,58C ''венец'':2A,5B ''вод'':35B ''газ'':33B ''документац'':40B ''заверш'':53B ''здан'':8B ''инженерн'':31B ''кв'':18B ''класс'':9B ''кр'':47B,67C ''красот'':26B,56C ''м'':19B ''магистральн'':1A,4B ''общ'':15B ''овик'':48B,68C ''отделен'':27B,57C ''отсутств'':34B ''пз'':46B,66C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''продуктов'':29B,59C ''проект'':3B,21B,50B ''салон'':25B,55C ''систем'':32B ''след'':23B ''соб'':7B ''соуэ'':44B,64C ''сс'':45B,65C ''статус'':52B ''стоимост'':49B ''супермаркет'':30B,60C ''тх'':42B,62C ''удобств'':24B ''э'':43B,63C ''электричеств'':37B ''этаж'':13B');
INSERT INTO stroy.project VALUES (48, 'Новаторские Вершины', 245, 1, '{74,66,32,78,34,1}', 33864175, '2023-06-06', 'Отменен', 'Проект "Новаторские Вершины" представляет собой здание класса B с 13 этажами и общей площадью 167300 кв.м. В проекте предусмотрены следующие удобства: прачечная, аптека, бизнес-центр, банкоматы, коворкинг. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: СОУЭ, АПС, ОВиК, КР. Стоимость проекта: 33864175, статус: Отменен.', '{"floors": 13, "amenities": ["прачечная", "аптека", "бизнес-центр", "банкоматы", "коворкинг"], "documents": ["СОУЭ", "АПС", "ОВиК", "КР"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "B", "total_area_sqm": 167300}', '''13'':12B,51C ''167300'':17B,70C ''220'':39B,68C ''33864175'':48B ''b'':10B,69C ''electr'':67C ''fals'':64C,66C ''gas'':63C ''water'':65C ''апс'':43B,60C ''аптек'':26B,53C ''банкомат'':30B,57C ''бизнес'':28B,55C ''бизнес-центр'':27B,54C ''вершин'':2A,5B ''вод'':36B ''газ'':34B ''документац'':41B ''здан'':8B ''инженерн'':32B ''кв'':18B ''класс'':9B ''коворкинг'':31B,58C ''кр'':45B,62C ''м'':19B ''новаторск'':1A,4B ''общ'':15B ''овик'':44B,61C ''отмен'':50B ''отсутств'':35B,37B ''площад'':16B ''прачечн'':25B,52C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,47B ''систем'':33B ''след'':23B ''соб'':7B ''соуэ'':42B,59C ''статус'':49B ''стоимост'':46B ''удобств'':24B ''центр'':29B,56C ''электричеств'':38B ''этаж'':13B');
INSERT INTO stroy.project VALUES (49, 'Город Мастеров', 21, 16, '{25,66}', 36333309, '2022-11-20', 'В работе', 'Проект "Город Мастеров" представляет собой здание класса Эконом с 24 этажами и общей площадью 193554 кв.м. В проекте предусмотрены следующие удобства: химчистка, рестораны и кафе, магазины одежды и обуви, продуктовый супермаркет. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: КР, ОВиК, ПЗ, ТХ, СС, ГС. Стоимость проекта: 36333309, статус: В работе.', '{"floors": 24, "amenities": ["химчистка", "рестораны и кафе", "магазины одежды и обуви", "продуктовый супермаркет"], "documents": ["КР", "ОВиК", "ПЗ", "ТХ", "СС", "ГС"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "Эконом", "total_area_sqm": 193554}', '''193554'':17B,81C ''220'':42B,79C ''24'':12B,57C ''36333309'':53B ''electr'':78C ''fals'':77C ''gas'':74C ''true'':75C ''water'':76C ''вод'':39B ''газ'':37B ''город'':1A,4B ''гс'':50B,73C ''документац'':44B ''здан'':8B ''инженерн'':35B ''каф'':28B,61C ''кв'':18B ''класс'':9B ''кр'':45B,68C ''м'':19B ''магазин'':29B,62C ''мастер'':2A,5B ''обув'':32B,65C ''общ'':15B ''овик'':46B,69C ''одежд'':30B,63C ''отсутств'':40B ''пз'':47B,70C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''продуктов'':33B,66C ''проект'':3B,21B,52B ''работ'':56B ''рестора'':26B,59C ''систем'':36B ''след'':23B ''соб'':7B ''сс'':49B,72C ''статус'':54B ''стоимост'':51B ''супермаркет'':34B,67C ''тх'':48B,71C ''удобств'':24B ''химчистк'':25B,58C ''экон'':10B,80C ''электричеств'':41B ''этаж'':13B');
INSERT INTO stroy.project VALUES (50, 'ПрестижПолис', 23, 44, '{15,41,73,3,7,40,33,62,14}', 19049371, '2023-06-02', 'Завершен', 'Проект "ПрестижПолис" представляет собой здание класса B+ с 16 этажами и общей площадью 187632 кв.м. В проекте предусмотрены следующие удобства: система климат-контроля, банкоматы, детская комната, круглосуточная охрана, зарядные станции для электромобилей, зона ожидания с мягкой мебелью, салоны красоты. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: ОВиК, АПС, СС, ТХ, ПЗ. Стоимость проекта: 19049371, статус: Завершен.', '{"floors": 16, "amenities": ["система климат-контроля", "банкоматы", "детская комната", "круглосуточная охрана", "зарядные станции для электромобилей", "зона ожидания с мягкой мебелью", "салоны красоты"], "documents": ["ОВиК", "АПС", "СС", "ТХ", "ПЗ"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "B+", "total_area_sqm": 187632}', '''16'':10B,63C ''187632'':15B,96C ''19049371'':60B ''220'':50B,94C ''b'':8B,95C ''electr'':93C ''fals'':90C ''gas'':89C ''true'':92C ''water'':91C ''апс'':54B,85C ''банкомат'':27B,68C ''вод'':47B ''газ'':45B ''детск'':28B,69C ''документац'':52B ''заверш'':62B ''зарядн'':32B,73C ''здан'':6B ''зон'':36B,77C ''инженерн'':43B ''кв'':16B ''класс'':7B ''климат'':25B,66C ''климат-контрол'':24B,65C ''комнат'':29B,70C ''контрол'':26B,67C ''красот'':42B,83C ''круглосуточн'':30B,71C ''м'':17B ''мебел'':40B,81C ''мягк'':39B,80C ''общ'':13B ''овик'':53B,84C ''ожидан'':37B,78C ''отсутств'':46B ''охра'':31B,72C ''пз'':57B,88C ''площад'':14B ''представля'':4B ''предусмотр'':20B ''престижполис'':1A,3B ''проект'':2B,19B,59B ''салон'':41B,82C ''систем'':23B,44B,64C ''след'':21B ''соб'':5B ''сс'':55B,86C ''станц'':33B,74C ''статус'':61B ''стоимост'':58B ''тх'':56B,87C ''удобств'':22B ''электричеств'':49B ''электромобил'':35B,76C ''этаж'':11B');
INSERT INTO stroy.project VALUES (77, 'Шик Шардс', 132, 12, '{73,56,36}', 26456773, '2022-11-15', 'В работе', 'Проект "Шик Шардс" представляет собой здание класса Эконом с 6 этажами и общей площадью 95827 кв.м. В проекте предусмотрены следующие удобства: салоны красоты, электроника и бытовая техника, продуктовый супермаркет. Инженерные системы: газ - отсутствует, вода - есть, электричество - 380 В. Документация: КР, ОВиК, ТХ, АР, ПЗ, АПС, СОУЭ, СС, ГС. Стоимость проекта: 26456773, статус: В работе.', '{"floors": 6, "amenities": ["салоны красоты", "электроника и бытовая техника", "продуктовый супермаркет"], "documents": ["КР", "ОВиК", "ТХ", "АР", "ПЗ", "АПС", "СОУЭ", "СС", "ГС"], "engineering": {"gas": false, "water": true, "electricity": 380}, "building_class": "Эконом", "total_area_sqm": 95827}', '''26456773'':54B ''380'':40B,81C ''6'':12B,58C ''95827'':17B,83C ''electr'':80C ''fals'':77C ''gas'':76C ''true'':79C ''water'':78C ''апс'':48B,72C ''ар'':46B,70C ''бытов'':29B,63C ''вод'':37B ''газ'':35B ''гс'':51B,75C ''документац'':42B ''здан'':8B ''инженерн'':33B ''кв'':18B ''класс'':9B ''кр'':43B,67C ''красот'':26B,60C ''м'':19B ''общ'':15B ''овик'':44B,68C ''отсутств'':36B ''пз'':47B,71C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''продуктов'':31B,65C ''проект'':3B,21B,53B ''работ'':57B ''салон'':25B,59C ''систем'':34B ''след'':23B ''соб'':7B ''соуэ'':49B,73C ''сс'':50B,74C ''статус'':55B ''стоимост'':52B ''супермаркет'':32B,66C ''техник'':30B,64C ''тх'':45B,69C ''удобств'':24B ''шардс'':2A,5B ''шик'':1A,4B ''экон'':10B,82C ''электричеств'':39B ''электроник'':27B,61C ''этаж'':13B');
INSERT INTO stroy.project VALUES (51, 'Рубиновый Остров', 97, 36, '{67,71,13,20,56}', 11641969, '2022-09-22', 'На подписании', 'Проект "Рубиновый Остров" представляет собой здание класса D с 7 этажами и общей площадью 106588 кв.м. В проекте предусмотрены следующие удобства: переговорные комнаты, прачечная, кофейня, химчистка, электроника и бытовая техника, салоны красоты, круглосуточная охрана, отделение банка. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: АПС, ЭОМ, СОУЭ, АР, ТХ, ПЗ, ГС. Стоимость проекта: 11641969, статус: На подписании.', '{"floors": 7, "amenities": ["переговорные комнаты", "прачечная", "кофейня", "химчистка", "электроника и бытовая техника", "салоны красоты", "круглосуточная охрана", "отделение банка"], "documents": ["АПС", "ЭОМ", "СОУЭ", "АР", "ТХ", "ПЗ", "ГС"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "D", "total_area_sqm": 106588}', '''106588'':17B,93C ''11641969'':59B ''380'':47B,91C ''7'':12B,63C ''d'':10B,92C ''electr'':90C ''fals'':87C,89C ''gas'':86C ''water'':88C ''апс'':50B,79C ''ар'':53B,82C ''банк'':39B,78C ''бытов'':32B,71C ''вод'':44B ''газ'':42B ''гс'':56B,85C ''документац'':49B ''здан'':8B ''инженерн'':40B ''кв'':18B ''класс'':9B ''комнат'':26B,65C ''кофейн'':28B,67C ''красот'':35B,74C ''круглосуточн'':36B,75C ''м'':19B ''общ'':15B ''остр'':2A,5B ''отделен'':38B,77C ''отсутств'':43B,45B ''охра'':37B,76C ''переговорн'':25B,64C ''пз'':55B,84C ''площад'':16B ''подписан'':62B ''прачечн'':27B,66C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,58B ''рубинов'':1A,4B ''салон'':34B,73C ''систем'':41B ''след'':23B ''соб'':7B ''соуэ'':52B,81C ''статус'':60B ''стоимост'':57B ''техник'':33B,72C ''тх'':54B,83C ''удобств'':24B ''химчистк'':29B,68C ''э'':51B,80C ''электричеств'':46B ''электроник'':30B,69C ''этаж'':13B');
INSERT INTO stroy.project VALUES (52, 'Сапфировая Гавань', 164, 8, '{32,20,41,62,72,57}', 37567876, '2023-05-25', 'Завершен', 'Проект "Сапфировая Гавань" представляет собой здание класса А+ с 14 этажами и общей площадью 51195 кв.м. В проекте предусмотрены следующие удобства: аптека, спа-центр, магазины одежды и обуви, система климат-контроля, видеонаблюдение, круглосуточная охрана, пропускная система. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: СС, ТХ, ПЗ, СОУЭ. Стоимость проекта: 37567876, статус: Завершен.', '{"floors": 14, "amenities": ["аптека", "спа-центр", "магазины одежды и обуви", "система климат-контроля", "видеонаблюдение", "круглосуточная охрана", "пропускная система"], "documents": ["СС", "ТХ", "ПЗ", "СОУЭ"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "А+", "total_area_sqm": 51195}', '''14'':12B,61C ''220'':49B,88C ''37567876'':58B ''51195'':17B,90C ''electr'':87C ''fals'':84C,86C ''gas'':83C ''water'':85C ''аптек'':25B,62C ''видеонаблюден'':37B,74C ''вод'':46B ''гаван'':2A,5B ''газ'':44B ''документац'':51B ''заверш'':60B ''здан'':8B ''инженерн'':42B ''кв'':18B ''класс'':9B ''климат'':35B,72C ''климат-контрол'':34B,71C ''контрол'':36B,73C ''круглосуточн'':38B,75C ''м'':19B ''магазин'':29B,66C ''обув'':32B,69C ''общ'':15B ''одежд'':30B,67C ''отсутств'':45B,47B ''охра'':39B,76C ''пз'':54B,81C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,57B ''пропускн'':40B,77C ''сапфиров'':1A,4B ''систем'':33B,41B,43B,70C,78C ''след'':23B ''соб'':7B ''соуэ'':55B,82C ''спа'':27B,64C ''спа-центр'':26B,63C ''сс'':52B,79C ''статус'':59B ''стоимост'':56B ''тх'':53B,80C ''удобств'':24B ''центр'':28B,65C ''электричеств'':48B ''этаж'':13B');
INSERT INTO stroy.project VALUES (53, 'Ультра Проект', 12, 1, '{41,22,32,18,78,27,77}', 25222206, '2023-10-26', 'В работе', 'Проект "Ультра Проект" представляет собой здание класса Комфорт с 20 этажами и общей площадью 184845 кв.м. В проекте предусмотрены следующие удобства: переговорные комнаты, отделение банка, пропускная система, салоны красоты, рестораны и кафе, выставочный зал. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: ОВиК, ГС, ЭОМ, АР, СС, АПС, СОУЭ, ПЗ. Стоимость проекта: 25222206, статус: В работе.', '{"floors": 20, "amenities": ["переговорные комнаты", "отделение банка", "пропускная система", "салоны красоты", "рестораны и кафе", "выставочный зал"], "documents": ["ОВиК", "ГС", "ЭОМ", "АР", "СС", "АПС", "СОУЭ", "ПЗ"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "Комфорт", "total_area_sqm": 184845}', '''184845'':17B,91C ''20'':12B,62C ''25222206'':58B ''380'':45B,89C ''electr'':88C ''fals'':87C ''gas'':84C ''true'':85C ''water'':86C ''апс'':53B,81C ''ар'':51B,79C ''банк'':28B,66C ''вод'':42B ''выставочн'':36B,74C ''газ'':40B ''гс'':49B,77C ''документац'':47B ''зал'':37B,75C ''здан'':8B ''инженерн'':38B ''каф'':35B,73C ''кв'':18B ''класс'':9B ''комнат'':26B,64C ''комфорт'':10B,90C ''красот'':32B,70C ''м'':19B ''общ'':15B ''овик'':48B,76C ''отделен'':27B,65C ''отсутств'':43B ''переговорн'':25B,63C ''пз'':55B,83C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':2A,3B,5B,21B,57B ''пропускн'':29B,67C ''работ'':61B ''рестора'':33B,71C ''салон'':31B,69C ''систем'':30B,39B,68C ''след'':23B ''соб'':7B ''соуэ'':54B,82C ''сс'':52B,80C ''статус'':59B ''стоимост'':56B ''удобств'':24B ''ультр'':1A,4B ''э'':50B,78C ''электричеств'':44B ''этаж'':13B');
INSERT INTO stroy.project VALUES (54, 'ФортунаГрад', 181, 14, '{17,31}', 4234567, '2023-09-19', 'В работе', 'Проект "ФортунаГрад" представляет собой здание класса D с 20 этажами и общей площадью 134681 кв.м. В проекте предусмотрены следующие удобства: продуктовый супермаркет, кофейня, коворкинг, пропускная система. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: ГС, ТХ, ПЗ, АР. Стоимость проекта: 4234567, статус: В работе.', '{"floors": 20, "amenities": ["продуктовый супермаркет", "кофейня", "коворкинг", "пропускная система"], "documents": ["ГС", "ТХ", "ПЗ", "АР"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "D", "total_area_sqm": 134681}', '''134681'':15B,67C ''20'':10B,49C ''380'':36B,65C ''4234567'':45B ''d'':8B,66C ''electr'':64C ''fals'':61C,63C ''gas'':60C ''water'':62C ''ар'':42B,59C ''вод'':33B ''газ'':31B ''гс'':39B,56C ''документац'':38B ''здан'':6B ''инженерн'':29B ''кв'':16B ''класс'':7B ''коворкинг'':26B,53C ''кофейн'':25B,52C ''м'':17B ''общ'':13B ''отсутств'':32B,34B ''пз'':41B,58C ''площад'':14B ''представля'':4B ''предусмотр'':20B ''продуктов'':23B,50C ''проект'':2B,19B,44B ''пропускн'':27B,54C ''работ'':48B ''систем'':28B,30B,55C ''след'':21B ''соб'':5B ''статус'':46B ''стоимост'':43B ''супермаркет'':24B,51C ''тх'':40B,57C ''удобств'':22B ''фортунаград'':1A,3B ''электричеств'':35B ''этаж'':11B');
INSERT INTO stroy.project VALUES (55, 'Хрустальная Галерея', 188, 3, '{74,66}', 4234567, '2023-01-11', 'В работе', 'Проект "Хрустальная Галерея" представляет собой здание класса B+ с 6 этажами и общей площадью 131509 кв.м. В проекте предусмотрены следующие удобства: прачечная, зона ожидания с мягкой мебелью, кофейня, пропускная система, подземный паркинг, выставочный зал, коворкинг, круглосуточная охрана, паркинг для посетителей. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: ГС, АР, СОУЭ, АПС, ОВиК. Стоимость проекта: 4234567, статус: В работе.', '{"floors": 6, "amenities": ["прачечная", "зона ожидания с мягкой мебелью", "кофейня", "пропускная система", "подземный паркинг", "выставочный зал", "коворкинг", "круглосуточная охрана", "паркинг для посетителей"], "documents": ["ГС", "АР", "СОУЭ", "АПС", "ОВиК"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "B+", "total_area_sqm": 131509}', '''131509'':17B,97C ''220'':51B,95C ''4234567'':61B ''6'':12B,65C ''b'':10B,96C ''electr'':94C ''fals'':91C,93C ''gas'':90C ''water'':92C ''апс'':57B,88C ''ар'':55B,86C ''вод'':48B ''выставочн'':36B,77C ''газ'':46B ''галере'':2A,5B ''гс'':54B,85C ''документац'':53B ''зал'':37B,78C ''здан'':8B ''зон'':26B,67C ''инженерн'':44B ''кв'':18B ''класс'':9B ''коворкинг'':38B,79C ''кофейн'':31B,72C ''круглосуточн'':39B,80C ''м'':19B ''мебел'':30B,71C ''мягк'':29B,70C ''общ'':15B ''овик'':58B,89C ''ожидан'':27B,68C ''отсутств'':47B,49B ''охра'':40B,81C ''паркинг'':35B,41B,76C,82C ''площад'':16B ''подземн'':34B,75C ''посетител'':43B,84C ''прачечн'':25B,66C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,60B ''пропускн'':32B,73C ''работ'':64B ''систем'':33B,45B,74C ''след'':23B ''соб'':7B ''соуэ'':56B,87C ''статус'':62B ''стоимост'':59B ''удобств'':24B ''хрустальн'':1A,4B ''электричеств'':50B ''этаж'':13B');
INSERT INTO stroy.project VALUES (57, 'ШедеврСтрой', 225, 14, '{41,65,64,47,2,14,73,9,30}', 37567876, '2022-10-09', 'На подписании', 'Проект "ШедеврСтрой" представляет собой здание класса Бизнес с 13 этажами и общей площадью 58760 кв.м. В проекте предусмотрены следующие удобства: спа-центр, салоны красоты, подземный паркинг. Инженерные системы: газ - есть, вода - есть, электричество - 220 В. Документация: АР, ГС, СОУЭ. Стоимость проекта: 37567876, статус: На подписании.', '{"floors": 13, "amenities": ["спа-центр", "салоны красоты", "подземный паркинг"], "documents": ["АР", "ГС", "СОУЭ"], "engineering": {"gas": true, "water": true, "electricity": 220}, "building_class": "Бизнес", "total_area_sqm": 58760}', '''13'':10B,49C ''220'':37B,65C ''37567876'':45B ''58760'':15B,67C ''electr'':64C ''gas'':60C ''true'':61C,63C ''water'':62C ''ар'':40B,57C ''бизнес'':8B,66C ''вод'':34B ''газ'':32B ''гс'':41B,58C ''документац'':39B ''здан'':6B ''инженерн'':30B ''кв'':16B ''класс'':7B ''красот'':27B,54C ''м'':17B ''общ'':13B ''паркинг'':29B,56C ''площад'':14B ''подземн'':28B,55C ''подписан'':48B ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,44B ''салон'':26B,53C ''систем'':31B ''след'':21B ''соб'':5B ''соуэ'':42B,59C ''спа'':24B,51C ''спа-центр'':23B,50C ''статус'':46B ''стоимост'':43B ''удобств'':22B ''центр'':25B,52C ''шедеврстр'':1A,3B ''электричеств'':36B ''этаж'':11B');
INSERT INTO stroy.project VALUES (58, 'ЭкоСфера', 205, 14, '{78,34,14,4,15,40}', 33864175, '2023-11-14', 'В работе', 'Проект "ЭкоСфера" представляет собой здание класса Комфорт с 6 этажами и общей площадью 143699 кв.м. В проекте предусмотрены следующие удобства: рестораны и кафе, круглосуточная охрана, Фуд-корт, зарядные станции для электромобилей. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: КР, АПС, ОВиК, ГС, СС, ЭОМ, СОУЭ. Стоимость проекта: 33864175, статус: В работе.', '{"floors": 6, "amenities": ["рестораны и кафе", "круглосуточная охрана", "Фуд-корт", "зарядные станции для электромобилей"], "documents": ["КР", "АПС", "ОВиК", "ГС", "СС", "ЭОМ", "СОУЭ"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "Комфорт", "total_area_sqm": 143699}', '''143699'':15B,85C ''220'':42B,83C ''33864175'':54B ''6'':10B,58C ''electr'':82C ''fals'':81C ''gas'':78C ''true'':79C ''water'':80C ''апс'':46B,72C ''вод'':39B ''газ'':37B ''гс'':48B,74C ''документац'':44B ''зарядн'':31B,67C ''здан'':6B ''инженерн'':35B ''каф'':25B,61C ''кв'':16B ''класс'':7B ''комфорт'':8B,84C ''корт'':30B,66C ''кр'':45B,71C ''круглосуточн'':26B,62C ''м'':17B ''общ'':13B ''овик'':47B,73C ''отсутств'':40B ''охра'':27B,63C ''площад'':14B ''представля'':4B ''предусмотр'':20B ''проект'':2B,19B,53B ''работ'':57B ''рестора'':23B,59C ''систем'':36B ''след'':21B ''соб'':5B ''соуэ'':51B,77C ''сс'':49B,75C ''станц'':32B,68C ''статус'':55B ''стоимост'':52B ''удобств'':22B ''фуд'':29B,65C ''фуд-корт'':28B,64C ''э'':50B,76C ''экосфер'':1A,3B ''электричеств'':41B ''электромобил'':34B,70C ''этаж'':11B');
INSERT INTO stroy.project VALUES (59, 'Бриллиантовый Берег', 188, 27, '{61,8}', 22753072, '2024-04-01', 'На подписании', 'Проект "Бриллиантовый Берег" представляет собой здание класса Эконом с 21 этажами и общей площадью 36090 кв.м. В проекте предусмотрены следующие удобства: Фуд-корт, конференц-залы, прачечная, кофейня, электроника и бытовая техника, пропускная система. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: ГС, ТХ, ПЗ, АПС, СС, АР, ОВиК. Стоимость проекта: 22753072, статус: На подписании.', '{"floors": 21, "amenities": ["Фуд-корт", "конференц-залы", "прачечная", "кофейня", "электроника и бытовая техника", "пропускная система"], "documents": ["ГС", "ТХ", "ПЗ", "АПС", "СС", "АР", "ОВиК"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "Эконом", "total_area_sqm": 36090}', '''21'':12B,62C ''220'':46B,89C ''22753072'':58B ''36090'':17B,91C ''electr'':88C ''fals'':85C ''gas'':84C ''true'':87C ''water'':86C ''апс'':52B,80C ''ар'':54B,82C ''берег'':2A,5B ''бриллиантов'':1A,4B ''бытов'':35B,73C ''вод'':43B ''газ'':41B ''гс'':49B,77C ''документац'':48B ''зал'':30B,68C ''здан'':8B ''инженерн'':39B ''кв'':18B ''класс'':9B ''конференц'':29B,67C ''конференц-зал'':28B,66C ''корт'':27B,65C ''кофейн'':32B,70C ''м'':19B ''общ'':15B ''овик'':55B,83C ''отсутств'':42B ''пз'':51B,79C ''площад'':16B ''подписан'':61B ''прачечн'':31B,69C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,57B ''пропускн'':37B,75C ''систем'':38B,40B,76C ''след'':23B ''соб'':7B ''сс'':53B,81C ''статус'':59B ''стоимост'':56B ''техник'':36B,74C ''тх'':50B,78C ''удобств'':24B ''фуд'':26B,64C ''фуд-корт'':25B,63C ''экон'':10B,90C ''электричеств'':45B ''электроник'':33B,71C ''этаж'':13B');
INSERT INTO stroy.project VALUES (60, 'Венец Веков', 190, 53, '{48,77,31,60,46,54,34,35}', 19049371, '2023-03-06', 'На подписании', 'Проект "Венец Веков" представляет собой здание класса C с 24 этажами и общей площадью 52308 кв.м. В проекте предусмотрены следующие удобства: коворкинг, подземный паркинг, велопарковка, пропускная система, отделение банка. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: КР, ЭОМ, СС, ТХ, СОУЭ, АР, ГС. Стоимость проекта: 19049371, статус: На подписании.', '{"floors": 24, "amenities": ["коворкинг", "подземный паркинг", "велопарковка", "пропускная система", "отделение банка"], "documents": ["КР", "ЭОМ", "СС", "ТХ", "СОУЭ", "АР", "ГС"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "C", "total_area_sqm": 52308}', '''19049371'':52B ''220'':40B,77C ''24'':12B,56C ''52308'':17B,79C ''c'':10B,78C ''electr'':76C ''fals'':73C ''gas'':72C ''true'':75C ''water'':74C ''ар'':48B,70C ''банк'':32B,64C ''век'':2A,5B ''велопарковк'':28B,60C ''венец'':1A,4B ''вод'':37B ''газ'':35B ''гс'':49B,71C ''документац'':42B ''здан'':8B ''инженерн'':33B ''кв'':18B ''класс'':9B ''коворкинг'':25B,57C ''кр'':43B,65C ''м'':19B ''общ'':15B ''отделен'':31B,63C ''отсутств'':36B ''паркинг'':27B,59C ''площад'':16B ''подземн'':26B,58C ''подписан'':55B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,51B ''пропускн'':29B,61C ''систем'':30B,34B,62C ''след'':23B ''соб'':7B ''соуэ'':47B,69C ''сс'':45B,67C ''статус'':53B ''стоимост'':50B ''тх'':46B,68C ''удобств'':24B ''э'':44B,66C ''электричеств'':39B ''этаж'':13B');
INSERT INTO stroy.project VALUES (61, 'Грандиозный Горизонт', 91, 56, '{14,28,24,8,17,49,65,37,66,22,47}', 21518505, '2023-05-28', 'На подписании', 'Проект "Грандиозный Горизонт" представляет собой здание класса Бизнес с 20 этажами и общей площадью 128733 кв.м. В проекте предусмотрены следующие удобства: прачечная, подземный паркинг, электроника и бытовая техника, велопарковка. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: ОВиК, АР, АПС, СОУЭ, КР, ТХ. Стоимость проекта: 21518505, статус: На подписании.', '{"floors": 20, "amenities": ["прачечная", "подземный паркинг", "электроника и бытовая техника", "велопарковка"], "documents": ["ОВиК", "АР", "АПС", "СОУЭ", "КР", "ТХ"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "Бизнес", "total_area_sqm": 128733}', '''128733'':17B,77C ''20'':12B,55C ''21518505'':51B ''380'':40B,75C ''electr'':74C ''fals'':71C,73C ''gas'':70C ''water'':72C ''апс'':45B,66C ''ар'':44B,65C ''бизнес'':10B,76C ''бытов'':30B,61C ''велопарковк'':32B,63C ''вод'':37B ''газ'':35B ''горизонт'':2A,5B ''грандиозн'':1A,4B ''документац'':42B ''здан'':8B ''инженерн'':33B ''кв'':18B ''класс'':9B ''кр'':47B,68C ''м'':19B ''общ'':15B ''овик'':43B,64C ''отсутств'':36B,38B ''паркинг'':27B,58C ''площад'':16B ''подземн'':26B,57C ''подписан'':54B ''прачечн'':25B,56C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,50B ''систем'':34B ''след'':23B ''соб'':7B ''соуэ'':46B,67C ''статус'':52B ''стоимост'':49B ''техник'':31B,62C ''тх'':48B,69C ''удобств'':24B ''электричеств'':39B ''электроник'':28B,59C ''этаж'':13B');
INSERT INTO stroy.project VALUES (62, 'Династия Домов', 23, 56, '{29,30,3,20,17,9}', 26456773, '2023-02-06', 'В работе', 'Проект "Династия Домов" представляет собой здание класса Эконом с 7 этажами и общей площадью 14826 кв.м. В проекте предусмотрены следующие удобства: паркинг для посетителей, банкоматы, продуктовый супермаркет, прачечная, кофейня, конференц-залы, Фуд-корт, бизнес-центр. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: ОВиК, ГС, ЭОМ, СОУЭ, КР, ТХ, ПЗ, СС, АР. Стоимость проекта: 26456773, статус: В работе.', '{"floors": 7, "amenities": ["паркинг для посетителей", "банкоматы", "продуктовый супермаркет", "прачечная", "кофейня", "конференц-залы", "Фуд-корт", "бизнес-центр"], "documents": ["ОВиК", "ГС", "ЭОМ", "СОУЭ", "КР", "ТХ", "ПЗ", "СС", "АР"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "Эконом", "total_area_sqm": 14826}', '''14826'':17B,101C ''26456773'':63B ''380'':49B,99C ''7'':12B,67C ''electr'':98C ''fals'':95C,97C ''gas'':94C ''water'':96C ''ар'':60B,93C ''банкомат'':28B,71C ''бизнес'':40B,83C ''бизнес-центр'':39B,82C ''вод'':46B ''газ'':44B ''гс'':53B,86C ''династ'':1A,4B ''документац'':51B ''дом'':2A,5B ''зал'':35B,78C ''здан'':8B ''инженерн'':42B ''кв'':18B ''класс'':9B ''конференц'':34B,77C ''конференц-зал'':33B,76C ''корт'':38B,81C ''кофейн'':32B,75C ''кр'':56B,89C ''м'':19B ''общ'':15B ''овик'':52B,85C ''отсутств'':45B,47B ''паркинг'':25B,68C ''пз'':58B,91C ''площад'':16B ''посетител'':27B,70C ''прачечн'':31B,74C ''представля'':6B ''предусмотр'':22B ''продуктов'':29B,72C ''проект'':3B,21B,62B ''работ'':66B ''систем'':43B ''след'':23B ''соб'':7B ''соуэ'':55B,88C ''сс'':59B,92C ''статус'':64B ''стоимост'':61B ''супермаркет'':30B,73C ''тх'':57B,90C ''удобств'':24B ''фуд'':37B,80C ''фуд-корт'':36B,79C ''центр'':41B,84C ''э'':54B,87C ''экон'':10B,100C ''электричеств'':48B ''этаж'':13B');
INSERT INTO stroy.project VALUES (63, 'Живописный Переулок', 170, 1, '{65,7,74,47,76}', 21518505, '2023-07-15', 'На подписании', 'Проект "Живописный Переулок" представляет собой здание класса Комфорт с 25 этажами и общей площадью 11349 кв.м. В проекте предусмотрены следующие удобства: бизнес-центр, велопарковка, зона ожидания с мягкой мебелью, круглосуточная охрана. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: АР, СОУЭ, ГС, СС. Стоимость проекта: 21518505, статус: На подписании.', '{"floors": 25, "amenities": ["бизнес-центр", "велопарковка", "зона ожидания с мягкой мебелью", "круглосуточная охрана"], "documents": ["АР", "СОУЭ", "ГС", "СС"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "Комфорт", "total_area_sqm": 11349}', '''11349'':17B,79C ''21518505'':52B ''220'':43B,77C ''25'':12B,56C ''electr'':76C ''fals'':73C,75C ''gas'':72C ''water'':74C ''ар'':46B,68C ''бизнес'':26B,58C ''бизнес-центр'':25B,57C ''велопарковк'':28B,60C ''вод'':40B ''газ'':38B ''гс'':48B,70C ''документац'':45B ''живописн'':1A,4B ''здан'':8B ''зон'':29B,61C ''инженерн'':36B ''кв'':18B ''класс'':9B ''комфорт'':10B,78C ''круглосуточн'':34B,66C ''м'':19B ''мебел'':33B,65C ''мягк'':32B,64C ''общ'':15B ''ожидан'':30B,62C ''отсутств'':39B,41B ''охра'':35B,67C ''переулок'':2A,5B ''площад'':16B ''подписан'':55B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,51B ''систем'':37B ''след'':23B ''соб'':7B ''соуэ'':47B,69C ''сс'':49B,71C ''статус'':53B ''стоимост'':50B ''удобств'':24B ''центр'':27B,59C ''электричеств'':42B ''этаж'':13B');
INSERT INTO stroy.project VALUES (64, 'Звездный Анклав', 24, 72, '{31,41,7,17,73,43,39,36,34,29,21}', 37567876, '2022-07-17', 'На подписании', 'Проект "Звездный Анклав" представляет собой здание класса А+ с 19 этажами и общей площадью 146834 кв.м. В проекте предусмотрены следующие удобства: зарядные станции для электромобилей, отделение банка, игровая зона для детей, бесплатный Wi-Fi. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: АПС, ЭОМ, ПЗ. Стоимость проекта: 37567876, статус: На подписании.', '{"floors": 19, "amenities": ["зарядные станции для электромобилей", "отделение банка", "игровая зона для детей", "бесплатный Wi-Fi"], "documents": ["АПС", "ЭОМ", "ПЗ"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "А+", "total_area_sqm": 146834}', '''146834'':17B,83C ''19'':12B,58C ''37567876'':54B ''380'':46B,81C ''electr'':80C ''fals'':79C ''fi'':38B,72C ''gas'':76C ''true'':77C ''water'':78C ''wi'':37B,71C ''wi-fi'':36B,70C ''анкла'':2A,5B ''апс'':49B,73C ''банк'':30B,64C ''бесплатн'':35B,69C ''вод'':43B ''газ'':41B ''дет'':34B,68C ''документац'':48B ''зарядн'':25B,59C ''звездн'':1A,4B ''здан'':8B ''зон'':32B,66C ''игров'':31B,65C ''инженерн'':39B ''кв'':18B ''класс'':9B ''м'':19B ''общ'':15B ''отделен'':29B,63C ''отсутств'':44B ''пз'':51B,75C ''площад'':16B ''подписан'':57B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,53B ''систем'':40B ''след'':23B ''соб'':7B ''станц'':26B,60C ''статус'':55B ''стоимост'':52B ''удобств'':24B ''э'':50B,74C ''электричеств'':45B ''электромобил'':28B,62C ''этаж'':13B');
INSERT INTO stroy.project VALUES (65, 'Изумрудный Замок', 261, 53, '{47,43,22,78,59,39,32}', 40037010, '2022-09-17', 'Завершен', 'Проект "Изумрудный Замок" представляет собой здание класса B с 9 этажами и общей площадью 121649 кв.м. В проекте предусмотрены следующие удобства: пропускная система, конференц-залы, видеонаблюдение, паркинг для посетителей, банкоматы, электроника и бытовая техника, зарядные станции для электромобилей, аптека, подземный паркинг. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: ОВиК, СОУЭ, АР, ТХ, АПС. Стоимость проекта: 40037010, статус: Завершен.', '{"floors": 9, "amenities": ["пропускная система", "конференц-залы", "видеонаблюдение", "паркинг для посетителей", "банкоматы", "электроника и бытовая техника", "зарядные станции для электромобилей", "аптека", "подземный паркинг"], "documents": ["ОВиК", "СОУЭ", "АР", "ТХ", "АПС"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "B", "total_area_sqm": 121649}', '''121649'':17B,100C ''380'':53B,98C ''40037010'':63B ''9'':12B,66C ''b'':10B,99C ''electr'':97C ''fals'':96C ''gas'':93C ''true'':94C ''water'':95C ''апс'':60B,92C ''аптек'':43B,85C ''ар'':58B,90C ''банкомат'':34B,76C ''бытов'':37B,79C ''видеонаблюден'':30B,72C ''вод'':50B ''газ'':48B ''документац'':55B ''заверш'':65B ''зал'':29B,71C ''замок'':2A,5B ''зарядн'':39B,81C ''здан'':8B ''изумрудн'':1A,4B ''инженерн'':46B ''кв'':18B ''класс'':9B ''конференц'':28B,70C ''конференц-зал'':27B,69C ''м'':19B ''общ'':15B ''овик'':56B,88C ''отсутств'':51B ''паркинг'':31B,45B,73C,87C ''площад'':16B ''подземн'':44B,86C ''посетител'':33B,75C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,62B ''пропускн'':25B,67C ''систем'':26B,47B,68C ''след'':23B ''соб'':7B ''соуэ'':57B,89C ''станц'':40B,82C ''статус'':64B ''стоимост'':61B ''техник'':38B,80C ''тх'':59B,91C ''удобств'':24B ''электричеств'':52B ''электромобил'':42B,84C ''электроник'':35B,77C ''этаж'':13B');
INSERT INTO stroy.project VALUES (66, 'Каньон Комфорта', 92, 36, '{8,53,2,14,63,65,54,21,36,44,24,39}', 10407402, '2023-08-31', 'Отменен', 'Проект "Каньон Комфорта" представляет собой здание класса А+ с 19 этажами и общей площадью 165035 кв.м. В проекте предусмотрены следующие удобства: Фуд-корт, магазины одежды и обуви, детская комната, спа-центр, круглосуточная охрана, переговорные комнаты, химчистка, выставочный зал, аптека. Инженерные системы: газ - есть, вода - есть, электричество - 220 В. Документация: СОУЭ, АПС, СС, КР, ОВиК. Стоимость проекта: 10407402, статус: Отменен.', '{"floors": 19, "amenities": ["Фуд-корт", "магазины одежды и обуви", "детская комната", "спа-центр", "круглосуточная охрана", "переговорные комнаты", "химчистка", "выставочный зал", "аптека"], "documents": ["СОУЭ", "АПС", "СС", "КР", "ОВиК"], "engineering": {"gas": true, "water": true, "electricity": 220}, "building_class": "А+", "total_area_sqm": 165035}', '''10407402'':62B ''165035'':17B,98C ''19'':12B,65C ''220'':52B,96C ''electr'':95C ''gas'':91C ''true'':92C,94C ''water'':93C ''апс'':56B,87C ''аптек'':44B,85C ''вод'':49B ''выставочн'':42B,83C ''газ'':47B ''детск'':32B,73C ''документац'':54B ''зал'':43B,84C ''здан'':8B ''инженерн'':45B ''каньон'':1A,4B ''кв'':18B ''класс'':9B ''комнат'':33B,40B,74C,81C ''комфорт'':2A,5B ''корт'':27B,68C ''кр'':58B,89C ''круглосуточн'':37B,78C ''м'':19B ''магазин'':28B,69C ''обув'':31B,72C ''общ'':15B ''овик'':59B,90C ''одежд'':29B,70C ''отмен'':64B ''охра'':38B,79C ''переговорн'':39B,80C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,61B ''систем'':46B ''след'':23B ''соб'':7B ''соуэ'':55B,86C ''спа'':35B,76C ''спа-центр'':34B,75C ''сс'':57B,88C ''статус'':63B ''стоимост'':60B ''удобств'':24B ''фуд'':26B,67C ''фуд-корт'':25B,66C ''химчистк'':41B,82C ''центр'':36B,77C ''электричеств'':51B ''этаж'':13B');
INSERT INTO stroy.project VALUES (67, 'Легендарный Ландшафт', 175, 35, '{28,25,49,51,5,63,33,34,62,23,6,3}', 17814804, '2023-12-12', 'Завершен', 'Проект "Легендарный Ландшафт" представляет собой здание класса B+ с 24 этажами и общей площадью 89012 кв.м. В проекте предусмотрены следующие удобства: зона ожидания с мягкой мебелью, продуктовый супермаркет, переговорные комнаты, банкоматы, детская комната, конференц-залы, химчистка, электроника и бытовая техника, магазины одежды и обуви. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: ОВиК, ГС, АПС, СОУЭ, КР, ТХ, ПЗ. Стоимость проекта: 17814804, статус: Завершен.', '{"floors": 24, "amenities": ["зона ожидания с мягкой мебелью", "продуктовый супермаркет", "переговорные комнаты", "банкоматы", "детская комната", "конференц-залы", "химчистка", "электроника и бытовая техника", "магазины одежды и обуви"], "documents": ["ОВиК", "ГС", "АПС", "СОУЭ", "КР", "ТХ", "ПЗ"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "B+", "total_area_sqm": 89012}', '''17814804'':68B ''24'':12B,71C ''380'':56B,108C ''89012'':17B,110C ''b'':10B,109C ''electr'':107C ''fals'':106C ''gas'':103C ''true'':104C ''water'':105C ''апс'':61B,98C ''банкомат'':34B,81C ''бытов'':43B,90C ''вод'':53B ''газ'':51B ''гс'':60B,97C ''детск'':35B,82C ''документац'':58B ''заверш'':70B ''зал'':39B,86C ''здан'':8B ''зон'':25B,72C ''инженерн'':49B ''кв'':18B ''класс'':9B ''комнат'':33B,36B,80C,83C ''конференц'':38B,85C ''конференц-зал'':37B,84C ''кр'':63B,100C ''ландшафт'':2A,5B ''легендарн'':1A,4B ''м'':19B ''магазин'':45B,92C ''мебел'':29B,76C ''мягк'':28B,75C ''обув'':48B,95C ''общ'':15B ''овик'':59B,96C ''одежд'':46B,93C ''ожидан'':26B,73C ''отсутств'':54B ''переговорн'':32B,79C ''пз'':65B,102C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''продуктов'':30B,77C ''проект'':3B,21B,67B ''систем'':50B ''след'':23B ''соб'':7B ''соуэ'':62B,99C ''статус'':69B ''стоимост'':66B ''супермаркет'':31B,78C ''техник'':44B,91C ''тх'':64B,101C ''удобств'':24B ''химчистк'':40B,87C ''электричеств'':55B ''электроник'':41B,88C ''этаж'':13B');
INSERT INTO stroy.project VALUES (68, 'Монолит Мечты', 63, 30, '{36,35,60,21,3,11,46,25,41,39,37,77}', 30160474, '2022-07-27', 'В работе', 'Проект "Монолит Мечты" представляет собой здание класса C с 9 этажами и общей площадью 40113 кв.м. В проекте предусмотрены следующие удобства: круглосуточная охрана, аптека, зарядные станции для электромобилей, отделение банка, паркинг для посетителей, пропускная система, банкоматы, Фуд-корт. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: КР, ОВиК, СОУЭ, ГС, ПЗ, ЭОМ, АПС. Стоимость проекта: 30160474, статус: В работе.', '{"floors": 9, "amenities": ["круглосуточная охрана", "аптека", "зарядные станции для электромобилей", "отделение банка", "паркинг для посетителей", "пропускная система", "банкоматы", "Фуд-корт"], "documents": ["КР", "ОВиК", "СОУЭ", "ГС", "ПЗ", "ЭОМ", "АПС"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "C", "total_area_sqm": 40113}', '''220'':50B,97C ''30160474'':62B ''40113'':17B,99C ''9'':12B,66C ''c'':10B,98C ''electr'':96C ''fals'':93C,95C ''gas'':92C ''water'':94C ''апс'':59B,91C ''аптек'':27B,69C ''банк'':33B,75C ''банкомат'':39B,81C ''вод'':47B ''газ'':45B ''гс'':56B,88C ''документац'':52B ''зарядн'':28B,70C ''здан'':8B ''инженерн'':43B ''кв'':18B ''класс'':9B ''корт'':42B,84C ''кр'':53B,85C ''круглосуточн'':25B,67C ''м'':19B ''мечт'':2A,5B ''монол'':1A,4B ''общ'':15B ''овик'':54B,86C ''отделен'':32B,74C ''отсутств'':46B,48B ''охра'':26B,68C ''паркинг'':34B,76C ''пз'':57B,89C ''площад'':16B ''посетител'':36B,78C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,61B ''пропускн'':37B,79C ''работ'':65B ''систем'':38B,44B,80C ''след'':23B ''соб'':7B ''соуэ'':55B,87C ''станц'':29B,71C ''статус'':63B ''стоимост'':60B ''удобств'':24B ''фуд'':41B,83C ''фуд-корт'':40B,82C ''э'':58B,90C ''электричеств'':49B ''электромобил'':31B,73C ''этаж'':13B');
INSERT INTO stroy.project VALUES (69, 'Олимпийский Оазис', 180, 24, '{39,18,33,6,45,53,31,23,38,43,37,47}', 17814804, '2022-06-14', 'В работе', 'Проект "Олимпийский Оазис" представляет собой здание класса B с 15 этажами и общей площадью 10572 кв.м. В проекте предусмотрены следующие удобства: паркинг для посетителей, продуктовый супермаркет, зона ожидания с мягкой мебелью, подземный паркинг, отделение банка, рестораны и кафе. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: ОВиК, ГС, АПС, СОУЭ, АР. Стоимость проекта: 17814804, статус: В работе.', '{"floors": 15, "amenities": ["паркинг для посетителей", "продуктовый супермаркет", "зона ожидания с мягкой мебелью", "подземный паркинг", "отделение банка", "рестораны и кафе"], "documents": ["ОВиК", "ГС", "АПС", "СОУЭ", "АР"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "B", "total_area_sqm": 10572}', '''10572'':17B,93C ''15'':12B,63C ''17814804'':59B ''380'':49B,91C ''b'':10B,92C ''electr'':90C ''fals'':87C,89C ''gas'':86C ''water'':88C ''апс'':54B,83C ''ар'':56B,85C ''банк'':38B,77C ''вод'':46B ''газ'':44B ''гс'':53B,82C ''документац'':51B ''здан'':8B ''зон'':30B,69C ''инженерн'':42B ''каф'':41B,80C ''кв'':18B ''класс'':9B ''м'':19B ''мебел'':34B,73C ''мягк'':33B,72C ''оазис'':2A,5B ''общ'':15B ''овик'':52B,81C ''ожидан'':31B,70C ''олимпийск'':1A,4B ''отделен'':37B,76C ''отсутств'':45B,47B ''паркинг'':25B,36B,64C,75C ''площад'':16B ''подземн'':35B,74C ''посетител'':27B,66C ''представля'':6B ''предусмотр'':22B ''продуктов'':28B,67C ''проект'':3B,21B,58B ''работ'':62B ''рестора'':39B,78C ''систем'':43B ''след'':23B ''соб'':7B ''соуэ'':55B,84C ''статус'':60B ''стоимост'':57B ''супермаркет'':29B,68C ''удобств'':24B ''электричеств'':48B ''этаж'':13B');
INSERT INTO stroy.project VALUES (70, 'Панорама Престижа', 270, 56, '{21,35,25,59,60,38,62}', 38802443, '2023-06-22', 'Завершен', 'Проект "Панорама Престижа" представляет собой здание класса B+ с 20 этажами и общей площадью 42212 кв.м. В проекте предусмотрены следующие удобства: коворкинг, Фуд-корт, пропускная система, кофейня, выставочный зал, магазины одежды и обуви. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: АПС, ГС, ОВиК, АР, СС. Стоимость проекта: 38802443, статус: Завершен.', '{"floors": 20, "amenities": ["коворкинг", "Фуд-корт", "пропускная система", "кофейня", "выставочный зал", "магазины одежды и обуви"], "documents": ["АПС", "ГС", "ОВиК", "АР", "СС"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "B+", "total_area_sqm": 42212}', '''20'':12B,58C ''220'':45B,82C ''38802443'':55B ''42212'':17B,84C ''b'':10B,83C ''electr'':81C ''fals'':78C,80C ''gas'':77C ''water'':79C ''апс'':48B,72C ''ар'':51B,75C ''вод'':42B ''выставочн'':32B,66C ''газ'':40B ''гс'':49B,73C ''документац'':47B ''заверш'':57B ''зал'':33B,67C ''здан'':8B ''инженерн'':38B ''кв'':18B ''класс'':9B ''коворкинг'':25B,59C ''корт'':28B,62C ''кофейн'':31B,65C ''м'':19B ''магазин'':34B,68C ''обув'':37B,71C ''общ'':15B ''овик'':50B,74C ''одежд'':35B,69C ''отсутств'':41B,43B ''панорам'':1A,4B ''площад'':16B ''представля'':6B ''предусмотр'':22B ''престиж'':2A,5B ''проект'':3B,21B,54B ''пропускн'':29B,63C ''систем'':30B,39B,64C ''след'':23B ''соб'':7B ''сс'':52B,76C ''статус'':56B ''стоимост'':53B ''удобств'':24B ''фуд'':27B,61C ''фуд-корт'':26B,60C ''электричеств'':44B ''этаж'':13B');
INSERT INTO stroy.project VALUES (71, 'Ренессанс Резиденции', 70, 14, '{42,1,46,5,4,45,24,70,29,38}', 17814804, '2023-12-06', 'Завершен', 'Проект "Ренессанс Резиденции" представляет собой здание класса А+ с 20 этажами и общей площадью 58699 кв.м. В проекте предусмотрены следующие удобства: электроника и бытовая техника, выставочный зал, химчистка, продуктовый супермаркет, зарядные станции для электромобилей, круглосуточная охрана. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: СС, АР, ОВиК, ТХ, ЭОМ, КР. Стоимость проекта: 17814804, статус: Завершен.', '{"floors": 20, "amenities": ["электроника и бытовая техника", "выставочный зал", "химчистка", "продуктовый супермаркет", "зарядные станции для электромобилей", "круглосуточная охрана"], "documents": ["СС", "АР", "ОВиК", "ТХ", "ЭОМ", "КР"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "А+", "total_area_sqm": 58699}', '''17814804'':58B ''20'':12B,61C ''380'':47B,88C ''58699'':17B,90C ''electr'':87C ''fals'':86C ''gas'':83C ''true'':84C ''water'':85C ''ар'':51B,78C ''бытов'':27B,64C ''вод'':44B ''выставочн'':29B,66C ''газ'':42B ''документац'':49B ''заверш'':60B ''зал'':30B,67C ''зарядн'':34B,71C ''здан'':8B ''инженерн'':40B ''кв'':18B ''класс'':9B ''кр'':55B,82C ''круглосуточн'':38B,75C ''м'':19B ''общ'':15B ''овик'':52B,79C ''отсутств'':45B ''охра'':39B,76C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''продуктов'':32B,69C ''проект'':3B,21B,57B ''резиденц'':2A,5B ''ренессанс'':1A,4B ''систем'':41B ''след'':23B ''соб'':7B ''сс'':50B,77C ''станц'':35B,72C ''статус'':59B ''стоимост'':56B ''супермаркет'':33B,70C ''техник'':28B,65C ''тх'':53B,80C ''удобств'':24B ''химчистк'':31B,68C ''э'':54B,81C ''электричеств'':46B ''электромобил'':37B,74C ''электроник'':25B,62C ''этаж'':13B');
INSERT INTO stroy.project VALUES (72, 'Созвездие Стиля', 128, 53, '{69,18,4,79,7,58}', 27691340, '2022-08-19', 'На подписании', 'Проект "Созвездие Стиля" представляет собой здание класса Бизнес с 14 этажами и общей площадью 170150 кв.м. В проекте предусмотрены следующие удобства: отделение банка, коворкинг, спа-центр, игровая зона для детей, электроника и бытовая техника, пропускная система. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: ЭОМ, ПЗ, АР, ОВиК, ГС, СОУЭ, АПС, ТХ. Стоимость проекта: 27691340, статус: На подписании.', '{"floors": 14, "amenities": ["отделение банка", "коворкинг", "спа-центр", "игровая зона для детей", "электроника и бытовая техника", "пропускная система"], "documents": ["ЭОМ", "ПЗ", "АР", "ОВиК", "ГС", "СОУЭ", "АПС", "ТХ"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "Бизнес", "total_area_sqm": 170150}', '''14'':12B,65C ''170150'':17B,97C ''27691340'':61B ''380'':48B,95C ''electr'':94C ''fals'':91C,93C ''gas'':90C ''water'':92C ''апс'':57B,88C ''ар'':53B,84C ''банк'':26B,67C ''бизнес'':10B,96C ''бытов'':37B,78C ''вод'':45B ''газ'':43B ''гс'':55B,86C ''дет'':34B,75C ''документац'':50B ''здан'':8B ''зон'':32B,73C ''игров'':31B,72C ''инженерн'':41B ''кв'':18B ''класс'':9B ''коворкинг'':27B,68C ''м'':19B ''общ'':15B ''овик'':54B,85C ''отделен'':25B,66C ''отсутств'':44B,46B ''пз'':52B,83C ''площад'':16B ''подписан'':64B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,60B ''пропускн'':39B,80C ''систем'':40B,42B,81C ''след'':23B ''соб'':7B ''созвезд'':1A,4B ''соуэ'':56B,87C ''спа'':29B,70C ''спа-центр'':28B,69C ''статус'':62B ''стил'':2A,5B ''стоимост'':59B ''техник'':38B,79C ''тх'':58B,89C ''удобств'':24B ''центр'':30B,71C ''э'':51B,82C ''электричеств'':47B ''электроник'':35B,76C ''этаж'':13B');
INSERT INTO stroy.project VALUES (73, 'Триумфальная Терраса', 273, 18, '{65,27,12,9,45}', 40037010, '2022-06-24', 'Отменен', 'Проект "Триумфальная Терраса" представляет собой здание класса Бизнес с 18 этажами и общей площадью 64249 кв.м. В проекте предусмотрены следующие удобства: банкоматы, игровая зона для детей, электроника и бытовая техника, переговорные комнаты, система климат-контроля, кофейня, магазины одежды и обуви, продуктовый супермаркет. Инженерные системы: газ - отсутствует, вода - есть, электричество - 380 В. Документация: АР, СОУЭ, АПС, ОВиК, ПЗ, ГС, ЭОМ, СС, КР. Стоимость проекта: 40037010, статус: Отменен.', '{"floors": 18, "amenities": ["банкоматы", "игровая зона для детей", "электроника и бытовая техника", "переговорные комнаты", "система климат-контроля", "кофейня", "магазины одежды и обуви", "продуктовый супермаркет"], "documents": ["АР", "СОУЭ", "АПС", "ОВиК", "ПЗ", "ГС", "ЭОМ", "СС", "КР"], "engineering": {"gas": false, "water": true, "electricity": 380}, "building_class": "Бизнес", "total_area_sqm": 64249}', '''18'':12B,71C ''380'':54B,108C ''40037010'':68B ''64249'':17B,110C ''electr'':107C ''fals'':104C ''gas'':103C ''true'':106C ''water'':105C ''апс'':59B,96C ''ар'':57B,94C ''банкомат'':25B,72C ''бизнес'':10B,109C ''бытов'':32B,79C ''вод'':51B ''газ'':49B ''гс'':62B,99C ''дет'':29B,76C ''документац'':56B ''здан'':8B ''зон'':27B,74C ''игров'':26B,73C ''инженерн'':47B ''кв'':18B ''класс'':9B ''климат'':38B,85C ''климат-контрол'':37B,84C ''комнат'':35B,82C ''контрол'':39B,86C ''кофейн'':40B,87C ''кр'':65B,102C ''м'':19B ''магазин'':41B,88C ''обув'':44B,91C ''общ'':15B ''овик'':60B,97C ''одежд'':42B,89C ''отмен'':70B ''отсутств'':50B ''переговорн'':34B,81C ''пз'':61B,98C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''продуктов'':45B,92C ''проект'':3B,21B,67B ''систем'':36B,48B,83C ''след'':23B ''соб'':7B ''соуэ'':58B,95C ''сс'':64B,101C ''статус'':69B ''стоимост'':66B ''супермаркет'':46B,93C ''террас'':2A,5B ''техник'':33B,80C ''триумфальн'':1A,4B ''удобств'':24B ''э'':63B,100C ''электричеств'':53B ''электроник'':30B,77C ''этаж'':13B');
INSERT INTO stroy.project VALUES (74, 'Фиеста Фасадов', 252, 33, '{11,27,70,16,50}', 4234567, '2022-06-20', 'Завершен', 'Проект "Фиеста Фасадов" представляет собой здание класса Комфорт с 7 этажами и общей площадью 167556 кв.м. В проекте предусмотрены следующие удобства: спа-центр, выставочный зал, салоны красоты, детская комната. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: ТХ, КР, СС, АР, ОВиК, ПЗ, ГС, СОУЭ, ЭОМ. Стоимость проекта: 4234567, статус: Завершен.', '{"floors": 7, "amenities": ["спа-центр", "выставочный зал", "салоны красоты", "детская комната"], "documents": ["ТХ", "КР", "СС", "АР", "ОВиК", "ПЗ", "ГС", "СОУЭ", "ЭОМ"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "Комфорт", "total_area_sqm": 167556}', '''167556'':17B,84C ''380'':41B,82C ''4234567'':55B ''7'':12B,58C ''electr'':81C ''fals'':80C ''gas'':77C ''true'':78C ''water'':79C ''ар'':47B,71C ''вод'':38B ''выставочн'':28B,62C ''газ'':36B ''гс'':50B,74C ''детск'':32B,66C ''документац'':43B ''заверш'':57B ''зал'':29B,63C ''здан'':8B ''инженерн'':34B ''кв'':18B ''класс'':9B ''комнат'':33B,67C ''комфорт'':10B,83C ''кр'':45B,69C ''красот'':31B,65C ''м'':19B ''общ'':15B ''овик'':48B,72C ''отсутств'':39B ''пз'':49B,73C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,54B ''салон'':30B,64C ''систем'':35B ''след'':23B ''соб'':7B ''соуэ'':51B,75C ''спа'':26B,60C ''спа-центр'':25B,59C ''сс'':46B,70C ''статус'':56B ''стоимост'':53B ''тх'':44B,68C ''удобств'':24B ''фасад'':2A,5B ''фиест'':1A,4B ''центр'':27B,61C ''э'':52B,76C ''электричеств'':40B ''этаж'':13B');
INSERT INTO stroy.project VALUES (75, 'Харизма Хайтс', 60, 33, '{73,68}', 22753072, '2023-02-25', 'Отменен', 'Проект "Харизма Хайтс" представляет собой здание класса А+ с 14 этажами и общей площадью 99910 кв.м. В проекте предусмотрены следующие удобства: конференц-залы, отделение банка, велопарковка, аптека, зона ожидания с мягкой мебелью, коворкинг, магазины одежды и обуви. Инженерные системы: газ - есть, вода - есть, электричество - 220 В. Документация: СС, ТХ, СОУЭ, ПЗ, ЭОМ, КР, АР, ОВиК. Стоимость проекта: 22753072, статус: Отменен.', '{"floors": 14, "amenities": ["конференц-залы", "отделение банка", "велопарковка", "аптека", "зона ожидания с мягкой мебелью", "коворкинг", "магазины одежды и обуви"], "documents": ["СС", "ТХ", "СОУЭ", "ПЗ", "ЭОМ", "КР", "АР", "ОВиК"], "engineering": {"gas": true, "water": true, "electricity": 220}, "building_class": "А+", "total_area_sqm": 99910}', '''14'':12B,65C ''220'':49B,96C ''22753072'':62B ''99910'':17B,98C ''electr'':95C ''gas'':91C ''true'':92C,94C ''water'':93C ''аптек'':31B,72C ''ар'':58B,89C ''банк'':29B,70C ''велопарковк'':30B,71C ''вод'':46B ''газ'':44B ''документац'':51B ''зал'':27B,68C ''здан'':8B ''зон'':32B,73C ''инженерн'':42B ''кв'':18B ''класс'':9B ''коворкинг'':37B,78C ''конференц'':26B,67C ''конференц-зал'':25B,66C ''кр'':57B,88C ''м'':19B ''магазин'':38B,79C ''мебел'':36B,77C ''мягк'':35B,76C ''обув'':41B,82C ''общ'':15B ''овик'':59B,90C ''одежд'':39B,80C ''ожидан'':33B,74C ''отделен'':28B,69C ''отмен'':64B ''пз'':55B,86C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,61B ''систем'':43B ''след'':23B ''соб'':7B ''соуэ'':54B,85C ''сс'':52B,83C ''статус'':63B ''стоимост'':60B ''тх'':53B,84C ''удобств'':24B ''хайтс'':2A,5B ''харизм'':1A,4B ''э'':56B,87C ''электричеств'':48B ''этаж'':13B');
INSERT INTO stroy.project VALUES (76, 'Цитадель Ценностей', 249, 75, '{16}', 32629608, '2023-11-20', 'На подписании', 'Проект "Цитадель Ценностей" представляет собой здание класса Бизнес с 17 этажами и общей площадью 24370 кв.м. В проекте предусмотрены следующие удобства: коворкинг, зарядные станции для электромобилей, аптека, бесплатный Wi-Fi, конференц-залы. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: ПЗ, ТХ, КР, ЭОМ. Стоимость проекта: 32629608, статус: На подписании.', '{"floors": 17, "amenities": ["коворкинг", "зарядные станции для электромобилей", "аптека", "бесплатный Wi-Fi", "конференц-залы"], "documents": ["ПЗ", "ТХ", "КР", "ЭОМ"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "Бизнес", "total_area_sqm": 24370}', '''17'':12B,58C ''220'':45B,81C ''24370'':17B,83C ''32629608'':54B ''electr'':80C ''fals'':79C ''fi'':34B,68C ''gas'':76C ''true'':77C ''water'':78C ''wi'':33B,67C ''wi-fi'':32B,66C ''аптек'':30B,64C ''бесплатн'':31B,65C ''бизнес'':10B,82C ''вод'':42B ''газ'':40B ''документац'':47B ''зал'':37B,71C ''зарядн'':26B,60C ''здан'':8B ''инженерн'':38B ''кв'':18B ''класс'':9B ''коворкинг'':25B,59C ''конференц'':36B,70C ''конференц-зал'':35B,69C ''кр'':50B,74C ''м'':19B ''общ'':15B ''отсутств'':43B ''пз'':48B,72C ''площад'':16B ''подписан'':57B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,53B ''систем'':39B ''след'':23B ''соб'':7B ''станц'':27B,61C ''статус'':55B ''стоимост'':52B ''тх'':49B,73C ''удобств'':24B ''ценност'':2A,5B ''цитадел'':1A,4B ''э'':51B,75C ''электричеств'':44B ''электромобил'':29B,63C ''этаж'':13B');
INSERT INTO stroy.project VALUES (78, 'Авангард Авеню', 154, 53, '{29,51,54,64,27,69}', 33864175, '2023-07-03', 'Завершен', 'Проект "Авангард Авеню" представляет собой здание класса Премиум с 17 этажами и общей площадью 8291 кв.м. В проекте предусмотрены следующие удобства: банкоматы, бесплатный Wi-Fi, зона ожидания с мягкой мебелью, паркинг для посетителей. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: ТХ, АР, ЭОМ. Стоимость проекта: 33864175, статус: Завершен.', '{"floors": 17, "amenities": ["банкоматы", "бесплатный Wi-Fi", "зона ожидания с мягкой мебелью", "паркинг для посетителей"], "documents": ["ТХ", "АР", "ЭОМ"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "Премиум", "total_area_sqm": 8291}', '''17'':12B,56C ''220'':45B,78C ''33864175'':53B ''8291'':17B,80C ''electr'':77C ''fals'':76C ''fi'':29B,61C ''gas'':73C ''true'':74C ''water'':75C ''wi'':28B,60C ''wi-fi'':27B,59C ''авангард'':1A,4B ''авен'':2A,5B ''ар'':49B,71C ''банкомат'':25B,57C ''бесплатн'':26B,58C ''вод'':42B ''газ'':40B ''документац'':47B ''заверш'':55B ''здан'':8B ''зон'':30B,62C ''инженерн'':38B ''кв'':18B ''класс'':9B ''м'':19B ''мебел'':34B,66C ''мягк'':33B,65C ''общ'':15B ''ожидан'':31B,63C ''отсутств'':43B ''паркинг'':35B,67C ''площад'':16B ''посетител'':37B,69C ''представля'':6B ''предусмотр'':22B ''премиум'':10B,79C ''проект'':3B,21B,52B ''систем'':39B ''след'':23B ''соб'':7B ''статус'':54B ''стоимост'':51B ''тх'':48B,70C ''удобств'':24B ''э'':50B,72C ''электричеств'':44B ''этаж'':13B');
INSERT INTO stroy.project VALUES (79, 'Бриз Благодати', 57, 33, '{30,45,5,79,3}', 5469134, '2022-07-18', 'Отменен', 'Проект "Бриз Благодати" представляет собой здание класса Эконом с 25 этажами и общей площадью 195746 кв.м. В проекте предусмотрены следующие удобства: отделение банка, круглосуточная охрана, коворкинг, кофейня, зарядные станции для электромобилей, игровая зона для детей. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: АПС, СС, ПЗ, ГС, ТХ, ОВиК, СОУЭ, КР. Стоимость проекта: 5469134, статус: Отменен.', '{"floors": 25, "amenities": ["отделение банка", "круглосуточная охрана", "коворкинг", "кофейня", "зарядные станции для электромобилей", "игровая зона для детей"], "documents": ["АПС", "СС", "ПЗ", "ГС", "ТХ", "ОВиК", "СОУЭ", "КР"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "Эконом", "total_area_sqm": 195746}', '''195746'':17B,92C ''25'':12B,62C ''380'':46B,90C ''5469134'':59B ''electr'':89C ''fals'':86C,88C ''gas'':85C ''water'':87C ''апс'':49B,77C ''банк'':26B,64C ''благодат'':2A,5B ''бриз'':1A,4B ''вод'':43B ''газ'':41B ''гс'':52B,80C ''дет'':38B,76C ''документац'':48B ''зарядн'':31B,69C ''здан'':8B ''зон'':36B,74C ''игров'':35B,73C ''инженерн'':39B ''кв'':18B ''класс'':9B ''коворкинг'':29B,67C ''кофейн'':30B,68C ''кр'':56B,84C ''круглосуточн'':27B,65C ''м'':19B ''общ'':15B ''овик'':54B,82C ''отделен'':25B,63C ''отмен'':61B ''отсутств'':42B,44B ''охра'':28B,66C ''пз'':51B,79C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,58B ''систем'':40B ''след'':23B ''соб'':7B ''соуэ'':55B,83C ''сс'':50B,78C ''станц'':32B,70C ''статус'':60B ''стоимост'':57B ''тх'':53B,81C ''удобств'':24B ''экон'':10B,91C ''электричеств'':45B ''электромобил'':34B,72C ''этаж'':13B');
INSERT INTO stroy.project VALUES (80, 'Величие Валлей', 19, 3, '{17,1,62,31,71,24,74,4,19,48,9}', 12876536, '2023-07-14', 'Завершен', 'Проект "Величие Валлей" представляет собой здание класса C с 21 этажами и общей площадью 146025 кв.м. В проекте предусмотрены следующие удобства: велопарковка, выставочный зал, магазины одежды и обуви, конференц-залы, химчистка, круглосуточная охрана, система климат-контроля, электроника и бытовая техника, видеонаблюдение. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: ПЗ, ОВиК, АПС, АР, ГС, ЭОМ, СОУЭ, СС. Стоимость проекта: 12876536, статус: Завершен.', '{"floors": 21, "amenities": ["велопарковка", "выставочный зал", "магазины одежды и обуви", "конференц-залы", "химчистка", "круглосуточная охрана", "система климат-контроля", "электроника и бытовая техника", "видеонаблюдение"], "documents": ["ПЗ", "ОВиК", "АПС", "АР", "ГС", "ЭОМ", "СОУЭ", "СС"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "C", "total_area_sqm": 146025}', '''12876536'':67B ''146025'':17B,108C ''21'':12B,70C ''220'':54B,106C ''c'':10B,107C ''electr'':105C ''fals'':104C ''gas'':101C ''true'':102C ''water'':103C ''апс'':59B,95C ''ар'':60B,96C ''бытов'':44B,90C ''валл'':2A,5B ''велич'':1A,4B ''велопарковк'':25B,71C ''видеонаблюден'':46B,92C ''вод'':51B ''выставочн'':26B,72C ''газ'':49B ''гс'':61B,97C ''документац'':56B ''заверш'':69B ''зал'':27B,34B,73C,80C ''здан'':8B ''инженерн'':47B ''кв'':18B ''класс'':9B ''климат'':40B,86C ''климат-контрол'':39B,85C ''контрол'':41B,87C ''конференц'':33B,79C ''конференц-зал'':32B,78C ''круглосуточн'':36B,82C ''м'':19B ''магазин'':28B,74C ''обув'':31B,77C ''общ'':15B ''овик'':58B,94C ''одежд'':29B,75C ''отсутств'':52B ''охра'':37B,83C ''пз'':57B,93C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,66B ''систем'':38B,48B,84C ''след'':23B ''соб'':7B ''соуэ'':63B,99C ''сс'':64B,100C ''статус'':68B ''стоимост'':65B ''техник'':45B,91C ''удобств'':24B ''химчистк'':35B,81C ''э'':62B,98C ''электричеств'':53B ''электроник'':42B,88C ''этаж'':13B');
INSERT INTO stroy.project VALUES (81, 'Город Гармонии', 23, 8, '{78,75,59,61,80,8,36,6,28,43,50,7}', 4234567, '2023-08-07', 'Завершен', 'Проект "Город Гармонии" представляет собой здание класса B+ с 25 этажами и общей площадью 178457 кв.м. В проекте предусмотрены следующие удобства: прачечная, магазины одежды и обуви, салоны красоты, банкоматы, бизнес-центр, выставочный зал. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: ГС, СОУЭ, ТХ, АР, ЭОМ, КР, АПС, ОВиК, СС. Стоимость проекта: 4234567, статус: Завершен.', '{"floors": 25, "amenities": ["прачечная", "магазины одежды и обуви", "салоны красоты", "банкоматы", "бизнес-центр", "выставочный зал"], "documents": ["ГС", "СОУЭ", "ТХ", "АР", "ЭОМ", "КР", "АПС", "ОВиК", "СС"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "B+", "total_area_sqm": 178457}', '''178457'':17B,92C ''25'':12B,62C ''380'':45B,90C ''4234567'':59B ''b'':10B,91C ''electr'':89C ''fals'':86C,88C ''gas'':85C ''water'':87C ''апс'':54B,82C ''ар'':51B,79C ''банкомат'':32B,70C ''бизнес'':34B,72C ''бизнес-центр'':33B,71C ''вод'':42B ''выставочн'':36B,74C ''газ'':40B ''гармон'':2A,5B ''город'':1A,4B ''гс'':48B,76C ''документац'':47B ''заверш'':61B ''зал'':37B,75C ''здан'':8B ''инженерн'':38B ''кв'':18B ''класс'':9B ''кр'':53B,81C ''красот'':31B,69C ''м'':19B ''магазин'':26B,64C ''обув'':29B,67C ''общ'':15B ''овик'':55B,83C ''одежд'':27B,65C ''отсутств'':41B,43B ''площад'':16B ''прачечн'':25B,63C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,58B ''салон'':30B,68C ''систем'':39B ''след'':23B ''соб'':7B ''соуэ'':49B,77C ''сс'':56B,84C ''статус'':60B ''стоимост'':57B ''тх'':50B,78C ''удобств'':24B ''центр'':35B,73C ''э'':52B,80C ''электричеств'':44B ''этаж'':13B');
INSERT INTO stroy.project VALUES (82, 'Доминион Достатка', 60, 1, '{23,13,44}', 33864175, '2022-11-29', 'Завершен', 'Проект "Доминион Достатка" представляет собой здание класса C с 24 этажами и общей площадью 39800 кв.м. В проекте предусмотрены следующие удобства: магазины одежды и обуви, пропускная система, велопарковка, банкоматы, бизнес-центр, прачечная. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: ОВиК, ПЗ, АПС. Стоимость проекта: 33864175, статус: Завершен.', '{"floors": 24, "amenities": ["магазины одежды и обуви", "пропускная система", "велопарковка", "банкоматы", "бизнес-центр", "прачечная"], "documents": ["ОВиК", "ПЗ", "АПС"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "C", "total_area_sqm": 39800}', '''24'':12B,55C ''33864175'':52B ''380'':44B,76C ''39800'':17B,78C ''c'':10B,77C ''electr'':75C ''fals'':72C,74C ''gas'':71C ''water'':73C ''апс'':49B,70C ''банкомат'':32B,63C ''бизнес'':34B,65C ''бизнес-центр'':33B,64C ''велопарковк'':31B,62C ''вод'':41B ''газ'':39B ''документац'':46B ''доминион'':1A,4B ''достатк'':2A,5B ''заверш'':54B ''здан'':8B ''инженерн'':37B ''кв'':18B ''класс'':9B ''м'':19B ''магазин'':25B,56C ''обув'':28B,59C ''общ'':15B ''овик'':47B,68C ''одежд'':26B,57C ''отсутств'':40B,42B ''пз'':48B,69C ''площад'':16B ''прачечн'':36B,67C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,51B ''пропускн'':29B,60C ''систем'':30B,38B,61C ''след'':23B ''соб'':7B ''статус'':53B ''стоимост'':50B ''удобств'':24B ''центр'':35B,66C ''электричеств'':43B ''этаж'':13B');
INSERT INTO stroy.project VALUES (83, 'Жемчужина Жизни', 243, 14, '{11,77,24,43,15,5}', 4234567, '2023-02-11', 'В работе', 'Проект "Жемчужина Жизни" представляет собой здание класса Бизнес с 21 этажами и общей площадью 139281 кв.м. В проекте предусмотрены следующие удобства: подземный паркинг, отделение банка, видеонаблюдение, кофейня, детская комната, конференц-залы, бизнес-центр, Фуд-корт, пропускная система. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: АПС, ГС, СОУЭ, ТХ, ЭОМ, ПЗ. Стоимость проекта: 4234567, статус: В работе.', '{"floors": 21, "amenities": ["подземный паркинг", "отделение банка", "видеонаблюдение", "кофейня", "детская комната", "конференц-залы", "бизнес-центр", "Фуд-корт", "пропускная система"], "documents": ["АПС", "ГС", "СОУЭ", "ТХ", "ЭОМ", "ПЗ"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "Бизнес", "total_area_sqm": 139281}', '''139281'':17B,99C ''21'':12B,66C ''220'':51B,97C ''4234567'':62B ''electr'':96C ''fals'':93C ''gas'':92C ''true'':95C ''water'':94C ''апс'':54B,86C ''банк'':28B,70C ''бизнес'':10B,37B,79C,98C ''бизнес-центр'':36B,78C ''видеонаблюден'':29B,71C ''вод'':48B ''газ'':46B ''гс'':55B,87C ''детск'':31B,73C ''документац'':53B ''жемчужин'':1A,4B ''жизн'':2A,5B ''зал'':35B,77C ''здан'':8B ''инженерн'':44B ''кв'':18B ''класс'':9B ''комнат'':32B,74C ''конференц'':34B,76C ''конференц-зал'':33B,75C ''корт'':41B,83C ''кофейн'':30B,72C ''м'':19B ''общ'':15B ''отделен'':27B,69C ''отсутств'':47B ''паркинг'':26B,68C ''пз'':59B,91C ''площад'':16B ''подземн'':25B,67C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,61B ''пропускн'':42B,84C ''работ'':65B ''систем'':43B,45B,85C ''след'':23B ''соб'':7B ''соуэ'':56B,88C ''статус'':63B ''стоимост'':60B ''тх'':57B,89C ''удобств'':24B ''фуд'':40B,82C ''фуд-корт'':39B,81C ''центр'':38B,80C ''э'':58B,90C ''электричеств'':50B ''этаж'':13B');
INSERT INTO stroy.project VALUES (84, 'Зенит Завтрашнего Дня', 206, 36, '{38,26,77,7,52,64,21}', 36333309, '2022-03-17', 'На подписании', 'Проект "Зенит Завтрашнего Дня" представляет собой здание класса А с 23 этажами и общей площадью 138209 кв.м. В проекте предусмотрены следующие удобства: видеонаблюдение, паркинг для посетителей, круглосуточная охрана, зарядные станции для электромобилей, банкоматы, рестораны и кафе, аптека, зона ожидания с мягкой мебелью, магазины одежды и обуви. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: СС, ГС, АР, КР, ЭОМ, ТХ. Стоимость проекта: 36333309, статус: На подписании.', '{"floors": 23, "amenities": ["видеонаблюдение", "паркинг для посетителей", "круглосуточная охрана", "зарядные станции для электромобилей", "банкоматы", "рестораны и кафе", "аптека", "зона ожидания с мягкой мебелью", "магазины одежды и обуви"], "documents": ["СС", "ГС", "АР", "КР", "ЭОМ", "ТХ"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "А", "total_area_sqm": 138209}', '''138209'':19B,111C ''23'':14B,73C ''36333309'':69B ''380'':58B,109C ''electr'':108C ''fals'':105C,107C ''gas'':104C ''water'':106C ''аптек'':41B,88C ''ар'':63B,100C ''банкомат'':37B,84C ''видеонаблюден'':27B,74C ''вод'':55B ''газ'':53B ''гс'':62B,99C ''дня'':3A,7B ''документац'':60B ''завтрашн'':2A,6B ''зарядн'':33B,80C ''здан'':10B ''зен'':1A,5B ''зон'':42B,89C ''инженерн'':51B ''каф'':40B,87C ''кв'':20B ''класс'':11B ''кр'':64B,101C ''круглосуточн'':31B,78C ''м'':21B ''магазин'':47B,94C ''мебел'':46B,93C ''мягк'':45B,92C ''обув'':50B,97C ''общ'':17B ''одежд'':48B,95C ''ожидан'':43B,90C ''отсутств'':54B,56B ''охра'':32B,79C ''паркинг'':28B,75C ''площад'':18B ''подписан'':72B ''посетител'':30B,77C ''представля'':8B ''предусмотр'':24B ''проект'':4B,23B,68B ''рестора'':38B,85C ''систем'':52B ''след'':25B ''соб'':9B ''сс'':61B,98C ''станц'':34B,81C ''статус'':70B ''стоимост'':67B ''тх'':66B,103C ''удобств'':26B ''э'':65B,102C ''электричеств'':57B ''электромобил'':36B,83C ''этаж'':15B');
INSERT INTO stroy.project VALUES (85, 'Империя Инноваций', 33, 27, '{7,9,8,32,64,35,19}', 15345670, '2023-08-25', 'В работе', 'Проект "Империя Инноваций" представляет собой здание класса C с 7 этажами и общей площадью 68660 кв.м. В проекте предусмотрены следующие удобства: конференц-залы, зона ожидания с мягкой мебелью, бесплатный Wi-Fi, круглосуточная охрана. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: СОУЭ, ЭОМ, ОВиК, АПС, СС. Стоимость проекта: 15345670, статус: В работе.', '{"floors": 7, "amenities": ["конференц-залы", "зона ожидания с мягкой мебелью", "бесплатный Wi-Fi", "круглосуточная охрана"], "documents": ["СОУЭ", "ЭОМ", "ОВиК", "АПС", "СС"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "C", "total_area_sqm": 68660}', '''15345670'':56B ''380'':46B,85C ''68660'':17B,87C ''7'':12B,60C ''c'':10B,86C ''electr'':84C ''fals'':81C,83C ''fi'':36B,72C ''gas'':80C ''water'':82C ''wi'':35B,71C ''wi-fi'':34B,70C ''апс'':52B,78C ''бесплатн'':33B,69C ''вод'':43B ''газ'':41B ''документац'':48B ''зал'':27B,63C ''здан'':8B ''зон'':28B,64C ''импер'':1A,4B ''инженерн'':39B ''инновац'':2A,5B ''кв'':18B ''класс'':9B ''конференц'':26B,62C ''конференц-зал'':25B,61C ''круглосуточн'':37B,73C ''м'':19B ''мебел'':32B,68C ''мягк'':31B,67C ''общ'':15B ''овик'':51B,77C ''ожидан'':29B,65C ''отсутств'':42B,44B ''охра'':38B,74C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,55B ''работ'':59B ''систем'':40B ''след'':23B ''соб'':7B ''соуэ'':49B,75C ''сс'':53B,79C ''статус'':57B ''стоимост'':54B ''удобств'':24B ''э'':50B,76C ''электричеств'':45B ''этаж'':13B');
INSERT INTO stroy.project VALUES (86, 'Каскад Красоты', 205, 12, '{10,19,67}', 4234567, '2022-07-12', 'Завершен', 'Проект "Каскад Красоты" представляет собой здание класса Премиум с 15 этажами и общей площадью 65718 кв.м. В проекте предусмотрены следующие удобства: велопарковка, продуктовый супермаркет, электроника и бытовая техника, видеонаблюдение, Фуд-корт. Инженерные системы: газ - есть, вода - есть, электричество - 220 В. Документация: СОУЭ, АР, ГС, АПС, КР, ОВиК, ТХ, ПЗ, ЭОМ. Стоимость проекта: 4234567, статус: Завершен.', '{"floors": 15, "amenities": ["велопарковка", "продуктовый супермаркет", "электроника и бытовая техника", "видеонаблюдение", "Фуд-корт"], "documents": ["СОУЭ", "АР", "ГС", "АПС", "КР", "ОВиК", "ТХ", "ПЗ", "ЭОМ"], "engineering": {"gas": true, "water": true, "electricity": 220}, "building_class": "Премиум", "total_area_sqm": 65718}', '''15'':12B,60C ''220'':43B,86C ''4234567'':57B ''65718'':17B,88C ''electr'':85C ''gas'':81C ''true'':82C,84C ''water'':83C ''апс'':49B,75C ''ар'':47B,73C ''бытов'':30B,66C ''велопарковк'':25B,61C ''видеонаблюден'':32B,68C ''вод'':40B ''газ'':38B ''гс'':48B,74C ''документац'':45B ''заверш'':59B ''здан'':8B ''инженерн'':36B ''каскад'':1A,4B ''кв'':18B ''класс'':9B ''корт'':35B,71C ''кр'':50B,76C ''красот'':2A,5B ''м'':19B ''общ'':15B ''овик'':51B,77C ''пз'':53B,79C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''премиум'':10B,87C ''продуктов'':26B,62C ''проект'':3B,21B,56B ''систем'':37B ''след'':23B ''соб'':7B ''соуэ'':46B,72C ''статус'':58B ''стоимост'':55B ''супермаркет'':27B,63C ''техник'':31B,67C ''тх'':52B,78C ''удобств'':24B ''фуд'':34B,70C ''фуд-корт'':33B,69C ''э'':54B,80C ''электричеств'':42B ''электроник'':28B,64C ''этаж'':13B');
INSERT INTO stroy.project VALUES (87, 'Лабиринт Люкса', 33, 58, '{80}', 35098742, '2023-08-22', 'В работе', 'Проект "Лабиринт Люкса" представляет собой здание класса B с 12 этажами и общей площадью 124481 кв.м. В проекте предусмотрены следующие удобства: круглосуточная охрана, банкоматы, детская комната, переговорные комнаты, бизнес-центр, отделение банка, зарядные станции для электромобилей, пропускная система, паркинг для посетителей. Инженерные системы: газ - есть, вода - есть, электричество - 380 В. Документация: СС, ОВиК, АПС, ГС, СОУЭ, ТХ, АР, ПЗ, ЭОМ. Стоимость проекта: 35098742, статус: В работе.', '{"floors": 12, "amenities": ["круглосуточная охрана", "банкоматы", "детская комната", "переговорные комнаты", "бизнес-центр", "отделение банка", "зарядные станции для электромобилей", "пропускная система", "паркинг для посетителей"], "documents": ["СС", "ОВиК", "АПС", "ГС", "СОУЭ", "ТХ", "АР", "ПЗ", "ЭОМ"], "engineering": {"gas": true, "water": true, "electricity": 380}, "building_class": "B", "total_area_sqm": 124481}', '''12'':12B,71C ''124481'':17B,109C ''35098742'':67B ''380'':53B,107C ''b'':10B,108C ''electr'':106C ''gas'':102C ''true'':103C,105C ''water'':104C ''апс'':58B,95C ''ар'':62B,99C ''банк'':36B,83C ''банкомат'':27B,74C ''бизнес'':33B,80C ''бизнес-центр'':32B,79C ''вод'':50B ''газ'':48B ''гс'':59B,96C ''детск'':28B,75C ''документац'':55B ''зарядн'':37B,84C ''здан'':8B ''инженерн'':46B ''кв'':18B ''класс'':9B ''комнат'':29B,31B,76C,78C ''круглосуточн'':25B,72C ''лабиринт'':1A,4B ''люкс'':2A,5B ''м'':19B ''общ'':15B ''овик'':57B,94C ''отделен'':35B,82C ''охра'':26B,73C ''паркинг'':43B,90C ''переговорн'':30B,77C ''пз'':63B,100C ''площад'':16B ''посетител'':45B,92C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,66B ''пропускн'':41B,88C ''работ'':70B ''систем'':42B,47B,89C ''след'':23B ''соб'':7B ''соуэ'':60B,97C ''сс'':56B,93C ''станц'':38B,85C ''статус'':68B ''стоимост'':65B ''тх'':61B,98C ''удобств'':24B ''центр'':34B,81C ''э'':64B,101C ''электричеств'':52B ''электромобил'':40B,87C ''этаж'':13B');
INSERT INTO stroy.project VALUES (88, 'Арена Амбиций', 258, 18, '{79,19,72,67,11,51,71}', 35098742, '2023-08-22', 'Завершен', 'Проект "Арена Амбиций" представляет собой здание класса Комфорт с 23 этажами и общей площадью 111280 кв.м. В проекте предусмотрены следующие удобства: прачечная, бесплатный Wi-Fi, спа-центр, игровая зона для детей, детская комната, кофейня, Фуд-корт, зона ожидания с мягкой мебелью. Инженерные системы: газ - есть, вода - есть, электричество - 380 В. Документация: АР, ГС, ЭОМ, ПЗ, СОУЭ, КР, ТХ, АПС, ОВиК. Стоимость проекта: 35098742, статус: Завершен.', '{"floors": 23, "amenities": ["прачечная", "бесплатный Wi-Fi", "спа-центр", "игровая зона для детей", "детская комната", "кофейня", "Фуд-корт", "зона ожидания с мягкой мебелью"], "documents": ["АР", "ГС", "ЭОМ", "ПЗ", "СОУЭ", "КР", "ТХ", "АПС", "ОВиК"], "engineering": {"gas": true, "water": true, "electricity": 380}, "building_class": "Комфорт", "total_area_sqm": 111280}', '''111280'':17B,112C ''23'':12B,72C ''35098742'':69B ''380'':55B,110C ''electr'':109C ''fi'':29B,77C ''gas'':105C ''true'':106C,108C ''water'':107C ''wi'':28B,76C ''wi-fi'':27B,75C ''амбиц'':2A,5B ''апс'':65B,103C ''ар'':1A,4B,58B,96C ''бесплатн'':26B,74C ''вод'':52B ''газ'':50B ''гс'':59B,97C ''дет'':36B,84C ''детск'':37B,85C ''документац'':57B ''заверш'':71B ''здан'':8B ''зон'':34B,43B,82C,91C ''игров'':33B,81C ''инженерн'':48B ''кв'':18B ''класс'':9B ''комнат'':38B,86C ''комфорт'':10B,111C ''корт'':42B,90C ''кофейн'':39B,87C ''кр'':63B,101C ''м'':19B ''мебел'':47B,95C ''мягк'':46B,94C ''общ'':15B ''овик'':66B,104C ''ожидан'':44B,92C ''пз'':61B,99C ''площад'':16B ''прачечн'':25B,73C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,68B ''систем'':49B ''след'':23B ''соб'':7B ''соуэ'':62B,100C ''спа'':31B,79C ''спа-центр'':30B,78C ''статус'':70B ''стоимост'':67B ''тх'':64B,102C ''удобств'':24B ''фуд'':41B,89C ''фуд-корт'':40B,88C ''центр'':32B,80C ''э'':60B,98C ''электричеств'':54B ''этаж'':13B');
INSERT INTO stroy.project VALUES (89, 'Башня Благосостояния', 179, 8, '{53,18,32,66,36,16,15,6,4,65}', 17814804, '2024-01-17', 'Отменен', 'Проект "Башня Благосостояния" представляет собой здание класса C с 11 этажами и общей площадью 29420 кв.м. В проекте предусмотрены следующие удобства: переговорные комнаты, бесплатный Wi-Fi, коворкинг, аптека, прачечная. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: ТХ, ОВиК, ЭОМ, АПС, ПЗ. Стоимость проекта: 17814804, статус: Отменен.', '{"floors": 11, "amenities": ["переговорные комнаты", "бесплатный Wi-Fi", "коворкинг", "аптека", "прачечная"], "documents": ["ТХ", "ОВиК", "ЭОМ", "АПС", "ПЗ"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "C", "total_area_sqm": 29420}', '''11'':12B,54C ''17814804'':51B ''29420'':17B,76C ''380'':41B,74C ''c'':10B,75C ''electr'':73C ''fals'':70C,72C ''fi'':30B,60C ''gas'':69C ''water'':71C ''wi'':29B,59C ''wi-fi'':28B,58C ''апс'':47B,67C ''аптек'':32B,62C ''башн'':1A,4B ''бесплатн'':27B,57C ''благосостоян'':2A,5B ''вод'':38B ''газ'':36B ''документац'':43B ''здан'':8B ''инженерн'':34B ''кв'':18B ''класс'':9B ''коворкинг'':31B,61C ''комнат'':26B,56C ''м'':19B ''общ'':15B ''овик'':45B,65C ''отмен'':53B ''отсутств'':37B,39B ''переговорн'':25B,55C ''пз'':48B,68C ''площад'':16B ''прачечн'':33B,63C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,50B ''систем'':35B ''след'':23B ''соб'':7B ''статус'':52B ''стоимост'':49B ''тх'':44B,64C ''удобств'':24B ''э'':46B,66C ''электричеств'':40B ''этаж'':13B');
INSERT INTO stroy.project VALUES (90, 'Венец Вдохновения', 98, 1, '{43,70,39}', 20283938, '2022-03-26', 'Отменен', 'Проект "Венец Вдохновения" представляет собой здание класса А с 16 этажами и общей площадью 105028 кв.м. В проекте предусмотрены следующие удобства: зарядные станции для электромобилей, продуктовый супермаркет, пропускная система. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: ОВиК, ЭОМ, СОУЭ, АР, ТХ, АПС. Стоимость проекта: 20283938, статус: Отменен.', '{"floors": 16, "amenities": ["зарядные станции для электромобилей", "продуктовый супермаркет", "пропускная система"], "documents": ["ОВиК", "ЭОМ", "СОУЭ", "АР", "ТХ", "АПС"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "А", "total_area_sqm": 105028}', '''105028'':17B,76C ''16'':12B,54C ''20283938'':51B ''220'':40B,74C ''electr'':73C ''fals'':72C ''gas'':69C ''true'':70C ''water'':71C ''апс'':48B,68C ''ар'':46B,66C ''вдохновен'':2A,5B ''венец'':1A,4B ''вод'':37B ''газ'':35B ''документац'':42B ''зарядн'':25B,55C ''здан'':8B ''инженерн'':33B ''кв'':18B ''класс'':9B ''м'':19B ''общ'':15B ''овик'':43B,63C ''отмен'':53B ''отсутств'':38B ''площад'':16B ''представля'':6B ''предусмотр'':22B ''продуктов'':29B,59C ''проект'':3B,21B,50B ''пропускн'':31B,61C ''систем'':32B,34B,62C ''след'':23B ''соб'':7B ''соуэ'':45B,65C ''станц'':26B,56C ''статус'':52B ''стоимост'':49B ''супермаркет'':30B,60C ''тх'':47B,67C ''удобств'':24B ''э'':44B,64C ''электричеств'':39B ''электромобил'':28B,58C ''этаж'':13B');
INSERT INTO stroy.project VALUES (91, 'Галерея Грандиозности', 253, 8, '{70,14,40,43,58,49}', 30160474, '2023-04-02', 'Отменен', 'Проект "Галерея Грандиозности" представляет собой здание класса B с 9 этажами и общей площадью 131320 кв.м. В проекте предусмотрены следующие удобства: Фуд-корт, велопарковка, видеонаблюдение. Инженерные системы: газ - отсутствует, вода - есть, электричество - 380 В. Документация: КР, СС, ГС, ЭОМ, ОВиК, ПЗ, СОУЭ, ТХ. Стоимость проекта: 30160474, статус: Отменен.', '{"floors": 9, "amenities": ["Фуд-корт", "велопарковка", "видеонаблюдение"], "documents": ["КР", "СС", "ГС", "ЭОМ", "ОВиК", "ПЗ", "СОУЭ", "ТХ"], "engineering": {"gas": false, "water": true, "electricity": 380}, "building_class": "B", "total_area_sqm": 131320}', '''131320'':17B,74C ''30160474'':50B ''380'':37B,72C ''9'':12B,53C ''b'':10B,73C ''electr'':71C ''fals'':68C ''gas'':67C ''true'':70C ''water'':69C ''велопарковк'':28B,57C ''видеонаблюден'':29B,58C ''вод'':34B ''газ'':32B ''галере'':1A,4B ''грандиозн'':2A,5B ''гс'':42B,61C ''документац'':39B ''здан'':8B ''инженерн'':30B ''кв'':18B ''класс'':9B ''корт'':27B,56C ''кр'':40B,59C ''м'':19B ''общ'':15B ''овик'':44B,63C ''отмен'':52B ''отсутств'':33B ''пз'':45B,64C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,49B ''систем'':31B ''след'':23B ''соб'':7B ''соуэ'':46B,65C ''сс'':41B,60C ''статус'':51B ''стоимост'':48B ''тх'':47B,66C ''удобств'':24B ''фуд'':26B,55C ''фуд-корт'':25B,54C ''э'':43B,62C ''электричеств'':36B ''этаж'':13B');
INSERT INTO stroy.project VALUES (92, 'Династия Дизайна', 223, 30, '{7,62,32,75,80,23,40}', 9172835, '2023-06-26', 'В работе', 'Проект "Династия Дизайна" представляет собой здание класса Комфорт с 10 этажами и общей площадью 79126 кв.м. В проекте предусмотрены следующие удобства: спа-центр, видеонаблюдение, круглосуточная охрана, конференц-залы, отделение банка, выставочный зал. Инженерные системы: газ - отсутствует, вода - есть, электричество - 380 В. Документация: ГС, ЭОМ, ОВиК, СС, АР, АПС, ТХ, КР. Стоимость проекта: 9172835, статус: В работе.', '{"floors": 10, "amenities": ["спа-центр", "видеонаблюдение", "круглосуточная охрана", "конференц-залы", "отделение банка", "выставочный зал"], "documents": ["ГС", "ЭОМ", "ОВиК", "СС", "АР", "АПС", "ТХ", "КР"], "engineering": {"gas": false, "water": true, "electricity": 380}, "building_class": "Комфорт", "total_area_sqm": 79126}', '''10'':12B,62C ''380'':45B,89C ''79126'':17B,91C ''9172835'':58B ''electr'':88C ''fals'':85C ''gas'':84C ''true'':87C ''water'':86C ''апс'':53B,81C ''ар'':52B,80C ''банк'':35B,73C ''видеонаблюден'':28B,66C ''вод'':42B ''выставочн'':36B,74C ''газ'':40B ''гс'':48B,76C ''дизайн'':2A,5B ''династ'':1A,4B ''документац'':47B ''зал'':33B,37B,71C,75C ''здан'':8B ''инженерн'':38B ''кв'':18B ''класс'':9B ''комфорт'':10B,90C ''конференц'':32B,70C ''конференц-зал'':31B,69C ''кр'':55B,83C ''круглосуточн'':29B,67C ''м'':19B ''общ'':15B ''овик'':50B,78C ''отделен'':34B,72C ''отсутств'':41B ''охра'':30B,68C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,57B ''работ'':61B ''систем'':39B ''след'':23B ''соб'':7B ''спа'':26B,64C ''спа-центр'':25B,63C ''сс'':51B,79C ''статус'':59B ''стоимост'':56B ''тх'':54B,82C ''удобств'':24B ''центр'':27B,65C ''э'':49B,77C ''электричеств'':44B ''этаж'':13B');
INSERT INTO stroy.project VALUES (93, 'Живописные Жилища', 170, 72, '{32,25,48,75,37}', 10407402, '2022-06-11', 'В работе', 'Проект "Живописные Жилища" представляет собой здание класса А+ с 13 этажами и общей площадью 179492 кв.м. В проекте предусмотрены следующие удобства: бизнес-центр, кофейня, коворкинг, продуктовый супермаркет, видеонаблюдение, аптека. Инженерные системы: газ - есть, вода - есть, электричество - 380 В. Документация: ГС, ЭОМ, ТХ, СС. Стоимость проекта: 10407402, статус: В работе.', '{"floors": 13, "amenities": ["бизнес-центр", "кофейня", "коворкинг", "продуктовый супермаркет", "видеонаблюдение", "аптека"], "documents": ["ГС", "ЭОМ", "ТХ", "СС"], "engineering": {"gas": true, "water": true, "electricity": 380}, "building_class": "А+", "total_area_sqm": 179492}', '''10407402'':50B ''13'':12B,54C ''179492'':17B,75C ''380'':41B,73C ''electr'':72C ''gas'':68C ''true'':69C,71C ''water'':70C ''аптек'':33B,63C ''бизнес'':26B,56C ''бизнес-центр'':25B,55C ''видеонаблюден'':32B,62C ''вод'':38B ''газ'':36B ''гс'':44B,64C ''документац'':43B ''живописн'':1A,4B ''жилищ'':2A,5B ''здан'':8B ''инженерн'':34B ''кв'':18B ''класс'':9B ''коворкинг'':29B,59C ''кофейн'':28B,58C ''м'':19B ''общ'':15B ''площад'':16B ''представля'':6B ''предусмотр'':22B ''продуктов'':30B,60C ''проект'':3B,21B,49B ''работ'':53B ''систем'':35B ''след'':23B ''соб'':7B ''сс'':47B,67C ''статус'':51B ''стоимост'':48B ''супермаркет'':31B,61C ''тх'':46B,66C ''удобств'':24B ''центр'':27B,57C ''э'':45B,65C ''электричеств'':40B ''этаж'':13B');
INSERT INTO stroy.project VALUES (94, 'Залог Затишья', 30, 56, '{80}', 15345670, '2022-06-23', 'Завершен', 'Проект "Залог Затишья" представляет собой здание класса B+ с 17 этажами и общей площадью 190615 кв.м. В проекте предусмотрены следующие удобства: пропускная система, круглосуточная охрана, зарядные станции для электромобилей, выставочный зал. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: ТХ, СС, ПЗ. Стоимость проекта: 15345670, статус: Завершен.', '{"floors": 17, "amenities": ["пропускная система", "круглосуточная охрана", "зарядные станции для электромобилей", "выставочный зал"], "documents": ["ТХ", "СС", "ПЗ"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "B+", "total_area_sqm": 190615}', '''15345670'':50B ''17'':12B,53C ''190615'':17B,74C ''220'':42B,72C ''b'':10B,73C ''electr'':71C ''fals'':70C ''gas'':67C ''true'':68C ''water'':69C ''вод'':39B ''выставочн'':33B,62C ''газ'':37B ''документац'':44B ''заверш'':52B ''зал'':34B,63C ''залог'':1A,4B ''зарядн'':29B,58C ''затиш'':2A,5B ''здан'':8B ''инженерн'':35B ''кв'':18B ''класс'':9B ''круглосуточн'':27B,56C ''м'':19B ''общ'':15B ''отсутств'':40B ''охра'':28B,57C ''пз'':47B,66C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,49B ''пропускн'':25B,54C ''систем'':26B,36B,55C ''след'':23B ''соб'':7B ''сс'':46B,65C ''станц'':30B,59C ''статус'':51B ''стоимост'':48B ''тх'':45B,64C ''удобств'':24B ''электричеств'':41B ''электромобил'':32B,61C ''этаж'':13B');
INSERT INTO stroy.project VALUES (95, 'Источник Идей', 80, 33, '{71,49,75,59,17,39,33,30}', 17814804, '2022-10-15', 'Завершен', 'Проект "Источник Идей" представляет собой здание класса Премиум с 8 этажами и общей площадью 42041 кв.м. В проекте предусмотрены следующие удобства: продуктовый супермаркет, детская комната, пропускная система, бизнес-центр. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: КР, ЭОМ, СОУЭ, ГС, АР, АПС, ОВиК, ТХ. Стоимость проекта: 17814804, статус: Завершен.', '{"floors": 8, "amenities": ["продуктовый супермаркет", "детская комната", "пропускная система", "бизнес-центр"], "documents": ["КР", "ЭОМ", "СОУЭ", "ГС", "АР", "АПС", "ОВиК", "ТХ"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "Премиум", "total_area_sqm": 42041}', '''17814804'':54B ''220'':41B,80C ''42041'':17B,82C ''8'':12B,57C ''electr'':79C ''fals'':76C ''gas'':75C ''true'':78C ''water'':77C ''апс'':49B,72C ''ар'':48B,71C ''бизнес'':32B,65C ''бизнес-центр'':31B,64C ''вод'':38B ''газ'':36B ''гс'':47B,70C ''детск'':27B,60C ''документац'':43B ''заверш'':56B ''здан'':8B ''ид'':2A,5B ''инженерн'':34B ''источник'':1A,4B ''кв'':18B ''класс'':9B ''комнат'':28B,61C ''кр'':44B,67C ''м'':19B ''общ'':15B ''овик'':50B,73C ''отсутств'':37B ''площад'':16B ''представля'':6B ''предусмотр'':22B ''премиум'':10B,81C ''продуктов'':25B,58C ''проект'':3B,21B,53B ''пропускн'':29B,62C ''систем'':30B,35B,63C ''след'':23B ''соб'':7B ''соуэ'':46B,69C ''статус'':55B ''стоимост'':52B ''супермаркет'':26B,59C ''тх'':51B,74C ''удобств'':24B ''центр'':33B,66C ''э'':45B,68C ''электричеств'':40B ''этаж'':13B');
INSERT INTO stroy.project VALUES (96, 'Колыбель Культуры', 136, 75, '{36,31,38,35,63,73,52,75}', 15345670, '2022-11-16', 'В работе', 'Проект "Колыбель Культуры" представляет собой здание класса Премиум с 19 этажами и общей площадью 23947 кв.м. В проекте предусмотрены следующие удобства: велопарковка, видеонаблюдение, детская комната, зона ожидания с мягкой мебелью, подземный паркинг, магазины одежды и обуви. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: ОВиК, ГС, АПС, СОУЭ, СС, АР, ТХ, КР, ЭОМ. Стоимость проекта: 15345670, статус: В работе.', '{"floors": 19, "amenities": ["велопарковка", "видеонаблюдение", "детская комната", "зона ожидания с мягкой мебелью", "подземный паркинг", "магазины одежды и обуви"], "documents": ["ОВиК", "ГС", "АПС", "СОУЭ", "СС", "АР", "ТХ", "КР", "ЭОМ"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "Премиум", "total_area_sqm": 23947}', '''15345670'':61B ''19'':12B,65C ''220'':47B,95C ''23947'':17B,97C ''electr'':94C ''fals'':91C,93C ''gas'':90C ''water'':92C ''апс'':52B,83C ''ар'':55B,86C ''велопарковк'':25B,66C ''видеонаблюден'':26B,67C ''вод'':44B ''газ'':42B ''гс'':51B,82C ''детск'':27B,68C ''документац'':49B ''здан'':8B ''зон'':29B,70C ''инженерн'':40B ''кв'':18B ''класс'':9B ''колыбел'':1A,4B ''комнат'':28B,69C ''кр'':57B,88C ''культур'':2A,5B ''м'':19B ''магазин'':36B,77C ''мебел'':33B,74C ''мягк'':32B,73C ''обув'':39B,80C ''общ'':15B ''овик'':50B,81C ''одежд'':37B,78C ''ожидан'':30B,71C ''отсутств'':43B,45B ''паркинг'':35B,76C ''площад'':16B ''подземн'':34B,75C ''представля'':6B ''предусмотр'':22B ''премиум'':10B,96C ''проект'':3B,21B,60B ''работ'':64B ''систем'':41B ''след'':23B ''соб'':7B ''соуэ'':53B,84C ''сс'':54B,85C ''статус'':62B ''стоимост'':59B ''тх'':56B,87C ''удобств'':24B ''э'':58B,89C ''электричеств'':46B ''этаж'':13B');
INSERT INTO stroy.project VALUES (97, 'Лаборатория Ландшафта', 167, 16, '{40,65,13,70,1}', 20283938, '2022-11-08', 'В работе', 'Проект "Лаборатория Ландшафта" представляет собой здание класса Эконом с 13 этажами и общей площадью 116457 кв.м. В проекте предусмотрены следующие удобства: салоны красоты, банкоматы, аптека, рестораны и кафе, конференц-залы, прачечная, переговорные комнаты. Инженерные системы: газ - есть, вода - есть, электричество - 220 В. Документация: ЭОМ, ОВиК, АПС, ТХ. Стоимость проекта: 20283938, статус: В работе.', '{"floors": 13, "amenities": ["салоны красоты", "банкоматы", "аптека", "рестораны и кафе", "конференц-залы", "прачечная", "переговорные комнаты"], "documents": ["ЭОМ", "ОВиК", "АПС", "ТХ"], "engineering": {"gas": true, "water": true, "electricity": 220}, "building_class": "Эконом", "total_area_sqm": 116457}', '''116457'':17B,83C ''13'':12B,58C ''20283938'':54B ''220'':45B,81C ''electr'':80C ''gas'':76C ''true'':77C,79C ''water'':78C ''апс'':50B,74C ''аптек'':28B,62C ''банкомат'':27B,61C ''вод'':42B ''газ'':40B ''документац'':47B ''зал'':34B,68C ''здан'':8B ''инженерн'':38B ''каф'':31B,65C ''кв'':18B ''класс'':9B ''комнат'':37B,71C ''конференц'':33B,67C ''конференц-зал'':32B,66C ''красот'':26B,60C ''лаборатор'':1A,4B ''ландшафт'':2A,5B ''м'':19B ''общ'':15B ''овик'':49B,73C ''переговорн'':36B,70C ''площад'':16B ''прачечн'':35B,69C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,53B ''работ'':57B ''рестора'':29B,63C ''салон'':25B,59C ''систем'':39B ''след'':23B ''соб'':7B ''статус'':55B ''стоимост'':52B ''тх'':51B,75C ''удобств'':24B ''э'':48B,72C ''экон'':10B,82C ''электричеств'':44B ''этаж'':13B');
INSERT INTO stroy.project VALUES (98, 'Маяк Мастерства', 69, 58, '{23,17}', 12876536, '2022-12-24', 'Отменен', 'Проект "Маяк Мастерства" представляет собой здание класса B с 19 этажами и общей площадью 63960 кв.м. В проекте предусмотрены следующие удобства: переговорные комнаты, зарядные станции для электромобилей, круглосуточная охрана. Инженерные системы: газ - есть, вода - есть, электричество - 220 В. Документация: ТХ, ОВиК, АПС, ЭОМ, КР, СС, АР. Стоимость проекта: 12876536, статус: Отменен.', '{"floors": 19, "amenities": ["переговорные комнаты", "зарядные станции для электромобилей", "круглосуточная охрана"], "documents": ["ТХ", "ОВиК", "АПС", "ЭОМ", "КР", "СС", "АР"], "engineering": {"gas": true, "water": true, "electricity": 220}, "building_class": "B", "total_area_sqm": 63960}', '''12876536'':52B ''19'':12B,55C ''220'':40B,76C ''63960'':17B,78C ''b'':10B,77C ''electr'':75C ''gas'':71C ''true'':72C,74C ''water'':73C ''апс'':45B,66C ''ар'':49B,70C ''вод'':37B ''газ'':35B ''документац'':42B ''зарядн'':27B,58C ''здан'':8B ''инженерн'':33B ''кв'':18B ''класс'':9B ''комнат'':26B,57C ''кр'':47B,68C ''круглосуточн'':31B,62C ''м'':19B ''мастерств'':2A,5B ''маяк'':1A,4B ''общ'':15B ''овик'':44B,65C ''отмен'':54B ''охра'':32B,63C ''переговорн'':25B,56C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,51B ''систем'':34B ''след'':23B ''соб'':7B ''сс'':48B,69C ''станц'':28B,59C ''статус'':53B ''стоимост'':50B ''тх'':43B,64C ''удобств'':24B ''э'':46B,67C ''электричеств'':39B ''электромобил'':30B,61C ''этаж'':13B');
INSERT INTO stroy.project VALUES (99, 'Небосвод Новаторства', 15, 14, '{23,18,55,24,41,64,21}', 26456773, '2023-02-11', 'На подписании', 'Проект "Небосвод Новаторства" представляет собой здание класса C с 11 этажами и общей площадью 178622 кв.м. В проекте предусмотрены следующие удобства: детская комната, велопарковка, переговорные комнаты, рестораны и кафе, бизнес-центр, пропускная система, выставочный зал, банкоматы. Инженерные системы: газ - отсутствует, вода - есть, электричество - 380 В. Документация: ПЗ, ТХ, АР, СС. Стоимость проекта: 26456773, статус: На подписании.', '{"floors": 11, "amenities": ["детская комната", "велопарковка", "переговорные комнаты", "рестораны и кафе", "бизнес-центр", "пропускная система", "выставочный зал", "банкоматы"], "documents": ["ПЗ", "ТХ", "АР", "СС"], "engineering": {"gas": false, "water": true, "electricity": 380}, "building_class": "C", "total_area_sqm": 178622}', '''11'':12B,61C ''178622'':17B,89C ''26456773'':57B ''380'':48B,87C ''c'':10B,88C ''electr'':86C ''fals'':83C ''gas'':82C ''true'':85C ''water'':84C ''ар'':53B,80C ''банкомат'':40B,77C ''бизнес'':34B,71C ''бизнес-центр'':33B,70C ''велопарковк'':27B,64C ''вод'':45B ''выставочн'':38B,75C ''газ'':43B ''детск'':25B,62C ''документац'':50B ''зал'':39B,76C ''здан'':8B ''инженерн'':41B ''каф'':32B,69C ''кв'':18B ''класс'':9B ''комнат'':26B,29B,63C,66C ''м'':19B ''небосвод'':1A,4B ''новаторств'':2A,5B ''общ'':15B ''отсутств'':44B ''переговорн'':28B,65C ''пз'':51B,78C ''площад'':16B ''подписан'':60B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,56B ''пропускн'':36B,73C ''рестора'':30B,67C ''систем'':37B,42B,74C ''след'':23B ''соб'':7B ''сс'':54B,81C ''статус'':58B ''стоимост'':55B ''тх'':52B,79C ''удобств'':24B ''центр'':35B,72C ''электричеств'':47B ''этаж'':13B');
INSERT INTO stroy.project VALUES (100, 'Оазис Оптимизма', 49, 1, '{70,79,26,27,2,80,61,53,34,33}', 11641969, '2023-03-27', 'В работе', 'Проект "Оазис Оптимизма" представляет собой здание класса D с 22 этажами и общей площадью 87797 кв.м. В проекте предусмотрены следующие удобства: детская комната, аптека, магазины одежды и обуви, кофейня, велопарковка. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: КР, ОВиК, АПС, СС, ПЗ, ГС. Стоимость проекта: 11641969, статус: В работе.', '{"floors": 22, "amenities": ["детская комната", "аптека", "магазины одежды и обуви", "кофейня", "велопарковка"], "documents": ["КР", "ОВиК", "АПС", "СС", "ПЗ", "ГС"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "D", "total_area_sqm": 87797}', '''11641969'':52B ''22'':12B,56C ''220'':41B,77C ''87797'':17B,79C ''d'':10B,78C ''electr'':76C ''fals'':75C ''gas'':72C ''true'':73C ''water'':74C ''апс'':46B,68C ''аптек'':27B,59C ''велопарковк'':33B,65C ''вод'':38B ''газ'':36B ''гс'':49B,71C ''детск'':25B,57C ''документац'':43B ''здан'':8B ''инженерн'':34B ''кв'':18B ''класс'':9B ''комнат'':26B,58C ''кофейн'':32B,64C ''кр'':44B,66C ''м'':19B ''магазин'':28B,60C ''оазис'':1A,4B ''обув'':31B,63C ''общ'':15B ''овик'':45B,67C ''одежд'':29B,61C ''оптимизм'':2A,5B ''отсутств'':39B ''пз'':48B,70C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,51B ''работ'':55B ''систем'':35B ''след'':23B ''соб'':7B ''сс'':47B,69C ''статус'':53B ''стоимост'':50B ''удобств'':24B ''электричеств'':40B ''этаж'':13B');
INSERT INTO stroy.project VALUES (101, 'Панорама Перспектив', 179, 53, '{41,32,37,43}', 32629608, '2024-01-14', 'Отменен', 'Проект "Панорама Перспектив" представляет собой здание класса Эконом с 19 этажами и общей площадью 139250 кв.м. В проекте предусмотрены следующие удобства: спа-центр, переговорные комнаты, кофейня, зона ожидания с мягкой мебелью. Инженерные системы: газ - отсутствует, вода - есть, электричество - 380 В. Документация: ПЗ, СОУЭ, ГС, ОВиК, АР, АПС, СС, ТХ. Стоимость проекта: 32629608, статус: Отменен.', '{"floors": 19, "amenities": ["спа-центр", "переговорные комнаты", "кофейня", "зона ожидания с мягкой мебелью"], "documents": ["ПЗ", "СОУЭ", "ГС", "ОВиК", "АР", "АПС", "СС", "ТХ"], "engineering": {"gas": false, "water": true, "electricity": 380}, "building_class": "Эконом", "total_area_sqm": 139250}', '''139250'':17B,86C ''19'':12B,59C ''32629608'':56B ''380'':43B,84C ''electr'':83C ''fals'':80C ''gas'':79C ''true'':82C ''water'':81C ''апс'':51B,76C ''ар'':50B,75C ''вод'':40B ''газ'':38B ''гс'':48B,73C ''документац'':45B ''здан'':8B ''зон'':31B,66C ''инженерн'':36B ''кв'':18B ''класс'':9B ''комнат'':29B,64C ''кофейн'':30B,65C ''м'':19B ''мебел'':35B,70C ''мягк'':34B,69C ''общ'':15B ''овик'':49B,74C ''ожидан'':32B,67C ''отмен'':58B ''отсутств'':39B ''панорам'':1A,4B ''переговорн'':28B,63C ''перспект'':2A,5B ''пз'':46B,71C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,55B ''систем'':37B ''след'':23B ''соб'':7B ''соуэ'':47B,72C ''спа'':26B,61C ''спа-центр'':25B,60C ''сс'':52B,77C ''статус'':57B ''стоимост'':54B ''тх'':53B,78C ''удобств'':24B ''центр'':27B,62C ''экон'':10B,85C ''электричеств'':42B ''этаж'':13B');
INSERT INTO stroy.project VALUES (102, 'Резиденция Роскоши', 68, 2, '{22,17,79,10,71,3,45,76,50,75,26}', 9172835, '2022-06-27', 'В работе', 'Проект "Резиденция Роскоши" представляет собой здание класса Эконом с 15 этажами и общей площадью 143768 кв.м. В проекте предусмотрены следующие удобства: пропускная система, подземный паркинг, отделение банка, салоны красоты, коворкинг, бизнес-центр, кофейня. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: АР, ЭОМ, СС, ГС, СОУЭ, ПЗ. Стоимость проекта: 9172835, статус: В работе.', '{"floors": 15, "amenities": ["пропускная система", "подземный паркинг", "отделение банка", "салоны красоты", "коворкинг", "бизнес-центр", "кофейня"], "documents": ["АР", "ЭОМ", "СС", "ГС", "СОУЭ", "ПЗ"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "Эконом", "total_area_sqm": 143768}', '''143768'':17B,87C ''15'':12B,60C ''220'':45B,85C ''9172835'':56B ''electr'':84C ''fals'':81C ''gas'':80C ''true'':83C ''water'':82C ''ар'':48B,74C ''банк'':30B,66C ''бизнес'':35B,71C ''бизнес-центр'':34B,70C ''вод'':42B ''газ'':40B ''гс'':51B,77C ''документац'':47B ''здан'':8B ''инженерн'':38B ''кв'':18B ''класс'':9B ''коворкинг'':33B,69C ''кофейн'':37B,73C ''красот'':32B,68C ''м'':19B ''общ'':15B ''отделен'':29B,65C ''отсутств'':41B ''паркинг'':28B,64C ''пз'':53B,79C ''площад'':16B ''подземн'':27B,63C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,55B ''пропускн'':25B,61C ''работ'':59B ''резиденц'':1A,4B ''роскош'':2A,5B ''салон'':31B,67C ''систем'':26B,39B,62C ''след'':23B ''соб'':7B ''соуэ'':52B,78C ''сс'':50B,76C ''статус'':57B ''стоимост'':54B ''удобств'':24B ''центр'':36B,72C ''э'':49B,75C ''экон'':10B,86C ''электричеств'':44B ''этаж'':13B');
INSERT INTO stroy.project VALUES (103, 'Сады Стабильности', 253, 3, '{73,5,51,27,77,69,7}', 7938268, '2022-09-25', 'В работе', 'Проект "Сады Стабильности" представляет собой здание класса А с 6 этажами и общей площадью 109833 кв.м. В проекте предусмотрены следующие удобства: продуктовый супермаркет, аптека, система климат-контроля, рестораны и кафе, зона ожидания с мягкой мебелью. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: ОВиК, КР, СОУЭ, ТХ, АПС, ГС, ПЗ, СС. Стоимость проекта: 7938268, статус: В работе.', '{"floors": 6, "amenities": ["продуктовый супермаркет", "аптека", "система климат-контроля", "рестораны и кафе", "зона ожидания с мягкой мебелью"], "documents": ["ОВиК", "КР", "СОУЭ", "ТХ", "АПС", "ГС", "ПЗ", "СС"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "А", "total_area_sqm": 109833}', '''109833'':17B,95C ''380'':47B,93C ''6'':12B,64C ''7938268'':60B ''electr'':92C ''fals'':91C ''gas'':88C ''true'':89C ''water'':90C ''апс'':54B,84C ''аптек'':27B,67C ''вод'':44B ''газ'':42B ''гс'':55B,85C ''документац'':49B ''здан'':8B ''зон'':35B,75C ''инженерн'':40B ''каф'':34B,74C ''кв'':18B ''класс'':9B ''климат'':30B,70C ''климат-контрол'':29B,69C ''контрол'':31B,71C ''кр'':51B,81C ''м'':19B ''мебел'':39B,79C ''мягк'':38B,78C ''общ'':15B ''овик'':50B,80C ''ожидан'':36B,76C ''отсутств'':45B ''пз'':56B,86C ''площад'':16B ''представля'':6B ''предусмотр'':22B ''продуктов'':25B,65C ''проект'':3B,21B,59B ''работ'':63B ''рестора'':32B,72C ''сад'':1A,4B ''систем'':28B,41B,68C ''след'':23B ''соб'':7B ''соуэ'':52B,82C ''сс'':57B,87C ''стабильн'':2A,5B ''статус'':61B ''стоимост'':58B ''супермаркет'':26B,66C ''тх'':53B,83C ''удобств'':24B ''электричеств'':46B ''этаж'':13B');
INSERT INTO stroy.project VALUES (104, 'Террасы Творчества', 49, 79, '{33,19,46,43,56}', 15345670, '2023-03-10', 'На подписании', 'Проект "Террасы Творчества" представляет собой здание класса D с 20 этажами и общей площадью 12742 кв.м. В проекте предусмотрены следующие удобства: пропускная система, кофейня, химчистка, продуктовый супермаркет. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 380 В. Документация: СОУЭ, ТХ, СС. Стоимость проекта: 15345670, статус: На подписании.', '{"floors": 20, "amenities": ["пропускная система", "кофейня", "химчистка", "продуктовый супермаркет"], "documents": ["СОУЭ", "ТХ", "СС"], "engineering": {"gas": false, "water": false, "electricity": 380}, "building_class": "D", "total_area_sqm": 12742}', '''12742'':17B,67C ''15345670'':46B ''20'':12B,50C ''380'':38B,65C ''d'':10B,66C ''electr'':64C ''fals'':61C,63C ''gas'':60C ''water'':62C ''вод'':35B ''газ'':33B ''документац'':40B ''здан'':8B ''инженерн'':31B ''кв'':18B ''класс'':9B ''кофейн'':27B,53C ''м'':19B ''общ'':15B ''отсутств'':34B,36B ''площад'':16B ''подписан'':49B ''представля'':6B ''предусмотр'':22B ''продуктов'':29B,55C ''проект'':3B,21B,45B ''пропускн'':25B,51C ''систем'':26B,32B,52C ''след'':23B ''соб'':7B ''соуэ'':41B,57C ''сс'':43B,59C ''статус'':47B ''стоимост'':44B ''супермаркет'':30B,56C ''творчеств'':2A,5B ''террас'':1A,4B ''тх'':42B,58C ''удобств'':24B ''химчистк'':28B,54C ''электричеств'':37B ''этаж'':13B');
INSERT INTO stroy.project VALUES (105, 'Утопия Успеха', 118, 16, '{71,77,50,68}', 22753072, '2024-01-17', 'Отменен', 'Проект "Утопия Успеха" представляет собой здание класса А с 20 этажами и общей площадью 198112 кв.м. В проекте предусмотрены следующие удобства: рестораны и кафе, электроника и бытовая техника, зона ожидания с мягкой мебелью, салоны красоты, аптека, Фуд-корт. Инженерные системы: газ - есть, вода - отсутствует, электричество - 380 В. Документация: СС, ГС, ТХ. Стоимость проекта: 22753072, статус: Отменен.', '{"floors": 20, "amenities": ["рестораны и кафе", "электроника и бытовая техника", "зона ожидания с мягкой мебелью", "салоны красоты", "аптека", "Фуд-корт"], "documents": ["СС", "ГС", "ТХ"], "engineering": {"gas": true, "water": false, "electricity": 380}, "building_class": "А", "total_area_sqm": 198112}', '''198112'':17B,90C ''20'':12B,61C ''22753072'':58B ''380'':50B,88C ''electr'':87C ''fals'':86C ''gas'':83C ''true'':84C ''water'':85C ''аптек'':39B,76C ''бытов'':30B,67C ''вод'':47B ''газ'':45B ''гс'':54B,81C ''документац'':52B ''здан'':8B ''зон'':32B,69C ''инженерн'':43B ''каф'':27B,64C ''кв'':18B ''класс'':9B ''корт'':42B,79C ''красот'':38B,75C ''м'':19B ''мебел'':36B,73C ''мягк'':35B,72C ''общ'':15B ''ожидан'':33B,70C ''отмен'':60B ''отсутств'':48B ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,57B ''рестора'':25B,62C ''салон'':37B,74C ''систем'':44B ''след'':23B ''соб'':7B ''сс'':53B,80C ''статус'':59B ''стоимост'':56B ''техник'':31B,68C ''тх'':55B,82C ''удобств'':24B ''успех'':2A,5B ''утоп'':1A,4B ''фуд'':41B,78C ''фуд-корт'':40B,77C ''электричеств'':49B ''электроник'':28B,65C ''этаж'':13B');
INSERT INTO stroy.project VALUES (106, 'Форпост Функциональности', 99, 18, '{76,48}', 32629608, '2022-08-23', 'Отменен', 'Проект "Форпост Функциональности" представляет собой здание класса Комфорт с 19 этажами и общей площадью 69677 кв.м. В проекте предусмотрены следующие удобства: прачечная, переговорные комнаты, кофейня, отделение банка, аптека, коворкинг, выставочный зал, бизнес-центр, продуктовый супермаркет. Инженерные системы: газ - отсутствует, вода - есть, электричество - 380 В. Документация: ЭОМ, СОУЭ, ОВиК, СС, АПС. Стоимость проекта: 32629608, статус: Отменен.', '{"floors": 19, "amenities": ["прачечная", "переговорные комнаты", "кофейня", "отделение банка", "аптека", "коворкинг", "выставочный зал", "бизнес-центр", "продуктовый супермаркет"], "documents": ["ЭОМ", "СОУЭ", "ОВиК", "СС", "АПС"], "engineering": {"gas": false, "water": true, "electricity": 380}, "building_class": "Комфорт", "total_area_sqm": 69677}', '''19'':12B,60C ''32629608'':57B ''380'':47B,86C ''69677'':17B,88C ''electr'':85C ''fals'':82C ''gas'':81C ''true'':84C ''water'':83C ''апс'':54B,80C ''аптек'':31B,67C ''банк'':30B,66C ''бизнес'':36B,72C ''бизнес-центр'':35B,71C ''вод'':44B ''выставочн'':33B,69C ''газ'':42B ''документац'':49B ''зал'':34B,70C ''здан'':8B ''инженерн'':40B ''кв'':18B ''класс'':9B ''коворкинг'':32B,68C ''комнат'':27B,63C ''комфорт'':10B,87C ''кофейн'':28B,64C ''м'':19B ''общ'':15B ''овик'':52B,78C ''отделен'':29B,65C ''отмен'':59B ''отсутств'':43B ''переговорн'':26B,62C ''площад'':16B ''прачечн'':25B,61C ''представля'':6B ''предусмотр'':22B ''продуктов'':38B,74C ''проект'':3B,21B,56B ''систем'':41B ''след'':23B ''соб'':7B ''соуэ'':51B,77C ''сс'':53B,79C ''статус'':58B ''стоимост'':55B ''супермаркет'':39B,75C ''удобств'':24B ''форпост'':1A,4B ''функциональн'':2A,5B ''центр'':37B,73C ''э'':50B,76C ''электричеств'':46B ''этаж'':13B');
INSERT INTO stroy.project VALUES (107, 'Хроника Харизмы', 266, 3, '{75,60,43,23,46,13,25}', 15345670, '2023-08-19', 'Отменен', 'Проект "Хроника Харизмы" представляет собой здание класса C с 17 этажами и общей площадью 156211 кв.м. В проекте предусмотрены следующие удобства: подземный паркинг, круглосуточная охрана, прачечная. Инженерные системы: газ - отсутствует, вода - есть, электричество - 220 В. Документация: ЭОМ, АР, СС, КР, ТХ, АПС. Стоимость проекта: 15345670, статус: Отменен.', '{"floors": 17, "amenities": ["подземный паркинг", "круглосуточная охрана", "прачечная"], "documents": ["ЭОМ", "АР", "СС", "КР", "ТХ", "АПС"], "engineering": {"gas": false, "water": true, "electricity": 220}, "building_class": "C", "total_area_sqm": 156211}', '''15345670'':48B ''156211'':17B,70C ''17'':12B,51C ''220'':37B,68C ''c'':10B,69C ''electr'':67C ''fals'':64C ''gas'':63C ''true'':66C ''water'':65C ''апс'':45B,62C ''ар'':41B,58C ''вод'':34B ''газ'':32B ''документац'':39B ''здан'':8B ''инженерн'':30B ''кв'':18B ''класс'':9B ''кр'':43B,60C ''круглосуточн'':27B,54C ''м'':19B ''общ'':15B ''отмен'':50B ''отсутств'':33B ''охра'':28B,55C ''паркинг'':26B,53C ''площад'':16B ''подземн'':25B,52C ''прачечн'':29B,56C ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,47B ''систем'':31B ''след'':23B ''соб'':7B ''сс'':42B,59C ''статус'':49B ''стоимост'':46B ''тх'':44B,61C ''удобств'':24B ''харизм'':2A,5B ''хроник'':1A,4B ''э'':40B,57C ''электричеств'':36B ''этаж'':13B');
INSERT INTO stroy.project VALUES (108, 'Цитадель Чудес', 275, 30, '{55,72,53,5,27,35,30,20,43,60}', 21518505, '2023-08-07', 'На подписании', 'Проект "Цитадель Чудес" представляет собой здание класса B с 18 этажами и общей площадью 27959 кв.м. В проекте предусмотрены следующие удобства: бизнес-центр, игровая зона для детей, зона ожидания с мягкой мебелью. Инженерные системы: газ - отсутствует, вода - есть, электричество - 380 В. Документация: ПЗ, КР, АПС, СОУЭ. Стоимость проекта: 21518505, статус: На подписании.', '{"floors": 18, "amenities": ["бизнес-центр", "игровая зона для детей", "зона ожидания с мягкой мебелью"], "documents": ["ПЗ", "КР", "АПС", "СОУЭ"], "engineering": {"gas": false, "water": true, "electricity": 380}, "building_class": "B", "total_area_sqm": 27959}', '''18'':12B,57C ''21518505'':53B ''27959'':17B,81C ''380'':44B,79C ''b'':10B,80C ''electr'':78C ''fals'':75C ''gas'':74C ''true'':77C ''water'':76C ''апс'':49B,72C ''бизнес'':26B,59C ''бизнес-центр'':25B,58C ''вод'':41B ''газ'':39B ''дет'':31B,64C ''документац'':46B ''здан'':8B ''зон'':29B,32B,62C,65C ''игров'':28B,61C ''инженерн'':37B ''кв'':18B ''класс'':9B ''кр'':48B,71C ''м'':19B ''мебел'':36B,69C ''мягк'':35B,68C ''общ'':15B ''ожидан'':33B,66C ''отсутств'':40B ''пз'':47B,70C ''площад'':16B ''подписан'':56B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,52B ''систем'':38B ''след'':23B ''соб'':7B ''соуэ'':50B,73C ''статус'':54B ''стоимост'':51B ''удобств'':24B ''центр'':27B,60C ''цитадел'':1A,4B ''чудес'':2A,5B ''электричеств'':43B ''этаж'':13B');
INSERT INTO stroy.project VALUES (109, 'Шедевр Штрихов', 116, 30, '{19,8,44,13,78,38,18,32,22,79}', 23987639, '2023-08-22', 'Завершен', 'Проект "Шедевр Штрихов" представляет собой здание класса А с 20 этажами и общей площадью 76135 кв.м. В проекте предусмотрены следующие удобства: салоны красоты, конференц-залы, отделение банка. Инженерные системы: газ - есть, вода - отсутствует, электричество - 220 В. Документация: АПС, СС, ТХ, КР. Стоимость проекта: 23987639, статус: Завершен.', '{"floors": 20, "amenities": ["салоны красоты", "конференц-залы", "отделение банка"], "documents": ["АПС", "СС", "ТХ", "КР"], "engineering": {"gas": true, "water": false, "electricity": 220}, "building_class": "А", "total_area_sqm": 76135}', '''20'':12B,51C ''220'':39B,68C ''23987639'':48B ''76135'':17B,70C ''electr'':67C ''fals'':66C ''gas'':63C ''true'':64C ''water'':65C ''апс'':42B,59C ''банк'':31B,58C ''вод'':36B ''газ'':34B ''документац'':41B ''заверш'':50B ''зал'':29B,56C ''здан'':8B ''инженерн'':32B ''кв'':18B ''класс'':9B ''конференц'':28B,55C ''конференц-зал'':27B,54C ''кр'':45B,62C ''красот'':26B,53C ''м'':19B ''общ'':15B ''отделен'':30B,57C ''отсутств'':37B ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,47B ''салон'':25B,52C ''систем'':33B ''след'':23B ''соб'':7B ''сс'':43B,60C ''статус'':49B ''стоимост'':46B ''тх'':44B,61C ''удобств'':24B ''шедевр'':1A,4B ''штрих'':2A,5B ''электричеств'':38B ''этаж'':13B');
INSERT INTO stroy.project VALUES (110, 'Эдем Элегантности', 242, 33, '{20}', 31395041, '2023-09-18', 'Отменен', 'Проект "Эдем Элегантности" представляет собой здание класса Эконом с 13 этажами и общей площадью 63092 кв.м. В проекте предусмотрены следующие удобства: конференц-залы, электроника и бытовая техника, коворкинг. Инженерные системы: газ - есть, вода - есть, электричество - 380 В. Документация: СС, АР, ТХ, СОУЭ, ЭОМ. Стоимость проекта: 31395041, статус: Отменен.', '{"floors": 13, "amenities": ["конференц-залы", "электроника и бытовая техника", "коворкинг"], "documents": ["СС", "АР", "ТХ", "СОУЭ", "ЭОМ"], "engineering": {"gas": true, "water": true, "electricity": 380}, "building_class": "Эконом", "total_area_sqm": 63092}', '''13'':12B,53C ''31395041'':50B ''380'':40B,72C ''63092'':17B,74C ''electr'':71C ''gas'':67C ''true'':68C,70C ''water'':69C ''ар'':44B,63C ''бытов'':30B,59C ''вод'':37B ''газ'':35B ''документац'':42B ''зал'':27B,56C ''здан'':8B ''инженерн'':33B ''кв'':18B ''класс'':9B ''коворкинг'':32B,61C ''конференц'':26B,55C ''конференц-зал'':25B,54C ''м'':19B ''общ'':15B ''отмен'':52B ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,49B ''систем'':34B ''след'':23B ''соб'':7B ''соуэ'':46B,65C ''сс'':43B,62C ''статус'':51B ''стоимост'':48B ''техник'':31B,60C ''тх'':45B,64C ''удобств'':24B ''э'':47B,66C ''эд'':1A,4B ''экон'':10B,73C ''элегантн'':2A,5B ''электричеств'':39B ''электроник'':28B,57C ''этаж'':13B');
INSERT INTO stroy.project VALUES (111, 'Ювелирная Яркость', 127, 30, '{20,33,65,8,12}', 25222206, '2022-05-01', 'В работе', 'Проект "Ювелирная Яркость" представляет собой здание класса Эконом с 7 этажами и общей площадью 124066 кв.м. В проекте предусмотрены следующие удобства: электроника и бытовая техника, система климат-контроля, зона ожидания с мягкой мебелью. Инженерные системы: газ - отсутствует, вода - есть, электричество - 380 В. Документация: ТХ, ОВиК, СС, АПС, АР. Стоимость проекта: 25222206, статус: В работе.', '{"floors": 7, "amenities": ["электроника и бытовая техника", "система климат-контроля", "зона ожидания с мягкой мебелью"], "documents": ["ТХ", "ОВиК", "СС", "АПС", "АР"], "engineering": {"gas": false, "water": true, "electricity": 380}, "building_class": "Эконом", "total_area_sqm": 124066}', '''124066'':17B,85C ''25222206'':55B ''380'':45B,83C ''7'':12B,59C ''electr'':82C ''fals'':79C ''gas'':78C ''true'':81C ''water'':80C ''апс'':51B,76C ''ар'':52B,77C ''бытов'':27B,62C ''вод'':42B ''газ'':40B ''документац'':47B ''здан'':8B ''зон'':33B,68C ''инженерн'':38B ''кв'':18B ''класс'':9B ''климат'':31B,66C ''климат-контрол'':30B,65C ''контрол'':32B,67C ''м'':19B ''мебел'':37B,72C ''мягк'':36B,71C ''общ'':15B ''овик'':49B,74C ''ожидан'':34B,69C ''отсутств'':41B ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,54B ''работ'':58B ''систем'':29B,39B,64C ''след'':23B ''соб'':7B ''сс'':50B,75C ''статус'':56B ''стоимост'':53B ''техник'':28B,63C ''тх'':48B,73C ''удобств'':24B ''экон'':10B,84C ''электричеств'':44B ''электроник'':25B,60C ''этаж'':13B ''ювелирн'':1A,4B ''яркост'':2A,5B');
INSERT INTO stroy.project VALUES (112, 'Янтарный Ярл', 67, 44, '{8,22,19,6,73,79,59,24,80,11,43}', 31395041, '2023-03-08', 'В работе', 'Проект "Янтарный Ярл" представляет собой здание класса Бизнес с 24 этажами и общей площадью 135748 кв.м. В проекте предусмотрены следующие удобства: игровая зона для детей, магазины одежды и обуви, зона ожидания с мягкой мебелью, выставочный зал, велопарковка, детская комната. Инженерные системы: газ - отсутствует, вода - отсутствует, электричество - 220 В. Документация: СОУЭ, КР, ТХ. Стоимость проекта: 31395041, статус: В работе.', '{"floors": 24, "amenities": ["игровая зона для детей", "магазины одежды и обуви", "зона ожидания с мягкой мебелью", "выставочный зал", "велопарковка", "детская комната"], "documents": ["СОУЭ", "КР", "ТХ"], "engineering": {"gas": false, "water": false, "electricity": 220}, "building_class": "Бизнес", "total_area_sqm": 135748}', '''135748'':17B,91C ''220'':50B,89C ''24'':12B,62C ''31395041'':58B ''electr'':88C ''fals'':85C,87C ''gas'':84C ''water'':86C ''бизнес'':10B,90C ''велопарковк'':40B,78C ''вод'':47B ''выставочн'':38B,76C ''газ'':45B ''дет'':28B,66C ''детск'':41B,79C ''документац'':52B ''зал'':39B,77C ''здан'':8B ''зон'':26B,33B,64C,71C ''игров'':25B,63C ''инженерн'':43B ''кв'':18B ''класс'':9B ''комнат'':42B,80C ''кр'':54B,82C ''м'':19B ''магазин'':29B,67C ''мебел'':37B,75C ''мягк'':36B,74C ''обув'':32B,70C ''общ'':15B ''одежд'':30B,68C ''ожидан'':34B,72C ''отсутств'':46B,48B ''площад'':16B ''представля'':6B ''предусмотр'':22B ''проект'':3B,21B,57B ''работ'':61B ''систем'':44B ''след'':23B ''соб'':7B ''соуэ'':53B,81C ''статус'':59B ''стоимост'':56B ''тх'':55B,83C ''удобств'':24B ''электричеств'':49B ''этаж'':13B ''янтарн'':1A,4B ''ярл'':2A,5B');


--
-- TOC entry 5923 (class 0 OID 4886089)
-- Dependencies: 513
-- Data for Name: project_payment; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.project_payment VALUES (1, 96, 4603701.00, 'Авансовый', '2022-11-16', '2022-11-16 17:29:30.657155');
INSERT INTO stroy.project_payment VALUES (2, 96, 1918208.75, 'Промежуточный', '2023-02-08', '2023-02-08 14:09:00.96792');
INSERT INTO stroy.project_payment VALUES (3, 96, 1918208.75, 'Промежуточный', '2023-05-03', '2023-05-02 16:29:41.265327');
INSERT INTO stroy.project_payment VALUES (4, 96, 3069134.00, 'Финальный', '2023-07-27', '2023-07-23 21:21:10.748576');
INSERT INTO stroy.project_payment VALUES (5, 76, 9788882.40, 'Авансовый', '2023-11-20', '2023-11-21 11:20:45.293727');
INSERT INTO stroy.project_payment VALUES (6, 76, 3262960.80, 'Промежуточный', '2023-12-17', '2023-12-16 19:09:44.091711');
INSERT INTO stroy.project_payment VALUES (7, 76, 3262960.80, 'Промежуточный', '2024-01-13', '2024-01-13 04:20:08.759921');
INSERT INTO stroy.project_payment VALUES (8, 76, 3262960.80, 'Промежуточный', '2024-02-09', '2024-02-11 18:30:00.998141');
INSERT INTO stroy.project_payment VALUES (9, 76, 6525921.60, 'Финальный', '2024-03-07', '2024-03-13 00:11:33.845547');
INSERT INTO stroy.project_payment VALUES (10, 10, 10159252.50, 'Авансовый', '2023-11-15', '2023-11-18 04:45:41.120041');
INSERT INTO stroy.project_payment VALUES (11, 10, 5644029.17, 'Промежуточный', '2024-01-11', '2024-01-12 21:00:26.212122');
INSERT INTO stroy.project_payment VALUES (12, 10, 6772835.00, 'Финальный', '2024-03-08', '2024-03-09 11:18:43.431217');
INSERT INTO stroy.project_payment VALUES (13, 89, 5344441.20, 'Авансовый', '2024-01-17', '2024-01-20 12:13:44.080935');
INSERT INTO stroy.project_payment VALUES (14, 89, 1781480.40, 'Промежуточный', '2024-02-16', '2024-02-14 07:53:25.748863');
INSERT INTO stroy.project_payment VALUES (15, 89, 1781480.40, 'Промежуточный', '2024-03-17', '2024-03-15 18:18:21.644001');
INSERT INTO stroy.project_payment VALUES (16, 89, 1781480.40, 'Промежуточный', '2024-04-16', '2024-04-16 20:41:12.527101');
INSERT INTO stroy.project_payment VALUES (17, 89, 3562960.80, 'Финальный', '2024-05-19', NULL);
INSERT INTO stroy.project_payment VALUES (18, 21, 2381480.40, 'Авансовый', '2022-05-28', '2022-05-31 11:46:00.547829');
INSERT INTO stroy.project_payment VALUES (19, 21, 992283.50, 'Промежуточный', '2022-07-14', '2022-07-12 07:08:23.35477');
INSERT INTO stroy.project_payment VALUES (20, 21, 992283.50, 'Промежуточный', '2022-08-30', '2022-08-29 13:22:52.503016');
INSERT INTO stroy.project_payment VALUES (21, 21, 1587653.60, 'Финальный', '2022-10-16', '2022-10-19 11:14:38.908068');
INSERT INTO stroy.project_payment VALUES (22, 39, 3122220.60, 'Авансовый', '2023-12-19', '2023-12-21 14:31:27.840034');
INSERT INTO stroy.project_payment VALUES (23, 39, 1300925.25, 'Промежуточный', '2024-03-16', '2024-03-17 05:33:07.185067');
INSERT INTO stroy.project_payment VALUES (24, 39, 1300925.25, 'Промежуточный', '2024-06-12', NULL);
INSERT INTO stroy.project_payment VALUES (25, 39, 2081480.40, 'Финальный', '2024-09-08', NULL);
INSERT INTO stroy.project_payment VALUES (26, 24, 2011110.30, 'Авансовый', '2022-10-21', '2022-10-22 13:52:25.56859');
INSERT INTO stroy.project_payment VALUES (27, 24, 670370.10, 'Промежуточный', '2022-12-19', '2022-12-21 12:31:30.269827');
INSERT INTO stroy.project_payment VALUES (28, 24, 670370.10, 'Промежуточный', '2023-02-16', '2023-02-15 12:20:23.561152');
INSERT INTO stroy.project_payment VALUES (29, 24, 670370.10, 'Промежуточный', '2023-04-16', '2023-04-14 23:31:27.936038');
INSERT INTO stroy.project_payment VALUES (30, 24, 1340740.20, 'Финальный', '2023-06-15', '2023-06-13 14:26:32.878138');
INSERT INTO stroy.project_payment VALUES (31, 35, 3862960.80, 'Авансовый', '2023-08-22', '2023-08-24 14:11:55.424498');
INSERT INTO stroy.project_payment VALUES (32, 35, 1287653.60, 'Промежуточный', '2023-09-03', '2023-09-04 12:51:47.210474');
INSERT INTO stroy.project_payment VALUES (33, 35, 1287653.60, 'Промежуточный', '2023-09-15', '2023-09-15 05:05:16.79058');
INSERT INTO stroy.project_payment VALUES (34, 35, 1287653.60, 'Промежуточный', '2023-09-27', '2023-09-28 20:10:42.611333');
INSERT INTO stroy.project_payment VALUES (35, 35, 2575307.20, 'Финальный', '2023-10-09', '2023-10-14 09:12:33.402747');
INSERT INTO stroy.project_payment VALUES (36, 12, 4233330.90, 'Авансовый', '2024-03-05', '2024-03-08 20:46:22.475081');
INSERT INTO stroy.project_payment VALUES (37, 12, 1763887.88, 'Промежуточный', '2024-05-10', NULL);
INSERT INTO stroy.project_payment VALUES (38, 12, 1763887.88, 'Промежуточный', '2024-07-15', NULL);
INSERT INTO stroy.project_payment VALUES (39, 12, 2822220.60, 'Финальный', '2024-09-19', NULL);
INSERT INTO stroy.project_payment VALUES (40, 80, 3862960.80, 'Авансовый', '2023-07-14', '2023-07-17 14:05:33.822675');
INSERT INTO stroy.project_payment VALUES (41, 80, 2146089.33, 'Промежуточный', '2023-09-06', '2023-09-09 09:41:52.488473');
INSERT INTO stroy.project_payment VALUES (42, 80, 2575307.20, 'Финальный', '2023-10-30', '2023-10-29 22:40:39.685034');
INSERT INTO stroy.project_payment VALUES (43, 32, 7937031.90, 'Авансовый', '2022-11-01', '2022-11-04 14:48:17.34324');
INSERT INTO stroy.project_payment VALUES (44, 32, 4409462.17, 'Промежуточный', '2023-02-06', '2023-02-08 08:20:28.514505');
INSERT INTO stroy.project_payment VALUES (45, 32, 5291354.60, 'Финальный', '2023-05-14', '2023-05-21 13:33:45.783247');
INSERT INTO stroy.project_payment VALUES (46, 92, 2751850.50, 'Авансовый', '2023-06-26', '2023-06-27 03:55:27.461005');
INSERT INTO stroy.project_payment VALUES (47, 92, 1146604.38, 'Промежуточный', '2023-07-07', '2023-07-05 22:42:51.153966');
INSERT INTO stroy.project_payment VALUES (48, 92, 1146604.38, 'Промежуточный', '2023-07-18', '2023-07-18 08:41:02.198511');
INSERT INTO stroy.project_payment VALUES (49, 92, 1834567.00, 'Финальный', '2023-07-29', '2023-08-03 13:38:56.086254');
INSERT INTO stroy.project_payment VALUES (50, 48, 10159252.50, 'Авансовый', '2023-06-06', '2023-06-09 14:57:46.691897');
INSERT INTO stroy.project_payment VALUES (51, 48, 4233021.88, 'Промежуточный', '2023-07-14', '2023-07-13 22:25:33.961225');
INSERT INTO stroy.project_payment VALUES (52, 48, 4233021.88, 'Промежуточный', '2023-08-21', '2023-08-24 07:20:03.993058');
INSERT INTO stroy.project_payment VALUES (53, 48, 6772835.00, 'Финальный', '2023-09-29', '2023-10-02 12:49:31.743871');
INSERT INTO stroy.project_payment VALUES (54, 91, 9048142.20, 'Авансовый', '2023-04-02', '2023-04-05 13:01:40.740585');
INSERT INTO stroy.project_payment VALUES (55, 91, 3016047.40, 'Промежуточный', '2023-05-14', '2023-05-13 14:28:06.185523');
INSERT INTO stroy.project_payment VALUES (56, 91, 3016047.40, 'Промежуточный', '2023-06-25', '2023-06-26 03:10:48.124642');
INSERT INTO stroy.project_payment VALUES (57, 91, 3016047.40, 'Промежуточный', '2023-08-06', '2023-08-08 20:49:50.997737');
INSERT INTO stroy.project_payment VALUES (58, 91, 6032094.80, 'Финальный', '2023-09-19', '2023-09-22 22:46:23.604001');
INSERT INTO stroy.project_payment VALUES (59, 54, 1270370.10, 'Авансовый', '2023-09-19', '2023-09-20 20:37:09.060261');
INSERT INTO stroy.project_payment VALUES (60, 54, 705761.17, 'Промежуточный', '2024-01-25', '2024-01-24 05:55:36.857188');
INSERT INTO stroy.project_payment VALUES (61, 54, 846913.40, 'Финальный', '2024-06-02', NULL);
INSERT INTO stroy.project_payment VALUES (62, 26, 5344441.20, 'Авансовый', '2022-07-28', '2022-07-31 02:10:01.055229');
INSERT INTO stroy.project_payment VALUES (63, 26, 2969134.00, 'Промежуточный', '2022-10-23', '2022-10-23 06:47:10.246609');
INSERT INTO stroy.project_payment VALUES (64, 26, 3562960.80, 'Финальный', '2023-01-18', '2023-01-17 02:24:27.531317');
INSERT INTO stroy.project_payment VALUES (65, 64, 11270362.80, 'Авансовый', '2022-07-17', '2022-07-18 16:44:03.521012');
INSERT INTO stroy.project_payment VALUES (66, 64, 3756787.60, 'Промежуточный', '2022-07-31', '2022-07-29 18:56:52.851559');
INSERT INTO stroy.project_payment VALUES (67, 64, 3756787.60, 'Промежуточный', '2022-08-14', '2022-08-13 03:24:16.016203');
INSERT INTO stroy.project_payment VALUES (68, 64, 3756787.60, 'Промежуточный', '2022-08-28', '2022-08-25 22:16:31.861618');
INSERT INTO stroy.project_payment VALUES (69, 64, 7513575.20, 'Финальный', '2022-09-13', '2022-09-11 20:47:01.62406');
INSERT INTO stroy.project_payment VALUES (70, 28, 4233330.90, 'Авансовый', '2023-04-12', '2023-04-14 20:15:08.599492');
INSERT INTO stroy.project_payment VALUES (71, 28, 2351850.50, 'Промежуточный', '2023-05-13', '2023-05-13 05:48:03.340644');
INSERT INTO stroy.project_payment VALUES (72, 28, 2822220.60, 'Финальный', '2023-06-14', '2023-06-18 01:30:18.80437');
INSERT INTO stroy.project_payment VALUES (73, 61, 6455551.50, 'Авансовый', '2023-05-28', '2023-05-30 16:59:49.655427');
INSERT INTO stroy.project_payment VALUES (74, 61, 2151850.50, 'Промежуточный', '2023-07-20', '2023-07-21 02:53:07.312219');
INSERT INTO stroy.project_payment VALUES (75, 61, 2151850.50, 'Промежуточный', '2023-09-11', '2023-09-10 07:55:13.409397');
INSERT INTO stroy.project_payment VALUES (76, 61, 2151850.50, 'Промежуточный', '2023-11-03', '2023-11-05 09:15:11.085035');
INSERT INTO stroy.project_payment VALUES (77, 61, 4303701.00, 'Финальный', '2023-12-27', '2023-12-25 22:26:42.896126');
INSERT INTO stroy.project_payment VALUES (78, 86, 1270370.10, 'Авансовый', '2022-07-12', '2022-07-15 11:56:56.548291');
INSERT INTO stroy.project_payment VALUES (79, 86, 705761.17, 'Промежуточный', '2022-10-17', '2022-10-16 04:50:31.814897');
INSERT INTO stroy.project_payment VALUES (80, 86, 846913.40, 'Финальный', '2023-01-23', '2023-01-22 19:36:05.863249');
INSERT INTO stroy.project_payment VALUES (81, 58, 10159252.50, 'Авансовый', '2023-11-14', '2023-11-16 22:40:16.310492');
INSERT INTO stroy.project_payment VALUES (82, 58, 5644029.17, 'Промежуточный', '2024-03-07', '2024-03-04 19:05:09.908521');
INSERT INTO stroy.project_payment VALUES (83, 58, 6772835.00, 'Финальный', '2024-06-30', NULL);
INSERT INTO stroy.project_payment VALUES (84, 69, 5344441.20, 'Авансовый', '2022-06-14', '2022-06-15 21:12:28.544993');
INSERT INTO stroy.project_payment VALUES (85, 69, 2226850.50, 'Промежуточный', '2022-08-12', '2022-08-12 13:21:54.966623');
INSERT INTO stroy.project_payment VALUES (86, 69, 2226850.50, 'Промежуточный', '2022-10-10', '2022-10-09 17:57:34.505258');
INSERT INTO stroy.project_payment VALUES (87, 69, 3562960.80, 'Финальный', '2022-12-09', '2022-12-06 06:03:00.556708');
INSERT INTO stroy.project_payment VALUES (88, 4, 7196291.70, 'Авансовый', '2022-08-03', '2022-08-04 18:19:32.692541');
INSERT INTO stroy.project_payment VALUES (89, 4, 2398763.90, 'Промежуточный', '2022-08-21', '2022-08-24 01:04:43.702965');
INSERT INTO stroy.project_payment VALUES (90, 4, 2398763.90, 'Промежуточный', '2022-09-08', '2022-09-10 07:50:26.17966');
INSERT INTO stroy.project_payment VALUES (91, 4, 2398763.90, 'Промежуточный', '2022-09-26', '2022-09-29 10:21:59.181244');
INSERT INTO stroy.project_payment VALUES (92, 4, 4797527.80, 'Финальный', '2022-10-17', '2022-10-20 04:04:16.465325');
INSERT INTO stroy.project_payment VALUES (93, 82, 10159252.50, 'Авансовый', '2022-11-29', '2022-12-02 01:49:27.392002');
INSERT INTO stroy.project_payment VALUES (94, 82, 3386417.50, 'Промежуточный', '2023-01-19', '2023-01-20 12:40:55.98354');
INSERT INTO stroy.project_payment VALUES (95, 82, 3386417.50, 'Промежуточный', '2023-03-11', '2023-03-11 22:47:52.208007');
INSERT INTO stroy.project_payment VALUES (96, 82, 3386417.50, 'Промежуточный', '2023-05-01', '2023-05-04 00:20:37.522249');
INSERT INTO stroy.project_payment VALUES (97, 82, 6772835.00, 'Финальный', '2023-06-23', '2023-06-23 03:07:18.163743');
INSERT INTO stroy.project_payment VALUES (98, 3, 7196291.70, 'Авансовый', '2024-03-17', '2024-03-19 22:40:48.81384');
INSERT INTO stroy.project_payment VALUES (99, 3, 2398763.90, 'Промежуточный', '2024-03-30', '2024-03-28 06:07:20.226337');
INSERT INTO stroy.project_payment VALUES (100, 3, 2398763.90, 'Промежуточный', '2024-04-12', '2024-04-09 17:00:58.096576');
INSERT INTO stroy.project_payment VALUES (101, 3, 2398763.90, 'Промежуточный', '2024-04-25', '2024-04-23 08:07:23.492592');
INSERT INTO stroy.project_payment VALUES (102, 3, 4797527.80, 'Финальный', '2024-05-10', NULL);
INSERT INTO stroy.project_payment VALUES (103, 87, 10529622.60, 'Авансовый', '2023-08-22', '2023-08-23 20:42:20.332233');
INSERT INTO stroy.project_payment VALUES (104, 87, 3509874.20, 'Промежуточный', '2023-10-17', '2023-10-19 23:40:55.920976');
INSERT INTO stroy.project_payment VALUES (105, 87, 3509874.20, 'Промежуточный', '2023-12-12', '2023-12-12 02:20:01.015673');
INSERT INTO stroy.project_payment VALUES (106, 87, 3509874.20, 'Промежуточный', '2024-02-06', '2024-02-08 23:33:32.583886');
INSERT INTO stroy.project_payment VALUES (107, 87, 7019748.40, 'Финальный', '2024-04-05', '2024-04-05 04:21:30.946977');
INSERT INTO stroy.project_payment VALUES (108, 73, 12011103.00, 'Авансовый', '2022-06-24', '2022-06-26 16:32:58.015778');
INSERT INTO stroy.project_payment VALUES (109, 73, 4003701.00, 'Промежуточный', '2022-07-10', '2022-07-08 21:37:06.110435');
INSERT INTO stroy.project_payment VALUES (110, 73, 4003701.00, 'Промежуточный', '2022-07-26', '2022-07-27 20:50:58.920521');
INSERT INTO stroy.project_payment VALUES (111, 73, 4003701.00, 'Промежуточный', '2022-08-11', '2022-08-12 09:11:54.678116');
INSERT INTO stroy.project_payment VALUES (112, 73, 8007402.00, 'Финальный', '2022-08-28', '2022-08-26 09:59:25.840964');
INSERT INTO stroy.project_payment VALUES (113, 88, 10529622.60, 'Авансовый', '2023-08-22', '2023-08-25 12:53:48.140946');
INSERT INTO stroy.project_payment VALUES (114, 88, 3509874.20, 'Промежуточный', '2023-09-21', '2023-09-22 22:03:02.089793');
INSERT INTO stroy.project_payment VALUES (115, 88, 3509874.20, 'Промежуточный', '2023-10-21', '2023-10-22 06:50:19.4551');
INSERT INTO stroy.project_payment VALUES (116, 88, 3509874.20, 'Промежуточный', '2023-11-20', '2023-11-23 02:13:11.998901');
INSERT INTO stroy.project_payment VALUES (117, 88, 7019748.40, 'Финальный', '2023-12-22', '2023-12-21 16:06:05.038324');
INSERT INTO stroy.project_payment VALUES (118, 79, 1640740.20, 'Авансовый', '2022-07-18', '2022-07-19 11:20:56.75417');
INSERT INTO stroy.project_payment VALUES (119, 79, 911522.33, 'Промежуточный', '2022-09-15', '2022-09-16 01:31:25.626846');
INSERT INTO stroy.project_payment VALUES (120, 79, 1093826.80, 'Финальный', '2022-11-14', '2022-11-19 02:29:03.516245');
INSERT INTO stroy.project_payment VALUES (121, 55, 1270370.10, 'Авансовый', '2023-01-11', '2023-01-13 13:26:11.787516');
INSERT INTO stroy.project_payment VALUES (122, 55, 705761.17, 'Промежуточный', '2023-05-11', '2023-05-09 23:13:21.535793');
INSERT INTO stroy.project_payment VALUES (123, 55, 846913.40, 'Финальный', '2023-09-08', '2023-09-12 17:48:23.73396');
INSERT INTO stroy.project_payment VALUES (124, 81, 1270370.10, 'Авансовый', '2023-08-07', '2023-08-08 21:24:27.981614');
INSERT INTO stroy.project_payment VALUES (125, 81, 529320.88, 'Промежуточный', '2023-09-03', '2023-09-05 23:47:15.328323');
INSERT INTO stroy.project_payment VALUES (126, 81, 529320.88, 'Промежуточный', '2023-09-30', '2023-09-27 20:04:13.58177');
INSERT INTO stroy.project_payment VALUES (127, 81, 846913.40, 'Финальный', '2023-10-29', '2023-10-29 01:26:42.230782');
INSERT INTO stroy.project_payment VALUES (128, 101, 9788882.40, 'Авансовый', '2024-01-14', '2024-01-17 15:38:06.739575');
INSERT INTO stroy.project_payment VALUES (129, 101, 4078701.00, 'Промежуточный', '2024-01-24', '2024-01-24 13:12:01.700257');
INSERT INTO stroy.project_payment VALUES (130, 101, 4078701.00, 'Промежуточный', '2024-02-03', '2024-02-03 19:06:22.631552');
INSERT INTO stroy.project_payment VALUES (131, 101, 6525921.60, 'Финальный', '2024-02-15', '2024-02-18 13:36:18.426942');
INSERT INTO stroy.project_payment VALUES (132, 5, 3492590.70, 'Авансовый', '2022-06-07', '2022-06-10 12:58:00.176573');
INSERT INTO stroy.project_payment VALUES (133, 5, 1455246.13, 'Промежуточный', '2022-08-06', '2022-08-08 21:55:17.141602');
INSERT INTO stroy.project_payment VALUES (134, 5, 1455246.13, 'Промежуточный', '2022-10-05', '2022-10-08 04:16:04.092095');
INSERT INTO stroy.project_payment VALUES (135, 5, 2328393.80, 'Финальный', '2022-12-05', '2022-12-02 21:00:51.611198');
INSERT INTO stroy.project_payment VALUES (136, 27, 1270370.10, 'Авансовый', '2022-12-27', '2022-12-30 13:02:40.003749');
INSERT INTO stroy.project_payment VALUES (137, 27, 423456.70, 'Промежуточный', '2023-02-20', '2023-02-21 15:03:33.547619');
INSERT INTO stroy.project_payment VALUES (138, 27, 423456.70, 'Промежуточный', '2023-04-16', '2023-04-17 06:41:07.274658');
INSERT INTO stroy.project_payment VALUES (139, 27, 423456.70, 'Промежуточный', '2023-06-10', '2023-06-08 05:15:32.942902');
INSERT INTO stroy.project_payment VALUES (140, 27, 846913.40, 'Финальный', '2023-08-04', '2023-08-11 17:55:03.981649');
INSERT INTO stroy.project_payment VALUES (141, 84, 10899992.70, 'Авансовый', '2022-03-17', '2022-03-19 21:21:53.588915');
INSERT INTO stroy.project_payment VALUES (142, 84, 3633330.90, 'Промежуточный', '2022-04-08', '2022-04-07 01:20:27.709386');
INSERT INTO stroy.project_payment VALUES (143, 84, 3633330.90, 'Промежуточный', '2022-04-30', '2022-04-29 06:09:45.369089');
INSERT INTO stroy.project_payment VALUES (144, 84, 3633330.90, 'Промежуточный', '2022-05-22', '2022-05-21 06:01:23.466973');
INSERT INTO stroy.project_payment VALUES (145, 84, 7266661.80, 'Финальный', '2022-06-13', '2022-06-14 04:09:47.516169');
INSERT INTO stroy.project_payment VALUES (146, 36, 3862960.80, 'Авансовый', '2023-07-22', '2023-07-22 20:48:18.502631');
INSERT INTO stroy.project_payment VALUES (147, 36, 1609567.00, 'Промежуточный', '2023-09-11', '2023-09-09 14:11:16.830611');
INSERT INTO stroy.project_payment VALUES (148, 36, 1609567.00, 'Промежуточный', '2023-11-01', '2023-11-04 06:34:28.394979');
INSERT INTO stroy.project_payment VALUES (149, 36, 2575307.20, 'Финальный', '2023-12-22', '2023-12-21 16:25:43.58656');
INSERT INTO stroy.project_payment VALUES (150, 50, 5714811.30, 'Авансовый', '2023-06-02', '2023-06-03 18:20:13.752897');
INSERT INTO stroy.project_payment VALUES (151, 50, 2381171.38, 'Промежуточный', '2023-07-10', '2023-07-10 17:09:50.665045');
INSERT INTO stroy.project_payment VALUES (152, 50, 2381171.38, 'Промежуточный', '2023-08-17', '2023-08-14 17:54:47.533795');
INSERT INTO stroy.project_payment VALUES (153, 50, 3809874.20, 'Финальный', '2023-09-26', '2023-09-25 03:01:30.346344');
INSERT INTO stroy.project_payment VALUES (154, 38, 8307402.00, 'Авансовый', '2023-03-01', '2023-03-02 11:27:50.677226');
INSERT INTO stroy.project_payment VALUES (155, 38, 3461417.50, 'Промежуточный', '2023-04-01', '2023-03-29 20:41:21.418656');
INSERT INTO stroy.project_payment VALUES (156, 38, 3461417.50, 'Промежуточный', '2023-05-02', '2023-04-29 20:38:47.564532');
INSERT INTO stroy.project_payment VALUES (157, 38, 5538268.00, 'Финальный', '2023-06-03', '2023-06-06 14:33:25.625202');
INSERT INTO stroy.project_payment VALUES (158, 97, 6085181.40, 'Авансовый', '2022-11-08', '2022-11-08 14:19:43.14097');
INSERT INTO stroy.project_payment VALUES (159, 97, 3380656.33, 'Промежуточный', '2022-12-15', '2022-12-14 05:47:45.821946');
INSERT INTO stroy.project_payment VALUES (160, 97, 4056787.60, 'Финальный', '2023-01-22', '2023-01-26 17:32:45.406021');
INSERT INTO stroy.project_payment VALUES (161, 37, 4974071.10, 'Авансовый', '2022-06-02', '2022-06-04 17:05:37.968013');
INSERT INTO stroy.project_payment VALUES (162, 37, 1658023.70, 'Промежуточный', '2022-06-26', '2022-06-29 07:07:18.546685');
INSERT INTO stroy.project_payment VALUES (163, 37, 1658023.70, 'Промежуточный', '2022-07-20', '2022-07-19 07:32:33.988544');
INSERT INTO stroy.project_payment VALUES (164, 37, 1658023.70, 'Промежуточный', '2022-08-13', '2022-08-11 14:04:22.990428');
INSERT INTO stroy.project_payment VALUES (165, 37, 3316047.40, 'Финальный', '2022-09-07', '2022-09-13 00:10:09.935734');
INSERT INTO stroy.project_payment VALUES (166, 42, 6455551.50, 'Авансовый', '2023-11-19', '2023-11-21 23:49:40.120941');
INSERT INTO stroy.project_payment VALUES (167, 42, 2689813.13, 'Промежуточный', '2024-02-20', '2024-02-19 21:13:26.100427');
INSERT INTO stroy.project_payment VALUES (168, 42, 2689813.13, 'Промежуточный', '2024-05-23', NULL);
INSERT INTO stroy.project_payment VALUES (169, 42, 4303701.00, 'Финальный', '2024-08-24', NULL);
INSERT INTO stroy.project_payment VALUES (170, 20, 11270362.80, 'Авансовый', '2022-09-30', '2022-10-01 11:48:03.111713');
INSERT INTO stroy.project_payment VALUES (171, 20, 6261312.67, 'Промежуточный', '2022-10-21', '2022-10-22 19:53:45.508872');
INSERT INTO stroy.project_payment VALUES (172, 20, 7513575.20, 'Финальный', '2022-11-11', '2022-11-13 23:57:27.925805');
INSERT INTO stroy.project_payment VALUES (173, 68, 9048142.20, 'Авансовый', '2022-07-27', '2022-07-29 04:06:47.806382');
INSERT INTO stroy.project_payment VALUES (174, 68, 3016047.40, 'Промежуточный', '2022-09-12', '2022-09-10 09:41:00.578386');
INSERT INTO stroy.project_payment VALUES (175, 68, 3016047.40, 'Промежуточный', '2022-10-29', '2022-10-28 08:03:08.49874');
INSERT INTO stroy.project_payment VALUES (176, 68, 3016047.40, 'Промежуточный', '2022-12-15', '2022-12-16 02:16:44.081394');
INSERT INTO stroy.project_payment VALUES (177, 68, 6032094.80, 'Финальный', '2023-01-31', '2023-02-04 23:44:48.471981');
INSERT INTO stroy.project_payment VALUES (178, 17, 5714811.30, 'Авансовый', '2023-07-17', '2023-07-17 15:16:55.997929');
INSERT INTO stroy.project_payment VALUES (179, 17, 1904937.10, 'Промежуточный', '2023-08-20', '2023-08-22 17:07:47.456861');
INSERT INTO stroy.project_payment VALUES (180, 17, 1904937.10, 'Промежуточный', '2023-09-23', '2023-09-22 05:03:06.886054');
INSERT INTO stroy.project_payment VALUES (181, 17, 1904937.10, 'Промежуточный', '2023-10-27', '2023-10-26 23:05:25.836652');
INSERT INTO stroy.project_payment VALUES (182, 17, 3809874.20, 'Финальный', '2023-12-03', '2023-11-30 12:36:21.01116');
INSERT INTO stroy.project_payment VALUES (183, 60, 5714811.30, 'Авансовый', '2023-03-06', '2023-03-09 14:48:31.286233');
INSERT INTO stroy.project_payment VALUES (184, 60, 2381171.38, 'Промежуточный', '2023-03-30', '2023-04-01 02:50:05.814314');
INSERT INTO stroy.project_payment VALUES (185, 60, 2381171.38, 'Промежуточный', '2023-04-23', '2023-04-22 01:42:53.598607');
INSERT INTO stroy.project_payment VALUES (186, 60, 3809874.20, 'Финальный', '2023-05-19', '2023-05-24 19:50:58.308677');
INSERT INTO stroy.project_payment VALUES (187, 111, 7566661.80, 'Авансовый', '2022-05-01', '2022-05-03 09:58:32.11061');
INSERT INTO stroy.project_payment VALUES (188, 111, 4203701.00, 'Промежуточный', '2022-09-04', '2022-09-06 11:52:02.717081');
INSERT INTO stroy.project_payment VALUES (189, 111, 5044441.20, 'Финальный', '2023-01-09', '2023-01-06 14:07:35.686745');
INSERT INTO stroy.project_payment VALUES (190, 106, 9788882.40, 'Авансовый', '2022-08-23', '2022-08-24 10:52:07.085128');
INSERT INTO stroy.project_payment VALUES (191, 106, 3262960.80, 'Промежуточный', '2022-10-27', '2022-10-28 09:48:48.619051');
INSERT INTO stroy.project_payment VALUES (192, 106, 3262960.80, 'Промежуточный', '2022-12-31', '2022-12-31 00:04:27.030806');
INSERT INTO stroy.project_payment VALUES (193, 106, 3262960.80, 'Промежуточный', '2023-03-06', '2023-03-09 07:43:37.060402');
INSERT INTO stroy.project_payment VALUES (194, 106, 6525921.60, 'Финальный', '2023-05-13', '2023-05-09 18:49:57.376368');
INSERT INTO stroy.project_payment VALUES (195, 13, 3862960.80, 'Авансовый', '2022-12-31', '2023-01-03 02:12:44.619315');
INSERT INTO stroy.project_payment VALUES (196, 13, 1287653.60, 'Промежуточный', '2023-02-17', '2023-02-18 16:22:34.982071');
INSERT INTO stroy.project_payment VALUES (197, 13, 1287653.60, 'Промежуточный', '2023-04-06', '2023-04-06 03:25:54.22323');
INSERT INTO stroy.project_payment VALUES (198, 13, 1287653.60, 'Промежуточный', '2023-05-24', '2023-05-24 10:18:08.037366');
INSERT INTO stroy.project_payment VALUES (199, 13, 2575307.20, 'Финальный', '2023-07-13', '2023-07-15 00:22:15.383527');
INSERT INTO stroy.project_payment VALUES (200, 75, 6825921.60, 'Авансовый', '2023-02-25', '2023-02-26 20:56:15.513651');
INSERT INTO stroy.project_payment VALUES (201, 75, 3792178.67, 'Промежуточный', '2023-06-06', '2023-06-06 06:13:34.998179');
INSERT INTO stroy.project_payment VALUES (202, 75, 4550614.40, 'Финальный', '2023-09-16', '2023-09-17 09:12:49.242945');
INSERT INTO stroy.project_payment VALUES (203, 46, 2751850.50, 'Авансовый', '2022-08-04', '2022-08-05 03:40:40.268812');
INSERT INTO stroy.project_payment VALUES (204, 46, 917283.50, 'Промежуточный', '2022-08-25', '2022-08-23 04:36:54.9494');
INSERT INTO stroy.project_payment VALUES (205, 46, 917283.50, 'Промежуточный', '2022-09-15', '2022-09-16 03:14:18.159771');
INSERT INTO stroy.project_payment VALUES (206, 46, 917283.50, 'Промежуточный', '2022-10-06', '2022-10-07 13:29:17.903919');
INSERT INTO stroy.project_payment VALUES (207, 46, 1834567.00, 'Финальный', '2022-10-27', '2022-11-03 05:10:44.741383');
INSERT INTO stroy.project_payment VALUES (208, 25, 4974071.10, 'Авансовый', '2022-09-02', '2022-09-04 19:07:32.777173');
INSERT INTO stroy.project_payment VALUES (209, 25, 2072529.63, 'Промежуточный', '2022-10-27', '2022-10-24 23:19:58.711804');
INSERT INTO stroy.project_payment VALUES (210, 25, 2072529.63, 'Промежуточный', '2022-12-21', '2022-12-21 12:08:51.029119');
INSERT INTO stroy.project_payment VALUES (211, 25, 3316047.40, 'Финальный', '2023-02-16', '2023-02-21 07:58:47.644451');
INSERT INTO stroy.project_payment VALUES (212, 83, 1270370.10, 'Авансовый', '2023-02-11', '2023-02-12 08:10:54.160156');
INSERT INTO stroy.project_payment VALUES (213, 83, 423456.70, 'Промежуточный', '2023-04-07', '2023-04-08 05:20:11.48902');
INSERT INTO stroy.project_payment VALUES (214, 83, 423456.70, 'Промежуточный', '2023-06-01', '2023-06-03 01:35:38.419334');
INSERT INTO stroy.project_payment VALUES (215, 83, 423456.70, 'Промежуточный', '2023-07-26', '2023-07-25 15:15:09.351668');
INSERT INTO stroy.project_payment VALUES (216, 83, 846913.40, 'Финальный', '2023-09-21', '2023-09-19 20:30:44.053703');
INSERT INTO stroy.project_payment VALUES (217, 98, 3862960.80, 'Авансовый', '2022-12-24', '2022-12-26 22:45:21.981997');
INSERT INTO stroy.project_payment VALUES (218, 98, 2146089.33, 'Промежуточный', '2023-02-22', '2023-02-24 07:06:28.209564');
INSERT INTO stroy.project_payment VALUES (219, 98, 2575307.20, 'Финальный', '2023-04-23', '2023-04-28 05:49:20.961684');
INSERT INTO stroy.project_payment VALUES (220, 9, 10529622.60, 'Авансовый', '2023-05-27', '2023-05-27 17:11:50.176454');
INSERT INTO stroy.project_payment VALUES (221, 9, 4387342.75, 'Промежуточный', '2023-06-07', '2023-06-04 22:16:37.39558');
INSERT INTO stroy.project_payment VALUES (222, 9, 4387342.75, 'Промежуточный', '2023-06-18', '2023-06-21 02:19:13.454509');
INSERT INTO stroy.project_payment VALUES (223, 9, 7019748.40, 'Финальный', '2023-06-30', '2023-06-29 18:46:28.239349');
INSERT INTO stroy.project_payment VALUES (224, 78, 10159252.50, 'Авансовый', '2023-07-03', '2023-07-04 10:31:48.058237');
INSERT INTO stroy.project_payment VALUES (225, 78, 4233021.88, 'Промежуточный', '2023-10-02', '2023-10-01 20:04:24.975921');
INSERT INTO stroy.project_payment VALUES (226, 78, 4233021.88, 'Промежуточный', '2024-01-01', '2023-12-29 19:13:16.48455');
INSERT INTO stroy.project_payment VALUES (227, 78, 6772835.00, 'Финальный', '2024-04-03', '2024-04-08 12:55:16.185036');
INSERT INTO stroy.project_payment VALUES (228, 29, 9418512.30, 'Авансовый', '2023-11-03', '2023-11-06 14:01:47.24859');
INSERT INTO stroy.project_payment VALUES (229, 29, 3924380.13, 'Промежуточный', '2023-11-16', '2023-11-16 10:22:18.094305');
INSERT INTO stroy.project_payment VALUES (230, 29, 3924380.13, 'Промежуточный', '2023-11-29', '2023-11-28 16:30:59.072962');
INSERT INTO stroy.project_payment VALUES (231, 29, 6279008.20, 'Финальный', '2023-12-13', '2023-12-14 03:28:21.932797');
INSERT INTO stroy.project_payment VALUES (232, 72, 8307402.00, 'Авансовый', '2022-08-19', '2022-08-22 04:12:27.395854');
INSERT INTO stroy.project_payment VALUES (233, 72, 4615223.33, 'Промежуточный', '2022-11-20', '2022-11-21 04:46:42.861526');
INSERT INTO stroy.project_payment VALUES (234, 72, 5538268.00, 'Финальный', '2023-02-22', '2023-02-25 13:24:37.09565');
INSERT INTO stroy.project_payment VALUES (235, 6, 9048142.20, 'Авансовый', '2023-01-21', '2023-01-24 03:37:32.880895');
INSERT INTO stroy.project_payment VALUES (236, 6, 3016047.40, 'Промежуточный', '2023-02-20', '2023-02-20 23:29:32.999373');
INSERT INTO stroy.project_payment VALUES (237, 6, 3016047.40, 'Промежуточный', '2023-03-22', '2023-03-25 03:30:47.703376');
INSERT INTO stroy.project_payment VALUES (238, 6, 3016047.40, 'Промежуточный', '2023-04-21', '2023-04-20 04:56:28.856011');
INSERT INTO stroy.project_payment VALUES (239, 6, 6032094.80, 'Финальный', '2023-05-21', '2023-05-19 15:23:52.020577');
INSERT INTO stroy.project_payment VALUES (240, 30, 4233330.90, 'Авансовый', '2022-11-21', '2022-11-22 06:53:29.914004');
INSERT INTO stroy.project_payment VALUES (241, 30, 1763887.88, 'Промежуточный', '2023-01-10', '2023-01-11 23:59:20.534704');
INSERT INTO stroy.project_payment VALUES (242, 30, 1763887.88, 'Промежуточный', '2023-03-01', '2023-03-01 22:59:44.584848');
INSERT INTO stroy.project_payment VALUES (243, 30, 2822220.60, 'Финальный', '2023-04-21', '2023-04-25 01:19:28.163634');
INSERT INTO stroy.project_payment VALUES (244, 53, 7566661.80, 'Авансовый', '2023-10-26', '2023-10-26 19:26:39.832252');
INSERT INTO stroy.project_payment VALUES (245, 53, 4203701.00, 'Промежуточный', '2023-12-26', '2023-12-28 15:17:21.813875');
INSERT INTO stroy.project_payment VALUES (246, 53, 5044441.20, 'Финальный', '2024-02-25', '2024-02-28 22:43:08.359685');
INSERT INTO stroy.project_payment VALUES (247, 56, 10159252.50, 'Авансовый', '2022-04-04', '2022-04-05 08:34:39.462645');
INSERT INTO stroy.project_payment VALUES (248, 56, 4233021.88, 'Промежуточный', '2022-05-13', '2022-05-14 15:58:57.546271');
INSERT INTO stroy.project_payment VALUES (249, 56, 4233021.88, 'Промежуточный', '2022-06-21', '2022-06-22 23:58:27.727261');
INSERT INTO stroy.project_payment VALUES (250, 56, 6772835.00, 'Финальный', '2022-07-30', '2022-08-04 18:54:00.923416');
INSERT INTO stroy.project_payment VALUES (251, 22, 7196291.70, 'Авансовый', '2023-08-10', '2023-08-10 14:24:46.095224');
INSERT INTO stroy.project_payment VALUES (252, 22, 2998454.88, 'Промежуточный', '2023-10-04', '2023-10-03 21:15:01.140966');
INSERT INTO stroy.project_payment VALUES (253, 22, 2998454.88, 'Промежуточный', '2023-11-28', '2023-11-28 00:55:10.446752');
INSERT INTO stroy.project_payment VALUES (254, 22, 4797527.80, 'Финальный', '2024-01-23', '2024-01-21 22:33:13.501575');
INSERT INTO stroy.project_payment VALUES (255, 15, 2011110.30, 'Авансовый', '2022-04-19', '2022-04-22 07:21:54.400346');
INSERT INTO stroy.project_payment VALUES (256, 15, 837962.63, 'Промежуточный', '2022-05-26', '2022-05-27 16:08:34.039453');
INSERT INTO stroy.project_payment VALUES (257, 15, 837962.63, 'Промежуточный', '2022-07-02', '2022-06-29 20:29:23.178561');
INSERT INTO stroy.project_payment VALUES (258, 15, 1340740.20, 'Финальный', '2022-08-08', '2022-08-05 02:50:56.462172');
INSERT INTO stroy.project_payment VALUES (259, 49, 10899992.70, 'Авансовый', '2022-11-20', '2022-11-21 16:14:33.494082');
INSERT INTO stroy.project_payment VALUES (260, 49, 3633330.90, 'Промежуточный', '2023-01-09', '2023-01-07 18:16:17.916422');
INSERT INTO stroy.project_payment VALUES (261, 49, 3633330.90, 'Промежуточный', '2023-02-28', '2023-02-26 07:54:14.384552');
INSERT INTO stroy.project_payment VALUES (262, 49, 3633330.90, 'Промежуточный', '2023-04-19', '2023-04-22 01:05:20.729362');
INSERT INTO stroy.project_payment VALUES (263, 49, 7266661.80, 'Финальный', '2023-06-11', '2023-06-17 13:10:31.339801');
INSERT INTO stroy.project_payment VALUES (264, 16, 4233330.90, 'Авансовый', '2022-12-21', '2022-12-25 00:07:37.19559');
INSERT INTO stroy.project_payment VALUES (265, 16, 1763887.88, 'Промежуточный', '2023-01-19', '2023-01-17 18:35:22.682769');
INSERT INTO stroy.project_payment VALUES (266, 16, 1763887.88, 'Промежуточный', '2023-02-17', '2023-02-18 20:26:19.886668');
INSERT INTO stroy.project_payment VALUES (267, 16, 2822220.60, 'Финальный', '2023-03-20', '2023-03-23 20:14:40.626932');
INSERT INTO stroy.project_payment VALUES (268, 52, 11270362.80, 'Авансовый', '2023-05-25', '2023-05-28 18:49:46.231976');
INSERT INTO stroy.project_payment VALUES (269, 52, 6261312.67, 'Промежуточный', '2023-09-09', '2023-09-11 07:51:39.136484');
INSERT INTO stroy.project_payment VALUES (270, 52, 7513575.20, 'Финальный', '2023-12-26', '2023-12-25 08:36:33.214874');
INSERT INTO stroy.project_payment VALUES (271, 102, 2751850.50, 'Авансовый', '2022-06-27', '2022-06-30 17:59:26.586976');
INSERT INTO stroy.project_payment VALUES (272, 102, 1528805.83, 'Промежуточный', '2022-10-13', '2022-10-14 23:17:15.781091');
INSERT INTO stroy.project_payment VALUES (273, 102, 1834567.00, 'Финальный', '2023-01-30', '2023-01-27 02:26:54.219616');
INSERT INTO stroy.project_payment VALUES (274, 2, 10899992.70, 'Авансовый', '2023-04-20', '2023-04-21 05:43:23.133781');
INSERT INTO stroy.project_payment VALUES (275, 2, 3633330.90, 'Промежуточный', '2023-06-25', '2023-06-25 22:05:46.123458');
INSERT INTO stroy.project_payment VALUES (276, 2, 3633330.90, 'Промежуточный', '2023-08-30', '2023-08-31 12:15:22.839331');
INSERT INTO stroy.project_payment VALUES (277, 2, 3633330.90, 'Промежуточный', '2023-11-04', '2023-11-05 17:01:04.913059');
INSERT INTO stroy.project_payment VALUES (278, 2, 7266661.80, 'Финальный', '2024-01-09', '2024-01-06 21:56:25.461121');
INSERT INTO stroy.project_payment VALUES (279, 59, 6825921.60, 'Авансовый', '2024-04-01', '2024-04-04 09:49:45.700984');
INSERT INTO stroy.project_payment VALUES (280, 59, 3792178.67, 'Промежуточный', '2024-05-31', NULL);
INSERT INTO stroy.project_payment VALUES (281, 59, 4550614.40, 'Финальный', '2024-07-30', NULL);
INSERT INTO stroy.project_payment VALUES (282, 108, 6455551.50, 'Авансовый', '2023-08-07', '2023-08-08 04:32:40.609916');
INSERT INTO stroy.project_payment VALUES (283, 108, 3586417.50, 'Промежуточный', '2023-10-19', '2023-10-16 17:06:53.793136');
INSERT INTO stroy.project_payment VALUES (284, 108, 4303701.00, 'Финальный', '2024-01-01', '2024-01-05 22:45:30.471163');
INSERT INTO stroy.project_payment VALUES (285, 103, 2381480.40, 'Авансовый', '2022-09-25', '2022-09-28 14:40:35.235837');
INSERT INTO stroy.project_payment VALUES (286, 103, 992283.50, 'Промежуточный', '2022-12-14', '2022-12-15 09:51:38.493877');
INSERT INTO stroy.project_payment VALUES (287, 103, 992283.50, 'Промежуточный', '2023-03-04', '2023-03-02 22:46:53.925788');
INSERT INTO stroy.project_payment VALUES (288, 103, 1587653.60, 'Финальный', '2023-05-25', '2023-05-26 07:33:36.485116');
INSERT INTO stroy.project_payment VALUES (289, 14, 4233330.90, 'Авансовый', '2022-07-11', '2022-07-13 23:33:51.753752');
INSERT INTO stroy.project_payment VALUES (290, 14, 2351850.50, 'Промежуточный', '2022-09-01', '2022-09-03 15:58:20.660779');
INSERT INTO stroy.project_payment VALUES (291, 14, 2822220.60, 'Финальный', '2022-10-23', '2022-10-21 11:19:52.921444');
INSERT INTO stroy.project_payment VALUES (292, 33, 2751850.50, 'Авансовый', '2022-06-04', '2022-06-05 17:03:45.228147');
INSERT INTO stroy.project_payment VALUES (293, 33, 1528805.83, 'Промежуточный', '2022-09-28', '2022-09-26 23:30:12.027982');
INSERT INTO stroy.project_payment VALUES (294, 33, 1834567.00, 'Финальный', '2023-01-23', '2023-01-20 15:54:34.139156');
INSERT INTO stroy.project_payment VALUES (295, 47, 1640740.20, 'Авансовый', '2022-12-11', '2022-12-12 02:24:38.81552');
INSERT INTO stroy.project_payment VALUES (296, 47, 546913.40, 'Промежуточный', '2023-01-10', '2023-01-11 02:30:03.091562');
INSERT INTO stroy.project_payment VALUES (297, 47, 546913.40, 'Промежуточный', '2023-02-09', '2023-02-08 14:38:27.227259');
INSERT INTO stroy.project_payment VALUES (298, 47, 546913.40, 'Промежуточный', '2023-03-11', '2023-03-13 01:33:38.216304');
INSERT INTO stroy.project_payment VALUES (299, 47, 1093826.80, 'Финальный', '2023-04-13', '2023-04-18 08:13:49.748016');
INSERT INTO stroy.project_payment VALUES (300, 7, 10529622.60, 'Авансовый', '2024-02-25', '2024-02-28 10:32:10.452941');
INSERT INTO stroy.project_payment VALUES (301, 7, 5849790.33, 'Промежуточный', '2024-06-13', NULL);
INSERT INTO stroy.project_payment VALUES (302, 7, 7019748.40, 'Финальный', '2024-09-30', NULL);
INSERT INTO stroy.project_payment VALUES (303, 95, 5344441.20, 'Авансовый', '2022-10-15', '2022-10-17 18:13:44.777778');
INSERT INTO stroy.project_payment VALUES (304, 95, 2226850.50, 'Промежуточный', '2022-12-31', '2023-01-01 15:59:14.249271');
INSERT INTO stroy.project_payment VALUES (305, 95, 2226850.50, 'Промежуточный', '2023-03-18', '2023-03-19 00:14:37.319878');
INSERT INTO stroy.project_payment VALUES (306, 95, 3562960.80, 'Финальный', '2023-06-04', '2023-06-03 16:48:53.163652');
INSERT INTO stroy.project_payment VALUES (307, 65, 12011103.00, 'Авансовый', '2022-09-17', '2022-09-19 22:31:46.883224');
INSERT INTO stroy.project_payment VALUES (308, 65, 4003701.00, 'Промежуточный', '2022-11-23', '2022-11-22 12:28:27.503639');
INSERT INTO stroy.project_payment VALUES (309, 65, 4003701.00, 'Промежуточный', '2023-01-29', '2023-01-30 00:48:53.879451');
INSERT INTO stroy.project_payment VALUES (310, 65, 4003701.00, 'Промежуточный', '2023-04-06', '2023-04-06 18:19:53.23894');
INSERT INTO stroy.project_payment VALUES (311, 65, 8007402.00, 'Финальный', '2023-06-14', '2023-06-19 04:20:21.192108');
INSERT INTO stroy.project_payment VALUES (312, 18, 6085181.40, 'Авансовый', '2023-03-28', '2023-03-28 18:16:49.496369');
INSERT INTO stroy.project_payment VALUES (313, 18, 2535492.25, 'Промежуточный', '2023-06-28', '2023-06-29 10:23:10.956985');
INSERT INTO stroy.project_payment VALUES (314, 18, 2535492.25, 'Промежуточный', '2023-09-28', '2023-09-27 11:23:41.265073');
INSERT INTO stroy.project_payment VALUES (315, 18, 4056787.60, 'Финальный', '2023-12-29', '2023-12-30 01:41:37.256498');
INSERT INTO stroy.project_payment VALUES (316, 40, 8677772.10, 'Авансовый', '2022-06-06', '2022-06-07 16:23:33.224382');
INSERT INTO stroy.project_payment VALUES (317, 40, 2892590.70, 'Промежуточный', '2022-07-16', '2022-07-15 11:13:47.97688');
INSERT INTO stroy.project_payment VALUES (318, 40, 2892590.70, 'Промежуточный', '2022-08-25', '2022-08-26 06:09:06.205487');
INSERT INTO stroy.project_payment VALUES (319, 40, 2892590.70, 'Промежуточный', '2022-10-04', '2022-10-01 20:14:25.456298');
INSERT INTO stroy.project_payment VALUES (320, 40, 5785181.40, 'Финальный', '2022-11-16', '2022-11-18 05:19:15.885031');
INSERT INTO stroy.project_payment VALUES (321, 43, 1640740.20, 'Авансовый', '2023-08-06', '2023-08-06 19:27:23.891794');
INSERT INTO stroy.project_payment VALUES (322, 43, 683641.75, 'Промежуточный', '2023-09-17', '2023-09-20 01:42:28.897275');
INSERT INTO stroy.project_payment VALUES (323, 43, 683641.75, 'Промежуточный', '2023-10-29', '2023-11-01 03:07:49.912343');
INSERT INTO stroy.project_payment VALUES (324, 43, 1093826.80, 'Финальный', '2023-12-11', '2023-12-09 19:48:32.411969');
INSERT INTO stroy.project_payment VALUES (325, 107, 4603701.00, 'Авансовый', '2023-08-19', '2023-08-20 05:30:43.582497');
INSERT INTO stroy.project_payment VALUES (326, 107, 2557611.67, 'Промежуточный', '2023-12-12', '2023-12-12 23:13:03.023844');
INSERT INTO stroy.project_payment VALUES (327, 107, 3069134.00, 'Финальный', '2024-04-05', '2024-04-06 15:19:31.344666');
INSERT INTO stroy.project_payment VALUES (328, 104, 4603701.00, 'Авансовый', '2023-03-10', '2023-03-11 23:11:14.741887');
INSERT INTO stroy.project_payment VALUES (329, 104, 2557611.67, 'Промежуточный', '2023-04-04', '2023-04-06 12:00:38.159273');
INSERT INTO stroy.project_payment VALUES (330, 104, 3069134.00, 'Финальный', '2023-04-30', '2023-05-05 01:45:48.49121');
INSERT INTO stroy.project_payment VALUES (331, 93, 3122220.60, 'Авансовый', '2022-06-11', '2022-06-14 11:24:22.512559');
INSERT INTO stroy.project_payment VALUES (332, 93, 1300925.25, 'Промежуточный', '2022-07-16', '2022-07-16 21:03:59.673514');
INSERT INTO stroy.project_payment VALUES (333, 93, 1300925.25, 'Промежуточный', '2022-08-20', '2022-08-21 09:50:48.055461');
INSERT INTO stroy.project_payment VALUES (334, 93, 2081480.40, 'Финальный', '2022-09-26', '2022-09-27 18:43:32.947013');
INSERT INTO stroy.project_payment VALUES (335, 112, 9418512.30, 'Авансовый', '2023-03-08', '2023-03-10 19:42:35.462234');
INSERT INTO stroy.project_payment VALUES (336, 112, 3139504.10, 'Промежуточный', '2023-04-22', '2023-04-22 01:00:42.923665');
INSERT INTO stroy.project_payment VALUES (337, 112, 3139504.10, 'Промежуточный', '2023-06-06', '2023-06-07 02:01:57.338515');
INSERT INTO stroy.project_payment VALUES (338, 112, 3139504.10, 'Промежуточный', '2023-07-21', '2023-07-21 13:35:11.137236');
INSERT INTO stroy.project_payment VALUES (339, 112, 6279008.20, 'Финальный', '2023-09-06', '2023-09-05 09:19:20.327113');
INSERT INTO stroy.project_payment VALUES (340, 41, 1640740.20, 'Авансовый', '2022-10-07', '2022-10-08 12:30:31.645048');
INSERT INTO stroy.project_payment VALUES (341, 41, 546913.40, 'Промежуточный', '2022-10-31', '2022-11-01 02:57:40.552235');
INSERT INTO stroy.project_payment VALUES (342, 41, 546913.40, 'Промежуточный', '2022-11-24', '2022-11-23 22:16:54.714156');
INSERT INTO stroy.project_payment VALUES (343, 41, 546913.40, 'Промежуточный', '2022-12-18', '2022-12-18 20:49:34.914916');
INSERT INTO stroy.project_payment VALUES (344, 41, 1093826.80, 'Финальный', '2023-01-14', '2023-01-13 15:12:27.81542');
INSERT INTO stroy.project_payment VALUES (345, 11, 7937031.90, 'Авансовый', '2022-07-10', '2022-07-10 20:52:02.788953');
INSERT INTO stroy.project_payment VALUES (346, 11, 4409462.17, 'Промежуточный', '2022-10-09', '2022-10-10 22:57:15.69123');
INSERT INTO stroy.project_payment VALUES (347, 11, 5291354.60, 'Финальный', '2023-01-08', '2023-01-10 01:26:46.29985');
INSERT INTO stroy.project_payment VALUES (348, 105, 6825921.60, 'Авансовый', '2024-01-17', '2024-01-17 22:08:01.540255');
INSERT INTO stroy.project_payment VALUES (349, 105, 3792178.67, 'Промежуточный', '2024-04-23', '2024-04-24 10:43:46.990799');
INSERT INTO stroy.project_payment VALUES (350, 105, 4550614.40, 'Финальный', '2024-07-29', NULL);
INSERT INTO stroy.project_payment VALUES (351, 19, 2381480.40, 'Авансовый', '2022-04-23', '2022-04-23 21:15:07.322917');
INSERT INTO stroy.project_payment VALUES (352, 19, 793826.80, 'Промежуточный', '2022-05-09', '2022-05-07 00:05:53.017504');
INSERT INTO stroy.project_payment VALUES (353, 19, 793826.80, 'Промежуточный', '2022-05-25', '2022-05-25 20:49:24.866944');
INSERT INTO stroy.project_payment VALUES (354, 19, 793826.80, 'Промежуточный', '2022-06-10', '2022-06-08 16:55:01.658507');
INSERT INTO stroy.project_payment VALUES (355, 19, 1587653.60, 'Финальный', '2022-06-26', '2022-06-23 03:45:17.7341');
INSERT INTO stroy.project_payment VALUES (356, 85, 4603701.00, 'Авансовый', '2023-08-25', '2023-08-28 07:46:17.830709');
INSERT INTO stroy.project_payment VALUES (357, 85, 1918208.75, 'Промежуточный', '2023-11-02', '2023-11-03 11:07:07.419148');
INSERT INTO stroy.project_payment VALUES (358, 85, 1918208.75, 'Промежуточный', '2024-01-10', '2024-01-10 20:05:40.536421');
INSERT INTO stroy.project_payment VALUES (359, 85, 3069134.00, 'Финальный', '2024-03-20', '2024-03-18 19:31:26.694855');
INSERT INTO stroy.project_payment VALUES (360, 71, 5344441.20, 'Авансовый', '2023-12-06', '2023-12-09 10:03:05.034722');
INSERT INTO stroy.project_payment VALUES (361, 71, 2226850.50, 'Промежуточный', '2024-01-12', '2024-01-11 21:18:13.950367');
INSERT INTO stroy.project_payment VALUES (362, 71, 2226850.50, 'Промежуточный', '2024-02-18', '2024-02-19 22:49:01.630998');
INSERT INTO stroy.project_payment VALUES (363, 71, 3562960.80, 'Финальный', '2024-03-26', '2024-03-25 07:04:46.47214');
INSERT INTO stroy.project_payment VALUES (364, 62, 7937031.90, 'Авансовый', '2023-02-06', '2023-02-07 06:52:43.753038');
INSERT INTO stroy.project_payment VALUES (365, 62, 3307096.63, 'Промежуточный', '2023-02-25', '2023-02-26 17:31:15.51072');
INSERT INTO stroy.project_payment VALUES (366, 62, 3307096.63, 'Промежуточный', '2023-03-16', '2023-03-13 21:26:23.751277');
INSERT INTO stroy.project_payment VALUES (367, 62, 5291354.60, 'Финальный', '2023-04-05', '2023-04-05 03:31:17.422953');
INSERT INTO stroy.project_payment VALUES (368, 1, 5714811.30, 'Авансовый', '2022-07-15', '2022-07-16 22:10:56.12614');
INSERT INTO stroy.project_payment VALUES (369, 1, 2381171.38, 'Промежуточный', '2022-08-02', '2022-07-31 06:33:49.375592');
INSERT INTO stroy.project_payment VALUES (370, 1, 2381171.38, 'Промежуточный', '2022-08-20', '2022-08-20 09:26:26.169504');
INSERT INTO stroy.project_payment VALUES (371, 1, 3809874.20, 'Финальный', '2022-09-09', '2022-09-11 19:27:09.444411');
INSERT INTO stroy.project_payment VALUES (372, 94, 4603701.00, 'Авансовый', '2022-06-23', '2022-06-24 14:49:47.843984');
INSERT INTO stroy.project_payment VALUES (373, 94, 1918208.75, 'Промежуточный', '2022-07-15', '2022-07-13 16:10:17.931259');
INSERT INTO stroy.project_payment VALUES (374, 94, 1918208.75, 'Промежуточный', '2022-08-06', '2022-08-08 09:10:26.033486');
INSERT INTO stroy.project_payment VALUES (375, 94, 3069134.00, 'Финальный', '2022-08-30', '2022-08-31 19:15:10.514243');
INSERT INTO stroy.project_payment VALUES (376, 74, 1270370.10, 'Авансовый', '2022-06-20', '2022-06-22 19:18:02.994434');
INSERT INTO stroy.project_payment VALUES (377, 74, 529320.88, 'Промежуточный', '2022-09-20', '2022-09-19 19:03:34.81957');
INSERT INTO stroy.project_payment VALUES (378, 74, 529320.88, 'Промежуточный', '2022-12-21', '2022-12-24 11:08:26.912273');
INSERT INTO stroy.project_payment VALUES (379, 74, 846913.40, 'Финальный', '2023-03-25', '2023-03-23 14:44:31.503172');
INSERT INTO stroy.project_payment VALUES (380, 31, 5344441.20, 'Авансовый', '2023-03-15', '2023-03-16 22:18:00.817802');
INSERT INTO stroy.project_payment VALUES (381, 31, 2969134.00, 'Промежуточный', '2023-04-21', '2023-04-21 19:46:35.282418');
INSERT INTO stroy.project_payment VALUES (382, 31, 3562960.80, 'Финальный', '2023-05-28', '2023-05-31 09:47:29.352511');
INSERT INTO stroy.project_payment VALUES (383, 70, 11640732.90, 'Авансовый', '2023-06-22', '2023-06-24 00:39:28.328634');
INSERT INTO stroy.project_payment VALUES (384, 70, 3880244.30, 'Промежуточный', '2023-07-14', '2023-07-14 16:00:12.226123');
INSERT INTO stroy.project_payment VALUES (385, 70, 3880244.30, 'Промежуточный', '2023-08-05', '2023-08-08 07:24:23.951448');
INSERT INTO stroy.project_payment VALUES (386, 70, 3880244.30, 'Промежуточный', '2023-08-27', '2023-08-30 04:11:14.964069');
INSERT INTO stroy.project_payment VALUES (387, 70, 7760488.60, 'Финальный', '2023-09-21', '2023-09-26 09:47:08.785232');
INSERT INTO stroy.project_payment VALUES (388, 110, 9418512.30, 'Авансовый', '2023-09-18', '2023-09-20 17:52:45.372897');
INSERT INTO stroy.project_payment VALUES (389, 110, 3924380.13, 'Промежуточный', '2023-10-28', '2023-10-31 05:15:10.907988');
INSERT INTO stroy.project_payment VALUES (390, 110, 3924380.13, 'Промежуточный', '2023-12-07', '2023-12-09 13:20:17.025226');
INSERT INTO stroy.project_payment VALUES (391, 110, 6279008.20, 'Финальный', '2024-01-16', '2024-01-19 09:29:41.948557');
INSERT INTO stroy.project_payment VALUES (392, 99, 7937031.90, 'Авансовый', '2023-02-11', '2023-02-12 11:48:22.542977');
INSERT INTO stroy.project_payment VALUES (393, 99, 2645677.30, 'Промежуточный', '2023-03-05', '2023-03-03 02:24:26.472385');
INSERT INTO stroy.project_payment VALUES (394, 99, 2645677.30, 'Промежуточный', '2023-03-27', '2023-03-27 07:53:12.418174');
INSERT INTO stroy.project_payment VALUES (395, 99, 2645677.30, 'Промежуточный', '2023-04-18', '2023-04-18 11:30:30.064851');
INSERT INTO stroy.project_payment VALUES (396, 99, 5291354.60, 'Финальный', '2023-05-12', '2023-05-14 09:52:17.358036');
INSERT INTO stroy.project_payment VALUES (397, 100, 3492590.70, 'Авансовый', '2023-03-27', '2023-03-30 21:13:47.391637');
INSERT INTO stroy.project_payment VALUES (398, 100, 1164196.90, 'Промежуточный', '2023-05-28', '2023-05-26 14:48:58.077659');
INSERT INTO stroy.project_payment VALUES (399, 100, 1164196.90, 'Промежуточный', '2023-07-29', '2023-07-31 19:08:49.984135');
INSERT INTO stroy.project_payment VALUES (400, 100, 1164196.90, 'Промежуточный', '2023-09-29', '2023-09-28 21:15:14.799129');
INSERT INTO stroy.project_payment VALUES (401, 100, 2328393.80, 'Финальный', '2023-11-30', '2023-12-02 13:02:08.052215');
INSERT INTO stroy.project_payment VALUES (402, 109, 7196291.70, 'Авансовый', '2023-08-22', '2023-08-24 00:24:37.957764');
INSERT INTO stroy.project_payment VALUES (403, 109, 2998454.88, 'Промежуточный', '2023-11-15', '2023-11-14 03:05:01.766169');
INSERT INTO stroy.project_payment VALUES (404, 109, 2998454.88, 'Промежуточный', '2024-02-08', '2024-02-06 12:50:24.385818');
INSERT INTO stroy.project_payment VALUES (405, 109, 4797527.80, 'Финальный', '2024-05-03', '2024-05-03 09:45:44.738134');
INSERT INTO stroy.project_payment VALUES (406, 34, 2381480.40, 'Авансовый', '2023-01-23', '2023-01-26 07:19:37.430541');
INSERT INTO stroy.project_payment VALUES (407, 34, 992283.50, 'Промежуточный', '2023-04-14', '2023-04-16 03:55:02.456753');
INSERT INTO stroy.project_payment VALUES (408, 34, 992283.50, 'Промежуточный', '2023-07-04', '2023-07-02 06:52:36.393007');
INSERT INTO stroy.project_payment VALUES (409, 34, 1587653.60, 'Финальный', '2023-09-24', '2023-09-23 01:44:56.941888');
INSERT INTO stroy.project_payment VALUES (410, 67, 5344441.20, 'Авансовый', '2023-12-12', '2023-12-16 00:01:11.375659');
INSERT INTO stroy.project_payment VALUES (411, 67, 2226850.50, 'Промежуточный', '2024-02-01', '2024-01-31 19:08:35.09799');
INSERT INTO stroy.project_payment VALUES (412, 67, 2226850.50, 'Промежуточный', '2024-03-23', '2024-03-20 19:56:30.482713');
INSERT INTO stroy.project_payment VALUES (413, 67, 3562960.80, 'Финальный', '2024-05-14', NULL);
INSERT INTO stroy.project_payment VALUES (414, 45, 1640740.20, 'Авансовый', '2023-02-19', '2023-02-22 18:25:41.563766');
INSERT INTO stroy.project_payment VALUES (415, 45, 683641.75, 'Промежуточный', '2023-03-27', '2023-03-26 12:27:05.154262');
INSERT INTO stroy.project_payment VALUES (416, 45, 683641.75, 'Промежуточный', '2023-05-02', '2023-05-02 22:23:20.274398');
INSERT INTO stroy.project_payment VALUES (417, 45, 1093826.80, 'Финальный', '2023-06-09', '2023-06-16 16:52:14.605327');
INSERT INTO stroy.project_payment VALUES (418, 23, 6085181.40, 'Авансовый', '2022-05-09', '2022-05-10 07:16:06.568967');
INSERT INTO stroy.project_payment VALUES (419, 23, 3380656.33, 'Промежуточный', '2022-06-10', '2022-06-12 03:33:58.216064');
INSERT INTO stroy.project_payment VALUES (420, 23, 4056787.60, 'Финальный', '2022-07-13', '2022-07-10 17:08:00.747347');
INSERT INTO stroy.project_payment VALUES (421, 44, 5344441.20, 'Авансовый', '2023-05-11', '2023-05-13 02:47:31.874223');
INSERT INTO stroy.project_payment VALUES (422, 44, 2969134.00, 'Промежуточный', '2023-09-23', '2023-09-22 20:04:26.012117');
INSERT INTO stroy.project_payment VALUES (423, 44, 3562960.80, 'Финальный', '2024-02-06', '2024-02-05 13:23:38.054872');
INSERT INTO stroy.project_payment VALUES (424, 8, 11270362.80, 'Авансовый', '2023-06-16', '2023-06-17 14:16:56.997333');
INSERT INTO stroy.project_payment VALUES (425, 8, 3756787.60, 'Промежуточный', '2023-07-15', '2023-07-15 22:09:03.715256');
INSERT INTO stroy.project_payment VALUES (426, 8, 3756787.60, 'Промежуточный', '2023-08-13', '2023-08-14 11:54:08.613462');
INSERT INTO stroy.project_payment VALUES (427, 8, 3756787.60, 'Промежуточный', '2023-09-11', '2023-09-11 09:27:09.842109');
INSERT INTO stroy.project_payment VALUES (428, 8, 7513575.20, 'Финальный', '2023-10-13', '2023-10-17 17:01:25.749831');
INSERT INTO stroy.project_payment VALUES (429, 51, 3492590.70, 'Авансовый', '2022-09-22', '2022-09-23 05:38:15.396516');
INSERT INTO stroy.project_payment VALUES (430, 51, 1455246.13, 'Промежуточный', '2022-11-20', '2022-11-21 23:47:19.593881');
INSERT INTO stroy.project_payment VALUES (431, 51, 1455246.13, 'Промежуточный', '2023-01-18', '2023-01-20 00:12:35.490427');
INSERT INTO stroy.project_payment VALUES (432, 51, 2328393.80, 'Финальный', '2023-03-20', '2023-03-16 14:25:56.530214');
INSERT INTO stroy.project_payment VALUES (433, 57, 11270362.80, 'Авансовый', '2022-10-09', '2022-10-09 16:22:08.734012');
INSERT INTO stroy.project_payment VALUES (434, 57, 3756787.60, 'Промежуточный', '2022-11-08', '2022-11-10 11:13:30.185933');
INSERT INTO stroy.project_payment VALUES (435, 57, 3756787.60, 'Промежуточный', '2022-12-08', '2022-12-06 09:09:23.682156');
INSERT INTO stroy.project_payment VALUES (436, 57, 3756787.60, 'Промежуточный', '2023-01-07', '2023-01-07 13:05:34.380565');
INSERT INTO stroy.project_payment VALUES (437, 57, 7513575.20, 'Финальный', '2023-02-07', '2023-02-12 23:15:16.875749');
INSERT INTO stroy.project_payment VALUES (438, 77, 7937031.90, 'Авансовый', '2022-11-15', '2022-11-15 18:29:00.171365');
INSERT INTO stroy.project_payment VALUES (439, 77, 3307096.63, 'Промежуточный', '2022-12-06', '2022-12-05 04:14:22.313471');
INSERT INTO stroy.project_payment VALUES (440, 77, 3307096.63, 'Промежуточный', '2022-12-27', '2022-12-29 17:40:24.637452');
INSERT INTO stroy.project_payment VALUES (441, 77, 5291354.60, 'Финальный', '2023-01-18', '2023-01-23 11:29:21.884095');
INSERT INTO stroy.project_payment VALUES (442, 90, 6085181.40, 'Авансовый', '2022-03-26', '2022-03-27 06:37:04.451633');
INSERT INTO stroy.project_payment VALUES (443, 90, 3380656.33, 'Промежуточный', '2022-04-11', '2022-04-11 03:01:32.537764');
INSERT INTO stroy.project_payment VALUES (444, 90, 4056787.60, 'Финальный', '2022-04-27', '2022-05-04 02:32:57.417387');
INSERT INTO stroy.project_payment VALUES (445, 66, 3122220.60, 'Авансовый', '2023-08-31', '2023-09-02 03:37:02.21828');
INSERT INTO stroy.project_payment VALUES (446, 66, 1300925.25, 'Промежуточный', '2023-11-25', '2023-11-26 01:06:45.966138');
INSERT INTO stroy.project_payment VALUES (447, 66, 1300925.25, 'Промежуточный', '2024-02-19', '2024-02-21 04:25:15.431652');
INSERT INTO stroy.project_payment VALUES (448, 66, 2081480.40, 'Финальный', '2024-05-17', NULL);
INSERT INTO stroy.project_payment VALUES (449, 63, 6455551.50, 'Авансовый', '2023-07-15', '2023-07-15 18:01:44.286774');
INSERT INTO stroy.project_payment VALUES (450, 63, 3586417.50, 'Промежуточный', '2023-10-16', '2023-10-16 22:26:45.230105');
INSERT INTO stroy.project_payment VALUES (451, 63, 4303701.00, 'Финальный', '2024-01-17', '2024-01-24 07:20:44.85951');


--
-- TOC entry 5926 (class 0 OID 4886098)
-- Dependencies: 516
-- Data for Name: type_of_work; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.type_of_work VALUES (1, 'Проектирование');
INSERT INTO stroy.type_of_work VALUES (2, 'Генеральное проектирование');
INSERT INTO stroy.type_of_work VALUES (3, 'Коммерческие интерьеры');
INSERT INTO stroy.type_of_work VALUES (4, 'Управление');
INSERT INTO stroy.type_of_work VALUES (5, 'Градостроительные проекты');
INSERT INTO stroy.type_of_work VALUES (6, 'Управление проектами');
INSERT INTO stroy.type_of_work VALUES (7, 'Девелопмент');


--
-- TOC entry 5928 (class 0 OID 4886102)
-- Dependencies: 518
-- Data for Name: unit_type; Type: TABLE DATA; Schema: stroy; Owner: -
--

INSERT INTO stroy.unit_type VALUES (1, 'Блок');
INSERT INTO stroy.unit_type VALUES (2, 'Отдел');
INSERT INTO stroy.unit_type VALUES (3, 'Департамент');
INSERT INTO stroy.unit_type VALUES (4, 'Группа');


--
-- TOC entry 5950 (class 0 OID 0)
-- Dependencies: 491
-- Name: address_address_id_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.address_address_id_seq', 5000, true);


--
-- TOC entry 5951 (class 0 OID 0)
-- Dependencies: 493
-- Name: city_city_id_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.city_city_id_seq', 47, true);


--
-- TOC entry 5952 (class 0 OID 0)
-- Dependencies: 495
-- Name: company_structure_unit_id_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.company_structure_unit_id_seq', 105, true);


--
-- TOC entry 5953 (class 0 OID 0)
-- Dependencies: 497
-- Name: country_country_id_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.country_country_id_seq', 9, true);


--
-- TOC entry 5954 (class 0 OID 0)
-- Dependencies: 499
-- Name: customer_customer_id_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.customer_customer_id_seq', 278, true);


--
-- TOC entry 5955 (class 0 OID 0)
-- Dependencies: 502
-- Name: employee_employee_id_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.employee_employee_id_seq', 80, true);


--
-- TOC entry 5956 (class 0 OID 0)
-- Dependencies: 505
-- Name: employee_salary_history_employee_salary_history_id_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.employee_salary_history_employee_salary_history_id_seq', 1, false);


--
-- TOC entry 5957 (class 0 OID 0)
-- Dependencies: 507
-- Name: grade_salary_grade_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.grade_salary_grade_seq', 20, true);


--
-- TOC entry 5958 (class 0 OID 0)
-- Dependencies: 509
-- Name: person_person_id_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.person_person_id_seq', 80, true);


--
-- TOC entry 5959 (class 0 OID 0)
-- Dependencies: 511
-- Name: position_position_id_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.position_position_id_seq', 203, true);


--
-- TOC entry 5960 (class 0 OID 0)
-- Dependencies: 514
-- Name: project_payment_project_payment_id_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.project_payment_project_payment_id_seq', 462, true);


--
-- TOC entry 5961 (class 0 OID 0)
-- Dependencies: 515
-- Name: project_project_id_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.project_project_id_seq', 112, true);


--
-- TOC entry 5962 (class 0 OID 0)
-- Dependencies: 517
-- Name: type_of_work_type_of_work_id_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.type_of_work_type_of_work_id_seq', 7, true);


--
-- TOC entry 5963 (class 0 OID 0)
-- Dependencies: 519
-- Name: unit_type_unit_type_id_seq; Type: SEQUENCE SET; Schema: stroy; Owner: -
--

SELECT pg_catalog.setval('stroy.unit_type_unit_type_id_seq', 4, true);


--
-- TOC entry 5672 (class 2606 OID 4886121)
-- Name: address address_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address_id);


--
-- TOC entry 5674 (class 2606 OID 4886123)
-- Name: city city_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.city
    ADD CONSTRAINT city_pkey PRIMARY KEY (city_id);


--
-- TOC entry 5676 (class 2606 OID 4886125)
-- Name: company_structure company_structure_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.company_structure
    ADD CONSTRAINT company_structure_pkey PRIMARY KEY (unit_id);


--
-- TOC entry 5678 (class 2606 OID 4886127)
-- Name: country country_country_name_key; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.country
    ADD CONSTRAINT country_country_name_key UNIQUE (country_name);


--
-- TOC entry 5680 (class 2606 OID 4886129)
-- Name: country country_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_id);


--
-- TOC entry 5682 (class 2606 OID 4886131)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 5684 (class 2606 OID 4886133)
-- Name: customer_type_of_work customer_type_of_work_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.customer_type_of_work
    ADD CONSTRAINT customer_type_of_work_pkey PRIMARY KEY (customer_id, type_of_work_id);


--
-- TOC entry 5686 (class 2606 OID 4886135)
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- TOC entry 5688 (class 2606 OID 4886137)
-- Name: employee_position employee_position_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.employee_position
    ADD CONSTRAINT employee_position_pkey PRIMARY KEY (employee_id, position_id);


--
-- TOC entry 5690 (class 2606 OID 4886139)
-- Name: employee_salary_history employee_salary_history_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.employee_salary_history
    ADD CONSTRAINT employee_salary_history_pkey PRIMARY KEY (employee_salary_history_id);


--
-- TOC entry 5692 (class 2606 OID 4886141)
-- Name: grade_salary grade_salary_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.grade_salary
    ADD CONSTRAINT grade_salary_pkey PRIMARY KEY (grade);


--
-- TOC entry 5694 (class 2606 OID 4886143)
-- Name: person person_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (person_id);


--
-- TOC entry 5696 (class 2606 OID 4886145)
-- Name: position position_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy."position"
    ADD CONSTRAINT position_pkey PRIMARY KEY (position_id);


--
-- TOC entry 5704 (class 2606 OID 4886147)
-- Name: project_payment project_payment_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.project_payment
    ADD CONSTRAINT project_payment_pkey PRIMARY KEY (project_payment_id);


--
-- TOC entry 5699 (class 2606 OID 4886149)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (project_id);


--
-- TOC entry 5701 (class 2606 OID 4886151)
-- Name: project project_project_name_key; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.project
    ADD CONSTRAINT project_project_name_key UNIQUE (project_name);


--
-- TOC entry 5706 (class 2606 OID 4886153)
-- Name: type_of_work type_of_work_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.type_of_work
    ADD CONSTRAINT type_of_work_pkey PRIMARY KEY (type_of_work_id);


--
-- TOC entry 5708 (class 2606 OID 4886155)
-- Name: type_of_work type_of_work_type_of_work_name_key; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.type_of_work
    ADD CONSTRAINT type_of_work_type_of_work_name_key UNIQUE (type_of_work_name);


--
-- TOC entry 5710 (class 2606 OID 4886157)
-- Name: unit_type unit_type_pkey; Type: CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.unit_type
    ADD CONSTRAINT unit_type_pkey PRIMARY KEY (unit_type_id);


--
-- TOC entry 5697 (class 1259 OID 4886371)
-- Name: project_details_gin_idx; Type: INDEX; Schema: stroy; Owner: -
--

CREATE INDEX project_details_gin_idx ON stroy.project USING gin (project_details);


--
-- TOC entry 5702 (class 1259 OID 4886372)
-- Name: project_search_vector_gin_idx; Type: INDEX; Schema: stroy; Owner: -
--

CREATE INDEX project_search_vector_gin_idx ON stroy.project USING gin (search_vector);


--
-- TOC entry 5729 (class 2620 OID 4886474)
-- Name: project tsvectorupdate_project; Type: TRIGGER; Schema: stroy; Owner: -
--

CREATE TRIGGER tsvectorupdate_project BEFORE INSERT OR UPDATE OF project_name, description, project_details ON stroy.project FOR EACH ROW EXECUTE FUNCTION stroy.project_search_vector_update();


--
-- TOC entry 5712 (class 2606 OID 4886158)
-- Name: address address_city_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.address
    ADD CONSTRAINT address_city_id_fkey FOREIGN KEY (city_id) REFERENCES stroy.city(city_id);


--
-- TOC entry 5713 (class 2606 OID 4886163)
-- Name: city city_country_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.city
    ADD CONSTRAINT city_country_id_fkey FOREIGN KEY (country_id) REFERENCES stroy.country(country_id);


--
-- TOC entry 5714 (class 2606 OID 4886168)
-- Name: company_structure company_structure_unit_type_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.company_structure
    ADD CONSTRAINT company_structure_unit_type_fkey FOREIGN KEY (unit_type) REFERENCES stroy.unit_type(unit_type_id);


--
-- TOC entry 5715 (class 2606 OID 4886173)
-- Name: customer customer_address_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.customer
    ADD CONSTRAINT customer_address_id_fkey FOREIGN KEY (address_id) REFERENCES stroy.address(address_id);


--
-- TOC entry 5716 (class 2606 OID 4886178)
-- Name: customer_type_of_work customer_type_of_work_customer_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.customer_type_of_work
    ADD CONSTRAINT customer_type_of_work_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES stroy.customer(customer_id);


--
-- TOC entry 5717 (class 2606 OID 4886183)
-- Name: customer_type_of_work customer_type_of_work_type_of_work_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.customer_type_of_work
    ADD CONSTRAINT customer_type_of_work_type_of_work_id_fkey FOREIGN KEY (type_of_work_id) REFERENCES stroy.type_of_work(type_of_work_id);


--
-- TOC entry 5718 (class 2606 OID 4886188)
-- Name: employee employee_person_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.employee
    ADD CONSTRAINT employee_person_id_fkey FOREIGN KEY (person_id) REFERENCES stroy.person(person_id);


--
-- TOC entry 5719 (class 2606 OID 4886193)
-- Name: employee_position employee_position_employee_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.employee_position
    ADD CONSTRAINT employee_position_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES stroy.employee(employee_id);


--
-- TOC entry 5720 (class 2606 OID 4886198)
-- Name: employee_position employee_position_position_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.employee_position
    ADD CONSTRAINT employee_position_position_id_fkey FOREIGN KEY (position_id) REFERENCES stroy."position"(position_id);


--
-- TOC entry 5721 (class 2606 OID 4886203)
-- Name: employee_salary_history employee_salary_history_employee_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.employee_salary_history
    ADD CONSTRAINT employee_salary_history_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES stroy.employee(employee_id);


--
-- TOC entry 5722 (class 2606 OID 4886208)
-- Name: employee_salary_history employee_salary_history_position_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.employee_salary_history
    ADD CONSTRAINT employee_salary_history_position_id_fkey FOREIGN KEY (position_id) REFERENCES stroy."position"(position_id);


--
-- TOC entry 5723 (class 2606 OID 4886213)
-- Name: person person_address_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.person
    ADD CONSTRAINT person_address_id_fkey FOREIGN KEY (address_id) REFERENCES stroy.address(address_id);


--
-- TOC entry 5724 (class 2606 OID 4886218)
-- Name: position position_grade_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy."position"
    ADD CONSTRAINT position_grade_fkey FOREIGN KEY (grade) REFERENCES stroy.grade_salary(grade);


--
-- TOC entry 5725 (class 2606 OID 4886223)
-- Name: position position_unit_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy."position"
    ADD CONSTRAINT position_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES stroy.company_structure(unit_id);


--
-- TOC entry 5726 (class 2606 OID 4886228)
-- Name: project project_customer_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.project
    ADD CONSTRAINT project_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES stroy.customer(customer_id);


--
-- TOC entry 5728 (class 2606 OID 4886233)
-- Name: project_payment project_payment_project_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.project_payment
    ADD CONSTRAINT project_payment_project_id_fkey FOREIGN KEY (project_id) REFERENCES stroy.project(project_id);


--
-- TOC entry 5727 (class 2606 OID 4886238)
-- Name: project project_project_manager_id_fkey; Type: FK CONSTRAINT; Schema: stroy; Owner: -
--

ALTER TABLE ONLY stroy.project
    ADD CONSTRAINT project_project_manager_id_fkey FOREIGN KEY (project_manager_id) REFERENCES stroy.employee(employee_id);


-- Completed on 2026-07-04 14:26:40

--
-- PostgreSQL database dump complete
--

