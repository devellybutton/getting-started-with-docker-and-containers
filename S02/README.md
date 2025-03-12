### 1. [nginx](#nginx)
### 2. [PostgreSQL](#postgresql)
### 3. [httpd](#httpd)
### 4. [node](#node)

---

# nginx

![Image](https://github.com/user-attachments/assets/cad77b24-4f1c-4696-8c03-04e746a9335d)

### 실제 작동 과정

1. 웹 브라우저나 curl 같은 클라이언트가 `http://localhost:8080`으로 접속
2. 호스트 컴퓨터의 8080 포트로 들어온 요청을 Docker가 가로채서 컨테이너 내부의 80 포트로 전달함.
3. 컨테이너 안에서 실행 중인 nginx 웹 서버가 80 포트에서 요청을 받아 처리함.

### 명령어 정리

```
docker run --rm -d -p 8080:80 nginx
```

- `docker run`: 새 컨테이너를 생성하고 실행
- `--rm`: 컨테이너가 종료될 때 자동으로 컨테이너를 삭제
- `-d`: 백그라운드에서 컨테이너 실행 (detached 모드)
- `-p 8080:80`: 호스트의 8080 포트를 컨테이너의 80 포트에 연결
  - 왼쪽 숫자 `8080`: 호스트 컴퓨터에서 사용할 포트 번호
  - 오른쪽 숫자 `80`: 컨테이너 내부에서 사용하는 포트 번호
- `nginx`: 사용할 도커 이미지 이름

```
curl http://localhost:8080
```

- 로컬호스트의 8080 포트에 HTTP 요청을 보내 응답을 확인

```
docker ps
```

- 현재 실행 중인 컨테이너 목록 표시

```
docker rm -f [CONTAINER_ID 또는 CONTAINER_NAME]
```

- 컨테이너를 강제로 삭제
- `-f`: 실행 중인 컨테이너도 강제로 중지하고 삭제

### 컨테이너 ID/이름 관련 팁

- 부분 ID 사용 : 컨테이너 ID의 처음 몇 글자만 사용해도 충분함 (충돌이 없을 경우)

  ```
  # 전체 ID가 abc123def456...인 경우
  docker rm -f abc12
  ```

- 탭 키로 자동완성

  ```
  # nginx로 시작하는 컨테이너 이름 자동완성
  docker rm -f ngi[TAB]
  ```

- 컨테이너 생성 시 --name 옵션으로 기억하기 쉬운 이름을 지정

  ```
  docker run --rm -d -p 8080:80 --name webserver nginx
  docker rm -f webserver
  ```

- 여러 컨테이너 한번에 삭제: 공백으로 구분하여 여러 컨테이너 ID/이름을 지정

  ```
  docker rm -f container1 container2 container3
  ```

- 명령어 조합: docker ps 결과를 파이프라인으로 연결해 자동 처리
  ```
  # nginx 이름을 포함한 모든 컨테이너 삭제
  docker rm -f $(docker ps -q -f name=nginx)
  ```

![Image](https://github.com/user-attachments/assets/713270ff-4cad-42a2-8f6e-7850781c99ae)

### 실제 작동 과정

- Docker의 주요 장점 중 하나가 바로 이 격리성
- 컨테이너 1의 NGINX 서버와 컨테이너 2의 NGINX 서버는 서로 완전히 독립적임.
  - 각 컨테이너 내부에서는 표준 포트(80)를 그대로 사용할 수 있음.
  - 외부에서는 호스트의 다른 포트(8080, 8081)를 통해 각각의 컨테이너에 접근함.
- 그래서 `docker run --rm -d -p 8080:80 nginx`와 `docker run --rm -d -p 8081:80 nginx`를 실행하면 두 개의 서로 다른 NGINX 컨테이너가 생성되고, 둘 다 각자의 80번 포트에서 웹 서버를 실행하지만 서로에게 영향을 주지 않음.

---

# PostgreSQL

![Image](https://github.com/user-attachments/assets/b2ac6300-51e2-4c35-8928-4ee1a3cedb3c)

![Image](https://github.com/user-attachments/assets/d5f89282-bd9a-48aa-b1d2-8454d4eb8e96)

### 도커 볼륨

- 도커 볼륨 : 호스트 시스템에 물리적으로 저장되는 실제 데이터 저장소
  - 컨테이너가 삭제되어도 데이터는 호스트 시스템에 안전하게 보존됨.
  - 컨테이너는 가상화된 환경이지만, 볼륨 데이터는 실제 호스트의 물리적 저장소에 저장됨.
- 일반적인 호스트 파일 시스템의 경로와는 조금 다르게 관리됨.

### 도커 볼륨이 실제로 저장되는 위치

- <b>linux</b> : `/var/lib/docker/volumes/` 디렉토리 아래에 저장됨.
- <b>Mac/Windows(Docker Desktop)</b> : Docker Desktop이 사용하는 가상 머신 내부에 저장됨.
  - Mac : HyperKit
  - Windows : WSL2(Windows Subsystem for Linux) 또는 Hyper-V

### 컨테이너 vs 도커

- 컨테이너 : 일회용 작업 공간
- 볼륨 : 작업 결과물을 보관하는 창고

### 결론

- Docker Desktop을 설치하면 내 컴퓨터의 디스크 공간의 일부가 이 가상 머신의 파일 시스템으로 할당되고, 그 안에 도커 볼륨 데이터가 실제로 저장됨.
- 그래서 컨테이너가 삭제되어도 볼륨 데이터는 이 가상머신 안에 계속 물리적으로 보존됨.

---

# httpd

![Image](https://github.com/user-attachments/assets/76bfe2bb-8e72-4c2f-a762-7f9e5ba4d0b1)

### 왜 Dockerfile이 없는가?
- Dockerfile을 직접 작성하지 않고 Docker Hub에서 제공하는 공식 httpd:2.4 이미지를 바로 사용하고 있음.

#### 1. 직접 이미지 빌드 vs 기존 이미지 사용:
- Node.js 예제: Dockerfile을 작성하고 docker build로 커스텀 이미지 생성
- 이번 Apache 예제: 이미 만들어진 공식 이미지를 가져와서(docker pull 과정이 내부적으로 실행됨) 바로 사용

#### 2. 사용 사례:
- 커스텀 애플리케이션(Node.js 서버 등)을 컨테이너화할 때는 Dockerfile 필요
- 표준 서비스(웹 서버, 데이터베이스 등)만 필요할 때는 공식 이미지를 그대로 사용 가능

![Image](https://github.com/user-attachments/assets/65236e94-babd-4fb1-a261-389a951863be)

![Image](https://github.com/user-attachments/assets/58644a06-7cc5-415e-9047-1dbcb70af8b3)

### 왜 읽기 전용(ro)으로 설정했는가?
- `-v .:/usr/local/apache2/htdocs/:ro `옵션에서 `:ro(read-only)`를 사용
#### 1. 보안:
- 컨테이너가 내부에서 마운트된 파일을 수정할 수 없게 함
- 악의적인 공격이나 오작동으로부터 호스트 파일을 보호
#### 2. 의도 명확화:
- 이 설정은 "호스트에서 개발하고, 컨테이너에서 실행"하는 워크플로우를 강제
- 개발자는 호스트에서만 파일을 수정하고, 컨테이너는 단순히 그 파일을 서빙하는 역할
#### 3. 예측 가능성:
- 컨테이너 내부에서 발생할 수 있는 예상치 못한 파일 변경을 방지
- 호스트 파일과 컨테이너 내 파일의 싱크가 깨지는 상황 방지

---

# node
- 로컬 소스 코드를 기반으로 이미지를 빌드하고, 그 이미지로 컨테이너를 생성해 웹 서버를 실행하며, 포트 매핑을 통해 외부에서 접근 가능하게 함.
![Image](https://github.com/user-attachments/assets/b3228204-84bd-4e88-8857-75021398acf6)

### 파일 구조 및 역할
- `Dockerfile`: 도커 이미지를 빌드하기 위한 지침서
- `package.json`: Node.js 애플리케이션의 메타데이터와 의존성 관리
- `server.js`: 실제 웹 서버 애플리케이션 코드
- `node.sh`: 쉘 스크립트 (보통 로컬 개발 환경 설정이나 유틸리티용)

### 실행 순서 (Docker 관점)
#### 1. 빌드 단계 (`docker build -t web .`):
- Dockerfile을 읽고 빌드 컨텍스트(현재 디렉토리)에서 이미지 생성
- 기본 이미지(node:21) 다운로드 → 작업 디렉토리 설정 → package.json 복사 → npm install 실행 → server.js 복사

#### 2. 실행 단계 (`docker run -d --rm -p 8080:5000 --name web web`):
- 컨테이너 생성 및 실행
- 호스트의 8080 포트를 컨테이너의 5000 포트로 매핑
- `CMD ["npm","start"]` 실행 (package.json에 정의된 start 스크립트 실행)
- 이 스크립트는 보통 `node server.js`를 실행

#### 3. 웹 서버 접근:
- 브라우저에서 `localhost:8080` 접속
- 요청이 컨테이너 내부의 5000 포트로 전달됨
server.js에서 구현된 웹 애플리케이션이 응답

![Image](https://github.com/user-attachments/assets/6e1aa318-60ca-493c-9306-87735999a355)

### 메모리 제한하여 도커 실행
- 컨테이너의 메모리를 10MB로 제한
- Node.js 기반 애플리케이션은 일반적으로 최소 수십 MB 이상의 메모리를 필요 (최소 100~256MB 이상)
```
docker run -p 8080:5000 --memory="10m" --name web web
```

#### 실행과정
1. 시작 시도
2. 메모리 부족으로 인한 오류 발생
3. 컨테이너 종료 (crash)

#### docker ps에는 보이지 않음
```
docker ps
```
![Image](https://github.com/user-attachments/assets/4dbf4d5d-853d-42ed-acf4-f0a4fdac9303)

#### docker ps -a에서만 보임
- 종료된 컨테이너도 보이기 때문임
```
docker ps -a
```
![Image](https://github.com/user-attachments/assets/e377e49b-7ad8-423b-a276-b94310f19c51)

#### 컨테이너 상세 정보 확인
- state 부분에 종료 이유와 코드를 확인 가능
```
docker inspect web
```
![Image](https://github.com/user-attachments/assets/98e15803-480f-4349-9e3a-3fa11c8379bb)