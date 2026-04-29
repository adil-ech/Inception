#!/bin/bash
set -e

echo "========================================="
echo "  Setting up FTP Server..."
echo "========================================="


if ! id "$FTP_USR" &>/dev/null; then
    echo "Creating FTP user: $FTP_USR"
    
    useradd -m -d /var/www/html -s /bin/bash "$FTP_USR"
    
    echo "$FTP_USR:$FTP_PSWD" | chpasswd
    
    echo "FTP user '$FTP_USR' created successfully"
else
    echo "FTP user '$FTP_USR' already exists, skipping creation"
fi


chown -R "$FTP_USR:$FTP_USR" /var/www/html
chmod -R 755 /var/www/html

echo "Permissions set on /var/www/html"


echo "Starting vsftpd..."

exec vsftpd /etc/vsftpd.conf