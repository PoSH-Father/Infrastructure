#!/bin/bash

# Prompt user for new hostname
read -p "Enter new hostname: " new_hostname

# Set new hostname in /etc/hostname
echo $new_hostname | sudo tee /etc/hostname > /dev/null

# Set new hostname in /etc/hosts
sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$new_hostname/" /etc/hosts

# Display message to confirm hostname change
echo "Hostname has been changed to $new_hostname. Reboot the system to apply the changes."
