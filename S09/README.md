# 섹션 9. 컴포즈

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
    - compose.yaml 파일을 기준으로 프로젝트 생성 및 관리
3. 간소화된 명령어
    - docker compose up과 docker compose down 만으로 전체 - 시스템 생성/삭제
    - 복잡한 명령어 작성 불필요
4. 시작 순서 자동화
    - 컨테이너 생성 순서 지정 가능 (의존성 관리)
5. 간편한 스케일링
    - docker compose scale 명령을 통한 손쉬운 스케일링
    - YAML 파일에서 미리 여러 인스턴스 지정 가능
6. 코드로 관리되는 인프라
    - 코드로 관리되어 시스템 구조 파악이 쉬움
    - 버전 관리 시스템과 통합 가능

## Docker Compose 버전 차이
- [NHN Cloud - Docker Compose와 버전별 차이](https://meetup.nhncloud.com/posts/277/)

![Image](https://github.com/user-attachments/assets/f793118e-e13f-4cbd-87cd-688deff9a702)
