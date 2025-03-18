# 섹션 7. 컨테이너

## 컨테이너의 정의
- 컨테이너는 실행에 필요한 모든 파일과 의존성을 이미지화하여, 호스트 시스템으로부터 격리된 환경에서 실행되는 프로세스
- 호스트 OS의 커널을 공유하면서 프로세스를 격리된 환경에서 실행하는 기술 <b>(격리된 프로세스 그룹)</b>
- 이 격리된 환경에서 애플리케이션이 동작하므로 호스트 시스템이나 다른 컨테이너에 영향을 주지 않고 일관된 방식으로 실행됨.

1. 도커 컨테이너는 "격리된 프로세스 그룹"
2. 도커 데몬이 이러한 프로세스들의 생명주기와 격리를 관리함.
3. 컨테이너의 격리는 리눅스 커널 기능을 통해 구현됨.

## 컨테이너의 생명주기 (Lifecycle)
`created` -> `running` -> `paused` -> `stopped` -> `restart` -> `deleted` 

## 실습 - 컨테이너의 생명주기 (Lifecycle)
### 윈젯으로 jq 설치
- jq 다운로드 [https://jqlang.org/download/]
- winget으로 jq 다운로드 방법 [https://learn.microsoft.com/en-us/windows/package-manager/winget/]

<details>
<summary><i>winget 설치 화면</i></summary>

![Image](https://github.com/user-attachments/assets/03bc161e-a363-47bd-b27b-cba8743bf53d)

</details>

### 컨테이너 생명주기 살펴보기 

#### 1. 기본 삭제 과정
```
docker run -d --name nginx nginx
docker inspect nginx --format '{{json .State}}' | jq
docker stop nginx
docker ps -a
docker rm nginx
```
- <b>특징</b>: 일반적인 컨테이너 생성-중지-삭제의 정석 과정
- <b>과정</b>:
    1. nginx 이미지로 백그라운드(-d) 컨테이너 생성 및 실행
    2. 컨테이너 상태 정보를 JSON 형식으로 확인
    3. 컨테이너 정상 종료
    4. 중지된 컨테이너 포함 모든 컨테이너 목록 확인
    5. 중지된 컨테이너 삭제
- <b>사용 시나리오</b>: 컨테이너 상태를 확인하고 정상적으로 종료 후 삭제해야 하는 경우

<details>
<summary><i>life-cycle.sh - 기본 삭제 방식</i></summary>

![Image](https://github.com/user-attachments/assets/fca2be26-d374-44d4-890b-713a330729ea)

</details>

#### 2. --rm 옵션 사용
```
docker run --rm -d --name nginx nginx
docker stop nginx
docker ps -a
```
- <b>특징</b>: 컨테이너 종료 시 자동 삭제
- <b>과정</b>:
    1. `--rm` 옵션을 사용하여 정지 시 자동 삭제되는 컨테이너 생성
    2. 컨테이너 정상 종료 (이 때 자동으로 삭제됨)
    3. 컨테이너 목록 확인 (nginx 컨테이너는 이미 삭제되어 목록에 없음)
- <b>사용 시나리오</b>: 임시 작업용 컨테이너, 테스트 환경, 별도 삭제 명령 없이 정리가 필요한 경우

<details>
<summary><i>life-cycle.sh - --rm 옵션</i></summary>

![Image](https://github.com/user-attachments/assets/25c3dce4-c35f-4dd4-87b2-cb1a79d701a9)

</details>

#### 3. --rm -f 옵션 사용
```
docker run -d --name nginx nginx
docker rm -f nginx
docker ps -a
```
- <b>특징</b>: 실행 중인 컨테이너를 강제로 즉시 종료 및 삭제
- <b>과정</b>:
    1. nginx 컨테이너 생성 및 실행
    2. `-f` 옵션으로 실행 중인 컨테이너를 강제 종료 및 삭제
    3. 컨테이너 목록 확인 (nginx 컨테이너가 삭제됨)
- <b>사용 시나리오</b>: 응답하지 않는 컨테이너 제거, 긴급 상황, 개발 환경에서 빠른 정리

<details>
<summary><i>life-cycle.sh - rm -f 옵션</i></summary>

![Image](https://github.com/user-attachments/assets/73980564-87cb-44df-bbb8-f647dd72950b)

</details>

#### 4. 대화형 컨테이너의 --rm 활용
```
docker run --rm -it busybox sh
```
- <b>특징</b>: 대화형 쉘 종료 시 컨테이너 자동 삭제
- <b>과정</b>:
    1. -it 옵션으로 대화형 터미널 연결, --rm으로 종료 시 자동 삭제 설정
    2. busybox 이미지의 sh 쉘 실행
    3. 쉘 종료 시(exit 명령어 또는 Ctrl+D) 컨테이너 자동 삭제
- <b>사용 시나리오</b>: 일회성 명령 실행, 스크립트 테스트, 임시 작업 수행

<details>
<summary><i>life-cycle.sh - 대화형 쉘과 --rm 조합</i></summary>

![Image](https://github.com/user-attachments/assets/0eebaf88-718f-4a47-bba9-4b21e7d1cd97)

</details>

### docker run: 컨테이너 실행

- [entrypoint에 대하여](./entrypoint/README.md)

#### 볼륨 마운트
```
-v "$(pwd)"/index.html:/usr/local/apache2/htdocs/index.html:ro
```
- `$(pwd)`: 현재 작업 디렉토리(리눅스/macOS에서 사용)를 의미
- `:ro` : 컨테이너 내부에서 이 파일을 수정할 수 없도록 함.
- 호스트의 현재 디렉토리에 있는 `index.html` 파일을 컨테이너 내부의 Apache 웹 서버 문서 루트에 마운트함.
    - 내 로컬 컴퓨터의 현재 폴더에 있는 `index.html` 파일을 그대로 웹 서버의 기본 페이지로 사용하라는 의미
    - 호스트에서 `index.html`을 수정하면 컨테이너 내부에서도 바로 변경사항이 반영됨.

#### 네트워크 삭제
```
docker network rm -f run
```
- `-f` 옵션(강제 삭제)은 네트워크 삭제 명령어에서는 작동하지 않음.
- 네트워크에 연결된 컨테이너가 있으면 먼저 해당 컨테이너를 중지하고 나서 네트워크를 삭제해야 함.

- 도커가 `-it` 플래그로 실행 중인 상태에서 터미널 상호작용이 변경되면 신호가 전달될 수 있음.

<details>
<summary><i>docker-run.sh</i></summary>

![Image](https://github.com/user-attachments/assets/c89c80cb-61a7-4573-b008-f1ffaeb24ac2)

![Image](https://github.com/user-attachments/assets/657af01c-20d6-48ee-b8ec-92aebfe1d936)

![Image](https://github.com/user-attachments/assets/4757f7ec-6424-4ed0-89fa-1c1c7a744fc7)

![Image](https://github.com/user-attachments/assets/c1e49574-7934-4306-ba69-a58a3337f23d)

</details>

### docker exec: 컨테이너 내부에 프로세스 실행

#### 도커에서 sleep infinite 명령어를 사용하는 이유
1. <b>컨테이너를 계속 실행 상태로 유지하기 위함</b>
- 도커 컨테이너는 기본적으로 메인 프로세스(PID 1)가 종료되면 같이 종료됨
- sleep infinite는 절대 종료되지 않는 프로세스이므로, 컨테이너를 계속 실행 상태로 유지할 수 있음
2. <b>최소한의 리소스 사용</b>
- sleep 명령어는 CPU나 메모리를 거의 사용하지 않음
- 따라서 컨테이너를 백그라운드에서 실행 상태로 유지하는 가장 경제적인 방법

<details>
<summary><i>docker-exec.sh</i></summary>

![Image](https://github.com/user-attachments/assets/623c96fc-7a8e-4adf-bca6-67849495a891)

</details>

### docker logs: 컨테이너 로그 확인 

- `while ($true) { curl.exe -s -o /dev/null http://localhost:8080; Start-Sleep -Seconds 1 }`
    - 무한 루프를 돌며
    - NGINX 서버에 요청을 조용히 보내고 (-s 옵션으로 출력 없음)
    - 응답을 버리고 (-o /dev/null로 출력 리다이렉션)
    - 1초를 기다린 후 다시 반복

#### 로그 확인 방법
- `docker logs nginx`: 기본 로그 출력
- `docker logs -t nginx`: 타임스탬프와 함께 로그 출력
- `docker logs -f nginx`: 로그를 실시간으로 계속 확인(follow)

#### 시간 기준 로그 필터링
- `docker logs -f --since 10s nginx`: 최근 10초 동안의 로그만 표시
- `docker logs --until 10s nginx`: 10초 전까지의 로그만 표시
- `docker logs -f --since 10s --until 1m nginx`: 10초 전부터 1분 전까지의 로그
- `docker logs -f --since=2024-07-11T00:00:00Z --until=2024-07-11T01:30:30Z nginx`: 특정 시간대의 로그만 표시

<details>
<summary><i>docker-logs.sh</i></summary>

![Image](https://github.com/user-attachments/assets/ca748f02-5422-454d-bfd2-c390da935b2a)

![Image](https://github.com/user-attachments/assets/e1d75b6f-32a1-4f33-9ed5-ede754da9e43)

</details>

### docker inspect: 컨테이너 세부 정보 확인
- Docker 객체(컨테이너, 이미지, 네트워크, 볼륨 등)에 대한 상세 정보를 JSON 형식으로 보여주는 명령어
- 이 명령어는 다양한 Docker 객체의 내부 구조, 설정, 상태 등을 확인할 때 매우 유용

#### 기본 정보
- `Id`: 컨테이너의 전체 ID
- `Created`: 컨테이너 생성 시간
- `Path & Args`: 컨테이너에서 실행 중인 명령어 ("sleep 10")

#### State: 컨테이너 상태 정보
- `Status`: 현재 상태 (running)
- `Running`: 실행 중인지 여부 (true/false)
- `StartedAt`: 시작 시간
- `FinishedAt`: 종료 시간
- `ExitCode`: 종료 코드

#### 주요 경로 정보
- `LogPath`: 로그 파일 위치
- `ResolvConfPath`: DNS 설정 파일 위치
- `HostsPath`: hosts 파일 위치

#### Config: 컨테이너 구성 정보
- `Cmd`: 실행 명령어
- `Image`: 사용된 이미지
- `Env`: 환경 변수

#### NetworkSettings: 네트워크 구성
- `IPAddress`: 컨테이너 IP 주소 (172.17.0.2)
- `Gateway`: 게이트웨이 주소 (172.17.0.1)
- `MacAddress`: MAC 주소
- `Networks`: 연결된 네트워크 정보

<details>
<summary><i>docker-inspect.sh</i></summary>

![Image](https://github.com/user-attachments/assets/18cb11e7-75ad-4896-b89a-7e050c0ede15)

</details>

## 컨테이너 재시작 정책

### 실습 - 컨테이너 재시작 정책

### 실습 - 도커를 활용한 서비스 개발 환경 구축

## 도커 서비스 운영 팁