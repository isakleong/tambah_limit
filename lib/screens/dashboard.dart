import 'dart:async';
import 'dart:convert';
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

enum CustomerBlockedType { NotBlocked, BlockedShip, BlockedInvoice, BlockedAll }  

class Dashboard extends StatefulWidget {
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> with TickerProviderStateMixin {

  CustomerBlockedType customerBlockedType = CustomerBlockedType.NotBlocked;

  Result result;
  
  String _lastSelected = 'TAB: 0';
  String dashboardTitle = "Blok Pelanggan";
  int currentIndex = 0;

  String blockedTypeSelected = "";
  int selectedRadio = -1;

  bool customerIdValid = false;
  bool searchLoading = false;
  bool updateLoading = false;

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

    if(result != null){
      // final resultObject = jsonDecode(result.data.toString());
      // var blockedType = resultObject[0]["blocked"];

      // resultObject[0]["blocked"] == 3 ? blockedTypeSelected = "Blocked All" : resultObject[0]["blocked"] == 0 ? blockedTypeSelected = "Not Blocked" : ""; -- kalau diblock, pas running awal, value ndk muncul, sedangkan kalau diunblock, pindah focus, value keganti
      // selectedRadio = resultObject[0]["blocked"];
    }

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
                  validate: customerIdValid,
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
                  child: TextView("CARI", 3, color: Colors.white),
                  onTap: () {
                    getBlockInfo();
                  },
                ),
              ),
              blockInfoDetailWidgetList.length == 0
              ? 
              Container()
              :
              ListView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(0),
                physics: ScrollPhysics(),
                shrinkWrap: true,
                children: blockInfoDetailWidgetList,
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
    final _formKey = GlobalKey<FormState>();

    List<Widget> tempWidgetList = [];

    if(result != null){
      final resultObject = jsonDecode(result.data.toString());
      var blockedType;
      
      // printHelp(resultObject[0]["blocked"]);
      // resultObject[0]["Name"];

      // String blockedTypeSelected = "coba";
      // var blockedType = resultObject[0]["blocked"];

      if(selectedRadio == -1){
        blockedType = resultObject[0]["blocked"];
        // blockedType == 3 ? blockedTypeSelected = "Blocked All" : blockedType == 0 ? blockedTypeSelected = "Not Blocked" : blockedType == 1 ? blockedTypeSelected = "Blocked Ship" : blockedType == 2 ? "Blocked Invoice" : ""; //kalau diunblock value awal bisa muncul, namun waktu onchange radio, value gk keganti. kalau diblock, running awal, value ndk muncul
        if(blockedType == 3) {
          blockedTypeSelected = "Blocked All";
          selectedRadio = 3;
        } else if(blockedType == 2) {
          blockedTypeSelected = "Blocked Invoice HEHEHE";
          selectedRadio = 2;
        } else if(blockedType == 1) {
          blockedTypeSelected = "Blocked Ship";
          selectedRadio = 1;
        } else {
          blockedTypeSelected = "Not Blocked";
          selectedRadio = 0;
        }
      } else {
        blockedType = selectedRadio;
        // blockedType == 3 ? blockedTypeSelected = "Blocked All" : blockedType == 0 ? blockedTypeSelected = "Not Blocked" : blockedType == 1 ? blockedTypeSelected = "Blocked Ship" : "Blocked Invoice"; //kalau diunblock value awal bisa muncul, namun waktu onchange radio, value gk keganti. kalau diblock, running awal, value ndk muncul
        if(blockedType == 3) {
          blockedTypeSelected = "Blocked All";
        } else if(blockedType == 2) {
          blockedTypeSelected = "Blocked Invoice";
        } else if(blockedType == 1) {
          blockedTypeSelected = "Blocked Ship";
        } else {
          blockedTypeSelected = "Not Blocked";
        }
      }
      

      tempWidgetList.add(
        Container(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: TextFormField(
                    enabled: false,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Kode Pelanggan",
                      hintText: resultObject[0]["No_"],
                      icon: Icon(Icons.bookmark),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: Colors.black54, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: TextFormField(
                    enabled: false,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Nama Pelanggan",
                      hintText: resultObject[0]["Name"],
                      icon: Icon(Icons.people),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: Colors.black54, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: TextFormField(
                    style: TextStyle(color: Colors.red),
                    enabled: false,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Alamat Pelanggan",
                      hintText: resultObject[0]["Address"],
                      icon: Icon(Icons.location_on),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: Colors.black54, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: TextFormField(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List<Widget>.generate(4, (int index) {
                                    var typeTitle = "";
                                    if(index == 0){
                                      typeTitle = "Not Blocked";
                                    } else if(index == 1){
                                      typeTitle = "Blocked Ship";
                                    } else if(index == 2){
                                      typeTitle = "Blocked Invoice";
                                    } else if(index == 3){
                                      typeTitle = "Blocked All";
                                    }
                                    return ListTile(
                                      title: Text('${typeTitle}'),
                                      leading: Radio(
                                        value: index,
                                        groupValue: selectedRadio,
                                        onChanged: (int value) {
                                          setState((){
                                            selectedRadio = value;
                                            blockedTypeSelected = typeTitle;
                                            Navigator.of(context, rootNavigator: true).pop();
                                          } );
                                        },
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          );
                        }
                      );
                    },
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Status Block",
                      hintText: blockedTypeSelected, //tanya ce elisa
                      icon: Icon(Icons.block),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: Colors.black54, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: Button(
                      key: Key("submit"),
                      backgroundColor: config.darkOrangeColor,
                      child: TextView("UBAH", 3, caps: true,),
                      onTap: (){
                        blockedType != resultObject[0]["blocked"]
                        ?
                        Alert(
                          context: context,
                          title: "Alert",
                          content: Text("Apakah Anda yakin ingin menyimpan data?"),
                          cancel: true,
                          type: "warning",
                          defaultAction: () {
                            updateBlock();
                          }
                        )
                        :
                        Alert(
                          context: context,
                          title: "Alert",
                          content: Text("Mohon untuk melakukan perubahan data terlebih dahulu"),
                          cancel: false,
                          type: "warning"
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      );
    }

    return tempWidgetList;
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

  void updateBlock() async {
    setState(() {
      updateLoading = true;
    });

    Alert(context: context, loading: true, disableBackButton: true);

    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    String user_code = sharedPreferences.getString('user_code');

    //http://192.168.10.213/dbrudie-2-0-0/updateBlock.php?json={ "user_code" : "isak", "kode_customer" : "01A01010001" , "block_lama" : 3, "block_baru" : 0}

    final resultObject = jsonDecode(result.data.toString());
    var block_lama = resultObject[0]["blocked"];
    var block_baru = selectedRadio;

    Result result_ = await customerAPI.updateBlock(context, parameter: 'json={"kode_customer":"${customerIdController.text}","user_code":"${user_code}","block_lama":${block_lama},"block_baru":${block_baru}}');

    Navigator.of(context).pop();

    if(result.success == 1){
      Alert(
        context: context,
        title: "Alert",
        content: Text(result_.message),
        cancel: false,
        type: "success"
      );
    } else{
      Alert(
        context: context,
        title: "Alert",
        content: Text(result_.message),
        cancel: false,
        type: "warning"
      );
    }
    setState(() {
      updateLoading = false;
    });

  }

  void getBlockInfo() async {
    setState(() {
      customerIdController.text.isEmpty ? customerIdValid = true : customerIdValid = false;
    });

    if(!customerIdValid){
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        searchLoading = true;
      });

      Alert(context: context, loading: true, disableBackButton: true);

      SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
      final SharedPreferences sharedPreferences = await _sharedPreferences;
      String user_code = sharedPreferences.getString('user_code');

      Result result_ = await customerAPI.getBlockInfo(context, parameter: 'json={"kode_customer":"${customerIdController.text}","user_code":"${user_code}"}');

      Navigator.of(context).pop();

      if(result_.success == 1){
        // final products = jsonDecode(result.data.toString());
        // products[0]["Name"]

        setState(() {
          result = result_;
          selectedRadio = -1;
        });

        // showBlockInfoDetail(config);
      } else {
        Alert(
          context: context,
          title: "Alert",
          content: Text(result_.message),
          cancel: false,
          type: "warning"
        );
        setState(() {
          result = null;
        });
      }

      setState(() {
        searchLoading = false;
      });

    } else {
      setState(() {
        result = null;
      });
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