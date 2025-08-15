# Country API

A comprehensive Rails 8 API application that provides country information through a RESTful API, configured with Docker Compose, PostgreSQL, RSpec, Swagger documentation, Solid Cache, and Solid Cable.

## 🌍 Overview

This API serves as a centralized source for country data, including:
- **Basic Information**: Name, codes (alpha2, alpha3), location coordinates
- **Demographics**: Population, area, capital cities
- **Geographic Details**: Region, subregion, borders, time zones
- **Economic Information**: Currencies, languages, calling codes
- **Political Information**: Official names, flags
- **Automatic Updates**: Daily synchronization with external Country API

The application fetches country data from external APIs and provides it through a clean, documented REST interface with automatic daily updates.

## 🚀 Quick Start

### Prerequisites
- Docker
- Docker Compose (`docker compose` not `docker-compose`)
- Git

### 1. Clone and Setup
```bash
git clone git@github.com:tiagocassio/country_api.git
git clone git@github.com:tiagocassio/country-client.git
cd country_api
```

### 2. Environment Configuration
```bash
# Copy and edit environment file
cp .env.example .env
# Edit .env with your specific values
```

### 3. Configure API Credentials
```bash
# Add your Country API credentials
docker compose exec api rails credentials:edit
```

### 4. One-Command Startup
```bash
# Make script executable and run
chmod +x start-projects.sh
./start-projects.sh
```

The startup script automatically:
- ✅ Starts all Docker services
- ✅ Sets up the database
- ✅ Runs migrations
- ✅ Seeds initial country data
- ✅ Starts background job workers
- ✅ Provides status and helpful commands

## 📡 API Endpoints

### Countries
- `GET /api/v1/countries` - List all countries with filtering and pagination
- `GET /api/v1/countries/:id` - Get detailed information about a specific country

### Authentication (Identity)
- `POST /api/identity/registrations` - User registration
- `POST /api/identity/sessions` - User login
- `DELETE /api/identity/sessions` - User logout
- `POST /api/identity/passwords` - Password reset
- `POST /api/identity/email_verifications` - Email verification

## 🔄 Country Update System

### Automatic Updates
The system automatically updates country information every day at 2:00 AM using background jobs.

### Manual Management
```bash
# Update all countries from API
docker compose exec api rails countries:update

# Update with statistics
docker compose exec api rails countries:update_with_stats

# Check data freshness
docker compose exec api rails countries:check_freshness
```

### Background Jobs
- **Solid Queue** processes background jobs
- **Daily country updates** run automatically
- **Error handling** and logging for failed updates
- **Statistics tracking** for created/updated countries

## 🏗️ Architecture

### Service Layer
- **CountryUpdateService**: Core business logic for country data management
- **API Integration**: Custom CountryApi client library
- **Data Processing**: Robust error handling and data validation

### Job System
- **UpdateCountriesJob**: Background job for country updates
- **Recurring Jobs**: Daily automatic updates
- **Queue Management**: Solid Queue for job processing

### Data Models
- **Country**: Comprehensive country information storage
- **User**: Authentication and user management
- **Session**: Secure session handling

## 🧪 Testing

### Test Coverage
- **100% Line Coverage** achieved
- **420+ test examples** covering all functionality
- **Comprehensive service testing** including edge cases
- **Job testing** with proper mocking

### Running Tests
```bash
# Run all tests
docker compose exec api bundle exec rspec

# Run specific test files
docker compose exec api bundle exec rspec spec/services/country_update_service_spec.rb
docker compose exec api bundle exec rspec spec/jobs/update_countries_job_spec.rb

# Run with coverage
docker compose exec api bundle exec rspec --format progress
```

### Test Structure
- **RSpec** for test framework
- **Factory Bot** for test data
- **VCR** for API response recording
- **WebMock** for HTTP request stubbing
- **Database Cleaner** for test isolation

## 🐳 Docker Configuration

### Services
- **Web**: Rails API application (Port 3000)
- **Database**: PostgreSQL 17 (Port 5433)
- **Cache**: Solid Cache for performance
- **Queue**: Solid Queue for background jobs

### Development vs Production
```bash
# Development (default)
./start-projects.sh

# Production
DOCKERFILE=Dockerfile RAILS_INTERNAL_PORT=80 ./start-projects.sh
```

## 🔧 Environment Configuration

### Required Variables
```bash
# Database
DATABASE_URL=postgresql://user:password@localhost:5433/country_api
POSTGRES_DB=country_api
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_PORT=5433

# Rails
RAILS_ENV=development
RAILS_PORT=3000
CLIENT_PORT=3001
SECRET_KEY_BASE=your_secret_key

## 📊 Monitoring and Maintenance

### Logs
```bash
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f web
docker compose logs -f db
```

### Database Management
```bash
# Rails console
docker compose exec api rails console

# Database reset
docker compose exec api rails db:reset

# Run migrations
docker compose exec api rails db:migrate
```

### Job Monitoring
```bash
# Check job status
docker compose exec api rails solid_queue:status

# View job logs
docker compose exec api tail -f log/solid_queue.log
```

### Generate Documentation
```bash
# Generate Swagger docs
docker compose exec api rails rswag

# View at http://localhost:3000/api-docs
```

## 🆘 Troubleshooting

### Common Issues
1. **Database connection errors**: Check PostgreSQL is running
2. **API key errors**: Verify credentials are set correctly
3. **Job failures**: Check Solid Queue worker is running
4. **Coverage drops**: Run full test suite to restore coverage

### Debug Commands
```bash
# Check service status
docker compose ps

# View service logs
docker compose logs api

# Test database connection
docker compose exec api rails db:version

# Check job queue
docker compose exec api rails solid_queue:status
```

**Built with ❤️ using Rails 8, Docker, and modern development practices**