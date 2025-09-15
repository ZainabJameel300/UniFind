import 'package:flutter/material.dart';
import 'package:unifind/components/post.dart';
import '../components/filters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _postStream = FirebaseFirestore.instance
    .collection('Posts')
    .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    // search & notifications
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: const Color(0xFFF1F1F1),
                            ),
                            child: const Row(
                              children: [
                                
                                // search 
                                Icon(Icons.search),
                                SizedBox(width: 5.0,),
                                Text("Search Items", style: TextStyle(fontSize: 16.0),),
        
                                Spacer(),
        
                                // AI search (camera)
                                Icon(Icons.photo_camera_outlined),              
                              ],
                            ),
                          ),
                        ),
        
                        const SizedBox(width: 8.0),
                        
                        // notifications icon
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: const Color(0xFFF1F1F1),
                          ),
                          child: const Icon(Icons.notifications_outlined)
                        ),
                      ],
                    ), 
                    
                    const SizedBox(height: 4.0),
                    
                    // filters
                    const Filters(),
        
                    const SizedBox(height: 4.0),
                  ],
                ),
              ),
                    
              // line
              const SizedBox(
                width: double.infinity,
                child: Divider(color: Color(0xFF8C8C8C), thickness: 1, height: 1,),
              ),     
                  
              // posts 
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0,),
                  child: StreamBuilder(
                    stream: _postStream, 
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text("Error");
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: const CircularProgressIndicator());
                      }
                        
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index){
                          DocumentSnapshot data = snapshot.data!.docs.elementAt(index);
                            return Post(
                              // avatar: avatar, 
                              // username: username, 
                              uid: data["uid"], 
                              createdAt: data["date"], 
                              pic: data["picture"], 
                              title: data["title"], 
                              description: data["description"], 
                              date: data["date"], 
                              location: data["location"], 
                              status: data["claim_status"],
                            );
                        }
                      );
                    },
                  ),
                ),
              ),
              
            ],
          ),
        )
      ),
    );
  }
}