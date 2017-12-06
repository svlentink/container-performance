#!/usr/bin/env python3

import subprocess
from flask import Flask
from flask import request
import requests
import time
import threading
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
    result = get_response_server(cmds,inp,port)
  else:
    # type is cli
    result = get_response_cli(cmds,inp)
  return(result,200)


def get_response_server(cmds, inp, port):
  killcmd = cmds['kill']
  delayed_kill(killcmd)
  if killcmd not in kill_container_at:
    subprocess.call(cmds['init'], shell=True)
  url = 'http://localhost:' + str(port) + '?param=' + str(inp)
  for i in range(100):
    try:
      r = requests.get(url).json
      return r
    except Exception as e:
      nothing = e
    time.sleep(0.05)
  raise TimeoutError('Could not reach container on ' + url)

def get_response_cli(cmd,inp):
  '''
  We perform the given command, the input is given to the CLI application
  '''
  result = subprocess.check_output(cmd + ' ' + str(inp) + ' 2> /dev/null', shell=True)
  # we do 2>/dev/null since lxc-execute gives some mount errs (which we do not use anyway)
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
  kill_container_at[cmd] = int(time.time()) + 8 # the next kill is scheduled in x sec

kill_container_at = {}
def kill_idle_containers(kill_container_at):
  while True:
    time.sleep(0.5)
    todoremove[]
    for killcmd in kill_container_at:
      if kill_container_at[killcmd] < int(time.time()):
        subprocess.call(killcmd, shell=True)
        print('Just performed:',killcmd)
        todoremove.append(killcmd) # it cannot be removed here, since it will remove an item of an array it is looping through
    for cmd in todoremove:
      del kill_container_at[cmd]

if __name__ == '__main__':
  t = threading.Thread(target=kill_idle_containers,args=(kill_container_at,))
  t.start()
  app.run(debug=True, port=8081, host='127.0.0.1')
