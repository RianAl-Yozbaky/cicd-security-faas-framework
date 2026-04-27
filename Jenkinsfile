pipeline {
    agent any

    stages {
        stage('Plan') {
            steps {
                echo "Stage 1: Plan"
                echo "Checking pipeline plan..."
            }
        }

        stage('Code') {
            steps {
                echo "Stage 2: Code"
                sh 'python3 -m py_compile app/app.py || python -m py_compile app/app.py'
            }
        }

        stage('Build') {
            steps {
                echo "Stage 3: Build"
                sh 'docker build -t cicd-security-lab .'
            }
        }

        stage('Test') {
            steps {
                echo "Stage 4: Test"
                sh 'pytest tests/'
            }
        }

        stage('Release') {
            steps {
                echo "Stage 5: Release"
                sh 'mkdir -p release'
                sh 'docker save cicd-security-lab -o release/cicd-security-lab.tar'
            }
        }

        stage('Deploy') {
            steps {
                echo "Stage 6: Deploy"
                sh 'docker run --rm cicd-security-lab'
            }
        }

        stage('Operate-Monitor') {
            steps {
                echo "Stage 7: Operate/Monitor"
                sh 'mkdir -p logs'
                sh 'echo "Application started successfully" > logs/app.log'
                sh 'cat logs/app.log'
            }
        }
    }
}
