import 'dart:convert';

import 'package:agora_chat_room_kit/chatroom_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    required this.roomId,
    required this.ownerId,
    super.key,
  });

  final String roomId;
  final String ownerId;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late ChatroomController controller;

  @override
  void initState() {
    super.initState();

    ChatRoomSettings.defaultIdentify = 'images/default_identify.png';
    ChatRoomSettings.defaultGiftIcon = 'images/sweet_heart.png';

    controller = ChatroomController(
      roomId: widget.roomId,
      ownerId: widget.ownerId,
      listener: ChatroomEventListener(
        (type, error) {
          vLog('ChatroomController error: $error, type: $type');
        },
      ),
      giftControllers: () async {
        List<DefaultGiftPageController> service = [];
        final value = await rootBundle.loadString('data/Gifts.json');
        Map<String, dynamic> map = json.decode(value);
        for (var element in map.keys.toList()) {
          service.add(
            DefaultGiftPageController(
              title: element,
              gifts: () {
                List<GiftEntityProtocol> list = [];
                map[element].forEach((element) {
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
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/chat_bg.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: ChatRoomUIKit(
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
            return Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).viewInsets.top + 10,
                  left: 0,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 54),
                        child: ChatroomPinMessageWidget(
                          roomId: controller.roomId,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(
                        height: 20,
                        child: ChatroomGlobalBroadcastView(),
                      )
                    ],
                  ),
                ),
                const Positioned(
                  left: 16,
                  right: 16,
                  height: 84,
                  bottom: 300,
                  child: ChatroomGiftMessageListView(),
                ),
                const Positioned(
                  left: 16,
                  right: 78,
                  height: 204,
                  bottom: 90,
                  child: ChatroomMessageListView(),
                )
              ],
            );
          },
        ),
      ),
    );

    content = GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: content,
    );

    return content;
  }
}
