#!/bin/bash
# Docker's environment variable are not passed to cron. We need to inject them
# inside the result file. The following command will add all variables starting
# with ENV_ to the top of the result file.
env | egrep '^ENV_' | cat - /tmp/crontab > /etc/cron.d/crontab

cron && tail -f /var/log/cron.log
