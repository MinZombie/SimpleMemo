### 개발 내용

- Realm으로 데이터를 저장, 수정, 삭제, 검색 기능 구현
- 다국어 처리
- 메모 데이터를 백업, 복구하는 기능
- 위젯킷으로 최신 메모 3개 바탕화면에서 보여주도록 구현

### 사용 기술 및 라이브러리

- Swift, iOS
- Realm
- Zip
- WidgetKit

## 고민 & 구현 방법

### CoreData가 아닌, Realm 사용한 이유

- Entity를 Xcode를 통해서 생성하고 데이터를 다루는게 직관적이지 않았습니다. Realm은 Realm Studio로 데이터를 한눈에 파악하기 쉬웠고, iOS와 Android 간 DB를 공유가 가능했고, 속도가 빠르다는 장점이 있어서 모바일에 사용하기에 최적화 됐다고 판단해서 사용하게 됐습니다.

### 다국어

- Localization으로 string 파일을 관리해서 다국어 처리를 했습니다.
    

### 위젯

- 사용자와의 상호작용 없이 메모만 보여주기 위해서 StaticConfiguration 사용했습니다.

```swift
@main
struct SimpleMemo_Widget: Widget {
    let kind: String = "SimpleMemo_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SimpleMemo_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("WidgetConfigurationDisplayName", comment: ""))
        .description(NSLocalizedString("WidgetDescription", comment: ""))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```
    

### 메모를 수정, 삭제 하기 위해서 셀을 선택했을 때, 선택한 메모를 DB에서 찾는 방법

- date를 메모의 id처럼 사용 했습니다. 메모를 추가하는 시점에 date 값도 같이 저장을 하게 되면 한 개만 존재하는 유일한 값이 될 수 있습니다.

```swift
class Memo: Object, Identifiable {
    @Persisted var date: Date = Date()
    @Persisted var content: String
    @Persisted var backgroundColor: String
    
    convenience init(content: String, backgroundColor: String) {
        self.init()
        self.content = content
        self.backgroundColor = backgroundColor
    }
}
```

### 앱에서 Realm 라이브러리를 이미 설치를 하고 사용하고 있는데, Widget에서는 왜 realm 데이터 사용이 안될까?

- App bundle안에 extension bundle이 있다고 해도, App container하고 Extension container은 서로 접근할 수 없어 App groups를 이용해서 서로 데이터를 공유할 수 있게 됐습니다.
![1](https://user-images.githubusercontent.com/78908490/170917006-da9aa0fd-9b1a-42a4-afb7-cba07ddf6c7f.png)

```swift
private var realm: Realm {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.headingtodev.simplememo")
        let realmURL = container?.appendingPathComponent("default.realm")
        let config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
        return try! Realm(configuration: config)
}
```

## 느낀점

### 사용자 입장에서 생각

- 개발자가 앱을 만들지만 결국 사용자가 앱을 사용하기 때문에, 사용자 입장에서 필요한 기능이 무엇인지, 어떻게 디자인을 해야 하는지 고민할 필요를 느꼈습니다.
- 사용자가 앱 내부의 코드를 볼 수는 없지만 가독성이 좋은 코드, 재사용이 용이한 코드등을 작성하는 것이 개발자뿐만 아니라 사용자를 위해서 필요한 것이라고 생각했습니다. 개발자가 좋은 코드로 개발하게 되면 좋은 앱을 개발할 가능성이 높아지고 사용자도 좋은 앱을 사용할 수 있기 때문입니다.


## 구현 영상

![1](https://user-images.githubusercontent.com/78908490/170917175-59735aca-b2f0-4c21-992f-fa80f4f73979.gif)
![2](https://user-images.githubusercontent.com/78908490/170917286-63b7c8ac-33cf-4fdf-abc5-a6220bce6dbf.gif)
![3](https://user-images.githubusercontent.com/78908490/170917303-fd7b2a78-fadd-4b2a-8374-c4e594f7edc2.gif)
