#!/bin/bash

# Update Termux packages
pkg update -y
pkg install proot-distro -y
pkg install python3 -y
pkg install git -y
git clone https://github.com/HugoFariad/scrit.git
cd scrit
pip install requests
python python.py
cd ..
rm scrit
# Install Debian
proot-distro install debian

# Ask for the username
echo "Enter the username you want to create:"
read username

# Ask if the user wants to set a password
echo "Do you want to set a password for the user? (y/n)"
read set_password

# If the user wants to set a password
if [ "$set_password" == "y" ]; then
    echo "Enter the password for user $username:"
    read -s password
    password_confirmation=""
    while [ "$password" != "$password_confirmation" ]; do
        echo "Confirm the password:"
        read -s password_confirmation
        if [ "$password" != "$password_confirmation" ]; then
            echo "Passwords do not match. Try again."
        fi
    done
fi

# Login to Debian without manual input
proot-distro login debian --user root << EOF

# Update the system inside Debian
apt update -y

# Install required packages
apt install sudo nano adduser -y

# Create the new user
adduser $username

# If the user chose to set a password, set the password
if [ "$set_password" == "y" ]; then
    echo "$username:$password" | chpasswd
fi

# Grant sudo privileges to the new user by editing the sudoers file
echo "$username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers > /dev/null

# Install necessary desktop environment packages
sudo apt install dbus-x11 nano gnome gnome-shell gnome-terminal gnome-tweaks gnome-software nautilus gnome-shell-extension-manager gedit tigervnc-tools gnupg2 -y

# Remove files related to login1
for file in \$(find /usr -type f -iname "*login1*"); do
    rm -rf \$file
done

EOF
git clone https://github.com/HugoFariad/dadwad.git
