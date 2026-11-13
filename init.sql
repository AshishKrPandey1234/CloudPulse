-- ===================================================================
-- CloudPulse Database Initialization Script
-- Executed on first startup of MySQL Docker container
-- ===================================================================

CREATE DATABASE IF NOT EXISTS cloudpulse_db;
USE cloudpulse_db;

CREATE TABLE IF NOT EXISTS status_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    message VARCHAR(500),
    environment VARCHAR(50),
    host VARCHAR(100),
    created_at DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Pre-seed initial health ping record
INSERT INTO status_logs (service_name, status, message, environment, host, created_at)
VALUES ('CloudPulse-Bootstrap', 'HEALTHY', 'Initial deployment health pulse verified', 'production', 'aws-ec2-node-01', NOW());
