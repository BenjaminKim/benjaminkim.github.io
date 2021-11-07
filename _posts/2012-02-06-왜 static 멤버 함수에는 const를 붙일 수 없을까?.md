---
layout: post
categories: programming
image: /assets/img/jeho.jpg
---
C++에서는 멤버 함수에 const 키워드를 사용할 수 있다.  
이는 메서드 내에서 멤버 변수들의 값을 바꾸지 않겠다는 약속이다.

```c++
void Clazz::foo() const
{
}
```

위의 `const` 변경자는 해당 인스턴스의 `this` 포인터에 영향을 끼치게 된다.  
즉 멤버 함수 내에서 `this` 포인터의 타입은 `const Clazz*` 가 된다.  
그러므로 해당 멤버 함수 내에서 멤버 변수의 값을 바꾸려고 하면 컴파일 에러가 발생한다.

```c++
static void Clazz::boo() const
{
}
```

하지만 `static` 멤버 함수에 대해 `const`를 붙일 경우에는 컴파일 에러가 발생한다.  
그 이유는 `static` 멤버 함수는 `this` 포인터를 가지고 있지 않기 때문이다.  
`this`가 없는데 어떻게 `this`를 `const`로 만들겠는가.