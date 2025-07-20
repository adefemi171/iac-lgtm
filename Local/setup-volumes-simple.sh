#!/bin/bash

echo "Setting up volumes for local development..."

mkdir -p ./volumes/loki-data
mkdir -p ./volumes/tempo-data
mkdir -p ./volumes/grafana-data

chmod 755 ./volumes/loki-data
chmod 755 ./volumes/tempo-data
chmod 755 ./volumes/grafana-data

echo ""
echo "✓ Volume directories created successfully!"
echo "✓ Containers will run as root (normal for local development)"
echo ""
echo "You can now run: docker-compose up -d"
echo ""
echo "Services will be available at:"
echo "- Grafana: http://localhost:3000 (admin/admin)"
echo "- Loki: http://localhost:3100"
echo "- Tempo: http://localhost:3200" 