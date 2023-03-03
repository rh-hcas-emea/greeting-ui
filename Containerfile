FROM registry.access.redhat.com/ubi9/nodejs-18 as build

# Install dependencies - caching can speed up development
COPY package.json package-lock.json ./
RUN npm ci

# Build application
COPY . .
RUN npm run build

# Runtime image
FROM registry.access.redhat.com/ubi8/nginx-120

# Add application sources to a directory that the assemble script expects them
# and set permissions so that the container runs without root access
COPY --from=build --chown=default $HOME/build /tmp/src/

# Let the assemble script to install the dependencies
RUN $STI_SCRIPTS_PATH/assemble

# Run script uses standard ways to run the application
CMD $STI_SCRIPTS_PATH/run
