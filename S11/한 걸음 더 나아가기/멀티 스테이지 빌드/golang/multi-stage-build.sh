# 각각의 이미지가 빌드되고, 결국 release-stage만 최종 이미지가 됨
# build-stage / run-test-stage / release-stage

# 단일 스테이지 빌드
docker build -t no-multistage .

# 빌드한 단일 스테이지 이미지 실행, 포트 바인딩
docker run --rm -p 8080:8080 no-multistage

# Dockerfile.multistage 파일로 run-test-stage라는 특정 스테이지까지만 빌드
docker build -t test -f Dockerfile.multistage --no-cache --progress plain --target run-test-stage .

# Dockerfile.multistage 파일을 사용하여 모든 스테이지를 빌드하고 최종 이미지를 생성
docker build -t multistage -f Dockerfile.multistage .

# 멀티스테이지 빌드로 생성된 최종 이미지를 실행
docker run -p 8080:8080 --rm multistage