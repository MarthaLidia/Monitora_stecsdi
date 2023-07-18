/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-12
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.utils;

/// Clase utilitaria que permite hacer las peticiones de http al servidor.
class UtilsHttp {
  static String? cookieInfo = '';

  static Future auth({required String user, required String pass}) async {
    var response = await http.get(
      finalPath(url: 'login'),
      headers: <String, String>{
        'authorization': 'Basic ${base64Encode(utf8.encode('$user:$pass'))}',
      },
    );

    if (response.body != '') {
      throw response.body.replaceAll('"', '');
    } else if (response.headers.containsKey('set-cookie')) {
      UtilsHttp.cookieInfo = response.headers['set-cookie']!;
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString('cookie', UtilsHttp.cookieInfo!);
    }
    return response;
  }

  static Map<String, String> get utilsHeaders => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'cookie': UtilsHttp.cookieInfo ?? '',
      };

  static Future<T> get<T>({
    required String url,
    Map<String, String> headers = const {},
    Map<String, String> urlParams = const {},
    Map<String, dynamic>? queryParams = const {},
    bool isPeople = false,
  }) async {
    try {
      var finalUrl = finalPath(
        url: url,
        isPeople: isPeople,
        urlParams: urlParams,
        queryParams: queryParams,
      );
      print(finalUrl);
      var innerHeaders = utilsHeaders;
      innerHeaders.addAll(headers);
      var res = await http.get(
        finalUrl,
        headers: innerHeaders,
      );
      return finalResponse<T>(res, finalUrl.toString());
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<T> post<T, E extends UtilsRequestWrapper>({
    required String url,
    required E body,
    Map<String, String> headers = const {},
    Map<String, String> urlParams = const {},
    Map<String, dynamic>? queryParams = const {},
  }) async {
    try {
      var finalUrl = finalPath(
        url: url,
        urlParams: urlParams,
        queryParams: queryParams,
      );
      var innerHeaders = utilsHeaders;
      innerHeaders.addAll(headers);

      var res = await http.post(
        finalUrl,
        headers: innerHeaders,
        body: jsonEncode(body.toJson()),
        encoding: Encoding.getByName('UTF-8'),
      );
      return finalResponse<T>(res, finalUrl.toString());
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<T> finalResponse<T>(http.Response res, String url) async {
    var response = json.decode(utf8.decoder.convert(res.bodyBytes));
    try {
      if (res.statusCode == 204) {
        throw 'ER-00';
      } else if (res.statusCode != 200) {
        throw 'ER-XX';
      } else if (url.contains('whoami')) {
        return response;
      } else if (response['code'] != 'EX-01') {
        throw response['code'];
      }

      if (response['result'] != null) {
        return response['result'];
      }
      dynamic empty;
      return empty;
    } catch (error) {
      throw response;
    }
  }

  static Uri finalPath({
    required String url,
    bool isPeople = false,
    Map<String, String>? urlParams,
    Map<String, dynamic>? queryParams,
  }) {
    var finalUrl = '/api/$url';
    urlParams?.forEach((key, value) {
      finalUrl = finalUrl.replaceAll(':$key', value);
    });
    /*return Uri.http(*/
    return Uri.https(
      isPeople ? UtilsConstants.apiUrlPeople : UtilsConstants.apiUrl,
      finalUrl,
      queryParams,
    );
  }

  static Future<bool> checkConnectivity() async {
    try {
      final response = await InternetAddress.lookup(UtilsConstants.host);
      if (response.isNotEmpty) {
        return true;
      }
    } on SocketException catch (err) {
      if (kDebugMode) {
        print('[ERROR]: $err');
      }
    }
    return false;
  }

  static handleError(dynamic error, {String? location}) {
    if (kDebugMode) {
      print('ERROR${location != null ? ' | $location' : ''}: $error');
    }

    if (error['result'] != null && error['result'].runtimeType == String) {
      UtilsToast.showDanger(error['result']);
    }
  }
}
