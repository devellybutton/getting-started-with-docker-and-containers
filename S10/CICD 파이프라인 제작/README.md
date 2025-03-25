# EC2, ECR, GitHub Actions를 활용한 Docker 컨테이너 CI/CD 배포 가이드
- [사전 준비](#사전-준비)
- [1. EC2 인스턴스에 IAM 역할 부여](#1-ec2-인스턴스에-iam-역할-부여)
- [2. EC2 인스턴스에 IAM 역할 연결](#2-ec2-인스턴스에-iam-역할-연결)
- [3. GitHub 저장소에 Secrets 설정](#3-github-저장소에-secrets-설정)
- [4.Docker Compose 파일 작성](#4-docker-compose-파일-작성)
- [5. GitHub Actions 워크플로우 파일 작성](#5-github-actions-워크플로우-파일-작성)
- [6. EC2 인스턴스 설정](#6-ec2-인스턴스-설정)
- [7. CI/CD 파이프라인 실행](#7-cicd-파이프라인-실행)

-------

## 사전 준비

1. AWS 계정
2. GitHub 계정 및 리포지토리
3. Docker가 설치된 EC2 인스턴스
4. Amazon ECR 리포지토리

## 1. EC2 인스턴스에 IAM 역할 부여

EC2 인스턴스가 ECR에서 이미지를 가져올 수 있도록 IAM 역할을 설정

1. AWS 콘솔에서 IAM 서비스로 이동
2. `역할 > 새 역할 생성`을 클릭
3. 신뢰할 수 있는 엔티티 유형으로 `AWS 서비스`를 선택
4. 사용 사례에서 `EC2` 선택
5. 권한 추가 단계에서 `AmazonEC2ContainerRegistryReadOnly` 정책 선택
6. 역할 이름을 지정하고 역할 생성 완료

## 2. EC2 인스턴스에 IAM 역할 연결

1. EC2 콘솔로 이동
2. 대상 인스턴스를 선택하고 `작업(Actions) > 보안(Security) > IAM 역할 수정(Modify IAM Role)`을 클릭
3. 앞서 생성한 IAM 역할을 선택하고 저장

## 3. GitHub 저장소에 Secrets 설정

GitHub Actions에서 AWS 서비스에 접근하기 위한 비밀 값을 설정

1. GitHub 리포지토리에서 `Settings > Secrets and variables > Actions`로 이동
2. 다음 비밀 값(secrets)을 추가:
   - `AWS_ACCESS_KEY_ID`: AWS IAM 사용자의 액세스 키 ID
   - `AWS_SECRET_ACCESS_KEY`: AWS IAM 사용자의 비밀 액세스 키
   - `ECR_REPO_URL`: ECR 저장소 URL (예: `012120701866.dkr.ecr.ap-northeast-2.amazonaws.com/my-repo`)
   - `HOST`: EC2 인스턴스의 퍼블릭 IP 또는 도메인
   - `USERNAME`: EC2 인스턴스 SSH 접속 사용자명 (예: `ec2-user`)
   - `SSH_PEM_KEY`: EC2 인스턴스 접속용 SSH 개인 키 (PEM 파일 내용)

## 4. Docker Compose 파일 작성

프로젝트 루트에 `compose.yaml` 파일을 생성

```yaml
services:
  app:
    build: .
    image: ${ECR_REPO_URL}:${IMAGE_TAG}
    ports:
      - "80:3000"
    restart: always
```

## 5. GitHub Actions 워크플로우 파일 작성

프로젝트의 `.github/workflows/` 디렉토리에 `cicd.yml` 파일을 생성

```yaml
name: Docker CI/CD Pipeline

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

env:
  ECR_REPO_URL: ${{ secrets.ECR_REPO_URL }}
  IMAGE_TAG: ${{ github.sha }}

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-northeast-2

      - name: Login to Amazon ECR
        id: login-ecr
        run: aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ${{ secrets.ECR_REPO_URL }}

      - name: Build and push Docker image
        run: |
          docker compose build
          IMAGE_NAME=$(echo $ECR_REPO_URL | cut -d'/' -f2)
          docker tag ${IMAGE_NAME}:latest ${ECR_REPO_URL}:${IMAGE_TAG}
          docker push ${ECR_REPO_URL}:${IMAGE_TAG}

      - name: Copy deployment files to server
        uses: appleboy/scp-action@v0.1.7
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.SSH_PEM_KEY }}
          source: "compose.yaml"
          target: "$HOME/deployment"

      - name: Deploy to EC2
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.SSH_PEM_KEY }}
          envs: ECR_REPO_URL,IMAGE_TAG
          script: |
            cd $HOME/deployment
            aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin $ECR_REPO_URL
            export ECR_REPO_URL=$ECR_REPO_URL
            export IMAGE_TAG=$IMAGE_TAG
            docker compose pull
            docker compose up -d
```

## 6. EC2 인스턴스 설정

EC2 인스턴스에 SSH로 접속하여 필요한 설정을 완료

```bash
# AWS CLI 설정
aws configure
# 리전, 키는 입력하고 기본 출력 형식은 엔터(json)

# 설정 확인
aws sts get-caller-identity

# ECR 로그인 테스트
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 012120701866.dkr.ecr.ap-northeast-2.amazonaws.com

# 이전 배포 파일 정리 (필요시)
cd $HOME/deployment
rm -rf *
```

## 7. CI/CD 파이프라인 실행

1. 코드를 GitHub 리포지토리의 main 브랜치에 푸시
2. GitHub Actions 탭에서 워크플로우 실행 과정 모니터링
3. 완료 후 EC2 인스턴스에서 애플리케이션 실행 확인

```bash
# 컨테이너 상태 확인
docker ps

# 로그 확인
docker logs <container_id>
```

## 문제 해결

- **이미지가 ECR에 없는 경우**: Docker Compose 파일에서 image 속성에 ECR 저장소 URL이 올바르게 지정되었는지 확인
- **EC2 배포 실패**: EC2 인스턴스에 IAM 역할이 제대로 설정되었는지, AWS CLI 설정이 올바른지 확인
- **권한 오류**: GitHub Secrets에 설정된 AWS 자격 증명에 ECR 푸시 권한이 있는지 확인
