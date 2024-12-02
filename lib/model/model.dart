// ignore_for_file: unnecessary_null_comparison, prefer_collection_literals

import 'package:document_expire/util/utils.dart';

class Doc
{
  int? id;
  String? title;
  String? expiration;
  
  int? fqYear;
  int? fqHalfYear;
  int? fqQuarter;
  int? fqMonth;
  
  Doc(this.title, this.expiration, this.fqYear,
  this.fqHalfYear, this.fqQuarter, this.fqMonth);
  
  Doc.withId(this.id, this.title, this.expiration, this.fqYear,
  this.fqHalfYear, this.fqQuarter, this.fqMonth);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["title"] = title;
    map["expiration"] = expiration;
    map["fqYear"] = fqYear;
    map["fqHalfYear"] = fqHalfYear;
    map["fqQuarter"] = fqQuarter;
    map["fqMonth"] = fqMonth;

    if (id != null) {
      map["id"] = id;
    }
    return map;
  }

 Doc.fromObject(dynamic o) {
   id = o["id"];
   title = o["title"];
   expiration = DateUtils.TrimDate(o["expiration"]);
   fqYear = o["fqYear"]; 
   fqHalfYear = o["fqHalfYear"];
   fqQuarter = o["fqQuarter"];
   fqMonth = o["fqMonth"];
 }
}
