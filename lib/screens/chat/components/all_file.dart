import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/model/file.model.dart';

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
                            getIconForFileType(fileType),
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

  Icon getIconForFileType(String fileType) {
    switch (fileType) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue);
      case 'xlsx':
        return const Icon(Icons.table_chart, color: Colors.green);
      case 'pptx':
        return const Icon(Icons.slideshow, color: Colors.orange);
      case 'txt':
        return const Icon(Icons.text_fields, color: Colors.black);
      case 'zip':
      case 'rar':
        return const Icon(Icons.archive, color: Colors.yellow);
      case 'mp4':
        return const Icon(Icons.video_library, color: Colors.purple);
      default:
        return const Icon(Icons.insert_drive_file);
    }
  }
}
