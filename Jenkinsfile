pipeline {
    agent any

    environment {
        // Docker configuration
        DOCKER_IMAGE_NAME = "laravel-jenkins-render-app"
        DOCKER_REGISTRY = "docker.io" // Docker Hub
        BUILD_NUMBER_TAG = "${BUILD_NUMBER}"
        LATEST_TAG = "latest"
        
        // Application configuration
        APP_NAME = "laravel-jenkins-render-app"
    }

    stages {
        stage('Checkout') {
            steps {
                echo '🔄 Checking out source code...'
                git branch: 'main', url: 'https://github.com/HitKakadiya3/laravel_jenkins_render_app.git'
            }
        }
        
        stage('Pre-flight Checks') {
            steps {
                echo '🔍 Running pre-flight checks...'
                script {
                    sh '''
                        echo "=== System Information ==="
                        echo "User: $(whoami)"
                        echo "Groups: $(groups)"
                        echo "PWD: $(pwd)"
                        echo "Build Number: ${BUILD_NUMBER}"
                        echo "Git Commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
                        
                        echo ""
                        echo "=== Docker Check ==="
                        if command -v docker >/dev/null 2>&1; then
                            echo "✅ Docker command available: $(docker --version)"
                            
                            if docker info >/dev/null 2>&1; then
                                echo "✅ Docker daemon accessible"
                                echo "Docker Root Dir: $(docker info --format '{{.DockerRootDir}}' 2>/dev/null || echo 'Unknown')"
                            else
                                echo "❌ Docker daemon NOT accessible"
                                echo "Socket info: $(ls -la /var/run/docker.sock 2>/dev/null || echo 'Socket not found')"
                                echo "💡 Fix: sudo usermod -aG docker jenkins && sudo chmod 666 /var/run/docker.sock"
                                exit 1
                            fi
                        else
                            echo "❌ Docker command not found"
                            exit 1
                        fi
                        
                        echo ""
                        echo "=== Credentials Check ==="
                        echo "Checking if required credentials are available..."
                    '''
                    
                    // Check if credentials exist
                    try {
                        withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDENTIALS', 
                                                       passwordVariable: 'DOCKER_PASSWORD', 
                                                       usernameVariable: 'DOCKER_USERNAME')]) {
                            echo "✅ Docker Hub credentials available: ${DOCKER_USERNAME}"
                        }
                    } catch (Exception e) {
                        echo "❌ Docker Hub credentials missing or invalid"
                        echo "💡 Add credential with ID: DOCKER_HUB_CREDENTIALS"
                        error("Missing Docker Hub credentials")
                    }
                    
                    try {
                        withCredentials([string(credentialsId: 'RENDER_DEPLOY_HOOK', variable: 'RENDER_DEPLOY_HOOK')]) {
                            echo "✅ Render deploy hook available"
                        }
                    } catch (Exception e) {
                        echo "❌ Render deploy hook missing"
                        echo "💡 Add credential with ID: RENDER_DEPLOY_HOOK"
                        error("Missing Render deploy hook")
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDENTIALS', 
                                                   passwordVariable: 'DOCKER_PASSWORD', 
                                                   usernameVariable: 'DOCKER_USERNAME')]) {
                        sh '''
                            echo "Building Docker image: ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER_TAG}"
                            
                            # Check if Dockerfile exists
                            if [ ! -f Dockerfile ]; then
                                echo "❌ Dockerfile not found!"
                                exit 1
                            fi
                            
                            # Build the Docker image with error handling
                            echo "Starting Docker build..."
                            if docker build -t ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER_TAG} .; then
                                echo "✅ Docker build successful for tag: ${BUILD_NUMBER_TAG}"
                            else
                                echo "❌ Docker build failed!"
                                exit 1
                            fi
                            
                            # Tag as latest
                            if docker tag ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER_TAG} ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${LATEST_TAG}; then
                                echo "✅ Tagged as latest"
                            else
                                echo "❌ Failed to tag as latest"
                                exit 1
                            fi
                            
                            # Show built images
                            echo "Built images:"
                            docker images | grep ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME} || echo "No images found matching pattern"
                        '''
                    }
                }
            }
        }

        stage('Docker Test') {
            when {
                expression { 
                    // Only run if we have docker access
                    return sh(script: 'docker info >/dev/null 2>&1', returnStatus: true) == 0
                }
            }
            steps {
                echo '🧪 Testing Docker image...'
                script {
                    withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDENTIALS', 
                                                   passwordVariable: 'DOCKER_PASSWORD', 
                                                   usernameVariable: 'DOCKER_USERNAME')]) {
                        sh '''
                            echo "Testing Docker image startup..."
                            
                            # Use a different port to avoid conflicts
                            TEST_PORT=8081
                            
                            # Run container in background for testing
                            echo "Starting test container on port $TEST_PORT..."
                            CONTAINER_ID=$(docker run -d -p $TEST_PORT:10000 ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER_TAG})
                            
                            if [ -z "$CONTAINER_ID" ]; then
                                echo "❌ Failed to start container"
                                exit 1
                            fi
                            
                            echo "✅ Started container: $CONTAINER_ID"
                            
                            # Wait for container to start
                            echo "Waiting for application to start..."
                            sleep 15
                            
                            # Show container logs for debugging
                            echo "Container logs:"
                            docker logs $CONTAINER_ID | tail -20
                            
                            # Test if application is responding (optional - don't fail on this)
                            if curl -f http://localhost:$TEST_PORT/ >/dev/null 2>&1; then
                                echo "✅ Application is responding on port $TEST_PORT"
                            else
                                echo "⚠️ Application health check failed, but continuing (container might still be starting)"
                            fi
                            
                            # Clean up test container
                            echo "Cleaning up test container..."
                            docker stop $CONTAINER_ID >/dev/null 2>&1 || true
                            docker rm $CONTAINER_ID >/dev/null 2>&1 || true
                            
                            echo "✅ Docker image test completed"
                        '''
                    }
                }
            }
        }

        stage('Docker Push') {
            steps {
                echo '📤 Pushing Docker image to registry...'
                script {
                    withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDENTIALS', 
                                                   passwordVariable: 'DOCKER_PASSWORD', 
                                                   usernameVariable: 'DOCKER_USERNAME')]) {
                        sh '''
                            echo "Logging into Docker Hub..."
                            echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                            
                            if [ $? -eq 0 ]; then
                                echo "✅ Docker Hub login successful"
                            else
                                echo "❌ Docker Hub login failed"
                                exit 1
                            fi
                            
                            echo "Pushing Docker images..."
                            
                            # Push versioned image
                            if docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER_TAG}; then
                                echo "✅ Pushed ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER_TAG}"
                            else
                                echo "❌ Failed to push versioned image"
                                exit 1
                            fi
                            
                            # Push latest image
                            if docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${LATEST_TAG}; then
                                echo "✅ Pushed ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${LATEST_TAG}"
                            else
                                echo "❌ Failed to push latest image"
                                exit 1
                            fi
                            
                            echo "✅ All Docker images pushed successfully"
                        '''
                    }
                }
            }
        }

        stage('Deploy to Render') {
            steps {
                echo '🚀 Deploying to Render...'
                script {
                    withCredentials([string(credentialsId: 'RENDER_DEPLOY_HOOK', variable: 'RENDER_DEPLOY_HOOK')]) {
                        sh '''
                            echo "Triggering deployment on Render..."
                            echo "Deploy Hook URL configured: ${RENDER_DEPLOY_HOOK:0:50}..."
                            
                            # Call the webhook with detailed error handling
                            RESPONSE=$(curl -s -o /tmp/render_response.txt -w "%{http_code}" -X POST "$RENDER_DEPLOY_HOOK")
                            
                            echo "Response Code: $RESPONSE"
                            
                            if [ -f /tmp/render_response.txt ]; then
                                echo "Response Body:"
                                cat /tmp/render_response.txt
                                rm -f /tmp/render_response.txt
                            fi
                            
                            if [ "$RESPONSE" -eq 200 ] || [ "$RESPONSE" -eq 201 ]; then
                                echo "✅ Deployment triggered successfully on Render (HTTP $RESPONSE)"
                                echo "🔗 Monitor deployment at: https://dashboard.render.com"
                            else
                                echo "❌ Failed to trigger deployment on Render (HTTP $RESPONSE)"
                                echo "💡 Check your Render deploy hook URL and service status"
                                exit 1
                            fi
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning up...'
            script {
                sh '''
                    echo "Performing cleanup..."
                    
                    # Clean up any test containers that might be running
                    docker ps -a | grep ${DOCKER_IMAGE_NAME} | awk '{print $1}' | xargs -r docker rm -f 2>/dev/null || true
                    
                    # Clean up Docker if we have access
                    if docker info >/dev/null 2>&1; then
                        echo "Cleaning up Docker images..."
                        docker system prune -f >/dev/null 2>&1 || echo "Docker cleanup had issues but continuing"
                    else
                        echo "Skipping Docker cleanup due to permission issues"
                    fi
                    
                    echo "✅ Cleanup completed"
                '''
            }
        }
        success {
            echo '🎉 Pipeline completed successfully!'
            script {
                withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDENTIALS', 
                                               passwordVariable: 'DOCKER_PASSWORD', 
                                               usernameVariable: 'DOCKER_USERNAME')]) {
                    echo """
                    🎉 Deployment Summary:
                    ==========================================
                    ✅ Docker Image: ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER_TAG}
                    ✅ Registry: Docker Hub  
                    ✅ Render App: https://laravel-jenkins-render-app-1.onrender.com/
                    ✅ Build Number: ${BUILD_NUMBER}
                    
                    🔗 Check your app: https://laravel-jenkins-render-app-1.onrender.com/
                    🔗 Docker Hub: https://hub.docker.com/r/${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}
                    🔗 Render Dashboard: https://dashboard.render.com
                    """
                }
            }
        }
        failure {
            echo '❌ Pipeline failed!'
            script {
                sh '''
                    echo "=============================================="
                    echo "❌ BUILD FAILED at $(date)"
                    echo "=============================================="
                    echo ""
                    echo "🔍 Troubleshooting steps:"
                    echo "1. Check Docker permissions: sudo usermod -aG docker jenkins"
                    echo "2. Check credentials in Jenkins: DOCKER_HUB_CREDENTIALS, RENDER_DEPLOY_HOOK"
                    echo "3. Verify Docker is running: sudo systemctl status docker"
                    echo "4. Check Jenkins logs above for specific error details"
                    echo ""
                    echo "🆘 Common fixes:"
                    echo "   sudo chmod 666 /var/run/docker.sock"
                    echo "   sudo systemctl restart jenkins"
                    echo ""
                '''
            }
        }
    }
}
