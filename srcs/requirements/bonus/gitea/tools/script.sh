#!/bin/bash
set -e

echo "Setting up Gitea directories..."

chown -R git:git /home/git/gitea
chmod -R 750 /home/git/gitea
chmod 770 /etc/gitea

echo "Starting Gitea..."

# gosu drops root privileges and exec's directly into gitea
# making gitea PID 1 instead of su
exec gosu git env \
    GITEA_WORK_DIR=/home/git/gitea \
    gitea web \
    --config /etc/gitea/app.ini \
    --port 3000 \
    --work-path /home/git/gitea