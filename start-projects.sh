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
export CLIENT_PORT=${CLIENT_PORT:-3001}
export RAILS_ENV=${RAILS_ENV:-development}

echo "📊 Environment Configuration:"
echo "   - Rails API Port: $RAILS_PORT"
echo "   - PostgreSQL Port: $POSTGRES_PORT"
echo "   - Client Port: $CLIENT_PORT"
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
sleep 5

# Check if database container is ready
echo "🗄️  Checking database container..."
echo -n "   Waiting for database container"
until docker compose exec -T db pg_isready -U $POSTGRES_USER > /dev/null 2>&1; do
    echo -n "."
    sleep 2
done
echo " ✅"

echo "✅ Database is ready!"

# Wait for Rails application to be ready
echo "🚀 Waiting for Rails application to be ready..."
echo -n "   Checking Rails availability"
until docker compose exec -T api bundle exec rails --version > /dev/null 2>&1; do
    echo -n "."
    sleep 2
done
echo " ✅"

# Additional wait to ensure Rails environment is fully loaded
echo -n "   Waiting for Rails environment"
sleep 5
echo " ✅"

# Run database setup if needed
echo "🔧 Setting up database..."
echo -n "   Checking database status"
if ! docker compose exec -T api bundle exec rails db:version > /dev/null 2>&1; then
    echo " - Creating database..."
    if docker compose exec -T api bundle exec rails db:create; then
        echo "   ✅ Database created successfully"
    else
        echo "   ❌ Failed to create database"
        exit 1
    fi
else
    echo " - Database exists"
fi

echo -n "   Running migrations"
if docker compose exec -T api bundle exec rails db:migrate; then
    echo " ✅"
else
    echo " ❌"
    echo "   ❌ Failed to run migrations"
    exit 1
fi

# Check if countries exist, if not run seeds
echo "🌍 Checking country data..."
echo -n "   Counting existing countries"
COUNTRY_COUNT=$(docker compose exec -T api bundle exec rails runner "puts Country.count" 2>/dev/null 2>&1 | grep -E '^[0-9]+$' || echo "0")

if [ "$COUNTRY_COUNT" -eq "0" ]; then
    echo " - No countries found, running seeds..."
    if docker compose exec -T api bundle exec rails db:seed; then
        echo "   ✅ Seeding completed"
    else
        echo "   ❌ Failed to run seeds"
        exit 1
    fi
else
    echo " - Found $COUNTRY_COUNT countries"
fi

echo "🔄 Starting background job worker..."
docker compose exec -d api bundle exec solid_queue --config config/solid_queue.yml
echo "📱 Client is configured to use Docker service 'api' for API calls"

echo ""
echo "🎉 Project started successfully!"
echo ""
echo "🌐 Access your application:"
echo "   - Rails API: http://localhost:$RAILS_PORT"
echo "   - API Documentation: http://localhost:$RAILS_PORT/api-docs"
echo "   - Client: http://localhost:$CLIENT_PORT"
echo "   - PostgreSQL: localhost:$POSTGRES_PORT"
echo ""
echo "📝 Useful commands:"
echo "   - View logs: docker compose logs -f"
echo "   - Rails console: docker compose exec api bundle exec rails console"
echo "   - Run tests: docker compose exec api bundle exec rspec"
echo "   - Update countries: docker compose exec api bundle exec rails countries:update"
echo "   - Check data freshness: docker compose exec api bundle exec rails countries:check_freshness"
echo "   - Rebuild client: docker compose build client"
echo "   - Client logs: docker compose logs -f client"
echo ""
echo "🛑 To stop: docker compose down"
echo "🔄 To restart: docker compose restart"
