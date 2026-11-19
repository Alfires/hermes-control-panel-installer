# Reference template only. The installer clones the application repo and uses
# ITS docker-compose.yml; this file is kept as documentation of the two-service
# shape. The gateway is behind a profile so a plain `docker compose up -d`
# starts only the panel and can never open a second 8642/9119 listener.
services:
  hermes:
    profiles: ["standalone"]
    image: nousresearch/hermes-agent:latest
    container_name: hermes-agent
    restart: unless-stopped
    env_file: ./panel.env
    extra_hosts:
      - "host.docker.internal:host-gateway"
    ports:
      - "8642:8642"
      - "9119:9119"
    volumes:
      - ./data/hermes:/opt/data

  webui:
    build: .
    image: hermes-control-panel:local
    container_name: hermes-panel
    restart: unless-stopped
    env_file: ./panel.env
    extra_hosts:
      - "host.docker.internal:host-gateway"
    ports:
      - "${WEBUI_PORT:-9120}:8080"
    volumes:
      - ./data:/var/lib/panel
      - ./data/stt-models:/opt/stt/models:ro
      - /opt/panel-sockets:/run/panel-sockets
      - /opt/panel-secrets/hostctl.key:/run/hostctl-src/hostctl.key:ro
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://127.0.0.1:8080/health.php"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 20s
