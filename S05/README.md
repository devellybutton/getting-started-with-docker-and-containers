# 섹션 5. 네트워크

- [도커 기본 네트워크와 문제점](#도커-기본-네트워크와-문제점)
- [커스텀 네트워크 생성 및 활용](#커스텀-네트워크-생성-및-활용)

---

## 도커 기본 네트워크와 문제점

![Image](https://github.com/user-attachments/assets/bdd8a427-0d65-4dcd-a268-5f79137ce407)

### 1. Docker 네트워크 개요
#### Docker의 기본 네트워크 인터페이스
- `eth0` (컨테이너 내부 네트워크 인터페이스)
- `docker0` (호스트 시스템의 Docker 브리지 네트워크)

#### 기본 네트워크 구성의 문제점
- <b>컨테이너 이름</b>으로 네트워크 접근 <b>불가능</b>
- 172.17.0.5와 같은 IP 주소로만 접근 가능

#### 네트워크 연결 방법
- `--link` 옵션 사용: `docker run -d -P --link pg web`
    - 이 방식은 legacy 방식으로 향후 사라질 예정
- 사용자 정의 네트워크 생성: `docker create network {이름}`
    - 권장되는 방법

### 2. default.sh 해석

#### 첫 번째 실습
- 기본 네트워크에서의 동작
    - 두 개의 busybox 컨테이너(b1, b2)를 실행
    - 각 컨테이너의 IP 확인 (ifconfig eth0)
    - 컨테이너 간 ping 테스트
        - 이름으로 ping 시도 → 실패
        - IP로 ping 시도 → 성공
- 두 번째 실습은 `--link` 옵션 사용
    - b1 컨테이너 실행
    - b2 컨테이너를 b1에 링크하여 실행
    - 이름으로 ping 테스트 → b1으로의 ping이 성공할 것으로 예상
- Docker 네트워크를 더 효과적으로 관리하려면 사용자 정의 네트워크를 만들고 컨테이너들을 해당 네트워크에 연결하는 방식이 권장됨.
![Image](https://github.com/user-attachments/assets/53ccbe14-2070-419c-9d5d-0fdb5a502302)

---

## 커스텀 네트워크 생성 및 활용

