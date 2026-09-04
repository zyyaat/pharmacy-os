# Pharmacy OS

A complete SaaS platform for pharmacy management - Scale-Ready from Day 1.

## Architecture

- **Monorepo** managed by Turborepo
- **Frontend**: 3 Next.js applications (marketing, pharmacy-app, admin-dashboard)
- **Backend**: Go API with Clean Architecture
- **Database**: PostgreSQL via Supabase with RLS multi-tenancy
- **Background Jobs**: River Queue (Postgres-based)
- **Real-time**: Supabase Realtime

## Project Structure

```
pharmacy-os/
├── apps/
│   ├── marketing/          # Public marketing website
│   ├── pharmacy-app/       # Main pharmacy management app
│   └── admin-dashboard/    # Admin panel for platform management
├── backend/                # Go API server
│   ├── cmd/server/         # Entry point
│   └── internal/
│       ├── handlers/       # HTTP handlers
│       ├── services/       # Business logic
│       ├── repository/     # Data access layer
│       ├── middleware/      # Auth, CORS, logging, etc.
│       ├── models/         # Data structures
│       └── config/         # Configuration
├── infra/
│   ├── docker-compose.yml  # Local development infrastructure
│   └── supabase/migrations/ # Database schema migrations
└── docs/                   # Architecture documentation
```

## Getting Started

```bash
# Install dependencies
npm install

# Start development servers
npm run dev

# Build for production
npm run build
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Next.js 14+, React 18+, TypeScript, Tailwind CSS |
| Backend | Go 21+, Gin/Echo framework |
| Database | PostgreSQL 15+ via Supabase |
| Auth | JWT + Supabase Auth |
| Multi-tenancy | RLS (Row Level Security) |
| Background Jobs | River Queue |
| Real-time | Supabase Realtime |
| Connection Pooling | Supavisor (port 6543) |

## Golden Rules

1. **RLS is mandatory** - All data access must go through RLS policies
2. **No Redis/Kafka** - Use River for jobs, Supabase Realtime for WebSocket
3. **Clean Architecture** - handlers → services → repository → DB
4. **SET LOCAL app.current_pharmacy_id** for tenant context
5. **All tables must have pharmacy_id** for multi-tenancy

## License

Private - All rights reserved
