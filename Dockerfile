FROM ubuntu

MAINTAINER "Julien Dubreuil"

RUN apt-get update && apt-get install -y cron
RUN rm -rf /var/lib/apt/lists/*

COPY crontab /tmp/crontab
COPY run-crond.sh /run-crond.sh

RUN chmod -v +x /run-crond.sh

RUN touch /var/log/cron.log

CMD ["/run-crond.sh"]
