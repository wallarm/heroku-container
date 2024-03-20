FROM <DOCKERHUB_USERNAME>/wallarm-heroku:4.10.3

ENV NODE_MAJOR=20

# Install NodeJS v20 from NodeSource
RUN apt-get update \
    && apt-get install -qqy ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install nodejs -qqy \
    && apt-get clean

ADD . /opt/webapp
WORKDIR /opt/webapp

# Install dependencies and build the app
RUN npm install --omit=dev 
ENV npm_config_prefix /opt/webapp

# Note that in private spaces the `run` section of heroku.yml is ignored
# See: https://devcenter.heroku.com/articles/build-docker-images-heroku-yml#known-issues-and-limitations
CMD ["npm", "run", "start"]
