# 'pg'라는 이름의 도커 볼륨 생성
docker volume create pg

# PostgreSQL 데이터베이스 컨테이너 실행
# -d 옵션이 없으므로 foreground 모드로 실행됨 (로그가 터미널에 직접 출력)
# windows 사용자의 경우 최상위 폴더의 "[필독] 윈도우 사용자분들께.txt"를 꼭 읽어주세요!
docker run --name pg --rm \
   --memory="512m" --cpus="0.5" \
   -v pg:/var/lib/postgresql/data \
   -e POSTGRES_PASSWORD=rex postgres
# --name pg: 컨테이너 이름을 'pg'로 설정
# --rm: 컨테이너 종료 시 자동으로 컨테이너 제거
# --memory="512m": 메모리 사용량을 512MB로 제한
# --cpus="0.5": CPU 사용량을 호스트의 50%로 제한
# -v pg:/var/lib/postgresql/data: 'pg' 볼륨을 컨테이너의 PostgreSQL 데이터 경로에 마운트
# -e POSTGRES_PASSWORD=rex: PostgreSQL 관리자 비밀번호를 'rex'로 설정

# 현재 실행 중인 모든 컨테이너 목록 및 상태 확인
docker ps

# 실행 중인 'pg' 컨테이너 내부에 bash 셸 실행
# -it: 대화형 터미널 모드로 실행 (입력과 출력이 가능)
docker exec -it pg bash

# PostgreSQL 서버에 postgres 사용자로 접속
psql -U postgres

# PostgreSQL 클라이언트 종료
exit

# 컨테이너 내 bash 셸 종료
exit

# 실행 중인 모든 컨테이너의 자원 사용량(CPU, 메모리 등) 실시간 모니터링
docker stats

# 볼륨이 현재 실행 중인 컨테이너에 의해 사용 중이므로 삭제 불가
docker volume rm pg

# 'pg' 컨테이너를 강제로 종료하고 제거
# -f: 실행 중인 컨테이너도 강제로 삭제
docker rm -f pg

# 이제 사용 중이지 않은 'pg' 볼륨 삭제
docker volume rm pg
