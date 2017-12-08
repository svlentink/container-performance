#!/usr/bin/env python

import requests
from os import getenv
from scenarios import *
from random import randrange
import json
import time



print('This script is the heart of the research, it gathers the numbers.')
amount_of_tests_per_case = 100
sleep_interval_between_tests = {
  "cli" : 2, #sec
  'server' : 20 #sec
}
testdata_output_path = '/root'




def measure_millis(url):
  startt = int(time.time() * 1000)
  r = requests.get(url)
  stopt = int(time.time() * 1000)
  delta = stopt - startt
  return { 'd' : delta, 's' : r.status_code }


def gather_metrics(conttype):
  results = {}
  filename = testdata_output_path + '/' + conttype + str(int(time.time())) + '.json'
  for reqtype in scenarios:
    results[reqtype] = {}
    for platform in scenarios[reqtype]:
      nr = randrange(100)
      url = 'http://main-controller:8081/GET/' + reqtype + '/' + platform + '/' + conttype + '/' + str(nr)
      
      for i in range(10):
        # To allow system optimizations (e.g. caching)
        # and initial container startup latency
        # we first start the container 10 times
        time.sleep(sleep_interval_between_tests[reqtype])
        measure_millis(url)
      
      arr = []
      for i in range(amount_of_tests_per_case):
        time.sleep(sleep_interval_between_tests[reqtype])
        metric = measure_millis(url + str(i))
        arr.append(metric)
      
      print('Saving preliminary result to disk', reqtype, platform)
      results[reqtype][platform] = arr
      with open(filename, 'w') as f:
        json.dump(results,f,default=str)

  return results

def metrics2r(results, conttype):
  files2write = {}
  for reqtype in results:
    for platform in results[reqtype]:
      arr = results[reqtype][platform]
      fileprefix = conttype + '_' + reqtype + '_' + platform + '_'
      for i in arr:
        s = i['s'] # status code e.g. 200 or 500
        d = i['d'] # time delta
        filename = fileprefix + str(s) + '.csv'
        if filename not in files2write:
          files2write[filename] = ""
        files2write[filename] += str(d) + ','
  
  for fln in files2write:
    csvdata = files2write[fln]
    with open(testdata_output_path + '/' + fln, 'a') as f:
      f.write(csvdata)
        

conttype = getenv('CONTAINERTYPE')
if not conttype or not len(conttype):
  print('ERROR please use export CONTAINERTYPE=insert_here')
else:
  m = gather_metrics(conttype)
  metrics2r(m,conttype)

print('finished')
