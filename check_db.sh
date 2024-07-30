#!/bin/bash

# MySQL connection details
MYSQL_HOST="test_db"  # Use the service name defined in docker-compose.yml
MYSQL_PORT="3306"
MYSQL_USER="root"
MYSQL_PASSWORD="${TEST_DB_PASSWORD}"
MYSQL_DATABASE="${TEST_DB}"

# Query to check for the entry
QUERY="SELECT COUNT(*) FROM words WHERE word='Test';"

wait_for_mysql() {
  echo "Waiting for MySQL to be ready..."
  while ! mysqladmin ping -h"$MYSQL_HOST" -P"$MYSQL_PORT" --silent; do
    echo -n "."
    sleep 1
  done
  echo "MySQL is up and running."
}

wait_for_mysql

# Run the query and capture the result
RESULT=$(mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -D "$MYSQL_DATABASE" -se "$QUERY")

# Check if the result is greater than 0
if [ "$RESULT" -gt 0 ]; then
  echo "Test passed: 'Test' entry found in the database."
  exit 0
else
  echo "Test failed: 'Test' entry not found in the database."
  exit 1
fi