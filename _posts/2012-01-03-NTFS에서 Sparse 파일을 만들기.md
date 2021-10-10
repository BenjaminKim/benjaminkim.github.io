---
layout: post
categories: programming
image: /assets/img/jeho.jpg
title: NTFS에서 Sparse 파일을 만들기
---
[Sparse 파일](https://docs.microsoft.com/en-us/windows/win32/fileio/sparse-files)을 만드는 것은 Win32 Api로서 제공되지는 않으며 파일 시스템이 인터페이스를 제공한다.  
콘트롤 코드를 파일 시스템 장치에 직접 보냄으로써 Sparse 파일을 만들어 낼 수 있다.

```c++
HANDLE h = CreateFileW(
  L”D:\\MySparseFile.TXT”,
  GENERIC_WRITE,
  FILE_SHARE_DELETE,
  0,
  CREATE_NEW,
  0,
  0
);

if (!DeviceIoControl(
  h,
  FSCTL_SET_SPARSE, // <--- 콘트롤 코드
  NULL,
  0,
  NULL,
  0,
  &dwWritten,
  NULL))
{
  dwError = GetLastError();
  return dwError;
}
```

Sparse 파일을 만들게 되면 파일 포인터를 충분히 크게 이동하고 SetEndOfFile을 호출해도 실제로 데이터를 기록하지 않는다.  
따라서 [SetEndOfFile](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-setendoffile)을 호출해도 즉시 반환된다.  
나중에 파일의 해당 부분을 읽을 때 파일 시스템이 해당 부분의 데이터는 0으로 돌려주는 것이다.

이 기능을 활용하면 [WriteFile](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-writefile) 같은 함수를 통해 실제로 디스크에 데이터를 쓰는 경우에만 용량을 차지하게 되는 이점이 있다.  
버추얼 박스나 VMware에서 생성하는 커다란 동적 하드 디스크를 구현 할 때 이런 방법을 사용하면 된다.  
처음에 가상 디스크의 용량을 크게 잡아둬도 실제 하드 디스크 용량을 차지하지 않다가, 사용하면 할수록 하드 디스크의 사용량이 늘어나는 것을 본 적이 있을 것이다.

Windows에 인스톨 될 수 있는 모든 파일 시스템이 Sparse 파일을 지원한다고 가정해서는 안된다.  
FAT이나 다른 벤더에서 만든 인스톨러블 파일 시스템은 Sparse 기능을 지원하지 않을 수도 있다.
Sparse 기능이 지원되는지 알아보기 위해서는 [GetVolumeInformation](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getvolumeinformationw) 함수를 사용한다.

FAT 파일 시스템도 Sparse파일을 지원하지 않는데, 그러므로 NTFS상의 Sparse 파일을 FAT 볼륨으로 복사하게 되면 FAT볼륨에서는 더 이상 공간이 절약되지 않는다. (실제로 0을 디스크에 써버릴 것이다.)  
Sparse 파일에서 실제로 디스크에 저장된 용량을 알고 싶을 때는 [GetCompressedFileSize](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getcompressedfilesizea) 함수를 사용하면 된다.
