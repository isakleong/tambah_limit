import 'dart:async';
import 'package:http/http.dart' show Client;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambah_limit/models/customerModel.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/resources/customerAPI.dart';
import 'package:tambah_limit/resources/userAPI.dart';
import 'package:tambah_limit/screens/addLimit.dart';
import 'package:tambah_limit/screens/addLimitCorporate.dart';
import 'package:tambah_limit/screens/changeBlockedStatus.dart';
import 'package:tambah_limit/screens/historyLimitRequest.dart';
import 'package:tambah_limit/screens/profile.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/EditText.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/bottombarAdapter.dart';
import 'package:tambah_limit/widgets/bottomBarLayout.dart';
import 'package:tambah_limit/widgets/bottombarWithIcon.dart';
import 'package:tambah_limit/widgets/bottomBarLayout.dart';

import 'package:tambah_limit/widgets/button.dart';



class Dashboard extends StatefulWidget {
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> with TickerProviderStateMixin {

  String _lastSelected = 'TAB: 0';
  String dashboardTitle = "Blok Pelanggan";
  int currentIndex = 0;

  bool customerIdValid = false;
  bool searchLoading = false;

  final customerIdController = TextEditingController();
  final FocusNode customerIdFocus = FocusNode();

  void _selectedTab(int index) {
    setState(() {
      if(index == 0){
        dashboardTitle = "Blok Pelanggan";
      } else if(index == 1){
        dashboardTitle = "Ubah Password";
      }
      _lastSelected = 'TAB: $index';
      currentIndex = index;
    });
  }

  void _selectedFab(int index) {
    setState(() {
      _lastSelected = 'FAB: $index';
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> blockInfoDetailWidgetList = showBlockInfoDetail(config);

    final List<Widget> menuList = [
      RefreshIndicator(
        onRefresh: refresh,
        child: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                child: EditText(
                  useIcon: true,
                  key: Key("CustomerId"),
                  controller: customerIdController,
                  focusNode: customerIdFocus,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.characters,
                  hintText: "Kode Pelanggan",
                  onSubmitted: (value) {
                    customerIdFocus.unfocus();
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                width: MediaQuery.of(context).size.width,
                child: Button(
                  loading: searchLoading,
                  backgroundColor: config.darkOpacityBlueColor,
                  child: TextView("Cari", 3, color: Colors.white),
                  onTap: () {
                    submitValidation();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // ProfilePage(model: config.user, mode: 3)
      Profile()
    ].where((c) => c != null).toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: TextView(dashboardTitle, 1),
        automaticallyImplyLeading: false,
      ),
      body: WillPopScope(
        onWillPop: willPopScope,
        child: Container(
          color: config.bodyBackgroundColor,
          child: menuList[currentIndex]
        ),
      ),
      bottomNavigationBar: FABBottomAppBar(
        centerItemText: '',
        color: config.grayColor,
        selectedColor: Colors.red,
        notchedShape: CircularNotchedRectangle(),
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(iconData: Icons.not_interested, text: 'Status Block'),
          FABBottomAppBarItem(iconData: Icons.password, text: 'Ubah Password'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(
          context), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  showBlockInfoDetail(Configuration config) {
    List<Widget> tempWidgetList = [];

  }




  Widget _buildFab(BuildContext context) {
    final btnTitle = [ "Tambah Limit", "Tambah Limit Corporate", "Riwayat Permintaan Limit" ];
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (context, offset) {
        return CenterAbout(
          position: Offset(offset.dx, offset.dy - btnTitle.length * 35.0),
          child: FabWithIcons(
            btnTitle: btnTitle,
            onIconTapped: _selectedFab,
          ),
        );
      },
      child: FloatingActionButton(
        onPressed: () { },
        tooltip: 'Increment',
        child: Icon(Icons.add),
        elevation: 2.0,
      ),
    );
  }

  void getBlockInfo() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      searchLoading = true;
    });

    Alert(context: context, loading: true, disableBackButton: true);

    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    String user_code = sharedPreferences.getString('user_code');

    Customer getBlockInfo = await customerAPI.getBlockInfo(context, parameter: 'json={"kode_customer":"${customerIdController.text}","user_code":"${user_code}","token":"tokencoba"}');

    Navigator.of(context).pop();

    if(getBlockInfo.Id != ""){
      Alert(
        context: context,
        title: "Alert",
        content: Text(getBlockInfo.Id),
        cancel: false,
        type: "warning"
      );
    } else {
      Alert(
        context: context,
        title: "Alert",
        content: Text("ERROR BRO"),
        cancel: false,
        type: "warning"
      );
    }

    setState(() {
      searchLoading = false;
    });
  }

  void submitValidation() {
    setState(() {
      customerIdController.text.isEmpty ? customerIdValid = true : customerIdValid = false;
    });

    if(!customerIdValid){
      getBlockInfo();
    }
  }

  Future<bool> willPopScope() async{
    // if (mCurrentIndex != 0) {
    //   setState(() {
    //     mCurrentIndex = 0;
    //   });
    // } else {
    //   if (isExit == false) {
    //     isExit = true;
    //     _scaffoldKey.currentState.showSnackBar(
    //       SnackBar(
    //         duration: Duration(seconds:1),
    //         content: Text(message["exitApps"]),
    //       )
    //     );
    //   } else if (isExit) {
    //     SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    //   }
    // }
    // return false;
  }

  Future<Null> refresh() async {
    // setState(() {
    //   dashboardListLoading = true;
    // });

    // initDashboardList();
    // await checkUser();
    
    // return null;
  }

}