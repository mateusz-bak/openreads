<!--
  Title: Openreads
  Description: A mobile books tracker written in Flutter. Free, private and open source.
  Author: mateusz-bak
  -->

# Openreads


<p align='center'>  
 <img src='doc/github/github-banner.png' width='100%'/>
</p>

[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/mateusz-bak/openreads?label=latest%20version&style=flat-square)](https://github.com/mateusz-bak/openreads/releases/latest)
[![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/mateusz-bak/openreads/test_build.yml?style=flat-square)](https://github.com/mateusz-bak/openreads/actions/workflows/test_build.yml)
[![Weblate project translated](https://img.shields.io/badge/weblate-translations_needed-orange?style=flat-square&logo=weblate)](https://hosted.weblate.org/engage/openreads/)
[![Join the community](https://img.shields.io/badge/matrix.org-join_community-teal?style=flat-square&logo=matrix)](https://matrix.to/#/#openreads:matrix.org)
<a rel="me" href='https://fosstodon.org/@openreads'><img alt="Mastodon Follow" src="https://img.shields.io/mastodon/follow/110707338082983645?domain=https%3A%2F%2Ffosstodon.org&style=flat-square&logo=mastodon&color=royalblue"></a>
<br/>

<a href='https://github.com/mateusz-bak/openreads/releases/latest'><img height=70 alt='Get it on Github' src='https://raw.githubusercontent.com/mateusz-bak/openreads/master/doc/github/get-it-on-github.png'/></a>
<a href='https://f-droid.org/en/packages/software.mdev.bookstracker'><img height=70 alt='Get it on F-Droid' src='https://fdroid.gitlab.io/artwork/badge/get-it-on.png'/></a>
<a href='https://play.google.com/store/apps/details?id=software.mdev.bookstracker'><img height=70 alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png'/></a>
<a href='https://apps.apple.com/app/id6476542305'><img height=70 alt='Download on App Store' src='https://raw.githubusercontent.com/mateusz-bak/openreads/master/doc/app_store/download_on_app_store.png'/></a>

### Openreads is a privacy oriented and open source cross-platform app written in Flutter available for Android and iOS for keeping track of your books.  
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

<br/>

<p align='left'>  
 <img src='doc/gplay/app-mockup/Google Pixel 4 XL Screenshot 0.png' width='19%'/>  
 <img src='doc/gplay/app-mockup/Google Pixel 4 XL Screenshot 1.png' width='19%'/>    
 <img src='doc/gplay/app-mockup/Google Pixel 4 XL Screenshot 2.png' width='19%'/>
 <img src='doc/gplay/app-mockup/Google Pixel 4 XL Screenshot 3.png' width='19%'/>
 <img src='doc/gplay/app-mockup/Google Pixel 4 XL Screenshot 4.png' width='19%'/>
</p>  
<br/>

## 🤝 Contributing

Do you want to support Openreads development? You are welcome to take below actions:

### 🪙 Become a Sponsor

Fund the project, or simply say thank you.

<a href='https://github.com/sponsors/mateusz-bak'><img height=50 alt='Become a GitHub Sponsor' src='https://raw.githubusercontent.com/mateusz-bak/openreads/master/doc/github/button_become-a-github-sponsor.png'/></a>
<a href="https://www.buymeacoffee.com/mateuszbak"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" height="50"></a>

### 📣 Spread the word about Openreads
#### 👍 Vote on Alternativeto.net
[Alternativeto.net link](https://alternativeto.net/software/openreads/about/)

#### 🌟 Give a star to the project
[Github.com link](https://github.com/mateusz-bak/openreads)

### 📖 Translate Openreads

Go to [Weblate](https://hosted.weblate.org/engage/openreads/) and help with the translations.

<a href="https://hosted.weblate.org/engage/openreads/">
<img src="https://hosted.weblate.org/widgets/openreads/-/multi-auto.svg" alt="Translation status" />
</a>

### 🐞 Report bugs or new ideas
Submit an issue here: [Openreads issues](https://github.com/mateusz-bak/openreads/issues).

### 📝 Contributors guide

Take a look at our [CONTRIBUTING.md](CONTRIBUTING.md) file.

## 📄 Attributions

### 👁️‍🗨️ Icons
[Font Awesome](https://fontawesome.com/ "Font Awesome")

## ❓ FAQ

- **What platforms is Openreads available for?** </br>
The app is written in the cross-platform framework Flutter. Android and iOS versions are available.
Be aware that releasing an app to the App Store requires paid Apple Developer account ($99 per year) so please consider donating.
- **Does Openreads support importing/exporting CSV file?**</br>
Yes! See format of the CSV file: 
[Openreads CSV format](doc/csv.md)
- **From which apps can Openreads import CSV files?**</br>
GoodReads, BookWyrm
- **Which data providers does OpenReads use?**</br>
Currently the one and only data source for the app is [OpenLibrary](https://openlibrary.org/), a FOSS crowdsourced library. Other sources (like BookBrainz) are considered for the future. There are no plans to add proprietary sources to the app (see: https://github.com/mateusz-bak/openreads/issues/90#issuecomment-1722339001)
- **Is it possible to upload my book's data to OpenLibrary?**</br>
Not for now; see https://github.com/mateusz-bak/openreads/issues/85

<br/>

## 🏗️ Build Process

1. Clone or download this repository

   ```sh
   git clone https://github.com/mateusz-bak/openreads.git
   cd openreads
   ```

2. Download dependencies

   ```sh
   flutter pub get
   ```

2. Build and install the app on your device<br/>
⚠️⚠️⚠️<br/>
WARNING: If you already have the Openreads app installed on your device, this step will uninstall it before installing the debug version.
This deletes all app data, to keep your books please make a backup first.<br/>
⚠️⚠️⚠️<br/>

   ```sh
   flutter run
   ```
