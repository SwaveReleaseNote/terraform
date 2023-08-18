kic terraform 

![제목 없는 다이어그램 drawio-1 복사본 2](https://github.com/SwaveReleaseNote/terraform/assets/54500840/251138c2-d5fb-439b-8281-cd72dea8075b)

미리 생성된 KIC의 클라우드 서브넷 일부와 kubenetes engine의 클러스터 내 인스턴스와 연결한  
클라우드 인프라를 코드로써 제어 할 수 있습니다.

Openstack provider의 spec을 따르고 있으며 작성하는데 사용한 KIC 기준 kubenetes engine 제어를 위한  
모듈을 따로 제공하지 않고 있어 제어가 불가능 하기 때문에 미리 생성해 인스턴스의 id를 입력할 필요가 있습니다.

> 실습 환경에서 서브넷 두개와 VPC는 미리 생성되어 할당을 받아 그 위에서 사용해야 했기 때문에 현재는  
> 변수에 해당 cidr 값을 넣고 data로써 값을 받아오게 되어 있습니다. 처음부터 시작하실 경우 resource 타입으로 직접 선언해 주십시오.

bastion host를 자동으로 생성하며 기존 kubenetes engine의 인스턴스에 동적으로 ssh 프록싱을 설정합니다.  
30000 - 30004 포트는 kubenetes engine의 인스턴스의 30000 - 30004 포트에 프록싱합니다.  
필요한 일부 보안 그룹의 포트 만을 개방합니다.  

object storage에 미리 업로드한 kubenetes engine 인증용 파일들과 ssh key를 이용하면  
bastion host에서 ansible을 이용한 kubenetes engine 인스턴스의 일괄 설정과 제어가 가능합니다.  

helm을 설치해 kubenetes engine 내부에 우리누리 시스템을 또한 한번에 배포합니다.

한번의 실행으로 세세한 설정을 제외한 아키텍쳐 전반의 배포가 가능합니다.

** 모든 원할한 실행을 위해 kubenetes engine 인스턴스의 사전 설정이 필요할 수 있습니다.
