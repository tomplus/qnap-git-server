# qnap-git-server

Host your own Git repositories on QNAP server

## Introduction

QNAP is a linux-based Network Attached Storage. It has a lot of nice features but there is no option for hosting git repositories by default. Fortunately there is an application named _Container Station_ which allows you to run Docker or LXC images. So it’s pretty easy to extend functions and for example install _GitLab_ to host git repositories (it’s QNAP recommendation). _Gitlab_ is a quite big system and if you need a just simple git server you can use this [qnap-git-server](https://github.com/tomplus/qnap-git-server).

## Instalation

First, you have to prepare a directory which will be attached to Docker. This directory has to contain your ssh public key and it is also a place where your repositories will be stored.

```
$ ssh admin@my-qnap.local
[~] cd /share
[/share] mkdir -p git/.ssh
[/share] mkdir git/pub
[/share] echo “---your public key from ~/.ssh/id_rsa.pub---” > git/.ssh/authorized_keys
[/share] chown 10000:10000 -R git/
[/share] chmod 700 git/
[/share] chmod 700 git/.ssh/
[/share] chmod 600 git/.ssh/authorized_keys
```

Now you can use _Container Station_ to start the image [tpimages/qnap-git-server](https://hub.docker.com/r/tpimages/qnap-git-server/). This image is prepared for arm32v7 only.
You have to mount prepared directory as /home/git and expose port 22 as for example 2222 to connect it from your local network. You can also start it from command line:

```
[~] docker run -d -v /share/git:/home/git -p 2222:22 --name qnap-git-server tpimages/qnap-git-server:latest
```

Now your server is up and running. You can connect to it via SSH to create a bare repository:

```
$ ssh -p 2222 git@my-qnap.local
$ mkdir pub/project.git
$ cd pub/project.git/
$ git init --bare
Initialized empty Git repository in /home/git/pub/project.git/
```

and then you can clone the repository
```
$ git clone ssh://git@my-qnap.local:2222/pub/project.git
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

If you get errors like `exec user process caused "exec format error"` it means that your qnap
has different architecture (eg. amd64) than the prepared image (arm32v7). It this case try to replace
the base image in `Dockerfile` from
```
FROM arm32v7/ubuntu:25.10
```
to for example:
```
FROM amd64/ubuntu:25.10
```
and build your own image.
