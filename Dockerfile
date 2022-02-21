FROM alpine:latest

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.description="Chrome running in headless mode in a tiny Alpine image" \
    org.label-schema.name="alpine-chrome" \
    org.label-schema.schema-version="1.0.0-rc1" \
    org.label-schema.usage="https://github.com/amg-web/alpine-chrome/blob/master/README.md" \
    org.label-schema.vcs-url="https://github.com/amg-web/alpine-chrome" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vendor="Anmg" \
    org.label-schema.version="latest"

# Installs latest Chromium package.
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" > /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
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
    ffmpeg \
    wqy-zenhei nodejs npm \
    ca-certificates \
#    tini make gcc g++ python3 \
    alsa-utils alsa-lib alsaconf alsa-ucm-conf \
    pulseaudio-alsa pulseaudio pulseaudio-utils alsa-plugins-pulse \
    && rm -rf /var/cache/* \
    && mkdir /var/cache/apk

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

# Install npm scripts puppeteer@13.1.0 for chromium 98
# https://github.com/puppeteer/puppeteer/blob/main/docs/api.md
RUN npm install npm@latest -g && npm init -y && npm i puppeteer-core@13.1 ws xhr2 xmlhttprequest xvfb 

#Initialize ENV
ENV REC_URL=" "

# Command that will execute when container starts
ENTRYPOINT ["sh","docker-entrypoint.sh"]
CMD node /usr/src/app/index.js $REC_URL
