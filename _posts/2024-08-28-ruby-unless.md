---
layout: post
categories: essay
image: /assets/img/unless_assert.png
title: Ruby의 unless 쉽게 읽기
date: 2024-08-28 11:30:00 +0900
---

Ruby 에는 `unless` 문법이 있습니다.  
`if !current_user`를 `unless current_user`로 쓸 수 있습니다.

간단한 조건에서는 좋은 것 같습니다.  
자연어처럼 읽히거든요.
```ruby
return unless user_logged_in # 깔끔
```

그런데 조건이 여러 개 있는 경우에는?
```ruby
unless file.exist? && file.owner == current_user && permission != :readonly
  # do something
end
```


하, 머리가 팽팽 돕니다.  
어떤 개새가 이렇게 코드를 써놨어?  
`unless` 로 복잡한 조건을 적은 코드를 볼 때마다 `if` 로 고치곤 했습니다.

어느 날, 같이 일하던 동생에게 흥미로운 조언을 들었습니다.  
> `unless`를 `assert` 처럼 생각하고 읽으면 좋아요.

아래 코드 처럼 생각하면 좋다는 것이었습니다.
```ruby
assert(file.exist? && file.owner == current_user && permission != :readonly)
```
즉, 반드시 파일이 존재해야 하고,  
소유자는 현재 사용자이며,  
읽기 전용이 아니어야 다음 코드로 진행할 수 있다.

함수 시작부에 `assert` 를 쓰듯이 `unless`를 비슷한 용도로 쓰면 읽기가 오히려 편한 경우가 있다고.  

```ruby
raise FileNotExist unless file.exist?
raise AccessDenied unless file.owner == current_user && permission != :readonly
```

오 뭐야? 좋은데?  
낯설음을 뒤로하고 저는 이걸 받아들였습니다.  
더 이상 `unless`를 `if` 로 고치지 않고 적절히 섞어 쓰게 됐습니다.

오늘도 이런 `unless` 코드를 쓰다가 조언해 준 동생 생각이 났습니다.  
알려줘서 고맙다.😁

P.S. 하지만... 알려줬던 동생은 이젠 전혀 기억도 못하는 것 같습니다.

![얼간의 동생과의 카톡 대화](/assets/img/unless_assert.png)

<br>
*함께 읽으면 좋은 글:*
* [Ruby는 프로그래머를 위한 선물](/essay/2022/02/18/ruby.html)
* [루비가 느리다고?](/essay/2023/01/04/dont-say-ruby-is-slow.html)

