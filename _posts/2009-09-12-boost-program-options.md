---
layout: post
categories: programming
image: /assets/img/jeho.jpg
title: boost 라이브러리로 커맨드 라인 파싱 쉽게 하기
date: 2009-09-12 17:40:00 +0900
---

콘솔 프로그램을 작성하다보면 커맨드라인 인터페이스를 제공해야 하는 경우가 종종 있다.  
옵션이 몇 개 없다면 대충 파싱해서 처리하면 그만이지만 그 수가 10개가 넘어가고 순서도 유연하게 입력받을 수 있게 하고 싶다면 [boost](https://www.boost.org/)를 사용해보는 것도 좋다.

`boost`에는 [program_options](https://www.boost.org/doc/libs/1_76_0/doc/html/program_options/tutorial.html)이라는 라이브러리가 포함되어 있는데, 우리가 리눅스에서 콘솔 프로그램에 옵션을 입력하는 것과 동일한 방법으로 사용할 수 있도록 하는 기능을 제공해준다.

다음은 간단한 코드와 사용법이다.  
`add_option()` 함수가 함수객체를 리턴하고 그 함수객체가 또 자신을 리턴하도록 되어있어 사용자는 괄호만을 붙여가며 옵션들을 편하게 집어넣을 수 있도록 해준 아이디어가 재미있다.

```c++
using namespace boost;
using namespace boost::program_options;
using namespace std;
 
int _tmain(int argc, TCHAR* argv[])
{
    options_description desc("Allowed options");
    desc.add_options()
    ("help,h", "produce a help screen")
    ("version,v", "print the version number")
    ("all,a", "print all lists")
    ("number,n", boost::program_options::value<size_t>(), "Number example")
    ("import,i", boost::program_options::value<std::string>(), "Import path")
    ;
 
    variables_map vm;
    store(parse_command_line(argc, argv, desc), vm);
 
    if(vm.count("help"))
    {
        std::cout << "Usage: regex [options]\n";
        std::cout << desc;
        return 0;
    }
    if(vm.count("version"))
    {
        std::cout << "Version 1.\n";
        return 0;
    }
    if(vm.count("all"))
    {
        std::cout << "--All option was set." << std::endl;
    }
    if(vm.count("import"))
    {
        std::string importpath = vm["import"].as<std::string>();
        std::cout << "The import path was set to \"" << importpath << "\"" << std::endl;
    }    
    if (vm.count("number"))
    {
        std::cout << "--Number option was set.(" << vm["number"].as<size_t>() <<")" << std::endl;
    }
 
    return 0;
}
```

```powershell
>ProgramOption.exe -h
Usage: regex [options]
Allowed options:
  -h [ --help ]         produce a help screen
  -v [ --version ]      print the version number
  -a [ --all ]          print all lists
  -n [ --number ] arg   Number example
  -i [ --import ] arg   Import path
```

```powershell
> ProgramOption.exe -a
--All option was set.

> ProgramOption.exe -v
Version 1.

> ProgramOption.exe -iC:\
The import path was set to "C:\"

> ProgramOption.exe -n2
--Number option was set.(2)

> ProgramOption.exe -an3 -iC:\
--All option was set.
The import path was set to "C:\"
--Number option was set.(3)

> ProgramOption.exe --import=C:\
The import path was set to "C:\"
```

실제 사용은 대부분의 콘솔 애플리케이션들이 커맨드 라인으로 인터페이스하는 방식과 똑같이 하면 된다.  
옵션의 순서도 물론 상관없으며, `ps -ef` 처럼 연속으로 2개씩 쓸 수도 있다.