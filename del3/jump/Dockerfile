FROM python:3.12-alpine
RUN apk add --no-cache openssh nmap curl bash \
 && pip install --no-cache-dir 'pymodbus[serial]==3.7.4' \
 && ssh-keygen -A \
 && adduser -D -s /bin/sh otadmin \
 && echo 'otadmin:LabPass2026!' | chpasswd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
