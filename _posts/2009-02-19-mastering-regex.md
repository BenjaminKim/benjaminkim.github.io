---
layout: post
categories: essay
image: https://www.hanbit.co.kr/data/books/B6347501827_l.jpg
title: 정규 표현식에 익숙해지기
date: 2009-02-19 20:08:00 +0900
---

![정규 표현식 완전 해부와 실습](https://www.hanbit.co.kr/data/books/B6347501827_l.jpg)  
*정규 표현식 완전 해부와 실습 - 서환수 역*

최근 한 달여 동안 침대에서 이 책을 읽으며 잠이들곤 했다.  
이 책은 정규표현식을 다루는 최고의 책이다.

인터넷을 둘러보다 보면 정규 표현식을 설명하는 많은 문서들에서 언제나 빠짐없이 등장하는 단 한권의 책이다.  
거의 모든 문서들에서 많은 정규식 책들 중 오직 이 책만을 추천하고 있을 정도로 이 책의 위상은 독보적이다.

이 책은 3판(2006)까지 나와있는데, 우리말로 되어있는 것은 2판(2002)이다.  
이 책의 저자는 정규 표현식 분야의 권위자이며, 실제로 정규 표현식의 발전에 많은 기여를 했다.

다음은 이 책(2판)의 목차이다. -3판에는 PHP가 추가되어있다.

* 1장. 정규 표현식 소개
* 2장. 기초 예제
* 3장. 정규 표현식의 기능과 종류
* 4장. 정규 표현식 처리 원리
* 5장. 실용 정규 표현식 기법
* 6장. 효율적인 정규 표현식 사용
* 7장. 펄
* 8장. 자바
* 9장. 닷넷

정규식을 처음 접하는 사람이 이 책의 1장과 2장을 보고 나면,
> "이제 나는 정규 표현식의 달인이야. 이제 이 책은 더 이상 안봐도 되겠어. 나머지는 실전으로 익히자."  

라는 생각에 사로잡히게 될지도 모른다.  
나는 실제로 그랬는데 아마 저자는 이미 그런 마음을 잘 알고 있었나보다.  
부디 책을 끝까지 정독하라는 충고를 곳곳에서 해주지 않았더라면 나는 분명히 이 책을 다 읽지 않았을 것이다.

그럼 이렇게 배워둔 정규 표현식을 어디에 써먹을 것인가?

정규식을 써야하는 곳은 수도 없이 많다. 아는만큼 보인다는 말이있다.  
심지어 이 책의 저자는 책의 오류를 찾기 위해 정규식을 사용하기도 했는데 이것은 정규식을 모르는 사람들은 상상도 할 수 없는 기발한 생각이다.

이런 유틸리티 목적만으로도 우리의 삶을 충분히 편하게 해주지만 우리는 프로그램에서도 멋진 식들을 활용해보길 원한다.

프로그래밍 코드에서 정규식을 사용해야하는 가장 잦은 부분, 그리고 중요한 부분은 아마도 입력값 검증일 것이다.

[Writing Secure Code](https://benjaminlog.tistory.com/entry/writingsecurecode)에서 [마이클 하워드](https://docs.microsoft.com/en-us/archive/blogs/michael_howard/)는 입력값 검증의 중요성을 무던히도 강조하는데,
그는 항상 모든 입력값을 정규식으로 완벽하게 체크하는 좋은 습관을 보여주었다.

이 책에서 저자는 정규식을 테스트 하기위해 perl 과 egrep을 많이 사용하는데,
내가 좋아하는 툴은 바로 vim이다.

나는 그동안 vim에서 정규식으로 매치를 해보고 치환을 할 때, 매치했던 표현식을 다시 재사용하는 방법을 몰라서 다시 힘들게 타이핑 하곤했는데 오늘 KLDP에서 좋은 답변을 얻었다.

> vim에서 정규식으로 문자열을 치환하기 위해
>
> /^some[regular]expression(.*)$ 와 같은 식을 만들어 먼저 원하는 문자열이 잘 매치되는지 확인을 해봅니다.
>
> 이제 :%s/the expression/replace string/g 를 통해 문자열을 바꾸고 싶은데,
> 위에서 썼던 식을 복사하고 붙여넣는 방법을 몰라서 다시 머리를 싸매며 타이핑하곤 합니다.
>
> 간단하게 할 수 있는 방법이 있습니까?

```vim
:%s//replace string/g
```

이 책은 번역이 아주 잘되어 있고 꽤나 신경을 써서 만들어진 흔적이 엿보인다.  
단지 흠이 있다면 몇몇 정규표현식에서의 오타와 예제 문자열들에서 있어야할 밑줄이 상당수 빠져있는 것인데 내용을 이해하는데 있어서 그렇게 불편한 정도는 아니다.

이런 부분들의 교정과 함께 3판 또한 출간된다면 나는 아주 기쁠 것 같다.