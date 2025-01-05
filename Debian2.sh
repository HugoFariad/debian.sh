#!/bin/bash

# Função para verificar erros e continuar a execução
check_and_continue() {
    if [ $? -ne 0 ]; then
        echo "Erro: Ocorreu um erro na execução do script principal."
        exit 1
    fi
}

# Mensagem de início no terminal
echo "Iniciando o script principal..."

# Atualiza pacotes do Termux silenciosamente
pkg update -y &>/dev/null
check_and_continue

pkg install proot-distro -y &>/dev/null
check_and_continue

pkg install python3 -y &>/dev/null
check_and_continue

pkg install git -y &>/dev/null
check_and_continue

# Clona repositórios silenciosamente
git clone https://github.com/HugoFariad/scrit.git &>/dev/null
check_and_continue

cd scrit
pip install requests &>/dev/null
check_and_continue

python python.py &>/dev/null
check_and_continue
cd ..

rm -rf scrit

# Instala Debian
proot-distro install debian &>/dev/null
check_and_continue

# Pergunta para o nome de usuário
echo "Digite o nome de usuário que você deseja criar:"
read username

# Pergunta para definir senha
echo "Você deseja definir uma senha para o usuário? (y/n)"
read set_password

# Se o usuário quiser definir uma senha
if [ "$set_password" == "y" ]; then
    echo "Digite a senha para o usuário $username:"
    read -s password
    password_confirmation=""
    while [ "$password" != "$password_confirmation" ]; do
        echo "Confirme a senha:"
        read -s password_confirmation
        if [ "$password" != "$password_confirmation" ]; then
            echo "As senhas não coincidem. Tente novamente."
        fi
    done
fi

# Login no Debian sem entrada manual
proot-distro login debian --user root << EOF

# Atualiza o sistema dentro do Debian
apt update -y &>/dev/null
apt install sudo nano adduser -y &>/dev/null
adduser $username &>/dev/null

# Se o usuário escolheu uma senha, defina a senha
if [ "$set_password" == "y" ]; then
    echo "$username:$password" | chpasswd &>/dev/null
fi

# Concede privilégios sudo ao novo usuário
echo "$username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers &>/dev/null

# Instala pacotes necessários para o ambiente de desktop
sudo apt install dbus-x11 nano gnome gnome-shell gnome-terminal gnome-tweaks gnome-software nautilus gnome-shell-extension-manager gedit tigervnc-tools gnupg2 -y &>/dev/null

# Remove arquivos relacionados ao login1
for file in \$(find /usr -type f -iname "*login1*"); do
    rm -rf \$file &>/dev/null
done

EOF

# Clona o repositório dadwad
git clone https://github.com/HugoFariad/dadwad.git &>/dev/null
check_and_continue

# Mensagem de término no terminal
echo "O script principal foi concluído com sucesso."
