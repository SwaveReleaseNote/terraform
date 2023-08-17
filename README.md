kic terraform 

미리 생성된 KIC의 클라우드 서브넷 일부와 kubenetes engine의 클러스터 내 인스턴스와 연결한
클라우드 인프라를 코드로써 제어 할 수 있습니다.

배스쳔 호스트를 자동으로 생성하며 기존 kubenetes engine의 인스턴스에 동적으로 ssh 프록싱을 설정합니다.
30000 - 30004 포트는 kubenetes engine의 인스턴스의 30000 - 30004 포트애 프록싱합니다.
필요한 일부의 포트의 보안 그룹만을 개방합니다.

object storage에 미리 업로드한 kubenetes engine 인증용 파일들과 ssh key를 이용하면
ansible을 이용한 kubenetes engine의 인스턴스의 일괄 설정이 가능합니다.

helm을 설치해 kubenetes engine 내부에 우리누리 시스템을 또한 한번에 배포합니다.

한번의 실행으로 세세한 설정을 제외한 아키텍쳐 전반의 배포가 가능합니다.

** 모든 원할한 실행을 위해 사전 설정이 필요할 수 있습니다.
