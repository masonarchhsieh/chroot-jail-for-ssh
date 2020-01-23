FROM debian:latest
COPY create_chrooted_jail.sh /home/
COPY add_chroot_user.sh /home/
RUN apt-get update && apt-get install -y \
        git \
        vim \
        ssh \
        tree \
        ansible
RUN bash /home/create_chrooted_jail.sh

