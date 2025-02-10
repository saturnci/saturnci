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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: builds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builds (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    report character varying,
    branch_name character varying NOT NULL,
    commit_hash character varying NOT NULL,
    commit_message character varying NOT NULL,
    author_name character varying NOT NULL,
    build_machine_id character varying,
    test_output text,
    seed integer NOT NULL,
    cached_status character varying,
    deleted_at timestamp(6) without time zone,
    api_token character varying
);


--
-- Name: charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.charges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    run_id uuid NOT NULL,
    rate numeric NOT NULL,
    run_duration numeric NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: github_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.github_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    github_installation_id character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    account_name character varying,
    deleted_at timestamp(6) without time zone,
    github_app_installation_url character varying,
    installation_response_payload jsonb
);


--
-- Name: github_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.github_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    body jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    project_id uuid
);


--
-- Name: project_secrets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_secrets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    key character varying NOT NULL,
    value character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    github_repo_full_name character varying,
    user_id uuid NOT NULL,
    github_account_id uuid,
    active boolean DEFAULT true NOT NULL,
    start_builds_automatically_on_git_push boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    concurrency integer DEFAULT 2 NOT NULL
);


--
-- Name: run_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.run_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    run_id uuid NOT NULL,
    type integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.runs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    build_id uuid NOT NULL,
    runner_id character varying,
    test_output text,
    test_report text,
    system_logs text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    order_index integer NOT NULL,
    runner_rsa_key_path character varying,
    exit_code integer,
    snapshot_image_id character varying,
    deleted_at timestamp(6) without time zone,
    terminate_on_completion boolean DEFAULT true NOT NULL,
    json_output jsonb
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: solid_cable_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_cable_messages (
    id bigint NOT NULL,
    channel bytea NOT NULL,
    payload bytea NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    channel_hash bigint NOT NULL
);


--
-- Name: solid_cable_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_cable_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_cable_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_cable_messages_id_seq OWNED BY public.solid_cable_messages.id;


--
-- Name: test_case_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_case_runs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    identifier character varying NOT NULL,
    path character varying NOT NULL,
    line_number integer NOT NULL,
    status integer NOT NULL,
    duration double precision NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    run_id uuid NOT NULL,
    description character varying NOT NULL,
    exception text,
    exception_message text,
    exception_backtrace text
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying DEFAULT ''::character varying,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    confirmation_token character varying,
    confirmed_at timestamp(6) without time zone,
    confirmation_sent_at timestamp(6) without time zone,
    unconfirmed_email character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying,
    provider character varying,
    uid character varying,
    super_admin boolean DEFAULT false,
    deleted_at timestamp(6) without time zone,
    api_token character varying
);


--
-- Name: solid_cable_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_cable_messages ALTER COLUMN id SET DEFAULT nextval('public.solid_cable_messages_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: builds builds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builds
    ADD CONSTRAINT builds_pkey PRIMARY KEY (id);


--
-- Name: charges charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges
    ADD CONSTRAINT charges_pkey PRIMARY KEY (id);


--
-- Name: github_accounts github_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_accounts
    ADD CONSTRAINT github_accounts_pkey PRIMARY KEY (id);


--
-- Name: github_events github_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_events
    ADD CONSTRAINT github_events_pkey PRIMARY KEY (id);


--
-- Name: project_secrets project_secrets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_secrets
    ADD CONSTRAINT project_secrets_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: run_events run_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.run_events
    ADD CONSTRAINT run_events_pkey PRIMARY KEY (id);


--
-- Name: runs runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT runs_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: solid_cable_messages solid_cable_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_cable_messages
    ADD CONSTRAINT solid_cable_messages_pkey PRIMARY KEY (id);


--
-- Name: test_case_runs test_case_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_case_runs
    ADD CONSTRAINT test_case_runs_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_builds_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_project_id ON public.builds USING btree (project_id);


--
-- Name: index_charges_on_run_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charges_on_run_id ON public.charges USING btree (run_id);


--
-- Name: index_github_accounts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_github_accounts_on_user_id ON public.github_accounts USING btree (user_id);


--
-- Name: index_github_events_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_github_events_on_project_id ON public.github_events USING btree (project_id);


--
-- Name: index_project_secrets_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_secrets_on_project_id ON public.project_secrets USING btree (project_id);


--
-- Name: index_project_secrets_on_project_id_and_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_project_secrets_on_project_id_and_key ON public.project_secrets USING btree (project_id, key);


--
-- Name: index_projects_on_github_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_github_account_id ON public.projects USING btree (github_account_id);


--
-- Name: index_projects_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_user_id ON public.projects USING btree (user_id);


--
-- Name: index_run_events_on_run_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_run_events_on_run_id ON public.run_events USING btree (run_id);


--
-- Name: index_run_events_on_run_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_run_events_on_run_id_and_type ON public.run_events USING btree (run_id, type);


--
-- Name: index_runs_on_build_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runs_on_build_id ON public.runs USING btree (build_id);


--
-- Name: index_runs_on_build_id_and_order_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_runs_on_build_id_and_order_index ON public.runs USING btree (build_id, order_index);


--
-- Name: index_runs_on_runner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_runs_on_runner_id ON public.runs USING btree (runner_id);


--
-- Name: index_saturn_installations_on_user_and_github_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_saturn_installations_on_user_and_github_id ON public.github_accounts USING btree (user_id, github_installation_id);


--
-- Name: index_solid_cable_messages_on_channel; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_cable_messages_on_channel ON public.solid_cable_messages USING btree (channel);


--
-- Name: index_solid_cable_messages_on_channel_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_cable_messages_on_channel_hash ON public.solid_cable_messages USING btree (channel_hash);


--
-- Name: index_solid_cable_messages_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_cable_messages_on_created_at ON public.solid_cable_messages USING btree (created_at);


--
-- Name: index_test_case_runs_on_run_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_test_case_runs_on_run_id ON public.test_case_runs USING btree (run_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: unique_index_on_charges_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_index_on_charges_job_id ON public.charges USING btree (run_id);


--
-- Name: builds fk_rails_182d0b005e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builds
    ADD CONSTRAINT fk_rails_182d0b005e FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: projects fk_rails_191b01ff5e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_191b01ff5e FOREIGN KEY (github_account_id) REFERENCES public.github_accounts(id);


--
-- Name: project_secrets fk_rails_2d6a047f82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_secrets
    ADD CONSTRAINT fk_rails_2d6a047f82 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: charges fk_rails_45a8e3b900; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges
    ADD CONSTRAINT fk_rails_45a8e3b900 FOREIGN KEY (run_id) REFERENCES public.runs(id);


--
-- Name: github_accounts fk_rails_6912493ca3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_accounts
    ADD CONSTRAINT fk_rails_6912493ca3 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: runs fk_rails_79505557ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT fk_rails_79505557ef FOREIGN KEY (build_id) REFERENCES public.builds(id);


--
-- Name: run_events fk_rails_8c2b22156a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.run_events
    ADD CONSTRAINT fk_rails_8c2b22156a FOREIGN KEY (run_id) REFERENCES public.runs(id);


--
-- Name: test_case_runs fk_rails_935b9df0d6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_case_runs
    ADD CONSTRAINT fk_rails_935b9df0d6 FOREIGN KEY (run_id) REFERENCES public.runs(id);


--
-- Name: projects fk_rails_b872a6760a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_b872a6760a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: github_events fk_rails_bb9ac61101; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_events
    ADD CONSTRAINT fk_rails_bb9ac61101 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250210022907'),
('20250206201312'),
('20250206194717'),
('20250206023730'),
('20250206023126'),
('20250206021809'),
('20250205222758'),
('20250203140043'),
('20250202024952'),
('20250201215922'),
('20250201181245'),
('20250201170609'),
('20250201150133'),
('20250201150022'),
('20250201142001'),
('20250128155608'),
('20250126144204'),
('20250124020028'),
('20250124015026'),
('20250122235609'),
('20250122235048'),
('20250119152634'),
('20250119152134'),
('20250119142839'),
('20241122132129'),
('20241122130509'),
('20241117153647'),
('20241117152804'),
('20241117152027'),
('20241117144546'),
('20241117140845'),
('20241106184126'),
('20241104014827'),
('20241102231003'),
('20241101204057'),
('20241101202138'),
('20241027201813'),
('20241026162319'),
('20241023230135'),
('20241022170535');

