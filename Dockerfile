FROM alpine:latest

# Installs latest Chromium package.
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk upgrade -U -a \
    && apk add \
    libstdc++ \
    chromium \
    xvfb \
    harfbuzz \
    nss \
    freetype \
    ttf-freefont \
    font-noto-emoji \
    gtk+3.0 \
  #  ffmpeg ffmpeg-libs \
    xvidcore opus libogg libvorbis libtheora x264 x265 x264-libs x265-libs \
    wqy-zenhei nodejs npm \
    ca-certificates \
#    tini make gcc g++ python3 \
    alsa-utils alsa-lib alsaconf alsa-ucm-conf \
    pulseaudio-alsa pulseaudio pulseaudio-utils alsa-plugins-pulse \
    && rm -rf /var/cache/* \
    && mkdir /var/cache/apk

RUN addgroup root audio && rc-update add alsa
#addgroup $USER audio

# COPY --from=mwader/static-ffmpeg:5.0 /ffmpeg /usr/local/bin/
# COPY --from=mwader/static-ffmpeg:5.0 /ffprobe /usr/local/bin/

COPY local.conf /etc/fonts/local.conf

# Add Chrome as a user
RUN mkdir -p /usr/src/app 
#    && adduser -D chrome \
#    && chown -R chrome:chrome /usr/src/app
# Run Chrome as non-privileged
# USER chrome
WORKDIR /usr/src/app

ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/

WORKDIR /usr/src/app
#copy all files from bbb-mp4 project
COPY manifest.json index.js *.sh ./

# Install npm scripts puppeteer-core@13.1 for chromium 98
# https://github.com/puppeteer/puppeteer/blob/main/docs/api.md
RUN npm install npm@latest -g && npm init -y && npm i puppeteer-core@13.1 ws xhr2 xmlhttprequest xvfb 

#Initialize ENV
ENV REC_URL=" "

# Command that will execute when container starts
ENTRYPOINT ["sh","docker-entrypoint.sh"]
CMD node /usr/src/app/index.js $REC_URL
