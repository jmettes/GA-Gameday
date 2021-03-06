#!/bin/bash -v

# attacks:
# - ELB min = 0
# - delete img.png
# - userdata change?

sudo apt-get update -y
sudo apt-get install python-pip -y
sudo pip install flask
sudo apt-get install nginx -y

export s=$(cat <<- END
from flask import Flask
import urllib2
from string import Template
from datetime import datetime
from datetime import timedelta

app = Flask(__name__)

t = Template("""
<meta http-equiv="refresh" content="5">
<center><h1>GA Gameday</h1></center>
<table style="width: 100%" cellspacing="10">
    <tr>
        <th style="width: 50%; background: black; color: white;">Team A</th>
        <th style="width: 50%; background: black; color: white;">Team B</th>
    </tr>
    <tr>
        <td><h2>Score: \$a_count</h2></td>
        <td><h2>Score: \$b_count</h2></td>
    </tr>
    <tr>
        <td valign="top"><strong>Codes:</strong><table><tr><td>\$a_code</td></tr></table></td>
        <td valign="top"><strong>Codes:</strong><table><tr><td>\$b_code</td></tr></table></td>
    </tr>
</table>
""")


data = {
    'team_a': {
        'count': 0,
        'codes': []
    },
    'team_b': {
        'count': 0,
        'codes': []
    }
}

def check_link(link, team):
    time = (datetime.now() + timedelta(hours=11)).strftime("%I:%M:%S%p")

    try:
        code = urllib2.urlopen(link, timeout=1).getcode()
        data[team]['codes'].insert(0, time + ' - ' + str(code)+ ' - ' + link.split('/')[-1])
        count = data[team]['count']

    except Exception as e:
        data[team]['codes'].insert(0, time + ' - ' + str(e) + ' - ' + link.split('/')[-1])
        code = e
        pass

    return code == 200

@app.route('/')
def score():

    if check_link("http://gameday-elb-team-a-790475977.ap-southeast-2.elb.amazonaws.com/hello.html", 'team_a'):
        data['team_a']['count'] = data['team_a']['count'] + 1
        if check_link("https://s3-ap-southeast-2.amazonaws.com/ga-gameday-team-a/hello.png", 'team_a'):
            data['team_a']['count'] = data['team_a']['count'] + 1
        else:
            data['team_a']['count'] = data['team_a']['count'] - 2
    else:
        data['team_a']['count'] = data['team_a']['count'] - 1

    if check_link("http://gameday-elb-team-b-1086806268.ap-southeast-2.elb.amazonaws.com/hello.html", 'team_b'):
        data['team_b']['count'] = data['team_b']['count'] + 1
        if check_link("https://s3-ap-southeast-2.amazonaws.com/ga-gameday-team-b/hello.png", 'team_b'):
            data['team_b']['count'] = data['team_b']['count'] + 1
        else:
            data['team_b']['count'] = data['team_b']['count'] - 2
    else:
        data['team_b']['count'] = data['team_b']['count'] - 1

    return t.substitute(a_count=data['team_a']['count'],
                        a_code="</td></tr><tr><td>".join(data['team_a']['codes']),

                        b_count=data['team_b']['count'],
                        b_code="</td></tr><tr><td>".join(data['team_b']['codes']))

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug = False)
END
)

echo "$s" > /home/ubuntu/server.py

export f="server {
    listen       80;
    server_name  13.210.36.5;

    location / {
        proxy_pass http://127.0.0.1:5000;
    }
}"

echo "$f" > /etc/nginx/conf.d/virtual.conf
sudo rm /etc/nginx/sites-enabled/default
sudo service nginx restart

export FLASK_APP=/home/ubuntu/server.py
flask run
