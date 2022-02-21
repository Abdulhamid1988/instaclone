import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instaclone/model/user_model.dart';
import 'package:instaclone/services/data_service.dart';
import 'package:instaclone/services/file_service.dart';
import 'package:instaclone/services/utils_service.dart';

import '../model/post_model.dart';
import '../services/auth_service.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool isLoading=false;
  String fullName = "", email = "", img_url = "";
  int axisCount = 1;
  List<Post> items=[];
  File? _image;
  int count_posts = 0, count_followers = 0, count_following = 0;
  var captionController=TextEditingController();
  final ImagePicker _picker = ImagePicker();

  _imgFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = File(image!.path);
    });
    _apiChangePhoto();
  }
  _imgFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = File(image!.path);
    });
    _apiChangePhoto();
  }
  _apiChangePhoto(){
    if(_image==null) return;
    setState(() {
      isLoading=true;
    });

    FileService.uploadUserImage(_image!).then((downloadUrl) => {
      _apiUpdateUser(downloadUrl!),

    });
  }
  _apiUpdateUser(String downloadUrl) async{

    User1 user1= await DataService.loadUser();
    user1.img_url=downloadUrl;
    await DataService.updateUser(user1);
    _apiLoadUser();
  }
  _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        }
    );
  }
  _apiLoadUser(){
    setState(() {
      isLoading=true;
    });
    DataService.loadUser().then((value) => {
      _showUserInfo(value),
    });
  }
  _showUserInfo(User1 user1){
    setState(() {
      isLoading=false;
      fullName=user1.fullname!;
      email=user1.email!;
      img_url=user1.img_url!;
      count_followers = user1.followers_count;
      count_following = user1.following_count;
    });
  }

  _apiLoadPosts(){
    DataService.loadPosts().then((value)=>{
      _resLoadPosts(value),
    });
  }
  _resLoadPosts(List<Post> posts){
    setState(() {
      items=posts;
      count_posts=items.length;
    });
  }
  _actionLogout() async{
    var result= await Utils.dialogCommon(context, "Instagram", "Do you want to LogOut?", false);
    if(result!=null&&result){
    AuthService.signOutUser(context);
    }
  }
  _actionRemovePost(Post post) async{
    var result= await Utils.dialogCommon(context, "Instagram", "Do you want to Remove this Post?", false);
    if(result!=null&&result){
      setState(() {
        isLoading=true;
      });
      DataService.removePost(post).then((value) => {
        _apiLoadPosts(),
      });
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiLoadUser();
    _apiLoadPosts();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Profile",
          style: TextStyle(color: Colors.black, fontFamily: "Billabong", fontSize: 25),),
        actions: [
          IconButton(
            onPressed: (){
              _actionLogout();
          },
            icon: const Icon(Icons.exit_to_app, color: Color.fromRGBO(193, 53, 132, 1)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(70),
                        border: Border.all(width: 1.5,color: Color.fromRGBO(193, 53, 132, 1),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: img_url==null||img_url.isEmpty
                            ? const Image(
                          image: AssetImage("assets/images/ic_person.png"),
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ):Image.network(img_url, width: 70, height: 70, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: (){
                          _showPicker(context);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Icon(Icons.add_circle, color: Colors.purple),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(fullName.toUpperCase(),style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                SizedBox(height: 3),
                Text(email,style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.normal),),

                Container(
                  height: 80,
                  child: Row(
                    children: [
                      Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(count_posts.toString(), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                                SizedBox(height: 3),
                                Text("Posts", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          )
                      ),
                      Container(width: 1, height: 20, color: Colors.grey.withOpacity(0.5),),
                      Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(count_followers.toString(), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                                SizedBox(height: 3),
                                Text("Followers", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          )
                      ),
                      Container(width: 1, height: 20, color: Colors.grey.withOpacity(0.5),),
                      Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(count_following.toString(), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                                SizedBox(height: 3),
                                Text("Following", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          )
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                axisCount = 1;
                              });
                            },
                            icon: Icon(Icons.list_alt),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                axisCount = 2;
                              });
                            },
                            icon: Icon(Icons.grid_view),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: axisCount),
                    itemCount: items.length,
                    itemBuilder: (context, index){
                      return _itemOfPost(items[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
          isLoading?const Center(
            child: CircularProgressIndicator(),
          ): SizedBox.shrink(),
        ],
      ),
    );
  }
  Widget _itemOfPost(Post post){
    return GestureDetector(
      onLongPress: (){
        _actionRemovePost(post);
      },
      child: Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: post.img_post!,
                width: double.infinity,
                placeholder: (context, url)=> const Center(child: CircularProgressIndicator(),),
                errorWidget: (context, url, error)=> Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 3),
            Text(post.caption!, style: TextStyle(color: Colors.black87.withOpacity(0.7)),maxLines: 2,),
          ],
        ),
      ),
    );

  }
}
