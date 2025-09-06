# 🚀 Supabase Studio Local Commands

## Quick Start Commands

### 1. Start Docker Desktop (if not running)
```bash
open -a Docker
```

### 2. Wait for Docker to start (optional check)
```bash
docker ps
```

### 3. Start Supabase Local Development
```bash
cd /Users/bhakinkhantarjeerawat/Documents/flutter_projects/flood_marker/flood_marker
supabase start
```

### 4. Check Supabase Status
```bash
supabase status
```

### 5. Open Supabase Studio in Browser
```bash
open http://127.0.0.1:54323
```

## Complete One-Line Command
```bash
open -a Docker && sleep 10 && cd /Users/bhakinkhantarjeerawat/Documents/flutter_projects/flood_marker/flood_marker && supabase start && open http://127.0.0.1:54323
```

## Service URLs (when running)

- **Supabase Studio:** http://127.0.0.1:54323
- **API URL:** http://127.0.0.1:54321
- **Database URL:** postgresql://postgres:postgres@127.0.0.1:54322/postgres
- **Inbucket (Email Testing):** http://127.0.0.1:54324
- **Analytics:** http://127.0.0.1:54327

## Stop Supabase
```bash
supabase stop
```

## Reset Database (if needed)
```bash
supabase db reset
```

## Troubleshooting

### If Docker is not running:
```bash
open -a Docker
# Wait for Docker to start, then run:
supabase start
```

### If ports are already in use:
```bash
supabase stop
supabase start
```

### Check if Supabase is running:
```bash
supabase status
```

## Notes

- Docker Desktop must be running for Supabase to work
- Supabase Studio will be available at http://127.0.0.1:54323
- All services run in Docker containers
- Database persists between restarts unless you run `supabase db reset`

## Project Configuration

- **Project ID:** flood_marker
- **Config File:** `supabase/config.toml`
- **Schema Files:** `supabase/schema.sql` and `supabase/schema_local.sql`
