sudo apt update -y
sudo apt install sudo nano adduser -y
echo "Please enter the username you want to create:"
read username
sudo adduser $username
echo "$username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers > /dev/null
sudo whoami
