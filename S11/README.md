# 섹션 11. 한 걸음 더 나아가기

## 멀티 스테이지 빌드란?
- Dockerfile 내에서 <b>여러 개의 FROM 명령</b>을 사용하여 각 빌드 단계를 분리하고, 최종 이미지에는 필요한 결과물만 복사하는 Docker 빌드 기법
    - `FROM`: Docker 이미지의 기반이 되는 베이스 이미지를 지정하는 지시어
    - 멀티 스테이지 빌드에서는 각 FROM이 독립적인 빌드환경(스테이지)를 생성
- 장점: 이미지 크기 감소, 보안 강화, 빌드 의존성 분리 등

### 예시
-  컴파일 언어들은 멀티 스테이지 빌드가 효과적임
- 빌드 과정에서 컴파일러, 개발 도구, 헤더 파일, 소스 코드 등이 필요하지만, 실행 시에는 컴파일된 바이너리 파일만 있으면 되기 때문임

### 멀티 스테이지 빌드 동작 방식
1. 기본적으로 가장 아래 있는 FROM을 기준으로 동작함
    - 마지막 스테이지를 실행하는데 필요한 스테이지들만 빌드 수행
    - 다만, 옛날 버전 사용 시에는 모든 스테이지가 빌드됨 (docker 23 버전 이후는 문제 없음)
2. 명시적으로 특정 스테이지를 실행시키려면, 아래 형태로 실행 필요
    ```
    docker build -t rex --target [스테이지명] . 
    ```

### 실습 과정
#### 단일 스테이지 빌드
![Image](https://github.com/user-attachments/assets/fa1e35da-b779-4724-862e-95453831653b)
![Image](https://github.com/user-attachments/assets/56a40888-c3f4-423a-897b-27f04775067e)

#### run-test-stage 까지 빌드
![Image](https://github.com/user-attachments/assets/0cf3aa76-17d5-4796-8f15-e1a80645cede)

## distroless

### RUN rm -rf 문제점
- `RUN rm -rf` 명령어를 사용해도 도커 이미지는 불변하기 때문에 파일이 실제로 제거되지 않음.
- 도커 이미지는 여러 레이어로 구성되며, 각 레이어는 이전 레이어 위에 추가됨. `RUN rm -rf` 명령어로 파일을 삭제하더라도, 새 레이어에 파일 삭제 정보 추가. 원본 파일은 이전 레이어에 존재함

### Distroless 이미지란?
- Google에서 개발한 최소화된 컨테이너 이미지
- 애플리케이션과 그 런타임 종속성만 포함 (쉘, 패키지 관리자 등 제외)
- 불필요한 도구(rm, ls, bash 등)가 처음부터 없음

![Image](https://github.com/user-attachments/assets/7d8a7048-a1ed-412f-905c-98543b0aa1ed)

![Image](https://github.com/user-attachments/assets/77625843-cac0-4102-8db1-b9c48b7e1353)

#### distroless에 쉘이 없는데 그럼 디버깅 할 때 컨테이너 내부에는 어떻게 접속함?
- `:debug`태그가 붙은 버전의 이미지는 busybox가 포함되어 있어서 기본 쉘 명령어로 컨테이너에 접속 가능 

    ![Image](https://github.com/user-attachments/assets/a398b0b9-7354-43e8-bf52-2a91b1f84361)