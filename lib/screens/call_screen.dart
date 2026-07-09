import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/vitala_api.dart';
import '../theme/colors.dart';

class CallScreen extends StatefulWidget {
  final RtcCredentials credentials;
  const CallScreen({super.key, required this.credentials});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  RtcEngine? _engine;
  int? _remoteUid;
  bool _joined = false;
  bool _micOn = true;
  bool _camOn = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (!kIsWeb) {
      await [Permission.camera, Permission.microphone].request();
    }
    final engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(
      appId: widget.credentials.appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        setState(() => _joined = true);
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        setState(() => _remoteUid = remoteUid);
      },
      onUserOffline: (connection, remoteUid, reason) {
        setState(() => _remoteUid = null);
      },
    ));
    await engine.enableVideo();
    await engine.startPreview();
    await engine.joinChannel(
      token: widget.credentials.token,
      channelId: widget.credentials.channel,
      uid: widget.credentials.uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
    setState(() => _engine = engine);
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = _engine;
    return Scaffold(
      backgroundColor: VitalaColors.ink,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video (full screen) or waiting state.
            Positioned.fill(
              child: engine != null && _remoteUid != null
                  ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: engine,
                  canvas: VideoCanvas(uid: _remoteUid),
                  connection: RtcConnection(channelId: widget.credentials.channel),
                ),
              )
                  : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: VitalaColors.tealSoft),
                    const SizedBox(height: 16),
                    Text(
                      _joined
                          ? 'Esperando al otro participante…\nComparte el código ${widget.credentials.channel}'
                          : 'Conectando…',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            // Local preview (picture-in-picture).
            if (engine != null)
              Positioned(
                top: 16,
                right: 16,
                width: 110,
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: engine,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
            // Room code chip.
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(widget.credentials.channel,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
            // Controls.
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundButton(
                    icon: _micOn ? Icons.mic : Icons.mic_off,
                    onTap: () {
                      setState(() => _micOn = !_micOn);
                      engine?.muteLocalAudioStream(!_micOn);
                    },
                  ),
                  const SizedBox(width: 16),
                  _RoundButton(
                    icon: _camOn ? Icons.videocam : Icons.videocam_off,
                    onTap: () {
                      setState(() => _camOn = !_camOn);
                      engine?.muteLocalVideoStream(!_camOn);
                    },
                  ),
                  if (!kIsWeb) ...[
                    const SizedBox(width: 16),
                    _RoundButton(
                      icon: Icons.cameraswitch,
                      onTap: () => engine?.switchCamera(),
                    ),
                  ],
                  const SizedBox(width: 16),
                  _RoundButton(
                    icon: Icons.call_end,
                    color: VitalaColors.danger,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _RoundButton({required this.icon, required this.onTap, this.color = Colors.white24});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
