*This project has been created as part of the 42 curriculum by [adechaji].*

---

# Inception

## Description

Inception is a system administration project from the 42 CC. The goal is simple on paper — set up a small but complete infrastructure using Docker Compose, where every service runs in its own container, built from scratch using custom Dockerfiles that must be built either from the penultimate stable
version of Alpine or Debian. The choice is yours (i chose `debian:bookworm`).

No pre-built images from Docker Hub. No shortcuts. Everything is written by hand.

The mandatory part requires setting up:
- **NGINX** — the only entry point, HTTPS only
- **WordPress** — the main web application
- **MariaDB** — the database backend

The bonus part extends the infrastructure with:
- **Redis** — object cache for WordPress
- **FTP Server** (vsftpd) — direct file access to the WordPress volume
- **Static Website** — a pure HTML portfolio served via HTTP server
- **Adminer** — a visual database management interface
- **Gitea** — a self-hosted Git service (extra service)

Everything talks to each other over a private Docker network called `inception`. Volumes persist data between restarts. The whole thing spins up with a single `make` command.

---

### Docker vs Virtual Machines

|               | Docker                        | Virtual Machine           |
|---------------|-------------------------------|---------------------------|
| **Startup**   | Seconds                       | Minutes                   |
| **Size**      | MBs                           | GBs                       |
| **Isolation** | Process-level                 | Full OS-level             |
| **Overhead**  | Very low (shares host kernel) | High (runs full guest OS) |
| **Use case**  | Services, microservices       | Full OS simulation        |

Docker containers share the host kernel — they don't emulate hardware. That's what makes them fast and lightweight. A VM boots an entire operating system. For a project like Inception where we're running 8+ services, VMs would be overkill and slow. Docker lets each service live in its own isolated environment without the weight.

---

### Secrets vs Environment Variables

|                         | Secrets                              | Environment Variables              |
|-------------------------|--------------------------------------|------------------------------------|
| **Storage**             | Files (not in env)                   | Shell environment                  |
| **Security**            | Higher                               | Lower                              |
| **Use in this project** | Not used                             | Used for configuration values      |

I chose the .env approach because Docker secrets are optional and mainly intended for Docker Swarm deployments. The important requirement is that credentials must not be hardcoded directly inside Dockerfiles, images, or committed publicly outside the allowed `.env/` secret mechanism.

---

### Docker Network vs Host Network

|                | Docker Network (`bridge`)                 | Host Network                               |
|----------------|--------------------------------------------|-------------------------------------------|
| **Isolation**  | Full — containers have their own network   | None — shares host network stack          |
| **Security**   | High                                       | Low                                       |
| **Port control** | Explicit expose/publish                  | Everything exposed automatically          |
| **Use case**   | Multi-container apps                       | Performance-critical, low-level tools     |

We use a custom bridge network called `inception`. Containers talk to each other by service name (e.g., `wordpress` connects to `mariadb` by hostname `mariadb`). Only NGINX exposes port 443 to the outside. Everything else is internal. Host networking would expose all ports to the host machine by default — not something you want in a production-style setup.

---

### Docker Volumes vs Bind Mounts

|                           | Docker Volumes             | Bind Mounts                         |
|---------------------------|----------------------------|-------------------------------------|
| **Location**              | Managed by Docker          | Explicit path on host               |
| **Portability**           | High                       | Low (path must exist)               |
| **Performance**           | Optimized                  | Same as host filesystem             |
| **Use in this project**   | Docker-managed persistence | Bind mounts to `/home/login/data/`  |

The subject requires volumes to mount to `/home/login/data/`. We use Docker named volumes configured with `driver: local` and `driver_opts` pointing to bind-mounted paths on the host. This satisfies both requirements — named volumes in Docker Compose AND actual data persistence at a known path on the host machine.

---

## Instructions

### Requirements

- Docker Engine
- Docker Compose v2
- `make`
- A Linux machine or VM (the project was developed and tested on `debian:bookworm`)

> If running on macOS with Docker Desktop, paths and socket behavior may differ slightly from a bare Linux setup.

---

### Setup

**1. Clone the repository**

```bash
git clone https://github.com/adil-ech/Inception
cd Inception
```

**2. Set up your `.env` file**

Create `srcs/.env` with the following variables:

```env
MYSQL_DTBS=wordpress
MYSQL_USR=youruser
MYSQL_PSWD=yourpassword
MYSQL_ROOT_PSWD=yourrootpassword
MYSQL_HOST=mariadb
FTP_USR=yourftpuser
FTP_PSWD=yourftppassword
```

**3. Add your domain to `/etc/hosts`**

```bash
echo "127.0.0.1 localhost" | sudo tee -a /etc/hosts
```

**4. Run it**

```bash
make
```

That's it. The Makefile handles directory creation and starts all containers.

---

### Makefile Commands

```bash
make        # Build and start all containers (same as make all)
make up     # Create data dirs + docker compose up --build -d
make down   # Stop and remove containers
make clean  # Stop containers + docker system prune + remove data dirs
make re     # Full clean rebuild (clean + all)
```

---

### Accessing the Services

| Service       | URL                                |
|---------------|------------------------------------|
| WordPress     | `https://localhost`                |
| Adminer       | `https://localhost/adminer/`       |
| Static Site   | `https://localhost/portfolio/`     |
| Gitea         | `http://localhost:3000`            |
| FTP           | `ftp://localhost:21`(use FileZilla)|

> NGINX uses a self-signed SSL certificate so you'll get a browser warning — just click through it.

---

### Connecting to the Database

```bash
# As root
docker exec -it mariadb mysql -u root -p -h localhost

# As WordPress user
docker exec -it mariadb mysql -u youruser -pyourpassword wordpress

# Show tables (verify DB is not empty after WordPress runs)
docker exec -it mariadb mysql -u root -p -h localhost -e "USE wordpress; SHOW TABLES;"
```

---

### Checking Services

```bash
# See all containers and their status
docker compose -f srcs/docker-compose.yml ps

# Check PID 1 for each container (should be the main service, not a script)
docker exec -it mariadb cat /proc/1/comm     # mysqld_safe
docker exec -it wordpress cat /proc/1/comm   # php-fpm8.2
docker exec -it nginx cat /proc/1/comm       # nginx
docker exec -it redis cat /proc/1/comm       # redis-server
docker exec -it gitea cat /proc/1/comm       # gitea

# Check volumes
docker volume ls
docker volume inspect srcs_db_data
```

---

## Resources

### Docker & Infrastructure

- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [Redis documentation](https://redis.io/docs/)
- [vsftpd documentation](https://security.appspot.com/vsftpd.html)
- [Adminer](https://www.adminer.org/)
- [Gitea documentation](https://docs.gitea.com/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)

---

### How AI Was Used

AI was used during this project mainly as a support tool for research, debugging, and understanding specific concepts — similarly to consulting documentation or examples online. Its usage stayed focused on guidance rather than automatic code generation.

Examples of where AI assistance was useful include:

- Understanding Docker networking and communication between containers
- Learning the difference between Docker volumes, bind mounts, and persistent storage
- Clarifying how PID 1 works inside containers and why process management matters
- Understanding container isolation, images, layers, and the Docker build process
- Learning how reverse proxies and HTTPS integration work in a multi-container environment
- Troubleshooting Docker logs, restart loops, port conflicts, and permission issues
- Understanding environment variables, secrets management, and container configuration practices
- Organizing and improving documentation structure for the README

AI was mostly used in a passive way: asking questions, clarifying requirements, understanding errors, or validating approaches before implementation.
Every service and configuration used in the project was reviewed, modified when necessary, and tested directly in the development environment on both macOS (Docker Desktop) and a Debian Bookworm virtual machine.