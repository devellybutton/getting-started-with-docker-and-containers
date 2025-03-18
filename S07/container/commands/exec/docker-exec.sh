# 무한히 sleep 상태
docker run -d --name busybox busybox sleep infinite

# 실행 중인 컨테이너에 접속 (대화형 터미널)
docker exec -it busybox sh

# 컨테이너 내부에서 프로세스 목록 확인
# 실제로 sh 프로세스가 하나 추가되어 있음
ps

# 컨테이너 내부 셸 종료
exit

# 외부에서 컨테이너 프로세스 확인
docker exec busybox ps

# 컨테이너 강제 삭제
docker rm -f busybox