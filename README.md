# React + TypeScript + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Oxc](https://oxc.rs)
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/)

## React Compiler

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type-aware lint rules:

```js
export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...

      // Remove tseslint.configs.recommended and replace with this
      tseslint.configs.recommendedTypeChecked,
      // Alternatively, use this for stricter rules
      tseslint.configs.strictTypeChecked,
      // Optionally, add this for stylistic rules
      tseslint.configs.stylisticTypeChecked,

      // Other configs...
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```

You can also install [eslint-plugin-react-x](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-x) and [eslint-plugin-react-dom](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-dom) for React-specific lint rules:

```js
// eslint.config.js
import reactX from 'eslint-plugin-react-x'
import reactDom from 'eslint-plugin-react-dom'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...
      // Enable lint rules for React
      reactX.configs['recommended-typescript'],
      // Enable lint rules for React DOM
      reactDom.configs.recommended,
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```
## CI/CD Automation

This project uses Jenkins for automated Docker build, push, and deployment to AWS EC2.

## CI/CD Automation

This project uses Jenkins to automate deployment.

GitHub → Jenkins → Docker Build → Docker Hub → AWS EC2 → Deployment Verification

## Project Overview

This project implements an automated CI/CD pipeline to build, publish, and deploy a React-based Kanban Dashboard application using Jenkins, Docker, Docker Hub, and AWS EC2.

The pipeline automates the deployment process whenever changes are pushed to the GitHub repository.

## Architecture

```text
Developer
   |
   | Git Push
   v
GitHub Repository
   |
   | SCM Polling
   v
Jenkins CI/CD Pipeline
   |
   |-- Checkout Source Code
   |-- Build Docker Image
   |-- Authenticate with Docker Hub
   |-- Push Versioned Image
   |-- Deploy to AWS EC2
   |-- Health Check
   |-- Verify Deployment
   |
   v
Docker Hub
   |
   v
AWS EC2 Instance
   |
   v
Docker Container
   |
   v
Kanban Dashboard Application
```

## Technologies Used

- Git and GitHub – Source code management
- Jenkins – CI/CD automation
- Docker – Containerization
- Docker Hub – Container image registry
- AWS EC2 – Application hosting
- Linux – Server operating system
- Nginx – Web server
- React and Vite – Frontend application

## CI/CD Pipeline Stages

1. **Checkout Code:** Jenkins retrieves the latest source code and Jenkinsfile from GitHub.
2. **Build Docker Image:** Builds the application using a multi-stage Dockerfile.
3. **Docker Hub Login:** Authenticates using Jenkins credentials.
4. **Push Image:** Publishes versioned Docker images and the latest tag.
5. **Deploy to EC2:** Replaces the existing container with the newly built image.
6. **Health Check:** Checks application availability using HTTP requests.
7. **Verify Deployment:** Confirms application response and running container status.

## Automated Trigger

Jenkins SCM polling is configured to periodically check the GitHub repository for changes.

When a new commit is detected, Jenkins automatically starts the CI/CD pipeline without requiring a manual build.

## Deployment Details

- Cloud Provider: AWS
- Compute Service: EC2
- Container Runtime: Docker
- Application Port: 8081
- Container Port: 8080
- Deployment Strategy: Docker container replacement with rollback support

## Rollback Mechanism

The pipeline captures the previously running Docker image before deployment.

If the newly deployed version fails the health check:

- The failed container is removed.
- The previous image is restored.
- The previous application version is started.
- A rollback health check is performed.

## Application URL

http://15.206.186.169:8081

## Key Learnings

- Implemented an end-to-end CI/CD pipeline.
- Created a multi-stage Docker build.
- Integrated GitHub with Jenkins.
- Configured Jenkins credentials securely.
- Published Docker images to Docker Hub.
- Deployed a containerized application on AWS EC2.
- Automated deployment through SCM polling.
- Implemented deployment health checks and rollback logic.
- Practiced troubleshooting Linux, Docker, Jenkins, Git, and AWS.


