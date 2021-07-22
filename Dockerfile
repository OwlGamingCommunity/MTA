FROM debian:stable-slim

# Dependencies
RUN apt-get update && apt-get install -y \
	unzip \
	wget \
	default-libmysqlclient-dev \
	libncurses5-dev \
	libncursesw5-dev \
	libncurses5 \
	libncursesw5 \
	&& apt clean \
	&& ldconfig

# Creates a system user with no password and a home directory
RUN useradd -d /home/mtasa -m mtasa

# Setup our workdir
WORKDIR /home/mtasa/

# Download the latest linux server binaries and set them up in /home/mtasa/server
RUN wget -O mta.tar.gz https://linux.mtasa.com/dl/multitheftauto_linux_x64.tar.gz \
	&& tar xfz mta.tar.gz \
	&& mv multitheftauto_linux_* server \
	&& rm mta.tar.gz \
	&& adduser -h /home/mtasa -D -S mtasa \
	&& chown -R mtasa server

# Copy our source code over
COPY --chown=mtasa mods/deathmatch/ server/mods/deathmatch/

RUN mv server/mods/deathmatch/linux-libs/* /usr/lib/x86_64-linux-gnu/

USER mtasa

EXPOSE 22003 22005 22126
# Can set defaults like so:
# ENV SERVER_IP 127.0.0.1

ADD --chown=mtasa docker-entrypoint.sh ./docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh
ENTRYPOINT [ "./docker-entrypoint.sh" ]