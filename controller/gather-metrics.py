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
  return { 'delta' : delta, 'status' : r.status_code }

def gather_metrics(conttype):
  results = {}
  for reqtype in scenarios:
    results[reqtype] = {}
    for platform in scenarios[reqtype]:
      nr = randrange(100)
      url = '127.0.0.1:8081/GET/' + reqtype + '/' + platform + '/' + conttype + '/' + str(nr)
      
      for i in range(10):
        #first 10 runs, for filecaching etc.
        measure_millis(url)
      
      arr = []
      for i in range(amount_of_tests_per_case):
        time.sleep(sleep_interval_between_tests)
        metric = measure_millis(url + str(i))
        arr.push(metric)
      
      print('Saving preliminary result to disk', reqtype, platform)
      results[reqtype][platform] = arr
      file = data_output_path + '/' + conttype + '.json'
      json.dump(results,file)




conttype = getenv('CONTAINERTYPE')
if not conttype or not len(conttype):
  print('ERROR please use export CONTAINERTYPE=insert_here')
else:
  gather_metrics(conttype)

print('finished')