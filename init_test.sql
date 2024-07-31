-- Create the database schema
CREATE DATABASE IF NOT EXISTS grigo_db;
USE grigo_db;
-- CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
-- USE $MYSQL_DATABASE;

-- Create the names table
CREATE TABLE IF NOT EXISTS names (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Insert sample data
INSERT INTO names (name) VALUES ('Grigo');
INSERT INTO names (name) VALUES ('Bianca');
INSERT INTO names (name) VALUES ('Stefan');
INSERT INTO names (name) VALUES ('Alexia');