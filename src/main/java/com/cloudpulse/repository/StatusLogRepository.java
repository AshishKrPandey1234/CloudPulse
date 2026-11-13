package com.cloudpulse.repository;

import com.cloudpulse.model.StatusLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StatusLogRepository extends JpaRepository<StatusLog, Long> {

    List<StatusLog> findTop20ByOrderByCreatedAtDesc();

    Optional<StatusLog> findTopByOrderByCreatedAtDesc();

    long countByStatus(String status);
}
