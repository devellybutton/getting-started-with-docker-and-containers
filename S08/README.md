# 섹션 8. [프로젝트] 실무 요구사항 해결하기 

![Image](https://github.com/user-attachments/assets/96dd36e6-7053-4f9d-b134-1bbdb427b584)

## 프로젝트 폴더 분석

- <b>was 폴더</b> - 개발용 3-tier 아키텍처
- <b>결과물 폴더</b> - 배포용 3-tier 아키텍처
    - 프레젠테이션 계층: NGINX (웹 서버/로드 밸런서)
    - 애플리케이션 계층: WAS (여러 인스턴스로 확장 가능)
    - 데이터 계층: MySQL (데이터베이스)

## 진행 순서

### 1. 커스텀 네트워크 생성
- `global.sh`에서 `docker network create service` 입력

### 2. 볼륨 생성 및 MySQL 컨테이너 실행
- mysql/mysql.sh에서 service라는 이름의 Docker 네트워크에 컨테이너를 연결
- 네트워크 내에서 이 컨테이너를 mysql이라는 별칭으로 참조하도록 함
- 호스트의 Docker 볼륨인 `mysql-volume`을 컨테이너의 `/var/lib/mysql` 디렉터리에 마운트

### 3. WAS
- 이미지 빌드
- 컨테이너 실행 (was1)
<details>
<summary><i>진행 과정</i></summary>

#### 이미지 빌드
- 현재 폴더의 Dockerfile을 was라는 이름으로 빌드
![Image](https://github.com/user-attachments/assets/dba49650-134f-45d0-aa87-713f88b41b95)

#### 컨테이너 띄우기
- was1, was2 컨테이너를 순차적으로 띄운다
![Image](https://github.com/user-attachments/assets/f418c3d5-ee26-471d-9382-a20183adff49)

![Image](https://github.com/user-attachments/assets/7a359406-a2d0-4c6b-a144-fb1dbc99a728)

</details>

### 4. WEB
- Nginx 컨테이너 실행

<details>
<summary><i>진행 과정</i></summary>

- Nginx를 리버스 프록시로 사용하여 외부 요청을 내부 "was" 서비스로 전달하는 구조 
![Image](https://github.com/user-attachments/assets/6f5ead71-7a41-495f-8958-bb8463253ce1)


- Nginx를 리버스 프록시로 사용하여 외부 요청을 내부 "was" 서비스로 전달하는 구조
    - 두 파일(`default.conf`와 `nginx.sh`)의 연관성
    - `nginx.sh` 스크립트가 실행되면, 이 스크립트는 Docker 명령을 통해 Nginx 컨테이너를 실행함. 이 과정에서 -v 옵션을 사용하여 로컬에 있는 `default.conf` 파일을 컨테이너 내부의 `/etc/nginx/conf.d/default.conf` 경로로 마운트(연결)

#### 전체 구조
- WAS 서비스는 직접 외부에 노출되지 않고, Nginx를 통해 요청이 전달되어 보안과 로드 밸런싱 등의 이점
![Image](https://github.com/user-attachments/assets/f7678924-8157-45d1-82c5-96f9a7c4c7e2)

#### 경로 불일치시 오류
- 터미널 실행할 떄 경로 맞는지 확인하자
![Image](https://github.com/user-attachments/assets/22254add-3d2f-4644-99eb-617433547d52)

#### 성공하면 나오는 화면
![Image](https://github.com/user-attachments/assets/0a987415-729a-4730-afda-5ff09c9e5164)

</details>

### 5. 스케일링을 위한 명령어 입력
- 추가 컨테이너 실행 및 Nginx 리로드
    - was2도 실행, nginx 리로드 명령어 입력

![Image](https://github.com/user-attachments/assets/846515f3-104b-4062-b2cf-4850ea96ce67)

--------

### 빌드 캐시
- Docker는 이미지를 빌드할 때 각 명령어가 생성하는 레이어를 추적
- 입력이 동일하면 Docker는 해당 명령어를 재실행하지 않고 캐시된 레이어를 사용

| 이미지 1 | 이미지 2 |
| --- | --- |
| ![Image](https://github.com/user-attachments/assets/aa01a9fc-7be4-4cb9-99c6-afa5f0682a42) | ![Image](https://github.com/user-attachments/assets/87f8a204-2665-4802-a2eb-7560e45ace8d) |

- <b>이미지 1</b>: `package.json`만 먼저 복사한 후 `yarn install` 실행, 그 다음 전체 파일 복사
- <b>이미지 2</b>: 모든 파일을 한번에 복사한 후 `yarn install` 실행

### Nginx 프로세스 구조
![Image](https://github.com/user-attachments/assets/7de6e082-08ee-40d2-a43c-20a267bcdad7)

#### 마스터 프로세스(Master Process)
- 로그에서 1#1로 식별됨
- 설정 파일을 읽고 평가
- 워커 프로세스를 생성하고 관리
- 권한 높은 작업(예: 포트 80 바인딩) 수행
- 시스템 관리자의 명령(예: 재시작, 종료) 처리

#### 워커 프로세스(Worker Process)
- 로그에서 29, 30, 31 등의 ID로 식별됨
- 클라이언트의 실제 연결과 요청을 처리
- 네트워크 연결, 컨텐츠 제공, 프록시 기능 등 수행
- 각 워커는 많은 동시 연결을 처리할 수 있음

#### 왜 이 로그가 표시되는가?
- 이 로그는 Nginx가 시작되는 과정에서 워커 프로세스들을 생성하고 있음을 나타냄
    - 총 7개의 워커 프로세스(29-35)가 시작됨
    - 이는 정상적인 Nginx 시작 과정의 일부
- 워커 프로세스 수는 일반적으로 서버의 CPU 코어 수에 맞게 설정되며, 이는 nginx.conf 파일의 worker_processes 지시어로 제어됨
    - 기본값은 auto로, 자동으로 사용 가능한 CPU 코어 수를 감지
