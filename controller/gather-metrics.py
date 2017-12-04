#!/usr/bin/env python

import requests
from os import getenv
from scenarios import *
from random import randrange
import json
import time

print('This script is the heart of the research, it gathers the numbers.')
amount_of_tests_per_case = 1000
sleep_interval_between_tests = 3 #sec
data_output_path = '/root'


def measure_millis(url):
  startt = int(time.time() * 1000)
  r = requests.get(url)
  stopt = int(time.time() * 1000)
  delta = stopt - startt
  return { 'd' : delta, 's' : r.status_code }


def gather_metrics(conttype):
  results = {}
  filename = data_output_path + '/' + conttype + '.json'
  for reqtype in scenarios:
    results[reqtype] = {}
    for platform in scenarios[reqtype]:
      nr = randrange(100)
      url = 'http://127.0.0.1:8081/GET/' + reqtype + '/' + platform + '/' + conttype + '/' + str(nr)
      
      for i in range(10):
        # To allow system optimizations (e.g. caching)
        # and initial container startup latency
        # we first start the container 10 times
        measure_millis(url)
      
      arr = []
      for i in range(amount_of_tests_per_case):
        time.sleep(sleep_interval_between_tests)
        metric = measure_millis(url + str(i))
        arr.append(metric)
      
      print('Saving preliminary result to disk', reqtype, platform)
      results[reqtype][platform] = arr
      with open(filename, 'w') as f:
        json.dump(results,f,default=str)



conttype = getenv('CONTAINERTYPE')
if not conttype or not len(conttype):
  print('ERROR please use export CONTAINERTYPE=insert_here')
else:
  gather_metrics(conttype)

print('finished')
