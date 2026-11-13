package com.cloudpulse.dto;

public class StatusLogRequest {

    private String serviceName;
    private String status;
    private String message;
    private String environment;

    public StatusLogRequest() {
    }

    public StatusLogRequest(String serviceName, String status, String message, String environment) {
        this.serviceName = serviceName;
        this.status = status;
        this.message = message;
        this.environment = environment;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getEnvironment() {
        return environment;
    }

    public void setEnvironment(String environment) {
        this.environment = environment;
    }
}
