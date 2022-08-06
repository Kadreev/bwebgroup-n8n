FROM node:lts-alpine

# Installs latest Chromium (100) package.
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      nodejs \
      yarn


# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Puppeteer v13.5.0 works with Chromium 100.
RUN yarn add puppeteer@13.5.0

# Add user so we don't need --no-sandbox.
RUN addgroup -S pptruser && adduser -S -G pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads /app \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app


# pass N8N_VERSION Argument while building or use default
ARG N8N_VERSION=0.188.0

# Update everything and install needed dependencies
RUN apk add --update graphicsmagick tzdata

# Set a custom user to not have n8n run as root
USER root

# Install n8n and the also temporary all the packages
# it needs to build it correctly.
RUN apk --update add --virtual build-dependencies python3 build-base && \
	npm_config_user=root npm install -g n8n@${N8N_VERSION} && \
	apk del build-dependencies

# Specifying work directory
WORKDIR /data

# copy start script to container
COPY ./start.sh /

# make the script executable
RUN chmod +x /start.sh

# define execution entrypoint
CMD ["/start.sh"]
USER pptruser
