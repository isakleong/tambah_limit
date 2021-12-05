import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:tambah_limit/widgets/TextView.dart';

class ModalWithPageView extends StatelessWidget {
  String modalTitle;
  List<Widget> modalContent;

  ModalWithPageView({
    this.modalTitle,
    this.modalContent
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar:
            AppBar(title: TextView(modalTitle, 3), automaticallyImplyLeading: false),
        body: SafeArea(
          bottom: false,
          child: PageView(
            children: List.generate(
                1,
                (index) => ListView(
                      shrinkWrap: true,
                      controller: ModalScrollController.of(context),
                      children: modalContent
                    )),
          ),
        ),
      ),
    );
  }
}