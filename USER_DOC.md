*This project has been created as part of the 42 curriculum by [adechaji].*

---
# User Documentation — Inception

> This document is intended for anyone who wants to run, access, or manage the Inception stack — no deep technical knowledge required.

---

## What Is This Stack?

Inception is a self-hosted web infrastructure. Once running, it provides the following services:

| Service          | What it does                           | How to access                     |
|------------------|----------------------------------------|-----------------------------------|
| **WordPress**    | The main website                       | `https://localhost`               |
| **Adminer**      | Visual database manager                | `https://localhost/adminer/`      |
| **Static Site**  | A simple portfolio page                | `https://localhost/portfolio/`    |
| **Gitea**        | A self-hosted Git platform             | `http://localhost:3000`           |
| **FTP Server**   | File access to WordPress files         | `ftp://localhost` port `21`       |
| **Redis**        | Cache layer (runs in background)       | Internal only                     |
| **MariaDB**      | Database (runs in background)          | Internal only                     |
| **NGINX**        | The front door — handles all HTTPS     | Port `443`                        |

Everything runs in Docker containers. You don't need to install PHP, MySQL, or anything else on your machine — Docker handles all of that.

---

## Starting the Project

Open a terminal at the root of the project and run:

```bash
make
```

That's it. This will:
1. Create the necessary data directories on your machine
2. Build all Docker images from scratch
3. Start all containers in the background

First build takes a few minutes. Subsequent starts are much faster.

---

## Stopping the Project

```bash
# Stop all containers (data is preserved)
make down

# Stop + wipe everything including data (full reset)
make clean
```

Use `make down` if you just want to pause. Use ``make fclean && clean` only if you want to start completely fresh.

---

## Accessing the Services

### WordPress (main site)
Open your browser and go to:
```
https://localhost
```
You'll get a security warning because the SSL certificate is self-signed — click **Advanced → Proceed** to continue. That's expected and normal for a local setup.

### Adminer (database UI)
```
https://localhost/adminer/
```
Login with:
- **System**: MySQL
- **Server**: `mariadb`
- **Username**: *(see credentials section below)*
- **Password**: *(see credentials section below)*
- **Database**: `wordpress`

### Static Portfolio Site
```
https://localhost/portfolio/
```
No login needed — it's a public static page.

### Gitea (Git service)
```
http://localhost:3000
```
Create an account on first visit, or use the admin account set up during initialization.

### FTP Access
Use [FileZilla](https://filezilla-project.org/) or any FTP client:
- **Host**: `ftp://localhost`
- **Port**: `21`
- **Protocol**: FTP
- **Encryption**: Plain FTP (not FTPS)
- **Username/Password**: *(see credentials section below)*

---

## Credentials

All credentials live in the `srcs/.env` file at the root of the project. Open it with any text editor:

```bash
cat srcs/.env
```

You'll find:

| Variable            | What it's for                 |
|---------------------|-------------------------------|
| `MYSQL_DTBS`        | Database name                 |
| `MYSQL_USR`         | WordPress database user       |
| `MYSQL_PSWD`        | WordPress database password   |
| `MYSQL_ROOT_PSWD`   | MariaDB root password         |
| `FTP_USR`           | FTP username                  |
| `FTP_PSWD`          | FTP password                  |

Keep this file private. Don't commit it to a public repository.

---

## Checking That Everything Is Running

```bash
# See all containers and their current status
docker compose -f srcs/docker-compose.yml ps
```

You should see something like this — every container should say `Up`:

```
NAME          STATUS
adminer       Up X minutes
ftp           Up X minutes
gitea         Up X minutes
mariadb       Up X minutes
nginx         Up X minutes
redis         Up X minutes (healthy)
static-site   Up X minutes
wordpress     Up X minutes
```

If any container shows `Restarting` — check its logs:

```bash
docker logs <container-name>
# Example:
docker logs mariadb
docker logs wordpress
```

---

## Where Is My Data Stored?

All persistent data lives on your host machine under:

```
/home/<your-login>/data/
├── db/          ← MariaDB database files
├── wordpress/   ← WordPress files (themes, plugins, uploads)
└── gitea/       ← Gitea repositories and config
```

This means if you restart the containers, your WordPress posts, database, and Gitea repos are all still there. Only `make fclean && clean` wipes this data.

---

## Common Questions

**Q: The site shows a "502 Bad Gateway" error.**
A: WordPress or MariaDB might still be starting up. Wait 20–30 seconds and refresh.

**Q: I get an SSL warning in the browser.**
A: That's expected. The certificate is self-signed. Click through the warning.

**Q: I forgot my WordPress admin password.**
A: Go to Adminer (`https://localhost/adminer/`), log in with the database credentials, browse the `wp_users` table, and reset the password from there.

**Q: FTP connection is refused.**
A: Make sure you're using **plain FTP** (not SFTP or FTPS) on port `21` with passive mode enabled in your FTP client.
