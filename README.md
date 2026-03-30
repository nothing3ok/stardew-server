# Nothing Stardew Server

Dockerized Stardew Valley multiplayer server with persistent storage, bundled SMAPI mods, and a browser-based management panel.

[涓枃璇存槑](README_CN.md)

## Overview

Nothing Stardew Server packages Stardew Valley, SMAPI, and a server-oriented mod stack into a Docker workflow that is easy to run on a VPS or home server.

The current project includes:

- Persistent saves, logs, backups, panel data, and custom mods
- Web panel for status, logs, config, saves, backups, and mods
- Save upload, backup, download, delete, and restore-oriented workflows
- Host migration for co-op saves from the web panel
- Automatic save loading through bundled mods
- Optional VNC access for first-time in-game setup

## Included Components

- Stardew Valley
- SMAPI
- Always On Server
- AutoHideHost
- ServerAutoLoad
- Skill Level Guard
- Web panel in `docker/web-panel`

## Ports

- `24642/udp`: Stardew multiplayer
- `5900/tcp`: VNC
- `9090/tcp`: Prometheus metrics
- `18642/tcp`: Web panel

## Persistent Data

The project stores runtime data under `./data`:

- `data/saves`
- `data/game`
- `data/steam`
- `data/logs`
- `data/backups`
- `data/panel`
- `data/custom-mods`

## Deployment Modes

### Automatic Setup

Use one of these one-command bootstrap entries when you want guided setup on a fresh server.

English:

```bash
curl -fsSL https://raw.githubusercontent.com/nothing3ok/stardew-server/main/quick-start.sh | bash
```

Chinese:

```bash
curl -fsSL https://raw.githubusercontent.com/nothing3ok/stardew-server/main/quick-start-zh.sh | bash
```

If you already cloned the repository, you can also run:

```bash
./quick-start.sh
# or
./quick-start-zh.sh
```

The script will:

- Check Docker and Docker Compose
- Create `.env`
- Ask for Steam credentials
- Create required data directories
- Fix permissions
- Start the stack
- Show next steps for Steam Guard, VNC, and web panel access

### Manual Setup

Use manual setup when you want full control over files and deployment.

#### 1. Prerequisites

- Docker
- Docker Compose
- A Steam account that owns Stardew Valley
- At least 2 GB RAM
- At least 2 GB free disk space

#### 2. Clone the repository

```bash
git clone https://github.com/nothing3ok/stardew-server.git
cd stardew-server
```

#### 3. Create `.env`

```bash
cp .env.example .env
```

Edit `.env` and set at least:

```env
STEAM_USERNAME=your_steam_username
STEAM_PASSWORD=your_steam_password
ENABLE_VNC=true
VNC_PASSWORD=stardew1
```

#### 4. Initialize data directories

```bash
./init.sh
```

This creates the required folders and sets ownership to `1000:1000`.

#### 5. Start the server

```bash
docker compose up -d
```

#### 6. Watch startup logs

```bash
docker logs -f nothing-stardew
```

If Steam Guard is enabled:

```bash
docker attach nothing-stardew
```

Enter the code, wait a few seconds, then detach with `Ctrl+P Ctrl+Q`.

## First Run

After the container is up, you can finish setup in one of two ways.

### Option 1: Web Panel

Open:

```text
http://your-server-ip:18642
```

On first visit, the panel asks you to create an admin password.

Current web panel features:

- Dashboard and runtime status
- Live logs
- SMAPI terminal
- Save list and default save selection
- Save upload
- Save backup creation
- Backup download
- Backup deletion
- Save deletion
- Host migration for co-op saves
- Config editing
- Mod management

### Option 2: VNC

Open your VNC client and connect to:

```text
your-server-ip:5900
```

Use the `VNC_PASSWORD` from `.env`.

Use VNC when you want to:

- Create a brand new co-op farm manually
- Load a save manually inside the game
- Verify first boot visually

After the initial in-game save is prepared, future restarts can auto-load through the bundled mod stack.

## Save and Backup Workflows

The current project supports these web panel operations:

- Upload a save archive or save folder package
- Select the default save for auto-load
- Create a backup before risky operations
- Download backups to your local machine
- Delete backups permanently
- Delete saves from the panel
- Migrate host ownership in a co-op save

Backup files are stored in:

```text
./data/backups
```

## Common Commands

Start:

```bash
docker compose up -d
```

Restart:

```bash
docker compose restart
```

Stop:

```bash
docker compose down
```

Logs:

```bash
docker logs -f nothing-stardew
```

Open container shell:

```bash
docker exec -it nothing-stardew bash
```

## Troubleshooting

### Disk write failure

Usually caused by wrong ownership on `data/`.

Run:

```bash
./init.sh
```

Or:

```bash
chown -R 1000:1000 data/
docker compose restart
```

### Players cannot join

- Check `24642/udp` is open
- Make sure the save is loaded
- Make sure clients use the same game version

### Steam Guard blocks first startup

Attach to the container and enter the code:

```bash
docker attach nothing-stardew
```

Detach with `Ctrl+P Ctrl+Q`, not `Ctrl+C`.

## Notes

- You must legally own Stardew Valley on Steam
- This project is not a piracy tool
- VNC passwords are limited to 8 characters by the VNC protocol
- After editing `.env`, restart the stack for changes to take effect

## License

MIT
