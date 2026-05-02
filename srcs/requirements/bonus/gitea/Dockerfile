FROM debian:bookworm

RUN apt update && apt install -y \
    curl \
    ca-certificates \
    git \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# Detect arch and download Gitea binary
RUN ARCH=$(dpkg --print-architecture) && \
    echo "Architecture: $ARCH" && \
    curl -fsSL "https://dl.gitea.com/gitea/1.21.4/gitea-1.21.4-linux-${ARCH}" \
    -o /usr/local/bin/gitea && \
    chmod +x /usr/local/bin/gitea

# Create git user
RUN useradd -m -s /bin/bash -d /home/git git

# Create required Gitea directories
RUN mkdir -p /home/git/gitea/{custom,data,log} \
             /home/git/gitea/data/repositories \
             /etc/gitea && \
    chown -R git:git /home/git/gitea && \
    chown -R git:git /etc/gitea && \
    chmod -R 750 /home/git/gitea && \
    chmod 770 /etc/gitea

COPY tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

EXPOSE 3000

CMD ["script.sh"]