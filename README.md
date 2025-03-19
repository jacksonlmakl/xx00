# Quick Start
```
git clone https://github.com/jacksonlmakl/deploy && \
cd deploy && \
docker pull jacksonmakl/deploy-framework:latest && \
docker compose up -d
 ```
# Run As Root
```
git clone https://github.com/jacksonlmakl/deploy && \
cd deploy && \
sudo docker pull jacksonmakl/deploy-framework:latest && \
sudo docker compose up -d
```
# Build Image
```
docker compose build --no-cache && docker compose up -d
```
# Requirements

To install **Docker** and **Docker Compose** on Ubuntu, follow these steps:

---

### **Step 1: Update System Packages**
```sh
sudo apt update && sudo apt upgrade -y
```

---

### **Step 2: Install Required Dependencies**
```sh
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```

---

### **Step 3: Add Docker’s Official GPG Key**
```sh
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

---

### **Step 4: Add Docker Repository**
```sh
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

---

### **Step 5: Install Docker Engine and CLI**
```sh
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
```

---

### **Step 6: Enable and Start Docker Service**
```sh
sudo systemctl enable docker
sudo systemctl start docker
```

---

### **Step 7: Verify Docker Installation**
```sh
docker --version
```
Expected output (example):
```
Docker version 24.x.x, build xxxxxx
```

---

## **Installing Docker Compose**
Starting with **Docker 20.10**, **Docker Compose** is now included as `docker compose` (without a hyphen), so you might not need a separate installation.

### **Step 8: Install Docker Compose**
```sh
sudo apt install -y docker-compose-plugin
```

Or manually download the latest release:

```sh
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K[^"]+')
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

---

### **Step 9: Verify Docker Compose Installation**
```sh
docker compose version
```
Expected output (example):
```
Docker Compose version v2.x.x
```

---

## **Step 10: Allow Running Docker Without Sudo (Optional)**
By default, Docker requires root privileges. To run it as a non-root user, add your user to the `docker` group:

```sh
sudo usermod -aG docker $USER
newgrp docker
```

Then test:
```sh
docker run hello-world
```

---

### **Step 11: Enable Docker at Startup**
```sh
sudo systemctl enable docker
```

---

### **Step 12: Restart System (Optional but Recommended)**
```sh
sudo reboot
```

---

### **You're Done! 🎉**
Now, you can use `docker` and `docker compose` normally. 🚀
