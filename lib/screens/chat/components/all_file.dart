import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/file.model.dart';
import 'package:zalo_app/services/api_service.dart';

class AllFileScreen extends StatefulWidget {
  const AllFileScreen({super.key, this.files});
  final List<FileModel>? files;

  @override
  State<AllFileScreen> createState() => AllFileScreenState();
}

class AllFileScreenState extends State<AllFileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<FileModel>? files = [];
  late List<FileModel>? fileImg = [];
  late List<FileModel>? filesAnother = [];

  @override
  void initState() {
    super.initState();
    for (var file in widget.files!) {
      String fileType = file.path!.split('.').last;

      if (fileType == 'jpg' ||
          fileType == 'jpeg' ||
          fileType == 'png' ||
          fileType == 'gif' ||
          fileType == "webp") {
        fileImg?.add(file);
      } else if (fileType != "mp3") {
        filesAnother?.add(file);
      }
    }
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quay lại"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        //style for appbar
        backgroundColor: Colors.blue,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Ảnh'),
                  Tab(text: 'File'),
                ],
                labelColor: Colors.black,
                unselectedLabelStyle: const TextStyle(
                  color: Colors.grey,
                ),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                indicatorColor: Colors.blue,
              ),
            ),
            Expanded(
              child: TabBarView(
                dragStartBehavior: DragStartBehavior.start,
                controller: _tabController,
                children: [
                  GridView.count(crossAxisCount: 3, children: [
                    for (var file in fileImg!)
                      Container(
                        margin: const EdgeInsets.all(5),
                        child: GestureDetector(
                          onTap: () {
                            GoRouter.of(context).pushNamed(
                                MyAppRouteConstants.fullRouteName,
                                extra: file.path);
                          },
                          child: Image.network(
                            file.path!,
                            width: size.width * 0.5,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                  ]),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      itemCount: filesAnother?.length,
                      itemBuilder: (context, index) {
                        String fileType =
                            filesAnother![index].path!.split('.').last;

                        return Row(
                          children: [
                            if (fileType == 'pdf')
                              const Icon(Icons.picture_as_pdf)
                            else if (fileType == 'docx')
                              const Icon(Icons.description)
                            else if (fileType == 'xlsx')
                              const Icon(Icons.table_chart)
                            else if (fileType == 'pptx')
                              const Icon(Icons.slideshow)
                            else if (fileType == 'txt')
                              const Icon(Icons.text_fields)
                            else if (fileType == 'zip')
                              const Icon(Icons.archive)
                            else if (fileType == 'rar')
                              const Icon(Icons.archive)
                            else if (fileType == 'mp4')
                              const Icon(Icons.video_library)
                            else
                              const Icon(Icons.insert_drive_file),
                            Expanded(
                              child: ListTile(
                                title: Text(filesAnother![index].filename!),
                                subtitle: Text(filesAnother![index].size),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                //config download file
                              },
                              child: const Icon(Icons.download),
                            )
                          ],
                        );
                      },
                    ),
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
