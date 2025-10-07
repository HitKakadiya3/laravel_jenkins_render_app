pipeline {
    agent any

    environment {
        APP_DIR = "/var/www/laravel_render_app"
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
                    
                    // Push to GitHub triggers auto-deploy on Render
                    echo 'Deployment will be triggered automatically on Render via GitHub webhook'
                    echo 'Monitor deployment status at: https://dashboard.render.com'
                }
            }
        }
    }
}
