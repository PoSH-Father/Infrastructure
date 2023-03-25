#!/bin/bash

# Set some variables for convenience
USER=$(whoami)
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="/var/log/security-check_$DATE.log"

# Start logging
echo "Security Check started on $DATE by user $USER" | tee $LOG_FILE

# Update the system packages
echo "Updating system packages..." | tee -a $LOG_FILE
sudo apt-get update | tee -a $LOG_FILE
sudo apt-get upgrade -y | tee -a $LOG_FILE

# Enable firewall
echo "Enabling firewall..." | tee -a $LOG_FILE
sudo ufw enable | tee -a $LOG_FILE

# Configure the firewall
echo "Configuring firewall..." | tee -a $LOG_FILE
sudo ufw default deny incoming | tee -a $LOG_FILE
sudo ufw default allow outgoing | tee -a $LOG_FILE
sudo ufw allow ssh | tee -a $LOG_FILE
sudo ufw allow http | tee -a $LOG_FILE
sudo ufw allow https | tee -a $LOG_FILE

# Install fail2ban
echo "Installing fail2ban..." | tee -a $LOG_FILE
sudo apt-get install fail2ban -y | tee -a $LOG_FILE

# Configure fail2ban
echo "Configuring fail2ban..." | tee -a $LOG_FILE
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local | tee -a $LOG_FILE
sudo sed -i 's/bantime  = 10m/bantime  = 1h/g' /etc/fail2ban/jail.local | tee -a $LOG_FILE
sudo sed -i 's/findtime  = 10m/findtime  = 5m/g' /etc/fail2ban/jail.local | tee -a $LOG_FILE
sudo sed -i 's/maxretry = 5/maxretry = 3/g' /etc/fail2ban/jail.local | tee -a $LOG_FILE

# Restart fail2ban
echo "Restarting fail2ban..." | tee -a $LOG_FILE
sudo service fail2ban restart | tee -a $LOG_FILE

# Disable guest account
echo "Disabling guest account..." | tee -a $LOG_FILE
sudo sh -c "echo 'allow-guest=false' >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf" | tee -a $LOG_FILE

# Lock down SSH
echo "Locking down SSH..." | tee -a $LOG_FILE
sudo sh -c "echo 'PermitRootLogin no' >> /etc/ssh/sshd_config" | tee -a $LOG_FILE
sudo sh -c "echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config" | tee -a $LOG_FILE
sudo service ssh restart | tee -a $LOG_FILE

# Harden file permissions
echo "Hardening file permissions..." | tee -a $LOG_FILE
sudo find / -type f -exec chmod 0644 {} \; | tee -a $LOG_FILE
sudo find / -type d -exec chmod 0755 {} \; | tee -a $LOG_FILE

# Log off all users
echo "Logging off all users..." | tee -a $LOG_FILE
sudo pkill -KILL -u $USER | tee -a $LOG_FILE

# Finish logging
echo "Security Check completed on $(date +"%Y-%m-%d_%H-%M-%S
