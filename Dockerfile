FROM ubuntu:22.04

# Ensure we're running as root by default (explicitly set)
USER root

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && \
    apt-get install -y python3 python3-pip wget curl jq cron git gnupg ca-certificates && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    pip3 install --upgrade pip


# Install Node.js 18.x using the official method
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y sudo && \
    apt-get install -y apt-utils

# Verify Node.js and npm installation
RUN node --version && npm --version

# Create app directory
WORKDIR /app

# Clone repository
RUN git clone --depth=1 "https://github.com/jacksonlmakl/framework.git" /app/

# Install dependencies
RUN cd /app && npm install

# Create a directory for Docker socket and other Docker related files
RUN mkdir -p /var/run

# Create necessary scripts
RUN chmod +x /app/bin/run /app/bin/deploy /app/bin/docker-stop /app/bin/docker-logs

# Create default controller.yaml if it doesn't exist
RUN chmod 666 /app/controller.yaml

# Create a wrapper script for the deploy command to avoid systemd dependency
RUN echo '#!/bin/bash\n\
\n\
# Path to the original deploy script\n\
DEPLOY_SCRIPT="/app/bin/deploy"\n\
\n\
# Function to start Docker service without systemd\n\
start_docker() {\n\
  if [ ! -S /var/run/docker.sock ]; then\n\
    echo "Starting Docker daemon..."\n\
    dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 &\n\
    # Wait for Docker to start\n\
    echo "Waiting for Docker to start..."\n\
    while ! docker info >/dev/null 2>&1; do\n\
      sleep 1\n\
    done\n\
    echo "Docker daemon started"\n\
  else\n\
    echo "Docker socket exists, assuming Docker is running"\n\
  fi\n\
}\n\
\n\
# Create a modified version of the deploy script without systemd dependencies\n\
modify_deploy_script() {\n\
  if [ -f "$DEPLOY_SCRIPT" ]; then\n\
    # Create a backup of the original script\n\
    cp "$DEPLOY_SCRIPT" "${DEPLOY_SCRIPT}.orig"\n\
    \n\
    # Replace systemctl commands with service or direct commands\n\
    sed -i "s/systemctl start docker/service docker start || dockerd --host=unix:\/\/\/var\/run\/docker.sock --host=tcp:\/\/0.0.0.0:2375 \&/g" "$DEPLOY_SCRIPT"\n\
    sed -i "s/systemctl enable docker/echo \"Docker service would be enabled at system startup\"/g" "$DEPLOY_SCRIPT"\n\
    sed -i "s/service cron start/\/etc\/init.d\/cron start/g" "$DEPLOY_SCRIPT"\n\
    \n\
    echo "Modified deploy script to work without systemd"\n\
  else\n\
    echo "Warning: Deploy script not found at $DEPLOY_SCRIPT"\n\
  fi\n\
}\n\
\n\
# Start Docker service\n\
start_docker\n\
\n\
# Modify the deploy script\n\
modify_deploy_script\n\
\n\
# Run the original deploy script with the environment set\n\
echo "Running deploy script..."\n\
cd /app && bash bin/deploy "$@"\n' > /app/docker-deploy-wrapper.sh && \
    chmod +x /app/docker-deploy-wrapper.sh


# Create start script - will be copied in later
RUN echo '#!/bin/bash\n\
echo "Starting application container..."\n\
echo "Node.js version: $(node --version)"\n\
echo "NPM version: $(npm --version)"\n\
\n\
# Make Docker socket accessible if mounted\n\
chmod 666 /app \n\
\n\
# Make Docker socket accessible if mounted\n\
chmod 777 /app \n\
\n\
# Make Docker socket accessible if mounted\n\
chmod 666 /var/run/docker.sock 2>/dev/null || true\n\
\n\

# Start backend server\n\
echo "Starting backend server on port 5000..."\n\
node /app/server.js & \n\
BACKEND_PID=$!\n\
\n\
# Wait a moment for backend to start\n\
sleep 2\n\
\n\
# Start frontend server\n\
echo "Starting frontend server on port 3000..."\n\
cd /app && npm run client & \n\
FRONTEND_PID=$!\n\
\n\
# Monitor processes\n\
echo "Application started:"\n\
echo "- Backend process ID: $BACKEND_PID"\n\
echo "- Frontend process ID: $FRONTEND_PID"\n\
echo "Access backend API at: http://localhost:5000"\n\
echo "Access frontend UI at: http://localhost:3000"\n\
\n\
# Trap SIGTERM and SIGINT\n\
trap '"'"'kill -TERM $BACKEND_PID $FRONTEND_PID; exit'"'"' TERM INT\n\
\n\
# Wait for either process to exit\n\
wait $BACKEND_PID $FRONTEND_PID\n' > /app/start.sh && \
    chmod +x /app/start.sh

# Expose both frontend and backend ports
EXPOSE 3000 5000 2375

# Command to run the application
CMD ["/app/start.sh"]
