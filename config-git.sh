#!/bin/bash

# Ejemplo de ejecución del bash: 
##  bash ./config-git.sh "Karen Osorio" kdosorio@unimayor.edu.co id_karen_osorio

# Comprobar si se proporcionaron argumentos
if [ $# -ne 3 ]; then
  echo "Error: Se necesitan exactamente 3 argumentos obligatorios."
  echo "Uso: bash $0 <nombre> <correo electrónico> <nombre del id, ejemplo: id_victor>"
  echo "  Si el nombre tiene más de una palabra, usar comillas; ejemplo: \"Victor Pinto\""
  exit 1 # Sale del script con código de error
fi

# archivo donde ubicar la llave
ssh_dir="$HOME/.ssh"
ssh_file="$ssh_dir/$3"
mkdir -p "$ssh_dir" && chmod 700 "$ssh_dir"
# Configuración de git
github_name=$1
github_email=$2
# Convertir a minúsculas
git_host=${github_name,,}
# Reemplazar los espacios por guiono
git_host=${git_host// /-}

# No tocar el resto del script
RED='\033[0;31m'
echo "config file path"
CONFIG_FILE="$ssh_dir/config"

echo "Configurando usuario y correo en git local; importante para hacer commits"
git config --global user.name "${github_name}"
git config --global user.email "${github_email}"

if [ -f "$ssh_file" ]; then
  echo -e "${RED}ERROR: El archivo de llave ${ssh_file} ya existe; seleccione otro nombre en la variable ssh_file y vuelva a ejecutar"
  exit 1
fi

ssh-keygen -f "$ssh_file" -t rsa -C "$github_email"

echo "Copie y pegue la siguiente llave en su github -> settings -> SSH and GPG Keys"
echo "-------------------------"
cat "${ssh_file}.pub"
echo "-------------------------"

config_file_text=$(cat << EOF

# Llave SSH de github de $1
Host $git_host.github.com
HostName github.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/$3
EOF
)

# Comprobar si existe el archivo config; si no existe, lo crea
if [ -f "$CONFIG_FILE" ]; then
  echo "El archivo config existe actualizando la configuración"

else
  echo "El archivo config no existe creando archivo e incluyendo la configuración"
  mkdir -p "$ssh_dir"
  touch "$CONFIG_FILE"
fi

echo "${config_file_text}" >> "$CONFIG_FILE"
