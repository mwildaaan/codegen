class MyFonts {
  List<Fonts>? fonts;

  MyFonts({this.fonts});

  MyFonts.fromJson(Map<String, dynamic> json) {
    if (json['fonts'] != null) {
      fonts = <Fonts>[];
      json['fonts'].forEach((v) {
        fonts!.add(Fonts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (fonts != null) {
      data['fonts'] = fonts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Fonts {
  String? family;
  List<Fontis>? fontis;

  Fonts({this.family, this.fontis});

  Fonts.fromJson(Map<String, dynamic> json) {
    family = json['family'];
    if (json['fonts'] != null) {
      fontis = <Fontis>[];
      json['fonts'].forEach((v) {
        fontis!.add(Fontis.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['family'] = family;
    if (fontis != null) {
      data['fonts'] = fontis!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Fontis {
  String? asset;
  int? weight;
  String? style;

  Fontis({this.asset, this.weight, this.style});

  Fontis.fromJson(Map<String, dynamic> json) {
    asset = json['asset'];
    weight = json['weight'];
    style = json['style'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['asset'] = asset;
    if (weight != null) {
      data['weight'] = weight;
    }
    if (style != null) {
      data['style'] = style;
    }
    return data;
  }
}