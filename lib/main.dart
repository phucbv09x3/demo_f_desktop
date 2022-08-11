import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:file_picker_desktop/file_picker_desktop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, TextInputFormatter, rootBundle;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Choose File Crop Save By PhucBv'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<File> filesItemCrop = [];
  double topCrop = 150;
  double leftCrop = 200;
  double widthCrop = 400;
  double heightCrop = 300;
  double widthSideOut = 800;
  double heightSideOut = 600;
  double defaultW = 0;
  double defaultH = 0;
  TextEditingController _textEditingControllerWidth = TextEditingController();
  TextEditingController _textEditingControllerHeight = TextEditingController();
  TextEditingController _textEditingControllerWidthSideOut = TextEditingController();
  TextEditingController _textEditingControllerHeightSideOut = TextEditingController();
  final String _pathDefaultAfterCrop = 'C:/Desktop/FolderCropImage';

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  showDialogSetting(context);
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)), // Set rounded corner radius
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 20, left: 20),
                  child: const Text(
                    "Cài đặt ảnh cắt",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                            insetPadding: const EdgeInsets.only(left: 20, right: 20),
                            child: Container(
                              height: 300,
                              width: 400,
                              margin: EdgeInsets.only(top: 19),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    child: const Text(
                                      "Chọn thông số",
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                    margin: EdgeInsets.only(top: 40),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    // width: 200,
                                    child: Row(
                                      children: [
                                        const Expanded(
                                            child: Text(
                                          "Chiều rộng",
                                          style: TextStyle(fontSize: 18),
                                        )),
                                        Expanded(
                                          child: TextField(
                                            controller: _textEditingControllerWidthSideOut,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.digitsOnly
                                            ],
                                            decoration: const InputDecoration(hintText: "Nhập chiều rộng (> 0)"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    // width: 200,
                                    child: Row(
                                      children: [
                                        const Expanded(
                                            child: Text(
                                          "Chiều cao",
                                          style: TextStyle(fontSize: 18),
                                        )),
                                        Expanded(
                                          child: TextField(
                                            controller: _textEditingControllerHeightSideOut,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.digitsOnly
                                            ],
                                            decoration: const InputDecoration(hintText: "Nhập chiều cao (> 0) "),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      defaultW = MediaQuery.of(context).size.width;
                                      defaultH = MediaQuery.of(context).size.height;
                                      double widthSideOutNew = double.parse(
                                          _textEditingControllerWidthSideOut.text.isEmpty
                                              ? '0'
                                              : _textEditingControllerWidthSideOut.text);
                                      double heightSideOutNew = double.parse(
                                          _textEditingControllerHeightSideOut.text.isEmpty
                                              ? '0'
                                              : _textEditingControllerHeightSideOut.text);
                                      print("checkW : ${widthSideOutNew}");
                                      if(widthSideOutNew == 0 || heightSideOutNew == 0) {
                                        showMessage(context, "Vui lòng nhập đủ thông tin ");
                                      } else if (widthSideOutNew > defaultW) {
                                        showMessage(context, "Chiều rộng phải nhỏ hơn $defaultW");
                                      } else if (heightSideOutNew > defaultH) {
                                        showMessage(context, "Chiều cao phải nhỏ hơn -> $defaultW");
                                      } else {
                                        Navigator.pop(context);
                                        setState(() {
                                          widthSideOut = widthSideOutNew;
                                          heightSideOut = heightSideOutNew;
                                          topCrop = (heightSideOut - heightCrop) / 2;
                                          leftCrop = (widthSideOut - widthCrop) / 2;
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(4.0)), // Set rounded corner radius
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.only(top: 20, left: 20),
                                      child: const Text(
                                        "Xác nhận",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ));
                      });
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)), // Set rounded corner radius
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 20, left: 20),
                  child: const Text(
                    "Cài đặt ảnh hiển thị",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                    child: filesItemCrop.isEmpty
                        ? Stack(
                            children: [
                              Container(
                                width: widthSideOut,
                                height: heightSideOut,
                                color: Colors.grey,
                                alignment: Alignment.bottomCenter,
                                padding: const EdgeInsets.all(10),
                                child: (filesItemCrop.isEmpty)
                                    ? InkWell(
                                        onTap: () async {
                                          chooseFile();
                                          // String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                                        },
                                        child: const Text("Tải ảnh lên tại đây ..."),
                                      )
                                    : Container(),
                              ),
                              Positioned(
                                  top: topCrop,
                                  left: leftCrop,
                                  child: Container(
                                    width: widthCrop,
                                    height: heightCrop,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(width: 1.0, color: Colors.black54),
                                      // borderRadius: BorderRadius.all(Radius.circular(4.0)), // Set rounded corner radius
                                    ),
                                  )),
                            ],
                          )
                        : Container(
                            width: widthSideOut,
                            alignment: Alignment.center,
                            child: ListView.builder(
                              itemCount: filesItemCrop.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, i) {
                                return itemCrop(filesItemCrop[i]);
                              },
                            ))),
              ),
              if (filesItemCrop.isNotEmpty)
                InkWell(
                  onTap: () async {
                    _save();
                    showMessage(context, "Ảnh được lưu ở C:/Desktop/FolderCropImage");
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(4.0)), // Set rounded corner radius
                      ),
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(top: 20, left: 20),
                      child: const Text(
                        "Lưu",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
  }

  Widget itemCrop(File file) {
    return Stack(
      children: [
        Image.file(
          file!,
          width: widthSideOut,
          height: heightSideOut,
          alignment: Alignment.center,
          fit: BoxFit.fill,
        ),
        Positioned(
            top: topCrop,
            left: leftCrop,
            child: Container(
              width: widthCrop,
              height: heightCrop,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 1.0, color: Colors.black54),
              ),
            ))
      ],
    );
  }

  void chooseFile() async {
    filesItemCrop.clear();
    try {
      var result = await pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          filesItemCrop = result.paths.map((path) => File(path!)).toList();
        });
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print(e);
    }
  }

  _save() async {
    await Directory(_pathDefaultAfterCrop).create();
    filesItemCrop.forEach((element) async {
      final xpath = element.path ?? '';
      final bytes = await File(xpath).readAsBytes();
      final img.Image? newImage = img.decodeImage(bytes);
      int w = newImage?.width ?? 0;
      int h = newImage?.height ?? 0;

      img.Image crop = img.copyCrop(newImage!, w * leftCrop ~/ widthSideOut, h * topCrop ~/ heightSideOut,
          w * widthCrop ~/ widthSideOut, h * heightCrop ~/ heightSideOut);

      var jpg = img.encodeJpg(crop);
      File("$_pathDefaultAfterCrop/File_crop_by_phucbv_${DateTime.now().millisecondsSinceEpoch}.png")
          .writeAsBytesSync(jpg);
    });
    filesItemCrop.clear();
    setState(() {});
  }

  void showDialogSetting(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              insetPadding: const EdgeInsets.only(left: 20, right: 20),
              child: Container(
                height: 300,
                width: 400,
                margin: EdgeInsets.only(top: 19),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: const Text(
                        "Chọn thông số cắt ảnh",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      margin: EdgeInsets.only(top: 40),
                    ),
                    SizedBox(
                      height: 40,
                      // width: 200,
                      child: Row(
                        children: [
                          const Expanded(
                              child: Text(
                            "Chiều rộng",
                            style: TextStyle(fontSize: 18),
                          )),
                          Expanded(
                            child: TextField(
                              controller: _textEditingControllerWidth,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(hintText: "Nhập chiều rộng "),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      // width: 200,
                      child: Row(
                        children: [
                          const Expanded(
                              child: Text(
                            "Chiều cao",
                            style: TextStyle(fontSize: 18),
                          )),
                          Expanded(
                            child: TextField(
                              controller: _textEditingControllerHeight,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(hintText: "Nhập chiều cao "),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        double widthCropNew = double.parse(_textEditingControllerWidth.text);
                        double heightCropNew = double.parse(_textEditingControllerHeight.text);
                        if (widthCropNew > widthSideOut) {
                          showMessage(context, "Chiều rộng phải nhỏ hơn $widthSideOut");
                        } else if (heightCropNew > heightSideOut) {
                          showMessage(context, "Chiều cao phải nhỏ hơn $heightSideOut");
                        } else {
                          Navigator.pop(context);
                          setState(() {
                            widthCrop = widthCropNew;
                            heightCrop = heightCropNew;
                            topCrop = (heightSideOut - heightCrop) / 2;
                            leftCrop = (widthSideOut - widthCrop) / 2;
                          });
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)), // Set rounded corner radius
                        ),
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(top: 20, left: 20),
                        child: const Text(
                          "Xác nhận",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    )
                  ],
                ),
              ));
        });
  }

  showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
