# 섹션 8. [프로젝트] 실무 요구사항 해결하기 

## 프로젝트 폴더 분석

- <b>was 폴더</b> - 개발용 3-tier 아키텍처
- <b>결과물 폴더</b> - 배포용 3-tier 아키텍처
    - 프레젠테이션 계층: NGINX (웹 서버/로드 밸런서)
    - 애플리케이션 계층: WAS (여러 인스턴스로 확장 가능)
    - 데이터 계층: MySQL (데이터베이스)

## 진행 순서

1. 커스텀 네트워크 생성
    - `global.sh`에서 `docker network create service` 입력
2. 볼륨 생성 및 MySQL 컨테이너 실행
    - mysql/mysql.sh에서 service라는 이름의 Docker 네트워크에 컨테이너를 연결
    - 네트워크 내에서 이 컨테이너를 mysql이라는 별칭으로 참조하도록 함
    - 호스트의 Docker 볼륨인 `mysql-volume`을 컨테이너의 `/var/lib/mysql` 디렉터리에 마운트
3. WAS
    - 이미지 빌드
    - 컨테이너 실행
4. WEB
    - Nginx 컨테이너 실행
5. 스케일링을 위한 명령어 입력
    - 추가 컨테이너 실행 및 Nginx 리로드
