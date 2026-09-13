-- The always-on app identity has schema modification rights because migrations run
-- inside the app VM and there is no separate migration identity yet. This is an
-- intentional temporary trade-off for operational simplicity.
SELECT * FROM pgaadauth_create_principal('${APP_IDENTITY_NAME}', false, false);

GRANT CONNECT ON DATABASE ${DB_NAME} TO "${APP_IDENTITY_NAME}";
GRANT USAGE, CREATE ON SCHEMA public TO "${APP_IDENTITY_NAME}";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${APP_IDENTITY_NAME}";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "${APP_IDENTITY_NAME}";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL PRIVILEGES ON TABLES TO "${APP_IDENTITY_NAME}";
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL PRIVILEGES ON SEQUENCES TO "${APP_IDENTITY_NAME}";
