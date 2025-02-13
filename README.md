_English | [中文](./README_zh.md)_

# ChatroomUIKit

ChatroomUIKit is designed to address most users' chat room requirements specific to pan-entertainment scenarios. It delivers good user experience in the use of APIs (for user-side developers) by streamlining SDK integration, facilitating customization, and offering comprehensive documentation.

## Development environment requirements

- SDK: >=3.0.0 <4.0.0
- Flutter: >=3.12.0

For the iOS app:

- Xcode 13 or higher
- iOS 11 or higher

For the Android app:

- minSDKVersion 21

## ChatroomUIKit installation

```sh
flutter pub get add chatroom_uikit
```

## Run the demo

[example](./example/README.md)

## Advanced usage

### Initialize the ChatroomUIKit

To initialize the ChatroomUIKit, you need to [get the App Key on the Agora Console](https://docs.agora.io/en/agora-chat/get-started/enable?platform=flutter#get-chat-project-information).  

```dart

await ChatroomUIKitClient.instance.initWithAppkey(appKey);

```

### Log in to ChatroomUIKit

To log in to the ChatroomUIKit, you need to pass in the user ID and token typed when you [register a user on the Agora Console](https://docs.agora.io/en/agora-chat/get-started/enable?platform=flutter#register-a-user).

```dart
try {
    await ChatroomUIKitClient.instance.loginWithToken(
        userId: userId,
        password: token, // Password typed when you register a user.
        userInfo: userInfo, // The current user object that conforms to the UserInfoProtocol protocol. The default user object is `UserEntity` in the ChatroomUIKit. 
    );
}on ChatError catch(e) {
    // error.
}
```

### Switch the theme

You can use `ChatUIKitTheme` to switch to the `light` or `dark` theme that comes with the ChatroomUIKit.

```dart
ChatUIKitTheme.instance.setColor(ChatUIKitColor.light());
```

To adjust theme colors, you need to define the `hue` value of the following colors in `ChatUIKitColor`:

```dart
ChatUIKitColor({
  this.primaryHue = 203,
  this.secondaryHue = 155,
  this.errorHue = 350,
  this.neutralHue = 203,
  this.neutralSpecialHue = 220,
  this.barrageLightness = LightnessStyle.oneHundred,
  this.isDark = false,
});
```

### chatroom_uikit component

1. To use `chatroom_uikit`, you need to first create `ChatroomController` and then set `ChatRoomUIKit` as the root node of the current page and other components as children of `ChatRoomUIKit`.

```dart
// roomId: Chat room ID.
// ownerId: User ID of the chat room owner.
ChatroomController controller = ChatroomController(roomId: roomId, ownerId: ownerId);

@override
Widget build(BuildContext context) {
  Widget content = Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(),
    body: ChatRoomUIKit(
      controller: controller,
      child: (context) {
        // Build pages within child components, like gift window and message list page. 
        return ...;
      },
    ),
  );

  return content;
}

```

### ChatroomMessageListView component

The `ChatroomMessageListView` component presents messages within the chat room. Make sure that this component acts as a child node of `ChatRoomUIKit`. You can add `ChatroomMessageListView` to the screen and set its position as follows:

```dart
@override
Widget build(BuildContext context) {
  Widget content = Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(),
    body: ChatRoomUIKit(
      controller: controller,
      child: (context) {
        return const Stack(
          children: [
            Positioned(
              left: 16,
              right: 78,
              height: 204,
              bottom: 90,
              child: ChatroomMessageListView(),
            )
            ...
          ],
        );
      },
    ),
  );

  return content;
}

```

`ChatroomMessageListView` provides items like click, long press, and repaint and also allows you to set the reportController. 

```dart
const ChatroomMessageListView({
  this.onTap,
  this.onLongPress,
  this.itemBuilder,
  this.reportController,
  this.controller,
  super.key,
});
```

The `ChatroomMessageListView` component does not show gifts by default. To show gifts, you need to set `enableMsgListGift` to `true` in [ChatRoomSettings](#chatroomsettings-settings).

```dart
ChatRoomSettings.enableMsgListGift = true;
```

### ChatInputBar component

The `ChatInputBar` component is used to send messages. It is placed in [chatroom_uikit](#chatroom_uikit-component) by default and the position is not configurable. This component can involve more click options and you can configure more click events in `ChatroomUIKit`.

```dart
// roomId: chat room ID.
// ownerId: user ID of the chat room.
ChatroomController controller = ChatroomController(roomId: roomId, ownerId: ownerId);

@override
Widget build(BuildContext context) {
  Widget content = Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(),
    body: ChatRoomUIKit(
      controller: controller,
      inputBar: ChatInputBar(),
      child: (context) {
        // Build pages within child components, like gift window and message list page.
        return ...;
      },
    ),
  );

  return content;
}

```

`ChatInputBar` allows you to add widgets via `leading` and `actions`. You can add four actions via `actions`.

```dart
ChatInputBar({
  this.inputIcon,
  this.inputHint,
  this.leading,
  this.actions,
  this.textDirection,
  this.onSend,
  super.key,
}) {
  assert(
      actions == null || actions!.length <= 4, 'can\'t more than 4 actions');
}
```

### ChatRoomGiftListView component

You need to configure gifts before selecting and sending them. For this purpose, you need to configure `giftControllers` in `ChatroomController`, passing in an instance that conforms to the `ChatroomGiftPageController` protocol (`DefaultGiftPageController` is available in `chatroom_uikit`).

```dart
ChatroomController controller = ChatroomController(
      roomId: widget.roomId,
      ownerId: widget.ownerId,
      giftControllers: () async {
        List<DefaultGiftPageController> service = [];
        // Parse the gift JSON and fill the parsing result in the gifts list in DefaultGiftPageController.
        final value = await rootBundle.loadString('data/Gifts.json');
        Map<String, dynamic> map = json.decode(value);
        for (var element in map.keys.toList()) {
          service.add(
            DefaultGiftPageController(
              title: element,
              gifts: () {
                List<GiftEntityProtocol> list = [];
                map[element].forEach((element) {
                  // Parse the JSON into the object that conforms to the GiftEntityProtocol protocol.
                  GiftEntityProtocol? gift = ChatroomUIKitClient
                      .instance.giftService
                      .giftFromJson(element);
                  if (gift != null) {
                    list.add(gift);
                  }
                });
                return list;
              }(),
            ),
          );
        }
        return service;
      }(),
    );

```

The gift list is displayed. You can add a button in [ChatInputBar](#chatinputbar-component) to show the gift list.

```dart
@override
Widget build(BuildContext context) {
  Widget content = Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(),
    body: ChatRoomUIKit(
      controller: controller,
      inputBar: ChatInputBar(
        actions: [
          InkWell(
            onTap: () => controller.showGiftSelectPages(),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Image.asset('images/send_gift.png'),
            ),
          ),
        ],
      ),
      child: (context) {
        return Container();
      },
    ),
  );

  return content;
}

```

You can select a gift and click `Send` to send it.

Gifts can be displayed via either of the following components:

- [ChatroomMessageListView component](#chatroommessagelistview-component)
- [ChatroomGiftMessageListView component](#chatroomgiftmessagelistview-component)

### ChatroomGiftMessageListView component

The `ChatroomGiftMessageListView` component displays gifts that are sent and received. Make sure that this component is set as a child component of `ChatRoomUIKit`. You can add this component to the screen and set its position as follows:

```dart
@override
Widget build(BuildContext context) {
  // Do not show gifts on the message list. 
  ChatRoomSettings.enableMsgListGift = false;
  Widget content = Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(),
    body: ChatRoomUIKit(
      controller: controller,
      child: (context) {
        return const Stack(
          children: [
            Positioned(
              left: 16,
              right: 180,
              height: 84,
              bottom: 300,
              child: ChatroomGiftMessageListView(),
            ),
            ...
          ],
        );
      },
    ),
  );

  return content;
}

```

`ChatroomGiftMessageListView` allows you to set the gift widget and placeholder icon.

```dart
const ChatroomGiftMessageListView({
  this.giftWidgetBuilder,
  this.placeholder,
  super.key,
});
```

### ChatroomGlobalBroadcastView component

The `ChatroomGlobalBroadcastView` component shows global broadcast messages. Remember to set this component as a child node of `ChatRoomUIKit`. You can add the `ChatroomGlobalBroadcastView` component to the screen and set its position as follows:

```dart

@override
Widget build(BuildContext context) {
  Widget content = Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(),
    body: ChatRoomUIKit(
      controller: controller,
      child: (context) {
        return Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).viewInsets.top + 10,
                height: 20,
                left: 20,
                right: 20,
                child: const ChatroomGlobalBroadcastView(),
              ),
              ...
            ],
          );
      },
    ),
  );

  return content;
}

```

`ChatroomGlobalBroadcastView` allows you to set the icon, font, and background color.

```dart
const ChatroomGlobalBroadcastView({
  this.icon,
  this.textStyle,
  this.backgroundColor,
  super.key,
});
```

### ChatRoomSettings class  

The `ChatRoomSettings` class provides ChatroomUIKit settings.

```dart
class ChatRoomSettings {
  static String? userDefaultAvatar; // Default avatar.
  static String? defaultIdentify; // Default identity icon.
  static String? defaultGiftIcon; // Default gift icon.

  static bool enableMsgListTime = true; // Whether the time is displayed on the message list.
  static bool enableMsgListAvatar = true; // Whether the avatars are displayed on the message list.
  static bool enableMsgListNickname = true; // Whether nicknames are displayed on the message list.
  static bool enableMsgListIdentify = true; // Whether identities are displayed on the message list.

  static bool enableMsgListGift = false; // Whether gifts are displayed on the message list.

  static bool enableParticipantItemIdentify = false; // Whether identities are displayed on the participant list.

  static CornerRadius inputBarRadius = CornerRadius.large; // Corner radius of the input box.
  static CornerRadius avatarRadius = CornerRadius.large; // Corner radius of the avatar.
}

```

## License

MIT
