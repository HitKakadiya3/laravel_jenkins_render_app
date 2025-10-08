pipeline {
    agent any

    environment {
        APP_DIR = "/var/www/laravel_render_app"
        // Remove hardcoded URL - will use credentials instead
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/HitKakadiya3/laravel_jenkins_render_app.git'
            }
        }
        stage('Install Dependencies') {
            steps {
                sh 'composer install --no-interaction --prefer-dist'
            }
        }
        stage('Run Migrations') {
            steps {
                sh 'php artisan migrate --force'
            }
        }
        stage('Deploy to Render') {
            steps {
                script {
                    echo 'Preparing for deployment to Render...'
                    
                    // Set production environment variables
                    sh 'cp .env.example .env'
                    sh 'php artisan key:generate'
                    
                    // Clear and cache configuration for production
                    sh 'php artisan config:clear'
                    sh 'php artisan cache:clear'
                    sh 'php artisan route:cache'
                    sh 'php artisan view:cache'
                    
                    // Trigger deployment on Render using Deploy Hook
                    echo 'Triggering deployment on Render using Deploy Hook... '
                    sh '''
                        echo "Calling Render Deploy Hook..."
                        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "https://api.render.com/deploy/srv-d3ifkaali9vc73eq3gqg?key=P07BBjAmA_Y")
                        if [ "$RESPONSE" -eq 200 ] || [ "$RESPONSE" -eq 201 ]; then
                            echo "✅ Deployment triggered successfully on Render"
                        else
                            echo "❌ Failed to trigger deployment on Render (HTTP $RESPONSE)"
                            exit 1
                        fi
                    '''
                    echo 'Deployment initiated on Render'
                    echo 'Monitor deployment status at: https://dashboard.render.com'
                }
            }
        }
    }
}
