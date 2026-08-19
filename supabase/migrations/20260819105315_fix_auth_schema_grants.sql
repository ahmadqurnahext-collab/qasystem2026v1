-- Restore grants on all auth tables to supabase_auth_admin
-- These grants were missing, causing GoTrue to fail with "Database error querying schema"

GRANT USAGE ON SCHEMA auth TO supabase_auth_admin;

-- Grant all privileges on all auth tables to supabase_auth_admin
DO $$
DECLARE
  tbl text;
BEGIN
  FOR tbl IN
    SELECT tablename FROM pg_tables WHERE schemaname = 'auth'
  LOOP
    EXECUTE format('GRANT ALL PRIVILEGES ON TABLE auth.%I TO supabase_auth_admin', tbl);
  END LOOP;
END $$;

-- Also grant on sequences in auth schema
DO $$
DECLARE
  seq text;
BEGIN
  FOR seq IN
    SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'auth'
  LOOP
    EXECUTE format('GRANT ALL PRIVILEGES ON SEQUENCE auth.%I TO supabase_auth_admin', seq);
  END LOOP;
END $$;

-- Grant on schema functions
DO $$
DECLARE
  fn text;
BEGIN
  FOR fn IN
    SELECT proname FROM pg_proc WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'auth')
  LOOP
    EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA auth TO supabase_auth_admin');
  END LOOP;
END $$;
