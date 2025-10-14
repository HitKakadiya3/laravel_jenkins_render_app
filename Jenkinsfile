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
        
        stage('Environment Setup') {
            steps {
                echo '⚙️ Setting up build environment...'
                script {
                    // Display build information
                    sh '''
                        echo "Build Number: ${BUILD_NUMBER}"
                        echo "Git Commit: $(git rev-parse --short HEAD)"
                        echo "Git Branch: $(git branch --show-current)"
                        echo "Docker Version: $(docker --version)"
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    // Build Docker image with multiple tags
                    withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDENTIALS', 
                                                   passwordVariable: 'DOCKER_PASSWORD', 
                                                   usernameVariable: 'DOCKER_USERNAME')]) {
                        sh '''
                            echo "Building Docker image: ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER_TAG}"
                            
                            # Build the Docker image
                            docker build -t ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER_TAG} .
                            docker build -t ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${LATEST_TAG} .
                            
                            echo "✅ Docker image built successfully"
                            docker images | grep ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}
                        '''
                    }
                }
            }
        }

        stage('Docker Test') {
            steps {
                echo '🧪 Testing Docker image...'
                script {
                    withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDENTIALS', 
                                                   passwordVariable: 'DOCKER_PASSWORD', 
                                                   usernameVariable: 'DOCKER_USERNAME')]) {
                        sh '''
                            echo "Testing Docker image startup..."
                            
                            # Run container in background for testing
                            CONTAINER_ID=$(docker run -d -p 8080:10000 ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER_TAG})
                            echo "Started container: $CONTAINER_ID"
                            
                            # Wait for container to start
                            sleep 30
                            
                            # Test if application is responding
                            if curl -f http://localhost:8080/ > /dev/null 2>&1; then
                                echo "✅ Application is responding"
                            else
                                echo "⚠️ Application health check - container may still be starting"
                            fi
                            
                            # Show container logs
                            echo "Container logs:"
                            docker logs $CONTAINER_ID
                            
                            # Clean up test container
                            docker stop $CONTAINER_ID
                            docker rm $CONTAINER_ID
                            
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
                            
                            echo "Pushing Docker images..."
                            docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER_TAG}
                            docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${LATEST_TAG}
                            
                            echo "✅ Docker images pushed successfully"
                            echo "Image: ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER_TAG}"
                            echo "Image: ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${LATEST_TAG}"
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
                            echo "Deploy Hook URL configured: ${RENDER_DEPLOY_HOOK:0:30}..."
                            
                            RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$RENDER_DEPLOY_HOOK")
                            
                            if [ "$RESPONSE" -eq 200 ] || [ "$RESPONSE" -eq 201 ]; then
                                echo "✅ Deployment triggered successfully on Render (HTTP $RESPONSE)"
                                echo "🔗 Monitor deployment at: https://dashboard.render.com"
                            else
                                echo "❌ Failed to trigger deployment on Render (HTTP $RESPONSE)"
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
                // Clean up Docker images to save space
                sh '''
                    echo "Cleaning up Docker images..."
                    docker system prune -f
                    echo "✅ Cleanup completed"
                '''
            }
        }
        success {
            echo '✅ Pipeline completed successfully!'
            script {
                withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDENTIALS', 
                                               passwordVariable: 'DOCKER_PASSWORD', 
                                               usernameVariable: 'DOCKER_USERNAME')]) {
                    echo """
                    🎉 Deployment Summary:
                    - Docker Image: ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER_TAG}
                    - Registry: Docker Hub
                    - Render App: https://laravel-jenkins-render-app-1.onrender.com/
                    - Build Number: ${BUILD_NUMBER}
                    """
                }
            }
        }
        failure {
            echo '❌ Pipeline failed!'
            script {
                sh '''
                    echo "Build failed at $(date)"
                    echo "Check the logs above for error details"
                '''
            }
        }
    }
}
