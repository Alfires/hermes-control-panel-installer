services:
  hermes:
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
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://127.0.0.1:8642/health"]
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 40s

  webui:
    build: .
    image: hermes-control-panel:local
    container_name: hermes-panel
    restart: unless-stopped
    env_file: ./panel.env
    ports:
      - "${WEBUI_PORT:?set WEBUI_PORT}:8080"
    volumes:
      - ./data:/var/lib/panel
      - ./data/stt-models:/opt/stt/models:ro
    depends_on:
      - hermes
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://127.0.0.1:8080/health.php"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 20s
