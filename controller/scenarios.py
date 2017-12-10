
# These scenarios define what commands will be run
# you can have a cli based application,
# will is just a string which we run, the input (a number)
# will be appended to it.
# Another scenario is the server applications
# these require a port on which they will listen
# a init commond, to get the server running
# and a kill command, to terminate the server.
scenarios = {
  'cli' : {
    'bash' : {
      'docker' : 'docker run cli-bash',
      'docker--rm' : 'docker run --rm cli-bash',
      'rkt' : 'rkt --insecure-options=image run ~/cli-bash.aci --',
      'lxc' : 'lxc-execute -n cli-bash -- /entrypoint'
    },
    'node' : {
      'docker' : 'docker run cli-node',
      'docker--rm' : 'docker run --rm cli-node',
      'rkt' : 'rkt --insecure-options=image run ~/cli-node.aci --',
      'lxc' : 'lxc-execute -n cli-node -- /entrypoint'
    },
    'python' : {
      'docker' : 'docker run cli-python',
      'docker--rm' : 'docker run --rm cli-python',
      'rkt' : 'rkt --insecure-options=image run ~/cli-python.aci --',
      'lxc' : 'lxc-execute -n cli-python -- /entrypoint'
    }
  },
  'server' : {
    'lamp': {
      'port' : 80, # this means that is is a running server
      'docker':{
        'init' : 'docker start server-lamp',
        'kill' : 'docker stop server-lamp'
      },
      'rkt':{
        # https://github.com/rkt/rkt/blob/master/Documentation/using-rkt-with-systemd.md
        'init': 'systemd-run rkt --insecure-options=image run --net=host ~/server-lamp.aci',
        'kill': "rkt stop `rkt list|grep running|awk '{print $1}'`"
      },
      'lxc':{
        'init' : 'lxc-start -n server-lamp',
        'kill' : 'lxc-stop -t 1 -n server-lamp'
      }
    }
  }
}
