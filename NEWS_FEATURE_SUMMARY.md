# News Feature - MVVM Architecture Summary

**Date:** 04/11/2025  
**Feature Location:** `lib/src/features/news`

---

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [MVVM Components](#mvvm-components)
3. [Feature Structure](#feature-structure)
4. [User-Level Usage](#user-level-usage)
5. [Data Flow](#data-flow)

---

## 🏗️ Architecture Overview

The News feature follows **MVVM (Model-View-ViewModel)** architecture pattern using **Flutter Riverpod** for state management:

- **Model**: Data classes representing API responses and business entities
- **View**: Flutter widgets (screens and UI components)
- **ViewModel**: Riverpod `StateNotifier` controllers managing business logic and state
- **Repository/Service**: Data layer handling API calls and data fetching

---

## 📦 MVVM Components

### 1. **MODELS** (`data/model/`)

#### Posts Models
- **`posts/all/posts_Model.dart`**: `PostsModel` class
  - Represents a news post/article
  - Fields: `id`, `title`, `description`, `layout`, `media`, `channel`, `views`, `likes`, `dislikes`, `comments`, `whatsApp`, `time`, etc.
  - Supports JSON serialization/deserialization

- **`posts/all/postsPaginationModel.dart`**: `PostsPagination` class
  - State model for paginated posts list
  - Contains: `posts` list, `page` number, `errorMessage`
  - Methods: `copyWith()`, `clearPosts()`, `postViews()`, `likes()`, `whatsShare()`, `commentCount()`

- **`posts/individual/postIndividualModel.dart`**: Model for single post view
- **`posts/postModelById.dart`**: Model for fetching post by ID

#### Topics Models
- **`topics/topics_Model.dart`**: `TopicsModel` class
  - Represents news topic/category
  - Fields: `id`, `name`, `icon`, `type` (e.g., 'political', 'landmark')

#### Politicians Models
- **`politician/politicians_Model.dart`**: `PoliticianModel` class
  - Represents politician/political figure
  - Fields: `id`, `name`, `profile` (image), `type`, `status` (follow/unfollow)

#### Comments Models
- **`comments/all/commentsModel.dart`**: 
  - `CommentsModel`: Main comment data
  - `ReplyComments`: Reply to comment data
  - Fields: `id`, `userId`, `username`, `userImage`, `commentData`, `likes`, `dislikes`, `replyCount`

- **`comments/all/commentsPagination.dart`**: Pagination state for comments
- **`comments/reply/replyCommentsPagination.dart`**: Pagination state for reply comments

---

### 2. **REPOSITORIES/SERVICES** (`data/repository/`)

#### Post Services
- **`post/all/postPaginationService.dart`**: `PostPaginationService`
  - `fetchPosts()`: Fetches paginated posts from API + RSS feeds
  - Combines API posts and RSS feed posts
  - Filters by topicId and topicType
  - Sorts by time (newest first)

- **`post/individual/postIndividualService.dart`**: Fetches single post by ID

#### Topics Service
- **`topics/topicsService.dart`**: `TopicsService`
  - Fetches available news topics/categories

#### Politicians Service
- **`politician/politiciansServices.dart`**: `PoliticiansService`
  - Fetches list of politicians
  - Handles follow/unfollow status

#### Comments Services
- **`comments/all/commentsPaginationService.dart`**: Fetches paginated comments
- **`comments/reply/replyCommentsPaginationService.dart`**: Fetches reply comments

---

### 3. **VIEWMODELS/CONTROLLERS** (`viewmodel/`)

All controllers use **Riverpod StateNotifierProvider** pattern:

#### Post Controllers
- **`post/all/postPaginationController.dart`**: `PostPaginationController`
  - Manages paginated posts list state
  - Methods:
    - `getPosts()`: Loads more posts (pagination)
    - `resetPosts()`: Resets and refreshes posts
    - `postViews()`: Updates view count
    - `likes()`: Handles like/dislike actions
    - `whatsShare()`: Updates WhatsApp share count
    - `commentsCount()`: Updates comment count
    - `handleScrollWithIndex()`: Auto-loads more on scroll

- **`post/single/postIndividualController.dart`**: `PostIndividualController`
  - Manages single post view state
  - Fetches individual post by ID

#### Topics Controller
- **`topics/topicsController.dart`**: `TopicsController`
  - Manages topics list state
  - Methods:
    - `getTopics()`: Fetches topics
    - `resetTopics()`: Clears topics
    - `newTopic()`: Adds/removes topic (for following)

#### Politicians Controller
- **`politician/politiciansControllers.dart`**: `PoliticiansController`
  - Manages politicians list state
  - Methods:
    - `getPoliticians()`: Fetches politicians
    - `resetPoliticians()`: Clears list
    - `updateStatus()`: Toggles follow/unfollow status

#### Comments Controllers
- **`comments/all/commentsPaginationController.dart`**: `CommentsPaginationController`
  - Manages comments pagination
  - Methods:
    - `getComments()`: Loads more comments
    - `newComment()`: Adds new comment
    - `likes()`: Handles comment likes/dislikes

- **`comments/reply/replyCommentsPaginationController.dart`**: Manages reply comments

---

### 4. **VIEWS** (`view/`)

#### Screens
- **`screens/news_dashboard.dart`**: `NewsDashboard` - Main news feed screen
  - Displays horizontal topics filter bar
  - Shows paginated posts list with infinite scroll
  - Pull-to-refresh functionality
  - Politicians section (for political topic)
  - Search functionality
  - Social interaction buttons (like, share, comment)

- **`screens/post/all/postViewScreen.dart`**: List view of posts
- **`screens/post/single/postViewSingle.dart`**: Individual post detail screen

- **`screens/comments/all/commentsScreen.dart`**: Comments list screen
- **`screens/comments/reply/replyCommentsScreen.dart`**: Reply comments screen
- **`screens/comments/single/newCommentScreen.dart`**: Add new comment screen

- **`screens/search/searchScreen.dart`**: News search screen
- **`screens/followers/followers.dart`**: Followers list (for politicians)

#### Widgets
- **`widgets/newsLayoutComponent.dart`**: Reusable news card component
- **`widgets/news_shimmer.dart`**: Loading shimmer effect
- **`widgets/topicListComponent.dart`**: Topic chip/button component
- **`widgets/politiciansLayout.dart`**: Politician card component
- **`widgets/socialBanner.dart`**: Like/share/comment action bar
- **`widgets/videoItem.dart`**: Video player component

#### RSS Utilities
- **`rss/feed_parser.dart`**: Parses RSS feeds
- **`rss/rss_utils.dart`**: RSS feed utilities and configuration

---

## 🎯 User-Level Usage

### How Users Access the News Feature

1. **Entry Point**: 
   - News feature is accessed from the main `DashBoardScreen` (home screen)
   - It's the **first tab** (index 0) in the bottom navigation bar
   - Located at: `lib/src/features/home/dashboardScreen.dart`

```dart
final List<Widget> _tabs = [
  NewsDashboard(),  // First tab - News feature
  JobComing(),
  ListingComing(),
  GreetingsDashboard(),
];
```

2. **Navigation Flow**:
   ```
   App Launch → SplashScreen → DashBoardScreen → NewsDashboard (Default Tab)
   ```

### User Experience Flow

#### 1. **Main News Dashboard** (`NewsDashboard`)
   - **Search Bar**: Tap to search news articles
   - **Topics Filter**: Horizontal scrollable list of topics (e.g., Political, Sports, Technology)
     - Tap a topic to filter posts
   - **Posts Feed**: 
     - Infinite scroll (loads more as user scrolls)
     - Pull down to refresh
     - Each post shows:
       - Title, description, media (image/video)
       - Channel name and logo
       - View count, like/dislike buttons
       - Share button (WhatsApp)
       - Comment count
   - **Politicians Section** (for political topic):
     - Horizontal list of politicians
     - Follow/Unfollow buttons
     - "More" button to see all followers

#### 2. **Post Interactions**
   - **Tap Post**: Opens `PostViewScreen` (detailed view)
   - **Like/Dislike**: Updates count immediately
   - **Share**: Shares via WhatsApp
   - **Comment**: Opens comments screen
   - **View Count**: Increments when post is viewed

#### 3. **Comments Flow**
   - Tap comment count → Opens `CommentsScreen`
   - View all comments with pagination
   - Add new comment
   - Reply to comments
   - Like/dislike comments

#### 4. **Search Flow**
   - Tap search bar → Opens `SearchScreen`
   - Search for news articles
   - Filter by keywords

#### 5. **Politicians Feature** (Political Topic)
   - View politicians in horizontal scroll
   - Tap "Follow" to follow a politician
   - Tap "Followers" button → Opens `Followers` screen
   - See all followed politicians

---

## 🔄 Data Flow

### Typical User Action Flow:

```
User Action (e.g., Tap Post)
    ↓
View (NewsDashboard) → Calls Controller Method
    ↓
ViewModel (PostPaginationController) → Calls Service
    ↓
Repository/Service (PostPaginationService) → API Call / RSS Feed
    ↓
Model (PostsModel) → Data Parsed
    ↓
State Updated (Riverpod StateNotifier)
    ↓
UI Rebuilds (View watches state)
```

### State Management Flow:

1. **Riverpod Providers** watch topicId and topicType
2. **Controllers** react to provider changes
3. **Services** fetch data from API/RSS
4. **Models** represent data structure
5. **Views** rebuild when state changes

---

## 📊 Key Features

### 1. **Pagination**
- Infinite scroll loading
- Page-based pagination
- Auto-loads when scrolling near end

### 2. **Multi-Source Data**
- Combines API posts and RSS feed posts
- Filters by topic
- Sorts by time (newest first)

### 3. **Real-time Updates**
- View counts update immediately
- Like/dislike updates instantly
- Comment counts sync
- Share counts tracked

### 4. **Topic Filtering**
- Dynamic topic selection
- Updates posts list based on selected topic
- Special handling for "political" topic (shows politicians)

### 5. **Social Features**
- Like/Dislike posts
- Comment on posts
- Reply to comments
- Share via WhatsApp
- Follow politicians

---

## 🔌 Integration Points

### App-Level Integration:
- **Main Entry**: `DashBoardScreen` includes `NewsDashboard` as first tab
- **Providers**: Uses Riverpod providers from `src/core/providers/`
- **Navigation**: Uses Flutter Navigator for screen transitions
- **Deep Links**: Supports Firebase Dynamic Links for direct post access
- **Notifications**: Handles push notifications for new posts

### Dependencies:
- `flutter_riverpod`: State management
- `http`: API calls
- `youtube_player_flutter`: Video playback
- `lazy_load_scrollview`: Infinite scroll
- `hive_flutter`: Local storage (user data)
- `firebase_messaging`: Push notifications

---

## 📝 Notes

- All controllers use Riverpod `StateNotifier` pattern
- Error handling is implemented in all services
- RSS feeds are parsed and combined with API data
- Politicians feature is only visible for "political" topic
- YouTube video thumbnails are auto-generated from video URLs
- Shimmer loading effects provide smooth UX during data fetch

---

**End of Summary**

