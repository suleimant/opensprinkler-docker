FROM amd64/debian as base
ENV DEBIAN_FRONTEND noninteractive

########################################
## 1st stage builds OS for RPi
FROM base as build
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update 
RUN apt-get install -y git apt-utils bash ca-certificates g++ mosquitto-dev 
RUN git clone https://github.com/OpenSprinkler/OpenSprinkler-Firmware.git && \
    cd OpenSprinkler-Firmware && \
    ./build.sh -s demo

########################################
## 2nd stage is minimal runtime + executable
FROM base
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update 
RUN apt-get install -y libstdc++ && \
    mkdir /OpenSprinkler && \
    mkdir -p /data/logs && \
    cd /OpenSprinkler && \
    ln -s /data/stns.dat && \
    ln -s /data/nvm.dat && \
    ln -s /data/ifkey.txt && \
    ln -s /data/logs

COPY --from=build /OpenSprinkler-Firmware/OpenSprinkler /OpenSprinkler/OpenSprinkler

#-- Logs and config information go into the volume on /data
VOLUME /data

#-- OpenSprinkler interface is available on 8080
EXPOSE 8080

#-- By default, start OS using /data for saving data/NVM/log files
CMD [ "./OpenSprinkler" ]
