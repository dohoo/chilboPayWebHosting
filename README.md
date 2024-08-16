# 칠보페이

칠보페이 앱 

## 꼭 알아야 하는 부분

lib 하위 폴더에서 만드시면 됩니다. lib 폴더 코드 쭉 읽어 보시고 이해한 후에 만드는 게 좋을 듯. 
처음에는 어려울 수 있으니까 꼭 구글링 하거나 ChatGPT한테 물어보면서 하세요. 

[디자인 참고](https://www.figma.com/design/QWbpSQLCdQjO8MkyKMABvK/%EC%B9%A0%EB%B3%B4%ED%8E%98%EC%9D%B4?node-id=0-1&t=gRFwPyncdcnqWXIV-0) 아직 미완

웬만하면 import 부분은 수정 안 하는게 좋아요. 만약 수정을 하고 싶다면 폴더 경로 잘 설정하시길 바랍니다. 

## 안드로이드 스튜디오에서 깃허브 사용 방법

- [깃, 깃허브 사용법 참고](https://sseozytank.tistory.com/41)
- [깃허브 For 플러터 참고](https://velog.io/@tlsgks48/GitHub-%EA%B9%83%ED%97%88%EB%B8%8C-Repository%EC%97%90-%EC%BD%94%EB%93%9C-%EC%98%AC%EB%A6%AC%EA%B8%B0-%EB%B0%8F-%EA%B0%80%EC%A0%B8%EC%98%A4%EA%B8%B0)

각자 브랜치 만들어서 거기에다 올려주세요. 예를들어, test 브랜치를 새로 만들어서 test 브랜치에만 push 하면 됩니다.
push 할 때는 무엇을 어떻게 수정했는지, 뭘 추가했는지 메시지를 구체적으로 써서 올려주세요.

## 서버 

서버는 라즈베리파이로 운영 중입니다. 
밑에 링크들은 서버 구조를 이해하기 위해 필요한 지식들이니까 읽어보세요.

chilbopay.com 도메인 사용중

- [api, api서버란?](https://maily.so/grabnews/posts/b2341a)
- [Node.js란?](https://velog.io/@remon/%EA%B0%9C%EB%B0%9C-%EA%B8%B0%EB%B3%B8-%EC%A7%80%EC%8B%9D-Node.js%EB%9E%80)
- [express란?](https://velog.io/@jwo0o0/Node.js-%ED%94%84%EB%A0%88%EC%9E%84%EC%9B%8C%ED%81%AC-Express-%EC%8B%9C%EC%9E%91%ED%95%98%EA%B8%B0-middleware)
- [http, https란?](https://mangkyu.tistory.com/98)
- [포트란?](https://ittrue.tistory.com/185)
- [DB란?](https://hongong.hanbit.co.kr/%EB%8D%B0%EC%9D%B4%ED%84%B0%EB%B2%A0%EC%9D%B4%EC%8A%A4-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0-databasedb-dbms-sql%EC%9D%98-%EA%B0%9C%EB%85%90/) 우리 서버는 mysql을 사용합니다.
- [mysql 사용법](https://velog.io/@ryong9rrr/mySQL-%EA%B8%B0%EB%B3%B8-%EC%82%AC%EC%9A%A9%EB%B2%95-%EC%A0%95%EB%A6%AC%EC%98%88%EC%A0%9C)
- [sql인젝션이란?](https://noirstar.tistory.com/264)
- [jwt란?](https://velog.io/@vamos_eon/JWT%EB%9E%80-%EB%AC%B4%EC%97%87%EC%9D%B8%EA%B0%80-%EA%B7%B8%EB%A6%AC%EA%B3%A0-%EC%96%B4%EB%96%BB%EA%B2%8C-%EC%82%AC%EC%9A%A9%ED%95%98%EB%8A%94%EA%B0%80-1)
- [bcrypt란?](https://velog.io/@sangmin7648/Bcrypt%EB%9E%80)

[서버 코드](https://github.com/dohoo/payWeb/tree/app) 서버쪽 코드인데 일단 api 서버로 사용중.
