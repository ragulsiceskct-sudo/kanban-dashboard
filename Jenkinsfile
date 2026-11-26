pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    environment {
        DOCKER_IMAGE = "ragul08112003/kanban-dashboard"
        CONTAINER_NAME = "kanban-dashboard"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/ragulsiceskct-sudo/kanban-dashboard.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_TOKEN" | docker login \
                            -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh '''
                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh '''
                    echo "Saving previous version..."

                    OLD_IMAGE_ID=$(docker inspect \
                        --format='{{.Image}}' \
                        ${CONTAINER_NAME} 2>/dev/null || true)

                    echo "Previous image: ${OLD_IMAGE_ID}"

                    echo "Stopping old container..."
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    DEPLOY_SUCCESS=false

                    echo "Deploying new version..."

                    if docker run -d \
                        --name ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        -p 8081:8080 \
                        ${DOCKER_IMAGE}:${BUILD_NUMBER}; then

                        echo "Container started."
                    else
                        echo "Docker container startup failed!"
                    fi

                    echo "Checking deployment health..."

                    for i in $(seq 1 10); do
                        if curl -fsS http://localhost:8081 > /dev/null; then
                            echo "Deployment successful!"
                            DEPLOY_SUCCESS=true
                            break
                        fi

                        echo "Health check attempt ${i} failed..."
                        sleep 3
                    done

                    if [ "$DEPLOY_SUCCESS" = "true" ]; then
                        echo "New version is running successfully."
                    else
                        echo "NEW DEPLOYMENT FAILED!"

                        echo "Removing failed container..."
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true

                        if [ -n "$OLD_IMAGE_ID" ]; then
                            echo "Rolling back to previous version..."

                            if docker run -d \
                                --name ${CONTAINER_NAME} \
                                --restart unless-stopped \
                                -p 8081:8080 \
                                "$OLD_IMAGE_ID"; then

                                echo "Previous container started."

                                for i in $(seq 1 10); do
                                    if curl -fsS http://localhost:8081 > /dev/null; then
                                        echo "Rollback successful!"
                                        break
                                    fi

                                    echo "Rollback health check ${i} failed..."
                                    sleep 3
                                done

                                if ! curl -fsS http://localhost:8081 > /dev/null; then
                                    echo "Rollback failed! Manual intervention required."
                                fi
                            else
                                echo "Rollback container could not start!"
                            fi
                        else
                            echo "No previous version available to restore."
                        fi

                        exit 1
                    fi
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    sleep 5

                    echo "Checking application..."

                    curl -f http://localhost:8081

                    echo "Checking Docker container..."

                    docker ps
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD Pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check the console output.'
        }
    }
}