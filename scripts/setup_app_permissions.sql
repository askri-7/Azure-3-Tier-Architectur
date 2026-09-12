-- Run this script as the configured PostgreSQL Entra administrator.
-- APP_IDENTITY_NAME must be the user-assigned identity name, not its client ID.
SELECT * FROM pgaadauth_create_principal('${APP_IDENTITY_NAME}', false, false);
SELECT * FROM pgaadauth_create_principal('${MIGRATION_IDENTITY_NAME}', false, false);

-- Grant application access to the target database and schema.
GRANT CONNECT ON DATABASE ${DB_NAME} TO "${APP_IDENTITY_NAME}";
GRANT USAGE ON SCHEMA public TO "${APP_IDENTITY_NAME}";

-- Prisma needs table write access and sequence usage for inserts and migrations.
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "${APP_IDENTITY_NAME}";
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO "${APP_IDENTITY_NAME}";

-- Preserve access for tables and sequences created later by migrations.
ALTER DEFAULT PRIVILEGES IN SCHEMA public
	GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${APP_IDENTITY_NAME}";
ALTER DEFAULT PRIVILEGES IN SCHEMA public
	GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO "${APP_IDENTITY_NAME}";

-- Migration identity needs schema modification rights, but the runtime app does not.
GRANT CONNECT ON DATABASE ${DB_NAME} TO "${MIGRATION_IDENTITY_NAME}";
GRANT USAGE, CREATE ON SCHEMA public TO "${MIGRATION_IDENTITY_NAME}";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${MIGRATION_IDENTITY_NAME}";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "${MIGRATION_IDENTITY_NAME}";