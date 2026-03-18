# Docker

> **_NOTE:_** The actions in this guide are handled by our [setup script](/linux/mint/initial-setup.sh). This guide is purely informational and should not be executed without reason. 

Linux Mint sometimes fails to start some of our Docker images, throwing a `Connection Refused` error. This, while not a huge issue, is quite annoying, as it can interrupt our workflow (application tries to start, but can't because S3 is refusing connection for example). The error causing the images to fail to start is quite vague and seems to be caused by a race condition where Docker starts before the home directory is fully mounted. This is where our Docker image configurations are kept, meaning that nothing can be started if they cannot be reached. This race condition is caused by Linux Mint's boot sequence being much more parallelized than, for example, OpenSUSE, where everything worked fine.

A temporary workaround for the current session is just restarting the images either by doing `docker-compose up` or `make services-restart` in the monolith repository. When you encounter the error, the `/home` partition is most definitely already mounted, so this restart does not throw any errors and starts the images succesfully.

There is also a more permanent fix. For this, first run `sudo systemctl edit docker.service`. Then, paste the following in the editor. Pay attention to the comments in the `docker.service` file. You need to paste this in the correct place - somewhere at the start of the file.
```sh
[Service]
ExecStartPre=/bin/sleep 5

[Unit]
After=home.mount
Requires=home.mount
```

The `After` entry tells `systemd` that the Docker service can not start unless `/home` is mounted, resolving the race condition that was happening. The `ExecStartPre` is an additional safety for this, as there might be a small delay between the system reporting `/home` as mounted and it actually being 
fully mounted and settled. The `Requires` tells `systemd` to not try to start at all if `/home` is not mounted. 

Save and exit this file and then apply the changes and restart the `docker.service`
```
sudo systemctl daemon-reload
sudo systemctl restart docker.service
```

The `restart docker.service` step will take a minute or so - this is normal, just wait it out. You can then validate whether this worked by restarting your system and running `docker ps`. This should list all images with `Status` `Up` or something similar instead of `Exited`. Make sure you see all the Docker images that Stager uses as a service. At the time of writing these are LocalStack, Mailpit, S3Ninja, ElasticMQ, redis and the database meaning that you should see at least 6 entries in the list produces by `docker ps`. 