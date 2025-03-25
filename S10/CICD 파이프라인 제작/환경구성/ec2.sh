# 꼭 ec2-user로 접근!
ssh -i docker-cicd-test.pem ec2-user@퍼블릭 ipv4 도메인

# docker compose 형태로 명령 실행가능하도록 설정
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
ln -s /usr/local/bin/docker-compose $DOCKER_CONFIG/cli-plugins/docker-compose