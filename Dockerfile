FROM i386/alpine as base

########################################
## 1st stage builds OS for RPi
FROM base as build

WORKDIR /OpenSprinkler-Firmware
RUN apk --no-cache add git bash ca-certificates g++ mosquitto-dev 
RUN git clone https://github.com/OpenSprinkler/OpenSprinkler-Firmware.git && \
    cd OpenSprinkler-Firmware && \
    ./build.sh -s demo

########################################
## 2nd stage is minimal runtime + executable
FROM base


RUN apk --no-cache add libstdc++ && \
  mkdir -p /data/logs && \
  ln -s /data/stns.dat && \
  ln -s /data/nvm.dat && \
  ln -s /data/ifkey.txt && \
  ln -s /data/logs

COPY --from=build /OpenSprinkler-Firmware/OpenSprinkler /OpenSprinkler/OpenSprinkler
WORKDIR /OpenSprinkler

#-- Logs and config information go into the volume on /data
VOLUME /data

#-- OpenSprinkler interface is available on 8080
EXPOSE 8080

#-- By default, start OS using /data for saving data/NVM/log files
CMD [ "./OpenSprinkler" ]
