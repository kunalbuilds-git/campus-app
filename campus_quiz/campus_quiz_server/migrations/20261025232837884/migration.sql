BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "shared_item" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "shared_item" (
    "id" bigserial PRIMARY KEY,
    "code" text NOT NULL,
    "kind" text NOT NULL,
    "payload" text NOT NULL,
    "createdBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "shared_item_code_idx" ON "shared_item" USING btree ("code");


--
-- MIGRATION VERSION FOR campus_quiz
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('campus_quiz', '20261025232837884', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025232837884', "timestamp" = now();

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
