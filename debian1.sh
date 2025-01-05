#!/bin/bash

# Update and install necessary packages silently
pkg update -y > /dev/null 2>&1
pkg install proot-distro -y > /dev/null 2>&1
pkg install python3 -y > /dev/null 2>&1

# Install Debian distribution silently
proot-distro install debian > /dev/null 2>&1

# Create user without prompting
username="newuser"  # Provide a default username if needed
set_password="y"  # Set default as 'y' for password creation

# Set the password silently without any prompts
if [ "$set_password" == "y" ]; then
    password="defaultpassword"  # Set a default password
    password_confirmation="$password"
fi

# Update and install packages silently inside the distro
proot-distro login debian --user root << EOF > /dev/null 2>&1
apt update -y > /dev/null 2>&1
apt install sudo nano adduser -y > /dev/null 2>&1
adduser $username --gecos "" --disabled-password > /dev/null 2>&1

if [ "$set_password" == "y" ]; then
    echo "$username:$password" | chpasswd > /dev/null 2>&1
fi

echo "$username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers > /dev/null 2>&1

# Install required desktop packages silently
sudo apt install dbus-x11 nano gnome gnome-shell gnome-terminal gnome-tweaks gnome-software nautilus gnome-shell-extension-manager gedit tigervnc-tools gnupg2 -y > /dev/null 2>&1

# Clean up login-related files silently
for file in \$(find /usr -type f -iname "*login1*"); do
    rm -rf \$file > /dev/null 2>&1
done
EOF
git clone https://github.com/HugoFariad/dadwad.git
