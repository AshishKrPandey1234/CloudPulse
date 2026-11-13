package com.cloudpulse;

import com.cloudpulse.dto.StatusLogRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class CloudPulseApplicationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("Context loads successfully")
    void contextLoads() {
    }

    @Test
    @DisplayName("GET /health should return 200 OK and healthy status")
    void testHealthEndpoint() throws Exception {
        mockMvc.perform(get("/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("UP")))
                .andExpect(jsonPath("$.service", is("CloudPulse-API")))
                .andExpect(jsonPath("$.databaseStatus", is("CONNECTED")));
    }

    @Test
    @DisplayName("POST and GET /api/status should record and retrieve status logs")
    void testStatusLogFlow() throws Exception {
        StatusLogRequest request = new StatusLogRequest(
                "PaymentGateway",
                "HEALTHY",
                "All upstream dependencies responding within 50ms",
                "test"
        );

        mockMvc.perform(post("/api/status")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.serviceName", is("PaymentGateway")))
                .andExpect(jsonPath("$.status", is("HEALTHY")))
                .andExpect(jsonPath("$.id", notNullValue()));

        mockMvc.perform(get("/api/status"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(greaterThanOrEqualTo(1))))
                .andExpect(jsonPath("$[0].serviceName", is("PaymentGateway")));
    }

    @Test
    @DisplayName("GET /actuator/prometheus should expose metrics scrape target")
    void testPrometheusEndpoint() throws Exception {
        mockMvc.perform(get("/actuator/prometheus"))
                .andExpect(status().isOk())
                .andExpect(content().string(containsString("jvm_memory_used_bytes")));
    }
}
