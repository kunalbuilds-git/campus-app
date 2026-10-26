BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "attendance_entry" (
    "id" bigserial PRIMARY KEY,
    "authUserId" text NOT NULL,
    "subjectCode" text NOT NULL,
    "subjectName" text NOT NULL,
    "attended" bigint NOT NULL,
    "total" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "attendance_user_subject_idx" ON "attendance_entry" USING btree ("authUserId", "subjectCode");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "notice" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "body" text NOT NULL,
    "category" text NOT NULL,
    "office" text NOT NULL,
    "publishedAt" timestamp without time zone NOT NULL,
    "pinned" boolean NOT NULL DEFAULT false
);

-- Indexes
CREATE INDEX "notice_published_idx" ON "notice" USING btree ("publishedAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "shared_item" (
    "id" bigserial PRIMARY KEY,
    "code" text NOT NULL,
    "kind" text NOT NULL,
    "payload" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "shared_item_code_idx" ON "shared_item" USING btree ("code");


--
-- MIGRATION VERSION FOR campus_quiz
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('campus_quiz', '20261025224920947', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025224920947', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
