package com.cloudpulse.controller;

import com.cloudpulse.dto.StatusLogRequest;
import com.cloudpulse.model.StatusLog;
import com.cloudpulse.repository.StatusLogRepository;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.InetAddress;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/status")
public class StatusLogController {

    private static final Logger log = LoggerFactory.getLogger(StatusLogController.class);

    private final StatusLogRepository repository;
    private final Counter statusWriteCounter;
    private final Counter statusReadCounter;

    public StatusLogController(StatusLogRepository repository, MeterRegistry meterRegistry) {
        this.repository = repository;
        this.statusWriteCounter = Counter.builder("cloudpulse_status_writes_total")
                .description("Total number of status log entries written")
                .register(meterRegistry);
        this.statusReadCounter = Counter.builder("cloudpulse_status_reads_total")
                .description("Total number of status queries performed")
                .register(meterRegistry);
    }

    @GetMapping
    public ResponseEntity<List<StatusLog>> getStatusLogs() {
        statusReadCounter.increment();
        List<StatusLog> logs = repository.findTop20ByOrderByCreatedAtDesc();
        return ResponseEntity.ok(logs);
    }

    @GetMapping("/latest")
    public ResponseEntity<?> getLatestStatusLog() {
        statusReadCounter.increment();
        return repository.findTopByOrderByCreatedAtDesc()
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.ok(Map.of("message", "No status logs recorded yet.")));
    }

    @PostMapping
    public ResponseEntity<StatusLog> createStatusLog(@RequestBody StatusLogRequest request) {
        statusWriteCounter.increment();

        String hostname = "unknown";
        try {
            hostname = InetAddress.getLocalHost().getHostName();
        } catch (Exception e) {
            log.warn("Failed to resolve hostname: {}", e.getMessage());
        }

        String serviceName = (request.getServiceName() != null && !request.getServiceName().isBlank())
                ? request.getServiceName() : "CloudPulse-Service";
        String status = (request.getStatus() != null && !request.getStatus().isBlank())
                ? request.getStatus().toUpperCase() : "HEALTHY";
        String message = (request.getMessage() != null && !request.getMessage().isBlank())
                ? request.getMessage() : "Routine status ping";
        String env = (request.getEnvironment() != null && !request.getEnvironment().isBlank())
                ? request.getEnvironment() : "production";

        StatusLog entity = new StatusLog(serviceName, status, message, env, hostname);
        StatusLog saved = repository.save(entity);

        log.info("Persisted status pulse [id={}, service={}, status={}]", saved.getId(), saved.getServiceName(), saved.getStatus());
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
    }
}
