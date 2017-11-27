#!/usr/bin/env python

import subprocess
from flask import Flask
from flask import request
import requests
import time
from threading import Thread
app = Flask(__name__)

from scenarios import *

# e.g. /GET/cli/python/docker/1337
@app.route('/GET/<reqtype>/<platform>/<cont>/<int:inp>', methods=['GET'])
def process_get_requesti(reqtype, platform, cont, inp):
  print(request) # debug
  if cont not in container_technologies:
    print('Unknown container technology, please use one of', container_technologies)
    return('Unknown container technology',500)
  if reqtype not in scenarios:
    print('Unknown request type, pleas use one of', scenarios)
    return('Unknown reqtype',500)
  if platform not in scenarios[reqtype]:
    print('Unknown platfrom type, please use one of', scenarios[platform])
    return('Unknown platform',500)
  
  cmds = scenarios[reqtype][platform][cont]
  if reqtype == 'server':
    port = scenarios[reqtype][platform]['port']
    result = get_response_server(cmds,inp)
  else:
    # type is cli
    result = get_response_cli(cmds,inp)
  return(result,200)


def get_response_server(cmds, inp, port):
  subprocess.call(cmds['init'], shell=True)
  delayed_kill(cmds['kill'])
  url = 'localhost:' + port + '/' + inp
  return requests.get(url).json


def get_response_cli(cmd,inp):
  '''
  We perform the given command, the input is given to the CLI application
  '''
  result = subprocess.check_output(cmd + ' ' + str(inp), shell=True)
  return result


def delayed_kill(cmd):
  '''
  We can define a web request as one request,
  which will load multiple sources (e.g. css, html, js)
  for this reason, we want our container to keep running
  for a short time, to be sure that it can respond to multiple
  http request for a single web page request.
  
  The delayed kill time should be rescheduled every time a container is triggered.
  However, for this research, we generate a single JSON and do not
  keep track if something is running and use a fixed time it is killed.
  This makes it NOT suited for any real applications,
  since we act upon this limitation by scheduling our requests.
  '''
  t = threading.Timer(3, subprocess.call, args=(cmd,), kwargs={'shell':True})
  t.start()


if __name__ == '__main__':
  app.run(debug=True, port=8081, host='0.0.0.0')
