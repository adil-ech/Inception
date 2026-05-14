*This project has been created as part of the 42 curriculum by [adechaji].*

---
# Developer Documentation — Inception

> This document covers everything a developer needs to know to set up, build, run, and debug the Inception infrastructure from scratch.

---

## Prerequisites

Before you start, make sure the following are installed on your machine:

| Tool                 | Purpose                  | Check                        |
|----------------------|--------------------------|------------------------------|
| Docker Engine        | Runs containers          | `docker --version`           |
| Docker Compose v2    | Orchestrates services    | `docker compose version`     |
| GNU Make             | Runs build commands      | `make --version`             |
| Git                  | Clone the repo           | `git --version`              |

The project targets **Debian Bookworm** as the base OS for all containers, and was tested on both a bare Debian VM and macOS with Docker Desktop.

> On macOS, the Docker socket lives at `/var/run/docker.sock` as a symlink to `~/.docker/run/docker.sock`. This is handled automatically.

---

## Project Structure

```
Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/50-server.cnf
        │   └── tools/script.sh
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/script.sh
        └── bonus/
            ├── redis/
            │   ├── Dockerfile
            │   └── conf/redis.conf
            ├── ftp/
            │   ├── Dockerfile
            │   ├── conf/vsftpd.conf
            │   └── tools/script.sh
            ├── adminer/
            │   ├── Dockerfile
            │   └── tools/script.sh
            ├── static-site/
            │   ├── Dockerfile
            │   └── www/index.html
            └── gitea/
                ├── Dockerfile
                └── tools/script.sh
```

---

## Configuration Files

### `srcs/.env`

This is the main configuration file. It must exist before running the project. Create it manually:

```env
# Database
MYSQL_DTBS=wordpress
MYSQL_USR=wpuser
MYSQL_PSWD=yourpassword
MYSQL_ROOT_PSWD=yourrootpassword
MYSQL_HOST=mariadb

# FTP
FTP_USR=ftpuser
FTP_PSWD=ftppassword
```

> Variable names must match exactly what the scripts expect. Double-check the `script.sh` files if you rename anything.

---

## Building and Launching

### Full build from scratch

```bash
make
# or explicitly:
make all
```

Under the hood this runs:

```bash
mkdir -p $(HOME)/data/db
mkdir -p $(HOME)/data/wordpress
mkdir -p $(HOME)/data/gitea
docker compose -f srcs/docker-compose.yml up --build -d
```

### Makefile reference

```bash
make          # Build images + start all containers
make up       # Same as above
make down     # Stop and remove containers (data preserved)
make clean    # Stop containers + docker system prune + remove data dirs
make fclean   # Full clean
make re       # Full clean rebuild (clean then all)
```

---

## Container Management

### Check status of all containers

```bash
docker compose -f srcs/docker-compose.yml ps
```

### View logs for a specific service

```bash
docker logs mariadb
docker logs wordpress
docker logs nginx
docker logs redis
docker logs gitea
```

Follow logs in real time:

```bash
docker logs -f wordpress
```

### Enter a container shell

```bash
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash
```

### Verify PID 1 for each container

A well-configured container should have its main service as PID 1, not a shell script. Check like this:

```bash
docker exec -it mariadb cat /proc/1/comm      # Expected: mysqld_safe
docker exec -it wordpress cat /proc/1/comm    # Expected: php-fpm8.2
docker exec -it nginx cat /proc/1/comm        # Expected: nginx
docker exec -it redis cat /proc/1/comm        # Expected: redis-server
docker exec -it gitea cat /proc/1/comm        # Expected: gitea
```

If you see `script.sh` or `bash` — the container's entrypoint is not using `exec` correctly. The fix is always to end the script with `exec <service>` instead of just calling the service directly.

---

## Volume Management

### List all volumes

```bash
docker volume ls
```

Expected output:

```
DRIVER    VOLUME NAME
local     srcs_db_data
local     srcs_wp_data
local     srcs_gitea_data
```

### Inspect a volume (verify bind path)

```bash
docker volume inspect srcs_db_data
```

The `Mountpoint` field must point to `/home/<login>/data/db` — this is what evaluators check. If it points to `/var/lib/docker/volumes/...` instead, your volume is missing the `driver_opts` bind mount configuration in `docker-compose.yml`.

Correct volume config in `docker-compose.yml`:

```yaml
volumes:
  db_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/adechaji/data/db
```

### Where data lives on disk

```
/home/<login>/data/
├── db/          ← MariaDB data files (/var/lib/mysql inside container)
├── wordpress/   ← WordPress web root (/var/www/html inside container)
└── gitea/       ← Gitea data (/home/git/gitea inside container)
```

Data survives container restarts and rebuilds. Only `make clean` deletes it.

---

## Database Access

```bash
# Connect as root (forces Unix socket, avoids hostname auth issues)
docker exec -it mariadb mysql -u root -p -h localhost

# Connect as WordPress user
docker exec -it mariadb mysql -u wpuser -pyourpassword wordpress

# Quick check — show all tables in wordpress DB
docker exec -it mariadb mysql -u root -p -h localhost \
  -e "USE wordpress; SHOW TABLES;"
```

> Always use `-h localhost` when connecting as root inside the container. Without it, MariaDB connects via TCP using the container hostname, and root is only allowed via the Unix socket.

---

## Networking

All services communicate over a private Docker bridge network named `inception`. No service except NGINX is exposed to the outside world.

```
External (port 443) → NGINX → WordPress (port 9000, internal)
                             → Adminer (port 8080, internal)
                             → Static Site (port 80, internal)
                             → Gitea (port 3000, also exposed directly)
                      FTP   → exposed on ports 21 + 21000-21010
```

Containers reference each other by service name. For example, WordPress connects to MariaDB at hostname `mariadb`, not `localhost` or an IP address.

---

## Rebuilding a Single Service

If you only change one Dockerfile or script, you don't need to rebuild everything:

```bash
# Rebuild and restart just one service
docker compose -f srcs/docker-compose.yml up --build -d mariadb
docker compose -f srcs/docker-compose.yml up --build -d wordpress
```

### Reset a single volume (e.g. MariaDB got corrupted)

```bash
docker compose -f srcs/docker-compose.yml down
docker volume rm srcs_db_data
rm -rf /home/adechaji/data/db
mkdir -p /home/adechaji/data/db
docker compose -f srcs/docker-compose.yml up --build -d
```

---

## Redis Cache

Redis runs as an in-memory object cache for WordPress. The WordPress Object Cache plugin connects to Redis at hostname `redis` on port `6379`.

Verify Redis is receiving hits:

```bash
# Ping test
docker exec -it redis redis-cli ping
# Should return: PONG

# Live traffic monitor
docker exec -it redis redis-cli monitor

# Cache stats
docker exec -it redis redis-cli INFO stats | grep keyspace
```

---

## FTP Server

The FTP container (vsftpd) mounts the same volume as WordPress (`wp_data`), so FTP clients see the WordPress files directly at `/var/www/html`.

Passive mode ports `21000–21010` are exposed for data transfers. If connecting from outside a local network, set `pasv_address` in `vsftpd.conf` to the machine's actual IP.

---

## AI Usage

AI was used occasionally during this project for debugging — mainly to get a second opinion on error messages and understand why certain things weren't working the way they should. Things like reading a crash log and figuring out what went wrong, or looking up the right flag for a command.

---

## Common Issues

| Symptom                                 | Likely cause                           | Fix                                                  |
|-----------------------------------------|----------------------------------------|------------------------------------------------------|
| `mariadb` keeps restarting              | Root password mismatch on restart      | Add `if [ ! -d /var/lib/mysql/mysql ]` init check    |
| `502 Bad Gateway` on WordPress          | WordPress or MariaDB still starting    | Wait 20–30 seconds and retry                         |
| PID 1 is `script.sh`                    | Missing `exec` before service start    | End script with `exec <service>`                     |
| Volume mountpoint is wrong path         | Missing `driver_opts` in compose       | Add bind mount config to volume definition           |
| FTP connection refused                  | Wrong mode (SFTP vs FTP)               | Use plain FTP, passive mode, port 21                 |
| MariaDB `Access denied for root@host`   | TCP vs socket connection               | Use `-h localhost` to force socket connection        |
