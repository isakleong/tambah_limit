import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class Button extends StatelessWidget {

  Widget child;
  Color backgroundColor;
  Key key;
  bool fill, loading;
  VoidCallback onTap;
  double borderRadius;

  Button({this.child, this.backgroundColor, this.onTap, this.key, this.fill = true, this.loading:false
  });

  @override
  Widget build(BuildContext context){
    if(loading) {
      onTap = (){};
    }
    return ElevatedButton(
      key: key,
      onPressed: onTap,
      child: loading ?
        Container(
          width: 40,
          height: 20,
          child:FlareActor('assets/flare/loading-button.flr', animation: "Play")
        )
        :
        child,
        style: ElevatedButton.styleFrom(
          primary: backgroundColor,
          padding: EdgeInsets.all(14),
          elevation: 2,
          )
    );
  }
}