#!/bin/bash

# Configuration
CONTAINER_NAME="test_database_container"
MYSQL_USER="root"
MYSQL_PORT="3306"
MYSQL_PASSWORD="${TEST_DB_PASSWORD}"
MYSQL_DATABASE="${TEST_DB}"

# Function to check if the MySQL container is ready
function wait_for_mysql() {
  echo "Waiting for MySQL container to be ready..."
  while true; do
    if docker exec "$CONTAINER_NAME" mysqladmin ping -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; then
      echo "MySQL is up and running!"
      break
    else
      echo "MySQL is not ready yet. Retrying in 5 seconds..."
      sleep 5
    fi
  done
}

# Main script execution
wait_for_mysql