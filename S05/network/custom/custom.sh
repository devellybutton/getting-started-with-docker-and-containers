# rex라는 이름의 커스텀 네트워크 생성
docker network create rex

docker run --rm -it --name b1 --network rex busybox sh
docker run --rm -it --name b2 --network rex busybox sh

ping b1
ping b2

exit

##### --network-alias #####
docker run --rm -d --name b1 --network rex --network-alias bb busybox sleep infinite
docker run --rm -d --name b2 --network rex --network-alias bb busybox sleep infinite
docker run --rm -d --name b3 --network rex --network-alias bb busybox sleep infinite

### ngnix (reverse proxy)

# dnsname, alias 살펴보기
docker inspect b1

docker run --rm -it --name b3 --network rex busybox sh

# 삭제 
docker rm -f $(docker ps -a -q)  # 모든 컨테이너(실행 중 + 중지된)의 ID
docker network rm rex  # rex 네트워크를 삭제