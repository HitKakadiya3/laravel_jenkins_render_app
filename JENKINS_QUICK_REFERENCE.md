# Jenkins CI/CD Quick Setup - Reference Card

## 🚀 Quick Start Commands

### 1. Jenkins Credentials Setup (Required)
```
Credential ID: DOCKER_HUB_CREDENTIALS
Type: Username with password
Username: your-dockerhub-username
Password: your-dockerhub-password

Credential ID: RENDER_DEPLOY_HOOK  
Type: Secret text
Secret: https://api.render.com/deploy/srv-xxxxx?key=yyyy
```

### 2. Pipeline Creation
```
Job Name: laravel-jenkins-render-app
Type: Pipeline
SCM: Git
Repository: https://github.com/HitKakadiya3/laravel_jenkins_render_app.git
Branch: */main
Script Path: Jenkinsfile
```

### 3. Update Render Configuration
Replace `your-dockerhub-username` in render.yaml:
```yaml
image:
  url: docker.io/your-dockerhub-username/laravel-jenkins-render-app:latest
```

### 4. Test Pipeline
```bash
# Manual trigger in Jenkins
1. Go to job → "Build Now"
2. Monitor console output
3. Check Docker Hub for new image
4. Verify deployment in Render

# Automatic trigger
1. Push code to main branch
2. Pipeline starts automatically
```

## 📋 Pipeline Stages Overview

| Stage | Duration | Description |
|-------|----------|-------------|
| Checkout | ~30s | Clone repository |
| Environment Setup | ~10s | Verify build tools |
| Docker Build | ~3-5min | Build Laravel Docker image |
| Docker Test | ~1min | Test container startup |
| Docker Push | ~1-2min | Push to Docker Hub |
| Deploy to Render | ~30s | Trigger Render deployment |

**Total Pipeline Time**: ~6-9 minutes

## 🔧 Required Jenkins Agent Setup

```bash
# Install Docker
sudo apt-get install docker.io
sudo usermod -aG docker jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# Verify
docker --version
```

## 🐳 Docker Image Info

- **Registry**: Docker Hub
- **Image Name**: `your-dockerhub-username/laravel-jenkins-render-app`
- **Tags**: 
  - `latest` (always points to newest)
  - `build-number` (specific versions)

## 🌐 URLs to Monitor

- **Jenkins Build**: `http://your-jenkins-server/job/laravel-jenkins-render-app/`
- **Docker Hub**: `https://hub.docker.com/r/your-username/laravel-jenkins-render-app`
- **Render Dashboard**: `https://dashboard.render.com/`
- **Live App**: `https://laravel-jenkins-render-app-1.onrender.com/`

## ⚠️ Common Issues & Fixes

| Issue | Quick Fix |
|-------|-----------|
| Docker permission denied | `sudo usermod -aG docker jenkins` |
| Docker Hub auth failed | Check credentials ID: `DOCKER_HUB_CREDENTIALS` |
| Render deploy failed | Verify webhook URL in `RENDER_DEPLOY_HOOK` |
| Build timeout | Increase Jenkins timeout settings |

## 📊 Success Indicators

✅ **Build Success**: Green build in Jenkins
✅ **Docker Push**: New image in Docker Hub  
✅ **Deployment**: "Deploy succeeded" in Render logs
✅ **App Running**: HTTP 200 response from app URL

This reference provides everything needed for day-to-day pipeline management!