import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';

import '../model/queue_state.dart';
import '../service/player_stream.dart';
import 'mini_player_widget.dart';
import 'player_widget.dart';

class AudioPlayerSliding extends StatefulWidget {
  const AudioPlayerSliding({Key? key}) : super(key: key);

  @override
  _AudioPlayerSlidingState createState() => _AudioPlayerSlidingState();
}

class _AudioPlayerSlidingState extends State<AudioPlayerSliding> {
  late ScrollController panelScrollController;

  ///The controller of sliding up panel
  SlidingUpPanelController panelController = SlidingUpPanelController();
  bool _isPanelExpanded = false;

  @override
  void initState() {
    panelScrollController = ScrollController();
    panelScrollController.addListener(() {
      if (panelScrollController.offset >=
              panelScrollController.position.maxScrollExtent &&
          !panelScrollController.position.outOfRange) {
        panelController.expand();
      } else if (panelScrollController.offset <=
              panelScrollController.position.minScrollExtent &&
          !panelScrollController.position.outOfRange) {
        // panelController.anchor();
      } else {}
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QueueState>(
      stream: playerStream.queueStateStream,
      builder: (context, snapshot) {
        final queueState = snapshot.data;
        final queue = queueState?.queue ?? const [];

        if (queue.isEmpty) {
          return SizedBox(height: 0);
        } else {
          return SlidingUpPanelWidget(
            controlHeight: 100.0,
            anchor: 0.4,
            panelController: panelController,
            enableOnTap: false,
            dragEnd: (details) {
              if (panelController.status == SlidingUpPanelStatus.expanded) {
                setState(() {
                  _isPanelExpanded = true;
                });
              }
              if (panelController.status == SlidingUpPanelStatus.collapsed) {
                setState(() {
                  _isPanelExpanded = false;
                });
              }
              print('dragEnd');
            },
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shadows: [
                  BoxShadow(
                    blurRadius: 5.0,
                    spreadRadius: 2.0,
                    color: const Color(0x11000000),
                  )
                ],
                shape: RoundedRectangleBorder(),
              ),
              child: Column(
                children: <Widget>[
                  // mini player
                  Visibility(
                    visible: !_isPanelExpanded,
                    child: InkWell(
                      onTap: () {
                        if (panelController.status ==
                            SlidingUpPanelStatus.collapsed) {
                          panelController.expand();
                          setState(() {
                            _isPanelExpanded = true;
                          });
                        }
                      },
                      child: MiniPlayerWidget(),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      child: PlayerWidget(
                        appBarOnTap: () {
                          if (panelController.status ==
                              SlidingUpPanelStatus.expanded) {
                            panelController.collapse();
                            setState(() {
                              _isPanelExpanded = false;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
          );
        }
      },
    );
  }
}
