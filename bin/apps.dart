import 'dart:convert';
import 'dart:io';

//todo: deserialize json, use built_value
class Apps {
  List json;

  List<String> get getPackages =>
      json.map((app) => app['package']).toList().cast<String>();

  Apps() {
    json = jsonDecode(File('apps.json').readAsStringSync());
  }

  String getLatestVersion(String package) =>
      json.where((app) => app['package'] == package).toList()[0]
          ['latest_version'];

  List getChangelog(String package) =>
      json.where((app) => app['package'] == package).toList()[0]['versions'];

  List<String> getPlatforms(String package) =>
      json.where((app) => app['package'] == package).toList()[0]['platforms'];
}
