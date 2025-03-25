# 섹션 10. 프로젝트) CI/CD 배포 파이프라인 제작

## 아키텍처
![Image](https://github.com/user-attachments/assets/4fb3418d-3b17-4cc0-98a9-b23ec224e9cd)

- 엔지니어가 코드를 GitHub 저장소(Repository)에 푸시하면, GitHub Actions가 자동으로 트리거됨. GitHub Actions는 두 가지 주요 작업을 수행:
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

## 도커 배포 환경 구성

## 도커 컴포즈 적용

## 이미지 빌드 및 ECR 적용

## 생성한 리소스 삭제