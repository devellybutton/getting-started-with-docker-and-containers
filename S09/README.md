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

### develop.watch
- `path`: 호스트 시스템에서 변경 사항을 감시할 경로
- `target`: 컨테이너 내부에서 변경 사항이 적용될 경로
- `action`:
    - `sync`: 변경된 파일만 컨테이너 내부로 복사 (빠름)
    - `rebuild`: 전체 이미지를 다시 빌드하고 컨테이너 재시작 (느림)

<details>
<summary><i>avatars 과정</i></summary>

- requirements 파일 변경되면 빌드 다시하고 재시작
    ![Image](https://github.com/user-attachments/assets/cbc0ea23-dcdb-4123-9272-6e7f499a20c0)

    ![Image](https://github.com/user-attachments/assets/bf2231a7-d989-436f-a326-492ab981858c)

- api 응답결과 변경하면 변경된 부분 복사됨
![Image](https://github.com/user-attachments/assets/a6c9e061-e6b2-4319-bbe0-a6c68ed630c0)

- 캐시마운트로 빌드와 재빌드 속도 개선
    - 캐시 마운트: `--mount=type=cache`는 Docker BuildKit의 캐시 기능을 사용
    - 타겟 디렉토리: `target=/root/.cache/pip`는 pip의 캐시 디렉토리를 지정
![Image](https://github.com/user-attachments/assets/54845b78-f4d0-4e89-9217-a24ed40ecee1)

</details>

### bind mount 대신 watch를 사용하는 이유
- `bind mount`는 "모든 파일을 항상 공유"하는 방식이고, `watch`는 "필요한 파일만 필요한 방식"으로 처리

1. 선택적 반응이 가능함
- `bind mount`: 모든 파일 변경을 무조건 컨테이너와 동기화
- `watch`: 파일 유형에 따라 다른 액션(sync/rebuild)을 취할 수 있음  
    - 소스 코드 변경: 파일만 빠르게 복사 (sync)
    - 의존성 파일 변경: 컨테이너 재빌드 (rebuild)

2. 성능과 리소스 관리가 더 좋음
- `bind mount`: 모든 파일을 실시간으로 동기화하므로 파일이 많을 때 성능 저하가 발생할 수 있음
- `watch`: 변경된 파일만 처리하여 더 효율적

3. 더 정교한 제어가 가능함
- `bind mount`: 단순히 디렉토리를 공유하는 방식
- `watch`: 특정 파일이나 패턴에 따라 다른 액션을 취할 수 있어 더 세밀한 제어가 가능

4. 실제 프로덕션 환경과 더 비슷함
- `bind mount`: 개발 환경에서만 사용하는 특별한 설정
- `watch`: 파일을 실제로 컨테이너에 복사하므로 프로덕션 환경과 더 유사한 동작을 보장

![Image](https://github.com/user-attachments/assets/e17766bb-c4fa-4bf2-8f3f-d29ffd338f56)

---------

## docker compose develop - 심화

### 1. compose watch와 애플리케이션 로그 관련 문제
- compose watch는 파일 변경 감지와 반영에 초점을 맞추어 실행되며, 빌드 로그와 watch 결과는 표시되지만, 실제 애플리케이션 로그는 보이지 않음. 
- 해결방법:
    - 별도의 터미널에서 `docker compose logs -f` 명령어로 로그를 확인
    - 로깅 시스템을 외부로 분리 (ELK 스택)
    - 디버깅 도구를 활용(예: VS Code의 디버그 설정)

### 2. 개발/프로덕션 환경 분리
#### 파일 구조
- `compose.yaml`: 모든 환경에서 공통으로 사용되는 설정
- `dev.compose.yaml`: 개발 환경에서만 필요한 설정 (볼륨 마운트, 개발 포트 등)
- `prod.compose.yaml`: 프로덕션 환경에서만 필요한 설정(복제본 수, 리소스 제한 등)
- `dev.dockerfile`/`prod.dockerfile`: 환경별 도커 이미지 빌드 설정

#### 명령어 설정
- 개발 환경: `docker compose -f compose.yaml -f dev.compose.yaml watch`
- 프로덕션 환경: `docker compose -f compose.yaml -f prod.compose.yaml up -d --build`

#### watch vs up --watch
- `watch` : 빌드 로그 O, 앱 로그 X
- `up --watch`: 빌드 로그 X, 앱 로그 O


<details>
<summary><i>테스트 과정</i></summary>

#### watch vs up --watch

![Image](https://github.com/user-attachments/assets/7296789d-5e5e-4bb6-a39b-44b01910d47b)

![Image](https://github.com/user-attachments/assets/91cfb4df-4f65-42ce-9101-862e94e659a6)

#### 항상 빌드하면서 백그라운드에서 up
- 개발 환경 설정을 사용하여 모든 서비스를 백그라운드에서 실행하며, 실행 전에 모든 이미지를 새로 빌드

![Image](https://github.com/user-attachments/assets/8b1286c4-ff64-4947-8d59-763c0224b2f5)

</details>

---------

## 실무 프로젝트 컴포즈 마이그레이션 - 1


---------

## 실무 프로젝트 컴포즈 마이그레이션 - 2
