# add_filebeat
Add filebeat to an ip range by activating postgres and apache.

The script will attempt to connect to an ip range using nmap.
Once connected to the machine, it drops an sh file which will then be run.

The sh script will test whether it is possible to install filebeat on the machine, and it will enable command logging.

A check will be made for apache and postgres to activate the modules.

I produced this script to deploy filbeat more quickly on a large number of machines and avoid more manual operations.


## Prerequisites

Python 3.9

```bash
pip install -r /path/to/requirements.txt
```

## Configuration

### filebeat.yml
The filebeat.yml file must be modified

- Line 110 `host: "http://replace.local:80"`
- Line 137 `hosts: ["replace.local:9200"]`
- Line 144 - 145 `username: "elastic" password: "XXXXX"` 

### add_filebeat.py
The add_filebeat.py file must be modified

- Line 10
```python
df = pd.read_csv('mdp.csv')
 ```
- Line 20
```python
scan_range = nm.scan(hosts="10.0.0.1-254",arguments='-n -sP -PE')
```
- Line 30
```python
username = 'user'
```

## Authors and acknowledgment
Camille VRIGNAUD

test4
