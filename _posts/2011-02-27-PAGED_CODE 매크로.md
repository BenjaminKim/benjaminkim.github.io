---
layout: post
categories: essay
image: /assets/img/jeho.jpg
title: PAGED_CODE 매크로
date: 2011-02-27 19:09:00 +0900
---

[PAGED_CODE](https://docs.microsoft.com/en-us/windows-hardware/drivers/kernel/paged_code) 는 다음과 같이 생긴 간단한 매크로이다.

```c++
#define PAGED_CODE() { \
  if (KeGetCurrentIrql() > APC_LEVEL) { \
    KdPrint(("EX: Pageable code called at IRQL %d\n", KeGetCurrentIrql())); \
      PAGED_ASSERT(FALSE); \
  } \
}
```

현재 IRQL을 체크해보고 IRQL이 APC_LEVEL 보다 높다면 시스템을 종료시킨다.

디바이스 드라이버는 유저 모드 프로그램들과는 다르게 텍스트 영역이 페이지 파일로 빠져나가지 않도록 설정된다.  
즉, 코드가 [기본적으로 nonpaged 영역에 할당](https://docs.microsoft.com/en-us/windows-hardware/drivers/kernel/making-drivers-pageable?redirectedfrom=MSDN)된다.

물론 드라이버 프로그래머에게는 이를 제어할 수 있는 방법 또한 주어지며 코드나 데이터를 페이징 가능하도록 설정 할 수도 있다.  
`#pragma alloc_text`나 `#pragma data_seg` 디렉티브를 사용하면 컴파일 타임에 코드나 데이터들에 대한 페이징 여부를 결정할 수 있다.

드라이버 내의 특정 함수들을 페이징 가능하게 만들고 싶다면 다음처럼 쓴다.

```c++
#pragma alloc_text(PAGE, functionName)
```

이 구문은 해당 함수의 선언보다는 아래에 있어야 하고 정의보다는 위에 있어야 한다.  
보통 c 모듈에서 헤더들을 include 한 뒤 그 바로 아래에 쓴다.

`#pragma alloc_text` 는 코드가 올라갈 섹션을 지정하는데, 섹션이란 PE 파일이 가지고 있는 바로 그 섹션을 말한다.  
위와 같이 쓰면 해당 PE파일에 `PAGE`라는 이름의 섹션이 새로 추가된다.  
그리고 I/O 매니저는 드라이버 이미지를 로드할 때 이미지 내의 섹션 이름 중 앞의 4글자가 `PAGE` 또는 `.EDA` 가 있는지 찾아보고 있다면 해당 섹션을 paged pool에 넣어버린다.  
이제 해당 코드는 시스템에 의해서 **필요없을 땐 언제라도 페이지 파일로 빠져나갈 수** 있다.

디바이스 드라이버의 세계에서 중요한 규칙중 하나는 IRQL이 Dispatch 레벨 이상일 때는 페이지 폴트가 일어나서는 안된다는 것이다.  
`IRQL >= DISPATCH_LEVEL` 일 때 페이지 폴트가 일어나게 되면(페이지 폴트 뿐만아니라 다른 어떤 소프트웨어 예외라도 일어나게되면) 시스템은 크래시된다.

위 규칙을 알고 나면 `#pragma alloc_text`를 이용해서 코드를 페이징 가능하게 만들었을 경우에, IRQL이 DISPATCH_LEVEL 이상인 상태에서 해당 함수가 불릴 경우 페이지 폴트가 발생해서 블루스크린이 발생할 수도 있다는 것을 알 수 있다.  
따라서 IRQL이 높을 때 불릴 수 있는 함수들은 paged pool에 할당해서는 안된다.  
그런데 운이 좋아서 해당 시점에 코드가 램에 잘 존재하고 있어서 페이지 폴트가 일어나지 않는다면?  
이는 버그를 감추어주게 되고 나중에 더 골치아픈 문제를 가져다준다.

페이징 가능한 함수들에 `PAGED_CODE` 매크로를 사용하면 이런 운에 의해 감추어지는 버그들을 없애 버리고 곧장 시스템을 크래시 시켜 버림으로서 문제가 있는 부분을 쉽게 찾아낼 수 있다.  
그래서 페이징 가능한 모든 코드에는 함수의 시작부에 `PAGED_CODE()` 매크로를 사용하는 것이다.

위에서 말한 내용들이 너무 복잡하다면 다음 규칙만 외워서 따라해도 좋다.

> `#pragma alloc_text`를 사용했다면 짝이 맞는 함수를 찾아가 시작부분에 `PAGED_CODE` 매크로를 써준다.

이 둘을 항상 짝으로 같이 다니게 하면 된다.(둘다 있거나 둘다 없거나)

여기까지 읽었으면,  

> "빌어먹을, 코드이든 데이터이든간에 무조건 nonpaged pool에 할당하는게 편한 것 아닌가?"

하는 생각이 들 것이다.  
물론 그렇게 하면 프로그래머는 좀 더 편해지겠지만, 오랫 동안 사용되지 않고 있는 코드와 데이터들이 메모리에서 내려가지 않기 때문에 시스템의 성능을 떨어뜨린다.
<br>
<br>
*비슷한 글:*
* [윈도우 디바이스 드라이버 프로그래밍 기초](/programming/2011/05/23/윈도우에서-디바이스-드라이버를-만들-때-알아야-할-기초적인-내용들.html)
* [FIELD_OFFSET 매크로](/programming/2011/03/01/FIELD_OFFSET-매크로.html)
* [_countof 매크로](/essay/2011/03/15/_countof-매크로.html)