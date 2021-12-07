---
layout: post
categories: programming
image: https://t1.daumcdn.net/cfile/tistory/1272672E4C57E35C05
title: 비주얼 스튜디오에서 pragma message 로 실수 방지 하기
date: 2010-01-13 23:17:00 +0900
---
[Jeffrey Richter의 Windows via C/C++](/essay/2008/12/19/windows-via-cpp.html) 예제 코드에는 공통 헤더파일이 있다.  
이 곳을 살펴보면 유용하게 사용할 수 있을만한 팁들이 많이 있다.  
그 중 가장 쉽고 편하게 쓸 수 있는 기능 하나를 소개하고자 한다.

코드를 작성하다가, '이 부분은 나중에 고쳐야지' 하고 주석으로 마킹해 놓은 뒤에 나중에 잊어버리고 그대로 릴리즈했던 경험이 있는 사람이라면 이 매크로를 좋아하게 될 것이다.

```c++
//// Pragma message helper macro ////
/* 
When the compiler sees a line like this:
   #pragma chMSG(Fix this later)
 
it outputs a line like this:
 
  c:\CD\CmnHdr.h(82):Fix this later
 
You can easily jump directly to this line and 
 examine the surrounding code.
*/

#define chSTR2(x) #x
#define chSTR(x)  chSTR2(x)
#define chMSG(desc) message(__FILE__ "(" chSTR(__LINE__) "):" #desc)
```

주석에 잘 쓰여 있듯이 `pragma` 지시어를 이용해서 코드 어떤 부분에,
```c++
#pragma chMSG(나중에 고칠 것)
int c = a + b;
```


이런 식으로 주석 대신 적어두는 것이다.

이제 빌드를 하게 되면, Output 창에 이 메세지가 나타나게 되므로 실수를 줄일수 있다.  
또한 에러나 경고 메세지처럼 더블 클릭 하게되면 해당 라인으로 바로 이동 된다.  
이것은 `pragma message`의 기능이 아니라 매크로에 파일과 라인수를 비주얼 스튜디오의 Output창이 알아볼 수 있는 형태로 써줬기 때문이다.

이 지시어는 아주 유용하긴 하지만 나는 조금 더 쓰기 편하도록 다음과 같이 매크로로 고쳐서 사용하고 있다.

```c++
#define chSTR2(x) #x
#define chSTR(x)  chSTR2(x)
 
#define chMSG(desc) message(__FILE__ "(" chSTR(__LINE__) "): --------" #desc "--------")
#define chFixLater message(__FILE__ "(" chSTR(__LINE__) "): --------Fix this later--------")
 
#define FixLater \
    do { \
    __pragma(chFixLater) \
    __pragma (warning(push)) \
    __pragma (warning(disable:4127)) \
    } while(0) \
    __pragma (warning(pop))
 
#define MSG(desc) \
    do { \
    __pragma(chMSG(desc)) \
    __pragma (warning(push)) \
    __pragma (warning(disable:4127)) \
    } while(0) \
    __pragma (warning(pop))
```

우선은 코드 중간 중간에 `#pragma`를 쑤셔넣는 것이 보기가 싫었는데, 이 `pragma`를 매크로 안으로 넣어버렸다.  
MSVC에는 `__pragma`라는 키워드를 사용할 수 있는데, 매크로 안에서 `pragma` 지시어을 사용하기 위해 고안되었다.  
만일 예전에 매크로를 만들다가 매크로 안에 `#pragma` 지시어까지 넣을 수 없을까 고민했던 적이 있던 사람에게는 아주 좋은 소식일 것이다.

또 하나는 코드 맨 끝에 세미콜론을 붙여야 컴파일 되도록 강제하였다.  
`#pragma` 지시어는 C문법이 아니므로 세미콜론을 써줄 필요가 없다.  
하지만 코드 중간 중간에 들어갈 매크로인만큼 세미콜론이 없으면 미관상에도 안좋고 복사해서 붙여넣기 등을 할 때 들여쓰기가 깨져버린다.

그래서 보통 매크로를 만들 때는 세미콜론을 붙여야 정상적으로 컴파일 되도록 작성하는 것이 좋다.  
위 매크로에서는 do while 얍삽이를 통해서 세미콜론을 강제하고 있다.  

do while 얍삽이를 쓰게되면, while(0) 때문에 경고가 발생하는데, 이 역시 `__pragma`로 감싸버려서 없앨 수 있다.

마지막으로 앞뒤로 대쉬(-)들을 붙여서 좀 더 눈에 띄기 쉽도록 하였다.

이제 다음과 같이 사용할 수 있다.

```c++
#pragma chMSG(블라블라블라)
int main()
{
    FixLater;
    int a;
 
    MSG(나중에 고칠 것);
    return 0;
}
```

![](https://t1.daumcdn.net/cfile/tistory/1272672E4C57E35C05)