// main.dart
// YouTube-like clone — single-file Flutter app
// Contains: responsive YouTube-style UI + lab exercise features mapped.
// No external packages required.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// -----------------------------
// Models
// -----------------------------
class Video {
  final String id;
  final String title;
  final String channel;
  final int views;
  final Duration duration;
  final String thumbnailKey; // used to pick a color placeholder
  final String description;

  Video({
    required this.id,
    required this.title,
    required this.channel,
    required this.views,
    required this.duration,
    required this.thumbnailKey,
    required this.description,
  });
}

class Comment {
  final String id;
  final String author;
  final String text;
  final DateTime time;
  Comment({required this.id, required this.author, required this.text, required this.time});
}

// -----------------------------
// Simulated API (async) - Future.delayed
// -----------------------------
Future<List<Video>> fetchTrending() async {
  debugPrint('fetchTrending() called');
  await Future.delayed(const Duration(milliseconds: 600));
  final rng = Random(42);
  final titles = [
    'Flutter: Build responsive UIs',
    'Sorting algorithms visualized',
    'Visual Notes — mind mapping',
    'Async patterns in Dart',
    'Provider vs InheritedWidget',
    'Designing cool UIs',
    'Dart tips & tricks',
    'Performance optimization'
  ];
  final channels = ['DevTV', 'AlgoHub', 'NoteLab', 'AsyncGeek', 'StateWire', 'DesignPro', 'DartDaily', 'PerfFix'];
  return List.generate(12, (i) {
    final d = Duration(minutes: 2 + rng.nextInt(10), seconds: rng.nextInt(60));
    return Video(
      id: 'vid_$i',
      title: titles[i % titles.length],
      channel: channels[i % channels.length],
      views: 1000 * (i + 5) + rng.nextInt(40000),
      duration: d,
      thumbnailKey: (i % 6).toString(),
      description: 'This is a simulated description for ${titles[i % titles.length]}. Demo video for lab exercises.',
    );
  });
}

Future<Map<String, dynamic>> fetchVideoDetails(String vid) async {
  debugPrint('fetchVideoDetails($vid)');
  await Future.delayed(const Duration(milliseconds: 350));
  final rng = Random(vid.hashCode);
  final comments = List.generate(4 + rng.nextInt(6), (i) {
    return Comment(
      id: '$vid-c$i',
      author: ['Alice', 'Bob', 'Carol', 'Dave', 'Eve'][i % 5],
      text: ['Great video!', 'Very helpful', 'Please cover X next', 'Thanks!'][i % 4],
      time: DateTime.now().subtract(Duration(minutes: (i + 1) * 11)),
    );
  });
  final related = await fetchTrending();
  return {'comments': comments, 'related': related};
}

// -----------------------------
// App State (ChangeNotifier + InheritedWidget provider-like)
// -----------------------------
class AppState extends ChangeNotifier {
  List<Video> trending = [];
  bool loading = false;

  // playback
  Video? current;
  Duration position = Duration.zero;
  bool playing = false;
  Timer? _playTimer;

  // UI state
  bool darkMode = false;
  int bottomIndex = 0;

  // user data
  List<String> favorites = [];
  List<String> history = [];
  Map<String, List<Comment>> comments = {}; // keyed by video id

  // search/filter
  String query = '';
  String activeFilter = 'All';

  AppState() {
    _load();
  }

  Future<void> _load() async {
    await loadTrending();
  }

  Future<void> loadTrending() async {
    loading = true;
    notifyListeners();
    trending = await fetchTrending();
    loading = false;
    notifyListeners();
  }

  void toggleTheme() {
    darkMode = !darkMode;
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  void setFilter(String f) {
    activeFilter = f;
    notifyListeners();
  }

  Future<void> openVideo(Video v) async {
    current = v;
    position = Duration.zero;
    playing = false;
    history.insert(0, v.id);
    if (history.length > 100) history.removeLast();
    notifyListeners();
    final det = await fetchVideoDetails(v.id);
    comments[v.id] = List<Comment>.from(det['comments'] as List<Comment>);
    notifyListeners();
  }

  void play() {
    if (current == null) return;
    if (playing) return;
    playing = true;
    _playTimer?.cancel();
    _playTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (current == null) return;
      position += const Duration(seconds: 1);
      if (position >= current!.duration) {
        position = current!.duration;
        pause();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    playing = false;
    _playTimer?.cancel();
    _playTimer = null;
    notifyListeners();
  }

  void seekTo(Duration t) {
    if (current == null) return;
    if (t < Duration.zero) {
      position = Duration.zero;
    } else if (t > current!.duration) {
      position = current!.duration;
    } else {
      position = t;
    }
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else { // Fixed: added block for else statement
      favorites.add(id);
    }
    notifyListeners();
  }

  void addComment(String vid, Comment c) {
    comments.putIfAbsent(vid, () => []);
    comments[vid]!.insert(0, c);
    notifyListeners();
  }

  void setBottomIndex(int i) {
    bottomIndex = i;
    notifyListeners();
  }

  void disposeState() {
    _playTimer?.cancel();
  }
}

class _AppProvider extends InheritedWidget {
  final AppState state;
  // Fix: Explicitly define Key? key and pass it to super() to resolve the optional parameter error
  const _AppProvider({required this.state, required super.child, Key? key}) : super(key: key);
  static AppState of(BuildContext ctx) {
    final provider = ctx.dependOnInheritedWidgetOfExactType<_AppProvider>();
    assert(provider != null, '_AppProvider missing');
    return provider!.state;
  }

  @override
  bool updateShouldNotify(covariant _AppProvider oldWidget) => true;
}

// -----------------------------
// Main
// -----------------------------
void main() {
  runApp(YouTubeCloneApp());
}

class YouTubeCloneApp extends StatefulWidget {
  @override
  State<YouTubeCloneApp> createState() => _YouTubeCloneAppState();
}

class _YouTubeCloneAppState extends State<YouTubeCloneApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.disposeState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppProvider(
      state: _state,
      child: AnimatedBuilder(
        animation: _state,
        builder: (c, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'YouTube-Lite Clone',
            theme: ThemeData(
              brightness: _state.darkMode ? Brightness.dark : Brightness.light,
              primarySwatch: Colors.red,
              useMaterial3: true,
            ),
            home: ShellScreen(),
          );
        },
      ),
    );
  }
}

// -----------------------------
// Shell: AppBar like YouTube, Body, BottomNav
// -----------------------------
class ShellScreen extends StatefulWidget {
  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  late AppState st;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    st = _AppProvider.of(context);
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => st.setQuery(q));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1000;
    final isNarrow = width < 700;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleSpacing: 8,
        title: Row(children: [
          // YouTube-like logo block
          Row(children: [
            Icon(Icons.play_circle_fill, color: Colors.red, size: 28),
            const SizedBox(width: 6),
            Text('YouTube', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color)),
          ]),
          const SizedBox(width: 12),
          // search box (responsive)
          Expanded(
            child: SizedBox(
              height: 42,
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice search simulated'))), icon: const Icon(Icons.mic)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // action icons
          Row(children: [
            IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create simulated'))), icon: const Icon(Icons.add_box_outlined)),
            IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications simulated'))), icon: const Icon(Icons.notifications_none)),
            // profile avatar placeholder
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile tapped'))),
              child: CircleAvatar(backgroundColor: Colors.grey.shade600, child: const Icon(Icons.person)),
            )
          ])
        ]),
      ),
      drawer: isNarrow ? Drawer(child: _buildDrawer()) : null,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isNarrow ? 6 : 12, vertical: 8),
          child: isWide
              ? Row(children: [
                  SizedBox(width: 220, child: _leftRail()), // left rail like YouTube desktop
                  const SizedBox(width: 12),
                  Expanded(child: _MainFeed()),
                  const SizedBox(width: 12),
                  SizedBox(width: 360, child: _RightRail()),
                ])
              : Column(children: [
                  Expanded(child: _MainFeed()),
                  if (!isNarrow) const SizedBox(height: 8),
                ]),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: st.bottomIndex,
        onTap: (i) => st.setBottomIndex(i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.subscriptions), label: 'Subscriptions'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Library'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload simulated'))),
        child: const Icon(Icons.video_call),
      ),
    );
  }

  Widget _buildDrawer() {
    return ListView(padding: EdgeInsets.zero, children: [
      DrawerHeader(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('YouTube Clone'), Text('Demo app for lab')])),
      ListTile(leading: const Icon(Icons.home), title: const Text('Home')),
      ListTile(leading: const Icon(Icons.explore), title: const Text('Explore')),
      ListTile(leading: const Icon(Icons.subscriptions), title: const Text('Subscriptions')),
      const Divider(),
      const Padding(padding: EdgeInsets.all(8.0), child: Text('Library')),
      ListTile(leading: const Icon(Icons.history), title: const Text('History')),
      ListTile(leading: const Icon(Icons.download), title: const Text('Downloads')),
    ]);
  }

  Widget _leftRail() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListTile(leading: const Icon(Icons.home), title: const Text('Home')),
      ListTile(leading: const Icon(Icons.explore), title: const Text('Explore')),
      ListTile(leading: const Icon(Icons.subscriptions), title: const Text('Subscriptions')),
      const Divider(),
      const Padding(padding: EdgeInsets.all(8.0), child: Text('Subscriptions', style: TextStyle(fontWeight: FontWeight.bold))),
      Expanded(
        child: ListView.builder(
          itemCount: min(6, st.trending.length),
          itemBuilder: (_, i) {
            final v = st.trending[i];
            return ListTile(leading: CircleAvatar(backgroundColor: Colors.primaries[i % Colors.primaries.length]), title: Text(v.channel, style: const TextStyle(fontSize: 13)));
          },
        ),
      ),
    ]);
  }
}

// -----------------------------
// Main Feed (list of videos) — looks like YouTube feed
// -----------------------------
class _MainFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final st = _AppProvider.of(context);
    return AnimatedBuilder(
      animation: st,
      builder: (_, __) {
        if (st.loading) return const Center(child: CircularProgressIndicator());
        // search & filter
        final q = st.query.trim().toLowerCase();
        final filtered = st.trending.where((v) {
          if (st.activeFilter != 'All' && !v.title.toLowerCase().contains(st.activeFilter.toLowerCase()) && !v.channel.toLowerCase().contains(st.activeFilter.toLowerCase())) return false;
          if (q.isEmpty) return true;
          return v.title.toLowerCase().contains(q) || v.channel.toLowerCase().contains(q);
        }).toList();

        // large hero at top (simulated 'recommended')
        return RefreshIndicator(
          onRefresh: () => st.loadTrending(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filtered.length + 1,
            itemBuilder: (ctx, idx) {
              if (idx == 0) return _heroCard(context, filtered.isNotEmpty ? filtered[0] : null);
              final v = filtered[idx - 1];
              return VideoListTile(video: v, index: idx - 1);
            },
          ),
        );
      },
    );
  }

  Widget _heroCard(BuildContext context, Video? v) {
    if (v == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _AppProvider.of(context).openVideo(v),
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(aspectRatio: 16 / 9, child: Stack(children: [
            // MODIFIED: Use FadeInImage for thumbnail
            FadeInImage.assetNetwork(
              placeholder: 'assets/loading.gif', // Placeholder asset (replace or remove if needed)
              image: 'https://picsum.photos/seed/${v.id.hashCode}/720/405', // Unique image per video
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                // Fallback to the colored container on error
                return Container(
                  color: _colorFromKey(v.thumbnailKey),
                  child: const Center(child: Icon(Icons.videocam, color: Colors.white, size: 48)),
                );
              },
            ),
            Positioned(bottom: 10, right: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: Colors.black54, child: Text(_fmtDuration(v.duration), style: const TextStyle(color: Colors.white)))),
          ])),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(children: [
              CircleAvatar(backgroundColor: Colors.grey.shade700, child: const Icon(Icons.person)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(v.title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text('${v.channel} • ${v.views} views', style: const TextStyle(color: Colors.grey, fontSize: 12))])),
              IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('More options'))), icon: const Icon(Icons.more_vert))
            ]),
          )
        ]),
      ),
    );
  }

  static Color _colorFromKey(String key) {
    final n = int.tryParse(key) ?? key.hashCode;
    final palette = [Colors.indigo, Colors.teal, Colors.orange, Colors.purple, Colors.blueGrey, Colors.green];
    return palette[n % palette.length];
  }

  static String _fmtDuration(Duration d) {
    final m = d.inMinutes.toString();
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// -----------------------------
// Video list tile — YouTube-like compact card
// -----------------------------
class VideoListTile extends StatefulWidget {
  final Video video;
  final int index;
  const VideoListTile({required this.video, required this.index, Key? key}) : super(key: key);

  @override
  State<VideoListTile> createState() => _VideoListTileState();
}

class _VideoListTileState extends State<VideoListTile> with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () => _enter.forward());
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = _AppProvider.of(context);
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: GestureDetector(
        onTap: () => st.openVideo(widget.video),
        onLongPress: () => _showOptions(context),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(children: [
            // thumbnail with mini progress painter
            Stack(children: [
              // MODIFIED: Use FadeInImage for thumbnail
              FadeInImage.assetNetwork(
                placeholder: 'assets/loading.gif', // Placeholder asset (replace or remove if needed)
                image: 'https://picsum.photos/seed/${widget.video.id.hashCode}/320/180', // Unique image per video
                width: 160,
                height: 92,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  // Fallback to the colored container on error
                  return Container(
                    width: 160,
                    height: 92,
                    color: _MainFeed._colorFromKey(widget.video.thumbnailKey),
                    child: const Center(child: Icon(Icons.videocam, color: Colors.white)),
                  );
                },
              ),
              Positioned(bottom: 6, right: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), color: Colors.black54, child: Text(_fmtDuration(widget.video.duration), style: const TextStyle(color: Colors.white, fontSize: 12)))),
            ]),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.video.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(children: [Text(widget.video.channel, style: const TextStyle(color: Colors.grey)), const SizedBox(width: 10), Text('${widget.video.views} views', style: const TextStyle(color: Colors.grey)), const SizedBox(width: 10), const Text('• 1 day ago', style: TextStyle(color: Colors.grey))]),
                  const SizedBox(height: 6),
                  Text(widget.video.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ),
            IconButton(onPressed: () => _showOptions(context), icon: const Icon(Icons.more_vert))
          ]),
        ),
      ),
    );
  }

  void _showOptions(BuildContext ctx) {
    final st = _AppProvider.of(ctx);
    showModalBottomSheet(context: ctx, builder: (_) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.playlist_add), title: const Text('Add to Playlist'), onTap: () => Navigator.pop(ctx)),
        ListTile(leading: const Icon(Icons.download), title: const Text('Download'), onTap: () => Navigator.pop(ctx)),
        ListTile(leading: const Icon(Icons.share), title: const Text('Share'), onTap: () => Navigator.pop(ctx)),
        ListTile(leading: Icon(st.favorites.contains(widget.video.id) ? Icons.favorite : Icons.favorite_border), title: const Text('Toggle Favorite'), onTap: () { st.toggleFavorite(widget.video.id); Navigator.pop(ctx); }),
      ]);
    });
  }

  static String _fmtDuration(Duration d) {
    final m = d.inMinutes.toString();
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// -----------------------------
// Right rail: player, subscribe, actions, comments, related
// -----------------------------
class _RightRail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final st = _AppProvider.of(context);
    return AnimatedBuilder(
      animation: st,
      builder: (_, __) {
        final cur = st.current;
        if (cur == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Up next', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Tap a video to open it and see player + comments here.'),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: () => st.loadTrending(), child: const Text('Refresh')),
              ]),
            ),
          );
        }

        final isFav = st.favorites.contains(cur.id);
        final comms = st.comments[cur.id] ?? [];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // player placeholder
              AspectRatio(aspectRatio: 16 / 9, child: _PlayerPlaceholder(video: cur)),
              const SizedBox(height: 12),
              Text(cur.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(children: [
                CircleAvatar(backgroundColor: Colors.grey.shade700, child: const Icon(Icons.person)),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cur.channel, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text('${cur.views} views', style: const TextStyle(color: Colors.grey, fontSize: 12))])),
                // subscribe button AnimatedSwitcher
                AnimatedSwitcher(duration: const Duration(milliseconds: 300), transitionBuilder: (w, anim) => ScaleTransition(scale: anim, child: w), child: ElevatedButton(
                  key: ValueKey(isFav), // Using isFav here
                  onPressed: () => st.toggleFavorite(cur.id),
                  child: Text(isFav ? 'Subscribed' : 'Subscribe'), // Using isFav here
                  style: ElevatedButton.styleFrom(backgroundColor: isFav ? Colors.grey : Colors.red), // Using isFav here
                )),
              ]),
              const SizedBox(height: 10),
              // action buttons row like YouTube
              Row(children: [
                _ActionIcon(icon: Icons.thumb_up, label: 'Like', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Liked (simulated)')))),
                const SizedBox(width: 8),
                _ActionIcon(icon: Icons.thumb_down, label: 'Dislike', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disliked (simulated)')))),
                const SizedBox(width: 8),
                _ActionIcon(icon: Icons.share, label: 'Share', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share (simulated)')))),
                const SizedBox(width: 8),
                _ActionIcon(icon: Icons.download, label: 'Download', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download (simulated)')))),
              ]),
              const SizedBox(height: 12),
              const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // comments list
              Expanded(
                child: comms.isEmpty
                    ? const Text('No comments yet.')
                    : ListView.separated(
                        itemCount: comms.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (_, i) {
                          final c = comms[i];
                          return ListTile(
                            dense: true,
                            leading: const CircleAvatar(backgroundColor: Colors.grey),
                            title: Text(c.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(c.text),
                            trailing: Text('${c.time.hour}:${c.time.minute.toString().padLeft(2, '0')}'),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              _CommentInput(videoId: cur.id),
            ]),
          ),
        );
      },
    );
  }
}

// small action button used in actions row
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionIcon({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)]),
      ),
    );
  }
}

// -----------------------------
// Player placeholder with scrub (CustomPainter) + controls
// -----------------------------
class _PlayerPlaceholder extends StatelessWidget {
  final Video video;
  const _PlayerPlaceholder({required this.video});
  @override
  Widget build(BuildContext context) {
    final st = _AppProvider.of(context);
    final isCurrent = st.current?.id == video.id;
    final pos = isCurrent ? st.position : Duration.zero;
    final pct = video.duration.inMilliseconds == 0 ? 0.0 : pos.inMilliseconds / video.duration.inMilliseconds;

    return GestureDetector(
      onTap: () => isCurrent ? (st.playing ? st.pause() : st.play()) : st.openVideo(video),
      child: Container(
        color: Colors.black,
        child: Stack(children: [
          // ADDED: Thumbnail image for player
          FadeInImage.assetNetwork(
            placeholder: 'assets/loading.gif',
            image: 'https://picsum.photos/seed/${video.id.hashCode}/720/405',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            imageErrorBuilder: (context, error, stackTrace) {
              return Container(
                color: _MainFeed._colorFromKey(video.thumbnailKey),
                child: const Center(child: Icon(Icons.videocam, color: Colors.white, size: 48)),
              );
            },
          ),
          // Overlay for play/pause icon (make it darker for contrast)
          Container(color: Colors.black38),
          Center(child: Icon(isCurrent && st.playing ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 64, color: Colors.white70)),
          Positioned(bottom: 8, left: 12, right: 12, child: SizedBox(height: 26, child: CustomPaint(painter: _PlayerScrubPainter(progress: pct)))),
        ]),
      ),
    );
  }
}

class _PlayerScrubPainter extends CustomPainter {
  final double progress;
  _PlayerScrubPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.white12;
    final fg = Paint()..shader = LinearGradient(colors: [Colors.red, Colors.orange]).createShader(Rect.fromLTWH(0, 0, size.width * progress, size.height));
    final r = RRect.fromRectAndRadius(Rect.fromLTWH(0, size.height / 4, size.width, size.height / 2), const Radius.circular(6));
    canvas.drawRRect(r, bg);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, size.height / 4, size.width * progress, size.height / 2), const Radius.circular(6)), fg);
    // knob
    final knobX = (size.width * progress).clamp(6.0, size.width - 6.0);
    final knob = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(knobX, size.height / 2), 6, knob);
  }

  @override
  bool shouldRepaint(covariant _PlayerScrubPainter old) => old.progress != progress;
}

// -----------------------------
// Comment input form (validation) — demonstrates Forms & validation
// -----------------------------
class _CommentInput extends StatefulWidget {
  final String videoId;
  const _CommentInput({required this.videoId});
  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _text = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _text.dispose();
    super.dispose();
  }

  void _post() {
    if (!_formKey.currentState!.validate()) return;
    final app = _AppProvider.of(context);
    final c = Comment(id: '${widget.videoId}-${DateTime.now().millisecondsSinceEpoch}', author: _name.text.trim(), text: _text.text.trim(), time: DateTime.now());
    app.addComment(widget.videoId, c);
    _name.clear();
    _text.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment posted')));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name', isDense: true), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null),
        const SizedBox(height: 6),
        TextFormField(controller: _text, decoration: const InputDecoration(labelText: 'Comment', isDense: true), validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Write something';
          if (v.trim().length < 3) return 'Too short';
          return null;
        }),
        const SizedBox(height: 8),
        Row(children: [ElevatedButton(onPressed: _post, child: const Text('Post')), const SizedBox(width: 8), OutlinedButton(onPressed: () { _name.clear(); _text.clear(); }, child: const Text('Clear'))]),
      ]),
    );
  }
}

// -----------------------------
// Comment: Right rail, etc.
// -----------------------------
// (Already included as _RightRail above)

// -----------------------------
// END
// -----------------------------