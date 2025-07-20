#!/bin/bash

echo "Sending test traces to Tempo..."

curl -X POST http://localhost:4318/v1/traces \
  -H "Content-Type: application/json" \
  -d '{
    "resourceSpans": [
      {
        "resource": {
          "attributes": [
            {"key": "service.name", "value": {"stringValue": "test-service"}},
            {"key": "service.version", "value": {"stringValue": "1.0.0"}}
          ]
        },
        "scopeSpans": [
          {
            "scope": {"name": "test-scope"},
            "spans": [
              {
                "traceId": "00000000000000000000000000000001",
                "spanId": "0000000000000001",
                "name": "HTTP GET /api/users",
                "kind": 1,
                "startTimeUnixNano": "'$(date +%s)000000000'",
                "endTimeUnixNano": "'$(($(date +%s) + 100))000000000'",
                "attributes": [
                  {"key": "http.method", "value": {"stringValue": "GET"}},
                  {"key": "http.url", "value": {"stringValue": "/api/users"}},
                  {"key": "http.status_code", "value": {"intValue": 200}}
                ]
              },
              {
                "traceId": "00000000000000000000000000000001",
                "spanId": "0000000000000002",
                "parentSpanId": "0000000000000001",
                "name": "Database Query",
                "kind": 2,
                "startTimeUnixNano": "'$(($(date +%s) + 10))000000000'",
                "endTimeUnixNano": "'$(($(date +%s) + 80))000000000'",
                "attributes": [
                  {"key": "db.system", "value": {"stringValue": "postgresql"}},
                  {"key": "db.statement", "value": {"stringValue": "SELECT * FROM users"}}
                ]
              }
            ]
          }
        ]
      }
    ]
  }'

echo ""
echo "✓ Test traces sent to Tempo!"
echo "You can now view them in Grafana at: http://localhost:3000"
echo "Navigate to: Explore > Tempo > TraceQL query: {resource.service.name=\"test-service\"}" 