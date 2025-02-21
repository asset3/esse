import "dart:collection";

import 'package:flutter/material.dart';

import 'package:esse/rpc.dart';
import 'package:esse/apps/primitives.dart';
import 'package:esse/apps/chat/models.dart';


class ChatProvider extends ChangeNotifier {
  Map<int, Friend> friends = {}; // all friends. friends need Re-order.

  int activedFriendId = 0; // actived friend's id.
  Friend? get activedFriend => this.friends[this.activedFriendId];

  List<int> orderKeys = []; // ordered chat friends with last message.

  /// all requests. request have order.
  SplayTreeMap<int, Request> requests = SplayTreeMap();

  /// current show messages. init number is 100, message have order.
  SplayTreeMap<int, Message> activedMessages = SplayTreeMap();

  void orderFriends(int id) {
    if (this.orderKeys.length == 0 || this.orderKeys[0] != id) {
      this.orderKeys.remove(id);
      this.orderKeys.insert(0, id);
    }
  }

  ChatProvider() {
    // rpc
    rpc.addListener('chat-friend-list', _friendList, false);
    rpc.addListener('chat-friend-info', _friendInfo, false);
    rpc.addListener('chat-friend-update', _friendUpdate, false);
    rpc.addListener('chat-friend-close', _friendClose, false);
    rpc.addListener('chat-request-list', _requestList, false);
    rpc.addListener('chat-request-create', _requestCreate, true, true);
    rpc.addListener('chat-request-delivery', _requestDelivery, false);
    rpc.addListener('chat-request-agree', _requestAgree, false);
    rpc.addListener('chat-request-reject', _requestReject, false);
    rpc.addListener('chat-request-delete', _requestDelete, false);
    rpc.addListener('chat-message-list', _messageList, false);
    rpc.addListener('chat-message-create', _messageCreate, true);
    rpc.addListener('chat-message-delete', _messageDelete, false);
    rpc.addListener('chat-message-delivery', _messageDelivery, false);
  }

  clear() {
    this.activedFriendId = 0;
    this.friends.clear();
    this.orderKeys.clear();
    this.requests.clear();
    this.activedMessages.clear();
  }

  updateActived() {
    this.clear();

    // load friends.
    rpc.send('chat-friend-list', []);
    notifyListeners();
  }

  updateActivedFriend(int id) {
    this.activedFriendId = id;
    this.activedMessages.clear();

    rpc.send('chat-message-list', [this.activedFriendId]);
    notifyListeners();
  }

  clearActivedFriend() {
    this.activedFriendId = 0;
    this.activedMessages.clear();
  }

  /// delete a friend.
  friendUpdate(int id, String remark) {
    this.friends[id]!.remark = remark;
    rpc.send('chat-friend-update', [id, remark]);
    notifyListeners();
  }

  /// delete a friend.
  friendClose(int id) {
    this.friends[id]!.isClosed = true;

    rpc.send('chat-friend-close', [id]);
    notifyListeners();
  }

  /// delete a friend.
  friendDelete(int id) {
    if (id == this.activedFriendId) {
      this.activedFriendId = 0;
      this.activedMessages.clear();
    }

    this.friends.remove(id);
    this.orderKeys.remove(id);

    rpc.send('chat-friend-delete', [id]);
    notifyListeners();
  }

  /// list all request.
  requestList() {
    rpc.send('chat-request-list', []);
  }

  /// clear the memory requests.
  requestClear() {
    this.requests.clear();
  }

  /// create a request for friend.
  requestCreate(Request req) {
    this.requests.remove(req.id);

    rpc.send('chat-request-create', [req.gid, req.addr, req.name, req.remark]);
    notifyListeners();
  }

  /// agree a request for friend.
  requestAgree(int id) {
    this.requests[id]!.overIt(true);

    rpc.send('chat-request-agree', [id]);
    notifyListeners();
  }

  /// reject a request for friend.
  requestReject(int id) {
    this.requests[id]!.overIt(false);

    rpc.send('chat-request-reject', [id]);
    notifyListeners();
  }

  /// delte a request for friend.
  requestDelete(int id) {
    this.requests.remove(id);

    rpc.send('chat-request-delete', [id]);
    notifyListeners();
  }

  /// create a message. need core server handle this message.
  /// and then this message will show in message list.
  messageCreate(Message msg) {
    final fgid = this.friends[msg.fid]!.gid;
    rpc.send('chat-message-create', [msg.fid, fgid, msg.type.toInt(), msg.content]);
  }

  /// delete a message.
  messageDelete(int id) {
    this.activedMessages.remove(id);

    rpc.send('chat-message-delete', [id]);
    notifyListeners();
  }

  /// list all friends.
  _friendList(List params) {
    this.orderKeys.clear();
    this.friends.clear();

    params.forEach((params) {
        final id = params[0];
        this.friends[id] = Friend.fromList(params);
        this.orderKeys.add(id);
    });
    notifyListeners();
  }

  _friendInfo(List params) {
    final id = params[0];
    this.friends[id] = Friend.fromList(params);
    notifyListeners();
  }

  _friendUpdate(List params) {
    final id = params[0];
    if (this.friends.containsKey(id)) {
      this.friends[id]!.remark = params[2];
      notifyListeners();
    }
  }

  _friendClose(List params) {
    final id = params[0];
    if (this.friends.containsKey(id)) {
      this.friends[id]!.isClosed = true;
      notifyListeners();
    }
  }

  /// list requests for friend.
  _requestList(List params) {
    this.requests.clear();
    params.forEach((param) {
        if (param.length == 10) {
          this.requests[param[0]] = Request.fromList(param);
        }
    });
    notifyListeners();
  }

  /// receive a request for friend.
  _requestCreate(List params) {
    this.requests[params[0]] = Request.fromList(params);
    notifyListeners();
  }

  /// created request had delivery.
  _requestDelivery(List params) {
    final id = params[0];
    final isDelivery = params[1];
    if (this.requests.containsKey(id)) {
      this.requests[id]!.isDelivery = isDelivery;
      notifyListeners();
    }
  }

  /// request for friend receive agree.
  _requestAgree(List params) {
    final id = params[0]; // request's id.
    if (this.requests.containsKey(id)) {
      this.requests[id]!.overIt(true);
    }
    var friend = Friend.fromList(params[1]);
    this.friends[friend.id] = friend;
    orderFriends(friend.id);
    notifyListeners();
  }

  /// request for friend receive reject.
  _requestReject(List params) {
    final id = params[0];
    if (this.requests.containsKey(id)) {
      this.requests[id]!.overIt(false);
      notifyListeners();
    }
  }

  _requestDelete(List params) {
    this.requests.remove(params[0]);
    notifyListeners();
  }

  /// list message with friend.
  _messageList(List params) {
    params.forEach((param) {
        if (param.length == 8) {
          this.activedMessages[param[0]] = Message.fromList(param);
        }
    });
    notifyListeners();
  }

  /// friend send message to me.
  _messageCreate(List params) {
    final msg = Message.fromList(params);
    if (msg.fid == this.activedFriendId) {
      if (!msg.isDelivery!) {
        msg.isDelivery = null; // When message create, set is is none;
      }
      this.activedMessages[msg.id] = msg;
    }
    orderFriends(msg.fid);
    notifyListeners();
  }

  _messageDelete(List params) {
    this.activedMessages.remove(params[0]);
    notifyListeners();
  }

  /// created message had delivery.
  _messageDelivery(List params) {
    final id = params[0];
    final isDelivery = params[1];
    if (this.activedMessages.containsKey(id)) {
      this.activedMessages[id]!.isDelivery = isDelivery;
      notifyListeners();
    }
  }
}
