# Webapp: HAW UCC on bwUniCluster under HAW project
-------------------------------------

The "Hochschulen fuer Angewandte Wissenschaften" project is designed to view and configure computational resources on HPC clusters at various providers.

The website is designed to process and display the HAW users usage of total cluster capacity on bwUniCluster.

## Frontend:
 Angular

## Data processing:
 Bash scripts / Python 3

## First install
1. Set personal user data in 'set_user_data.sh' script and run it.
2. Run 'npm install' in './bwUniCluster' folder.
2. Run 'npm install' in './app_uni' folder.

## Update
Run 'bwUniCluster*/main_sh/update.sh' or set a scheduled cron job 'bwUniCluster*/main_sh/cronJob.sh'
