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

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowsSingleInstance.ensureSingleInstance(args, "custom_identifier", onSecondWindow: (args) {
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
  double defaultW = 0;
  double defaultH = 0;
  final String _pathDefaultAfterCrop = 'C:/Desktop/FolderCropImage';
  CropController controller = CropController(
    defaultCrop: const Rect.fromLTRB(0.2, 0.2, 0.8, 0.8),
  );
  Rect frameCrop = const Rect.fromLTRB(0.2, 0.2, 0.8, 0.8);
  File? fileDefault;
  late AnimationController controllerLoading;
  final List<XFile> _list = [];
  bool _dragging = false;
  Offset? offset;
  bool isShowLoading = false;
  bool isShowImageDefault = false;

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    controllerLoading.dispose();
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void initState() {
    // TODO: implement initState
    controllerLoading = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controllerLoading.repeat(reverse: true);
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
                if (!isShowImageDefault) {
                  chooseFileDefault();
                } else {
                  setState(() {
                    isShowImageDefault = false;
                    controller = CropController(
                      defaultCrop: frameCrop,
                    );
                    Future.delayed(const Duration(milliseconds: 100), () {
                      chooseFileDefault();
                    });
                  });
                }
              },
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Container(
                  margin: const EdgeInsets.all(10),
                  child: const Text('Tải 1 ảnh mẫu lên hoặc kéo vào để căn chỉnh kích thước cắt tại đây ...')),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  isShowImageDefault = !isShowImageDefault;
                  controller = CropController(
                    defaultCrop: frameCrop,
                  );
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
                  isShowImageDefault ? "Thu lại" : "Hiển thị mẫu",
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            (isShowImageDefault)
                ? Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      // width: widthSideOut,
                      margin: const EdgeInsets.only(top: 20),
                      // height: heightSideOut,
                      alignment: Alignment.center,
                      child: DropTarget(
                          onDragDone: (detail) async {
                            setState(() {
                              debugPrint('PHUCBV => onDragDone:');
                              fileDefault = File(detail.files.first.path ?? '');
                              // _list.addAll(detail.files);
                            });

                            for (final file in detail.files) {
                              debugPrint('  ${file.path} ${file.name}'
                                  '  ${await file.lastModified()}'
                                  '  ${await file.length()}'
                                  '  ${file.mimeType}');
                            }
                          },
                          onDragUpdated: (details) {
                            setState(() {
                              debugPrint('PHUCBV => onDragUpdated:');
                              offset = details.localPosition;
                            });
                          },
                          onDragEntered: (detail) {
                            setState(() {
                              debugPrint('PHUCBV => onDragEntered:');
                              _dragging = true;
                              offset = detail.localPosition;
                            });
                          },
                          onDragExited: (detail) {
                            setState(() {
                              debugPrint('PHUCBV => onDragExited:');
                              _dragging = false;
                              offset = null;
                            });
                          },
                          child: CropImage(
                            image: fileDefault != null
                                ? Image.file(
                                    fileDefault!,
                                    fit: BoxFit.fill,
                                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                      return Container(
                                        // width: widthSideOut,
                                        // height: heightSideOut,
                                        color: Colors.grey,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    "assets/images/img_demo1.jpg",
                                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                      return Container();
                                    },
                                  ),
                            controller: controller,
                            // alwaysShowThirdLines: true,
                            onCrop: (Rect r) async {
                              setState(() {
                                debugPrint('PHUCBV => onCrop: ${r}');
                                frameCrop = r;
                              });
                            },
                          )),
                    ))
                : Container(),
            const SizedBox(
              height: 20,
            ),
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
                              double wTP = (frameCrop.right - (frameCrop.left));
                              double hTP = (frameCrop.bottom - (frameCrop.top));
                              img.Image crop = img.copyCrop(newImage!, (frameCrop.left * w).toInt(),
                                  (frameCrop.top * h).toInt(), (wTP * w).toInt(), (hTP * h).toInt());
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
                        width: MediaQuery.of(context).size.width / 3,
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
                                          double wTP = (frameCrop.right - (frameCrop.left));
                                          double hTP = (frameCrop.bottom - (frameCrop.top));
                                          img.Image crop = img.copyCrop(newImage!, (frameCrop.left * w).toInt(),
                                              (frameCrop.top * h).toInt(), (wTP * w).toInt(), (hTP * h).toInt());
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
                                )),
                            const Text("Hoặc kéo file thả vào đây ", style: TextStyle(fontSize: 16))
                          ],
                        )))),
            if (isShowLoading == true)
              Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  value: controllerLoading.value,
                  color: Colors.blue,
                  strokeWidth: 10,
                  semanticsLabel: 'Linear progress indicator',
                ),
              ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () async {
                  await OpenFile.open(_pathDefaultAfterCrop);
                },
                child: const Align(alignment: Alignment.center, child: Text("Ảnh đã cắt xem tại đây !"))),
            const SizedBox(
              height: 30,
            )
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
        isShowImageDefault = true;
      });
    } else {
      if (fileDefault != null) {
        setState(() {
          isShowImageDefault = true;
        });
      }
      // User canceled the picker
    }
  }

  showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
