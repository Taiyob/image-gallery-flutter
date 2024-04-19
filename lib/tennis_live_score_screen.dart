import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_firebase_project/firebase_messaging.dart';
import 'package:first_firebase_project/firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessagingService.initialize();
  print(await FirebaseMessagingService.getFCMToken());
  runApp(const OngoingMatch());
}

class TenisLiveScoreScreen extends StatefulWidget {
  const TenisLiveScoreScreen({super.key, required this.ID});

  final String ID;

  @override
  State<TenisLiveScoreScreen> createState() => _TenisLiveScoreScreenState();
}

class _TenisLiveScoreScreenState extends State<TenisLiveScoreScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LiveScoreScreen(
        docId: widget.ID,
      ),
    );
  }
}

class LiveScoreScreen extends StatefulWidget {
  const LiveScoreScreen({super.key, required this.docId});

  final String docId;

  @override
  State<LiveScoreScreen> createState() => _LiveScoreScreenState();
}

class _LiveScoreScreenState extends State<LiveScoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Screen'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(24),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('tennis')
                      .doc(widget.docId)
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }
                    final playerOneScore = snapshot.data?.get('player1') ?? '0';
                    final playerTwoScore = snapshot.data?.get('player2') ?? '0';
                    return Row(
                      children: [
                        _buildPlayerScore(
                            playerName: 'Player1', score: playerOneScore),
                        const SizedBox(
                          height: 50,
                          child: VerticalDivider(),
                        ),
                        _buildPlayerScore(
                            playerName: 'Player2', score: playerTwoScore),
                      ],
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScore(
      {required final String playerName, required final String score}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            score,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            playerName,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class OngoingMatch extends StatefulWidget {
  const OngoingMatch({super.key});

  @override
  State<OngoingMatch> createState() => _OngoingMatchState();
}

class _OngoingMatchState extends State<OngoingMatch> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TennisMatchListScreen(),
    );
  }
}

class TennisMatchListScreen extends StatefulWidget {
  const TennisMatchListScreen({super.key});

  @override
  State<TennisMatchListScreen> createState() => _TennisMatchListScreenState();
}

class _TennisMatchListScreenState extends State<TennisMatchListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Match'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('tennis').snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            return ListView.separated(
                itemCount: snapshot.data?.docs.length ?? 0,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  return ListTile(
                    title: Text(
                      doc.get('name'),
                    ),
                    subtitle: Text(doc.id),
                    trailing: const Icon(Icons.arrow_forward_outlined),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TenisLiveScoreScreen(
                            ID: doc.id,
                          ),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (_, __) => const Divider());
          }),
    );
  }
}
