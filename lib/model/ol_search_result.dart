import 'dart:convert';

OLSearchResult openLibrarySearchResultFromJson(String str) =>
    OLSearchResult.fromJson(json.decode(str));

class OLSearchResult {
  OLSearchResult({
    this.numFound,
    this.start,
    this.numFoundExact,
    required this.docs,
    this.openLibrarySearchResultNumFound,
    this.q,
    this.offset,
  });

  final int? numFound;
  final int? start;
  final bool? numFoundExact;
  final List<OLSearchResultDoc> docs;
  final int? openLibrarySearchResultNumFound;
  final String? q;
  final dynamic offset;

  factory OLSearchResult.fromJson(Map<String, dynamic> json) => OLSearchResult(
        numFound: json["numFound"],
        start: json["start"],
        numFoundExact: json["numFoundExact"],
        docs: List<OLSearchResultDoc>.from(
            json["docs"].map((x) => OLSearchResultDoc.fromJson(x))),
        openLibrarySearchResultNumFound: json["num_found"],
        q: json["q"],
        offset: json["offset"],
      );
}

class OLSearchResultDoc {
  OLSearchResultDoc({
    this.key,
    this.type,
    this.seed,
    this.title,
    this.titleSuggest,
    this.editionCount,
    this.editionKey,
    this.publishDate,
    this.publishYear,
    this.firstPublishYear,
    this.medianPages,
    this.lccn,
    this.publishPlace,
    this.oclc,
    this.contributor,
    this.lcc,
    this.ddc,
    this.isbn,
    this.lastModifiedI,
    this.ebookCountI,
    this.ebookAccess,
    this.hasFulltext,
    this.publicScanB,
    this.ia,
    this.iaCollection,
    this.iaCollectionS,
    this.lendingEditionS,
    this.lendingIdentifierS,
    this.printdisabledS,
    this.coverEditionKey,
    this.coverI,
    this.firstSentence,
    this.publisher,
    this.language,
    this.authorKey,
    this.authorName,
    this.authorAlternativeName,
    this.person,
    this.place,
    this.subject,
    this.idAlibrisId,
    this.idAmazon,
    this.idBodleianOxfordUniversity,
    this.idDepsitoLegal,
    this.idGoodreads,
    this.idGoogle,
    this.idHathiTrust,
    this.idLibrarything,
    this.idPaperbackSwap,
    this.idWikidata,
    this.idYakaboo,
    this.iaLoadedId,
    this.iaBoxId,
    this.publisherFacet,
    this.personKey,
    this.placeKey,
    this.personFacet,
    this.subjectFacet,
    this.version,
    this.placeFacet,
    this.lccSort,
    this.authorFacet,
    this.subjectKey,
    this.ddcSort,
    this.idAmazonCaAsin,
    this.idAmazonCoUkAsin,
    this.idAmazonDeAsin,
    this.idAmazonItAsin,
    this.idCanadianNationalLibraryArchive,
    this.idOverdrive,
    this.idAbebooksDe,
    this.idBritishLibrary,
    this.idBritishNationalBibliography,
    this.time,
    this.timeFacet,
    this.timeKey,
    this.subtitle,
  });

  final String? key;
  final Type? type;
  final List<String>? seed;
  final String? title;
  final String? titleSuggest;
  final int? editionCount;
  final List<String>? editionKey;
  final List<String>? publishDate;
  final List<int>? publishYear;
  final int? firstPublishYear;
  final int? medianPages;
  final List<String>? lccn;
  final List<String>? publishPlace;
  final List<String>? oclc;
  final List<String>? contributor;
  final List<String>? lcc;
  final List<String>? ddc;
  final List<String>? isbn;
  final int? lastModifiedI;
  final int? ebookCountI;
  final EbookAccess? ebookAccess;
  final bool? hasFulltext;
  final bool? publicScanB;
  final List<String>? ia;
  final List<String>? iaCollection;
  final String? iaCollectionS;
  final String? lendingEditionS;
  final String? lendingIdentifierS;
  final String? printdisabledS;
  final String? coverEditionKey;
  final int? coverI;
  final List<String>? firstSentence;
  final List<String>? publisher;
  final List<String>? language;
  final List<String>? authorKey;
  final List<String>? authorName;
  final List<String>? authorAlternativeName;
  final List<String>? person;
  final List<String>? place;
  final List<String>? subject;
  final List<String>? idAlibrisId;
  final List<String>? idAmazon;
  final List<String>? idBodleianOxfordUniversity;
  final List<String>? idDepsitoLegal;
  final List<String>? idGoodreads;
  final List<String>? idGoogle;
  final List<String>? idHathiTrust;
  final List<String>? idLibrarything;
  final List<String>? idPaperbackSwap;
  final List<String>? idWikidata;
  final List<String>? idYakaboo;
  final List<String>? iaLoadedId;
  final List<String>? iaBoxId;
  final List<String>? publisherFacet;
  final List<String>? personKey;
  final List<String>? placeKey;
  final List<String>? personFacet;
  final List<String>? subjectFacet;
  final double? version;
  final List<String>? placeFacet;
  final String? lccSort;
  final List<String>? authorFacet;
  final List<String>? subjectKey;
  final String? ddcSort;
  final List<String>? idAmazonCaAsin;
  final List<String>? idAmazonCoUkAsin;
  final List<String>? idAmazonDeAsin;
  final List<String>? idAmazonItAsin;
  final List<String>? idCanadianNationalLibraryArchive;
  final List<String>? idOverdrive;
  final List<String>? idAbebooksDe;
  final List<String>? idBritishLibrary;
  final List<String>? idBritishNationalBibliography;
  final List<String>? time;
  final List<String>? timeFacet;
  final List<String>? timeKey;
  final String? subtitle;

  factory OLSearchResultDoc.fromJson(Map<String, dynamic> json) =>
      OLSearchResultDoc(
        key: json["key"],
        type: json["type"] == null ? null : typeValues.map[json["type"]],
        seed: json["seed"] == null
            ? null
            : List<String>.from(json["seed"].map((x) => x)),
        title: json["title"],
        titleSuggest: json["title_suggest"],
        editionCount: json["edition_count"],
        editionKey: json["edition_key"] == null
            ? null
            : List<String>.from(json["edition_key"].map((x) => x)),
        publishDate: json["publish_date"] == null
            ? null
            : List<String>.from(json["publish_date"].map((x) => x)),
        publishYear: json["publish_year"] == null
            ? null
            : List<int>.from(json["publish_year"].map((x) => x)),
        firstPublishYear: json["first_publish_year"],
        medianPages: json["number_of_pages_median"],
        lccn: json["lccn"] == null
            ? null
            : List<String>.from(json["lccn"].map((x) => x)),
        publishPlace: json["publish_place"] == null
            ? null
            : List<String>.from(json["publish_place"].map((x) => x)),
        oclc: json["oclc"] == null
            ? null
            : List<String>.from(json["oclc"].map((x) => x)),
        contributor: json["contributor"] == null
            ? null
            : List<String>.from(json["contributor"].map((x) => x)),
        lcc: json["lcc"] == null
            ? null
            : List<String>.from(json["lcc"].map((x) => x)),
        ddc: json["ddc"] == null
            ? null
            : List<String>.from(json["ddc"].map((x) => x)),
        isbn: json["isbn"] == null
            ? null
            : List<String>.from(json["isbn"].map((x) => x)),
        lastModifiedI: json["last_modified_i"],
        ebookCountI: json["ebook_count_i"],
        ebookAccess: json["ebook_access"] == null
            ? null
            : ebookAccessValues.map[json["ebook_access"]],
        hasFulltext: json["has_fulltext"],
        publicScanB: json["public_scan_b"],
        ia: json["ia"] == null
            ? null
            : List<String>.from(json["ia"].map((x) => x)),
        iaCollection: json["ia_collection"] == null
            ? null
            : List<String>.from(json["ia_collection"].map((x) => x)),
        iaCollectionS: json["ia_collection_s"],
        lendingEditionS: json["lending_edition_s"],
        lendingIdentifierS: json["lending_identifier_s"],
        printdisabledS: json["printdisabled_s"],
        coverEditionKey: json["cover_edition_key"],
        coverI: json["cover_i"],
        firstSentence: json["first_sentence"] == null
            ? null
            : List<String>.from(json["first_sentence"].map((x) => x)),
        publisher: json["publisher"] == null
            ? null
            : List<String>.from(json["publisher"].map((x) => x)),
        language: json["language"] == null
            ? null
            : List<String>.from(json["language"].map((x) => x)),
        authorKey: json["author_key"] == null
            ? null
            : List<String>.from(json["author_key"].map((x) => x)),
        authorName: json["author_name"] == null
            ? null
            : List<String>.from(json["author_name"].map((x) => x)),
        authorAlternativeName: json["author_alternative_name"] == null
            ? null
            : List<String>.from(json["author_alternative_name"].map((x) => x)),
        person: json["person"] == null
            ? null
            : List<String>.from(json["person"].map((x) => x)),
        place: json["place"] == null
            ? null
            : List<String>.from(json["place"].map((x) => x)),
        subject: json["subject"] == null
            ? null
            : List<String>.from(json["subject"].map((x) => x)),
        idAlibrisId: json["id_alibris_id"] == null
            ? null
            : List<String>.from(json["id_alibris_id"].map((x) => x)),
        idAmazon: json["id_amazon"] == null
            ? null
            : List<String>.from(json["id_amazon"].map((x) => x)),
        idBodleianOxfordUniversity:
            json["id_bodleian__oxford_university"] == null
                ? null
                : List<String>.from(
                    json["id_bodleian__oxford_university"].map((x) => x)),
        idDepsitoLegal: json["id_depósito_legal"] == null
            ? null
            : List<String>.from(json["id_depósito_legal"].map((x) => x)),
        idGoodreads: json["id_goodreads"] == null
            ? null
            : List<String>.from(json["id_goodreads"].map((x) => x)),
        idGoogle: json["id_google"] == null
            ? null
            : List<String>.from(json["id_google"].map((x) => x)),
        idHathiTrust: json["id_hathi_trust"] == null
            ? null
            : List<String>.from(json["id_hathi_trust"].map((x) => x)),
        idLibrarything: json["id_librarything"] == null
            ? null
            : List<String>.from(json["id_librarything"].map((x) => x)),
        idPaperbackSwap: json["id_paperback_swap"] == null
            ? null
            : List<String>.from(json["id_paperback_swap"].map((x) => x)),
        idWikidata: json["id_wikidata"] == null
            ? null
            : List<String>.from(json["id_wikidata"].map((x) => x)),
        idYakaboo: json["id_yakaboo"] == null
            ? null
            : List<String>.from(json["id_yakaboo"].map((x) => x)),
        iaLoadedId: json["ia_loaded_id"] == null
            ? null
            : List<String>.from(json["ia_loaded_id"].map((x) => x)),
        iaBoxId: json["ia_box_id"] == null
            ? null
            : List<String>.from(json["ia_box_id"].map((x) => x)),
        publisherFacet: json["publisher_facet"] == null
            ? null
            : List<String>.from(json["publisher_facet"].map((x) => x)),
        personKey: json["person_key"] == null
            ? null
            : List<String>.from(json["person_key"].map((x) => x)),
        placeKey: json["place_key"] == null
            ? null
            : List<String>.from(json["place_key"].map((x) => x)),
        personFacet: json["person_facet"] == null
            ? null
            : List<String>.from(json["person_facet"].map((x) => x)),
        subjectFacet: json["subject_facet"] == null
            ? null
            : List<String>.from(json["subject_facet"].map((x) => x)),
        version:
            json["_version_"] == null ? null : json["_version_"].toDouble(),
        placeFacet: json["place_facet"] == null
            ? null
            : List<String>.from(json["place_facet"].map((x) => x)),
        lccSort: json["lcc_sort"],
        authorFacet: json["author_facet"] == null
            ? null
            : List<String>.from(json["author_facet"].map((x) => x)),
        subjectKey: json["subject_key"] == null
            ? null
            : List<String>.from(json["subject_key"].map((x) => x)),
        ddcSort: json["ddc_sort"],
        idAmazonCaAsin: json["id_amazon_ca_asin"] == null
            ? null
            : List<String>.from(json["id_amazon_ca_asin"].map((x) => x)),
        idAmazonCoUkAsin: json["id_amazon_co_uk_asin"] == null
            ? null
            : List<String>.from(json["id_amazon_co_uk_asin"].map((x) => x)),
        idAmazonDeAsin: json["id_amazon_de_asin"] == null
            ? null
            : List<String>.from(json["id_amazon_de_asin"].map((x) => x)),
        idAmazonItAsin: json["id_amazon_it_asin"] == null
            ? null
            : List<String>.from(json["id_amazon_it_asin"].map((x) => x)),
        idCanadianNationalLibraryArchive:
            json["id_canadian_national_library_archive"] == null
                ? null
                : List<String>.from(
                    json["id_canadian_national_library_archive"].map((x) => x)),
        idOverdrive: json["id_overdrive"] == null
            ? null
            : List<String>.from(json["id_overdrive"].map((x) => x)),
        idAbebooksDe: json["id_abebooks_de"] == null
            ? null
            : List<String>.from(json["id_abebooks_de"].map((x) => x)),
        idBritishLibrary: json["id_british_library"] == null
            ? null
            : List<String>.from(json["id_british_library"].map((x) => x)),
        idBritishNationalBibliography:
            json["id_british_national_bibliography"] == null
                ? null
                : List<String>.from(
                    json["id_british_national_bibliography"].map((x) => x)),
        time: json["time"] == null
            ? null
            : List<String>.from(json["time"].map((x) => x)),
        timeFacet: json["time_facet"] == null
            ? null
            : List<String>.from(json["time_facet"].map((x) => x)),
        timeKey: json["time_key"] == null
            ? null
            : List<String>.from(json["time_key"].map((x) => x)),
        subtitle: json["subtitle"],
      );
}

enum EbookAccess { borrowable, noEbook, public, printdisabled }

final ebookAccessValues = EnumValues({
  "borrowable": EbookAccess.borrowable,
  "no_ebook": EbookAccess.noEbook,
  "printdisabled": EbookAccess.printdisabled,
  "public": EbookAccess.public
});

enum Type { work }

final typeValues = EnumValues({"work": Type.work});

class EnumValues<T> {
  Map<String, T> map;

  EnumValues(this.map);
}
