# Laravel App Deployment to Render

## Prerequisites
1. Docker Desktop installed and running
2. Docker Hub account (https://hub.docker.com)
3. Render account (https://render.com)

## Step 1: Build and Push Docker Image

### 1.1 Login to Docker Hub
```bash
docker login
```
Enter your Docker Hub username and password when prompted.

### 1.2 Build the Docker Image
```bash
docker build -t your-dockerhub-username/laravel-jenkins-render-app:latest .
```
Replace `your-dockerhub-username` with your actual Docker Hub username.

### 1.3 Push to Docker Hub
```bash
docker push your-dockerhub-username/laravel-jenkins-render-app:latest
```

### 1.4 Alternative: Tag existing image and push
If you already built the image as `laravel-app`:
```bash
docker tag laravel-app your-dockerhub-username/laravel-jenkins-render-app:latest
docker push your-dockerhub-username/laravel-jenkins-render-app:latest
```

## Step 2: Deploy to Render

### Option A: Using render.yaml (Recommended)
1. Push your code to a Git repository (GitHub, GitLab, etc.)
2. Connect your repository to Render
3. Render will automatically use the `render.yaml` file for deployment configuration

### Option B: Manual Deployment via Render Dashboard
1. Go to https://render.com and log in
2. Click "New" → "Web Service"
3. Choose "Deploy an existing image from a registry"
4. Enter your Docker image: `your-dockerhub-username/laravel-jenkins-render-app:latest`
5. Configure the following settings:
   - **Name**: laravel-jenkins-render-app
   - **Region**: Choose your preferred region
   - **Plan**: Free or Starter
   - **Port**: 10000
   - **Health Check Path**: /

### Environment Variables (Required)
Set these in Render's dashboard under Environment Variables:
- `APP_ENV` = `production`
- `APP_DEBUG` = `false`
- `APP_KEY` = Generate a new key (use `php artisan key:generate` locally to get one)
- `APP_URL` = Your Render app URL (will be provided after deployment)
- `LOG_CHANNEL` = `stderr`
- `LOG_LEVEL` = `info`
- `SESSION_DRIVER` = `cookie`
- `CACHE_DRIVER` = `file`
- `QUEUE_CONNECTION` = `sync`

## Step 3: Database Setup (If needed)
If your Laravel app uses a database:
1. In Render, create a new PostgreSQL database
2. Add these environment variables in your web service:
   - `DB_CONNECTION` = `pgsql`
   - `DB_HOST` = (provided by Render)
   - `DB_PORT` = `5432`
   - `DB_DATABASE` = (provided by Render)
   - `DB_USERNAME` = (provided by Render)
   - `DB_PASSWORD` = (provided by Render)

## Step 4: Custom Domain (Optional)
1. In Render dashboard, go to your service settings
2. Click on "Custom Domains"
3. Add your domain and follow DNS configuration instructions

## Automated Deployment
With the render.yaml file, your app will automatically redeploy when you push changes to your connected Git repository.

## Troubleshooting
- Check Render logs in the dashboard if deployment fails
- Ensure all required environment variables are set
- Verify your Docker image is publicly accessible on Docker Hub
- Check that port 10000 is properly exposed in your Dockerfile

## Important Notes
- The app runs on port 10000 (Render's default)
- Logs are configured to output to stderr for Render's log system
- The startup script handles the Laravel server initialization
- Storage is mounted to persist uploaded files and logs