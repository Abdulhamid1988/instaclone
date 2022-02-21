
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../model/post_model.dart';
import '../services/data_service.dart';
import '../services/utils_service.dart';


class MyLikesPage extends StatefulWidget {
  const MyLikesPage({Key? key,}) : super(key: key);

  @override
  _MyLikesPageState createState() => _MyLikesPageState();
}

class _MyLikesPageState extends State<MyLikesPage> {
  List<Post> items=[];
  bool isLoading=false;

  void _apiLoadLikes() {
    setState(() {
      isLoading = true;
    });
    DataService.loadLikes().then((value) => {
      _resLoadLikes(value),
    });
  }

  void _resLoadLikes(List<Post> posts) {
    setState(() {
      items = posts;
      isLoading = false;
    });
  }
  void _apiPostUnLike(Post post) {
    setState(() {
      isLoading = true;
      post.liked = false;
    });
    DataService.likePost(post, false).then((value) => {
      _apiLoadLikes(),
    });
  }
  _actionRemovePost(Post post) async{
    var result= await Utils.dialogCommon(context, "Instagram", "Do you want to remove this post", false);
    if(result!=null&&result){
      setState(() {
        isLoading=true;
      });
      DataService.removePost(post).then((value) => {
        _apiLoadLikes(),
      });
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiLoadLikes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Likes", style: TextStyle(color: Colors.black, fontFamily: 'Billabong', fontSize: 25),
        ),

      ),

      body: Stack(
        children: [
          items.length>0?
          ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index){
                return _itemOfPost(items[index]);
              }
          ):const Center(
            child: Text("No Likes Posts"),
          ),
          isLoading ? const Center(
            child: CircularProgressIndicator(),
          ): const SizedBox.shrink(),
        ],
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
                      children: [
                        Text(post.fullname!,style: const TextStyle(
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
            imageUrl: post.img_post!,
            placeholder: (context, url)=> const CircularProgressIndicator(),
            errorWidget: (context, url, error)=> const Icon(Icons.error),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: (){
                      if(post.liked){
                        _apiPostUnLike(post);
                      }
                    },
                    icon: post.liked ? const Icon(FontAwesome.heart, color: Colors.red):const Icon(FontAwesome.heart_o),
                  ),
                  IconButton(
                    onPressed: (){},
                    icon: const Icon(FontAwesome.send),
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

