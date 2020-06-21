FROM  i386/alpine as base-img

ENV LANG C.UTF-8

########################################
FROM base-img as build-img

RUN apk --no-cache add git  bash ca-certificates g++

RUN git clone https://github.com/OpenSprinkler/OpenSprinkler-Firmware.git && \
    cd OpenSprinkler-Firmware && \
RUN apk --no-cache add libmosquitto-dev
    ./build.sh -s demo

########################################
FROM base-img

RUN apk --no-cache add  libstdc++ && \
    mkdir /OpenSprinkler && \
    mkdir -p /data/logs && \
    cd /OpenSprinkler && \
    ln -s /data/stns.dat && \
    ln -s /data/nvm.dat && \
    ln -s /data/ifkey.txt && \
    ln -s /data/logs

COPY --from=build-img /OpenSprinkler-Firmware/OpenSprinkler /OpenSprinkler/OpenSprinkler
WORKDIR /OpenSprinkler

#-- Logs and config information go into the volume on /data
VOLUME /data

#-- OpenSprinkler interface is available on 8080
EXPOSE 80

CMD [ "./OpenSprinkler" ]
