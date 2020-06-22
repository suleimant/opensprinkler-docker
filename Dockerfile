########################################
## 1st stage builds OS for RPi
FROM i386/ubuntu as build
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y apt-utils git  bash ca-certificates g++
RUN git clone https://github.com/OpenSprinkler/OpenSprinkler-Firmware.git && \
    cd OpenSprinkler-Firmware && \
    ./build.sh -s demo

########################################
## 2nd stage is minimal runtime + executable
FROM  i386/ubuntu
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /OpenSprinkler
RUN apt-get update
RUN apt-get install -y  apt-utils libstdc++ && \
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
EXPOSE 80

CMD [ "./OpenSprinkler" ]
