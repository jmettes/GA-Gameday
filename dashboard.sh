# attacks:
# - ELB min = 0
# - delete img.png
# - userdata change?

sudo apt-get update -y
sudo apt-get install python-pip -y
sudo pip install flask
sudo apt-get install nginx

s=$(cat <<- END
from flask import Flask
import urllib2
from string import Template
from datetime import datetime

app = Flask(__name__)

t = Template("""
<!-- <meta http-equiv="refresh" content="5"> -->
<h1>GA Gameday</h1>
<table>
    <tr>
        <th>Team A</th>
        <th>Team B</th>
    </tr>
    <tr>
        <td><strong>Score:</strong> $a_count</td>
        <td><strong>Score:</strong> $b_count</td>
    </tr>
    <tr>
        <td valign="top"><strong>Codes:</strong><table><tr><td>$a_code</td></tr></table></td>
        <td valign="top"><strong>Codes:</strong><table><tr><td>$b_code</td></tr></table></td>
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
    time = datetime.now().strftime("%I:%M:%S%p")

    try:
        code = urllib2.urlopen(link).getcode()
        if code == 200:
            data[team]['count'] = data[team]['count'] + 1
        else:
            data[team]['count'] = data[team]['count'] - 1

        data[team]['codes'].insert(0, time + ' - ' + str(code))
        count = data[team]['count']

    except Exception as e:
        data[team]['count'] = data[team]['count'] - 1
        data[team]['codes'].insert(0, time + ' - ' + str(e))
        count = data[team]['count']
        code = e
        pass

@app.route('/')
def score():

    check_link("http://google.com/asdadasd", 'team_a')

    return t.substitute(a_count=data['team_a']['count'],
                        a_code="</td></tr><tr><td>".join(data['team_a']['codes']),

                        b_count=data['team_b']['count'],
                        b_code="</td></tr><tr><td>".join(data['team_b']['codes']))

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug = False)
END
)

echo "$s" > server.py
export FLASK_APP=server.py
flask run

f="server {
    listen       80;
    server_name  13.210.36.5;

    location / {
        proxy_pass http://127.0.0.1:5000;
    }
}"

sudo sh -c 'echo $f > /etc/nginx/conf.d/virtual.conf'
sudo service nginx restart



