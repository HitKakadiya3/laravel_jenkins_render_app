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
                // For Render, usually push to GitHub triggers auto-deploy
                echo 'Push to GitHub triggers auto-deploy on Render'
            }
        }
    }
}
