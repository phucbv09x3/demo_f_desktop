import 'dart:io';

import 'package:crop_image/crop_image.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker_desktop/file_picker_desktop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

void main(List<String> args)async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowsSingleInstance.ensureSingleInstance(
      args,
      "custom_identifier",
      onSecondWindow: (args) {
        print("checkAr : ${args}");
      });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Cắt ảnh'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  List<File> filesItemCrop = [];
  double topCrop = 150;
  double leftCrop = 200;
  double widthCrop = 400;
  double heightCrop = 300;
  double widthSideOut = 800;
  double heightSideOut = 600;
  double defaultW = 0;
  double defaultH = 0;
  String _pathDefaultAfterCrop = 'C:/Desktop/FolderCropImage';
  var controller = CropController(
    aspectRatio: 1.5,
    defaultCrop: const Rect.fromLTRB(0.2, 0.2, 0.8, 0.8),
  );
  Rect _rect = Rect.fromLTRB(0.2, 0.2, 0.8, 0.8);
  File? fileDefault;
  late AnimationController controller1;
  final List<XFile> _list = [];
  bool _dragging = false;
  Offset? offset;
  bool isShowLoading = false;
  TextEditingController _textEditingControllerWidthSideOut = TextEditingController();
  TextEditingController _textEditingControllerHeightSideOut = TextEditingController();
  bool isShowSetting = false;

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    controller1.dispose();
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void initState() {
    // TODO: implement initState
    controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controller1.repeat(reverse: true);
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
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
            Container(
                margin: const EdgeInsets.all(10),
                child: const Text("Vui lòng di chuyển khung bên trong ảnh để cài đặt thông số cho ảnh được cắt")),
            InkWell(
              onTap: () {
                chooseFileDefault();
              },
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Container(
                  margin: const EdgeInsets.all(10),
                  child: const Text('Tải 1 ảnh mẫu lên hoặc kéo vào để căn chỉnh kích thước cắt tại đây ...')),
            ),
            InkWell(
              onTap: () {
                showDialogSetting(context);
              },
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
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
            InkWell(
              onTap: () {
                setState(() {
                  isShowSetting = !isShowSetting;
                  if (isShowSetting) {
                    controller = CropController(
                      aspectRatio: 1.5,
                      defaultCrop: _rect,
                    );
                  }
                });
              },
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(4.0)), // Set rounded corner radius
                ),
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 20, left: 20),
                child: Text(
                  isShowSetting ? "Thu lại" : "Hiển thị mẫu",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            (isShowSetting)
                ? Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: widthSideOut,
                      margin: const EdgeInsets.only(top: 20),
                      height: heightSideOut,
                      alignment: Alignment.center,
                      child: DropTarget(
                          onDragDone: (detail) async {
                            setState(() {
                              fileDefault = File(detail.files.first.path ?? '');
                              // _list.addAll(detail.files);
                            });

                            debugPrint('onDragDone:');
                            for (final file in detail.files) {
                              debugPrint('  ${file.path} ${file.name}'
                                  '  ${await file.lastModified()}'
                                  '  ${await file.length()}'
                                  '  ${file.mimeType}');
                            }
                          },
                          onDragUpdated: (details) {
                            setState(() {
                              offset = details.localPosition;
                            });
                          },
                          onDragEntered: (detail) {
                            setState(() {
                              _dragging = true;
                              offset = detail.localPosition;
                            });
                          },
                          onDragExited: (detail) {
                            setState(() {
                              _dragging = false;
                              offset = null;
                            });
                          },
                          child: CropImage(
                            image: fileDefault != null
                                ? Image.file(
                                    fileDefault!,
                                    fit: BoxFit.fill,
                                    width: widthSideOut,
                                    height: heightSideOut,
                                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                      return Container(
                                        width: widthSideOut,
                                        height: heightSideOut,
                                        color: Colors.grey,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    "assets/images/img_demo1.jpg",
                                    width: widthSideOut,
                                    height: heightSideOut,
                                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                      return Container(
                                        width: widthSideOut,
                                        height: heightSideOut,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                            controller: controller,
                            // alwaysShowThirdLines: true,
                            onCrop: (Rect r) async {
                              setState(() {
                                _rect = r;
                                controller = CropController(
                                  aspectRatio: 1.5,
                                  defaultCrop: _rect,
                                );
                              });
                            },
                          )),
                    ))
                : Container(),
            SizedBox(height: 20,),
            Align(
                alignment: Alignment.center,
                child: DropTarget(
                    onDragDone: (detail) async {
                      await Directory(_pathDefaultAfterCrop).create();
                      setState(() {
                        isShowLoading = true;
                        _list.clear();
                        _list.addAll(detail.files);
                        if (_list.isNotEmpty) {
                          try {
                            _list.forEach((element) async {
                              final xpath = element.path;
                              final bytes = await File(xpath).readAsBytes();
                              final img.Image? newImage = img.decodeImage(bytes);

                              int w = newImage?.width ?? 0;
                              int h = newImage?.height ?? 0;
                              double wTP = (_rect.right - (_rect.left));
                              double hTP = (_rect.bottom - (_rect.top));
                              img.Image crop = img.copyCrop(newImage!, (_rect.left * w).toInt(),
                                  (_rect.top * h).toInt(), (wTP * w).toInt(), (hTP * h).toInt());
                              final jpg = img.encodeJpg(crop);
                              File("$_pathDefaultAfterCrop/File_crop_by_phucbv_${DateTime.now().millisecondsSinceEpoch}.png")
                                  .writeAsBytesSync(jpg);
                            });
                            showMessage(context, "Thành công");
                          } catch (e) {
                            showMessage(context, "Có lỗi xảy ra");
                          }
                        }
                        isShowLoading = false;
                      });

                      debugPrint('onDragDone:');
                      for (final file in detail.files) {
                        debugPrint('  ${file.path} ${file.name}'
                            '  ${await file.lastModified()}'
                            '  ${await file.length()}'
                            '  ${file.mimeType}');
                      }
                    },
                    onDragUpdated: (details) {
                      setState(() {
                        offset = details.localPosition;
                      });
                    },
                    onDragEntered: (detail) {
                      setState(() {
                        _dragging = true;
                        offset = detail.localPosition;
                      });
                    },
                    onDragExited: (detail) {
                      setState(() {
                        _dragging = false;
                        offset = null;
                      });
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width  / 3,
                        height: 300,
                        color: Colors.blueGrey,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                                onTap: () async {
                                  setState(() async {
                                    await Directory(_pathDefaultAfterCrop).create();
                                    isShowLoading = true;
                                    var listFile = await chooseFile(); //ok
                                    if (listFile.isNotEmpty) {
                                      try {
                                        listFile.forEach((element) async {
                                          final xpath = element.path;
                                          final bytes = await File(xpath).readAsBytes();
                                          final img.Image? newImage = img.decodeImage(bytes);

                                          int w = newImage?.width ?? 0;
                                          int h = newImage?.height ?? 0;
                                          double wTP = (_rect.right - (_rect.left));
                                          double hTP = (_rect.bottom - (_rect.top));
                                          img.Image crop = img.copyCrop(newImage!, (_rect.left * w).toInt(),
                                              (_rect.top * h).toInt(), (wTP * w).toInt(), (hTP * h).toInt());
                                          final jpg = img.encodeJpg(crop);
                                          File("$_pathDefaultAfterCrop/File_crop_by_phucbv_${DateTime.now().millisecondsSinceEpoch}.png")
                                              .writeAsBytesSync(jpg);
                                        });
                                        showMessage(context, "Thành công");
                                      } catch (e) {
                                        showMessage(context, "Có lỗi xảy ra");
                                      }
                                    }
                                    isShowLoading = false;
                                  });
                                },
                                child: Container(
                                  width: 200,
                                  margin: EdgeInsets.only(bottom: 10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(4.0)), // Set rounded corner radius
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.folder,
                                        color: Colors.black,
                                        size: 40,
                                      ),
                                      Text(
                                        " Chọn các file",
                                        style: TextStyle(fontSize: 20),
                                      )
                                    ],
                                  ),
                                )
                            ),
                            const Text("Hoặc kéo file thả vào đây ", style: TextStyle(fontSize: 16))
                          ],
                        )))),
            if (isShowLoading == true)
              Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  value: controller1.value,
                  color: Colors.blue,
                  strokeWidth: 10,
                  semanticsLabel: 'Linear progress indicator',
                ),
              ),
            SizedBox(height: 20,),
            InkWell(
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () async {
                  await OpenFile.open(_pathDefaultAfterCrop);
                },
                child: Align(alignment: Alignment.center, child: Text("Ảnh đã cắt xem tại đây !"))),
            SizedBox(height: 30,)
          ],
        )));
  }

  Future<List<File>> chooseFile() async {
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
    return filesItemCrop;
  }

  void chooseFileDefault() async {
    var result = await pickFiles(
      allowMultiple: false,
    );
    // FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path ?? '');
      setState(() {
        fileDefault = file;
      });
    } else {
      // User canceled the picker
    }
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
                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(hintText: "Nhập chiều rộng (> 100)"),
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
                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(hintText: "Nhập chiều cao (> 100) "),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        defaultW = MediaQuery.of(context).size.width;
                        defaultH = MediaQuery.of(context).size.height;
                        double widthSideOutNew = double.parse(_textEditingControllerWidthSideOut.text.isEmpty
                            ? '0'
                            : _textEditingControllerWidthSideOut.text);
                        double heightSideOutNew = double.parse(_textEditingControllerHeightSideOut.text.isEmpty
                            ? '0'
                            : _textEditingControllerHeightSideOut.text);
                        print("checkW : ${widthSideOutNew}");
                        if (widthSideOutNew == 0 || heightSideOutNew == 0) {
                          showMessage(context, "Vui lòng nhập đủ thông tin ");
                        } else if (widthSideOutNew > defaultW) {
                          showMessage(context, "Chiều rộng phải nhỏ hơn $defaultW");
                        } else if (heightSideOutNew > defaultH) {
                          showMessage(context, "Chiều cao phải nhỏ hơn -> $defaultW");
                        } else if (heightSideOutNew < 100) {
                          showMessage(context, "Chiều cao phải lớn hơn 100");
                        } else if (widthSideOutNew < 100) {
                          showMessage(context, "Chiều rộng phải lớn hơn 100");
                        } else {
                          Navigator.pop(context);
                          setState(() {
                            widthSideOut = widthSideOutNew;
                            heightSideOut = heightSideOutNew;
                            // topCrop = (heightSideOut - heightCrop) / 2;
                            // leftCrop = (widthSideOut - widthCrop) / 2;
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
