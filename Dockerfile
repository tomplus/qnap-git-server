FROM amd64/ubuntu:25.10
RUN userdel -r ubuntu
RUN apt-get update \
 && apt-get upgrade -y && apt-get install -y openssh-server bash git vim lighttpd libcgi-pm-perl busybox-syslogd \
 && rm -rf /var/lib/apt/lists/* \
 && rm /etc/update-motd.d/* \
 && addgroup --gid 1000 git \
 && adduser --home /home/git --shell /bin/bash --uid 1000 --gid 1000 --gecos "" --disabled-password git \
 && /usr/bin/ssh-keygen -A \
 && rm /etc/pam.d/sshd

ADD start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22 1234

CMD ["/start.sh"]
