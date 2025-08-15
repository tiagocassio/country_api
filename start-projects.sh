#!/bin/bash

echo "🚀 Starting Country API Project..."

# Check if .env file exists
if [ ! -f "./.env" ]; then
    echo "❌ Error: .env file not found"
    echo "Please create a .env file with the required environment variables"
    exit 1
fi

# Load environment variables
source ./.env

# Set default values if not defined
export RAILS_PORT=${RAILS_PORT:-3000}
export POSTGRES_PORT=${POSTGRES_PORT:-5433}
export RAILS_ENV=${RAILS_ENV:-development}

echo "📊 Environment Configuration:"
echo "   - Rails API Port: $RAILS_PORT"
echo "   - PostgreSQL Port: $POSTGRES_PORT"
echo "   - Rails Environment: $RAILS_ENV"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running"
    echo "Please start Docker and try again"
    exit 1
fi

# Start all services
echo "🐳 Starting Docker Compose services..."
docker compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if database is ready
echo "🗄️  Checking database connection..."
until docker compose exec -T api rails db:version > /dev/null 2>&1; do
    echo "   Waiting for database..."
    sleep 5
done

echo "✅ Database is ready!"

# Run database setup if needed
echo "🔧 Setting up database..."
if ! docker compose exec -T api rails db:version > /dev/null 2>&1; then
    echo "   Creating database..."
    docker compose exec -T api rails db:create
fi

echo "   Running migrations..."
docker compose exec -T api rails db:migrate

# Check if countries exist, if not run seeds
echo "🌍 Checking country data..."
COUNTRY_COUNT=$(docker compose exec -T api rails runner "puts Country.count" 2>/dev/null || echo "0")

if [ "$COUNTRY_COUNT" -eq "0" ]; then
    echo "   No countries found, running seeds..."
    docker compose exec -T api rails db:seed
else
    echo "   Found $COUNTRY_COUNT countries in database"
fi

# Start Solid Queue worker for background jobs
echo "🔄 Starting background job worker..."
docker compose exec -d api bundle exec solid_queue --config config/solid_queue.yml

echo ""
echo "🎉 Project started successfully!"
echo ""
echo "🌐 Access your application:"
echo "   - Rails API: http://localhost:$RAILS_PORT"
echo "   - API Documentation: http://localhost:$RAILS_PORT/api-docs"
echo "   - PostgreSQL: localhost:$POSTGRES_PORT"
echo ""
echo "📝 Useful commands:"
echo "   - View logs: docker compose logs -f"
echo "   - Rails console: docker compose exec api rails console"
echo "   - Run tests: docker compose exec api bundle exec rspec"
echo "   - Update countries: docker compose exec api rails countries:update"
echo "   - Check data freshness: docker compose exec api rails countries:check_freshness"
echo ""
echo "🛑 To stop: docker compose down"
echo "🔄 To restart: docker compose restart"
