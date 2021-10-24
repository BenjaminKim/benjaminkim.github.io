---
layout: post
categories: programming
image: /assets/img/books.jpg
title: 알아두면 유용한 MoveFileEx 함수의 펜딩 옵션
---
[MoveFileEx](https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-movefileexw) 함수는 파일 이름 변경이나 삭제를 컴퓨터가 재시작할 때 까지 지연시킬 수 있는 상당히 유용한 옵션이 있다.  
사용 중인 DLL을 교체 한다거나 언인스톨시 파일을 삭제해야 하는데 파일이 사용중이어서 삭제할 수 없는 경우에 유용하게 쓸 수 있다.

`MoveFile` 함수는 내부적으로 `CreateFile` 함수를 통해 파일을 오픈하는데 이 때 `DesiredAccess`로 `DELETE`을 사용한다.  
파일이 잘 열렸다면 `RenameInformation IRP`를 날린 후 핸들을 닫고 성공으로 반환하지만, 이미 다른 위치에서 파일이 열려있었다면 먼저 파일을 연쪽에서 `FILE_SHARE_DELETE`를 함께 주지 않았었을 경우 파일 열기가 `ERROR_SHARING_VIOLATION` 으로 실패하게 되어 `MoveFile` 함수 또한 실패로 리턴해버리게 되는 것이다.

재부팅 시에라도 dll 등을 교체시켜주거나 깨끗하게 삭제하기를 원한다면 `MoveFileEx`함수를 호출 할 때 세번째 파라메터로 `MOVEFILE_DELAY_UNTIL_REBOOT` 옵션을 주면 된다.  
이렇게 하면 `MoveFileEx`함수는 레지스트리의 `HKLM\System\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations` 위치에 어떤 오퍼레이션이었는지 정보를 적어 놓기만 하고 리턴한다.  
시스템이 재부팅 되고 나서 응용프로그램들이 실행되기 전 운영체제에서 레지스트리를 확인해 보고 해당 동작을(이름 변경 혹은 삭제) 수행해 주기 때문에 어떤 파일이던지 삭제가 가능하다.  
`HKLM` 위치에 써야 하기 때문에 관리자 권한이 필요하다.

이와 관련된 몇 가지 알아두면 좋을 지식들이 있다.

1. 다른 곳에서 파일을 열고 있다고 이름 변경을 못하는 것은 아니다.  
먼저 파일을 연쪽에서 어떤 공유 모드로 파일을 열었는지가 중요하다.  
파일을 먼저 오픈 하는 쪽에서 `FILE_SHARE_DELETE`옵션을 주어서 `CreateFile`을 하면 다른 위치에서 해당 파일의 이름을 변경 할 수 있다.  
심지어는 삭제도 가능한데(`DeleteFile`을 호출하면 성공한다) 이때는 파일이 삭제 상태로만 마킹 되며 파일 시스템 드라이버는 해당 파일을 열어 놓은 모든 핸들이 닫힐 때 실제로 삭제를 수행한다.  
이렇게 삭제 상태로 마킹되어 있는 동안에는 또 다른 곳에서 파일 오픈 시도가 생겼을 때 `ERROR_ACCESS_DENIED` 에러가 발생하게 된다.  
파일 핸들을 닫기 전까지는 이런 `DELETE_PENDING` 상태의 파일을 삭제되지 않은 상태의 파일로 다시 돌리는 것 또한 가능하다.

2. 어딘가에서 파일 삭제를 허용하지 않고 먼저 파일을 열어두었을 시에 `MoveFileEx`에 `MOVEFILE_DELAY_UNTIL_REBOOT` 옵션을 주어 함수를 호출하면 파일 열기시 `ERROR_SHARING_VIOLATION`에러를 받게 된다. 
하지만 이 때는 `MoveFileEx` 함수가 실패로 리턴하지 않고 레지스트리에 기록을 해주기 때문에, 어떤 상태의 파일이든지 간에 이름 변경이나 삭제를 할 수가 있는 것이다.

3. 함수 모양을 봤을 때 `MoveFileEx`나 `DeleteFile`처럼 HANDLE을 인자로 전달받지 않고 파일 경로를 전달 받는 함수는 모두 내부적으로 파일을 오픈한다.

4. [SetFileInformationByHandle](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-setfileinformationbyhandle?redirectedfrom=MSDN) 함수를 사용하면 추가적으로 파일을 다시 열지 않고 Rename, Delete등의 작업을 할 수 있다.  
이 함수는 파일 시스템 드라이버에 전달되는 IRP와 거의 비슷하게 매핑되는 아주 강력한 함수이다.  
파일 속성에 대한 모든 조작은 이 함수를 통해서 할 수 있다.  
하지만 워낙 저수준의 함수이기 때문에 사용법이 조금 어렵게 느껴질 수도 있다.  
아래 글에 해당 함수를 사용하여 이름 변경을 하는 코드에 대한 설명이 있다.  
[하위 디렉터리의 파일이 변경 되었는지 감지하는 법](https://jeho.page/essay/2010/12/20/%ED%95%98%EC%9C%84-%EB%94%94%EB%A0%89%ED%84%B0%EB%A6%AC%EC%9D%98-%ED%8C%8C%EC%9D%BC%EC%9D%B4-%EB%B3%80%EA%B2%BD-%EB%90%98%EC%97%88%EB%8A%94%EC%A7%80-%EA%B0%90%EC%A7%80%ED%95%98%EA%B8%B0.html)