import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/config/agora_config.dart';
import 'package:whatsapp_ui/features/call/controller/call_controller.dart';
import 'package:whatsapp_ui/models/call.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;

  const CallScreen({
    super.key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
  });

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  late RtcEngine _engine;
  int? _remoteUid;           // ← penting: simpan UID user lain
  bool _localUserJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.camera, Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: AgoraConfig.appId,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() => _localUserJoined = true);
          print("Local user joined channel: ${connection.channelId}");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user joined: $remoteUid");
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("Remote user offline: $remoteUid");
          setState(() => _remoteUid = null);
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    // Join channel
    await _engine.joinChannel(
      token: '',                    // ganti dengan token dari server kalau production
      channelId: widget.channelId,
      uid: 0,                         // local user selalu 0
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Remote Video (user lain)
          if (_remoteUid != null)
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _remoteUid!),
                connection: RtcConnection(channelId: widget.channelId),
              ),
            )
          else
            const Center(
              child: Text(
                "Menunggu lawan bicara...",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

          // Local Video (kamera sendiri) - kecil di pojok
          Positioned(
            top: 40,
            right: 20,
            child: SizedBox(
              width: 120,
              height: 180,
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),
          ),

          // Control Buttons
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                      _engine.muteLocalAudioStream(_isMuted);
                    });
                  },
                  icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                  color: Colors.white,
                  iconSize: 30,
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isVideoEnabled = !_isVideoEnabled;
                      _engine.muteLocalVideoStream(!_isVideoEnabled);
                    });
                  },
                  icon: Icon(_isVideoEnabled ? Icons.videocam : Icons.videocam_off),
                  color: Colors.white,
                  iconSize: 30,
                ),
                const SizedBox(width: 40),
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () async {
                    await _engine.leaveChannel();
                    if (mounted) {
                      ref.read(callControllerProvider).endCall(
                            widget.call.callerId,
                            widget.call.receiverId,
                            context,
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: const Icon(Icons.call_end, size: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}