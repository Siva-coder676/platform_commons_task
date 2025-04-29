# platform_commons_task

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Description About the App Project

  I implemented this app using Flutter state management. The app was built using the Dio package as the network client, and we used model classes for parsing data. We utilized the Workmanager plugin for scheduling background tasks efficiently, and SQLite database for data storing and retrieving purposes.

  I will explain these steps one by one:

  1. The main.dart file is the starting point of the application.

  2. I created a user list screen for showing a list of users, adding pagination functionality according to page number for showing infinite users based on pagination response.

  3. I created an AddUserScreen for storing users to the backend database via API. There I implemented two TextFormFields to get name and job information and push that object to the backend.

  4. I created a MovieListScreen to display movies. There I also implemented pagination functionality to load infinite movies according to the page.

  5. I created a MovieDetailScreen to show the details of a movie. If the user clicks on a particular movie on the movie list screen, it will navigate to the MovieDetailScreen.

  6. I have used dependency injection using get_it package to access the service instance objects.

  Challenges I Faced During This App:

  In my previous app development, I used the shared preferences plugin for local storage, but here I implemented SQLite database. This was a little challenging for me, but I gained some experience with this package and database. Similarly, the Workmanager plugin was new to me, but I learned a lot while implementing this feature and gained some experience with it. I also implemented connectivity functionality - if the network is off, the data comes from the local database, and if the network is on, the data comes from the REST API.

  These are the challenges and experiences I had while developing this app.RetryClaude can make mistakes. Please double-check responses.
