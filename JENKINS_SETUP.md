# Jenkins CI/CD Pipeline Setup for Laravel Docker Deployment

## Overview
This guide sets up a complete CI/CD pipeline that:
1. Builds Docker images in Jenkins
2. Pushes images to Docker Hub
3. Triggers deployment on Render hosting

## Prerequisites
- Jenkins server with Docker installed
- Docker Hub account
- Render account with your Laravel app connected

## 1. Jenkins Credentials Setup

### 1.1 Docker Hub Credentials
1. Go to Jenkins Dashboard → Manage Jenkins → Manage Credentials
2. Click "Global" domain → "Add Credentials"
3. Create **Username with password** credential:
   - **Kind**: Username with password
   - **ID**: `DOCKER_HUB_CREDENTIALS`
   - **Username**: Your Docker Hub username
   - **Password**: Your Docker Hub password or access token
   - **Description**: Docker Hub Login Credentials

### 1.2 Render Deploy Hook
1. In Render Dashboard, go to your service
2. Go to Settings → Deploy Hook
3. Copy the Deploy Hook URL
4. In Jenkins, add **Secret text** credential:
   - **Kind**: Secret text
   - **ID**: `RENDER_DEPLOY_HOOK`
   - **Secret**: Your Render Deploy Hook URL
   - **Description**: Render Deploy Hook URL

## 2. Jenkins Pipeline Configuration

### 2.1 Create New Pipeline Job
1. Jenkins Dashboard → "New Item"
2. Enter job name: `laravel-jenkins-render-app`
3. Select "Pipeline" → Click "OK"

### 2.2 Configure Pipeline
1. **General Tab**:
   - ✅ GitHub project: `https://github.com/HitKakadiya3/laravel_jenkins_render_app`
   - ✅ Build Triggers: "GitHub hook trigger for GITScm polling"

2. **Pipeline Tab**:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/HitKakadiya3/laravel_jenkins_render_app.git`
   - **Branch**: `*/main`
   - **Script Path**: `Jenkinsfile`

## 3. Jenkins Agent Requirements

### 3.1 Install Docker on Jenkins Agent
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# CentOS/RHEL
sudo yum install docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### 3.2 Install Required Tools
```bash
# Install curl (if not present)
sudo apt-get install curl

# Verify installations
docker --version
curl --version
```

## 4. Pipeline Stages Explained

### Stage 1: Checkout
- Clones the repository from GitHub
- Switches to the main branch

### Stage 2: Environment Setup
- Displays build information
- Verifies Docker installation

### Stage 3: Docker Build
- Builds Docker image with build number tag
- Creates both versioned and latest tags
- Uses multi-stage building for optimization

### Stage 4: Docker Test
- Runs container for health check
- Tests application startup
- Verifies container functionality
- Cleans up test containers

### Stage 5: Docker Push
- Authenticates with Docker Hub
- Pushes both tagged and latest images
- Makes images available for deployment

### Stage 6: Deploy to Render
- Triggers Render deployment via webhook
- Uses the latest pushed Docker image
- Provides deployment status feedback

## 5. Render Configuration Update

### 5.1 Update Render Service Settings
In your Render dashboard:
1. Go to your service settings
2. Update **Docker Image**: `your-dockerhub-username/laravel-jenkins-render-app:latest`
3. Ensure **Auto-Deploy** is enabled for webhook triggers

### 5.2 Environment Variables in Render
Ensure these are set in Render:
```
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:generated-key
DB_CONNECTION=sqlite
DB_DATABASE=/var/www/html/database/database.sqlite
SESSION_DRIVER=database
CACHE_STORE=database
LOG_CHANNEL=stderr
```

## 6. GitHub Webhook Setup (Optional)

### 6.1 Configure GitHub Webhook
1. Go to GitHub repository → Settings → Webhooks
2. Click "Add webhook"
3. **Payload URL**: `http://your-jenkins-server/github-webhook/`
4. **Content type**: `application/json`
5. **Events**: "Just the push event"
6. **Active**: ✅ Checked

## 7. Testing the Pipeline

### 7.1 Manual Trigger
1. Go to Jenkins job → "Build Now"
2. Monitor console output for each stage
3. Verify Docker image in Docker Hub
4. Check deployment in Render dashboard

### 7.2 Automatic Trigger
1. Make a code change and push to main branch
2. Pipeline should automatically start
3. Verify end-to-end deployment

## 8. Monitoring and Logs

### 8.1 Jenkins Build Logs
- Jenkins Dashboard → Job → Build History → Console Output

### 8.2 Docker Hub Registry
- Check images at: `https://hub.docker.com/r/your-username/laravel-jenkins-render-app`

### 8.3 Render Deployment Logs
- Render Dashboard → Your Service → Logs

## 9. Troubleshooting

### Common Issues:

#### 9.1 Docker Permission Denied
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

#### 9.2 Docker Hub Authentication Failed
- Verify credentials ID matches: `DOCKER_HUB_CREDENTIALS`
- Check username/password in Jenkins credentials

#### 9.3 Render Deploy Hook Failed
- Verify webhook URL is correct
- Check credential ID: `RENDER_DEPLOY_HOOK`
- Ensure webhook is active in Render

#### 9.4 Application Not Starting
- Check Render logs for container startup errors
- Verify Docker image runs locally
- Check environment variables in Render

## 10. Pipeline Benefits

✅ **Automated Docker Builds**: Every commit triggers a new Docker image
✅ **Version Control**: Each build gets a unique tag
✅ **Automated Testing**: Container health checks before deployment
✅ **Zero Downtime**: Render handles rolling deployments
✅ **Rollback Capability**: Previous Docker image versions available
✅ **Monitoring**: Complete pipeline visibility and logging

## Security Best Practices

1. **Use Jenkins Credentials Manager** for all secrets
2. **Never hardcode** Docker Hub passwords or API keys
3. **Regularly rotate** Docker Hub access tokens
4. **Use specific Docker Hub permissions** (not full account access)
5. **Monitor pipeline logs** for any exposed credentials
6. **Keep Jenkins and Docker updated** to latest versions

This setup provides a production-ready CI/CD pipeline for your Laravel application with Docker containerization and automated deployment to Render!