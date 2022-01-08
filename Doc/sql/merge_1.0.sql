//CREATE DATABASE stegun_flashmem WITH ENCODING 'UTF-8';

DROP TABLE IF EXISTS game_message_queue;
DROP TABLE IF EXISTS game_stage;
DROP TABLE IF EXISTS game_session;
DROP TABLE IF EXISTS device_session;
DROP TABLE IF EXISTS device;

DROP SEQUENCE IF EXISTS game_message_queue_seq;
DROP SEQUENCE IF EXISTS game_stage_seq;
DROP SEQUENCE IF EXISTS game_session_seq;
DROP SEQUENCE IF EXISTS device_session_seq;
DROP SEQUENCE IF EXISTS device_seq;

CREATE SEQUENCE device_seq;
CREATE TABLE device ( 
	id INTEGER NOT NULL DEFAULT nextval('device_seq'::regclass) PRIMARY KEY,
	device_name VARCHAR(32) NOT NULL,
	identifier VARCHAR(40) NOT NULL,
	language VARCHAR(2) NOT NULL,
	token VARCHAR(64) NOT NULL,
    bundle_name VARCHAR(16) DEFAULT 'FlashMem',
	created_at TIMESTAMP,
	updated_at TIMESTAMP
);

CREATE SEQUENCE device_session_seq;
CREATE TABLE device_session (
    id INTEGER NOT NULL DEFAULT nextval('device_session_seq') PRIMARY KEY,
    device_name VARCHAR(32) NOT NULL,
    device_identifier VARCHAR(40) NOT NULL,
    session_start TIMESTAMP NOT NULL,
    session_auto_stop TIMESTAMP NOT NULL,
    session_stop TIMESTAMP,
    session_status VARCHAR NOT NULL DEFAULT 'available',
    is_bot BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE SEQUENCE game_session_seq;
CREATE TABLE game_session (
    id INTEGER NOT NULL DEFAULT nextval('game_session_seq') PRIMARY KEY,
    device_session_id_host INTEGER NOT NULL,
    device_session_id_guest INTEGER,
    stages INTEGER DEFAULT 0,
    main_score_host INTEGER DEFAULT 0,
    main_score_guest INTEGER DEFAULT 0,
    session_start TIMESTAMP NOT NULL,
    session_auto_stop TIMESTAMP NOT NULL,
    session_auto_expire TIMESTAMP NOT NULL,
    session_stop TIMESTAMP,
    session_status VARCHAR(10) NOT NULL DEFAULT 'waiting',
    host_message VARCHAR(1024),
    guest_message VARCHAR(1024),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT game_session_fk_1 FOREIGN KEY(device_session_id_host) REFERENCES device_session (id),
    CONSTRAINT game_session_fk_2 FOREIGN KEY(device_session_id_guest) REFERENCES device_session (id)
);

CREATE SEQUENCE game_stage_seq;
CREATE TABLE game_stage (
    id INTEGER NOT NULL DEFAULT nextval('game_stage_seq') PRIMARY KEY,
    game_session_id INTEGER NOT NULL,
    stage_number INTEGER DEFAULT 1 NOT NULL,
    difficulty VARCHAR(16),
    score_host INTEGER DEFAULT 0,
    score_guest INTEGER DEFAULT 0,
    game_path VARCHAR(1024),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT game_stage_fk_1 FOREIGN KEY(game_session_id) REFERENCES game_session (id)
);

CREATE SEQUENCE game_message_queue_seq;
CREATE TABLE game_message_queue (
    id INTEGER NOT NULL DEFAULT nextval('game_message_queue_seq') PRIMARY KEY,
    game_session_id INTEGER NOT NULL,
    receiver VARCHAR(5),
    message VARCHAR(1024),
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    is_push BOOLEAN DEFAULT FALSE NOT NULL,
    stage_difficulty VARCHAR(16),
    created_at TIMESTAMP,
    CONSTRAINT game_message_queue_fk_1 FOREIGN KEY(game_session_id) REFERENCES game_session (id)
);