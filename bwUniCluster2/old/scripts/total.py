#!/usr/bin/env python3
import os, json, sys, getopt
from datetime import date

dir_path = os.path.dirname(os.path.realpath(__file__))

def getHAW(dataLine):
  return dataLine.split(',')[1]

def getTotal(dataLine):
  sum = 0
  for element in dataLine.split(',')[1:]:
    sum += float(element)
  return "%.2f" % sum

def getDataLine(dataFile, year, month):
  if month < 10:
    mnth = '0' + str(month)
  else: mnth = str(month)
  with open(dataFile, 'r') as f:
    for line in f:
      if str(year) + "-" + mnth + "," in line:
        return line
  return str(year) + "-" + str(month) + ",0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0"

def tsObject(dataFile, year=2017, endMonth=12):
  text = "export const total_uca_" + str(year) + " = [\n"

  if year == 2017: startMonth = 5
  else: startMonth = 1
  while startMonth <= endMonth:
    dataLine = getDataLine(dataFile, year, startMonth)
    text += "  {year: " + str(year) + ", month: " + str(startMonth) + ", haw: " + getHAW(dataLine) + ", total: " + getTotal(dataLine) + "}"
    if startMonth != endMonth:
      text += ",\n"
    else:
      text += "\n]\n\n"
    startMonth += 1
  return text

def createTotalTS(dataFile, outputFile):
  if not os.path.isfile(dataFile): return "ERROR reading: " + dataFile

  with open(outputFile, 'w') as tsFile:
    year, startYear = date.today().year, 2017
    while startYear < year:
      tsFile.write(tsObject(dataFile, startYear, 12))
      startYear += 1
    tsFile.write(tsObject(dataFile, year, date.today().month))

def main (argv):
  dataFile = "/www/faculty/it/bwHPC/SCRIPTS/statistics/uc1_knotenauslastung_standorte.csv"
  outputFile = os.path.join(dir_path, "../../total.ts")
  try:
    opts, args = getopt.getopt(argv, "o:i:")
  except getopt.GetoptError:
    print ('GetoptError')
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-i':
      dataFile = arg
    elif opt == '-o':
      outputFile = arg
  createTotalTS(dataFile, outputFile)

if __name__ == "__main__":
  main(sys.argv[1:])
