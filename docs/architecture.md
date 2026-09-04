# Pharmacy OS - Architecture Document

## 1. Tech Stack (Final - Non-Negotiable)

| Layer | Technology | Version |
|-------|------------|---------|
| **Frontend Framework** | Next.js | 14+ |
| **UI Library** | React | 18+ |
| **Language** | TypeScript | 5.4+ |
| **Styling** | Tailwind CSS | 3.4+ |
| **Backend Language** | Go | 1.21+ |
| **HTTP Framework** | Gin/Echo | Latest |
| **Database** | PostgreSQL 15+ via Supabase | - |
| **ORM** | Raw SQL (no ORM) | - |
| **Connection Pooling** | Supavisor | Port 6543 |
| **Authentication** | JWT + Supabase Auth | - |
| **Multi-tenancy** | RLS (Row Level Security) | - |
| **Background Jobs** | River Queue (Postgres-based) | - |
| **Real-time** | Supabase Realtime | - |
| **Monorepo** | Turborepo | 2.0+ |

## 2. Project Structure

```
pharmacy-os/
├── apps/
│   ├── marketing/              # Public marketing website
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── page.tsx
│   │   │   │   ├── layout.tsx
│   │   │   │   ├── globals.css
│   │   │   │   ├── pricing/
│   │   │   │   ├── privacy-policy/
│   │   │   │   └── terms-of-use/
│   │   │   └── components/
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── pharmacy-app/           # Main pharmacy management app
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── (auth)/login/
│   │   │   │   └── (dashboard)/
│   │   │   │       ├── page.tsx (dashboard)
│   │   │   │       ├── inventory/
│   │   │   │       │   └── [id]/
│   │   │   │       ├── employees/
│   │   │   │       │   └── new/
│   │   │   │       ├── attendance/
│   │   │   │       ├── settings/
│   │   │   │       ├── reports/
│   │   │   │       └── branches/
│   │   │   │           └── new/
│   │   │   ├── components/
│   │   │   │   ├── layout/ (sidebar, header)
│   │   │   │   └── ui/ (button, card, input, table, modal, badge, etc.)
│   │   │   ├── lib/ (supabase, auth, api, utils, validations)
│   │   │   ├── hooks/ (useAuth, usePharmacy, useEmployees, useInventory, useAttendance)
│   │   │   └── types/ (employee, medication, branch, attendance, pharmacy)
│   │   └── package.json
│   │
│   └── admin-dashboard/        # Platform admin panel
│       ├── src/
│       │   ├── app/
│       │   │   ├── page.tsx
│       │   │   ├── pharmacies/
│       │   │   ├── analytics/
│       │   │   ├── settings/
│       │   │   └── employees/
│       │   ├── components/
│       │   ├── lib/
│       │   ├── hooks/
│       │   └── types/
│       └── package.json
│
├── backend/                    # Go API server
│   ├── cmd/server/main.go     # Entry point
│   ├── go.mod
│   └── internal/
│       ├── config/            # Configuration loading
│       ├── models/            # Data structures (models.go + permission.go)
│       ├── handlers/          # HTTP handlers
│       │   ├── handler.go
│       │   ├── pharmacy_handler.go
│       │   ├── branch_handler.go
│       │   ├── employee_handler.go
│       │   ├── inventory_handler.go
│       │   ├── attendance_handler.go
│       │   └── dashboard_handler.go
│       ├── services/          # Business logic layer
│       │   ├── pharmacy_service.go
│       │   ├── branch_service.go
│       │   ├── employee_service.go
│       │   ├── inventory_service.go
│       │   └── attendance_service.go
│       ├── repository/        # Data access layer
│       │   ├── pharmacy_repo.go
│       │   ├── branch_repo.go
│       │   ├── employee_repo.go
│       │   ├── medication_repo.go
│       │   └── attendance_repo.go
│       └── middleware/         # HTTP middleware
│           ├── logging.go
│           ├── recovery.go
│           ├── cors.go
│           ├── auth.go
│           ├── tenant.go
│           └── permissions.go  # Reserved for permissions system
│
├── infra/
│   ├── docker-compose.yml     # Local development infrastructure
│   └── supabase/migrations/
│       ├── 00000000000001_init.sql
│       └── 00000000000002_permissions_system.sql  # Reserved for permissions
│
└── docs/
    └── architecture.md        # This document
```

## 3. Database Schema

### Core Tables

#### `pharmacies` (Tenant Table)
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, DEFAULT uuid_generate_v4() |
| name | VARCHAR(255) | NOT NULL |
| email | VARCHAR(255) | UNIQUE, NOT NULL |
| phone | VARCHAR(50) | - |
| plan_type | ENUM(free, pro, enterprise) | DEFAULT 'free' |
| is_active | BOOLEAN | DEFAULT true |
| created_at | TIMESTAMPTZ | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() |

#### `branches`
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| pharmacy_id | UUID | FK → pharmacies, NOT NULL |
| name | VARCHAR(255) | NOT NULL |
| address | TEXT | NOT NULL |
| phone | VARCHAR(50) | - |
| is_active | BOOLEAN | DEFAULT true |
| created_at | TIMESTAMPTZ | DEFAULT NOW() |

**RLS Policy**: Pharmacies can only see their own branches

#### `employees`
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| pharmacy_id | UUID | FK → pharmacies, NOT NULL |
| branch_id | UUID | FK → branches |
| first_name | VARCHAR(100) | NOT NULL |
| last_name | VARCHAR(100) | NOT NULL |
| email | VARCHAR(255) | NOT NULL |
| phone | VARCHAR(50) | - |
| password_hash | VARCHAR(255) | NOT NULL |
| role | ENUM(admin, pharmacist, cashier, stockkeeper) | DEFAULT 'cashier' |
| is_active | BOOLEAN | DEFAULT true |
| created_at | TIMESTAMPTZ | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() |

**Unique Index**: (email, pharmacy_id)
**RLS Policy**: Pharmacies can only see their own employees

#### `medications` (Inventory)
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| pharmacy_id | UUID | FK → pharmacies, NOT NULL |
| name | VARCHAR(255) | NOT NULL |
| generic_name | VARCHAR(255) | - |
| sku | VARCHAR(100) | NOT NULL |
| quantity | INTEGER | >= 0, DEFAULT 0 |
| min_stock_level | INTEGER | DEFAULT 10 |
| price | DECIMAL(10,2) | NOT NULL |
| expiry_date | DATE | - |
| created_at | TIMESTAMPTZ | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() |

**Unique Index**: (sku, pharmacy_id)
**RLS Policy**: Pharmacies can only see their own medications

#### `attendance_records` (PARTITIONED)
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | Part of PK |
| employee_id | UUID | FK → employees, NOT NULL |
| clock_in | TIMESTAMPTZ | Part of PK, NOT NULL |
| clock_out | TIMESTAMPTZ | - |
| notes | TEXT | - |

**Partitioning**: Monthly by `clock_in`
**Primary Key**: `(id, clock_in)` - MANDATORY for partitioning
**RLS Policy**: Through employees table join

#### `inventory_transfers`
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| pharmacy_id | UUID | FK → pharmacies, NOT NULL |
| from_branch_id | UUID | FK → branches |
| to_branch_id | UUID | FK → branches, NOT NULL |
| medication_id | UUID | FK → medications, NOT NULL |
| quantity | INTEGER | > 0 |
| status | VARCHAR(20) | pending/in_transit/completed/cancelled |
| requested_by | UUID | FK → employees |
| approved_by | UUID | FK → employees |
| created_at | TIMESTAMPTZ | DEFAULT NOW() |
| completed_at | TIMESTAMPTZ | - |

#### `audit_logs` (No RLS Required)
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| pharmacy_id | UUID | FK → pharmacies, NOT NULL |
| user_id | UUID | NOT NULL |
| action | VARCHAR(100) | NOT NULL |
| resource | VARCHAR(100) | NOT NULL |
| resource_id | UUID | - |
| details | JSONB | - |
| ip_address | INET | - |
| user_agent | TEXT | - |
| created_at | TIMESTAMPTZ | DEFAULT NOW() |

## 4. Authentication & Middleware Chain

### JWT Auth Flow
1. Client sends credentials to `/api/v1/auth/login`
2. Server validates against `employees` table
3. Server issues JWT with claims: `{ sub: user_id, pharmacy_id, role }`
4. Client includes JWT in Authorization header: `Bearer <token>`

### Middleware Order (Critical)
```
Logger → Recovery → CORS → Auth(JWT) → TenantContext(RLS) → Handler
```

### Tenant Context (RLS)
Every protected request must execute:
```sql
SET LOCAL app.current_pharmacy_id = '<pharmacy_id_from_jwt>';
```

This enables RLS policies to filter data by tenant automatically.

## 5. River Queue Job Types

| Job Type | Description | Trigger |
|----------|-------------|---------|
| `expiry_check` | Check for expiring medications | Daily cron |
| `low_stock_check` | Alert on low stock items | On stock change |
| `send_notification` | Send email/push notifications | On various events |
| `generate_report` | Generate periodic reports | Scheduled |
| `cleanup_old_data` | Archive old data | Monthly cron |

## 6. Supabase Realtime Usage

| Feature | Channel | Use Case |
|---------|---------|----------|
| Inventory updates | `pharmacy:{id}:inventory` | Real-time stock changes |
| Attendance sync | `pharmacy:{id}:attendance` | Live clock-in/out |
| Notifications | `user:{id}:notifications` | Push notifications |

## 7. API Endpoints

### Public Endpoints
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/auth/login` | User login |
| POST | `/api/v1/auth/register` | New pharmacy registration |
| GET | `/health` | Health check |

### Protected Endpoints (Require JWT)

#### Pharmacies
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/pharmacies` | List pharmacies (admin) |
| GET | `/api/v1/pharmacies/:id` | Get pharmacy details |
| POST | `/api/v1/pharmacies` | Create pharmacy |
| PUT | `/api/v1/pharmacies/:id` | Update pharmacy |

#### Branches
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/branches` | List branches |
| POST | `/api/v1/branches` | Create branch |
| GET | `/api/v1/branches/:id` | Get branch |
| PUT | `/api/v1/branches/:id` | Update branch |

#### Employees
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/employees` | List employees |
| POST | `/api/v1/employees` | Create employee |
| GET | `/api/v1/employees/:id` | Get employee |
| PUT | `/api/v1/employees/:id` | Update employee |
| DELETE | `/api/v1/employees/:id` | Deactivate employee |

#### Inventory
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/inventory` | List medications |
| POST | `/api/v1/inventory` | Add medication |
| GET | `/api/v1/inventory/:id` | Get medication |
| PUT | `/api/v1/inventory/:id` | Update medication |
| PATCH | `/api/v1/inventory/:id/stock` | Adjust stock |

#### Attendance
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/attendance/clock-in` | Clock in |
| POST | `/api/v1/attendance/clock-out` | Clock out |
| GET | `/api/v1/attendance` | List records |
| GET | `/api/v1/attendance/today` | Today's attendance |

#### Dashboard
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/dashboard/stats` | Dashboard statistics |
| GET | `/api/v1/dashboard/activity` | Recent activity |

## 8. Scaling Roadmap

### Phase 1: Development ($0/month)
- Local Supabase instance via Docker
- Single Go server
- Direct database connections

### Phase 2: Startup ($35/month)
- Supabase Free Tier
- Single VPS for backend
- Supavisor connection pooling

### Phase 3: Growth ($200-$1000+/month)
- Supabase Pro Tier
- Load balancer + multiple Go instances
- Read replicas for reporting
- CDN for static assets

### Phase 4: Enterprise (Custom)
- Dedicated infrastructure
- Multi-region deployment
- Advanced monitoring & alerting
- Custom integrations

## 9. Golden Rules

### Go Backend Rules
1. **Clean Architecture Only**: handlers → services → repository → DB
2. **No business logic in handlers**
3. **No SQL in services** - all queries in repository layer
4. **Always use prepared statements** - prevent SQL injection
5. **SET LOCAL for every tenant request**

### Database Rules
1. **All tables must have `pharmacy_id`** (except audit_logs which has it for filtering)
2. **RLS is mandatory** on all tenant data tables
3. **Index on `pharmacy_id`** for all tables
4. **Use correct INDEX syntax**: `CREATE INDEX name ON table(column);`
5. **Partitioned tables must have composite PK** including partition column

### Frontend Rules
1. **TypeScript strict mode** - no `any`
2. **Components must be reusable**
3. **All API calls through lib/api.ts**
4. **Use hooks for data fetching**

## 10. Prohibited Items (Do Not Use)

❌ **Redis** - Use River Queue for jobs, Supabase for caching
❌ **Kafka** - Use River Queue for async processing
❌ **Kubernetes** - Use simple VPS/deployment initially
❌ **WebSocket Hub** - Use Supabase Realtime
❌ **Custom Sharding** - Use Postgres partitions as designed
❌ **ORM** - Use raw SQL with pgx for performance
❌ **Global variables** - Use dependency injection

---

**Document Version**: 1.0
**Last Updated**: 2024
**Status**: Approved for Implementation
