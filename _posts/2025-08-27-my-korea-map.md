---
layout: post
categories: essay
image: /assets/img/mykoreamap.jpg
title: 내가 가본 우리나라 앱 개발 뒷 이야기
date: 2025-08-27 00:59:00 +0900
---

며칠 전 공개했던 [내가 가본 우리나라](/essay/2025/08/01/my-korea-map.html) 웹사이트를 앱으로도 만들어봤습니다.  
[안드로이드](https://play.google.com/store/apps/details?id=com.my.koreamap&hl=ko), [아이폰](https://apps.apple.com/kr/app/id6749817480) 그리고 맥 앱까지. (맥은 아직 심사 중이에요)

간단한 아이디어였고 제가 쓰고 싶은 마음에 만들기도 했지만,  
레일즈 8을 좀 더 알아보고자 하는 마음.  
제 기술 스택을 정돈해 보고 싶은 마음이 있었어요.

루비 온 레일즈, Vue.js, React  
SwiftUI, 플러터, React Native, Universal Windows Platform 

계속 이렇게 공부만 하면서 왔다 갔다 해야 하나?  
좀 잘 정리해서 내 주력 스택을 확정시킬 순 없을까?

루비 온 레일즈 8의 기본 기능을 최대한 활용해 보고 싶었습니다.
* Hotwire, Stimulus, Turbo, importmap을 통한 외부 종속성 없는 자바스크립트 환경.
* Kamal 을 통한 배포.
* Solid Queue를 통한 백그라운드 작업.
* Solid Cache 캐싱.
* sqlite와 홈서버로 프로덕션 환경 운영해 보기.
* ~~Hotwire Native를 통한 모바일 앱 개발까지.~~

웹사이트를 다 만들고 나서 아주 홀가분했습니다. Hotwire에 대해 거의 아는 게 없었지만 AI 덕분에 수월했어요.  
React 같은 걸 쓸 필요가 있나? 하는 생각을 많이 했습니다. Webpack이나 Vite 같은 피곤한 도구들 안 봐도 되는 것도 정말 좋았고요.

모바일 앱을 만들기 위해 [Hotwire Native](https://native.hotwired.dev/)와 이틀 정도 씨름하다가...  
이건 도저히 안 되겠다. 더러워서 못 해먹겠다 하고 포기했습니다.

결국 플러터를 선택해서 안드로이드, 아이폰, 맥 앱을 만들었습니다.  
총 코드는 90% 정도가 레일즈이고 10% 정도가 플러터.

클로드 코드로만 작업했고, 제가 직접 코드에 관여한 부분은 없었던 것 같아요.  
클로드 코드를 사용할 때는 [여러 작업을 병렬로 안 하고 최대한 순차적으로](/essay/2025/07/23/context-swiching.html) 진행하려고 노력했습니다.  
다른 프로젝트도 신경 쓰지 않고요. 안 그러면 제 머리가 따라갈 수 없어서.    
여담이지만 저는 클로드 코드에 mcp도 하나도 연결하지 않았고, 남들이 만든 agents.md 같은 것들도 잘 보지 않습니다. 노땅이 다 된 것 같아요.

규모가 작은 앱이긴 하지만, 이번 작업으로 이 스택에 자신감이 생겼습니다.  
앞으로도 새로운 서비스 만들 땐 이렇게 만들지 않을까 싶습니다. 😁
<br>
<br>
*함께 읽으면 좋은 글:*
* [루비가 느리다고?](/essay/2023/01/04/dont-say-ruby-is-slow.html)
* [집에서 서버를 운영하는 게 가능한가요?](/essay/2024/04/29/home-server.html)
* [진짜 1인 개발자 전성시대](/essay/2025/08/11/solo-developer.html)