#!/usr/bin/env python3
"""
CloudPulse Infrastructure & Synthetic Health Monitor
=====================================================
Automated prober that monitors the CloudPulse microservice health,
records response latencies, detects outages, logs telemetry,
and triggers alerts when SLA thresholds are breached.

Author: Ashish Kumar Pandey (ashishkrpandey1234)
Project: CloudPulse
Target: Leegality DevOps Production Standards
"""

import argparse
import json
import logging
import os
import sys
import time
from datetime import datetime, timezone
import requests

# ANSI Color Codes for DevOps Terminal Output
GREEN = "\033[92m"
YELLOW = "\033[93m"
RED = "\033[91m"
CYAN = "\033[96m"
BOLD = "\033[1m"
RESET = "\033[0m"


class CloudPulseHealthMonitor:
    def __init__(self, host: str, interval: int, timeout: int,
                 threshold_ms: float, max_consecutive_failures: int,
                 log_file: str, webhook_url: str = None):
        self.host = host.rstrip("/")
        self.health_url = f"{self.host}/health"
        self.status_api_url = f"{self.host}/api/status"
        self.prometheus_url = f"{self.host}/actuator/prometheus"
        self.interval = interval
        self.timeout = timeout
        self.threshold_ms = threshold_ms
        self.max_failures = max_consecutive_failures
        self.webhook_url = webhook_url or os.getenv("ALERT_WEBHOOK_URL")

        self.consecutive_failures = 0
        self.is_currently_down = False
        self.total_checks = 0
        self.successful_checks = 0

        # Configure file logger
        self.logger = logging.getLogger("CloudPulseMonitor")
        self.logger.setLevel(logging.INFO)
        formatter = logging.Formatter(
            '{"timestamp": "%(asctime)s", "level": "%(levelname)s", "message": %(message)s}'
        )
        file_handler = logging.FileHandler(log_file)
        file_handler.setFormatter(formatter)
        self.logger.addHandler(file_handler)

    def print_banner(self):
        banner = f"""
{CYAN}{BOLD}========================================================================
   CloudPulse Automated Telemetry & Health Probe
   Host Target:  {self.host}
   Probe Interval: {self.interval}s | Timeout: {self.timeout}s | SLA: {self.threshold_ms}ms
========================================================================{RESET}
"""
        print(banner)

    def send_alert(self, title: str, message: str, severity: str = "CRITICAL"):
        """Sends alert notification to console, log file, and optional webhook."""
        color = RED if severity == "CRITICAL" else GREEN if severity == "RECOVERED" else YELLOW
        print(f"\n{color}{BOLD}🚨 [{severity}] {title}{RESET}")
        print(f"{color}{message}{RESET}\n")

        # Record to structured JSON log
        self.logger.warning(json.dumps({
            "event": "ALERT",
            "severity": severity,
            "title": title,
            "message": message,
            "host": self.host
        }))

        # Send Webhook Notification (Slack/Discord/Teams compatible)
        if self.webhook_url:
            try:
                payload = {
                    "text": f"*{severity}: {title}*\n{message}\nTarget: `{self.host}`"
                }
                requests.post(self.webhook_url, json=payload, timeout=3)
            except Exception as e:
                print(f"{YELLOW}[WARN] Failed to dispatch webhook alert: {e}{RESET}")

    def probe_once(self) -> dict:
        """Executes a single synthetic probe against the /health endpoint."""
        self.total_checks += 1
        start_time = time.perf_counter()
        probe_result = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "target": self.health_url,
            "status_code": None,
            "latency_ms": 0.0,
            "healthy": False,
            "database_status": "UNKNOWN",
            "error": None
        }

        try:
            response = requests.get(self.health_url, timeout=self.timeout)
            latency_ms = (time.perf_counter() - start_time) * 1000
            probe_result["latency_ms"] = round(latency_ms, 2)
            probe_result["status_code"] = response.status_code

            if response.status_code == 200:
                payload = response.json()
                probe_result["healthy"] = payload.get("status") == "UP"
                probe_result["database_status"] = payload.get("databaseStatus", "UNKNOWN")
                probe_result["uptime_seconds"] = payload.get("uptimeSeconds", 0)
            else:
                probe_result["healthy"] = False
                probe_result["error"] = f"HTTP {response.status_code}: {response.text[:100]}"

        except requests.exceptions.Timeout:
            latency_ms = (time.perf_counter() - start_time) * 1000
            probe_result["latency_ms"] = round(latency_ms, 2)
            probe_result["error"] = f"Connection timed out after {self.timeout}s"
        except requests.exceptions.ConnectionError:
            latency_ms = (time.perf_counter() - start_time) * 1000
            probe_result["latency_ms"] = round(latency_ms, 2)
            probe_result["error"] = "Connection refused / host unreachable"
        except Exception as e:
            latency_ms = (time.perf_counter() - start_time) * 1000
            probe_result["latency_ms"] = round(latency_ms, 2)
            probe_result["error"] = str(e)

        return probe_result

    def process_result(self, res: dict):
        """Processes probe result, logs telemetry, and determines alerting states."""
        ts = res["timestamp"]
        latency = res["latency_ms"]
        status_code = res["status_code"]
        db = res["database_status"]
        err = res["error"]

        if res["healthy"]:
            self.successful_checks += 1
            self.consecutive_failures = 0

            # Check if this is a recovery from a prior outage
            if self.is_currently_down:
                self.is_currently_down = False
                self.send_alert(
                    "Service Recovered",
                    f"CloudPulse service at {self.host} has recovered and is UP. DB Status: {db}, Latency: {latency}ms.",
                    severity="RECOVERED"
                )

            # Check latency SLA breach
            if latency > self.threshold_ms:
                status_icon = f"{YELLOW}[HIGH LATENCY]{RESET}"
                latency_str = f"{YELLOW}{latency:6.2f}ms{RESET}"
            else:
                status_icon = f"{GREEN}[HEALTHY]{RESET}"
                latency_str = f"{GREEN}{latency:6.2f}ms{RESET}"

            print(f"{ts} | {status_icon} HTTP {status_code} | Latency: {latency_str} | DB: {GREEN}{db}{RESET}")

            # Structured file log
            self.logger.info(json.dumps(res))

        else:
            self.consecutive_failures += 1
            status_icon = f"{RED}[CRITICAL]{RESET}"
            print(f"{ts} | {status_icon} HTTP {status_code} | Latency: {latency:6.2f}ms | Error: {RED}{err}{RESET}")
            self.logger.error(json.dumps(res))

            # Trigger alert once threshold of failures is reached
            if self.consecutive_failures >= self.max_failures and not self.is_currently_down:
                self.is_currently_down = True
                self.send_alert(
                    "Application Downtime Detected",
                    f"CloudPulse service at {self.host} is failing health checks ({self.consecutive_failures} consecutive failures).\nError: {err}",
                    severity="CRITICAL"
                )

    def run_continuous(self):
        """Runs the monitoring loop indefinitely."""
        self.print_banner()
        try:
            while True:
                res = self.probe_once()
                self.process_result(res)
                time.sleep(self.interval)
        except KeyboardInterrupt:
            print(f"\n{CYAN}Monitoring halted by operator.{RESET}")
            self.print_summary()

    def run_once(self) -> int:
        """Runs a single probe and returns exit code 0 for healthy, 1 for failure (ideal for CI/CD)."""
        res = self.probe_once()
        self.process_result(res)
        return 0 if res["healthy"] else 1

    def print_summary(self):
        availability = (self.successful_checks / self.total_checks * 100) if self.total_checks > 0 else 0
        print(f"\n{BOLD}Probe Execution Summary:{RESET}")
        print(f"  Total Probes:       {self.total_checks}")
        print(f"  Successful Probes:  {self.successful_checks}")
        print(f"  Calculated Uptime:  {availability:.2f}%\n")


def main():
    parser = argparse.ArgumentParser(description="CloudPulse Synthetic Health Monitor")
    parser.add_argument("--host", default=os.getenv("TARGET_HOST", "http://localhost:8080"),
                        help="Target base URL (default: http://localhost:8080)")
    parser.add_argument("--interval", type=int, default=10,
                        help="Polling interval in seconds (default: 10)")
    parser.add_argument("--timeout", type=int, default=5,
                        help="Request timeout in seconds (default: 5)")
    parser.add_argument("--threshold-ms", type=float, default=500.0,
                        help="Latency SLA threshold in ms (default: 500)")
    parser.add_argument("--consecutive-failures", type=int, default=2,
                        help="Consecutive failures before alert (default: 2)")
    parser.add_argument("--log-file", default="health_monitor.log",
                        help="Log file path (default: health_monitor.log)")
    parser.add_argument("--webhook-url", default=None,
                        help="Optional alert webhook URL (Slack/Discord/Teams)")
    parser.add_argument("--once", action="store_true",
                        help="Execute a single check and exit with code (0 for healthy, 1 for failure)")

    args = parser.parse_args()

    monitor = CloudPulseHealthMonitor(
        host=args.host,
        interval=args.interval,
        timeout=args.timeout,
        threshold_ms=args.threshold_ms,
        max_consecutive_failures=args.consecutive_failures,
        log_file=args.log_file,
        webhook_url=args.webhook_url
    )

    if args.once:
        sys.exit(monitor.run_once())
    else:
        monitor.run_continuous()


if __name__ == "__main__":
    main()
