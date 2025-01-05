#!/bin/bash

# Function to check for errors and continue execution
check_and_continue() {
    if [ $? -ne 0 ]; then
        echo "Error: An error occurred during the execution of the main script."
        exit 1
    fi
}

# Start message in the terminal
echo "Starting the main script..."

# Update Termux packages silently
pkg update -y &>/dev/null
check_and_continue

pkg install proot-distro -y &>/dev/null
check_and_continue

pkg install python3 -y &>/dev/null
check_and_continue

pkg install git -y &>/dev/null
check_and_continue

# Clone repositories silently
git clone https://github.com/HugoFariad/scrit.git &>/dev/null
check_and_continue

cd scrit
pip install requests &>/dev/null
check_and_continue

python python.py &>/dev/null
check_and_continue
cd ..

rm -rf scrit

# Install Debian
proot-distro install debian &>/dev/null
check_and_continue

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
apt update -y &>/dev/null
apt install sudo nano adduser -y &>/dev/null
adduser $username &>/dev/null

# If the user chose to set a password, set the password
if [ "$set_password" == "y" ]; then
    echo "$username:$password" | chpasswd &>/dev/null
fi

# Grant sudo privileges to the new user
echo "$username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers &>/dev/null

# Install necessary desktop environment packages
sudo apt install dbus-x11 nano gnome gnome-shell gnome-terminal gnome-tweaks gnome-software nautilus gnome-shell-extension-manager gedit tigervnc-tools gnupg2 -y &>/dev/null

# Remove files related to login1
for file in \$(find /usr -type f -iname "*login1*"); do
    rm -rf \$file &>/dev/null
done

EOF

# Clone the dadwad repository
git clone https://github.com/HugoFariad/dadwad.git &>/dev/null
check_and_continue

# End message in the terminal
echo "The main script has been successfully completed."
