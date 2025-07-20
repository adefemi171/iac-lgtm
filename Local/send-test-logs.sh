#!/bin/bash

echo "Sending test logs to Loki..."

curl -X POST http://localhost:3100/loki/api/v1/push \
  -H "Content-Type: application/json" \
  -d '{
    "streams": [
      {
        "stream": {
          "job": "test-app",
          "level": "info",
          "service": "web-server"
        },
        "values": [
          ["'$(date +%s)000000000'", "User logged in successfully - user_id=12345"],
          ["'$(date +%s)000000000'", "API request processed - endpoint=/api/users method=GET status=200"],
          ["'$(date +%s)000000000'", "Database query executed - table=users duration=45ms"],
          ["'$(date +%s)000000000'", "Cache miss - key=user_profile_12345"],
          ["'$(date +%s)000000000'", "Payment processed - amount=99.99 currency=USD"]
        ]
      }
    ]
  }'

echo ""
echo "✓ Test logs sent to Loki!"
echo "You can now view them in Grafana at: http://localhost:3000"
echo "Navigate to: Explore > Loki > LogQL query: {job=\"test-app\"}" 