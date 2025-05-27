FROM alpine:3.21.3

RUN apk add --no-cache openssh-server git \
 && addgroup -g 1000 git \
 && adduser -h /home/git -s /bin/sh -u 1000 -G git -g "" -D git \
 && passwd -d git \
 && /usr/bin/ssh-keygen -A

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
