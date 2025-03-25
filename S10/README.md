# 섹션 10. 프로젝트) CI/CD 배포 파이프라인 제작

## 아키텍처
![Image](https://github.com/user-attachments/assets/4fb3418d-3b17-4cc0-98a9-b23ec224e9cd)

- 엔지니어가 코드를 GitHub 저장소(Repository)에 푸시하면, workflow yaml이 실행되고, GitHub Actions가 자동으로 트리거됨. GitHub Actions는 두 가지 주요 작업을 수행:
1. 코드를 사용하여 도커 이미지를 빌드하고 이를 ECR(Elastic Container Registry)에 저장
2. SSH를 통해 서버에 접속하여 배포 명령을 실행
- 서버는 ECR에서 새롭게 빌드된 도커 이미지를 가져와 실행함으로써 애플리케이션을 업데이트

## CI/CD와 Github Actions

### CI/CD
| 구성 요소  | 설명 |
|------------|-------------------------------------------------------------|
| **CI (Continuous Integration)**  | - 지속적 통합 <br> - 쉽게 말해, “배포 가능한 환경을 항상 유지하는 것” 이라고 표현할 수 있음. <br> - 소스코드, 라이브러리 등 변경 시 자동으로 빌드/테스트 등을 수행하도록 만드는 것 |
|  **CD (Continuous Delivery/Deployment)** |  - 지속적 전달/배포 <br> - 전달은 배포 단계를 수동으로 진행하는 것 <br> - CI 단계가 완료된 후, 자동으로 프로덕션 환경에 배포되도록 만드는 것                   |



### GitHub Actions
- GitHub이 제공하는 CI/CD 플랫폼
- 간단한 yaml 파일 작성을 통해 CI/CD 자동화 가능

### GitHub Actions 구성 요소
| 구성 요소  | 설명 |
|------------|-------------------------------------------------------------|
| **Event**  | PR, Push, Issue 등의 이벤트로 Workflow를 트리거할 수 있음 |
| **Runner** | Workflow를 실행하는 서버(컨테이너) |
| **Workflow** | 하나 이상의 Job을 포함하는 파일로, Event 또는 수동 트리거 가능 |
| **Job** | 여러 Step을 순서대로 실행하며, 동일한 Runner에서 실행 |
| **Action** | 자주 반복되는 작업을 편리하게 실행할 수 있도록 도와주는 애플리케이션 |

## 무작정 실행해보기
- 레포 생성 > Actions > simple 검색 후 선택 
- `.github`부터 `workflow` 까지는 규칙
- 앞이 `runner`나 `github`으로 시작하는 것만 보면 됨
- terraform: 디버깅 하기 위한 폴더

### docker compose 명령 사용 가능하게 하기
![Image](https://github.com/user-attachments/assets/378c62aa-de85-44d8-a1ee-b9341133b9d4)

### 변수 표현 방식 차이
- `${{ runner.os }}`: 컨텍스트 변수
    - GitHub Actions가 워크플로우를 실행하기 전에 해석/처리
- `$RUNNER_OS`: 환경 변수
    - 워크플로우가 실제로 실행되는 시점에 셸(shell)에 의해 해석

```
$ echo "Linux" Linux
Linux Linux
```
- 첫 번째 "Linux"는 `${{ runner.os }}`가 GitHub에 의해 대체된 값
- 두 번째 "Linux"는 `$RUNNER_OS` 환경 변수가 셸에 의해 해석된 값

## 도커 배포 환경 구성
- SCP(Secure Copy Protocol)를 통한 파일 복사
- SSH를 통한 빌드 및 실행

### 사전 준비
- `userdata.sh` 파일의 내용을 EC2의 "User Data" 섹션에 복사 
    ![Image](https://github.com/user-attachments/assets/56779fc3-80d8-4523-8152-a328c3f12769)

1. 키 파일 설정
    - too open 에러 뜨면
    ```
    chmod 400 docker-cicd-key.pem
    ```

2. SSH로 EC2 인스턴스 접속
    ```
    ssh -i docker-cicd-key.pem ec2-user@[EC2-퍼블릭-도메인]
    ```

3. GitHub 프로젝트 설정
    - `.github/workflows` 디렉토리에 워크플로우 파일을 `simple-cicd.yaml`로 생성/변경
    - GitHub 저장소의 Settings > Secrets and Variables에서 필요한 환경변수와 시크릿 설정:
        - EC2 관련 접속 정보
        - 필요한 인증 정보

4. SCP를 통한 파일 복사 (GitHub Actions에서 자동화)
    - GitHub Actions 워크플로우 파일에 SCP 관련 단계 추가
    - 로컬 코드를 EC2 인스턴스로 복사
        ![Image](https://github.com/user-attachments/assets/a843e324-fc0b-4178-96be-d77725142697)

5. 배포 및 실행 (GitHub Actions에서 자동화)
    - SSH 명령어로 EC2에서 Docker 빌드 및 실행 명령어 수행

6. 애플리케이션 접속을 위한 설정
    - EC2 보안 그룹에서 애플리케이션 포트(예: 8080) 인바운드 규칙 추가
        ![Image](https://github.com/user-attachments/assets/d08592ae-10d1-4c33-a14e-6a1f5740e933)

7. 웹 브라우저에서 [EC2-퍼블릭-도메인]:8080으로 접속 확인
    ![Image](https://github.com/user-attachments/assets/5c361c2f-cfc9-4f11-97ea-d451b4317fca)

### Github Actions 플랫폼 캐싱 기능
![Image](https://github.com/user-attachments/assets/1cb676c3-0b36-4c9d-b6e0-107fb3929ee8)

## 도커 컴포즈 적용



## 이미지 빌드 및 ECR 적용


## 생성한 리소스 삭제