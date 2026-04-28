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
  "file_content": "def add(a, b):\\n    return a + b\\n\\nprint(add(2, 3))",
  "actual_label": "CLEAN"
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
stage('Build Security Check') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'aws-credentials',
            usernameVariable: 'AWS_ACCESS_KEY_ID',
            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
        )]) {
            sh '''
            export AWS_DEFAULT_REGION=us-east-1

            cat > build_payload.json << 'EOF'
{
  "sample_id": "jenkins_build_001",
  "file_name": "Dockerfile",
  "file_content": "FROM python:3.12-slim\\nWORKDIR /app\\nCOPY requirements.txt .\\nRUN pip install -r requirements.txt\\nCOPY . .\\nCMD [\\"python\\", \\"app.py\\"]",
  "actual_label": "CLEAN"
}
EOF

            aws lambda invoke \
              --function-name cicd-build-detector \
              --payload file://build_payload.json \
              --cli-binary-format raw-in-base64-out \
              build_output.json

            cat build_output.json

            if grep -q "BLOCK_PIPELINE" build_output.json; then
              echo "Attack detected in Build stage. Stopping pipeline."
              exit 1
            fi
            '''
        }
    }
}
        stage('Build') {
            steps {
                echo "Stage 3: Build"
                sh 'docker build -t cicd-security-lab .'
            }
        }
stage('Test Security Check') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'aws-credentials',
            usernameVariable: 'AWS_ACCESS_KEY_ID',
            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
        )]) {
            sh '''
export AWS_DEFAULT_REGION=us-east-1

cat > test_payload.json << 'EOF'
{
  "sample_id": "jenkins_test_001",
  "file_name": "test_app.py",
  "file_content": "def test_addition():\\n    assert 2 + 3 == 5\\n\\ndef test_subtraction():\\n    assert 5 - 2 == 3",
  "actual_label": "CLEAN"
}
EOF

aws lambda invoke \
  --function-name cicd-test-detector \
  --payload file://test_payload.json \
  --cli-binary-format raw-in-base64-out \
  test_output.json

cat test_output.json

if grep -q "BLOCK_PIPELINE" test_output.json; then
  echo "Attack detected in Test stage. Stopping pipeline."
  exit 1
fi
'''
        }
    }
}
        stage('Test') {
            steps {
                echo "Stage 4: Test"
                sh 'PYTHONPATH=. pytest tests/'
             }
       }
stage('Release Security Check') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'aws-credentials',
            usernameVariable: 'AWS_ACCESS_KEY_ID',
            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
        )]) {
            sh '''
export AWS_DEFAULT_REGION=us-east-1

cat > release_payload.json << 'EOF'
{
  "sample_id": "jenkins_release_001",
  "file_name": "release.yml",
  "file_content": "release_version = '1.0.2'\\nverify: true\\nsignature: true\\nchecksum: sha256",
  "actual_label": "CLEAN"
}
EOF

aws lambda invoke \
  --function-name cicd-release-detector \
  --payload file://release_payload.json \
  --cli-binary-format raw-in-base64-out \
  release_output.json

cat release_output.json

if grep -q "BLOCK_PIPELINE" release_output.json; then
  echo "Attack detected in Release stage. Stopping pipeline."
  exit 1
fi
'''
        }
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
