-- Create the schema supapasskeys
CREATE SCHEMA supapasskeys;

-- Create the supapasskeys role to run migrations
CREATE ROLE supapasskeys WITH LOGIN PASSWORD 'supapasskeys';

-- Grant access to the schema supapasskeys
GRANT USAGE, CREATE ON SCHEMA supapasskeys TO supapasskeys;
