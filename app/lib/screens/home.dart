import 'package:flutter/material.dart';
import 'package:harf_ba_harf/services/app_colors.dart';
import 'package:harf_ba_harf/services/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:harf_ba_harf/widgets/past_meeting_card.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';
import 'package:harf_ba_harf/widgets/sidebar.dart';
import 'package:harf_ba_harf/widgets/upcoming_meetings_card.dart';
import 'package:harf_ba_harf/providers/upload_progress_provider.dart';
import 'package:intl/intl.dart';

// Add a RouteObserver for navigation awareness
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final int _currentNavIndex = 2;
  final List<Color> upcomingColors = UpcomingMeetingCard.colorOptions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register this page as a RouteAware
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Unregister RouteAware
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this page (e.g., from upload/detail screens)
    setState(() {}); // Triggers a one-time refresh
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('EEEE, d MMMM y').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            onSelected: (value) {
              if (value == 'live') {
                Navigator.pushNamed(
                  context,
                  '/live-transcription',
                ); // Remove .then((_) => setState(() {}));
              } else {
                Navigator.pushNamed(
                  context,
                  '/file-transcription',
                ); // Remove .then((_) => setState(() {}));
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    value: 'live',
                    child: ListTile(
                      leading: Icon(Icons.mic),
                      title: Text('Live Transcription'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'file',
                    child: ListTile(
                      leading: Icon(Icons.upload_file),
                      title: Text('File Transcription'),
                    ),
                  ),
                ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const SidebarDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Meetings Today",
                style: AppTextStyles.pageTitle.copyWith(
                  color: AppColors.blackish,
                ),
              ),
              Text(
                currentDate,
                style: AppTextStyles.subtext.copyWith(
                  color: AppColors.blackish,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/calendar');
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text("Calendar View"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.mainSageGreen,
                    textStyle: AppTextStyles.body2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Meeting>>(
                stream: Meeting.getUpcomingMeetings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading meetings"));
                  }
                  final meetings = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: meetings.length,
                    itemBuilder: (context, index) {
                      final meeting = meetings[index];
                      return UpcomingMeetingCard(
                        meeting: meeting,
                        index: index,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "History",
                    style: AppTextStyles.pageTitle.copyWith(
                      color: AppColors.blackish,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/history'),
                    child: const Text("View All"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mainSageGreen,
                      textStyle: AppTextStyles.body2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<Meeting>>(
                stream: Meeting.getPastMeetings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading meetings: \\${snapshot.error}",
                      ),
                    );
                  }
                  final pastMeetings = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pastMeetings.length,
                    itemBuilder: (context, index) {
                      final meeting = pastMeetings[index];
                      // Use Selector instead of Consumer to only rebuild the card that needs it
                      return Consumer<UploadProgressProvider>(
                        builder: (context, progressProvider, child) {
                          final progress = progressProvider.getProgress(
                            meeting.id,
                          );
                          return PastMeetingCard(
                            meeting: meeting,
                            onTap:
                                () => Navigator.pushNamed(
                                  context,
                                  '/meeting-detail',
                                  arguments: meeting,
                                ),
                            uploadProgress: progress,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingNavBar(
        context: context,
        currentIndex: _currentNavIndex,
      ),
    );
  }

  // void _navigateToDetail(BuildContext context, Meeting meeting) {
  //   Navigator.pushNamed(context, '/meeting-detail', arguments: meeting);
  // }
}

// NOTE: To enable RouteAware, ensure you add the routeObserver to your MaterialApp:
// MaterialApp(
//   navigatorObservers: [routeObserver],
//   ...
// )
