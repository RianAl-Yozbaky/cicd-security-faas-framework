pipeline {
    agent any

    stages {
        stage('Plan') {
            steps {
                echo "Plan stage"
            }
        }

        stage('Code') {
            steps {
                echo "Code stage"
                sh 'echo Running code stage'
            }
        }

        stage('Test') {
            steps {
                echo "Test stage"
            }
        }
    }
}
