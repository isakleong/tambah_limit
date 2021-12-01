import 'package:flutter/material.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/button.dart';

// https://stackoverflow.com/questions/46480221/flutter-floating-action-button-with-speed-dail
class FabWithIcons extends StatefulWidget {
  FabWithIcons({this.btnTitle, this.onIconTapped});
  final List<String> btnTitle;
  ValueChanged<int> onIconTapped;
  @override
  State createState() => FabWithIconsState();
}

class FabWithIconsState extends State<FabWithIcons> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.btnTitle.length, (int index) {
        return _buildChild(index);
      }).toList()..add(
        _buildFab(),
      ),
    );
  }

  Widget _buildChild(int index) {
    return Container(
      height: 70.0,
      width: MediaQuery.of(context).size.width,
      alignment: FractionalOffset.topCenter,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Interval(
              0.0,
              1.0 - index / widget.btnTitle.length / 2.0,
              curve: Curves.easeOut
          ),
        ),
        child: Wrap(
          children: <Widget>[
            Container(
              child: Button(
                backgroundColor: config.darkOpacityBlueColor,
                child: TextView(widget.btnTitle[index], 7, color: Colors.white),
                onTap: () {
                  
                },
              ),
            ),
          ],
        ),
        // FloatingActionButton(
        //   backgroundColor: config.grayColor,
        //   mini: true,
        //   child: Icon(widget.icons[index], color: foregroundColor),
        //   onPressed: () => _onTapped(index),
        // ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        if (_controller.isDismissed) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      tooltip: 'Increment',
      child: Icon(Icons.add),
      elevation: 2.0,
    );
  }

  void _onTapped(int index) {
    _controller.reverse();
    widget.onIconTapped(index);
  }
}