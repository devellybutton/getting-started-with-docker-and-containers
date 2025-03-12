# 섹션 4. 이미지

- [이미지와 레이어](#이미지와-레이어)
- [Dockerfile](#dockerfile)
- [자주 쓰는 명령어](#자주-쓰는-명령어)
- [빌드 컨텍스트와 이미지 빌드](#빌드-컨텍스트와-이미지-빌드)
- [빌드 캐시의 정의 및 활용](#빌드-캐시의-정의-및-활용)

---

## 이미지와 레이어

![Image](https://github.com/user-attachments/assets/7143af1b-9f79-4f33-b404-1d2c65c761a3)

### 1. 이미지의 개념과 특징

#### 이미지

- 컨테이너(프로세스)를 실행하는데 필요한 모든 것들을 포함하는 압축 파일
- 런타임(python 등), 바이너리(실행파일), 코드, 라이브러리, 설정 파일 등

#### 이미지에 포함되는 것들

- 런타임 환경: Python, Node.js, Java 등의 실행 환경
- 바이너리(실행 파일): 애플리케이션 실행 파일
- 애플리케이션 코드: 개발자가 작성한 소스 코드
- 라이브러리 및 종속성: 애플리케이션이 의존하는 라이브러리
- 환경 변수 및 설정 파일: 애플리케이션 구성 정보
- 파일 시스템 구조: 필요한 디렉토리 및 파일 구조

#### 이미지의 주요 특징

- 불변성, 계층화된 구조, 상태 비저장(Stateless), 이식성

| 개념                                        | 설명                                                                                                                                                                            |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **불변성(Immutability)**                    | 컨테이너 이미지는 한 번 생성되면 변경할 수 없으며, 수정이 필요할 경우 새로운 이미지를 만들어야 함. <br> 이 특징은 환경의 일관성을 보장하고 버전 관리가 용이하게 함.             |
| **계층 구조(Layered Architecture)**         | 컨테이너 이미지는 여러 계층(layer)로 구성된 파일 시스템을 사용함. <br> 각 명령(RUN, COPY, ADD 등)은 이전 계층에 변경을 적용하며, 이 변경 사항은 새 계층으로 캐시됨.             |
| **캐시(Caching)**                           | 이미 빌드된 계층은 캐시되어, 이미 변경되지 않은 계층을 다시 빌드할 필요가 없어 빌드 시간이 단축되고 디스크 공간이 절약됨. <br> 여러 이미지는 동일한 기본 계층을 공유할 수 있음. |
| **상태 없는 컨테이너(Stateless Container)** | 상태가 없는 컨테이너는 삭제되면 그 안의 모든 변경 사항이 사라짐. <br> 즉, 컨테이너는 실행 중에만 데이터를 보유하고 종료 후에는 모든 변화가 사라지는 것임.                       |
| **이식성(Portability)**                     | 컨테이너는 필요한 모든 의존성(라이브러리, 설정 등)을 포함하여, 동일한 컨테이너를 다양한 환경에서 실행할 수 있게 함. <br> "내 컴퓨터에서는 안 돌아가" 문제를 해결함.             |

#### 데이터 지속성

- 컨테이너는 임시적인 환경이므로, 영구적인 데이터 저장을 위해서는:
  - <b>볼륨(Volumes)</b>: Docker에서 관리하는 영구 저장소
  - <b>바인드 마운트(Bind Mounts)</b>: 호스트 파일 시스템의 특정 경로를 컨테이너에 마운트
  - <b>tmpfs 마운트</b>: 메모리에만 데이터 저장(리부팅 시 소멸)

### 2. Docker 컨테이너의 상태 비저장 특성

![Image](https://github.com/user-attachments/assets/92ebc3f7-aa65-47dc-a55c-2be5021fffff)

#### Docker의 특징

- 컨테이너는 항상 이미지의 원본 상태에서 시작
- 컨테이너 내부의 변경사항은 해당 컨테이너의 생명주기 동안만 유지
- 데이터를 영구적으로 보존하려면 볼륨(volume)이나 바인드 마운트(bind mount)를 사용해야 함

![Image](https://github.com/user-attachments/assets/0ae37530-4207-417a-9083-f905eabf5ad9)

---

## Dockerfile

### 1. Dockerfile

- 이미지를 만들기 위한 설계도 역할
- Dockerfile에 명시된 명령어(Instruction) 기반으로 이미지를 생성함
- 작동 방식 : 설계도 => 이미지 생성(빌드) => 실행

### 2. 명령어 형식

```
Instruction arguments
```

- <b>INSTRUCTION</b>: 대문자로 작성하는 명령어 (예: FROM, RUN, COPY)
- <b>arguments</b>: 해당 명령어에 전달할 인자값

---

## 자주 쓰는 명령어

| 명령어     | 레이어 생성 용도 | 빌드/실행 시점  | 설명                     |
| ---------- | ---------------- | --------------- | ------------------------ |
| [ARG](#arg)        | 아니오           | 빌드 시         | 빌드 시 사용할 변수 설정 |
| [FROM](#from)       | 예               | 빌드 시         | 기본 이미지 지정         |
| [WORKDIR](#workdir)    | 예               | 빌드 시         | 작업 디렉토리 설정       |
| [RUN](#run)        | 예               | 빌드 시         | 명령어 실행              |
| [COPY](#copy)       | 예               | 빌드 시         | 파일/디렉토리 복사       |
| [ENV](#env)        | 예               | 빌드 및 실행 시 | 환경 변수 설정           |
| [EXPOSE](#expose)     | 아니오           | 문서화 목적     | 컨테이너 포트 명시       |
| [VOLUME](#volume)     | 예               | 실행 시         | 데이터 볼륨 설정         |
| [ENTRYPOINT](#entrypoint) | 아니오           | 실행 시         | 시작 명령어 설정         |
| [CMD](#cmd)        | 아니오           | 실행 시         | 기본 인자 설정           |

#### ARG

- <b>빌드 시</b> 사용할 변수 설정
- 컨테이너 실행 시에는 사용되지 않음.
- 일부 특수 ARG 변수는 별도 정의 없이도 사용 가능 (예: HTTP_PROXY, ALL_PROXY)
- 플랫폼 관련 글로벌 인자: `TARGETOS`, `TARGETARCH` (크로스 플랫폼 빌드 시 유용)

```
# 기본 사용법
ARG IMAGE_VERSION=21

# ARG로 정의한 변수를 다른 명령어에서 사용
FROM node:${IMAGE_VERSION}
```

```
# 빌드 시 인자 전달
docker build --build-arg IMAGE_VERSION=22 -t my-node-app .
```

#### FROM

- 기본 이미지 (이미지 빌드의 기반이 되는 이미지) 지정

```
# 기본 사용법 (태그 미지정 시 latest 사용)
FROM node

# 특정 버전 지정
FROM node:21

# ARG 변수 사용
FROM node:${IMAGE_VERSION}

# 다이제스트(해시) 사용 - 더 명확한 버전 지정
FROM node@sha256:93d2e5a40ac9059a93627b9d9e7f22ce9c44c729b9a2299bc786acb130b156a3
```

#### WORKDIR

- 작업 디렉토리 설정
- 지정된 디렉토리가 없으면 자동으로 생성됨.
- 항상 명시적으로 WORKDIR을 설정하는 것이 좋음.

```
# 기본 사용법
WORKDIR /usr/src/app

# 이후의 모든 명령어는 이 디렉토리를 기준으로 실행됨
COPY . .  # /usr/src/app으로 복사
RUN npm install  # /usr/src/app에서 실행
```

#### RUN

- 빌드 시 명령어 실행
- 여러 RUN 명령어를 하나로 결합하여 <b>레이어 수를 최소화</b>하는 것이 좋음.

```
# 기본 사용법
RUN npm install

# 여러 명령어를 한 레이어에 실행 (레이어 수 최소화)
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*
```

#### COPY

- 호스트에서 컨테이너 이미지로 파일/디렉토리 복사
- `ADD <src> <dst>`
  - COPY와 비슷하나, 1) 자동 압축 해제 / 2) Git 저장소 복사 등 가능
  - Dockerfile만 보고 예상하기 어려우며, 외부에 의해 변화 가능하므로 사용 지양

```
# 기본 사용법: 현재 디렉토리의 모든 파일을 작업 디렉토리로 복사
COPY . .

# 특정 파일만 복사
COPY package.json package-lock.json ./

# 와일드카드 사용
COPY *.txt /app/
COPY hello?.txt ./  # ? 는 한 글자 와일드카드
```

#### ENV

- <b>컨테이너 실행 시</b>에 사용될 환경 변수를 설정
  - ENV는 빌드 및 실행 시점 모두에 적용됨
  - 빌드 시에만 필요한 변수는 ARG 사용 권장
  - 상위 이미지의 ENV 값을 상속함

```
# 기본 사용법
ENV NODE_ENV=production

# 여러 변수 설정
ENV PORT=3000 \
    DEBUG=false \
    LOG_LEVEL=info
```

#### EXPOSE

- 컨테이너가 실행 중에 수신할 포트를 지정 <b>(문서화 목적, 실제 포트 개방 혹은 매핑 X)</b>
- 실제 포트 매핑은 컨테이너 실행 시 설정해야됨.

```
# 기본 사용법 (TCP 포트)
EXPOSE 5000

# TCP 및 UDP 포트 지정
EXPOSE 5000/tcp 5000/udp
```

```
# 자동 포트 매핑 (-P 옵션 사용)
docker run -P my-app
# EXPOSE된 포트가 호스트의 임의 포트에 매핑됨
```

#### VOLUME

- 데이터 지속성을 위한 볼륨 생성
  - `docker run --rm` 사용 시 컨테이너가 종료되면 볼륨도 함께 삭제됨
  - `docker rm -f`로 강제 삭제 시에는 볼륨이 유지됨

```
# 기본 사용법
VOLUME /var/lib/postgresql/data

# 여러 볼륨 지정
VOLUME ["/data", "/logs", "/config"]
```

#### ENTRYPOINT

- 컨테이너 시작 명령어
- CMD와 함께 사용하여 <b>ENTRYPOINT</b>는 실행 파일, <b>CMD</b>는 기본 인자를 지정하는 형태로 사용

```
# 실행 파일 형태 (권장)
ENTRYPOINT ["npm"]

# 쉘 형태 (환경 변수 확장이 필요할 때)
ENTRYPOINT npm $NPM_COMMAND
```

#### CMD

- 컨테이너 시작 시 실행될 명령어 또는 ENTRYPOINT의 인자를 지정

```
# 단독 사용 시 - 완전한 명령어 지정
CMD ["npm", "start"]

# ENTRYPOINT와 함께 사용 시 - 인자만 지정
ENTRYPOINT ["npm"]
CMD ["start"]
# 결과적으로 'npm start' 실행됨
```

```
# CMD는 컨테이너 실행 시 인자로 오버라이드 가능
docker run my-app test
# 'npm test'가 실행됨 (start 대신 test가 CMD를 대체)
```

---

## 빌드 컨텍스트와 이미지 빌드

---

## 빌드 캐시의 정의 및 활용
