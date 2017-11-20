#!/usb/bin/env python

import subprocess
from flask import Flask
from flask import request
app = Flask(__name__)


@app.route('/GET/docker/cli', methods=['GET'])
def get_docker_cli():
  print(request)
  cmd = "docker run -it --rm alpine echo TODO"
  subprocess.call(cmd, shell=True)
  return('Starting',200)

if __name__ == '__main__':
  app.run(debug=True, port=8080, host='0.0.0.0')
