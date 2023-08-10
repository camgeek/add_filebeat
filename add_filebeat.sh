#!/bin/bash

# Check that the /etc/os-release file exists
if [ -e "/etc/os-release" ]; then
    # Read the contents of the /etc/os-release file
    source /etc/os-release
    
    # Check if the distribution name contains "Ubuntu" and "Server".
    if [[ "$NAME" == *"Ubuntu"* && "$ID" == "ubuntu" ]]; then
        echo "The machine is an Ubuntu."
    else
        echo $NAME
        echo $ID
        echo "The machine is not Ubuntu."
        exit 1
    fi
else
    echo "The /etc/os-release file does not exist. Impossible to determine the operating system."
    exit 1
fi


word_to_find="history"
file="/etc/bash.bashrc"

# Check if the file exists
if [ -e "$fichier" ]; then
    # Use the 'grep' command to search for the word in the file
    if grep -q "$word_to_find" "$file"; then
        echo "The word '$word_to_find' was found in the file. bash.bashrc OK"
    else
        echo "The word '$word_to_find' was not found in the file. We add to bash.bashrc"
        ligne_bashrc="PROMPT_COMMAND='history -a >(logger -t "\""[COMMAND] [\$USER] \$SSH_CONNECTION"\"")'"
        sed -i "$ a $ligne_bashrc" /etc/bash.bashrc
    fi
else
    echo "The file does not exist."
fi

# Name of the file to be checked
file_to_check="/etc/filebeat/filebeat.yml"

# Check if the file exists
if [ -e "$file_to_check" ]; then
    echo "filebeat is already installed"
    exit 1
else
    echo "Filebeat can be installed"
fi

echo "Installation requirements"

sudo apt-get -y install apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get -y install filebeat

#Deleting a sample file
rm -rf /etc/filebeat/filebeat.yml
cp filebeat.yml /etc/filebeat/filebeat.yml
chmod 600 /etc/filebeat/filebeat.yml
chown root:root /etc/filebeat/filebeat.yml

systemctl start filebeat
systemctl enable filebeat
filebeat modules enable system

if command -v psql >/dev/null 2>&1; then
    echo "PostgreSQL is installed."
    filebeat modules enable postgresql
else
    echo "PostgreSQL is not installed."
fi

if command -v apache2 >/dev/null 2>&1; then
    # Check that the Apache configuration directory exists
    if [ -d "/etc/apache2" ]; then
        echo "Apache is installed."
        filebeat modules enable apache
    else
        echo "The Apache configuration directory does not exist. Apache may not be installed."
    fi
else
    echo "Apache is not installed."
fi

systemctl restart filebeat