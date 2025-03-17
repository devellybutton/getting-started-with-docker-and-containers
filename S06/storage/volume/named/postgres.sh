docker volume create pg

docker run --name pg --rm -d \
    -v pg:/var/lib/postgresql/data \
    -e POSTGRES_PASSWORD=rex postgres

docker volume inspect pg

# Named Volume은 -v 옵션으로 삭제 불가
docker rm -f -v pg

# 네임드 볼륨은 삭제되지 않은 걸 확인할 수 있음
docker volume ls 

# 네임드 볼륨 삭제
docker volume rm pg
