import 'package:hive/hive.dart';
import 'package:jaguar/jaguar.dart';

import 'apps.dart';

void main() async {
  await Hive.init('data');
  await Hive.openBox('analytics');

  //todo: taking into consideration platform when checking version
  final server = Jaguar(port: 7800);
  server.get('/versions', (Context ctx) {
    if (!ctx.query.containsKey('package')) {
      return Response.json(
          {'ok': false, 'error': 'package parameter is required'});
    }
    if (!ctx.query.containsKey('version')) {
      return Response.json(
          {'ok': false, 'error': 'version parameter is required'});
    }
    if (!ctx.query.containsKey('platform')) {
      return Response.json(
          {'ok': false, 'error': 'platform parameter is required'});
    }

    var apps = Apps();
    if (!apps.getPackages.contains(ctx.query['package'])) {
      return Response.json({'ok': false, 'error': 'app doesn\'t exist'});
    }

    analytics(
        ctx.query['package'],
        ctx.query['platform'],
        ctx.query['version'],
        ctx.query.containsKey('platform_version')
            ? ctx.query['platform_version']
            : null);

    if (ctx.query['version'] == apps.getLatestVersion(ctx.query['package'])) {
      return Response.json({'ok': true, 'latest': true});
    }
    if (ctx.query['version'] != apps.getLatestVersion(ctx.query['package'])) {
      return Response.json({
        'ok': true,
        'latest': false,
        'latest_version': apps.getLatestVersion(ctx.query['package']),
        'changelog': apps.getChangelog(ctx.query['package'])
      });
    }
    throw Exception();
  });

  server.get('/analytics', (Context ctx) {
    if (!ctx.query.containsKey('package')) {
      return Response.json(
          {'ok': false, 'error': 'package parameter is required'});
    }
    if (!ctx.query.containsKey('version')) {
      return Response.json(
          {'ok': false, 'error': 'version parameter is required'});
    }
    if (!ctx.query.containsKey('platform')) {
      return Response.json(
          {'ok': false, 'error': 'platform parameter is required'});
    }

    var apps = Apps();
    if (!apps.getPackages.contains(ctx.query['package'])) {
      return Response.json({'ok': false, 'error': 'app doesn\'t exist'});
    }

    analytics(
        ctx.query['package'],
        ctx.query['platform'],
        ctx.query['version'],
        ctx.query.containsKey('platform_version')
            ? ctx.query['platform_version']
            : null);

    return Response.json({'ok': true});
  });

  await server.serve();
}

void analytics(String package, String platform, String version, String args) {
  List data = Hive.box('analytics').get(package, defaultValue: []);
  data.add({
    'platform': platform,
    'args': args,
    'version': version,
    'date': DateTime.now().toIso8601String()
  });
  Hive.box('analytics').put(package, data);
}
