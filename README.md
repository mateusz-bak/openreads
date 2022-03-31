# Openreads


<p align='center'>  
 <img src='doc/github/github-banner.png' width='100%'/>
</p>

[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/mateusz-bak/openreads-android?label=latest%20version)](https://github.com/mateusz-bak/openreads-android/releases/latest)
[![Build Status](https://git-drone.mateusz.ovh/api/badges/mateusz-bak/openreads-android/status.svg)](https://git-drone.mateusz.ovh/mateusz-bak/openreads-android)
[![Crowdin](https://badges.crowdin.net/openreads-android/localized.svg)](https://crowdin.com/project/openreads-android)
<br/>

<a href='https://play.google.com/store/apps/details?id=software.mdev.bookstracker'><img height=100 alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png'/></a>
<a href='https://github.com/mateusz-bak/openreads-android/releases/latest'><img height=100 alt='Get it on Github' src='https://raw.githubusercontent.com/mateusz-bak/openreads-android/master/doc/github/get-it-on-github.png'/></a>

<br/><br/>
### Openreads is an Android app written in Kotlin for keeping tracks of your books.  
#### There are three lists provided so you won't get confused:  
- books you finished,  
- books you are currently reading,  
- books you want to read later.

#### The books can be added by:
- looking up in Open Library database,
- scanning book's barcode,
- adding book's details manually.

####  You can also see come cool statistics!  

<br/><br/>
## Screenshots  
<p align='center'>  
 <img src='doc/github/screenshot-finished_n_framed.png' width='30%'/>  
 <img src='doc/github/screenshot-display-book_n_framed.png' width='30%'/>    
 <img src='doc/github/screenshot-statistics_n_framed.png' width='30%'/>
</p>  

<br/><br/>

## Contributing

Do you want to support Openread's development? You are welcome to take below actions:

### Help translate Openreads:
Go to [Crowdin project](https://crwd.in/openreads-android) and start translating!

### Have you found a bug in Openreads?
Submit an issue here: [Openread's issues](https://github.com/mateusz-bak/openreads-android/issues).

### Do you have an idea that could improve Openreads for everyone?
Submit a feature request here: [Openread's issues](https://github.com/mateusz-bak/openreads-android/issues).

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
[Iconscout](https://iconscout.com/ "Iconscout")
