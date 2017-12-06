
container_technologies = ['docker','rkt','lxc']

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
      'rkt' : '',
      'lxc' : 'lxc-execute -n cli-bash -- /entrypoint'
    },
    'node' : {
      'docker' : 'docker run cli-node',
      'rkt' : '',
      'lxc' : 'lxc-execute -n cli-node -- /entrypoint'
    },
    'python' : {
      'docker' : 'docker run cli-python',
      'rkt' : '',
      'lxc' : 'lxc-execute -n cli-python -- /entrypoint'
    }
  },
  'server' : {
    'lamp': {
      'port' : 8888, # this means that is is a running server
      'docker':{
        'init' : 'docker start --net=host server-lamp',
        'kill' : 'docker stop server-lamp'
      },
      'rkt':{
        'init': ''
      },
      'lxc':{
        'init' : 'lxc-start -n server-lamp',
        'kill' : 'lxc-stop -n server-lamp'
      }
    }
  }
}
