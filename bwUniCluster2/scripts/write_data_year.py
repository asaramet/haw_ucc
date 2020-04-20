#!/usr/bin/env python3

import os, sys, getopt
from string import Template

MD = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
OUT_FOLDER = os.path.join(MD, "src/app/_data")
DATA_FOLDER = "/www/faculty/it/bwHPC/SCRIPTS/bwUniCluster2/sacct_logs"
TEMP_FILE = os.path.join(DATA_FOLDER, "temp.txt")

PREFIXES = ['aa', 'as', 'es', 'hf', 'hk', 'hn', 'hr', 'hs', 'ht', 'hu', 'ro']

def main(argv):
  usage_msg = 'Usage: ' + argv[0] + ' -y <year> -m <last month>'
  try:
    opts, args = getopt.getopt(argv[1:], "y:m:")
  except getopt.GetoptError:
    print(usage_msg)
    sys.exit(1)

  year, month = 0, 0
  for opt, arg in opts:
    if opt == "-y":
      year = int(arg)
    if opt == "-m":
      month = int(arg)

  if year == 0 or month == 0:
    print('Missing year or month.', usage_msg)
    sys.exit(2)

  write_ts(year, month)

def write_ts(year, month):
  OUT_FILE = os.path.join(OUT_FOLDER, str(year) + ".ts")

  if not os.path.exists(OUT_FOLDER):
    os.makedirs(OUT_FOLDER)

  if os.path.isfile(TEMP_FILE):
    os.remove(TEMP_FILE)

  start_month = 3 if year == 2020 else 1

  text = ''
  while start_month <= month:
    month_string = '0' + str(start_month) if start_month < 10 else str(start_month)
    log_file = os.path.join(DATA_FOLDER, str(year) + '-' + month_string + '.log')

    template = "export const udata_${year}_${month} = ${data}\n\n"
    text += Template(template).substitute(year = str(year), month = str(start_month),
      data = monthly_data(log_file))
    start_month += 1

    # append log data to TEMP_FILE to get the yearly totals later
    with open(log_file, 'r') as file:
      content = file.read()
    with open(TEMP_FILE, 'a') as temp_file:
      temp_file.write(content)

  # get totals from TEMP_FILE
  template = "export const udata_${year} = ${data}\n"
  text += Template(template).substitute(year = str(year), data = monthly_data(TEMP_FILE))

  with open(OUT_FILE, 'w') as file:
    file.write(text)
  os.remove(TEMP_FILE)


def monthly_data(log_file):
  #dict = [{'haw': 'aa', 'data':[{'userID':'aa_000'}]}]
  if not os.path.isfile(log_file):
    print("ERROR: file", log_file, "not found!")
    sys.exit(3)

  data_list = []
  with open(log_file, 'r') as file:
    for line in file:

      user_data = line.split()[1:4]
      prefix = user_data[0].split('_')[0]
      data = {'userID': user_data[1], 'email': '-', 'costs': user_data[2]}
      if prefix in PREFIXES:
        if data_list == []:
          data_list = [{'haw': prefix, 'data': [data]}]
          continue

        found_uni_in_db = 0 # flag to check if the data was updated
        for uni in data_list:
          if uni['haw'] == prefix:

            if is_user(data_list, prefix, user_data[1]):
              # get the user data and update the costs in data
              for user_obj in uni['data']:
                if user_obj ['userID'] == user_data[1]:
                  data['costs'] = str(int(user_data[2]) + int(user_obj['costs']))
                  uni['data'].remove(user_obj)

            uni['data'].append(data)
            found_uni_in_db = 1

        if found_uni_in_db == 0:
          data_list.append({'haw': prefix, 'data':[data]})

  return data_list

def is_user(data_list, uni_prefix, user_ID):
  # check if user exists in database
  if data_list == []:
    return False
  for uni in data_list:
    if uni['haw'] == uni_prefix:
      for user in uni['data']:
        if user['userID'] == user_ID:
          return True
  return False


if __name__ == "__main__":
  main(sys.argv)
