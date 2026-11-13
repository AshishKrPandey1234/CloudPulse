package com.cloudpulse;

import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.lang.management.ManagementFactory;
import java.net.InetAddress;

@SpringBootApplication
public class CloudPulseApplication {

    private static final Logger log = LoggerFactory.getLogger(CloudPulseApplication.class);

    public static void main(String[] args) {
        SpringApplication.run(CloudPulseApplication.class, args);
    }

    @EventListener(ApplicationReadyEvent.class)
    public void onStartup() {
        try {
            String host = InetAddress.getLocalHost().getHostName();
            String ip = InetAddress.getLocalHost().getHostAddress();
            long uptime = ManagementFactory.getRuntimeMXBean().getUptime();

            log.info("==================================================================");
            log.info(" CloudPulse Microservice successfully initialized!");
            log.info(" Host: {} ({})", host, ip);
            log.info(" JVM Uptime at startup: {} ms", uptime);
            log.info(" Health Endpoint: http://localhost:8080/health");
            log.info(" Status API: http://localhost:8080/api/status");
            log.info(" Prometheus Scrape Target: http://localhost:8080/actuator/prometheus");
            log.info("==================================================================");
        } catch (Exception e) {
            log.warn("Could not determine local network info: {}", e.getMessage());
        }
    }
}
