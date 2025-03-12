# 8080 포트 사용중인 컨테이너 없는지 확인
docker ps

# 현재경로(.)를 기준으로 Dockerfile에 명시된 명렁을 실행해 web 이라는 이름의 이미지 생성
docker build -t web .

# 로컬에 저장된 모든 Docker 이미지 목록 확인
# docker image ls와 동일
docker images

# 백그라운드로 도커 실행,
# 종료 시 자동 삭제,
# 포트 매핑 설정
# --name web web (컨테이너 이름 / 이미지 이름)
docker run -d --rm -p 8080:5000 --name web web

# 컨테이너 강제 종료
docker rm -f web

# 재밌는 장난 해보기
# --memory="10m": 컨테이너가 사용할 수 있는 메모리를 10MB로 제한
# --rm 옵션이 없으면 컨테이너가 종료되어도 끝까지 삭제되지 않음
docker run -p 8080:5000 --memory="10m" --name web web

# 실행 중인(running) 컨테이너 목록에 보이지 않음
docker ps

# 모든 상태를 보여주는(-a) 목록에 보임
# 실행 중이 아닌 컨테이너를 포함한 모든 컨테이너 목록 표시
docker ps -a

# 컨테이너에 대한 자세한(inspect) 정보 보기
docker inspect web

docker rm -f web
