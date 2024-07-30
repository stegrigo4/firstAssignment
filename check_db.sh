#!/bin/sh

# Configuration
MYSQL_USER="root"
MYSQL_PORT="3306"
MYSQL_PASSWORD="${TEST_DB_PASSWORD}"
MYSQL_DATABASE="${TEST_DB}"
MYSQL_TABLE="words"
MYSQL_COLUMN="word"
MYSQL_HOST="test_database_container"

function query_database() {
  echo "Querying the database for the specific value..."
  QUERY_RESULT=$(mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -D "$MYSQL_DATABASE" -se "SELECT word FROM $MYSQL_TABLE where word='Test'")

  if [ "$QUERY_RESULT" == "Test" ]; then
    echo "Query result(s):"
    echo "$QUERY_RESULT"
    return 0
  else      
    echo "No matching records found."
    return 1
  fi
}

# Loop to check the database every 5 seconds for up to 60 seconds
for ((i=0; i<12; i++)); do
  query_database
  if [ $? -eq 0 ]; then
    echo "Success: Found the matching record."
    exit 0
  fi
  echo "Retrying in 5 seconds..."
  sleep 5
done

echo "Failed: Could not find the matching record after 60 seconds."
exit 1