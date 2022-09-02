import 'dart:io';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:http/http.dart';

//

_getValue(contents) sync* {
  var content = contents.split('\n');
  for (var i = 0; i < content.length; i++) {
    if (content[i].contains('<option value="')) {
      var value = content[i].split('value="')[1].split('"')[0];
      // if value is not a number, skip it
      if (int.tryParse(value) != null) {
        yield value;
      }
    }
  }
}

_getContent(contents) sync* {
  var content = contents.split('\n');
  for (var i = 0; i < content.length; i++) {
    if (content[i].contains('EPB_')) {
      String url = content[i].split('href="')[1].split('"')[0];
      String name_item = content[i].split('">')[1].split('</a>')[0];
      String name = url.split('EPB_')[1].split('.pdf')[0];
      yield {
        'category': 'EPB',
        'url': url,
        'name': '',
        'name_data': 'EPB_$name.pdf',
        'name_item': name_item
      };
    }
    if (content[i].contains('TF_')) {
      String url = content[i].split('href="')[1].split('"')[0];
      String name_item = content[i].split('">')[1].split('</a>')[0];
      String name = url.split('TF_')[1].split('.pdf')[0];
      yield {
        'category': 'TF',
        'url': url,
        'name': name,
        'name_data': 'TF_$name.pdf',
        'name_item': name_item
      };
    }
    if (content[i].contains('ErP_')) {
      String url = content[i].split('href="')[1].split('"')[0];
      String name_item = content[i].split('">')[1].split('</a>')[0];
      String name = url.split('ErP_')[1].split('.pdf')[0];
      yield {
        'category': 'ErP',
        'url': url,
        'name': '',
        'name_data': 'ErP_$name.pdf',
        'name_item': name_item
      };
    }
    if (content[i].contains('/lightbox/')) {
      String url = content[i].split('href="')[1].split('" title=')[0];
      String name_item = content[i].split(' title="')[1].split('">')[0];
      yield {
        'category': 'image',
        'url': url,
        'name': '',
        'name_data':
            '${url.replaceAll('https://www.generalbenelux.com/images/lightbox/', '')}',
        'name_item': name_item
      };
    }
  }
}

void _downloadContent(map) async {
  for (var i = 0; i < map.length; i++) {
    print(map[i]);
    var url = map[i]['url'];
    var name = map[i]['name_data'];

    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();
    response.pipe(
        File('/home/quinten/dev/archivegeneral/downloads/$name').openWrite());
  }
}

void _addToCSV(map) {
  String _getDescription(map) {
    var name;
    for (var i = 0; i < map.length; i++) {
      if (map[i]['category'] == 'TF') {
        name = map[i]['name'];
      }
    }

    var string = '<div><br></div><div>';

    for (var i = 0; i < map.length; i++) {
      if (map[i]['category'] == 'EPB') {
        '<h3 class="title-5" style="font-family: swiss_721_bt, HelveticaNeue-Light, &quot;Helvetica Neue Light&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, &quot;Lucida Grande&quot;, sans-serif; clear: both; margin: 0px 0px 1em; font-size: 20px; line-height: 1.25; color: rgb(88, 89, 91);">EPB-verslagen</h3>';

        string = string +
            '<ul class="download-list" style="overflow: hidden; padding: 0px; margin: 0px 0px 20px; list-style: none; color: rgb(88, 89, 91); font-family: HelveticaNeue-Light, &quot;Helvetica Neue Light&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, &quot;Lucida Grande&quot;, sans-serif; font-size: 16px;"><li class="download-list__item" style="margin: 0px 0px 5px; position: relative; padding: 0px 0px 0px 20px;"><a href="https://archive.org/download/general_$name/${map[i]['name_data']}" class="download-popup-trigger" data-id="3446" data-lang="be" style="color: rgb(130, 194, 65); font-weight: 700;">${map[i]['name_item']}</a></li></ul>';
      }
      if (map[i]['category'] == 'TF') {
        if (i > 0) {
          if (map[i - 1]['category'] == 'EPB') {
            string = string +
                '<h3 class="title-5" style="font-family: swiss_721_bt, HelveticaNeue-Light, &quot;Helvetica Neue Light&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, &quot;Lucida Grande&quot;, sans-serif; clear: both; margin: 0px 0px 1em; font-size: 20px; line-height: 1.25; color: rgb(88, 89, 91);">Technische fiches</h3>';
          } else if (i == 0) {
            string = string +
                '<h3 class="title-5" style="font-family: swiss_721_bt, HelveticaNeue-Light, &quot;Helvetica Neue Light&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, &quot;Lucida Grande&quot;, sans-serif; clear: both; margin: 0px 0px 1em; font-size: 20px; line-height: 1.25; color: rgb(88, 89, 91);">Technische fiches</h3>';
          }
        }

        string = string +
            '<ul class="download-list" style="overflow: hidden; padding: 0px; margin: 0px 0px 20px; list-style: none; color: rgb(88, 89, 91); font-family: HelveticaNeue-Light, &quot;Helvetica Neue Light&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, &quot;Lucida Grande&quot;, sans-serif; font-size: 16px;"><li class="download-list__item" style="margin: 0px 0px 5px; position: relative; padding: 0px 0px 0px 20px;"><a href="https://archive.org/download/general_$name/${map[i]['name_data']}" class="download-popup-trigger" data-id="3446" data-lang="be" style="color: rgb(130, 194, 65); font-weight: 700;">${map[i]['name_item']}</a></li></ul>';
      }
      if (map[i]['category'] == 'ErP') {
        if (map[i - 1]['category'] == 'TF') {
          string = string +
              '<h3 class="title-5" style="font-family: swiss_721_bt, HelveticaNeue-Light, &quot;Helvetica Neue Light&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, &quot;Lucida Grande&quot;, sans-serif; clear: both; margin: 0px 0px 1em; font-size: 20px; line-height: 1.25; color: rgb(88, 89, 91);">ErP-gegevens</h3>';
        }
        string = string +
            '<ul class="download-list" style="overflow: hidden; padding: 0px; margin: 0px 0px 20px; list-style: none; color: rgb(88, 89, 91); font-family: HelveticaNeue-Light, &quot;Helvetica Neue Light&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, &quot;Lucida Grande&quot;, sans-serif; font-size: 16px;"><li class="download-list__item" style="margin: 0px 0px 5px; position: relative; padding: 0px 0px 0px 20px;"><a href="https://archive.org/download/general_$name/${map[i]['name_data']}" class="download-popup-trigger" data-id="3438" data-lang="all" style="color: rgb(130, 194, 65); font-weight: 700;">${map[i]['name_item']}</a></li></ul>';
      }
      if (map[i]['category'] == 'image') {
        if (map[i - 1]['category'] == 'ErP') {
          string = string +
              '<br style="color: rgb(88, 89, 91); font-family: HelveticaNeue-Light, &quot;Helvetica Neue Light&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, &quot;Lucida Grande&quot;, sans-serif; font-size: 16px;"><h2 class="title-3" style="font-family: swiss_721_bt, HelveticaNeue-Light, &quot;Helvetica Neue Light&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, &quot;Lucida Grande&quot;, sans-serif; clear: both; margin: 0px 0px 1em; font-size: 24px; line-height: 1.25; color: rgb(88, 89, 91);">Afbeeldingen</h2>';
        }
        string = string +
            '<div class="grid__row" data-component="lightbox" style="width: 700px; color: rgb(88, 89, 91); font-family: HelveticaNeue-Light, &quot;Helvetica Neue Light&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, &quot;Lucida Grande&quot;, sans-serif; font-size: 16px;"><a class="grid--v-large__col--6 js-lightbox-739" href="https://archive.org/download/general_$name/${map[i]['name_data']}" title="Foto buitenuit" data-gallery="gallery" data-description="1 / 1" style="color: rgb(130, 194, 65); font-weight: 700; box-sizing: border-box; position: relative; width: 343.391px; float: left; margin-right: 13.2031px;"><img src="${map[i]['name_item']}" alt="Foto buitenuit" loading="lazy" style="border-style: none; position: relative; display: inline-block; vertical-align: top; margin-top: 0.2rem; width: auto; max-width: 100%; height: auto; margin-bottom: 20px;"></a></div>';
      }
    }

    return string + '</div>';
  }

  try {
    var description = _getDescription(map);
    description = description.replaceAll('"', '""');
    var name = map[0]['name'];
    var csv = 'general_$name,${map[0]['name_data']},"' +
        description +
        '",manual,fujitsu general,fujitsu ,general,fujitsu general $name,fujitsu general,2022,opensource_media';

    for (var i = 1; i < map.length; i++) {
      csv = csv + '\n,${map[i]['name_data']},,,,,,,,,';
    }

    new File('/home/quinten/dev/archivegeneral/downloads/upload.csv')
        .writeAsStringSync('\n$csv', mode: FileMode.append);
  } catch (e) {
    print(e);
  }
}

void main() async {
  // open index.html with dart:io
  // get value
  get_index() async {
    var address =
        Uri.parse('https://www.generalbenelux.com/nl_be/infotheek/downloads/');
    var response = await get(address);
    return await response.body.toString();
  }

  List<dynamic> value = _getValue(await get_index()).toList();

  for (var i = 0; i < value.length; i++) {
    print(value[i]);

    get_contents() async {
      var address = Uri.parse(
          'https://www.generalbenelux.com/nl_be/infotheek/downloads/?id=${value[i]}');
      var response = await get(address);
      return await response.body.toString();
    }

    _downloadContent(_getContent(await get_contents()).toList());
    _addToCSV(_getContent(await get_contents()).toList());
  }
}
