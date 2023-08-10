import os
import paramiko
import random
import string
import nmap
import csv
import pandas as pd

#Replace with your password file
df = pd.read_csv('mdp.csv')

def search_password(df, host):
    result = df[df.iloc[:, 4] == host] #Replace with the correct column
    if not result.empty:
        return result['Password'].values[0]
    else:
        return False
    
nm = nmap.PortScanner()
scan_range = nm.scan(hosts="10.0.0.1-254",arguments='-n -sP -PE') #Scan only hosts / no ports
hostlist = nm.all_hosts() #array


for host in hostlist:
    password = search_password(df, host)
    if password == False:
        print("No password for ", host)
        continue
    try:
        username = 'user' # Replace with your username
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.load_system_host_keys()
        client.connect(hostname=host,username=username, password=password)
        
        scp = client.open_sftp()
        scp.put('add_filebeat.sh','/home/'.usernmae.'/add_filebeat.sh')
        scp.put('filebeat.yml','/home/'.usernmae.'/filebeat.yml')
        scp.close()
        
        command = f'chmod 777 add_filebeat.sh'
        stdin, stdout, stderr = client.exec_command(command)
        
        print('Launch for', host)
        command = f'echo -e "{password}" | sudo -S ./add_filebeat.sh'
        stdin, stdout, stderr = client.exec_command(command)
        print(stderr.readlines())
        print(stdout.readlines())
        client.close()
    except paramiko.AuthenticationException as error:
        print ("Password incorrect")
