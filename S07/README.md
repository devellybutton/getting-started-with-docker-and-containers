# 섹션 7. 컨테이너
- [컨테이너의 정의](#컨테이너의-정의)
- [컨테이너의 생명주기](#컨테이너의-생명주기-lifecycle)
- [실습-컨테이너의 생명주기](#실습---컨테이너의-생명주기-lifecycle)
- [컨테이너 재시작 정책](#컨테이너-재시작-정책)
- [도커 서비스 운영 팁](#도커-서비스-운영-팁)

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

### 1. 컨테이너 오류 시 발생할 수 있는 문제
- 재시작 없음: 서비스 장애 지속, 비즈니스 영향 증가
- 무조건 재시작: 실패 요청 반복으로 다른 서비스 및 자원에 부담 증가

### 2. 도커 재시작 정책 옵션(`docker run --restart [VALUE]`)

| 정책        | 설명                                                                 |
|-------------|----------------------------------------------------------------------|
| **no**      | 자동 재시작 없음 (기본값)                                               |
| **on-failure[:max-retries]** | 종료 코드가 0이 아닐 때만 재시작                                        |
| **always**  | 수동 삭제(rm) 전까지 항상 재시작  <br>  - `docker stop` 후에는 재시작 안 함 <br> - 도커 데몬 재시작 시 컨테이너도 재시작됨                                   |
| **unless-stopped** | always와 유사하나, 도커 데몬 재시작 시에도 컨테이너 재시작 안 함           |

### 실습 - 컨테이너 재시작 정책

- ExitCode가 1인 것은 정상 종료(0)가 아닌 오류로 인한 종료

#### always vs unless-stopped
- 도커 데몬이 재시작될 때의 차이
- `always`: 도커 서비스가 재시작되면 이전에 중지했던 컨테이너도 모두 재시작됨
- `unless-stopped`: 도커 서비스가 재시작되어도 이전에 명시적으로 중지했던 컨테이너는 재시작되지 않음

<details>
<summary><i>restart-policy.sh</i></summary>

![Image](https://github.com/user-attachments/assets/101958da-d371-4ecd-9d43-b058491a0ae5)

![Image](https://github.com/user-attachments/assets/dcc90589-5ca3-44ce-a85a-edee9e58d133)

</details>

### 실습 - 도커를 활용한 서비스 개발 환경 구축

#### 도커로 개발 환경을 구축할 때의 장점
1. 일관된 개발 환경
    - 개발 환경 격리로 인한 일관성으로 “제 PC에선 되는데…” 방지 가능
    - 로컬 버전을 맞추기 위한 노력 감소 및 업그레이드 매우 편해짐
2. 빠른 적용
    - docker run만 입력하면 되므로, 환경을 맞추기 위한 노력이 줄어듦
3. 성공적인 운영 배포
    - 개발부터 운영 환경과 비슷하게 만들어,
    - 컨테이너 환경으로 인한 차이로 정상 배포가 안되는 케이스가 줄어듦

![Image](https://github.com/user-attachments/assets/1f515e70-58f7-440d-9a03-3d1595cb336a)

#### 구조 설명
- MySQL 데이터베이스와 Node.js 애플리케이션을 각각 별도의 컨테이너로 실행
- todo라는 Docker 네트워크를 생성하여 두 컨테이너가 서로 통신할 수 있게 함
- 특히 Node.js 애플리케이션이 mysql이라는 호스트명으로 MySQL 컨테이너에 접근 가능

#### EC2 인스턴스와 Docker 볼륨
- <b>EC2 인스턴스를 중단(stop)했다가 다시 시작하는 경우</b>:
    - EC2 인스턴스의 EBS 볼륨은 유지되므로 Docker 볼륨도 보존
    - 인스턴스를 다시 시작하면 Docker 볼륨에 저장된 MySQL 데이터도 그대로 유지
- <b>EC2 인스턴스를 종료(terminate)하는 경우</b>:
    - 기본적으로 EC2의 루트 볼륨은 삭제되므로 Docker 볼륨도 함께 삭제
    - 따라서 MySQL에 저장된 모든 데이터가 손실

![Image](https://github.com/user-attachments/assets/a72deb66-a7df-4904-9fd6-11f711323d81)

## 도커 서비스 운영 팁

### 1. 컨테이너 관리 전략
- <b>--rm 옵션 사용 금지</b>: 프로덕션 환경에서는 컨테이너 종료 시 자동 삭제되는 --rm 옵션을 사용하지 말 것. 컨테이너가 삭제되면 로그와 문제 진단 정보도 함께 사라짐
- <b>적절한 재시작 정책 설정</b>: 서비스 특성에 맞는 --restart 정책(on-failure, always, unless-stopped)을 설정

### 2. 볼륨 관리
- <b>Named Volume 사용</b>: 데이터 지속성을 위해 항상 Named Volume을 사용
- <b>읽기 전용(ro) 옵션 적용</b>: 데이터 무결성을 위해 읽기만 필요한 볼륨은 `:ro` 옵션으로 마운트
- <b>백업 전략 수립</b>: 중요 데이터에 대한 정기적 백업 계획을 수립

### 3. 네트워크 구성
- <b>별도 네트워크 구축</b>: 기본 bridge 네트워크 대신 사용자 정의 네트워크를 생성하여 컨테이너 간 격리와 통신을 관리
- <b>내부 DNS 활용</b>: 사용자 정의 네트워크에서는 컨테이너 이름으로 통신이 가능
- <b>노출 포트 최소화</b>: 외부에 필요한 포트만 제한적으로 노출

### 4. 이미지 최적화
- <b>레이어 수 최소화</b>: Dockerfile 명령어 병합으로 레이어 수 감소
- <b>이미지 사이즈 축소</b>: 필요한 패키지만 설치하고 멀티스테이지 빌드를 활용
- <b>베이스 이미지 선택</b>: `alpine` 또는 `slim` 버전과 같은 경량 이미지 사용을 고려

### 5. 리소스 관리
- <b>리소스 제한 설정</b>: `--cpus`, `--memory`, `--pids-limit` 등으로 리소스 사용량을 제한
- <b>스왑 비활성화 고려</b>: 메모리 성능을 위해 --memory-swap 옵션 사용을 검토
- <b>리소스 모니터링</b>: 컨테이너별 리소스 사용량을 지속적으로 모니터링

### 6. 모니터링 및 로깅
- <b>중앙 집중식 로깅</b>: ELK, Fluentd, Loki 등을 활용해 로그를 중앙에서 수집하고 분석
- <b>메트릭 수집</b>: Prometheus, Grafana 등으로 컨테이너 성능 메트릭을 수집하고 시각화
- <b>알림 시스템 구축</b>: 임계값 초과 시 알림을 받을 수 있는 시스템을 구축

### 7. 보안 강화
- 루트가 아닌 사용자 실행: 컨테이너를 비루트 사용자로 실행
- 권한 제한: `--cap-drop`, `--cap-add`로 필요한 권한만 부여
- 이미지 취약점 스캔: 배포 전 이미지 취약점을 정기적으로 스캔