# Creating a container for cron jobs

This is an example of how to create a docker container to run scheduled commands
using the crontab.

You can run it using

    $ docker build -t docker-cron-example .

    $ docker run -it --name cron-example docker-cron-example

Few minutes after having started the container you should see something similar to this:

```
Hello
Hello
Hello
```

## Using environment variables

Once the simple cron job is working, the main goal was to access environment variables in the command. For the example a simple "hello $world" is displayed but you may want to use variables inside a script. Unfortunately, the command executed by cron had not access to the container's environment variables. Thanks to this useful [stackoverflow thread](http://stackoverflow.com/questions/26822067/running-cron-python-jobs-within-docker) who gave me the solution who show me how to inject variables to the crontab file.

 The following command included in [run-crond.sh](run-crond.sh) loads all the environment variables, gets the one starting with ENV_, combine them at the top of the /tmp/crontab file and finally move the result to /etc/cron.d/crontab

    env | egrep '^ENV_' | cat - /tmp/crontab > /etc/cron.d/crontab

Add env variable to the docker run command to make use of them:

    $ docker run -it -e ENV_NAME=f00 docker-cron-example

This should output you the following log.

```
Hello f00
Hello f00
Hello f00
```

## Accessing to the logs

You can access to the crontab output by running docker logs on your container

    $ docker run -d -e ENV_NAME=f00 docker-cron-example
    $ docker logs <container_name>
    hello f00
    hello f00    

## The Dockerfile

```
FROM ubuntu

MAINTAINER "Julien Dubreuil"

RUN apt-get update && apt-get install -y \
       cron \ 
&& rm -rf /var/lib/apt/lists/*

COPY crontab /tmp/crontab

COPY run-crond.sh /run-crond.sh
RUN chmod -v +x /run-crond.sh

RUN touch /var/log/cron.log

CMD ["/run-crond.sh"]

```

1. The FROM command specify our base image. It used a ubuntu image as our base image but you can use a smaller one like Alpine and so one.

2. We install the cron package using the RUN command and in addition, we clean up the apt cache by removing /var/lib/apt/lists in orddr to reduce the image size.

3. Next, we copy the crontab file to the local directory of the container in order to make it available as declared in the run-crond.sh file.

3. Then, we copy the crontab run script to the container and make it executable.

4. We Create a default log file for the cron job.

5. Finally, we specify the command that container will execute on startup.

## Copyright and License

MIT License, see [LICENSE](License.txt) for details.

Copyright (c) 2017 Julien Dubreuil
