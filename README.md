# Country View API

A Rails 8 API application configured with Docker Compose, PostgreSQL, RSpec, Swagger documentation, Solid Cache, and Solid Cable that helps to see Countries informations. This project works together with the **Country Client** (Next.js frontend) to provide a complete country exploration experience.

## Prerequisites

- Docker
- Docker Compose (`docker compose` not `docker-compose`)
- Git

## Quick Start

### Option 1: Run Both Projects Together (Recommended)

1. **Navigate to the parent directory**
   ```bash
   cd ..  # From country_api directory
   ```

2. **Setup environment variables**
   ```bash
   cd country_api
   cp .env.example .env
   # Edit .env with your specific values
   cd ..
   ```

3. **Start all services (API + Client + Database)**
   ```bash
   ./start-projects.sh
   # Or manually: docker-compose up --build -d
   ```

4. **Access your applications**
   - **Rails API**: http://localhost:3000
   - **Next.js Client**: http://localhost:3001
   - **PostgreSQL**: localhost:5432

### Option 2: Run Only the API

1. **Setup environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your specific values
   ```

2. **Start development environment**
   ```bash
   docker compose up --build
   ```

3. **Setup the database**
   ```bash
   docker compose exec api rails db:create
   docker compose exec api rails db:migrate
   ```

4. **Generate RSpec and Swagger configuration**
   ```bash
   docker compose exec api rails generate rspec:install
   docker compose exec api rails generate rswag:install
   ```

## Environment Configuration

Copy `.env.example` to `.env` and configure the following variables:

### Database Configuration
- `DATABASE_URL` - Complete PostgreSQL connection string
- `POSTGRES_DB` - Database name
- `POSTGRES_USER` - Database username
- `POSTGRES_PASSWORD` - Database password
- `POSTGRES_PORT` - External PostgreSQL port (default: 5432)

### Rails Configuration
- `RAILS_ENV` - Rails environment (development/production)
- `RAILS_PORT` - External Rails port (default: 3000)
- `RAILS_INTERNAL_PORT` - Internal container port (3000 for dev, 80 for prod)
- `SECRET_KEY_BASE` - Rails secret key for development
- `RAILS_MASTER_KEY` - Rails master key for production

### Docker Configuration
- `DOCKERFILE` - Which Dockerfile to use (Dockerfile.dev/Dockerfile)

## Development vs Production

### Development (Default)
```bash
# Uses Dockerfile.dev and development settings
docker compose up --build
```

### Production
```bash
# Set environment variables for production
DOCKERFILE=Dockerfile RAILS_INTERNAL_PORT=80 docker compose up --build
```

Or update your `.env` file:
```
DOCKERFILE=Dockerfile
RAILS_INTERNAL_PORT=80
RAILS_ENV=production
```

## Services

### Complete Project Setup (Both API + Client)
When running both projects together from the parent directory:

- **Rails API**: Port 3000 (configurable via `RAILS_PORT`)
- **Next.js Client**: Port 3001
- **PostgreSQL**: Port 5432 (configurable via `POSTGRES_PORT`)
- **All services** include volumes for live code reloading

### API Only Setup
When running only the API from the country_api directory:

- **Web Service (Development)**: Port 3000 (configurable via `RAILS_PORT`)
- **Production**: Port 3000 (or configured port) mapping to internal port 80
- Includes volumes for live code reloading

- **Database Service (Development)**: PostgreSQL 17
- Port 5433 (configurable via `POSTGRES_PORT`)
- Persistent data storage

## Features

### Testing with RSpec
- Configured for API testing
- Factory Bot for test data
- Run tests: `docker compose exec api bundle exec rspec`

### API Documentation with Swagger
- rswag gems for API documentation
- Access Swagger UI at: `http://localhost:3000/api-docs`
- Generate docs: `docker compose exec api rails rswag`

### Caching with Solid Cache
- Configured as Rails cache store
- Database-backed caching solution

### WebSockets with Solid Cable
- Configured as Action Cable adapter
- Database-backed WebSocket solution

## Common Commands

### Database Operations
```bash
# Create database
docker compose exec api rails db:create

# Run migrations
docker compose exec api rails db:migrate

# Seed database
docker compose exec api rails db:seed

# Reset database
docker compose exec api rails db:reset
```

### Testing
```bash
# Run all tests
docker compose exec api bundle exec rspec

# Run specific test file
docker compose exec api bundle exec rspec file/to/load_spec.rb

# Generate Swagger documentation
docker compose exec api rails rswag
```

### Rails Console
```bash
docker compose exec api rails console
```

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f web
```