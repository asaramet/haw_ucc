#!/usr/bin/env python3

import os, json, sys, getopt

dir_path = os.path.dirname(os.path.realpath(__file__))
dataFolder = "/www/faculty/it/bwHPC/SCRIPTS/bwUniCluster1/haw"
outputFolder = os.path.join(dir_path, "ngData/_data")

hawPrefixes = ['aa', 'as', 'es', 'hf', 'hk', 'hn', 'hr', 'hs', 'ht', 'hu', 'ro']

def jsonDump (year, month):
  if not os.path.exists(outputFolder): os.makedirs(outputFolder)
  outFile = outputFile(year, month, '.json')
  if os.path.exists(outFile): os.remove(outFile)
  print ("Gathering data for " + str(year) + ' ' + str(month) + '...')
  haw_data_list = createDataList(year, month)
  if haw_data_list != []:
    with open (outFile, "w") as jsonFile:
      json.dump(haw_data_list, jsonFile)

def tsDump (year, month):
  if not os.path.exists(outputFolder): os.makedirs(outputFolder)
  outFile = outputFile(year, -1, '.ts')
  print ("Gathering data for " + str(year) + ' ' + str(month) + '...')
  haw_data_list = createDataList(year, month)
  if haw_data_list != []:
    if month == -1:
      listName = 'export const udata_' + str(year) + ' = '
    else:
      listName = 'export const udata_' + str(year) + '_' + str(month) + ' = '
    with open (outFile, "a") as tsFile:
      tsFile.write('\n' + listName + str(haw_data_list) + '\n')

def outputFile (year, month, extension):
  if month == -1:
    return os.path.join(outputFolder, str(year) + extension)
  return os.path.join(outputFolder, str(year) + '-' + str(month) + extension)

def createDataList (year, month):
  data_list = []
  for prefix in hawPrefixes:
    data = gatherData(year, month, prefix)
    if data != []:
      data_list.append({"haw": prefix, "data": data})
  return data_list

def gatherData (year, month, haw_prefix):
  # if you want to gather data for the whole year set month = -1
  if month in range(1,10):
    logFile = '0' + str(month) + '.log'
  elif month in range(10,13):
    logFile = str(month) + '.log'
  elif month == -1: # calculate for entire year
    logFile = 'total.log'
  else: logFile = 'none'
  file = os.path.join(dataFolder, haw_prefix, str(year), logFile)
  if os.path.isfile(file):
    data = []
    with open(file, 'r') as log_file:
      for line in log_file:
        updateJobData (data, jobDict(line))
    return removeCost(data)
  else:
    return []

def stringIndexInLine (line, string):
  return (line.find(string), line.find(string) + len(string))

def checkAvailability (line, searchString):
  index = stringIndexInLine (line, searchString)
  if index[0] != -1:
    return line[index[1]:line.find(';', index[0])]
  else: return 'unknown'

def jobDict (line):
  return {
    #'prcs': checkAvailability(line, 'TotalRequestedProcs='),
    #'nodes': checkAvailability(line, 'TotalRequestedNodes='),
    'userID': checkAvailability(line, 'User='),
    'email': checkAvailability(line, 'Mail='),
    'cost': [checkAvailability(line, 'TotalCost=')],
    #'walltime': checkAvailability(line, 'UsedWallTime=')
  }

def updateJobData (dataList, insertDict):
  for userDict in dataList:
    if userDict['userID'] == insertDict['userID']:
      if userDict['email'] != 'unknown':
        insertDict['email'] = userDict['email']
      insertDict['cost'].extend(userDict['cost'])
      dataList.remove(userDict)
  totalCosts = 0
  for cost in insertDict['cost']:
    totalCosts += float(cost)
  dataList.append({
    "userID": insertDict['userID'],
    "email": insertDict['email'],
    "cost": insertDict['cost'],
    "totalCosts": totalCosts
  })

def removeCost (dataList):
  returnDict = []
  for rowDict in dataList:
    returnDict.append({
      "userID": rowDict['userID'],
      "email": rowDict['email'],
      "costs": rowDict['totalCosts']
    })
  return returnDict

def main (argv):
  year = -1
  month = -1
  try:
    opts, args = getopt.getopt(argv, "tjy:m:")
  except getopt.GetoptError:
    print ('user_data.py -y <year> -m <month> -j|-t')
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-y':
      year = int(arg)
    elif opt == '-m':
      month = int(arg)
    if opt == '-j':
      jsonDump(year, month)
    elif opt == '-t':
      tsDump(year, month)


if __name__ == "__main__":
  main(sys.argv[1:])
