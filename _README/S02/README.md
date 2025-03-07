# nginx

![Image](https://github.com/user-attachments/assets/cad77b24-4f1c-4696-8c03-04e746a9335d)

### 실제 작동 과정
1. 웹 브라우저나 curl 같은 클라이언트가 `http://localhost:8080`으로 접속
2. 호스트 컴퓨터의 8080 포트로 들어온 요청을 Docker가 가로채서 컨테이너 내부의 80 포트로 전달함.
3. 컨테이너 안에서 실행 중인 nginx 웹 서버가 80 포트에서 요청을 받아 처리함.

### 명령어 정리
```
docker run --rm -d -p 8080:80 nginx
```
- `docker run`: 새 컨테이너를 생성하고 실행
- `--rm`: 컨테이너가 종료될 때 자동으로 컨테이너를 삭제
- `-d`: 백그라운드에서 컨테이너 실행 (detached 모드)
- `-p 8080:80`: 호스트의 8080 포트를 컨테이너의 80 포트에 연결
    - 왼쪽 숫자 `8080`: 호스트 컴퓨터에서 사용할 포트 번호
    - 오른쪽 숫자 `80`: 컨테이너 내부에서 사용하는 포트 번호
- `nginx`: 사용할 도커 이미지 이름

```
curl http://localhost:8080
```
- 로컬호스트의 8080 포트에 HTTP 요청을 보내 응답을 확인

```
docker ps
```
- 현재 실행 중인 컨테이너 목록 표시

```
docker rm -f [CONTAINER_ID 또는 CONTAINER_NAME]
```
- 컨테이너를 강제로 삭제
- `-f`: 실행 중인 컨테이너도 강제로 중지하고 삭제

### 컨테이너 ID/이름 관련 팁
- 부분 ID 사용 : 컨테이너 ID의 처음 몇 글자만 사용해도 충분함 (충돌이 없을 경우)
    ```
    # 전체 ID가 abc123def456...인 경우
    docker rm -f abc12  
    ```

- 탭 키로 자동완성
    ```
    # nginx로 시작하는 컨테이너 이름 자동완성
    docker rm -f ngi[TAB] 
    ```

- 컨테이너 생성 시 --name 옵션으로 기억하기 쉬운 이름을 지정
    ```
    docker run --rm -d -p 8080:80 --name webserver nginx
    docker rm -f webserver
    ```

- 여러 컨테이너 한번에 삭제: 공백으로 구분하여 여러 컨테이너 ID/이름을 지정
    ```
    docker rm -f container1 container2 container3
    ```

- 명령어 조합: docker ps 결과를 파이프라인으로 연결해 자동 처리
    ```
    # nginx 이름을 포함한 모든 컨테이너 삭제
    docker rm -f $(docker ps -q -f name=nginx)  
    ```

![Image](https://github.com/user-attachments/assets/713270ff-4cad-42a2-8f6e-7850781c99ae)

### 실제 작동 과정
- Docker의 주요 장점 중 하나가 바로 이 격리성
- 컨테이너 1의 NGINX 서버와 컨테이너 2의 NGINX 서버는 서로 완전히 독립적임.
    - 각 컨테이너 내부에서는 표준 포트(80)를 그대로 사용할 수 있음.
    - 외부에서는 호스트의 다른 포트(8080, 8081)를 통해 각각의 컨테이너에 접근함.
- 그래서 `docker run --rm -d -p 8080:80 nginx`와 `docker run --rm -d -p 8081:80 nginx`를 실행하면 두 개의 서로 다른 NGINX 컨테이너가 생성되고, 둘 다 각자의 80번 포트에서 웹 서버를 실행하지만 서로에게 영향을 주지 않음.

---

# PostgreSQL

---

# httpd

---

# node