package com.cloudpulse.controller;

import com.cloudpulse.dto.HealthResponse;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.lang.management.ManagementFactory;
import java.sql.Connection;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@RestController
public class HealthController {

    private final DataSource dataSource;
    private final Counter healthCheckCounter;

    @Value("${spring.profiles.active:default}")
    private String activeProfile;

    @Value("${cloudpulse.version:1.0.0}")
    private String appVersion;

    public HealthController(DataSource dataSource, MeterRegistry meterRegistry) {
        this.dataSource = dataSource;
        this.healthCheckCounter = Counter.builder("cloudpulse_health_checks_total")
                .description("Total number of health check requests received")
                .tag("endpoint", "/health")
                .register(meterRegistry);
    }

    @GetMapping("/health")
    public ResponseEntity<HealthResponse> checkHealth() {
        healthCheckCounter.increment();

        String dbStatus = "DISCONNECTED";
        boolean dbHealthy = false;

        try (Connection conn = dataSource.getConnection()) {
            if (conn.isValid(2)) {
                dbStatus = "CONNECTED";
                dbHealthy = true;
            }
        } catch (Exception e) {
            dbStatus = "ERROR: " + e.getMessage();
        }

        long uptimeSeconds = ManagementFactory.getRuntimeMXBean().getUptime() / 1000;
        Runtime runtime = Runtime.getRuntime();
        long totalMemoryMb = runtime.totalMemory() / (1024 * 1024);
        long freeMemoryMb = runtime.freeMemory() / (1024 * 1024);
        long usedMemoryMb = totalMemoryMb - freeMemoryMb;

        Map<String, Object> metrics = new HashMap<>();
        metrics.put("heapMemoryUsedMb", usedMemoryMb);
        metrics.put("heapMemoryTotalMb", totalMemoryMb);
        metrics.put("availableProcessors", runtime.availableProcessors());

        String overallStatus = dbHealthy ? "UP" : "DEGRADED";
        HttpStatus httpStatus = dbHealthy ? HttpStatus.OK : HttpStatus.SERVICE_UNAVAILABLE;

        HealthResponse response = new HealthResponse(
                overallStatus,
                "CloudPulse-API",
                appVersion,
                activeProfile,
                Instant.now().toString(),
                uptimeSeconds,
                dbStatus,
                metrics
        );

        return new ResponseEntity<>(response, httpStatus);
    }

    @GetMapping("/")
    public ResponseEntity<Map<String, Object>> root() {
        Map<String, Object> info = new HashMap<>();
        info.put("service", "CloudPulse DevOps Monitoring Microservice");
        info.put("status", "ONLINE");
        info.put("documentation", "https://github.com/AshishKrPandey1234/CloudPulse");
        info.put("endpoints", Map.of(
                "health", "/health",
                "status_api", "/api/status",
                "prometheus_metrics", "/actuator/prometheus",
                "actuator_health", "/actuator/health"
        ));
        return ResponseEntity.ok(info);
    }
}
