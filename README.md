# qnap-git-server

Host your own Git repositories on QNAP server

## Introduction

QNAP is a linux-based Network Attached Storage. It has a lot of nice features but there is no option for hosting git repositories by default. Fortunately there is an application named _Container Station_ which allows you to run Docker or LXC images. So it’s pretty easy to extend functions and for example install _GitLab_ to host git repositories (it’s QNAP recommendation). _Gitlab_ is a quite big system and if you need a just simple git server you can use this [xrubioj/qnap-git-server](https://github.com/xrubioj/qnap-git-server).

This project is based on [tomplus/qnap-git-server](https://github.com/tomplus/qnap-git-server), but it has been rewritten from the scratch to use a more lightweight alternative (Alpine Linux). Also, it builds images for Intel/AMD and ARM CPUs.

## Instalation

First, you have to prepare a directory which will be attached to Docker. This directory has to contain your ssh public key and it is also a place where your repositories will be stored.

You can use the following script:

```
$ ./init.sh <user>@<qnap-address> <ssh-public-key-path>
# e.g.
$ ./init.sh admin@my-qnap.local ~/.ssh/id_rsa.pub
```

Alternatively, you can run the steps manually by `ssh`ing to your QNAP box as `admin` and manually running the commands like so:

```
$ ssh admin@my-qnap.local
[~] cd /share
[/share] mkdir -p git/.ssh
[/share] mkdir git/pub
[/share] echo “---your public key from ~/.ssh/id_rsa.pub---” > git/.ssh/authorized_keys
[/share] chown 1000:1000 -R git/
[/share] chmod 700 git/
[/share] chmod 700 git/.ssh/
[/share] chmod 600 git/.ssh/authorized_keys
```

Now you can use _Container Station_ to start the image [xrubioj/qnap-git-server](https://hub.docker.com/r/xrubioj/qnap-git-server/). This image is prepared for linux/amd64, linux/386, linux/arm/v7 (32 bits) and linux/arm64.
You have to mount prepared directory as /home/git and expose port 22 as for example 2222 to connect it from your local network. You can also start it from command line:

```
[~] docker run -d -v /share/git:/home/git -p 2222:22 --rm tpimages/qnap-git-server:latest
```

## Accessing git repositories from your home directory

You can link your `pub` directory to be visible from your QNAP user's home directory. In my case:

```
$ ssh -p 2222 git@my-qnap.local

# Confirm where /share/homes point to
[~] ls -l /share/homes
lrwxrwxrwx 1 admin administrators 23 2024-08-16 09:25 /share/homes -> CE_CACHEDEV1_DATA/homes/

# Link /share/git to git directory in your user network share (based on the result of the previous ls command)
[~] ln -s /share/git/ /share/CE_CACHEDEV1_DATA/homes/my_user/git
```

## Creating your first repository

Now your server is up and running. You can connect to it via SSH to create a bare repository:

```
$ ssh -p 2222 git@my-qnap.local
[~] mkdir pub/project.git
[~] cd pub/project.git/
[~] git init --bare
Initialized empty Git repository in /home/git/pub/project.git/
```

and then you can clone the repository:

```
$ git clone ssh://git@my-qnap.local:2222/home/git/pub/project.git
```

## Building

If you want to build you own custom version of this image your can do it simple by docker build command:

```
docker build -t qnap-git-server:my-own-version .
```

## Troubleshooting

Structure of file `git/.ssh/authorized_keys` requires that each key is stored in separate lines.
If you store there only one key, ensure that there are not additional new lines `\n`.

To check logs from syslogd you can use command `docker exec` to run `syslogd`. It'll start the deamon
syslogd and all logs will be writting to /var/log/messages.
