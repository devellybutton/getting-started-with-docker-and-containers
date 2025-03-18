# 섹션 7. 컨테이너

## 컨테이너의 정의
- 컨테이너는 실행에 필요한 모든 파일과 의존성을 이미지화하여, 호스트 시스템으로부터 격리된 환경에서 실행되는 프로세스
- 이 격리된 환경에서 애플리케이션이 동작하므로 호스트 시스템이나 다른 컨테이너에 영향을 주지 않고 일관된 방식으로 실행됨.

## 컨테이너의 생명주기 (Lifecycle)
`created` -> `running` -> `paused` -> `stopped` -> `restart` -> `deleted` 

## 실습 - 컨테이너의 생명주기 (Lifecycle)
### 윈젯으로 jq 설치
- jq 다운로드 [https://jqlang.org/download/]
- winget으로 jq 다운로드 방법 [https://learn.microsoft.com/en-us/windows/package-manager/winget/]

![Image](https://github.com/user-attachments/assets/03bc161e-a363-47bd-b27b-cba8743bf53d)

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

### docker exec: 컨테이너 내부에 프로세스 실행

### docker logs: 컨테이너 로그 확인 

### docker inspect: 컨테이너 세부 정보 확인

## 컨테이너 재시작 정책

### 실습 - 컨테이너 재시작 정책

### 실습 - 도커를 활용한 서비스 개발 환경 구축

## 도커 서비스 운영 팁