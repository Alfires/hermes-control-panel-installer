# hermes-control-panel-installer

One-line installer for the Hermes Control Deck.

```bash
curl -fsSL http://192.168.2.157:3001/Alfires/hermes-control-panel-installer/raw/branch/main/install.sh | sudo bash
```

Root is required: the panel is the only consumer of two root-owned brokers
(vault and host control) reached over group-restricted unix sockets. The
installer:

1. clones/updates the application repo into `/opt/hermes-control-panel`;
2. generates a root-only host-control HMAC key in `/opt/panel-secrets`;
3. installs and starts `panel-hostctl.service` and `panel-socket-relay.service`;
4. writes `panel.env` using the **actual** variable names the app reads
   (`PANEL_ADMIN_PASSWORD`, `PANEL_LLM_KEY`, `VAULT_SOCKET`, `HOSTCTL_SOCKET`,
   `PANEL_HOST_KEY`, …) — an existing admin password is preserved;
5. builds and starts **only** the `webui` service with `--no-deps`.

The `hermes` service in the application compose is behind a `standalone`
profile, so a plain `docker compose up` can never open a second gateway on
ports 8642/9119. Point the panel at an existing gateway with `HERMES_URL` and
`HERMES_DASHBOARD_URL` in `panel.env`.

Secrets are generated locally, are never printed, and remain root-only
(`chmod 600`). The admin password is stored only in `panel.env`.

## Commands

```bash
sudo bash install.sh            # install / upgrade
sudo bash install.sh status     # compose status
sudo bash install.sh uninstall  # stop the panel (data and secrets preserved)
```

See `.env.example` for the complete list of supported variables.
