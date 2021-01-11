#!/usr/bin/env python3

import os, sys, getopt
from datetime import datetime, date, timedelta

MD = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
OUT_FOLDER = os.path.join(MD, "src/app/_data")
DATA_FOLDER = "/www/faculty/it/bwHPC/SCRIPTS/bwUniCluster2/sacct_logs"


PARTITIONS = ["dev_single", "single", "dev_multiple", "multiple", "fat", "dev_multiple_e",
  "multiple_e", "dev_special", "special", "gpu_4", "gpu_8"]

def main(argv):
  msg = f"Usage: {argv[0]} -y START_YEAR"

  try:
    opts, args = getopt.getopt(argv[1:], "y:")
  except getopt.GetoptError:
    print(msg)
    sys.exit(1)

  start_year = 2020
  for opt, arg in opts:
    if opt == "-y" and int(arg) > 2020:
      start_year = int(arg)

  END_YEAR = date.today().year

  # write collected data into the data file
  while start_year <= END_YEAR:
    # sort text into a dict once
    sorted_text = read_data(start_year)

    data_file = os.path.join(OUT_FOLDER, f"{start_year}.ts")

    with open(data_file, 'w') as f:
      for queue in PARTITIONS:
        f.write(ts_list(queue, sorted_text))

    start_year += 1

# convert data line to ts list
def convert(line):
  data = line.split()
  if data[-1] == "Unknown" or data[6] == "Unknown":
    return -1
  start = datetime.fromisoformat(data[6])
  submit = datetime.fromisoformat(data[-1])
  wait = start - submit

  # get number of procs
  ntasks = data[-3]

  # get days to add to hours if it is the case
  if ('day' in str(wait)):
    days = wait.days
    time = str(wait).split(', ')[1].split(":")
    hours = time
  else:
    days = 0
    time = str(wait).split(':')

  hours = days * 24 + int(time[0])
  minutes = int(time[1])
  seconds = int(time[2])

  total = seconds + 60 * minutes + 3600 * hours

  if total == 0: return -1

  return f'["", new Date({start.year}, {start.month - 1}, {start.day}), {total}, {ntasks}]'

def read_data(year):
  if year == 2020:
    start_month = 3
  else:
    start_month = 1

  # set the end month up to which to read data to
  CURRENT_YEAR = date.today().year
  if year < CURRENT_YEAR:
    end_month = 12
  else:
    yesterday = date.today() - timedelta(1)
    end_month = yesterday.month

  # init a dictionary to collect lines from all the data files
  sorted_lines = {}
  for queue in PARTITIONS:
    sorted_lines[queue] = []

  # read each file and sort lines into the dictionary
  while start_month <= end_month:
    if start_month < 10:
      month = f"0{start_month}"
    else: month = str(start_month)

    file = os.path.join(DATA_FOLDER, f"{year}-{month}.log")
    with open(file, 'r') as f:
      for line in f:
        queue = line.split()[-2]
        if queue not in PARTITIONS: continue # ignore comments and redundancy in txt file
        sorted_lines[queue].append(line)

    start_month += 1

  return sorted_lines

# return ts list for a specific queue
def ts_list(queue, sorted_text):
  text = f"export const {queue}:any[] = ["
  for line in sorted_text[queue]:
    converted = convert(line)
    if converted != -1:
      text += converted + ", "
  text += "]\n\n"
  return text

if __name__ == '__main__':
  main(sys.argv)
