import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:instaclone/services/data_service.dart';

import '../model/post_model.dart';
import '../services/utils_service.dart';

class MyFeedPage extends StatefulWidget {
  PageController pageController;
  MyFeedPage({Key? key, required this.pageController}) : super(key: key);

  @override
  _MyFeedPageState createState() => _MyFeedPageState();
}
class _MyFeedPageState extends State<MyFeedPage> {
  bool isLoading=false;
  List<Post> items=[];

  _apiLoadFeeds(){
    DataService.loadFeeds().then((value)=>{
      _resLoadFeeds(value),
    });
  }
  _resLoadFeeds(List<Post> posts){
    setState(() {
      items=posts;
    });
  }
  void _apiPostLike(Post post) async {
    setState(() {
      isLoading = true;
    });
    await DataService.likePost(post, true);
    setState(() {
      isLoading = false;
      post.liked = true;
    });
  }

  void _apiPostUnLike(Post post) async {
    setState(() {
      isLoading = true;
    });
    await DataService.likePost(post, false);
    setState(() {
      isLoading = false;
      post.liked = false;
    });
  }
  _actionRemovePost(Post post) async{
    var result= await Utils.dialogCommon(context, "Instagram", "Do you want to remove this post", false);
    if(result!=null&&result){
      setState(() {
        isLoading=true;
      });
      DataService.removePost(post).then((value) => {
        _apiLoadFeeds(),
      });
  }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiLoadFeeds();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Instagram", style: TextStyle(color: Colors.black, fontFamily: 'Billabong', fontSize: 25),
        ),
        actions: [
          IconButton(
              onPressed: (){
                widget.pageController.animateToPage(2, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
              },
              icon: const Icon(Icons.camera_alt, color: Color.fromRGBO(193, 53, 132, 1)),
          ),
        ],
      ),
    body: ListView.builder(
        itemCount: items.length,
          itemBuilder: (context, index){
          return _itemOfPost(items[index]);
          }
      ),
    );
  }
  Widget _itemOfPost(Post post){
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: const Image(
                        image: AssetImage("assets/images/ic_person.png"),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Text(post.fullname!, style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Text(post.date!,style: const TextStyle(
                            fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ],
                ),
                post.mine?
                IconButton(
                    onPressed: (){
                      _actionRemovePost(post);

                    },
                    icon: const Icon(SimpleLineIcons.options),
                ):const SizedBox.shrink(),
              ],
            ),
          ),
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
              imageUrl: post.img_post!,
              placeholder: (context, url)=> const Center(child: CircularProgressIndicator(),),
              errorWidget: (context, url, error)=> const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: (){
                        if(!post.liked){
                          _apiPostLike(post);
                        }else{
                          _apiPostUnLike(post);
                        }
                      },
                      icon: post.liked ? const Icon(FontAwesome.heart, color: Colors.red):const Icon(FontAwesome.heart_o),
                  ),
                  IconButton(
                    onPressed: (){},
                    icon: const Icon(Icons.share_outlined),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${post.caption}",
                    style: TextStyle(color: Colors.black),
                  )
                ]
              ),
              
            ),
          ),


        ],
      ),
    );
  }
}
