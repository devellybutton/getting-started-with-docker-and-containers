# 섹션 9. 컴포즈
- [Docker Compose 등장 배경과 장점](#docker-compose-등장-배경과-장점)
- [무작정 띄워보기](#무작정-띄워보기)
- [docker compose build](#docker-compose-build)
- [docker compose deploy](#docker-compose-deploy)
- [docker compose develop - 기초](#docker-compose-develop---기초)
- [docker compose develop - 심화](#docker-compose-develop---심화)
- [실무 프로젝트 컴포즈 마이그레이션 1](#실무-프로젝트-컴포즈-마이그레이션---1)
- [실무 프로젝트 컴포즈 마이그레이션 2](#실무-프로젝트-컴포즈-마이그레이션---2)

------------------------

## Docker Compose 등장 배경과 장점

### 기존 방식(Docker만 사용)의 문제점
1. 네트워크 관리의 어려움
    - 네트워크 생성 및 설정을 수동으로 기억해야 함
2. 볼륨 관리의 비효율성
    - 서비스와 관련 없는 볼륨을 사용하게 될 가능성
3. 명령어 기억 부담
    - 복잡한 Docker 명령어를 기억해야 함
4. 서비스 시작 순서 관리
    - 컨테이너 시작 순서를 수동으로 관리해야 함 (예: DB → WAS → WEB)
5. 스케일링의 어려움
    - 확장 시 기존 컨테이너 실행 명령어를 기억해야 함
    - 각 컨테이너마다 다른 이름 지정 필요
6. 구조 파악의 어려움
    - 전체 시스템 구조를 한눈에 파악하기 어려움

### Docker Compose의 장점
1. 자동화된 네트워크 관리
    - 커스텀 네트워크 자동 생성
2. 프로젝트 기반 관리
    - `compose.yaml` 파일을 기준으로 프로젝트 생성 및 관리
3. 간소화된 명령어
    - `docker compose up`과 `docker compose down` 만으로 전체 시스템 생성/삭제
    - 복잡한 명령어 작성 불필요
4. 시작 순서 자동화
    - 컨테이너 생성 순서 지정 가능 (의존성 관리)
5. 간편한 스케일링
    - `docker compose scale` 명령을 통한 손쉬운 스케일링
    - YAML 파일에서 미리 여러 인스턴스 지정 가능
6. 코드로 관리되는 인프라
    - 코드로 관리되어 시스템 구조 파악이 쉬움
    - 버전 관리 시스템과 통합 가능

## Docker Compose 버전 차이
- [NHN Cloud - Docker Compose와 버전별 차이](https://meetup.nhncloud.com/posts/277/)

![Image](https://github.com/user-attachments/assets/f793118e-e13f-4cbd-87cd-688deff9a702)

--------------

## 무작정 띄워보기

### Redis 데이터베이스 연결 시 오류 처리와 재시도 로직

#### Backoff
- 연결 실패 후 재시도 전에 잠시 대기하는 전략. 이 코드에서는 0.5초를 대기
- 연속적인 재시도가 서버에 부담을 주는 것을 방지하기 위한 방법

#### Exponential Backoff
- 재시도할 때마다 대기 시간을 지수적으로 증가시키는 전략
- 예를 들어, 첫 번째 실패 후 1초, 두 번째 실패 후 2초, 세 번째 실패 후 4초 등으로 대기 시간이 점점 길어짐. 

#### Jitter
- 모든 클라이언트가 동시에 재시도하는 것을 방지하기 위해 대기 시간에 무작위성을 추가하는 기법
- 예를 들어, 정확히 1초가 아니라 0.8~1.2초 사이의 랜덤한 시간을 대기하는 방식

### docker images vs docker compose images
- `docker images`: 로컬에 있는 모든 Docker 이미지 목록을 보여줌
- `docker compose images`: 현재 Docker Compose로 실행 중인 컨테이너들의 이미지 정보를 보여줌

### 빌드한 이미지 변경사항 반영
- `docker compose up -d`: 이미 빌드된 이미지가 있다면 그것을 사용
- `docker compose up -d --build`: 코드를 변경했다면 이 명령어를 사용해야 변경사항이 반영된 새 이미지를 빌드하고 실행

### 프로젝트 이름 지정 
- `-p` 또는 `--project-name` 옵션을 사용하여 프로젝트 이름을 지정

```
docker compose -p rex up -d
docker compose -p rex down
```

<details>
<summary><i>실습 과정</i></summary>

![Image](https://github.com/user-attachments/assets/fd7d2851-7b35-43e4-81a7-925468c7b430)

![Image](https://github.com/user-attachments/assets/a1d2ef37-6c43-4204-8c29-0bbe2ffa4f42)

![Image](https://github.com/user-attachments/assets/eead765e-db72-4f1c-aefd-7fa7d12b1c7c)

</details>

--------------

## docker compose build

- `docker compose build`: compose.yaml에서 build 항목이 있는 모든 서비스의 이미지를 빌드
- `docker compose up -d`: 컨테이너를 백그라운드로 실행하지만, 이미 빌드된 이미지가 있으면 새로 빌드하지 않고 그대로 사용함. 따라서 소스코드가 변경되어도 반영되지 않음.
- `docker compose up -d --build`: 컨테이너를 실행하기 전에 항상 이미지를 새로 빌드함. 소스코드 변경사항이 반영됨.

---------

## docker compose deploy

### depends on
- 서비스 간의 시작 순서 지정
- redis가 실행되어야 web 서비스가 시작될 수 있도록 함
- 빠르게 시작되는 서비스(redis)는 큰 문제가 없지만, MySQL처럼 시작에 시간과 CPU가 많이 필요한 서비스의 경우 의존성 순서가 중요함.
- 의존성이 없으면 웹 서비스 컨테이너가 종속된 서비스를 찾지 못해 죽을 수 있음

### deploy 설정
- `replicas: 1`: 생성할 컨테이너 개수를 지정
    - 현재 스크립트에는 port 바인딩이 1개만 되어 있으므로 이 상태에서 replicas가 여러 개이면 다른 컨테이너는 포트 바인딩이 안 됨.
    - [포트 바인딩 문제](./port-binding/README.md)
- `restart_policy`: 컨테이너가 종료될 때 재시작하는 정책을 설정
    - `condition`: any: 어떤 상황에서든 재시작합니다.
    - `on-failure`로 설정하면 오류가 발생했을 때만 재시작합니다.
    - `max_attempts`: 최대 재시작 시도 횟수 (window 시간 내 실패는 횟수에 포함되지 않음)

### window 옵션
- `window: 60s`: 컨테이너가 60초 동안 정상 상태로 유지되면 안정적인 상태로 간주
- 일반적으로 필수는 아님

### stop_signal
- `stop_signal`: SIGINT: 컨테이너를 중지할 때 보낼 신호를 지정
- Flask는 SIGINT를 받으면 정상적으로(gracefully) 종료

### 명령어
- `docker stats`: 모든 컨테이너의 자원 사용량 보여줌
- `docker compose stats`: Compose로 실행 중인 컨테이너만 보여줌
- `--wait 옵션`: Compose 명령이 모든 서비스가 정상 상태에 도달할 때까지 기다림

![Image](https://github.com/user-attachments/assets/09709822-e170-410f-8946-05aa99cd2ec1)

---------

## docker compose develop - 기초



---------

## docker compose develop - 심화

---------

## 실무 프로젝트 컴포즈 마이그레이션 - 1

---------

## 실무 프로젝트 컴포즈 마이그레이션 - 2