# Openreads


<p align='center'>  
 <img src='doc/github/github-banner.png' width='100%'/>
</p>

[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/mateusz-bak/openreads-android?label=latest%20version)](https://github.com/mateusz-bak/openreads-android/releases/latest)
[![Pull request](https://github.com/mateusz-bak/openreads-android/actions/workflows/test_build.yml/badge.svg?branch=master&event=push)](https://github.com/mateusz-bak/openreads-android/actions/workflows/test_build.yml)
[![Crowdin](https://badges.crowdin.net/openreads-android/localized.svg)](https://crowdin.com/project/openreads-android)
<br/>

<a href='https://f-droid.org/en/packages/software.mdev.bookstracker'><img height=75 alt='Get it on F-Droid' src='https://fdroid.gitlab.io/artwork/badge/get-it-on.png'/></a>
<a href='https://play.google.com/store/apps/details?id=software.mdev.bookstracker'><img height=75 alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png'/></a>
<a href='https://github.com/mateusz-bak/openreads-android/releases/latest'><img height=75 alt='Get it on Github' src='https://raw.githubusercontent.com/mateusz-bak/openreads-android/master/doc/github/get-it-on-github.png'/></a>
<br/>
<a href='https://matrix.to/#/#openreads:matrix.org'><img height=75 alt='Join the community on Element' src='https://raw.githubusercontent.com/mateusz-bak/openreads-android/master/doc/github/join_element.png'/></a>

<br/>

### Openreads is a privacy oriented and open source Android app written in Kotlin for keeping tracks of your books.  
#### There are four lists provided so you won't get confused:  
- books you finished,  
- books you are currently reading,  
- books you want to read later,
- books you didn't finish.

You can use custom tags and filter through them.

#### A book can be added by:
- looking it up in the Open Library database,
- scanning its barcode,
- adding its details manually.

####  You can also view some cool statistics!  

<br/><br/>
## Screenshots  
<p align='center'>  
 <img src='doc/github/screenshot-finished_n_framed.png' width='30%'/>  
 <img src='doc/github/screenshot-display-book_n_framed.png' width='30%'/>    
 <img src='doc/github/screenshot-statistics_n_framed.png' width='30%'/>
</p>  

<br/><br/>

## Contributing

Do you want to support Openreads development? You are welcome to take below actions:

### Help translate Openreads:
Go to [Crowdin project](https://crwd.in/openreads-android) and start translating!

### Have you found a bug in Openreads?
Submit an issue here: [Openreads issues](https://github.com/mateusz-bak/openreads-android/issues).

### Do you have an idea that could improve Openreads for everyone?
Submit a feature request here: [Openreads issues](https://github.com/mateusz-bak/openreads-android/issues).

<br/><br/>
## Build Process

### Dependencies

- Android SDK

### Build

1. Clone or download this repository

   ```sh
   git clone https://github.com/mateusz-bak/openreads-android.git
   cd openreads-android
   ```

2. Open the project in Android Studio and run it from there or build an APK directly through Gradle:

   ```sh
   ./gradlew assembleDebug
   ```

### Deploy to device/emulator

   ```sh
   ./gradlew installDebug
   ```

*You can also replace the "Debug" with "Release" to get an optimized release binary.*

<br/><br/>
## Attributions

### Contributors

#### Testing
[Wiktor Młynarczyk](https://github.com/jokereey "jokereey")


### Used APIs
[Open Library](https://openlibrary.org/ "Open Library")


### Icons and illustrations made by
[Katerina Limpitsouni](https://undraw.co/illustrations "Katerina Limpitsouni")
<br/>
[Iconscout](https://iconscout.com/ "Iconscout")
