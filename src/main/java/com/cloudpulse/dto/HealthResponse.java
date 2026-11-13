package com.cloudpulse.dto;

import java.util.Map;

public class HealthResponse {

    private String status;
    private String service;
    private String version;
    private String environment;
    private String timestamp;
    private long uptimeSeconds;
    private String databaseStatus;
    private Map<String, Object> systemMetrics;

    public HealthResponse() {
    }

    public HealthResponse(String status, String service, String version, String environment,
                          String timestamp, long uptimeSeconds, String databaseStatus,
                          Map<String, Object> systemMetrics) {
        this.status = status;
        this.service = service;
        this.version = version;
        this.environment = environment;
        this.timestamp = timestamp;
        this.uptimeSeconds = uptimeSeconds;
        this.databaseStatus = databaseStatus;
        this.systemMetrics = systemMetrics;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getService() {
        return service;
    }

    public void setService(String service) {
        this.service = service;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getEnvironment() {
        return environment;
    }

    public void setEnvironment(String environment) {
        this.environment = environment;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public long getUptimeSeconds() {
        return uptimeSeconds;
    }

    public void setUptimeSeconds(long uptimeSeconds) {
        this.uptimeSeconds = uptimeSeconds;
    }

    public String getDatabaseStatus() {
        return databaseStatus;
    }

    public void setDatabaseStatus(String databaseStatus) {
        this.databaseStatus = databaseStatus;
    }

    public Map<String, Object> getSystemMetrics() {
        return systemMetrics;
    }

    public void setSystemMetrics(Map<String, Object> systemMetrics) {
        this.systemMetrics = systemMetrics;
    }
}
