# 섹션 3. 레지스트리와 레포지토리
- [레지스트리와 레포지토리](#레지스트리와-레포지토리)
- [Private Registry 생성 및 활용](#private-registry-생성-및-활용)
- [기타](#기타)

----

## 레지스트리와 레포지토리

### 1. Docker 레지스트리와 레포지토리 

![Image](https://github.com/user-attachments/assets/e6c789b8-ac9d-4dad-84fa-e757a863d926)

#### Docker 레지스트리
- 도커 이미지를 저장하고 배포하는 서버 시스템
- 이미지의 태그와 계층을 관리하는 중앙 저장소
- 종류: Docker Hub(공식), GitHub Container Registry, Amazon ECR, Private Registry 등 

#### Docker 레포지토리
- 레지스트리 내에서 관련 이미지의 컬렉션을 담는 네임스페이스
- 동일한 애플리케잇연의 여러 버전 이미지를 포함
- 형식: [레지스트리 주소]/[사용자 또는 조직명]/[이미지명]:[태그]
    - 예: `docker.io/bitnami/mysql:8.0.33`

#### 관계
- 레지스트리는 여러 레포지토리를 포함
- 레포지토리는 여러 이미지 태그를 포함
- 비유: 레지스트리는 GitHub, 레포지토리는 프로젝트, 태그는 버전

---

## Private Registry 생성 및 활용

- 프라이빗 레지스트리는 Docker Hub와 완전히 독립된, 사용자가 직접 통제하는 이미지 저장소

![Image](https://github.com/user-attachments/assets/26c93790-40d9-41d3-8eb3-d80ff960996e)

![Image](https://github.com/user-attachments/assets/c8b6e4ca-a5c4-4b29-9b0e-42aef6a2c56b)

### 1. Private 레지스트리 서버 실행
```
docker run -d -p 1111:5000 --name registry-srv --env-file .env.dev registry
```
- 공식 registry 이미지로 Private 레지스트리 서버 실행
- 호스트의 1111 포트를 컨테이너의 5000 포트에 매핑
- 환경 설정은 `.env.dev` 파일에서 로드

### 2. 레지스트리 내 레포지토리 목록 확인
```
curl http://localhost:1111/v2/_catalog
```
- 레지스트리 API를 통해 현재 저장된 레포지토리 목록 조회

### 3. 레지스트리 UI 실행
```
docker run --rm -d -p 8080:80 --name registry-ui -e REGISTRY_URL=http://localhost:1111 -e SINGLE_REGISTRY=true joxit/docker-registry-ui
```
- 레지스트리 내용을 시각화하는 웹 UI 컨테이너 실행
- 8080 포트에서 웹 인터페이스 제공

### 4. 이미지 및 컨테이너 상태 확인
```
docker ps
docker images
```
![Image](https://github.com/user-attachments/assets/648ac567-59ad-46f8-be05-31f016ed0c03)

### 5. 이미지 태그 변경 및 푸시
```
docker tag registry localhost:1111/registry:v0.0.1
docker push localhost:1111/registry:v0.0.1
```
- 로컬 registry 이미지에 Private 레지스트리 주소 포함한 새 태그 부여
- 태그된 이미지를 Private 레지스트리에 푸시
![Image](https://github.com/user-attachments/assets/146c9e54-f233-4ef0-8a0e-e4ab9b8da810)

### 6. Private 레지스트리에서 이미지 가져오기
```
docker pull localhost:1111/registry:v0.0.1
```
- 이미 로컬에 존재하므로 실제 다운로드 없이 완료

### 7. 초기화 명령어 세트
- 모든 컨테이너, 볼륨, 네트워크 및 빌드 캐시 정리
- 시스템 정리 후 상태 확인
![Image](https://github.com/user-attachments/assets/938779f9-9873-4bd9-889d-8432bbcd842a)

---

## 기타

### 1. 태그 관련
- 태그를 명시하지 않으면 자동으로 `latest` 태그가 적용됨.
```
# 아래 두 명령어는 동일
docker pull nginx
docker pull nginx:latest
```

### 2. pull과 run의 차이
#### docker pull
- 명시적으로 이미지만 다운로드하는 명령어
- 이미지를 로컬에 가져오기만 하고 실행하지는 않음
- 예: `docker pull nginx`

#### docker run
- 컨테이너를 생성하고 실행하는 명령어
- 지정한 이미지가 로컬에 없으면 자동으로 pull작업을 먼저 수행
- 이미지 다운로드 후 컨테이너로 실행까지 진행
- 예: `docker run nginx`

